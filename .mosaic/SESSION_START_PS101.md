# PS101 ARCHITECTURE - SESSION START PROTOCOL

**READ THIS FIRST BEFORE ANY PS101 WORK**

Date: 2026-02-15
Status: CANONICAL - Mandatory reading for all agents
Authority: This document supersedes all other PS101 documentation

---

## ⚠️ CRITICAL: PS101 IS 8 PROMPTS, NOT 10 STEPS

**THE CORRECT ARCHITECTURE:**
- **8 sequential prompts** (linear flow)
- "Question 1 of 8" → "Question 2 of 8" → ... → "Question 8 of 8"
- 8 progress dots
- Simple flat state structure
- No nesting, no steps, no sub-prompts

**THE WRONG ARCHITECTURE (2+ months of error):**
- ❌ 10 steps with nested prompts
- ❌ "Step 1 of 10" → "Prompt 3 of 6"
- ❌ 30+ total questions
- ❌ Complex nested state
- ❌ Experiment components (Step 6-9)

---

## WHY THIS MATTERS

**User explicitly stated:**
- "this is definitely NOT how it is supposed to work"
- "I have been saying this for at least 2 months"
- "step 1 is not meant to have 6 steps, that would be crazy making for the user"

**2+ months of development wasted on wrong architecture because:**
1. Documentation (v2 spec) was wrong
2. Agents trusted docs over user feedback
3. No enforcement to prevent regression

**THIS MUST NEVER HAPPEN AGAIN.**

---

## MANDATORY REFERENCES (READ THESE IN ORDER)

### 1. **ONLY Canonical Spec** ✅
**File:** `docs/PS101_CANONICAL_SPEC_V3_CORRECTED.md`
**Status:** AUTHORITATIVE - This is the ONLY correct spec

**Key points:**
- 8 prompts total (listed in spec)
- Source of truth: `frontend/data/prompts.ps101.json`
- Simple linear flow
- No nested structure

### 2. **Deprecated Spec** ❌
**File:** `docs/DEPRECATED_PS101_CANONICAL_SPEC_V2.md`
**Status:** WRONG - Do NOT implement anything from this file

**Why it exists:**
- Historical record of 2-month error
- Lesson learned documentation
- Shows what NOT to do

### 3. **Correction Documentation**
**File:** `docs/ARCHITECTURE_CORRECTION_2026_02_15.md`
**Purpose:** Explains the 2-month error and correction process

### 4. **Implementation**
**File:** `frontend/index.html` (lines ~2800+)
**Code:** Embedded PS101 simple flow (8 prompts)
**Note:** Old 10-step code was REMOVED on 2026-02-15

---

## ENFORCEMENT MECHANISMS (DO NOT BYPASS)

### Gate 13: Ghost Code Detection
**File:** `.mosaic/enforcement/gate_13_no_ps101_ghosts.sh`
**Purpose:** Blocks deployment if old 10-step code is present
**When:** Runs in pre-push hook (automatic)

**Detects:**
- Old methods: `getActiveExperiment()`, `getCurrentStep()`, `goToStep()`
- Old patterns: `step.prompts.length`
- Experiment components
- Duplicate PS101State definitions

**If this fails:** DO NOT bypass - it means ghost code from old architecture is back

### Regression Detection
**File:** `verifiers/verify_no_ps101_regression.sh`
**Purpose:** 12-point check for old architecture
**When:** Run manually or in CI

### E2E Test
**File:** `test-ps101-simple-flow.js`
**Purpose:** Validates 8-prompt flow works correctly
**Expectation:** 38/38 tests pass

---

## IF YOU NEED TO WORK ON PS101

### ✅ DO THIS:

1. **Read v3 spec first:**
   ```bash
   cat docs/PS101_CANONICAL_SPEC_V3_CORRECTED.md
   ```

2. **Check current implementation:**
   ```bash
   grep -A20 "PS101 Simple Sequential Flow" frontend/index.html
   ```

3. **Run regression detector:**
   ```bash
   ./verifiers/verify_no_ps101_regression.sh
   ```

4. **Test before deploying:**
   ```bash
   node test-ps101-simple-flow.js
   ```

5. **Verify live site:**
   ```bash
   curl https://whatismydelta.com | grep "Question 1 of 8"
   ```

### ❌ DO NOT DO THIS:

1. **Do NOT reference old specs:**
   - ❌ PS101_CANONICAL_SPEC_V2.md
   - ❌ Any docs in `backups/` folders
   - ❌ IMPLEMENTATION_SUMMARY_PS101_V2.md

