# Testing & Validation Gates Documentation

**Project:** WIMD-Deploy-Project
**Last Updated:** 2026-02-03
**Gate Count:** 11 (10 code quality + 1 UI validation)

---

## Overview

The project uses an 11-gate enforcement system to ensure code quality, production health, and user experience before deployment.

**Gate Categories:**
- **Gates 1-8:** Pre-commit checks (code quality, syntax, patterns)
- **Gate 9:** Pre-push production health check (blocking)
- **Gate 10:** Pre-commit codebase health audit
- **Gate 11:** Pre-push UI validation (non-blocking)

---

## Gate 11: UI Validation & Interactive Testing

**Purpose:** Validates that users can actually interact with the UI, not just that code exists.

**Location:** `.mosaic/enforcement/gate_11_ui_validation.sh`

**When It Runs:**
- Automatically on `git push origin main` (after Gate 9)
- Manually: `./.mosaic/enforcement/gate_11_ui_validation.sh`
- Non-blocking: Warnings don't prevent deployment

### What Gate 11 Tests

#### Test 1: Production Deployment Validation
- Runs: `test-deployment.js`
- Checks: 21 automated tests
- Pass Threshold: ≥90%
- Validates:
  - Page loads without errors
  - No critical JavaScript errors
  - PS101 implementation present
  - Authentication UI present
  - Backend API configured
  - Performance acceptable (<5s load)

#### Test 2: Interactive UI Elements
- Runs: `test-ui-interactions.js`
- Checks: User interaction capabilities
- Pass Threshold: ≥70%
- Validates:
  - Buttons are clickable
  - Inputs accept text
  - Forms respond to submission
  - Navigation works
  - Keyboard navigation functional

#### Test 3: User Flow Validation
- Runs: `test-ui-flow.js`
- Checks: End-to-end user journey
- Validates:
  - Landing page loads
  - "Start" button reveals PS101
  - Text inputs become visible
  - Users can type responses
  - Submit buttons work

#### Test 4: Critical UI Elements
- Checks: Essential features present
- Validates:
  - PS101 10-step framework
  - Authentication system
  - Chat/coach interface

#### Test 5: JavaScript Error Check
- Checks: No blocking JavaScript errors
- Validates:
  - No syntax errors
  - No "Unexpected token" errors
  - No FATAL errors

### Gate 11 Results Interpretation

**PASS (5-6 tests passed):**
```
✅ Gate 11 PASSED: UI validation successful
```
- All tests passed
- UI is fully functional
- Users can complete workflows

**WARN (3-4 tests passed):**
```
⚠️  Gate 11 completed with warnings (non-blocking)
```
- Some tests failed (usually visibility-related)
- Core functionality works
- Deployment proceeds with warnings

**FAIL (<3 tests passed):**
```
❌ Gate 11 FAILED: UI validation issues detected
```
- Major UI issues detected
- Still non-blocking (warns only)
- Review logs before deployment

---

## Test Scripts

### `test-deployment.js`

**Purpose:** Comprehensive production validation

**What It Tests:**
1. Page load & accessibility
2. Critical UI elements present
3. PS101 framework implementation
4. Authentication system
5. Interactive elements (buttons/inputs)
6. Backend API integration
7. Content verification
8. Visual capture (screenshots)
9. Console log analysis
10. Performance metrics

**Pass Criteria:** 90% of 21 tests passing

**Run Manually:**
```bash
node test-deployment.js
```

**Output:**
- Console summary
- Screenshots: `/tmp/deployment-test-*.png`
- Exit code: 0 (pass), 1 (fail)

---

### `test-ui-interactions.js`

**Purpose:** Validate user interactions

**What It Tests:**
1. Navigation & links clickable
2. Chat input accepts text
3. PS101 step navigation
4. Authentication forms functional
5. Button click responses
6. Form validation
7. Responsive element visibility
8. Scroll behavior
9. Dynamic content updates
10. Error states
11. Keyboard navigation
12. Multi-step workflows

**Pass Criteria:** 70% of 18 tests passing

**Run Manually:**
```bash
node test-ui-interactions.js
```

**Output:**
- Console summary with step-by-step results
- Screenshots: `/tmp/ui-test-*.png`
- Exit code: 0 (pass), 1 (fail)

---

### `test-ui-flow.js`

**Purpose:** Simulate actual user journey

**What It Tests:**
1. Landing page visibility
2. CTA button functionality
3. PS101 workflow reveal
4. Text input interaction
5. Form submission
6. Multi-step progression

**User Journey:**
```
1. User lands on homepage
   → Sees 10 buttons, 5 inputs

2. User clicks "Start"
   → PS101 workflow appears
   → 20 inputs become visible

3. User types response
   → Input accepts text

4. User clicks "Submit"
   → Form processes submission
   → Next step appears
```

**Run Manually:**
```bash
node test-ui-flow.js
```

**Output:**
- Step-by-step journey log
- Screenshots: `/tmp/flow-*.png`
- Console shows what users see at each step

---

## Difference: Code Exists vs UI Works

### ❌ **BAD Testing** (What We Fixed)

**Before (Static Analysis Only):**
```bash
# Just checks if text exists
grep -o "PS101" index.html
# Result: "PS101 found" ✅

# Problem: Doesn't tell you if users can USE it!
```

**Issues:**
- Code might exist but be invisible (CSS: display:none)
- Buttons might exist but be disabled
- Forms might exist but not accept input
- No verification that users can complete workflows

### ✅ **GOOD Testing** (What We Do Now)

**After (Interactive Testing with Playwright):**
```javascript
// Actually opens browser and simulates user
const button = await page.$('button:has-text("Start")');
await button.click(); // REAL click
await page.type('input', 'My career goal'); // REAL typing
await page.click('button[type="submit"]'); // REAL submission
```

