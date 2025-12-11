# Mosaic MVP Testing Guide
**Complete Testing Procedures with Exact URLs and Commands**

**Date:** 2025-12-10
**Session ID:** claude_code_mosaic_testing
**Status:** READY FOR TESTING

---

## Quick Start - Chrome with CodexCapture

**Command to open Chrome with CodexCapture:**
```bash
open -a "Google Chrome" --args --load-extension=/path/to/codexcapture https://whatismydelta.com
```

**Or if CodexCapture is already installed:**
```bash
open -a "Google Chrome" https://whatismydelta.com
```

---

## Production URLs

**Frontend:** https://whatismydelta.com
**Backend API:** https://what-is-my-delta-site-production.up.railway.app
**Health Check:** https://what-is-my-delta-site-production.up.railway.app/health

---

## Test 1: Backend Health Check

**Purpose:** Verify backend is running and database connected

**Command:**
```bash
curl -s https://what-is-my-delta-site-production.up.railway.app/health | python3 -m json.tool
```

**Expected Response:**
```json
{
    "ok": true,
    "timestamp": "2025-12-10T...",
    "checks": {
        "database": true,
        "prompt_system": true,
        "ai_fallback_enabled": true,
        "ai_available": true
    }
}
```

**Success Criteria:**
- ✅ "ok": true
- ✅ "database": true (means PostgreSQL connected, not SQLite)
- ✅ HTTP 200 status

**If Failed:**
- Check Railway logs: `railway logs | head -100`
- Check for PostgreSQL connection errors
- Verify DATABASE_URL is set

---

## Test 2: Verify Context Extraction Endpoint Exists

**Purpose:** Confirm /api/ps101/extract-context endpoint is registered

**Command:**
```bash
# This will return 401/422 (expected - requires auth), not 404
curl -X POST https://what-is-my-delta-site-production.up.railway.app/api/ps101/extract-context \
  -H "Content-Type: application/json" \
  -v 2>&1 | grep -E "HTTP|404|401|422"
```

**Expected Response:**
```
< HTTP/2 422
{"detail":[{"type":"missing","loc":["header","x-user-id"],"msg":"Field required"...
```

**Success Criteria:**
- ✅ HTTP 422 (Unprocessable Entity - missing X-User-ID header)
- ❌ HTTP 404 would mean endpoint not registered

**If HTTP 404:**
- Endpoint not registered correctly
- Check router prefix in api/index.py
- Verify api/ps101.py is imported

---

## Test 3: Frontend Loads Correctly

**Purpose:** Verify frontend deployed to Netlify

**Steps:**

1. **Open browser:**
   ```bash
   open https://whatismydelta.com
   ```

2. **Check page title:**
   - Should see: "What Is My Delta — Find Your Next Career Move"

3. **Check console for errors:**
   - Open DevTools (Cmd+Option+I)
   - Console tab
   - Should see no red errors
   - May see logs like "[PS101] Initializing..."

4. **Verify UI elements visible:**
   - Login/Register buttons (top right)
   - "Get Started" or main CTA
   - Navigation menu

**Success Criteria:**
- ✅ Page loads (not blank)
- ✅ No 404 errors
- ✅ Auth UI present
- ✅ No console errors

---

## Test 4: User Registration

**Purpose:** Create test account for PS101 flow

**URL:** https://whatismydelta.com

**Steps:**

1. **Click "Register" or "Sign Up"**

2. **Fill in form:**
   - Email: `test+mosaic_$(date +%s)@example.com`
   - Password: `TestPass123!`
   - (Use timestamped email to avoid duplicates)

3. **Submit registration**

4. **Check for success:**
   - Should redirect to dashboard/app
   - Should see user menu with email
   - Console should log user_id

**Success Criteria:**
- ✅ Registration succeeds
- ✅ User logged in
- ✅ Can see user email in UI

**If Failed:**
- Check Network tab for /auth/register errors
- Check Railway logs for auth errors
- Verify users table exists in database

