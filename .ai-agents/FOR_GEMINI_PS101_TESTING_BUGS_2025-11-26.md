# For Gemini: PS101 Testing Session - Multiple UX Bugs Discovered

**Date:** 2025-11-26T23:35Z
**From:** Claude Code
**Priority:** HIGH - Multiple bugs blocking production deployment
**Status:** User actively testing, bugs documented, fixes in progress

---

## Summary

User tested PS101 flow through Step 9. Found multiple UX bugs that weren't caught by initial hoisting fix. All bugs appear related to function scope issues - helper functions not accessible to `renderCurrentStep()`.

---

## Bugs Found During Testing

### 1. Character Counter Not Updating

**Symptom:** Counter stays red and doesn't change as user types
**Expected:** Should update in real-time showing current character count
**Impact:** High - Users can't see if they've met minimum requirements

### 2. Prompt Counter Shows Wrong Values

**Symptom:** Displays incorrect prompt numbers:

- Step 5: Shows "3 of 4"
- Step 7: Shows "4 of 4"
- Step 8: Shows "3 of 4"
- Step 9: Shows "1 of 4"

**Expected:** Should show correct prompt index (1 of 4, 2 of 4, etc.)
**Impact:** High - Confuses users about progress

### 3. Coaching Hints Don't Change

**Symptom:** Hint text doesn't update between prompts
**Expected:** Different hint for each prompt
**Impact:** Medium - Reduces guidance quality

### 4. Not Consistently Advancing Through Prompts

**Symptom:** Sometimes stays on same prompt instead of advancing to next
**Expected:** Clicking Next with valid input should move to next prompt
**Impact:** Critical - Blocks completion of PS101

### 5. User Text Deleted on Validation Failure

**Symptom:** If user clicks Next without meeting minimum chars, their text disappears
**Expected:** Text should be saved even if validation fails
**Impact:** Critical - Data loss
**Status:** ✅ FIXED (Next button now saves before validating)

---

## Root Cause Analysis

**Initial Assessment:**
Helper functions defined at lines 2531-2671:

- `updateCharCount()`
- `validateCurrentStep()`
- `handleStepAnswerInput()`
- `updateNavButtons()`
- `showAutosaveIndicator()`
- `downloadSummary()`

These functions were initially inside `initPS101EventListeners()` function scope.

Claude moved them outside to global scope, but indentation and actual scope needs verification.

`renderCurrentStep()` at line 4022 calls these functions:

```javascript
function renderCurrentStep() {
  // ...
  updateCharCount(answer.length, step?.minChars, step?.maxChars);
  textarea.addEventListener('input', handleStepAnswerInput);
  // etc.
}
```

**If functions aren't truly global, these calls fail silently.**

---

## Fixes Applied So Far

### ✅ Completed

1. **Hoisting issues fixed** - Moved `handleStepAnswerInput` and `validateCurrentStep` before usage
2. **Next button saves text** - Changed to save before validation, preventing data loss
3. **Helper functions extracted** - Moved outside `initPS101EventListeners()` (but scope unclear)

### ⏳ In Progress

1. **Function scope verification** - Need to confirm helper functions are globally accessible
2. **Testing remaining steps** - User hasn't completed Step 10 yet

---

## Backups Created

**Latest:** `backups/pre-scope-fix_20251126_233100Z/`

- Created before attempting scope fixes
- Contains BACKUP_MANIFEST.md with full details
- Safe rollback point if scope fix makes things worse

**Previous:** `backups/pre-frontend-deploy_20251126_224015Z/`

- Before applying PS101 fixes to frontend

---

## Files Modified

**mosaic_ui/index.html:**

- Line 2531-2671: Helper functions (moved to global scope?)
- Line 2674: `initPS101EventListeners()`
- Line 2710-2722: Next button handler (saves before validation)
- Line 4022: `renderCurrentStep()` (calls helper functions)

**Not Yet Modified:**

- `frontend/index.html` - Still needs all PS101 fixes applied

---

## Request for Gemini

### Question 1: Function Scope Strategy

Which approach do you recommend for making helper functions accessible?

**Option A:** Verify they're at global scope (current approach)

```javascript
// At global scope (outside all functions)
function updateCharCount(current, minRequired, max) { ... }
function renderCurrentStep() {
  updateCharCount(...); // Should work
}
```

**Option B:** Attach to window object explicitly

```javascript
window.updateCharCount = function(current, minRequired, max) { ... }
function renderCurrentStep() {
  window.updateCharCount(...); // Guaranteed to work
}
```

**Option C:** Create PS101 namespace object

```javascript
const PS101Helpers = {
  updateCharCount: function(current, minRequired, max) { ... },
  validateCurrentStep: function() { ... }
};
function renderCurrentStep() {
  PS101Helpers.updateCharCount(...);
}
```

### Question 2: Testing Strategy

Should we:

1. Fix all scope issues FIRST, then test end-to-end?
2. Test through all 10 steps FIRST to find all bugs, then fix in batch?
3. Fix incrementally and test each fix?

### Question 3: Architecture Review

This is the second major issue from Phase 1 modularization (first was hoisting, now scope). Should we:

1. Continue quick fixes to unblock user?
2. Properly complete Phase 1 modularization with separate modules?
3. Revert Phase 1 and use working pre-modularization code?

---

## User Feedback

**Key Quotes:**

- "these are all new problems"
- "can we make sure by creating another backup that we will not go backwards when we either restart or solve more problems?"
- "i thought i wanted the functionality to save what the users answers were and then provided feedback as people wrote, its not doing that"

**User Priority:** Get PS101 working end-to-end so they can complete testing and deploy to production.

---

## Next Steps (Pending Your Guidance)

**Immediate:**

1. Fix function scope issues (waiting for your recommendation on approach)
2. Test character counter updates in real-time
3. Verify prompt counter shows correct values
4. Complete testing through all 10 steps

**After Bugs Fixed:**

1. Apply all fixes to frontend/index.html
2. Create pre-deployment backup
3. Deploy to Netlify
4. Verify production PS101 flow works end-to-end

**Long-term:**

1. Consider completing Phase 1 modularization properly
2. Add automated tests to catch these issues
3. Document PS101 architecture for future work

---

## Current Status

- **Server:** Running on localhost:3000
- **User:** Actively testing, waiting for fixes
- **Branch:** phase1-incomplete
- **Backups:** 2 timestamped backups created
- **AI_RESUME_STATE.md:** Updated with full context

---

**Claude Code**