2. **Do NOT implement:**
   - ❌ "Step 1 of 10" pattern
   - ❌ Nested prompts (step.prompts array)
   - ❌ Experiment components
   - ❌ Obstacle mapping
   - ❌ Action planning
   - ❌ 10 progress dots

3. **Do NOT bypass enforcement:**
   - ❌ `git push --no-verify`
   - ❌ Commenting out Gate 13
   - ❌ Modifying regression detector to pass

---

## DATA STRUCTURES

### ✅ CORRECT (v3):
```javascript
{
  "currentPromptIndex": 0,        // 0-7
  "answers": [                     // Array of 8 strings
    "Answer to question 1",
    "Answer to question 2",
    // ... 8 total
  ],
  "prompts": [                     // Loaded from JSON
    "What problem are you trying to solve...",
    // ... 8 total
  ],
  "startedAt": "2026-02-15T...",
  "completed": false
}
```

**localStorage key:** `ps101_simple_state`

### ❌ WRONG (v2 - deprecated):
```javascript
{
  "currentStep": 1,                // 1-10
  "currentPromptIndex": 0,
  "steps": {
    "1": {
      "prompts": [ /* 6 prompts */ ],
      "answers": [ /* 6 answers */ ]
    },
    // ... 10 steps
  },
  "experiments": [ /* ... */ ]
}
```

**localStorage key:** `ps101_v2_state` (OLD - do not use)

---

## VERIFICATION CHECKLIST

**Before claiming PS101 work is complete:**

```
□ Ran: ./verifiers/verify_no_ps101_regression.sh → EXIT CODE 0
□ Ran: ./.mosaic/enforcement/gate_13_no_ps101_ghosts.sh → EXIT CODE 0
□ Ran: node test-ps101-simple-flow.js → 38/38 PASSED
□ Verified: curl https://whatismydelta.com | grep "Question 1 of 8" → FOUND
□ Verified: curl https://whatismydelta.com | grep "Step 1 of 10" → NOT FOUND
□ Verified: curl https://whatismydelta.com | grep -c "class=\"dot\"" → 8 DOTS
□ Read: docs/PS101_CANONICAL_SPEC_V3_CORRECTED.md → UNDERSTOOD
□ Avoided: All deprecated specs and backups
```

**If ANY check fails:** Do NOT deploy. Fix the issue first.

---

## DANGER ZONES (HIGH RISK OF REGRESSION)

### 1. Reading Old Documentation
**Risk:** Implementing from wrong spec
**Mitigation:** ONLY use v3 spec, ignore all others

### 2. Copy-Paste from Backups
**Risk:** Reintroducing ghost code
**Mitigation:** Never copy from `backups/` or `deprecated/` folders

### 3. "Fixing" Tests to Pass
**Risk:** Masking regression
**Mitigation:** If test fails, fix CODE not TEST

### 4. Bypassing Enforcement
**Risk:** Deploying ghost code
**Mitigation:** Never use `--no-verify`, never disable gates

### 5. Trusting Documentation Over Code
**Risk:** Same 2-month error
**Mitigation:** Live site is source of truth, docs can be wrong

---

## IF YOU ENCOUNTER CONFLICTS

**Scenario:** Documentation says "10 steps" but code has "8 prompts"

**Resolution:**
1. ✅ **Code is correct** (8 prompts)
2. ❌ **Documentation is wrong** (old v2 spec)
3. **Action:** Update/deprecate the wrong documentation
4. **Do NOT:** Change code to match wrong docs

**Scenario:** User reports "Step 1 of 10" on live site

**Resolution:**
1. **CRITICAL BUG** - Old architecture returned
2. **Immediate action:** Run regression detector
3. **Root cause:** Ghost code or wrong deployment
4. **Fix:** Restore from known-good commit
5. **Prevent:** Check why enforcement failed

---

## SUMMARY

**The 8-Prompt Rule:**
- PS101 = 8 prompts
- Question 1-8, not Step 1-10
- Linear flow, no nesting
- Source: `frontend/data/prompts.ps101.json`

**The Three Protections:**
1. **Clean code:** Ghost code removed (2026-02-15)
2. **Enforcement:** Gate 13 blocks old patterns
3. **Documentation:** This file guides correctly

**If Unsure:**
```bash
# Quick sanity check
curl https://whatismydelta.com | grep -o "Question 1 of 8"
# Should output: "Question 1 of 8"

# If not found → CRITICAL REGRESSION
```

---

**LAST UPDATED:** 2026-02-15
**LAST VERIFIED WORKING:** commit 7d7d012 (8-prompt architecture deployed)
**NEXT SESSION:** Read this file FIRST, then proceed

---

**END OF PS101 SESSION START PROTOCOL**
