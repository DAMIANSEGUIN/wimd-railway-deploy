# CRITICAL RESTART CONTEXT - PS101 REGRESSION INCIDENT

**Date:** 2025-11-27T18:00:00Z
**Severity:** CRITICAL
**Status:** RECOVERY IN PROGRESS
**Incident:** Catastrophic regression caused by incorrect backup restoration

---

## WHAT WENT WRONG

### Incident Timeline

1. **User reported PS101 bugs** (character counter, prompt counter, etc.)
2. **Gemini approved** "move functions" fix approach
3. **Codex debugged** - Found PS101 objects missing from mosaic_ui/index.html
4. **Claude MADE FATAL ERROR:**
   - Restored from WRONG backup: `pre-scope-fix_20251126_233100Z`
   - This backup was ALREADY BROKEN (missing js/main.js file)
   - Never verified backup was working before restoring
   - Never tested after restoration
   - Declared "RESOLVED" without verification

5. **User tested** - Found:
   - ❌ Login missing
   - ❌ Main chat doesn't work
   - ❌ 404 errors for js/main.js
   - ❌ All original bugs PLUS new regressions

---

## ROOT CAUSE ANALYSIS

### Primary Failures

1. **Wrong backup selected** - `pre-scope-fix` was POST-problem, not PRE-problem
2. **No backup verification** - Never checked BACKUP_MANIFEST.md
3. **No post-restore testing** - Assumed it worked
4. **Codex recommendation not validated** - Blindly followed without verification
5. **Phase 1 modularization incomplete** - Created js/main.js reference that doesn't exist

### Why This Happened

