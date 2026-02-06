# Mosaic Platform Troubleshooting Checklist

**Custom Dashboard Filter for Claude Code**

**Document Metadata:**

- Created: 2025-11-02 by Claude Code
- Last Updated: 2025-12-06 by Claude Code
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE

---

## 🏷️ LAST KNOWN WORKING VERSION

**Latest Functional Deployment:**

- **Git Tag:** `prod-2025-11-18`
- **Commit:** `31d099c`
- **Status:** Production deployed to Render/Netlify
- **To Restore:** `git checkout prod-2025-11-18`
- **To Create New Tag:** `git tag prod-YYYY-MM-DD` (after verified deployment)

**Check Current Production Tag:**

```bash
git describe --tags --abbrev=0
```

**List All Production Tags:**

```bash
git tag -l "prod-*" --sort=-version:refname | head -5
```

---

## Quick Diagnostic Filter

**Run this checklist BEFORE making any code changes:**

### Backend Checklist
```
□ Read recent Render deployment logs
□ Check /health endpoint status
□ Verify DATABASE_URL format (postgresql://...render.internal)
□ Confirm PostgreSQL service status in Render dashboard
□ Review last 3 git commits for breaking changes
□ Check if error is in known taxonomy (see below)
```

### Frontend Checklist (NEW - Added 2026-02-06)
```
□ Run frontend smoke test: ./scripts/test_frontend_smoke.sh
□ Check browser console for JavaScript errors (Cmd+Option+J on Mac)
□ Verify PS101 navigation works (Steps 1-10)
□ Test with clean localStorage (clear browser data)
□ Run Playwright E2E tests: npx playwright test test-ps101-complete-flow.js
□ Verify live site matches local: curl https://whatismydelta.com | grep PS101State
```

---

## Error Classification Dashboard

### 🔴 CRITICAL (Production Down)

#### Backend Errors
| Error Label | Symptom | Root Cause | First Action |
|-------------|---------|------------|--------------|
| `RAILWAY_RESTART_LOOP` | Container crashes repeatedly | Code bug, dependency missing | Check deploy logs for exception |
| `PG_CONNECTION_FAILED` | App using SQLite fallback | Wrong DATABASE_URL, network issue | Verify DATABASE_URL contains `render.internal` |
| `CONTEXT_MANAGER_BUG` | AttributeError: 'object has no attribute execute' | Using `conn = get_conn()` instead of `with get_conn() as conn:` | Search codebase for incorrect pattern |
| `OPENAI_INVALID_KEY` | All AI features fail | API key revoked/wrong | Check OPENAI_API_KEY in Render variables |

#### Frontend Errors (NEW - Added 2026-02-06)
| Error Label | Symptom | Root Cause | First Action |
|-------------|---------|------------|--------------|
| `PS101_NAVIGATION_STUCK` | User stuck on same step/prompt | nextPrompt() or nextStep() broken | Check browser console for JS errors, verify navigation functions exist |
| `PS101_STATE_CORRUPT` | Wrong step count, missing prompts | localStorage corrupted or wrong PS101_STEPS array | Clear localStorage, verify PS101_STEPS has 10 steps |
| `FRONTEND_JS_ERROR` | White screen, features not working | JavaScript exception on page load | Open browser console (Cmd+Option+J), check for errors |
| `FRONTEND_NOT_DEPLOYED` | Live site shows old code | Netlify deploy failed or cached | Check Netlify dashboard, hard refresh browser (Cmd+Shift+R) |
| `LOCALSTORAGE_FULL` | User data not saving | Browser storage quota exceeded | Clear old session data, implement storage cleanup |

### 🟡 WARNING (Degraded)

| Error Label | Symptom | Root Cause | First Action |
|-------------|---------|------------|--------------|
| `SQLITE_FALLBACK_ACTIVE` | Data wiped on deploy | PostgreSQL not connected | Check DATABASE_URL, PostgreSQL service status |
| `OPENAI_RATE_LIMIT` | 429 errors from OpenAI | Usage spike, quota exceeded | Enable retry with backoff, check usage |
| `PS101_STATE_CORRUPT` | Users seeing wrong questions | prompt_index out of range | Reset session PS101 state |
| `EMBEDDING_FAILED` | Semantic search not working | OpenAI embeddings API down | Use keyword fallback |

### 🟢 INFO (Functional but Needs Attention)

