# PS101 Canonical Specification (v3 - CORRECTED)

**Date:** 2026-02-15
**Author:** Claude Sonnet 4.5 (Architectural Correction)
**Status:** CANONICAL - Replaces v2
**Authority:** This document supersedes all previous PS101 specifications

---

## CRITICAL CORRECTION

**PREVIOUS ARCHITECTURE (v1-v2) WAS INCORRECT:**
- 10 steps with 3-6 prompts each = 30+ total questions
- Complex nested navigation ("Prompt 3 of 6" within "Step 1 of 10")
- User reported this as wrong for 2+ months

**CORRECT ARCHITECTURE (v3):**
- **8 sequential prompts** (linear flow, no nesting)
- Simple navigation: "Question 1 of 8", "Question 2 of 8", etc.
- Source of truth: `frontend/data/prompts.ps101.json`

---

## 1. The 8 PS101 Prompts

These 8 prompts are the complete PS101 experience:

1. **What problem are you trying to solve, in one sentence?**
2. **What would 'success' look like in 4–6 weeks? Be specific.**
3. **What is the single biggest obstacle between you and that success?**
4. **What's one action you can take in the next 48 hours?**
5. **If you had to cut the plan to a third, what would you keep?**
6. **Who can you ask for help, and what exactly will you ask?**
7. **What data would convince you the plan is working?**
8. **What's the smallest test that would move this forward?**

---

## 2. User Experience

### Navigation Flow
```
Welcome Screen
    ↓
Question 1 of 8 → Answer → Next
    ↓
Question 2 of 8 → Answer → Next
    ↓
...
    ↓
Question 8 of 8 → Answer → Complete
    ↓
Summary Screen (all 8 answers displayed)
```

### Progress Indicator
- 8 dots representing 8 questions
- Current question highlighted
- Completed questions filled
- Label: "Question N of 8"

### Validation
- Minimum 10 characters per answer
- "Next →" button disabled until valid
- "Complete →" on final question
- "← Back" always available (except Q1)

---

## 3. Implementation Requirements

### Frontend
- Load prompts from `frontend/data/prompts.ps101.json`
- Single `currentPromptIndex` (0-7)
- No nested step structure
- Simple state: `{currentPromptIndex, answers[], startedAt, completed}`

### Storage
- localStorage key: `ps101_simple_state`
- Backend sync (future): POST to `/api/ps101/save`

### Visual Design
- Peripheral Calm aesthetic (existing Mosaic style)
- Generous whitespace
- Smooth 180-220ms transitions
- Autosave with "Saved • HH:MM" indicator

---

## 4. Data Structure

```javascript
{
  "currentPromptIndex": 0,        // 0-7
  "answers": [                     // Array of 8 strings
    "Answer to question 1",
    "Answer to question 2",
    // ...
    "Answer to question 8"
  ],
  "startedAt": "2026-02-15T...",
  "completed": false
}
```

---

## 5. Deprecated Concepts

**DO NOT IMPLEMENT:**
- ❌ Steps (no Step 1, Step 2, etc.)
- ❌ Multiple prompts per step
- ❌ Nested navigation
- ❌ Experiment canvas (Step 6)
- ❌ Obstacle mapping (Step 7)
- ❌ Action planning (Step 8)
- ❌ 10 dots (use 8 dots)
- ❌ PS101_STEPS array

These were part of incorrect v2 architecture and should be removed.

---

## 6. Migration Path

### For Existing Users
- If localStorage contains `ps101_v2_state` with complex structure:
  - Extract answers from nested structure
  - Flatten to 8 answers (take first answer from each step 1-8)
  - Save as `ps101_simple_state`
  - Clear old state

### Code Changes Required
1. Replace `PS101_STEPS` array with simple prompt loader
2. Remove all step-related logic
3. Update progress indicator (10 → 8 dots)
4. Simplify navigation (no sub-prompts)
5. Update all tests

---

## 7. Success Metrics

**User Experience:**
- Single linear flow (no confusion about "prompts within steps")
- Completion time: 15-20 minutes
- All 8 questions answered

**Technical:**
- Simple codebase (~300 lines vs 1000+)
- Easy to maintain
- Fast load time
- No architectural complexity

---

## 8. References

**Source Files:**
- Canonical prompt list: `frontend/data/prompts.ps101.json`
- Implementation: `frontend/ps101_simple.js`
- Tests: `test-ps101-simple-flow.js` (to be created)

**Deprecated Files:**
- ❌ `docs/PS101_CANONICAL_SPEC_V2.md` (complex 10-step version)
- ❌ `docs/IMPLEMENTATION_SUMMARY_PS101_V2.md`
- ❌ All references to "10 steps" or "multi-prompt steps"

---

**This specification is now the single source of truth for PS101 architecture.**
