# HANDOFF TO NARs - Mosaic MVP Testing
**Date:** 2025-12-12
**From:** Claude Code
**To:** NARs team
**Priority:** P0

---

## YOUR TASK

Test the Mosaic MVP user flow:
1. User registration
2. PS101 questionnaire (10 questions)
3. Personalized career coaching

---

## CURRENT BLOCKER

**Backend endpoint `/api/ps101/extract-context` returns 404 - should return 422**

**What this means:**
Railway is running old code from Dec 3, 2025 (commit `96e711c1`). The ps101 context extraction endpoint exists in the GitHub repo but hasn't been deployed.

**User needs to:**
1. Go to Railway dashboard (https://railway.app)
2. Project: `wimd-career-coaching` → Service: `what-is-my-delta-site`
3. Settings → Source → Disconnect/Reconnect GitHub integration
4. Point to: `DAMIANSEGUIN/wimd-railway-deploy`, branch `main`
5. Trigger deployment
6. Verify new commit deployed (should be `a968e9a` or later, NOT `96e711c1`)

**Once user confirms Railway deployed new code, verify:**
```bash
curl -X POST https://what-is-my-delta-site-production.up.railway.app/api/ps101/extract-context -w "\nHTTP Status: %{http_code}\n"
```
Should return: `HTTP Status: 422` (NOT 404)

---

## TESTING STEPS (AFTER BLOCKER FIXED)

### Test 1: Manual User Registration Test
**URL:** https://whatismydelta.com

**Test script:**
1. Navigate to homepage
2. Locate "Register" or "Sign Up" button
3. Fill registration form:
   - Email: Generate unique (e.g., `test_nars_$(timestamp)@example.com`)
   - Password: `TestPass123!`
4. Submit form
5. **Expected:** Redirect to dashboard, user authenticated, email shown in UI
6. **Record:** User ID, email, any errors

**If fails:**
- Check browser console for errors
- Check Network tab → `/auth/register` response
- Provide: Screenshot, console errors, network response

### Test 2: PS101 Questionnaire Flow
**Prerequisites:** User must be logged in (from Test 1)

**Test script:**
1. Navigate to PS101 section (should auto-start or have "Get Started" button)
2. Complete all 10 questions with test answers:
   - Q1 (Problem): "Stuck in corporate job, want freelance AI consulting"
   - Q2 (Passions): "Building ML models, teaching"
   - Q3 (Skills): "Python, PyTorch, technical writing"
   - Q4 (Secret powers): "Explaining complex concepts simply"
   - Q5 (Experiments): "Offer free consulting to 2 startups"
   - Q6 (Smallest version): "LinkedIn outreach to 3 founders"
   - Q7 (Internal obstacles): "Imposter syndrome, income fear"
   - Q8 (External obstacles): "Need $5k/month, 20hrs/week max"
   - Q9 (Key quotes): "Building someone else's dream"
   - Q10 (Commitment): "Send 3 LinkedIn messages this week"
3. Submit final answer
4. **Monitor browser console during submission:**
   - Should see: `"Triggering backend context extraction..."`
   - Should see: `"Context extraction successful"`
   - Should NOT see: 404 errors
5. **Check Network tab:**
   - Look for POST to `/api/ps101/extract-context`
   - Status should be: 200 OK
6. **Record:** Console logs, network request/response, any errors

**If context extraction fails:**
- **404 error:** Railway still on old code - alert user
- **503 error:** Backend issue - check Railway logs for Claude API errors
- **No request sent:** Frontend issue - check console for JavaScript errors

### Test 3: Personalized Coaching Verification
**Prerequisites:** User completed PS101 (from Test 2)

**Test script:**
1. Navigate to Chat/Coach interface
2. Send message: "What should I do next?"
3. **Analyze response for personalization:**
   - ✅ PASS: Mentions "freelance AI consulting", "imposter syndrome", "LinkedIn outreach", or other PS101-specific details
   - ❌ FAIL: Generic career advice with no reference to PS101 answers
4. Send follow-up: "I'm worried about money"
5. **Analyze response:**
   - ✅ PASS: Addresses "$5k/month" concern from PS101
   - ❌ FAIL: Generic financial advice
6. **Record:** Full conversation, whether personalized or generic

**If not personalized:**
- Context extraction likely failed (check Test 2 results)
- Check Railway logs for context retrieval errors
- Verify database: User should have entry in `user_contexts` table

---

## DELIVERABLES

**Test Report (Markdown format):**
```markdown
# Mosaic MVP Test Results - [DATE]
**Tester:** [NARs agent name]
**Environment:** Production (whatismydelta.com)

## Test Results

### Blocker Status
- Railway deployment: ✅ Fixed / ❌ Still blocked
- Active commit: [commit hash]
- Endpoint status: [HTTP status code]

### Test 1: User Registration
- Status: ✅ PASS / ❌ FAIL
- User created: [email]
- User ID: [from console or UI]
- Issues: [if any]

### Test 2: PS101 Flow
- Status: ✅ PASS / ❌ FAIL
- Questions completed: [X/10]
- Context extraction: ✅ Success / ❌ Failed
- Console logs: [paste relevant logs]
- Issues: [if any]

### Test 3: Personalized Coaching
- Status: ✅ PASS / ❌ FAIL
- Personalization detected: ✅ YES / ❌ NO
- Example response: [paste first response]
- Issues: [if any]

## Screenshots
[Attach: Registration page, PS101 flow, Chat interface]

## Logs
[Attach: Browser console errors, Network tab for failed requests]

## Recommendations
[Next steps based on findings]
```

---

## REFERENCE MATERIALS

**In GitHub repo (`DAMIANSEGUIN/wimd-railway-deploy`):**
- `docs/NARS_TESTING_INSTRUCTIONS.md` - Detailed testing procedures
- `docs/TESTING_HANDOFF_2025-12-12.md` - Full context and background
- `TROUBLESHOOTING_CHECKLIST.md` - Common issues and fixes

**Production URLs:**
- Frontend: https://whatismydelta.com
- Backend API: https://what-is-my-delta-site-production.up.railway.app
- Health check: https://what-is-my-delta-site-production.up.railway.app/health

**Railway Dashboard:**
https://railway.app/project/wimd-career-coaching

---

## TIMELINE

- Railway fix: User action required (5-10 min)
- Test 1: 5 minutes
- Test 2: 15 minutes
- Test 3: 5 minutes
- Report: 10 minutes

**Total:** ~40 minutes after blocker resolved

---

## QUESTIONS FOR USER

Before testing:
1. Has Railway been reconnected and redeployed?
2. What commit hash is currently deployed?
3. Does `/api/ps101/extract-context` return 422?

If blocked:
1. Can you share Railway dashboard screenshot?
2. Which commit is shown as "Active" in Deployments?

---

**Status:** BLOCKED - Waiting for user to fix Railway deployment
**Next step:** User fixes Railway → NARs run tests → NARs deliver report