**Capture Test User Credentials:**
```
Email: ____________________
Password: ____________________
User ID (from console): ____________________
```

---

## Test 5: PS101 Flow - Complete All 10 Questions

**Purpose:** Complete PS101 to trigger context extraction

**URL:** https://whatismydelta.com (after logging in)

**Steps:**

1. **Navigate to PS101:**
   - Click "Get Started" or "PS101" button
   - Should see: "Personal Situation 101"

2. **Complete all 10 questions:**

   **Question 1: Problem Definition**
   - "What career challenge are you trying to solve?"
   - Answer: "I'm stuck in a corporate job and want to transition to freelance consulting in AI/ML"

   **Question 2: Passions**
   - "What work makes you lose track of time?"
   - Answer: "Building ML models, teaching others about AI, writing technical tutorials"

   **Question 3: Skills**
   - "What are you demonstrably good at?"
   - Answer: "Python, PyTorch, data analysis, technical writing, presenting"

   **Question 4: Secret Powers**
   - "What do others say you're great at that you take for granted?"
   - Answer: "Explaining complex concepts simply, spotting patterns in data, staying calm under pressure"

   **Question 5: Proposed Experiments**
   - "What small experiments could you run to test this transition?"
   - Answer: "Offer free ML consulting to 2 startups, publish 1 tutorial per week, give a conference talk"

   **Question 6: Smallest Version**
   - "What's the tiniest version of this you could try this week?"
   - Answer: "Reach out to 3 founders on LinkedIn offering free 30-min ML consulting calls"

   **Question 7: Internal Obstacles**
   - "What fears or self-doubt are holding you back?"
   - Answer: "Imposter syndrome, fear of unstable income, worried I'm not expert enough"

   **Question 8: External Obstacles**
   - "What practical constraints are you facing?"
   - Answer: "Need $5k/month to cover expenses, have 20 hours/week max for side projects, location-limited"

   **Question 9: Key Quotes**
   - "Any powerful phrases or insights that capture your situation?"
   - Answer: "I feel like I'm building someone else's dream instead of my own"

   **Question 10: Commitment**
   - "What's one thing you commit to doing this week?"
   - Answer: "Send 3 LinkedIn messages to founders offering free ML consulting"

3. **Submit final answer**

4. **Check console for context extraction:**
   - Open DevTools Console
   - Should see: "Triggering backend context extraction..."
   - Should see: "Context extraction successful: ..."

**Success Criteria:**
- ✅ All 10 questions answered
- ✅ PS101 marked complete
- ✅ Console shows context extraction triggered
- ✅ Console shows extraction successful (no errors)

**If Context Extraction Failed:**
- Check Network tab for POST /api/ps101/extract-context
- Check response status (should be 200)
- Check Railway logs for extraction errors
- Verify CLAUDE_API_KEY is set

**Debugging Commands:**
```bash
# Check if context was saved to database
# (Requires Railway shell or psql access)
railway run psql $DATABASE_URL -c "SELECT user_id, extracted_at FROM user_contexts ORDER BY extracted_at DESC LIMIT 5;"

# Check Railway logs for extraction
railway logs | grep -i "extract\|context\|claude"
```

---

## Test 6: Verify Context Extraction (Manual API Call)

**Purpose:** Test context extraction endpoint directly

**Prerequisites:**
- User account created (Test 4)
- PS101 completed (Test 5)
- User ID known (from console or database)

**Command:**
```bash
# Replace USER_ID with actual user_id from Test 4
USER_ID="replace-with-actual-user-id"

curl -X POST https://what-is-my-delta-site-production.up.railway.app/api/ps101/extract-context \
  -H "Content-Type: application/json" \
  -H "X-User-ID: $USER_ID" \
  -s | python3 -m json.tool
```

