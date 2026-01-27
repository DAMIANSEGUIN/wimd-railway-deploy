# Testing Handoff - Mosaic MVP

**Date:** 2025-12-12
**From:** Claude Code
**To:** Next testing agent (Netlify agent runners or manual tester)
**Priority:** P0 - Critical deployment blocker

---

## Current Status

### ✅ What Works

- Backend health: <https://what-is-my-delta-site-production.up.render.app/health> (PostgreSQL connected)
- Frontend: <https://whatismydelta.com> (loads)
- Browser test script created: `./scripts/test_mosaic_browser.sh` (opens Chrome with CodexCapture)

### ❌ Critical Blocker: Render Deployment Stuck on Old Code

**Problem:**

- Render is serving code from **Dec 3, 2025 (commit 96e711c1)** - 9 days old
- Latest code with `/api/ps101/extract-context` endpoint is **NOT deployed**
- GitHub repo has the code (commit a968e9a from Dec 10, 2025)
- Render's GitHub auto-deploy **IS NOT WORKING**

**Evidence:**

```bash
# Endpoint returns 404 (should be 422 for missing auth header)
curl -X POST https://what-is-my-delta-site-production.up.render.app/api/ps101/extract-context

# OpenAPI only shows old endpoint
curl -s https://what-is-my-delta-site-production.up.render.app/openapi.json | grep ps101
# Shows: /wimd/start-ps101 (OLD)
# Missing: /api/ps101/extract-context (NEW)

# Render dashboard shows: Active deployment 96e711c1 (Dec 3, 2025, 10:17 PM)
```

**Root Cause:**
Render's GitHub integration is connected but NOT pulling latest commits from `wimd-render-deploy` repo.

---

## What Needs to Be Fixed FIRST

### Option 1: Fix Render GitHub Integration (RECOMMENDED)

**In Render Dashboard:**

1. Go to Project Settings → GitHub/Source
2. Verify connected to: `github.com/DAMIANSEGUIN/wimd-render-deploy`
3. Verify watching branch: `main`
4. Click "Disconnect" then "Reconnect Repository"
5. Trigger new deployment
6. **Verify it deploys commit `7354f00` or `a968e9a`** (NOT `96e711c1`)

### Option 2: Manual Render CLI Deploy (BLOCKED)

Render CLI command `render up` fails with:

```
Permission denied (os error 13)
```

This suggests file permission issue in local directory. Not recommended path.

### Option 3: Push to render-origin (DON'T DO THIS)

Per DEPLOYMENT_TRUTH.md, `render-origin` is LEGACY and has no write access (403 errors).

---

## Once Render Deploys Latest Code

### Test 1: Verify Endpoint Exists

```bash
# Should return 422 (missing X-User-ID header), NOT 404
curl -X POST https://what-is-my-delta-site-production.up.render.app/api/ps101/extract-context \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n"

# Expected: HTTP Status: 422
# Current (WRONG): HTTP Status: 404
```

### Test 2: Verify OpenAPI Updated

```bash
curl -s https://what-is-my-delta-site-production.up.render.app/openapi.json | python3 -c "import sys, json; paths = json.load(sys.stdin).get('paths', {}); print([p for p in paths.keys() if 'ps101' in p])"

# Expected: ['/wimd/start-ps101', '/api/ps101/extract-context']
# Current (WRONG): ['/wimd/start-ps101']
```

---

## Then Run MVP User Tests

### Test 3: Frontend Loads

```bash
./scripts/test_mosaic_browser.sh
# Opens Chrome with CodexCapture extension
# URL: https://whatismydelta.com
```

**Manual checks:**

- [ ] Page loads (not blank)
- [ ] Login/Register buttons visible
- [ ] No console errors
- [ ] Auth UI present

### Test 4: User Registration

**In browser:**

1. Click "Register" or "Sign Up"
2. Email: `test+mosaic_$(date +%s)@example.com`
3. Password: `TestPass123!`
4. Submit registration
5. **Expected:** Redirect to dashboard, user logged in

