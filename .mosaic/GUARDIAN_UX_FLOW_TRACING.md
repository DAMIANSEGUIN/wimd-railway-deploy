# Guardian UX Flow Tracing System

**Created:** 2026-02-03
**Purpose:** Automatically trace user experience flows through codebase to find architectural violations

---

## Overview

The Guardian now has the capability to trace entire user journeys through the codebase and validate architectural congruence at every layer:

```
Frontend UI → State Management → Backend API → Database Schema
```

This catches bugs like the PS101 flow issue where:
- **Frontend** defined 10 steps
- **PROMPT_HINTS** only covered step 1 (6 hints)
- **User experience** cycled through "1-6", "1-4", then "1-10" steps inconsistently

---

## How It Works

### Gate 12: UX Flow Congruence Checker

**Location:** `.mosaic/enforcement/gate_12_ux_flow_congruence.py`

**What It Traces:**

1. **Frontend UI Flow Definitions**
   - Finds all instances of user flow definitions (e.g., `PS101_STEPS`)
   - Validates consistency across frontend files (mosaic_ui/, frontend/)
   - Checks step counts, prompt counts, titles match

2. **State Management**
   - Analyzes state objects (e.g., `PS101State`)
   - Validates init() logic against canonical definitions
   - Checks for proper validation and bounds checking

3. **Hint/Guidance Coverage**
   - Validates `PROMPT_HINTS` covers all steps
   - Checks for hardcoded step counts ("of 10" should use `.length`)
   - Ensures hints match prompt structure

4. **Backend API Contracts**
   - Compares frontend fetch() calls to backend route definitions
   - Validates `/auth/*`, `/wimd/*`, `/jobs/*` endpoint congruence
   - Checks for missing or orphaned endpoints

5. **Database Schema** (future)
   - Validates schema matches API contracts
   - Checks for missing tables/columns referenced in code

---

## What It Catches

### Example 1: PS101 Flow Bug (Real Incident)

**Before Gate 12:**
```javascript
const PS101_STEPS = [/* 10 steps */];

const PROMPT_HINTS = {
  1: [/* 6 hints */]
  // Steps 2-10 MISSING
};
```

**Gate 12 Output:**
```
❌ PS101: PROMPT_HINTS missing for steps [2, 3, 4, 5, 6, 7, 8, 9, 10] in mosaic_ui/index.html
```

**Result:** Would have caught the bug BEFORE deployment

---

### Example 2: Frontend/Backend Endpoint Mismatch

**Before Gate 12:**
```javascript
// Frontend
fetch('/api/auth/verify-token');

// Backend - MISSING /auth/verify-token route
```

**Gate 12 Output:**
```
⚠️  Auth: Frontend calls /api/auth/verify-token but backend doesn't define it
```

**Result:** Catches broken auth flows before users experience them

---

### Example 3: Inconsistent Definitions Across Files

**Before Gate 12:**
```javascript
// mosaic_ui/index.html
const PS101_STEPS = [/* 10 steps */];

// frontend/index.html
const PS101_STEPS = [/* 6 steps */]; // OLD VERSION
```

**Gate 12 Output:**
```
❌ PS101: Inconsistent step counts across files: {'mosaic_ui/index.html': 10, 'frontend/index.html': 6}
```

**Result:** Catches deployment of mismatched versions

---

## Integration

### Pre-Commit Hook
Gate 12 runs automatically on every commit:

```bash
# .git/hooks/pre-commit
python3 .mosaic/enforcement/gate_12_ux_flow_congruence.py || exit 1
```

### Manual Execution
```bash
python3 .mosaic/enforcement/gate_12_ux_flow_congruence.py
```

### CI/CD Pipeline (Future)
Add to GitHub Actions:
```yaml
- name: UX Flow Congruence Check
  run: python3 .mosaic/enforcement/gate_12_ux_flow_congruence.py
```

---

## How To Add New Flow Checks

Want Gate 12 to trace a new user flow? Add an analyzer method:

```python
def analyze_job_search_flow(self):
    """Analyze job search flow for congruence"""
    print("📋 Analyzing Job Search Flow...")

    # 1. Extract frontend search UI
    # 2. Extract backend /jobs/* endpoints
    # 3. Validate congruence
    # 4. Report violations
```