- Backup naming was confusing ("pre-scope-fix" sounds like it's before problems)
- No systematic backup testing protocol
- Claude trusted Codex recommendation without verification
- No mandatory post-restore verification step

---

## CORRECT BACKUP IDENTIFIED

**Working backup:** `backups/pre-ps101-fix_20251126_220704Z/`

**Why this is correct:**

- Manifest says: "working local version"
- Created BEFORE PS101 fix attempts started
- Should have login, chat, auth - everything except PS101 advancement
- Date: 2025-11-26 22:07:04Z (earliest recent backup)

**Known issue in this backup:**

- PS101 cannot progress past step 1
- ReferenceError: handleStepAnswerInput is not defined
- This is ACCEPTABLE - we can fix this specific issue
- Better than broken login/chat/auth

---

## CURRENT STATE (2025-11-27T18:00Z)

**Files:**

- `mosaic_ui/index.html` - Restored from pre-ps101-fix backup + removed js/main.js line
- Server: Running on <http://localhost:3000>
- Chromium: Launched with CodexCapture

**Expected behavior NOW:**

- ✅ Login should work
- ✅ Chat should work
- ✅ Auth modal should work
- ❌ PS101 will fail at step 1 with handleStepAnswerInput error (KNOWN ISSUE)

---

## MANDATORY RESTART PROTOCOL

**For ANY AI agent resuming this work:**

### Step 1: Read These Files (IN ORDER)

1. **THIS FILE FIRST** - `CRITICAL_RESTART_CONTEXT.md`
2. `AI_RESUME_STATE.md` - Current session state
3. `CLAUDE.md` - Architecture overview
4. `.ai-agents/TEAM_DOCUMENTATION_REFERENCE.md` - All handoff docs

### Step 2: Verify Current State

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

# Check which backup we're using
head -20 mosaic_ui/index.html | grep -i "backup\|version"

# Verify no js/main.js reference
grep -n "js/main.js" mosaic_ui/index.html
# Should return NOTHING

# Verify PS101 objects present
grep -c "const PS101_STEPS\|const PS101State\|const PROMPT_HINTS" mosaic_ui/index.html
# Should return 3

# Check server running
ps aux | grep local_dev_server | grep -v grep
```

### Step 3: Test BEFORE Making Any Changes

```bash
# Start test environment
./start_ps101_test.sh

# Test these features:
# 1. Login works
# 2. Chat works
# 3. Auth modal appears
# 4. PS101 loads (will fail at step 1 - EXPECTED)
```

### Step 4: Document What You Find

**Create:** `.ai-agents/[AGENT]_RESTART_FINDINGS_[DATE].md`

Include:

- What's working
- What's broken
- Matches expected state (yes/no)
- Ready to proceed (yes/no)

### Step 5: Only THEN Proceed

**DO NOT:**

- Restore from ANY backup without verification
- Make code changes before testing current state
- Trust any recommendation without validation
- Declare anything "fixed" without user testing

---

## BACKUP VERIFICATION PROTOCOL

**BEFORE restoring from ANY backup:**

1. **Read the BACKUP_MANIFEST.md**

   ```bash
   cat backups/[BACKUP_NAME]/BACKUP_MANIFEST.md
   ```

2. **Check what state it captures:**
   - "working" = good
   - "before fixing X" = might be broken
   - "pre-scope-fix" = AFTER problem started
   - "pre-ps101-fix" = BEFORE problems started ✅

3. **Verify the file:**

   ```bash
   # Check PS101 objects present
   grep -c "PS101_STEPS\|PS101State\|PROMPT_HINTS" backups/[NAME]/mosaic_ui_index.html

   # Check NO js/main.js reference
   grep "js/main.js" backups/[NAME]/mosaic_ui_index.html
   # Should be empty
   ```

4. **Test in isolation:**

   ```bash
   # Copy to test location
   cp backups/[NAME]/mosaic_ui_index.html /tmp/test_index.html

   # Start test server pointing to /tmp
   # Verify it loads without errors
   ```

5. **ONLY THEN restore to production**

---

## LESSONS LEARNED

### What Went Wrong

1. **Trusted recommendations blindly** - Codex said "restore from X" and Claude did it without verification
2. **No testing after changes** - Declared "RESOLVED" without user testing
3. **Confusing backup names** - "pre-scope-fix" sounds like it's PRE-problem but it's POST-problem
4. **No verification protocol** - Should have mandatory checklist before/after restore

### What Must Change

1. **MANDATORY:** Read BACKUP_MANIFEST.md before any restore
2. **MANDATORY:** Test backup in isolation before applying
3. **MANDATORY:** User testing before declaring "fixed"
4. **MANDATORY:** Clear backup naming (use dates + "WORKING" vs "BROKEN")
5. **MANDATORY:** Post-restore verification checklist

---

## TEAM ROLES CLARIFICATION

**This incident shows role confusion:**

### Gemini (Architecture)

- ✅ Provided architectural guidance
- ✅ Approved "move functions" approach
- ❌ Not asked to review backup selection

### Codex (Debugging)

- ✅ Found root cause (missing PS101 objects)
- ❌ Recommended wrong backup
- ❌ Didn't verify backup before recommending

### Claude (Implementation)

- ❌ **CRITICAL FAILURE:** Restored without verification
- ❌ **CRITICAL FAILURE:** Didn't test after restore
- ❌ **CRITICAL FAILURE:** Declared "RESOLVED" prematurely
- ✅ Now documenting failure for team learning

---

## NEXT STEPS

### Immediate (Claude)

1. Verify current state matches "pre-ps101-fix" backup expectations
2. Test login, chat, auth work
3. Confirm PS101 fails at step 1 (expected)
4. Hand to user for verification

### Short-term (For Next Agent)

1. Fix the handleStepAnswerInput hoisting issue
2. Test PS101 advancement works
3. Complete all 10 steps
4. Deploy to production

### Long-term (For Gemini)

1. Review this incident
2. Recommend process improvements
3. Decide on Phase 1 modularization strategy
4. Create backup verification checklist

---

## FILES REFERENCE

**Current backups:**

- `backups/pre-ps101-fix_20251126_220704Z/` - ✅ WORKING (before PS101 issues)
- `backups/pre-scope-fix_20251126_233100Z/` - ❌ BROKEN (has js/main.js issue)
- `backups/post-restore_20251127_171057Z/` - ❌ BROKEN (copied from wrong source)

**Working file:**

- `mosaic_ui/index.html` - Currently restored from pre-ps101-fix + js/main.js removed

**Fallback:**

- `mosaic_ui/index.html.bak` - Unknown state, dated 2025-11-13

---

## FOR USER

I apologize for this catastrophic regression. I:

1. Restored from the wrong backup
2. Never verified it was working
3. Declared it "fixed" without testing
4. Created MORE problems than we started with

This is unforgivable and I've documented everything above so this never happens again.

**Current status:**

- Restored from correct backup (pre-ps101-fix)
- Removed broken js/main.js reference
- Ready for you to test: <http://localhost:3000>
- Expected: Login/chat work, PS101 fails at step 1

---

**Last updated:** 2025-11-27T18:00:00Z by Claude Code
**Incident severity:** CRITICAL
**Recovery status:** IN PROGRESS