**If fails:** Check Network tab for `/auth/register` errors

### Test 5: Complete PS101 Flow

**Follow guide:** `.ai-agents/validation/MOSAIC_MVP_TESTING_GUIDE.md` (Test 5, lines 170-252)

**10 Questions with sample answers provided in guide**

**Critical check after Q10:**

- [ ] Console shows: "Triggering backend context extraction..."
- [ ] Console shows: "Context extraction successful"
- [ ] No 404 errors in Network tab for `/api/ps101/extract-context`

**If context extraction fails:**

- Check Render logs: `render logs | grep -i "extract\|context"`
- Verify CLAUDE_API_KEY is set in Render variables
- Check for 503 errors (Claude API issue)

### Test 6: Personalized Coaching

**After PS101 complete:**

1. Navigate to Chat/Coach interface
2. Send message: "What should I do next?"
3. **Expected:** Response references PS101 answers (e.g., mentions your career goal, obstacles, experiments)
4. **NOT expected:** Generic response that ignores context

**If not personalized:**

- Check database: `render run psql $DATABASE_URL -c "SELECT user_id, extracted_at FROM user_contexts;"`
- Verify context was saved
- Check Render logs for context retrieval errors

---

## Known Issues (Not Blockers)

### OpenAI Quota Exceeded

Render logs show:

```
OpenAI API error: Error code: 429 - {'error': {'message': 'You exceeded your current quota...'}}
```

**Impact:** Semantic search fallback to keyword matching
**Status:** Acceptable for MVP testing (doesn't block auth or PS101)

### FOREIGN KEY Constraint Failed

Render logs show:

```
⚠️ Fallback logging failed: FOREIGN KEY constraint failed
```

**Impact:** Minor logging issue
**Status:** Non-critical, can fix later

---

## Test Results Template

```markdown
## Mosaic MVP Test Results - 2025-12-12

**Tester:** [Your Name]

| Test | Status | Notes |
|------|--------|-------|
| Render Deployment Fixed | ⬜ | Commit deployed: _____ |
| Endpoint /api/ps101/extract-context | ⬜ | HTTP status: _____ |
| Frontend Loads | ⬜ | |
| User Registration | ⬜ | Email: _____ |
| PS101 Complete (10 questions) | ⬜ | |
| Context Extraction | ⬜ | Check console logs |
| Personalized Coaching | ⬜ | Response personalized: Y/N |

**Critical Issues Found:**
1. [Issue description]
   - Severity: [Critical/High/Medium/Low]
   - Steps to reproduce: [...]

**Test Account:**
- Email: _____________________
- Password: _____________________
- User ID: _____________________
```

---

## Quick Reference

**Production URLs:**

- Frontend: <https://whatismydelta.com>
- Backend: <https://what-is-my-delta-site-production.up.render.app>
- Health: <https://what-is-my-delta-site-production.up.render.app/health>

**Local Testing Script:**

```bash
cd /Users/damianseguin/WIMD-Deploy-Project
./scripts/test_mosaic_browser.sh
```

**Full Testing Guide:**
`.ai-agents/validation/MOSAIC_MVP_TESTING_GUIDE.md`

**Deployment Truth:**
`DEPLOYMENT_TRUTH.md` (canonical reference)

---

## Questions for User

1. **Render deployment:** Did reconnecting GitHub integration work?
2. **Which commit is now deployed?** (Check Render dashboard)
3. **Does `/api/ps101/extract-context` return 422 now?** (Not 404)

---

**Status:** BLOCKED on Render deployment
**Next Agent:** Fix Render deployment first, then run tests 3-6
**Estimated Time:** 15 minutes to fix Render + 20 minutes to test MVP flow

---

**Last Updated:** 2025-12-12 17:22 PST
**Created By:** Claude Code
**Priority:** P0
