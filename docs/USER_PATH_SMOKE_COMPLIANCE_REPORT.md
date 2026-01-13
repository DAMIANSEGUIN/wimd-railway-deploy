# USER_PATH_SMOKE Compliance Report
**Date**: 2026-01-13
**Gate**: USER_PATH_SMOKE (GOVERNANCE.md requirement)
**Status**: ❌ BLOCKED

---

## Executive Summary

USER_PATH_SMOKE gate correctly identified that system is NOT usable despite /health passing. All issues are backend configuration/code problems, NOT Netlify redirects.

---

## Issue 1: /config Returns Empty apiBase

### Current Behavior
```bash
$ curl https://mosaic-backend-tpog.onrender.com/config
{"apiBase":"","schemaVersion":"v2"}
```

### Root Cause
**File**: `api/index.py:889`
```python
def config():
    s = get_settings()
    return {"apiBase": os.getenv("PUBLIC_API_BASE", ""), "schemaVersion": s.APP_SCHEMA_VERSION}
```

Environment variable `PUBLIC_API_BASE` is not set on Render, returns empty string.

### Impact
Frontend cannot determine backend URL, API calls will fail.

### Fix Required
**Option A**: Set environment variable on Render
```bash
PUBLIC_API_BASE=https://mosaic-backend-tpog.onrender.com
```

**Option B**: Hardcode in settings (not recommended)
```python
return {"apiBase": "https://mosaic-backend-tpog.onrender.com", ...}
```

**Recommendation**: Option A (environment variable)

---

## Issue 2: /auth/register Returns 404

### Current Behavior
```bash
$ curl -X POST https://mosaic-backend-tpog.onrender.com/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
{"detail":"Not Found"}
```

### Root Cause
Searched `api/index.py` for `/auth/register` endpoint - **not found**.

The `/auth/register` route does not exist in the deployed backend code.

### Impact
Users cannot register, system unusable for new users.

### Fix Required
1. Locate auth endpoints (may be in separate file)
2. Verify they're imported in main app
3. OR implement missing auth endpoints

**Investigation needed**: Check for:
- `api/auth.py` or similar auth module
- FastAPI router imports for auth
- Whether auth was removed/deprecated

---

## Issue 3: /wimd Returns 500 Internal Server Error

### Current Behavior
```bash
$ curl -X POST https://mosaic-backend-tpog.onrender.com/wimd \
  -H "Content-Type: application/json" \
  -d '{"prompt":"test"}'
Internal Server Error
```

### Root Cause
Backend crashes when processing /wimd request.

### Impact
Main chat feature completely broken.

### Fix Required
1. Check Render logs for Python traceback
2. Likely causes:
   - Missing dependency (OpenAI/Anthropic client)
   - Invalid API key
   - Database connection issue
   - Missing required fields in request body

**Investigation command** (on Render dashboard):
```bash
# View recent logs
render logs
```

Look for Python exceptions around /wimd endpoint.

---

## Netlify Redirects: ✅ VERIFIED CORRECT

All required redirects exist in `netlify.toml`:
- /config → backend (line 15-18)
- /auth/register → backend (line 51-54)
- /auth/login → backend (line 57-60)
- /wimd → backend (line 27-30)

**Netlify is NOT the problem.** All issues are on backend.

---

## Compliance Checklist

### Before Re-running USER_PATH_SMOKE:

- [ ] Set PUBLIC_API_BASE environment variable on Render
- [ ] Find and fix /auth/register endpoint (404)
- [ ] Fix /wimd 500 error (check Render logs)
- [ ] Redeploy backend to Render
- [ ] Wait 2 minutes for deploy
- [ ] Run: `./scripts/mosaic_enforce.sh --mode=integration`

### Expected Results After Fixes:

```bash
⏳ Testing USER_PATH_SMOKE (critical user endpoints)...
  ✓ /config returns valid apiBase: https://mosaic-backend-tpog.onrender.com
  ✓ /auth/register endpoint exists
  ✓ /wimd endpoint exists (main feature)
✅ PASS: USER_PATH_SMOKE (critical user paths functional)
```

---

## Governance Validation

Per GOVERNANCE.md:
> "A system is considered healthy only if real users can successfully use it end-to-end."

**Current Status**: System FAILS this requirement.
- /health passes ✅
- Users cannot use system ❌

USER_PATH_SMOKE gate correctly enforces this by testing actual user endpoints, not just component health.

---

## Next Actions (Priority Order)

1. **IMMEDIATE**: Set PUBLIC_API_BASE on Render dashboard
   - Navigate to: Render > mosaic-backend service > Environment
   - Add: PUBLIC_API_BASE=https://mosaic-backend-tpog.onrender.com
   
2. **HIGH**: Investigate /auth/register 404
   - Search codebase for auth implementation
   - Verify routes are registered
   
3. **HIGH**: Debug /wimd 500 error
   - Check Render logs
   - Look for Python exceptions
   - Verify OpenAI/Anthropic API keys set
   
4. **VERIFY**: Re-run USER_PATH_SMOKE gate
   - Command: `./scripts/mosaic_enforce.sh --mode=integration`
   - Must return ALLOW before deployment approved

---

**This report documents why governance BLOCKED deployment - system not usable despite /health passing.**