**Verifies:**
- ✅ Elements are VISIBLE to users
- ✅ Elements are ENABLED (not disabled)
- ✅ Buttons respond to CLICKS
- ✅ Inputs accept TEXT
- ✅ Forms process SUBMISSION
- ✅ Workflows progress STEP-BY-STEP

---

## Running Tests Manually

### Quick Deployment Check
```bash
node test-deployment.js
```

### Interactive UI Check
```bash
node test-ui-interactions.js
```

### Full User Journey
```bash
node test-ui-flow.js
```

### Run Gate 11 Manually
```bash
./.mosaic/enforcement/gate_11_ui_validation.sh
```

### Run All Gates (Pre-Push Simulation)
```bash
# Run all pre-commit gates
git add .
git commit -m "test"

# Run all pre-push gates
./scripts/push.sh origin main
```

---

## Playwright Setup

**Installation:**
```bash
npm install --no-save playwright
npx playwright install chromium
```

**Why Playwright:**
- Real browser testing (not mocked)
- Simulates actual user interactions
- Captures screenshots for verification
- Detects console errors users would see

**Browser:** Chromium headless (145.0+)

---

## Test Output Locations

**Logs:**
- `/tmp/gate11-deployment.log` - Deployment test results
- `/tmp/gate11-interactions.log` - Interactive test results
- `/tmp/gate11-flow.log` - User flow test results

**Screenshots:**
- `/tmp/deployment-test-*.png` - Deployment validation
- `/tmp/ui-test-*.png` - Interactive element tests
- `/tmp/flow-*.png` - User journey screenshots
- `/tmp/ps101-ui-test.png` - PS101 specific tests

---

## Common Issues & Solutions

### Issue: "User flow test failed or timed out"

**Cause:** Flow test runs slowly (500ms slowMo)

**Solution:** This is expected, gate is non-blocking

**Manual Check:**
```bash
node test-ui-flow.js
# Review /tmp/flow-*.png screenshots
```

### Issue: "Interactive tests below 70%"

**Cause:** Some UI elements hidden until user authentication

**Solution:**
- Check `/tmp/ui-test-*.png` screenshots
- Verify elements appear after login
- This is expected behavior (non-blocking)

### Issue: "PS101 implementation missing"

**Cause:** Code was removed or renamed

**Solution:**
```bash
grep -r "PS101_STEPS" mosaic_ui/ frontend/
# If not found, PS101 code was deleted
```

---

## Gate Integration Timeline

**Pre-Commit (Gates 1-8, 10):**
- Runs automatically on `git commit`
- Blocking: Must pass to commit
- Fast: <5 seconds

**Pre-Push (Gates 9, 11):**
- Runs automatically on `git push origin main`
- Gate 9: Blocking (production health)
- Gate 11: Non-blocking (UI validation)
- Slower: 30-90 seconds

---

## Why UI Testing Matters

**Real Incident (Feb 3, 2026):**

**Problem:**
```javascript
// Syntax error on line 3421
})();

  function scrollToSection(id) { // ← Orphaned function
    // ...
  }
```

**Impact:**
- Page loaded (HTML/CSS fine)
- JavaScript crashed silently
- Users saw broken UI
- Static tests missed it (grep found "scrollToSection")

**Solution:**
- Playwright test ran actual browser
- Detected: `Uncaught SyntaxError: Unexpected token ')'`
- Fixed before users affected

**Lesson:** Code existing ≠ code working

---

## Best Practices

### For Developers

1. **Run tests locally before pushing:**
   ```bash
   node test-deployment.js && node test-ui-interactions.js
   ```

2. **Check screenshots when tests fail:**
   ```bash
   open /tmp/ui-test-*.png
   ```

3. **Don't bypass gates without reason:**
   ```bash
   # Emergency only
   git push --no-verify origin main
   ```

### For AI Agents

1. **Always use Playwright for UI verification**
   - Don't just grep for text
   - Actually test interactions

2. **Check Gate 11 logs when deployment issues occur:**
   ```bash
   cat /tmp/gate11-*.log
   ```

3. **Include UI testing in session protocol**
   - Control Surface v2.2 includes testing section
   - Remind agents to use browser tests

---

## Maintenance

**Adding New Tests:**

1. Create test script:
   ```javascript
   // test-new-feature.js
   const { chromium } = require('playwright');
   // ... test implementation
   ```

2. Add to Gate 11:
   ```bash
   # Edit .mosaic/enforcement/gate_11_ui_validation.sh
   # Add new test section
   ```

3. Update this documentation

**Updating Thresholds:**

Edit `.mosaic/enforcement/gate_11_ui_validation.sh`:
```bash
# Line ~30: Deployment test threshold
if (( $(echo "$PASS_RATE >= 90" | bc -l) )); then

# Line ~45: Interactive test threshold
if (( $(echo "$PASS_RATE >= 70" | bc -l) )); then
```

---

## Summary

**Gate 11 ensures:**
- ✅ UI loads without errors
- ✅ Users can interact with elements
- ✅ Forms accept input
- ✅ Workflows complete successfully
- ✅ No critical JavaScript errors
- ✅ Performance is acceptable

**Non-blocking by design:**
- Warns about issues
- Doesn't prevent deployment
- Gives developers visibility

**Trust but verify:**
- Automated testing catches issues
- Screenshots provide evidence
- Logs enable debugging

**The goal:** No user ever sees a broken UI that passes our gates.

---

**Questions? See:**
- Control Surface v2.2: `SESSION_START_CONTROL_SURFACE_v2.2.md`
- Session Start Guide: `SESSION_START_README.md`
- Deployment Report: `DEPLOYMENT_TEST_REPORT_2026_02_03.md`