| Error Label | Symptom | Root Cause | First Action |
|-------------|---------|------------|--------------|
| `RERANKER_UNAVAILABLE` | Using mock reranker | CrossEncoder model load failed | Acceptable fallback, monitor quality |
| `PROMPT_CSV_WARNING` | Some prompts missing | CSV parse issue | Validate CSV format |
| `SESSION_EXPIRED` | User logged out unexpectedly | TTL exceeded (>30 days) | Normal behavior |

---

## Code Change Pre-Flight Checklist

**Before writing ANY code:**

```
ARCHITECTURE AWARENESS:
□ Do I understand what layer this touches? (DB / API / LLM / UI)
□ Have I checked for similar code patterns in the codebase?
□ Do I know what happens if this component fails?

DATABASE CHANGES:
□ Am I using context manager? (with get_conn() as conn:)
□ Am I using PostgreSQL syntax? (%s not ?, SERIAL not AUTOINCREMENT)
□ Am I getting cursor first? (cursor = conn.cursor())
□ Is this operation idempotent? (ON CONFLICT, check before insert)

ERROR HANDLING:
□ Am I logging errors explicitly? (not swallowing exceptions)
□ Will this fail gracefully? (fallback behavior defined)
□ Can I diagnose this from logs alone? (enough context logged)

DEPLOYMENT SAFETY:
□ Can I rollback this change? (git revert path clear)
□ Is there a feature flag? (can disable without deploy)
□ Have I tested locally? (golden dataset, manual test)
□ Did I check for breaking changes? (API contracts, schema)
```

---

## Symptom → Diagnosis Flow

### Symptom: "Invalid Credentials" After Deployment

```
1. Check: Is PostgreSQL connected?
   render logs | grep STORAGE
   → Look for: "[STORAGE] ✅ PostgreSQL connection pool created"
   → If SQLite fallback: DATABASE_URL issue

2. Check: Does user exist in database?
   # This requires Render shell or psql access
   → If user missing: Database wiped (SQLite fallback confirmed)

3. Check: Was deployment recent?
   git log --oneline -5
   → If deploy within last hour: Database reset on deploy

4. Diagnosis: SQLITE_FALLBACK_ACTIVE
   → Action: Fix DATABASE_URL (ensure render.internal)
   → Verify: PostgreSQL service status in Render
```

### Symptom: Deployment Failed

```
1. Check: Build logs or deploy logs?
   Render dashboard → Deployment → Build Logs vs Deploy Logs
   → If no deploy logs: App crashed on startup
   → If build failed: Dependency or syntax error

2. Check: What's the error message?
   Look for:
   - "AttributeError" → Likely context manager bug
   - "ModuleNotFoundError" → Missing dependency in requirements.txt
   - "psycopg2" → PostgreSQL connection issue
   - "Syntax Error" → Python syntax error in code

3. Check: Recent commits
   git log --oneline -3
   → Identify what changed recently

4. Action: Rollback if needed
   git revert HEAD
   git push render-origin main
```

### Symptom: App Slow / Timeouts

```
1. Check: Health endpoint
   curl https://what-is-my-delta-site-production.up.render.app/health
   → Check p95_latency_ms

2. Check: Is it OpenAI/Anthropic?
   Render logs | grep -i "openai\|anthropic"
   → Look for slow response times

3. Check: Database queries
   → Slow queries (missing indexes)
   → Too many queries (N+1 problem)

4. Diagnosis:
   → If AI calls: Add timeout, retry logic
   → If DB: Add indexes, optimize queries
   → If overall: Scale Render instance
```

### Symptom: Users Seeing Old Data

```
1. Check: Browser cache?
   → Ask user to hard refresh (Ctrl+Shift+R)

2. Check: Netlify deployment
   → Is frontend deployed?
   → Check Netlify dashboard

3. Check: Session state
   → Old session data in localStorage
   → Clear localStorage in browser console

4. Diagnosis: LIKELY_CACHING
   → Action: Add cache-busting headers
   → Or: Increment version number in /config
```

---

## Render-Specific Diagnostics

### Check DATABASE_URL Format

```bash
# In Render CLI
render variables | grep DATABASE_URL

# Should contain:
✅ postgresql://
✅ render.internal (NOT render.app)
✅ :5432/render

# Should NOT contain:
❌ sqlite://
❌ render.app (public URL, use internal)
```

### Check PostgreSQL Service

```bash
# In Render dashboard:
1. Click PostgreSQL service
2. Status should be: "Active" or "Running"
3. Check "Metrics" - should show connections
4. Check "Logs" - no errors
```

### Check Deployment Logs

