# DIAGNOSTIC: Production Login Failure (10+ days)

**Date:** 2025-11-24
**Issue:** Login fails for existing user (<damian.seguin@gmail.com>) but works for newly registered accounts
**Severity:** P0 - Blocks production use
**For:** NARs

---

## SYMPTOMS

### What Works ✅

- Backend API health check: `{"ok":true,"database":true,"prompt_system":true}`
- User registration: New accounts can be created
- Login with newly created accounts: <testuser@test.com> logs in successfully
- Database connectivity: All connection pool operations working

### What Fails ❌

- Login for <damian.seguin@gmail.com>: Always returns `{"detail":"Invalid credentials"}`
- Frontend JavaScript error: `bindPS101TextareaInput is not defined` (in console)
- User reports: "i have done this every time and it has never worked" (10+ days)

---

## EVIDENCE FROM TESTING (2025-11-24)

```bash
# Test 1: Backend Health - PASSES
curl https://what-is-my-delta-site-production.up.render.app/health
# Result: {"ok":true,"database":true,"prompt_system":true}

# Test 2: Register New Account - WORKS
curl -X POST https://what-is-my-delta-site-production.up.render.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"testuser@test.com","password":"testpass123"}'
# Result: {"user_id":"6c27a2bf-bf11-4d27-ad8c-e52631bb485f",...}

# Test 3: Login with New Account - WORKS
curl -X POST https://what-is-my-delta-site-production.up.render.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"testuser@test.com","password":"testpass123"}'
# Result: {"user_id":"6c27a2bf-bf11-4d27-ad8c-e52631bb485f",...}

# Test 4: Register damian.seguin@gmail.com - ACCOUNT EXISTS
curl -X POST https://what-is-my-delta-site-production.up.render.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"damian.seguin@gmail.com","password":"anypassword"}'
# Result: {"detail":"User already exists"}

# Test 5: Login with damian.seguin@gmail.com - FAILS
curl -X POST https://what-is-my-delta-site-production.up.render.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"damian.seguin@gmail.com","password":"[any password tried]"}'
# Result: {"detail":"Invalid credentials"}
```

**Key Finding:** The authentication logic works correctly for new accounts but fails for the existing <damian.seguin@gmail.com> account.

---

## CODE ANALYSIS

### Authentication Flow (api/storage.py:201-225)

```python
def authenticate_user(email: str, password: str) -> Optional[str]:
    """Authenticate user and return user ID if successful"""
    normalized_email = _normalize_email(email)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, password_hash FROM users WHERE LOWER(email) = LOWER(%s)",
            (normalized_email,)
        )
        row = cursor.fetchone()
        if not row:
            return None  # User not found
        user_id, password_hash = row
        if verify_password(password, password_hash):
            cursor.execute(
                "UPDATE users SET last_login = %s WHERE id = %s",
                (datetime.utcnow().isoformat(), user_id)
            )
            return user_id
        return None  # Password verification failed
```

### Password Hashing (api/storage.py:191-199)

```python
def hash_password(password: str) -> str:
    """Hash a password using SHA-256 with salt"""
    salt = secrets.token_hex(16)
    return hashlib.sha256((password + salt).encode()).hexdigest() + ":" + salt

def verify_password(password: str, hashed: str) -> bool:
    """Verify a password against its hash"""
    try:
        hash_part, salt = hashed.split(":")
        return hashlib.sha256((password + salt).encode()).hexdigest() == hash_part
    except:
        return False  # Malformed hash or verification error
```

**Hash Format:** `[64-char-hex-hash]:[32-char-hex-salt]`
**Expected Length:** 97 characters (64 + 1 + 32)

---

## HYPOTHESES (Ranked by Likelihood)

### 1. **Corrupted/Incompatible Password Hash in Database** (MOST LIKELY)

- **Evidence:** New accounts work, existing account fails
- **Root Cause:** Password hash for <damian.seguin@gmail.com> may be:
  - From old hashing algorithm (pre-SHA-256 implementation)
  - Corrupted during migration
  - Malformed (missing salt separator `:`)
  - Different format that doesn't match `hash:salt` pattern

### 2. **Database Migration Issues**

- **Evidence:** Git history shows Phase 1 rollback (commit 39b2486)
- **Root Cause:** Schema changes may have:
  - Altered password_hash column without migrating existing data
  - Changed hashing algorithm without rehashing existing passwords
  - Left orphaned/incompatible hashes

### 3. **Email Normalization Mismatch**

- **Evidence:** Code uses `_normalize_email()` and `LOWER(email)` in query
- **Root Cause:** Account may be stored with different email format:
  - Original: `Damian.Seguin@gmail.com` vs query: `damian.seguin@gmail.com`
  - However, this is unlikely since registration check confirms account exists

### 4. **Password Never Set Correctly**

- **Evidence:** User reports never being able to log in
- **Root Cause:** Account created without proper password hash
  - Import from external source
  - Admin creation without password
  - Registration bug at time of account creation

---

## INVESTIGATION STEPS FOR NARs

### Step 1: Check Password Hash Format (CRITICAL)

```sql
-- Connect to production PostgreSQL database
-- Check the password_hash for damian.seguin@gmail.com

SELECT
    id,
    email,
    LENGTH(password_hash) as hash_length,
    password_hash,
    created_at,
    last_login
FROM users
WHERE LOWER(email) = 'damian.seguin@gmail.com';
```

