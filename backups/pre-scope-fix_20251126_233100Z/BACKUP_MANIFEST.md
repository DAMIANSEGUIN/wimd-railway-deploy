# Backup Manifest - Pre-Scope Fix

**Created:** 2025-11-26T23:31:00Z
**Agent:** Claude Code
**Purpose:** Before fixing function scope issues that prevent character counter and prompt updates

---

## Current State

**Fixes Applied:**

- ✅ Hoisting issues fixed (handleStepAnswerInput, validateCurrentStep moved before usage)
- ✅ Next button saves text even when validation fails
- ✅ Helper functions moved outside initPS101EventListeners (PARTIAL)

**Known Bugs Still Present:**

- ❌ Character counter doesn't update as you type (stays red)
- ❌ Prompt counter shows wrong values (e.g., "3 of 4" at step 5)
- ❌ Coaching hints don't change between prompts
- ❌ Not consistently advancing through prompts

**Root Cause Identified:**

- Helper functions (updateCharCount, validateCurrentStep, etc.) defined at lines 2531-2671
- But they may have wrong indentation/scope
- `renderCurrentStep()` at line 4022 tries to call these functions
- If functions aren't globally accessible, nothing updates

---

## Files in This Backup

### mosaic_ui_index.html

- **Source:** `mosaic_ui/index.html`
- **Status:** Has hoisting fixes + partial scope fix
- **Issues:** Character counter, prompt counter, coaching hints not working

### frontend_index.html

- **Source:** `frontend/index.html`
- **Status:** Has helper functions added (from earlier), NOT tested

---

## Recovery Instructions

If scope fix makes things worse:

```bash
BACKUP="backups/pre-scope-fix_20251126_233100Z"
cp "$BACKUP/mosaic_ui_index.html" mosaic_ui/index.html
```

---

## Next Steps

1. Fix function scope so helper functions are globally accessible
2. Ensure renderCurrentStep() can call updateCharCount, validateCurrentStep, etc.
3. Test character counter updates as you type
4. Test prompt counter shows correct values
5. Test coaching hints change between prompts

---

**DO NOT DELETE until scope fix is verified working**
