# COMPLETION PROTOCOL

**MANDATORY: Before claiming ANY work is "complete" or "deployed successfully"**

Created: 2026-02-15
Authority: This protocol is BLOCKING - cannot be skipped

---

## ⚠️ CRITICAL RULE

**DO NOT claim work is complete until ALL checks pass.**

If you say "deployment complete" or "all work done" without running these checks, that is a **protocol failure**.

---

## CHECK BEFORE ACT + AVOID CODE BLOAT PROTOCOL (MANDATORY)

**Before running ANY command or creating ANY file:**

### Step 1: Check if action is needed
```bash
# ❌ WRONG: Act without checking
npm install
npx playwright install chromium

# ✅ CORRECT: Check first
npm list || npm install
npx playwright --version || npx playwright install chromium
```

### Step 2: Check for existing similar solutions (AVOID BLOAT)
```bash
# ❌ WRONG: Create new file without checking for similar
cat > validate_new_feature.sh

# ✅ CORRECT: Search for existing validators
find . -name "*validate*.sh" -o -name "*verify*.sh"
# If found: Extend existing file instead

# ❌ WRONG: Create new test file
cat > test-feature-v2.js

# ✅ CORRECT: Check existing tests
ls test-*.js
# If similar exists: Add to existing test file

# ❌ WRONG: Create new protocol doc
cat > .mosaic/NEW_PROTOCOL.md

# ✅ CORRECT: Check existing docs
ls .mosaic/*.md | grep -i protocol
# If similar exists: Update existing doc instead
```

### Step 3: Decision Tree
```
About to create/install something?
  ↓
  Does it already exist exactly? → Use it (no action)
  ↓
  Does something similar exist? → Extend/upgrade it
  ↓
  Will this duplicate functionality? → Don't create
  ↓
  No existing solution? → Create new + document why
```

**Why this matters:**

- **Avoids code bloat:** Prevents duplicate implementations
- **Reduces maintenance:** One place to update vs many
- **Improves discoverability:** Easier to find existing solutions
- **Prevents conflicts:** No competing implementations
- **Shows awareness:** Demonstrates understanding of codebase
- **Saves time:** Reusing is faster than creating new

---

## COMPLETION CHECKLIST (Execute in Order)

### Step 1: Code-Level Verification
```bash
□ Run regression detector (if applicable to change)
□ Run unit tests (if applicable)
□ Check for compilation/syntax errors
□ Verify no TODO/FIXME comments in changed code
```

### Step 2: Deployment Verification
```bash
□ Code committed to git
□ Code pushed to origin/main
□ Deployment triggered (Netlify/Render)
□ Deployment completed (check dashboard)
□ No deployment errors in logs
```

### Step 3: Live Site Verification (MANDATORY)
```bash
□ Curl live site to verify code present
□ Check specific change is visible (grep/search)
□ Verify old code NOT present (grep for removed patterns)
```

### Step 4: FRONTEND TESTING (MANDATORY for UI changes)
```bash
□ Run E2E test suite: node test-ps101-simple-flow.js
□ Verify test exit code = 0 (success)
□ Check test output: X/X PASSED
□ Review any test warnings or skipped tests
□ If tests fail: DO NOT claim completion, fix issues first
```

**PS101-Specific Tests:**
```bash
# Must pass before claiming PS101 work is complete:
□ node test-ps101-simple-flow.js → 38/38 PASSED
□ ./.mosaic/enforcement/gate_13_no_ps101_ghosts.sh → EXIT 0
□ ./verifiers/verify_no_ps101_regression.sh → EXIT 0
```

### Step 5: Manual Verification (For Critical Changes)
```bash
□ Open live site in browser
□ Test the specific feature changed
□ Verify expected behavior
□ Check browser console for errors
□ Test on different viewport sizes (if UI change)
```

### Step 6: Monitoring (First 5-10 Minutes)
```bash
□ Check logs for errors (Netlify/Render)
□ Monitor error rate (if tracking implemented)
□ Check health endpoint
□ Verify no user-facing errors
```

### Step 7: Documentation
```bash
□ Update CLAUDE.md if status changed
□ Create receipt file (if applicable)
□ Update relevant protocol docs
□ Commit documentation changes
```

---

## FAILURE MODES & ACTIONS

**If ANY check fails:**

1. **DO NOT** claim work is complete
2. **DO NOT** say "deployment successful"
3. **DO** fix the failing check first
4. **DO** re-run all checks after fix
5. **DO** document what failed and how it was fixed

**If test infrastructure is broken:**

1. **DO NOT** skip tests
2. **DO** fix the test infrastructure
3. **DO** verify tests can run
4. **THEN** re-run tests and verify pass

**If tests pass locally but fail in CI/CD:**

1. **DO NOT** bypass CI/CD
2. **DO** investigate environment difference
3. **DO** fix root cause (not the test)
4. **THEN** verify CI/CD passes

---

## EXAMPLES

### ❌ WRONG (Protocol Failure)

```
Agent: "All work completed successfully. The deployment is live."

[But agent did not run frontend tests]
[User discovers bugs in production]
```

### ✅ CORRECT

```
Agent: "Code deployed. Let me verify before claiming completion."

[Runs curl checks]
[Runs E2E tests: 38/38 PASSED]
[Opens browser to manual test]
[Checks logs for 5 minutes]

Agent: "Verification complete:
- ✅ Code deployed and visible on live site
- ✅ E2E tests: 38/38 PASSED (100%)
- ✅ No errors in logs
- ✅ Manual test confirmed working
Work is now complete."
```

---

## ENFORCEMENT

**How this protocol is enforced:**

1. **Technical:** Pre-push hook runs tests (blocks bad code)
2. **Procedural:** This document defines completion criteria
3. **Cognitive:** Agent must follow this checklist before claiming done

**Why all three layers:**

- Technical enforcement can fail (Playwright not installed)
- Procedural enforcement requires reading docs
- Cognitive enforcement requires agent discipline

**This protocol is mandatory to prevent:**

- Claiming completion when tests weren't run
- Deploying broken code that passes hooks
- False confidence in deployment status

---

## INTEGRATION WITH OTHER PROTOCOLS

**Related documents:**

- `.mosaic/SESSION_START_PS101.md` - PS101-specific session start
- `.git/hooks/pre-push` - Automated pre-deployment checks
- `TROUBLESHOOTING_CHECKLIST.md` - Debugging workflow
- `.mosaic/enforcement/gate_13_no_ps101_ghosts.sh` - Ghost code detector

**When to use this protocol:**

- ✅ Before saying "work complete"
- ✅ Before saying "deployment successful"
- ✅ Before marking task as "done"
- ✅ Before closing session (if work was done)
- ✅ Before handoff to next agent

**When NOT needed:**

- ❌ Exploratory work (no deployment)
- ❌ Documentation-only changes (no code)
- ❌ Investigation tasks (no changes made)

---

## LAST UPDATED

**Date:** 2026-02-15
**Reason:** Frontend testing protocol gap discovered
**Incident:** Agent claimed completion without running E2E tests
**Resolution:** This document created as mandatory checklist

---

**END OF COMPLETION PROTOCOL**
