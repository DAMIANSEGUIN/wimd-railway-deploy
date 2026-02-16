# NEW SESSION VERIFICATION CHECKLIST

**FOR NEW AGENT: Read and complete this checklist at session start**

**Purpose:** Verify you have sufficient context to work responsibly on this project

**Created:** 2026-02-15
**Test Protocol:** `.mosaic/CONTEXT_PROVISIONING_TEST.md`

---

## 🎯 YOUR TASK

Complete ALL verification steps below and report results in your first response.

**DO NOT skip any step.** Each verifies a critical dependency.

---

## STEP 1: Read State Files (MANDATORY)

Run these commands and show the output:

```bash
# 1.1: Check current commit
git rev-parse --short HEAD

# 1.2: Read agent state
cat .mosaic/agent_state.json | jq '{last_agent, last_commit, current_task, handoff_message}'

# 1.3: Read current task
cat .mosaic/current_task.json | jq '{task_id, objective, status, priority}'

# 1.4: Read project metadata
cat .mosaic/project_state.json | jq '.project_metadata'
```

**Fill out:**
```
□ Current git commit: ___________
□ Last agent: ___________
□ Last commit in state: ___________
□ Do they match? YES / NO
□ Current task: ___________
□ Task status: ___________
```

**CRITICAL:** If git commit ≠ last_commit in state → State files are STALE → REPORT THIS

---

## STEP 2: Verify Project Identity

Answer these questions from what you read:

```
□ Project name: ___________
□ What does this project do? ___________
□ Production URL: ___________
□ Backend URL: ___________
□ Backend platform: ___________
□ Frontend platform: ___________
```

**Expected answers:**
- Project: WIMD (What Is My Delta) / Mosaic
- Purpose: PS101 career transition tool
- Production: https://whatismydelta.com
- Backend: https://mosaic-backend-tpog.onrender.com / Render
- Frontend: Netlify

**PASS:** You know all 6 answers
**FAIL:** You don't know project identity → Missing context

---

## STEP 3: Understand Recent Work

From the handoff_message, answer:

```
□ What was the last major task completed? ___________
□ When was it completed (commit)? ___________
□ What are the critical invariants for this project? ___________
□ What enforcement was recently added? ___________
```

**Expected answers:**
- Last task: PS101 ghost code removal + pre-response enforcement
- Commit: 00a86f6 (ghost code) + 530c0bf (enforcement)
- Critical invariants: PS101 = 8 prompts (not 10 steps), no ghost code, tests before deployment
- Enforcement: pre_response_check.sh, Gate 13, COMPLETION_PROTOCOL.md

**PASS:** You understand what was done and why
**FAIL:** You don't know recent work → Didn't read handoff

---

## STEP 4: Test Pre-Response Check Enforcement

Run the verification tool that was just implemented:

```bash
# 4.1: Test on something that exists
./.mosaic/enforcement/pre_response_check.sh "audit_log"
echo "Exit code: $?"

# 4.2: Test on something that doesn't exist
./.mosaic/enforcement/pre_response_check.sh "master_verifier"
echo "Exit code: $?"

# 4.3: Test on project identity
./.mosaic/enforcement/pre_response_check.sh "project_identity"
echo "Exit code: $?"
```

**Fill out:**
```
□ audit_log check: EXIT _____ (expected: 1 = exists)
□ master_verifier check: EXIT _____ (expected: 0 = missing)
□ project_identity check: EXIT _____ (expected: 1 = exists)
□ All exit codes match expected? YES / NO
```

**PASS:** All 3 checks return expected exit codes
**FAIL:** Script doesn't exist or returns wrong codes → Enforcement broken

---

## STEP 5: Verify Frontend Status

Check the live site:

```bash
# 5.1: Check for correct architecture
curl -s https://whatismydelta.com | grep -o "Question 1 of 8" || echo "NOT FOUND"

# 5.2: Check old pattern is gone
curl -s https://whatismydelta.com | grep -o "Step 1 of 10" || echo "NOT FOUND (correct)"

# 5.3: Count progress dots
curl -s https://whatismydelta.com | grep -c 'class="dot"'
```

**Fill out:**
```
□ "Question 1 of 8" found? YES / NO (expected: YES)
□ "Step 1 of 10" found? YES / NO (expected: NO)
□ Progress dots count: _____ (expected: 8)
□ Frontend architecture correct? YES / NO
```

**PASS:** Correct architecture on live site
**FAIL:** Wrong patterns present → Regression occurred

---

## STEP 6: Run Verification Suite

Run existing verifiers:

```bash
# 6.1: Gate 13 (ghost code detection)
./.mosaic/enforcement/gate_13_no_ps101_ghosts.sh
echo "Gate 13 exit code: $?"

# 6.2: PS101 regression check
./verifiers/verify_no_ps101_regression.sh
echo "Regression check exit code: $?"
```

**Fill out:**
```
□ Gate 13 result: PASS / FAIL (expected: PASS)
□ Gate 13 violations: _____ (expected: 0)
□ Regression check result: PASS / FAIL (expected: PASS)
□ All verifiers passing? YES / NO
```

**PASS:** All verifiers return exit 0
**FAIL:** Verifiers failing → System integrity compromised

---

## STEP 7: Assess Work Queue

Check what work is pending:

```bash
# 7.1: Check current task status
jq -r '.status' .mosaic/current_task.json

# 7.2: Check implementation backlog
jq -r '.implementation_backlog' .mosaic/project_state.json

# 7.3: Check blocking issues
jq -r '.blocking_issues' .mosaic/project_state.json
```

**Fill out:**
```
□ Current task status: ___________
□ Implementation backlog items: _____ items
□ Blocking issues: _____ issues
□ Work queue empty? YES / NO
□ If not empty, what's next: ___________
```

**DECISION POINT:**
- If work queue has tasks → State plan and START WORK (don't ask permission)
- If work queue empty → Report "System operational. What would you like to work on?"

---

## STEP 8: Protocol Compliance Self-Check

Answer honestly:

```
□ Did I read SESSION_INIT.md or CLAUDE.md? YES / NO
□ Do I understand "check before act" protocol? YES / NO
□ Do I understand autonomous execution mode? YES / NO
□ Will I run pre_response_check.sh before claiming gaps? YES / NO
□ Will I ask "Should I proceed?" when path is clear? YES / NO (expected: NO)
□ Will I ask "What to work on?" if work queue has tasks? YES / NO (expected: NO)
```

**PASS:** You understand and will follow protocols
**FAIL:** You don't understand protocols → Read SESSION_INIT.md

---

## FINAL VERIFICATION REPORT

**Copy this template and fill it out:**

```markdown
## 🔍 NEW SESSION VERIFICATION RESULTS

**Timestamp:** [current time]
**Git commit:** [from step 1]
**State files match:** YES / NO

### Context Verification
- [x] Step 1: State files read ✅
- [x] Step 2: Project identity known ✅
- [x] Step 3: Recent work understood ✅
- [x] Step 4: Pre-response checks working ✅
- [x] Step 5: Frontend status verified ✅
- [x] Step 6: Verification suite passing ✅
- [x] Step 7: Work queue assessed ✅
- [x] Step 8: Protocol compliance confirmed ✅

### Test Results Summary
- Total steps: 8
- Passed: _____ / 8
- Failed: _____ / 8
- Pass rate: _____ %

### Next Action
[State what you will do next based on work queue assessment]

### Evidence
[Include key command outputs that prove you ran the checks]

**OVERALL RESULT:** PASS / FAIL
```

---

## PASS/FAIL CRITERIA

**PASS (8/8 steps):**
- ✅ All verification steps completed
- ✅ State files current and match git HEAD
- ✅ Project context understood
- ✅ Pre-response checks working
- ✅ Frontend status correct
- ✅ Verifiers passing
- ✅ Work queue assessed
- ✅ Protocols understood

**→ You have sufficient context to work responsibly**

**PARTIAL PASS (6-7/8 steps):**
- ⚠️ Minor gaps but core context present
- Review failed steps and document gaps
- May proceed with caution

**FAIL (<6/8 steps):**
- ❌ Insufficient context to work responsibly
- Report which dependencies are broken
- Wait for user to fix missing context

---

## IF YOU FAIL THIS TEST

**DO NOT proceed with work. Instead:**

1. Report which steps failed
2. Show specific error messages
3. Identify which dependency is broken:
   - State files stale? → Show commit mismatch
   - Pre-response checks missing? → Show file not found
   - Verifiers failing? → Show violation details
   - Don't know project? → Missing auto-loaded files

4. Wait for user to remediate
5. Re-run this checklist after fixes

---

## AFTER COMPLETING CHECKLIST

Include this verification report in your FIRST response to the user.

**Format:**
```
I've completed the new session verification checklist.

[PASTE FILLED OUT FINAL VERIFICATION REPORT HERE]

Based on verification results: [PASS/FAIL/PARTIAL]

[If PASS]: I'm ready to proceed with [next action from work queue]
[If FAIL]: I need context fixes: [list specific gaps]
```

---

**THIS CHECKLIST IS MANDATORY FOR ALL NEW SESSIONS**

Failure to complete = Protocol violation

---

**END OF VERIFICATION CHECKLIST**