**Expected Response:**
```json
{
    "problem_definition": "I'm stuck in a corporate job and want to transition to freelance consulting in AI/ML",
    "passions": [
        "Building ML models",
        "Teaching others about AI",
        "Writing technical tutorials"
    ],
    "skills": [
        "Python",
        "PyTorch",
        "Data analysis",
        "Technical writing",
        "Presenting"
    ],
    "secret_powers": [
        "Explaining complex concepts simply",
        "Spotting patterns in data",
        "Staying calm under pressure"
    ],
    "proposed_experiments": [
        {
            "idea": "Offer free ML consulting to 2 startups",
            "smallest_version": "Reach out to 3 founders on LinkedIn..."
        }
    ],
    "internal_obstacles": [
        "Imposter syndrome",
        "Fear of unstable income",
        "Worried I'm not expert enough"
    ],
    "external_obstacles": [
        "Need $5k/month to cover expenses",
        "20 hours/week max for side projects",
        "Location-limited"
    ],
    "key_quotes": [
        "I feel like I'm building someone else's dream instead of my own"
    ]
}
```

**Success Criteria:**
- ✅ HTTP 200 status
- ✅ Valid JSON response
- ✅ All fields present (problem_definition, passions, skills, etc.)
- ✅ Content matches PS101 answers (approximately - LLM may paraphrase)

**If Failed:**
- HTTP 404: Endpoint not registered (check router prefix)
- HTTP 401/422: Missing or invalid X-User-ID header
- HTTP 404 "PS101 not completed": User hasn't completed PS101
- HTTP 503: Claude API error (check CLAUDE_API_KEY, quota)

---

## Test 7: Completion Gate - Chat Before PS101

**Purpose:** Verify completion gate blocks coaching without PS101

**Steps:**

1. **Create NEW test account** (or use account without PS101):
   ```
   Email: test+no_ps101_$(date +%s)@example.com
   Password: TestPass123!
   ```

2. **Navigate to Chat/Coach interface**

3. **Send a message:**
   - Type: "Help me find a new career"
   - Click Send

4. **Check response:**
   - Should see: "Please complete the PS101 questionnaire first to get personalized coaching."
   - OR: "It looks like you're not logged in. Please log in and complete the PS101 questionnaire for a personalized experience."

**Success Criteria:**
- ✅ Chat blocked for user without PS101
- ✅ Helpful message shown (not generic error)
- ✅ No crash or white screen

**If Failed:**
- Chat allows message without PS101: Completion gate not working
- Generic error: Check completion gate logic in api/index.py:387-397

---

## Test 8: Personalized Coaching - Chat After PS101

**Purpose:** Verify context-aware coaching with dynamic system prompt

**Prerequisites:**
- User account with PS101 completed (from Test 5)
- Context extracted successfully (from Test 6)

**Steps:**

1. **Log in with test account from Test 5**

2. **Navigate to Chat/Coach interface**

3. **Send a message:**
   - Type: "What should I do next?"
   - Click Send

4. **Analyze response:**
   - Should reference your PS101 context:
     - Mentions "freelance consulting" or "AI/ML"
     - References "imposter syndrome" or other obstacles
     - Suggests small experiments
     - Uses phrase "building someone else's dream" (key quote)
   - Should NOT mention "PS101" explicitly
   - Should focus on actionable next steps

**Expected Response Example:**
```
I hear you want to transition from corporate to freelance AI/ML consulting.
Given your strength in explaining complex concepts simply and your passion
for teaching, reaching out to those 3 founders on LinkedIn is a perfect
first experiment.

Let's make it even smaller: pick just ONE founder whose work you genuinely
admire. What would you say in that first message?
```

**Success Criteria:**
- ✅ Response is personalized (references PS101 context)
- ✅ No mention of "PS101" in response
- ✅ Actionable suggestions
- ✅ Uses key quotes or specific details from answers

**If Generic (Not Personalized):**
- Check Network tab for POST /wimd/ask
- Verify request includes session_id
- Check Railway logs for context retrieval
- Verify user_contexts table has data for this user

