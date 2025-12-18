# Deployment Test Protocol

**Gated Testing Sequence - Follow in Order, No Exceptions**

**Document Metadata:**

- Created: 2025-12-11 by Claude Code
- Last Updated: 2025-12-11 by Claude Code
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE

---

## PROTOCOL RULES

1. **Execute gates in exact order** (1 → 2 → 3 → 4)
2. **Do not skip gates** even if interrupted
3. **Do not proceed to next gate** until current gate passes
4. **Document results** at each gate
5. **If gate fails** → stop, report, fix, restart from Gate 1

---

## GATE 1: BACKEND API HEALTH

**Purpose:** Verify backend is deployed and responding

**Tests:**

```bash
# Test 1.1: Basic health check
curl https://what-is-my-delta-site-production.up.railway.app/health

# Test 1.2: Comprehensive health
curl https://what-is-my-delta-site-production.up.railway.app/health/comprehensive

# Test 1.3: Configuration
curl https://what-is-my-delta-site-production.up.railway.app/config

# Test 1.4: Active prompts
curl https://what-is-my-delta-site-production.up.railway.app/prompts/active
```

**Success Criteria:**

- All endpoints return HTTP 200
- Health check shows `"ok": true`
- Database connected (no SQLite fallback)
- AI providers available (OpenAI + Anthropic)
- Failure rate = 0%

**Gate Status:** [ ] PASS / [ ] FAIL

**If FAIL:** Check Railway logs, verify DATABASE_URL, check PostgreSQL service

---

## GATE 2: CORE API ENDPOINTS

**Purpose:** Verify critical business logic endpoints

**Tests:**

```bash
# Test 2.1: Career coaching (PS101)
curl -X POST https://what-is-my-delta-site-production.up.railway.app/wimd \
  -H "Content-Type: application/json" \
  -d '{"prompt": "I feel stuck in my career"}'

# Test 2.2: User registration
curl -X POST https://what-is-my-delta-site-production.up.railway.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "test_'$(date +%s)'@example.com", "password": "testpass123"}'

# Test 2.3: Job search
curl "https://what-is-my-delta-site-production.up.railway.app/jobs/search?query=software+engineer&location=remote&limit=3"

# Test 2.4: RAG health
curl https://what-is-my-delta-site-production.up.railway.app/health/rag
```

**Success Criteria:**

- PS101 flow starts (returns session_id + step 1 question)
- User registration succeeds (returns user_id)
- Job search returns results or empty array (not error)
- RAG system reports healthy

**Gate Status:** [ ] PASS / [ ] FAIL

**If FAIL:** Check specific endpoint logs, verify OpenAI API key, check job sources

---

## GATE 3: FRONTEND AVAILABILITY

**Purpose:** Verify frontend is deployed and loading

**Tests:**

```bash
# Test 3.1: Frontend loads
curl -I https://whatismydelta.com

# Test 3.2: Assets accessible
curl -I https://whatismydelta.com/favicon.ico

# Test 3.3: Netlify proxy working
curl -I https://whatismydelta.com/health
```

**Success Criteria:**

- Frontend returns HTTP 200
- HTML contains expected title
- Favicon exists
- Netlify proxy routes to Railway backend

**Gate Status:** [ ] PASS / [ ] FAIL

**If FAIL:** Check Netlify deployment status, verify domain configuration

---

## GATE 4: HANDOFF TO USER FOR UI TESTING

**Purpose:** Provide user with manual testing instructions

**What I tested (automated):**

- ✅ Backend APIs functional
- ✅ Database connected
- ✅ AI providers available
- ✅ Frontend deployed

**What you need to test (manual):**

1. **Trial Mode:** Visit <https://whatismydelta.com> → verify 5-minute trial works
2. **Registration:** Create account → verify email/password flow
3. **Login:** Sign in → verify session persists
4. **Chat Interface:** Ask career question → verify response appears
5. **File Upload:** Upload resume → verify processing works
6. **Navigation:** Test all buttons → verify no broken links
7. **PS101 Flow:** Complete full 10-step process → verify no errors

**Manual Test Template:**

```
□ Trial mode timer displays correctly
□ Can create new account
□ Can log in with credentials
□ Chat interface responds to questions
□ File upload processes documents
□ All navigation buttons work
□ PS101 completes without errors
□ No console errors in browser devtools
□ Works on Chrome/Firefox/Safari
□ Mobile responsive layout works
```

**Gate Status:** [ ] USER TESTING COMPLETE

**If FAIL:** User reports specific UI issue → create bug ticket → fix → redeploy → restart Gate 1

---

## CHECKPOINT TRACKING

**Current Deployment:**

- Git Commit: `a490040`
- Deployment Tag: `prod-2025-11-18`
- Deployed: 2025-11-18
- Tested: [DATE]

**Test Results:**

- Gate 1: [ ] PASS / [ ] FAIL
- Gate 2: [ ] PASS / [ ] FAIL
- Gate 3: [ ] PASS / [ ] FAIL
- Gate 4: [ ] USER TESTING COMPLETE

**Overall Status:** [ ] PASSED ALL GATES / [ ] FAILED AT GATE [#]

---

## PROTOCOL ENFORCEMENT

**If interrupted during testing:**

1. Note current gate number
2. Complete current test
3. Resume at next test in sequence
4. Do NOT jump ahead
5. Do NOT restart unless explicitly requested

**Example interrupt handling:**

```
User: "Wait, check the database first"
Agent: "Currently at Gate 2, Test 2.2. Will complete this test, then check database at your request, then resume at Gate 2, Test 2.3"
```

**Example restart:**

```
User: "Start deployment testing"
Agent: "Starting Gate 1: Backend API Health..."
[executes all tests in Gate 1]
[reports results]
[proceeds to Gate 2 only if Gate 1 passed]
```

---

**END OF PROTOCOL**

Protocol Status: ✅ ACTIVE
Last Updated: 2025-12-11
Enforce: MANDATORY for all deployment testing