**What to look for:**

- Hash length should be ~97 characters
- Hash should contain exactly one `:` separator
- Format: `[64-char-hex]:[32-char-hex]`
- If different format → **Hypothesis 1 confirmed**

**Compare with working account:**

```sql
SELECT
    id,
    email,
    LENGTH(password_hash) as hash_length,
    password_hash,
    created_at
FROM users
WHERE email = 'testuser@test.com';
```

### Step 2: Check Account Creation Date

```sql
SELECT created_at FROM users WHERE LOWER(email) = 'damian.seguin@gmail.com';
```

**Cross-reference with git history:**

- Find commits around account creation date
- Look for hashing algorithm changes
- Check for migration scripts that may have run

### Step 3: Review Git History for Auth Changes

```bash
# Already identified in git log - need deeper analysis
git log --all --grep="auth" --grep="password" --grep="hash" --oneline

# Key commit to investigate:
# 39b2486 - Phase 1 rollback that broke UI

# Check what changed in authentication:
git show 39b2486 -- api/storage.py
git show 39b2486 -- api/index.py

# Look for password hash format changes:
git log -p -- api/storage.py | grep -A5 -B5 "hash_password\|verify_password"
```

### Step 4: Check for Migration Scripts

```bash
# Look for database migration files
find . -name "*migration*" -o -name "*alembic*" -o -name "*schema*"

# Check for password-related migrations
grep -r "password_hash" . --include="*.sql" --include="*.py"
```

### Step 5: Test Password Reset (If Available)

If password reset functionality exists:

1. Trigger password reset for <damian.seguin@gmail.com>
2. Set new password
3. Attempt login
4. If this works → **Hypothesis 1 confirmed** (old hash was incompatible)

---

## RECOMMENDED FIXES (Based on Root Cause)

### If Hypothesis 1 (Corrupted Hash) is Confirmed

**Option A: Direct Password Reset (FASTEST)**

```sql
-- Generate new hash for a known password
-- Use Python to generate: hash_password("TemporaryPassword123")
-- Then update database:

UPDATE users
SET password_hash = '[newly-generated-hash-with-salt]'
WHERE LOWER(email) = 'damian.seguin@gmail.com';
```

**Option B: Force Re-registration**

```sql
-- Delete old account (backup first!)
DELETE FROM users WHERE LOWER(email) = 'damian.seguin@gmail.com';

-- User re-registers through normal flow
-- This ensures new hash format is used
```

**Option C: Migration Script for All Old Accounts**
If multiple accounts affected:

```python
# Migration script to identify and fix all old hash formats
# Notify affected users to reset passwords
```

### If Hypothesis 2 (Migration Issues) is Confirmed

Review and fix migration scripts, then run database repair:

```bash
# Example migration to fix password hashes
alembic upgrade head  # or whatever migration system is used
```

---

## PRODUCTION LOG ANALYSIS

**User feedback:** "cant you look at prod logs and git history so you dont keep trying the same solutions that do not work?"

### Render Logs to Check

```bash
# View recent production logs
render logs --service production

# Filter for authentication attempts
render logs --service production | grep "auth/login"

# Look for password verification failures
render logs --service production | grep "verify_password\|Invalid credentials"

# Check for any database errors
render logs --service production | grep "ERROR\|Exception"
```

**What to look for:**

- Pattern of login failures for specific email
- Any exceptions in `verify_password()` function
- Database connection issues during auth attempts
- Differences between successful (testuser) and failed (damian) attempts

---

## FRONTEND ISSUE (SECONDARY)

**Error:** `bindPS101TextareaInput is not defined`

**Location:** Console error when page loads

**Investigation:**

```bash
# Check if function exists in deployed frontend
grep -r "bindPS101TextareaInput" frontend/

# Check git history for when this broke
git log -p --all -- "frontend/*.js" | grep -B10 -A10 "bindPS101TextareaInput"
```

**Likely cause:** Phase 1 rollback (commit 39b2486) removed PS101 functionality but left references

**Fix:** Either restore PS101 integration or remove all references to bindPS101TextareaInput

---

## SUCCESS CRITERIA

- [ ] <damian.seguin@gmail.com> can successfully log in
- [ ] Root cause identified and documented
- [ ] Fix applied does not break existing working accounts
- [ ] Frontend console error resolved
- [ ] All auth tests passing

---

## NOTES FROM PREVIOUS ATTEMPTS

User indicates this has been attempted multiple times over 10 days without success. **DO NOT:**

- Ask user to try logging in again with same credentials
- Test registration without checking existing hash first
- Attempt password changes without understanding root cause
- Make assumptions about correct password format

**DO:**

- Start with database inspection (Step 1)
- Compare working vs broken accounts
- Review git history for context
- Check production logs for patterns
- Propose fix based on evidence, not guesses

---

## CONTEXT FILES

- Authentication logic: `api/storage.py:191-225`
- Login endpoint: `api/index.py` (search for `/auth/login`)
- Git history: Phase 1 rollback at commit `39b2486`
- Frontend: `frontend/index.html` (authenticateUser function)
- Team status: `TEAM_STATUS.json` (this is P1.1 priority task)

---

**END OF DIAGNOSTIC**