**Debugging Commands:**
```bash
# Check if context is in database
railway run psql $DATABASE_URL -c "SELECT user_id, context_data FROM user_contexts WHERE user_id = 'USER_ID_HERE';"

# Check Railway logs for system prompt
railway logs | grep -i "system_prompt\|ps101\|context"
```

---

## Test 9: X-User-ID Header in Frontend

**Purpose:** Verify frontend sends X-User-ID header with API requests

**Steps:**

1. **Log in with test account**

2. **Open DevTools → Network tab**

3. **Send a chat message**

4. **Find POST request to /wimd/ask**

5. **Check Request Headers:**
   - Should include: `X-User-ID: <user_id>`
   - Should include: `X-Session-ID: <session_id>`

**Success Criteria:**
- ✅ X-User-ID header present
- ✅ X-User-ID matches logged-in user
- ✅ X-Session-ID header present

**If Missing:**
- Check frontend/index.html:1970-1977 for header logic
- Verify currentUser object has userId property
- Check browser console for errors

---

## Test 10: Database Verification

**Purpose:** Verify data persists correctly in PostgreSQL

**Commands:**

```bash
# Check users table
railway run psql $DATABASE_URL -c "SELECT id, email, created_at FROM users ORDER BY created_at DESC LIMIT 5;"

# Check ps101_responses table
railway run psql $DATABASE_URL -c "SELECT user_id, step, prompt_index, LENGTH(response) as response_length FROM ps101_responses ORDER BY user_id DESC LIMIT 20;"

# Check user_contexts table
railway run psql $DATABASE_URL -c "SELECT user_id, extracted_at, extraction_model FROM user_contexts ORDER BY extracted_at DESC LIMIT 5;"

# Check user_contexts content (pretty print JSON)
railway run psql $DATABASE_URL -c "SELECT user_id, context_data FROM user_contexts ORDER BY extracted_at DESC LIMIT 1;" | cat
```

**Success Criteria:**
- ✅ Users exist in users table
- ✅ PS101 responses saved (10 rows per user)
- ✅ user_contexts has extracted data
- ✅ context_data is valid JSON with all required fields

---

## Test 11: Error Handling - Claude API Timeout

**Purpose:** Verify timeout and retry logic works

**This is a destructive test - DO NOT run in production without backup**

**Steps:**

1. **Temporarily set CLAUDE_API_KEY to invalid value:**
   ```bash
   railway variables --set CLAUDE_API_KEY=sk-ant-invalid-test-key
   ```

2. **Wait for Railway to redeploy (~2 min)**

3. **Trigger context extraction:**
   - Complete PS101 with new test account
   - Check console for extraction error

4. **Expected behavior:**
   - Console shows: "Context extraction failed: ..."
   - User can still use app (no crash)
   - Error logged in Railway logs

5. **Restore correct API key:**
   ```bash
   railway variables --set CLAUDE_API_KEY=sk-ant-api03-<actual-key>
   ```

**Success Criteria:**
- ✅ Graceful error handling (no crash)
- ✅ Error message logged
- ✅ User informed of failure

---

## Test 12: End-to-End User Journey

**Purpose:** Complete user flow from registration to personalized coaching

**Full Steps:**

1. **Register new account**
   - Email: test+e2e_$(date +%s)@example.com
   - Password: TestPass123!

2. **Complete PS101 (all 10 questions)**
   - Use sample answers from Test 5
   - Wait for "Context extraction successful" in console

3. **Send first chat message**
   - Message: "What should I do next?"
   - Verify response is personalized

4. **Send follow-up message**
   - Message: "I'm worried about the financial risk"
   - Verify coach addresses internal obstacles

5. **Check conversation continuity**
   - Verify chat remembers previous messages
   - Verify context still applied

**Success Criteria:**
- ✅ Full flow completes without errors
- ✅ Each step works as expected
- ✅ Context persists across messages
- ✅ Coaching feels personalized

**Time Estimate:** 10-15 minutes

---

## Test 13: Monitoring and Logs

**Purpose:** Verify production monitoring is working

**Commands:**