```bash
# In Render dashboard:
1. Click what-is-my-delta-site service
2. Click "Deployments" tab
3. Click most recent deployment
4. Click "Deploy Logs" (NOT Build Logs)
5. Look for:
   - [STORAGE] messages
   - Exception tracebacks
   - "ERROR:" lines
```

---

## Code Pattern Filters

### ✅ CORRECT Patterns (Use These)

```python
# Database operations
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    result = cursor.fetchone()

# Error handling with logging
try:
    result = risky_operation()
except SpecificException as e:
    logger.error(f"Operation failed: {e}")
    # Explicit fallback or re-raise
    raise

# Idempotent inserts
cursor.execute("""
    INSERT INTO table (id, data)
    VALUES (%s, %s)
    ON CONFLICT (id) DO UPDATE SET data = EXCLUDED.data
""", (id, data))

# Retry with backoff
@retry_with_exponential_backoff(max_retries=3)
def call_external_api():
    # API call here
    pass
```

### ❌ INCORRECT Patterns (Never Use)

```python
# Wrong: Direct get_conn() usage
conn = get_conn()
cursor = conn.execute(...)  # AttributeError!

# Wrong: SQLite syntax in PostgreSQL
cursor.execute("SELECT * FROM users WHERE email = ?", (email,))  # Use %s

# Wrong: Silent exception swallowing
try:
    risky_operation()
except:
    pass  # No logging, no fallback

# Wrong: Non-idempotent operations
cursor.execute("INSERT INTO table VALUES (%s)", (data,))  # Fails on duplicate

# Wrong: Infinite retry
while True:
    try:
        call_api()
        break
    except:
        continue  # Never gives up!
```

---

## Frontend Debugging Workflow (NEW - Added 2026-02-06)

### Quick Triage: Is It Frontend or Backend?

```bash
# Test 1: Can you reach the site?
curl -I https://whatismydelta.com
# → If 200: Frontend deployed
# → If 4xx/5xx: Netlify issue

# Test 2: Is JavaScript working?
curl -s https://whatismydelta.com | grep "PS101State"
# → If found: Code deployed
# → If not found: Old version cached

# Test 3: Is backend responding?
curl https://mosaic-backend-tpog.onrender.com/health
# → If {"ok":true}: Backend working
# → If error: Backend down

# Test 4: Open browser console
open -a "Google Chrome" https://whatismydelta.com
# Press Cmd+Option+J
# → If no errors: Frontend working
# → If errors: JavaScript broken
```

### Frontend-Specific Debugging Steps

#### Step F1: Check Browser Console (ALWAYS DO THIS FIRST)

```
1. Open site: https://whatismydelta.com
2. Open console: Cmd+Option+J (Mac) or F12 (Windows/Linux)
3. Refresh page: Cmd+R
4. Look for errors (red text)
5. Screenshot ANY errors
```

**Common Errors:**
- `ReferenceError: PS101State is not defined` → Code broken
- `TypeError: Cannot read property 'length' of undefined` → Array missing
- `localStorage quota exceeded` → Storage full
- `Failed to fetch` → Backend API down

#### Step F2: Test PS101 Flow Manually

```bash
# Open browser with clean state
open -a "Google Chrome" --args --incognito https://whatismydelta.com

# Manual test checklist:
□ Click "Start with questions"
□ Fill out Step 1, Prompt 1 (50+ characters)
□ Click "Next Prompt" → Should advance to Prompt 2
□ Fill out all 6 prompts in Step 1
□ Click "Next Step" → Should advance to Step 2
□ Check step label shows "Step 2 of 10"
□ Check browser console for [PS101] debug logs
```

#### Step F3: Check localStorage State

```javascript
// Open browser console and run:
JSON.parse(localStorage.getItem('ps101_v2_state'))

// Expected output:
{
  currentStep: 1,          // Should be 1-10
  currentPromptIndex: 0,   // Should be 0-based
  steps: {...},            // User answers
  startedAt: "2026-02-06..."
}

// If corrupted, clear it:
localStorage.removeItem('ps101_v2_state')
location.reload()
```

#### Step F4: Run Automated Tests

```bash
# Quick smoke test (30 seconds)
./scripts/test_frontend_smoke.sh

# Full E2E test (2-3 minutes)
npx playwright test test-ps101-complete-flow.js --headed

# Step 6 validation test
npx playwright test test-ps101-step6-validation.js --headed
```

#### Step F5: Compare Local vs Production

```bash
# Check what's deployed
curl -s https://whatismydelta.com | grep -o "console.log.*PS101.*nextPrompt" | head -1

# Check local file
grep -o "console.log.*PS101.*nextPrompt" frontend/index.html | head -1

# If different: Need to redeploy
netlify deploy --prod --dir=frontend
```

