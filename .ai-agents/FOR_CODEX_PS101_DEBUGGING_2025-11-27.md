# For Codex: PS101 Debugging Session

**Date:** 2025-11-27
**From:** Claude Code (Sonnet 4.5)
**To:** Codex (Terminal/Cursor)
**Priority:** HIGH - User waiting for PS101 fixes
**Role:** Debugging & Testing

---

## Your Mission

Debug the PS101 flow to identify the **actual root cause** of the UX bugs found during user testing. User needs PS101 working end-to-end.

---

## Context

**What happened:**

1. User tested PS101 through Step 9
2. Found 5 critical UX bugs (see below)
3. Gemini analyzed and approved fix: "Move function definitions to global scope"
4. Claude (me) examined code and found functions ARE already at global scope
5. BUT also found duplicate `updateNavButtons` function definitions (lines 2575 and 2673)
6. Need actual debugging to find real problem

**Current status:**

- Local server NOT running
- Files have been modified but bugs still present
- Backup available at `backups/pre-scope-fix_20251126_233100Z/`

---

## The 5 Bugs to Debug

1. ❌ **Character counter doesn't update as you type** - stays red/static
2. ❌ **Prompt counter shows wrong values** (e.g., "3 of 4" at step 5, "4 of 4" at step 7)
3. ❌ **Coaching hints don't change** between prompts
4. ❌ **Not consistently advancing** through prompts - sometimes stays on same prompt
5. ❌ **Completion screen says "Next Prompt"** instead of completion message

---

## Your Tasks

### 1. Start Local Server

```bash
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
python3 local_dev_server.py
# Server should start on http://localhost:3000
```

### 2. Open Browser & Test PS101

- Navigate to <http://localhost:3000>
- Click "Start PS101" or continue if in progress
- Open browser DevTools console (F12 or Cmd+Option+I)

### 3. Test Each Bug & Capture Errors

**Bug 1: Character Counter**

- Start typing in textarea
- Watch char counter (should update in real-time)
- Check console for JavaScript errors
- Expected: `updateCharCount()` should be called on input event

**Bug 2: Prompt Counter**

- Note what step you're on
- Check what the counter displays
- Click "Next Prompt" several times
- Record actual vs. expected values

**Bug 3: Coaching Hints**

- Read the hint text
- Click "Next Prompt"
- Does hint change?
- Check if `PROMPT_HINTS` array is being accessed correctly

**Bug 4: Advancing Through Prompts**

- Fill out a prompt (meet minimum chars)
- Click "Next Prompt"
- Does it advance or stay on same prompt?
- Check console for validation errors

**Bug 5: Completion Screen**

- Complete all 10 steps
- Check final button text
- Should say "Complete PS101 →" not "Next Prompt →"

### 4. Inspect Function Scope in Console

In browser console, check if functions are accessible:

```javascript
// Test if functions exist at global scope
typeof updateCharCount
typeof handleStepAnswerInput
typeof validateCurrentStep
typeof updateNavButtons
typeof renderCurrentStep

// Check for duplicates
updateNavButtons.toString()
```

### 5. Check Event Listeners

```javascript
// Get textarea and inspect listeners
const textarea = document.getElementById('step-answer');
console.log('Textarea:', textarea);

// Check if input event is attached
// (May need to use getEventListeners(textarea) in Chrome DevTools)
```

---

## Key Files to Examine

**Main file:** `mosaic_ui/index.html`

**Critical sections:**

- Line 2531-2573: `updateCharCount()` - Should update character display
- Line 2575-2622: `updateNavButtons()` - FIRST definition
- Line 2673-2720: `updateNavButtons()` - DUPLICATE (suspicious!)
- Line 2772-2844: `validateCurrentStep()` - Validates before advancing
- Line 2847-2859: `handleStepAnswerInput()` - Called on textarea input
- Line 2862: `initPS101EventListeners()` - Sets up event listeners
- Line 2984: `renderCurrentStep()` - Renders each prompt

**Specific issues to check:**

- Are there TWO definitions of `updateNavButtons`? (lines 2575 and 2673)
- Which one is actually being called?
- Is `handleStepAnswerInput` actually attached to textarea?
- Is `updateCharCount` being called when user types?

---

## Expected Findings

Please document:

1. **Console errors** (exact error messages, line numbers)
2. **Function accessibility** (are functions defined at global scope?)
3. **Event listener status** (is input event attached to textarea?)
4. **Duplicate function issue** (which `updateNavButtons` is active?)
5. **State management** (is `PS101State` updating correctly?)

---

## Deliverable

Create a file: `.ai-agents/CODEX_DEBUGGING_FINDINGS_2025-11-27.md`

Include:

- What's actually broken (not what we thought was broken)
- Console errors (screenshots or copy/paste)
- Function scope findings
- Which of the 5 bugs are related vs. separate issues
- Recommended fix approach

---

## Notes

- User has approval for all actions this session
- Server process: Kill with Ctrl+C when done
- If you need to restore backup: `cp backups/pre-scope-fix_20251126_233100Z/mosaic_ui_index.html mosaic_ui/index.html`

---

## Handoff Back to Claude Code

When debugging complete, create handoff with:

- Root cause(s) identified
- Recommended implementation approach
- Any code snippets showing the fix

Claude Code will implement the fixes based on your findings.

---

**Codex - you are the debugging specialist. Find the real problem!**