```bash
# Check health endpoint
watch -n 30 'curl -s https://what-is-my-delta-site-production.up.railway.app/health | python3 -m json.tool'

# Monitor Railway logs for errors
railway logs | grep -i "error\|warn\|exception" --color=always

# Check for context extraction events
railway logs | grep -i "context extracted\|extract-context" --color=always

# Check for completion gate events
railway logs | grep -i "ps101\|completion\|questionnaire" --color=always

# Check Claude API usage
railway logs | grep -i "claude\|anthropic" --color=always
```

**Success Criteria:**
- ✅ No unexpected errors in logs
- ✅ Health endpoint consistently returns ok: true
- ✅ Context extraction events logged
- ✅ No 404 errors on /api/ps101/extract-context

---

## Test Results Template

**Copy this template to track test results:**

```markdown
# Mosaic MVP Test Results
**Date:** 2025-12-10
**Tester:** [Your Name]

## Test Results Summary

| Test | Status | Notes |
|------|--------|-------|
| 1. Backend Health | ⬜ | |
| 2. Context Endpoint Exists | ⬜ | |
| 3. Frontend Loads | ⬜ | |
| 4. User Registration | ⬜ | |
| 5. PS101 Flow Complete | ⬜ | |
| 6. Context Extraction API | ⬜ | |
| 7. Completion Gate (Before) | ⬜ | |
| 8. Personalized Coaching | ⬜ | |
| 9. X-User-ID Header | ⬜ | |
| 10. Database Verification | ⬜ | |
| 11. Error Handling | ⬜ | |
| 12. End-to-End Journey | ⬜ | |
| 13. Monitoring/Logs | ⬜ | |

**Legend:** ✅ Pass | ❌ Fail | ⚠️ Partial | ⬜ Not Tested

## Test Account Details

**Account 1 (With PS101):**
- Email: ____________________
- Password: ____________________
- User ID: ____________________
- Context Extracted: ⬜ Yes ⬜ No

**Account 2 (Without PS101):**
- Email: ____________________
- Password: ____________________
- User ID: ____________________

## Issues Found

1. **Issue:** [Description]
   - **Severity:** Critical / High / Medium / Low
   - **Steps to Reproduce:** [Steps]
   - **Expected:** [Expected behavior]
   - **Actual:** [Actual behavior]
   - **Logs:** [Relevant logs]

## Notes

[Any additional observations]
```

---

## Quick Reference Card

**Production URLs:**
```
Frontend:  https://whatismydelta.com
Backend:   https://what-is-my-delta-site-production.up.railway.app
Health:    https://what-is-my-delta-site-production.up.railway.app/health
```

**Key Commands:**
```bash
# Health check
curl -s https://what-is-my-delta-site-production.up.railway.app/health | python3 -m json.tool

# Open Chrome
open -a "Google Chrome" https://whatismydelta.com

# Railway logs
railway logs | grep -i "error\|context"

# Database check
railway run psql $DATABASE_URL -c "SELECT COUNT(*) FROM user_contexts;"
```

**Test Credentials Template:**
```
Email: test+mosaic_[timestamp]@example.com
Password: TestPass123!
```

---

## Contact for Issues

If you encounter issues during testing:

1. **Capture error details:**
   - Screenshot of error
   - Browser console logs (DevTools → Console)
   - Network request details (DevTools → Network)
   - Railway logs (railway logs | tail -100)

2. **Check common issues:**
   - 404 on /api/ps101/extract-context → Router prefix issue
   - Context extraction fails → CLAUDE_API_KEY issue
   - Chat not personalized → Context not saved or retrieved
   - Completion gate not working → Check api/index.py:387-397

3. **Report to Claude Code with:**
   - Which test failed (number and name)
   - Error messages (exact text)
   - Logs (Railway + browser console)
   - Test account details (email, user_id)

---

**END OF TESTING GUIDE**

Generated by: Claude Code
Schema Version: v1.0
Status: READY FOR TESTING
Priority: P0 (Mosaic MVP Validation)