### Frontend Error Patterns

**Pattern 1: Navigation Stuck**
```
Symptom: User clicks "Next" but stays on same step/prompt
Root Cause: nextPrompt() or nextStep() broken, localStorage corrupted
Debug:
  1. Open console, look for [PS101] logs
  2. Check localStorage state
  3. Verify PS101_STEPS array has 10 steps
Fix: Clear localStorage, verify navigation functions exist
```

**Pattern 2: Wrong Step Count**
```
Symptom: Shows "Step 1 of 7" instead of "Step 1 of 10"
Root Cause: PS101_STEPS array truncated, hardcoded step count
Debug:
  1. Search for "of 10" in frontend/index.html
  2. Count steps in PS101_STEPS array
  3. Check updateProgressIndicator() function
Fix: Ensure using PS101_STEPS.length dynamically
```

**Pattern 3: White Screen / JavaScript Error**
```
Symptom: Page loads but shows blank white screen
Root Cause: JavaScript exception on page load
Debug:
  1. Open console, check for red errors
  2. Look for uncaught exceptions
  3. Check network tab for failed requests
Fix: Fix JavaScript syntax error, redeploy
```

**Pattern 4: Old Code Deployed**
```
Symptom: Recent code changes not visible on live site
Root Cause: Netlify cache, failed deployment
Debug:
  1. Check Netlify deployment dashboard
  2. Hard refresh browser (Cmd+Shift+R)
  3. Curl live site and check content
Fix: Force redeploy, clear CDN cache
```

### Frontend Monitoring Tools

```bash
# Tool 1: Smoke Test (run before every deploy)
./scripts/test_frontend_smoke.sh

# Tool 2: E2E Tests (run after deploy)
npx playwright test test-ps101-complete-flow.js

# Tool 3: Live Site Check
curl -s https://whatismydelta.com | grep "PS101State" && echo "✅ Deployed" || echo "❌ Not deployed"

# Tool 4: Browser Console Logging
# (Enabled in production with [PS101] prefix for debugging)
open https://whatismydelta.com
# Press Cmd+Option+J and look for [PS101] logs

# Tool 5: Netlify Deploy Status
netlify status

# Tool 6: Visual Regression (future)
# npx playwright test --update-snapshots
```

---

## Backend Debugging Workflow

### Step 1: Classify the Issue

```
Ask yourself:
1. When did this start? (recent deploy? always?)
2. Who is affected? (all users? one user? specific action?)
3. What's the error? (exception? wrong behavior? slow?)
4. Where is it? (frontend? API? database? LLM?)

Map to category:
- INFRA: Render, PostgreSQL, networking
- DATA: Sessions, users, PS101 state
- MODEL: OpenAI, Anthropic, prompts
- PROMPT: CSV, JSON parsing
- INTEGRATION: Job sources, external APIs
```

### Step 2: Gather Context

```
Collect diagnostics:
□ Render deployment logs (last 200 lines)
□ Health endpoint response (/health)
□ Recent git commits (git log -5)
□ Environment variables (render variables)
□ PostgreSQL service status
□ Error message (full traceback)
□ User actions that triggered it
□ Recent deployments timeline
```

### Step 3: Form Hypothesis

```
Based on error category + context:

If INFRA error:
  → Check DATABASE_URL format
  → Check PostgreSQL service status
  → Check recent Render changes

If DATA error:
  → Check database schema version
  → Check for foreign key violations
  → Check session expiration

If MODEL error:
  → Check API keys set
  → Check rate limits / quota
  → Check model names valid

If PROMPT error:
  → Validate JSON/CSV files
  → Check file permissions
  → Check for schema changes

If INTEGRATION error:
  → Check external API status
  → Check API keys / auth
  → Check for API changes
```

### Step 4: Test Hypothesis

```
Verify hypothesis:
□ Can I reproduce locally?
□ Does the log match the hypothesis?
□ Does a simple fix resolve it?
□ Is there a known playbook for this?

If hypothesis wrong:
→ Go back to Step 2 with more context
→ Consult SELF_DIAGNOSTIC_FRAMEWORK.md
→ Escalate to NARs with full context
```

### Step 5: Implement Fix

```
Before fixing:
□ Check pre-flight checklist (above)
□ Ensure rollback path exists
□ Test locally first
□ Run golden dataset tests

After fixing:
□ Deploy with clear commit message
□ Monitor logs for 5 minutes
□ Verify health endpoint
□ Test the specific symptom
□ Update documentation if new pattern
```