Then call it from `analyze_all_flows()`:

```python
def analyze_all_flows(self):
    self.analyze_ps101_flow()
    self.analyze_auth_flow()
    self.analyze_coach_flow()
    self.analyze_job_search_flow()  # NEW
```

---

## Testing the Guardian's Tracing

### Demonstration Script
```bash
./.mosaic/enforcement/gate_12_demo_before_fix.sh
```

Shows what Gate 12 would have caught with the old buggy PS101 code.

### Current Status
```bash
python3 .mosaic/enforcement/gate_12_ux_flow_congruence.py
```

Output:
```
✅ Gate 12 PASSED: All UX flows are architecturally congruent

All checks passed:
  - PS101 flow consistent across frontend files
  - Auth endpoints match frontend/backend
  - Coach endpoints match frontend/backend
```

---

## Why This Matters

**Before Gate 12:**
- User reports: "PS101 shows 1-6 steps, then 1-4, then 1-10"
- Developer manually traces code to find mismatch
- Takes hours to locate the bug
- Might miss other instances of same pattern

**After Gate 12:**
- Commit blocked if architectural violation detected
- Clear error message points to exact issue
- Automated - runs every commit
- Catches bugs BEFORE users experience them

---

## Comparison: Static vs Flow-Based Testing

### Static Testing (Old Gates 1-11)
- ✅ Checks **code patterns** (context managers, SQL syntax)
- ❌ Doesn't trace **user journeys**
- ❌ Can't detect **architectural mismatches** across layers

### Flow-Based Testing (Gate 12)
- ✅ Traces **entire user experience** through codebase
- ✅ Validates **frontend ↔ backend ↔ database** congruence
- ✅ Detects **missing implementations** at any layer
- ✅ Catches **version mismatches** (old code in one file, new in another)

---

## Real Incident: PS101 Bug

**User Report:**
> "PS101 starts as 6 questions, leaves out question 2, then jumps to question 2 of 10. I think there are 2 versions."

**Root Cause:**
- `PS101_STEPS` = 10 steps (canonical)
- `PROMPT_HINTS` = only step 1 defined (6 hints)
- Corrupted localStorage loaded old state
- User confused prompt count within step with step count

**How Gate 12 Would Have Helped:**
1. ❌ Would have blocked commit with incomplete `PROMPT_HINTS`
2. ⚠️  Would have warned about mismatch between definitions
3. ✅ Would have enforced architectural consistency

**Outcome:**
- Bug fixed with validation logic
- Gate 12 now catches this pattern automatically
- Future similar bugs prevented

---

## Future Enhancements

### Planned Additions:
1. **Database Schema Tracing**
   - Validate tables/columns match code references
   - Check for orphaned schemas
   - Verify migration scripts

2. **API Contract Validation**
   - JSON schema validation for API requests/responses
   - Type checking for frontend ↔ backend data flow
   - Version compatibility checks

3. **Performance Flow Analysis**
   - Detect N+1 query patterns
   - Find missing indexes for hot paths
   - Validate caching at each layer

4. **A/B Test Congruence**
   - Validate experiment definitions match across frontend/backend
   - Check feature flags are consistent
   - Ensure variant implementations complete

---

## Summary

Gate 12 gives the Guardian the ability to **"walk through" user experiences in code** and validate that every layer is architecturally congruent.

**Key Benefits:**
- ✅ Catches multi-layer bugs before deployment
- ✅ Enforces architectural consistency automatically
- ✅ Provides clear error messages pointing to exact issues
- ✅ Runs on every commit (preventive, not reactive)
- ✅ Extensible - easy to add new flow checks

**The Guardian can now answer:** "If a user clicks this button, will the entire flow from frontend → backend → database work correctly?"

---

**Related Documentation:**
- `TESTING_GATES_DOCUMENTATION.md` - All Guardian gates explained
- `TROUBLESHOOTING_CHECKLIST.md` - Error patterns Gate 12 complements
- `DEPLOYMENT_TEST_REPORT_2026_02_03.md` - PS101 bug incident report
