# For Gemini: PS101 Hoisting Issue - Phase 1 Modularization Bug

**Date:** 2025-11-26T22:10Z
**From:** Claude Code
**Priority:** HIGH - Blocks PS101 functionality
**Status:** Problem defined, backup created, awaiting architectural guidance

---

## Problem Summary

**User Report:** "Got past sign in/log in. Main chat worked, got to step 1 of PS101 but no further."

**Root Cause:** Phase 1 modularization introduced a function hoisting error.

---

## Technical Details

### Console Error
```
[INIT] Initialization error: ReferenceError:
handleStepAnswerInput is not defined
  at initApp (index:2519:7)
  at HTMLDocument.safeInitApp (index:3124:7)
```

### Code Issue

**File:** `mosaic_ui/index.html`

**Line 2590-2591:** Function is used
```javascript
const textarea = document.getElementById('step-answer');
if (textarea) {
  textarea.removeEventListener('input', handleStepAnswerInput);
  textarea.addEventListener('input', handleStepAnswerInput); // ❌ ReferenceError
}
```

**Line 3759:** Function is defined (~1200 lines later)
```javascript
function handleStepAnswerInput(e) {
  const step = PS101State.getCurrentStep();
  if (!step) return;
  updateCharCount(
    e.target.value.length,
    step?.minChars || 0,
    step?.maxChars || 0
  );
  PS101State.setAnswer(PS101State.currentStep, PS101State.currentPromptIndex, e.target.value);
  const promptIndex = PS101State.currentPromptIndex || 0;
  const totalPrompts = step.prompts ? step.prompts.length : 1;
  updateNavButtons(PS101State.currentStep, promptIndex, totalPrompts);
}
```

### Why This Happened

During Phase 1 modularization, code was reorganized but function definitions weren't hoisted properly. JavaScript function declarations are hoisted, but this function is being referenced before its declaration appears in the code flow.

---

## Proposed Solutions

### Option 1: Move Function Definition (Simple)
Move `handleStepAnswerInput` definition from line 3759 to before line 2590.

**Pros:**
- Simple, minimal change
- Fixes immediate issue

**Cons:**
- Doesn't address architectural question
- May have other similar issues

### Option 2: Hoist All PS101 Functions (Comprehensive)
Review all PS101 functions and ensure proper hoisting order.

**Pros:**
- Prevents similar issues
- Better architecture

**Cons:**
- More work
- Need to review entire PS101 code structure

### Option 3: Module Refactor (Long-term)
Complete the Phase 1 modularization by moving PS101 functions to separate module.

**Pros:**
- Proper separation of concerns
- Prevents hoisting issues

**Cons:**
- Larger scope
- Delays fix

---

## Current State

### Backup Created
**Location:** `backups/pre-ps101-fix_20251126_220704Z/`
**Reference:** `.ai-agents/CURRENT_BACKUP_REFERENCE.md`
**Commit:** c8f1fd3

Safe to experiment with fixes.

### Testing Environment
- Local server running: http://localhost:3000/ (PID 57948)
- CodexCapture active in Chromium
- User has verified issue with screenshots

### Files Affected
- `mosaic_ui/index.html` - Needs fix
- `frontend/index.html` - Will need same fix

---

## Request for Gemini

**As the architect of Phase 1 modularization:**

1. **Which solution do you recommend?**
   - Option 1 (quick fix)?
   - Option 2 (comprehensive review)?
   - Option 3 (complete refactor)?
   - Different approach?

2. **Are there other similar hoisting issues** we should check for?

3. **Should we complete Phase 1 modularization** properly before more fixes?

4. **Testing strategy:** Once fixed, what should we verify works?

---

## What I Can Do

Once you provide architectural guidance, I can:
- Implement the fix in `mosaic_ui/index.html`
- Apply to `frontend/index.html`
- Test locally with CodexCapture
- Deploy to Netlify
- Verify PS101 flow works end-to-end

---

## Timeline

**Blocking:** User cannot use PS101 (core feature)
**Urgency:** Medium-High (other features work)
**Complexity:** Low (once approach decided)

Awaiting your architectural decision.

---

**Claude Code**