---

## Quick Reference Commands

```bash
# Check deployment status
render status

# Get environment variables
render variables

# View recent logs
render logs

# Check health endpoint
curl https://what-is-my-delta-site-production.up.render.app/health

# Check if PostgreSQL connected
render logs | grep -i "storage\|postgres"

# Rollback to previous commit
git revert HEAD && git push render-origin main

# Force redeploy (no code changes)
git commit --allow-empty -m "Redeploy" && git push render-origin main

# Run tests locally
pytest tests/test_golden_dataset.py -v
```

---

## Decision Tree: "Should I Deploy This?"

```
START
  │
  ├─> Does this change database code?
  │     ├─> YES: Did I use context manager pattern?
  │     │     ├─> NO: ❌ FIX FIRST
  │     │     └─> YES: Did I use PostgreSQL syntax (%s)?
  │     │           ├─> NO: ❌ FIX FIRST
  │     │           └─> YES: Continue
  │     └─> NO: Continue
  │
  ├─> Does this change error handling?
  │     ├─> YES: Am I logging errors?
  │     │     ├─> NO: ❌ ADD LOGGING
  │     │     └─> YES: Continue
  │     └─> NO: Continue
  │
  ├─> Have I tested locally?
  │     ├─> NO: ❌ TEST FIRST
  │     └─> YES: Continue
  │
  ├─> Do I have a rollback plan?
  │     ├─> NO: ❌ PLAN ROLLBACK
  │     └─> YES: Continue
  │
  └─> ✅ SAFE TO DEPLOY
        │
        ├─> Deploy: git push render-origin main
        ├─> Monitor: render logs (5 min)
        ├─> Verify: curl /health
        └─> Test: specific symptom resolved
```

---

## Emergency Procedures

### 🚨 Production is Down

```
IMMEDIATE:
1. Check Render dashboard - is service running?
2. If crashed: Check deploy logs for error
3. If context manager bug: Rollback immediately
4. If PostgreSQL: Check DATABASE_URL, PostgreSQL service

ROLLBACK:
git revert HEAD
git push render-origin main --force
# Wait 2 minutes
curl /health

COMMUNICATE:
- Post status update
- ETA for fix
- Workaround if any
```

### 🔥 Data Loss Detected

```
ASSESS:
1. Is PostgreSQL connected? (check logs for STORAGE messages)
2. If SQLite fallback: All data lost on last deploy
3. If PostgreSQL: Check if table dropped/truncated

RECOVER:
- If SQLite: No recovery possible (ephemeral)
- If PostgreSQL: Check for backups in Render
- Last resort: Restore from git history + redeploy

PREVENT:
- Ensure DATABASE_URL uses render.internal
- Verify PostgreSQL service active
- Add data backup strategy
```

### ⚡ Performance Degradation

```
DIAGNOSE:
1. Check /health endpoint - what's p95_latency_ms?
2. Check Render metrics - CPU/Memory usage
3. Check logs - slow queries, API timeouts?

IMMEDIATE FIX:
- If OpenAI timeout: Add shorter timeout + fallback
- If DB slow: Add indexes, optimize queries
- If memory: Restart service, investigate leak

LONG TERM:
- Scale Render instance
- Add caching layer
- Optimize hot paths
```

---

## Checklist Summary (Print This)

**Before Every Code Change:**

```
□ Read SELF_DIAGNOSTIC_FRAMEWORK.md
□ Context manager pattern? (with get_conn() as conn:)
□ PostgreSQL syntax? (%s, SERIAL, cursor first)
□ Errors logged explicitly?
□ Idempotent operation?
□ Rollback plan exists?
□ Tested locally?
```

**Before Every Deploy:**

```
□ Run ./pre_deploy_check.sh
□ Golden dataset tests pass?
□ Regression tests pass?
□ Database connection works?
□ Environment variables set?
□ Git commit message clear?
```

**After Every Deploy:**

```
□ Monitor logs 5 minutes
□ Check /health endpoint
□ Verify PostgreSQL connected (no SQLite fallback)
□ Test the specific fix
□ No new errors in logs?
```

**When Things Break:**

```
□ Get full error message from logs
□ Classify error (INFRA/DATA/MODEL/PROMPT/INTEGRATION)
□ Check if known error (see dashboard above)
□ Execute playbook if exists
□ If new error: gather full context
□ Form hypothesis → test → fix → verify
□ If stuck: escalate with FULL context
```

---

**END OF TROUBLESHOOTING CHECKLIST**
