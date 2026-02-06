# Testing Oversight System - "The Watcher"

**Created:** 2026-02-06
**Purpose:** Ensure continuous test execution with automated oversight
**Status:** ACTIVE

---

## Problem: Tests Without a Watcher

**What went wrong:**
- Tests existed (`test-ps101-complete-flow.js`) but nobody ran them
- Deployment script only did trivial string matching (`grep "PS101State"`)
- PS101 navigation bug reached production despite test coverage
- **Root cause:** No automated oversight ensuring tests actually RUN

**The old way:**
```
Developer → Writes Code → Manually runs tests (maybe) → Deploys
              ↓
         Tests gather dust in repo
```

---

## Solution: Multi-Layer Oversight

### Layer 1: Pre-Push Verification (Local)

**File:** `scripts/pre_push_verification.sh`

**Runs:** Before every `git push` via git hook

**What it does:**
```bash
#!/bin/bash
# AUTOMATICALLY RUNS when you try to push code

./scripts/test_all.sh  # Runs ALL 19 test suites
# If ANY test fails → Push BLOCKED
```

**Setup:**
```bash
# One-time setup (copy to git hooks)
cp scripts/pre_push_verification.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

**Benefits:**
- ✅ Catches bugs BEFORE they reach GitHub
- ✅ Fast feedback (runs on your machine)
- ✅ Can't forget to run tests (automatic)

---

### Layer 2: GitHub Actions CI (The Watcher)

**File:** `.github/workflows/comprehensive-testing.yml`

**Runs:** Automatically on EVERY commit to `main` or `develop`

**What it does:**
1. Sets up clean Ubuntu VM
2. Installs Python + Node.js + Playwright
3. Runs `./scripts/test_all.sh`
4. Uploads logs/screenshots if tests fail
5. **BLOCKS MERGE** if tests fail

**How to check status:**
```
1. Push code to GitHub
2. Go to: https://github.com/DAMIANSEGUIN/wimd-render-deploy/actions
3. See green checkmark ✅ or red X ❌
4. If red: Click to see which test failed
```

**Benefits:**
- ✅ Independent verification (not on your machine)
- ✅ Can't bypass (GitHub enforces it)
- ✅ Screenshots/videos of Playwright failures
- ✅ Test logs saved for 30 days

---

### Layer 3: Master Test Runner (Comprehensive)

**File:** `scripts/test_all.sh`

**Runs:** By local hook + GitHub Actions

**What it tests:**

#### Backend Tests (9 suites)
```
✅ Startup checks & health monitoring
✅ Prompt selector & AI fallback
✅ RAG engine & semantic search
✅ Job sources (12 external APIs)
✅ PS101 persona system
✅ Claude/OpenAI integration
✅ Cost controls & usage tracking
✅ Trigger detection system
✅ Semantic matching
```

#### Frontend Tests (7 suites via Playwright)
```
✅ PS101 complete flow (Steps 1-10)
✅ PS101 step 6 validation
✅ PS101 navigation system
✅ PS101 UI components
✅ UI flow integration
✅ UI interactions & event handling
✅ Deployment verification
```

#### Integration Tests (1 suite)
```
✅ Frontend smoke test (critical features)
```

#### Enforcement Tests (2 suites)
```
✅ Session init validation
✅ Gates validation
```

**Total: 19 test suites covering all modules**

---

## Addressing Brittleness Concerns

### Question: "Is a code-wide test prone to failing?"

**Answer:** Yes, BUT that's the point! Here's why it's OK:

### 1. Fail Fast, Fail Loudly

**Old way:**
```
Silent failure → Bug reaches production → User reports it
```

**New way:**
```
Test fails → Build blocked → Fix before deploy → User never sees bug
```

### 2. Test Suite Is Resilient

The test runner handles failures gracefully:

```bash
# Each test suite runs independently
run_test_suite "Backend: Startup Checks" "pytest test_startup.py"
run_test_suite "Frontend: PS101 Flow" "playwright test ps101.js"
# If test 1 fails, test 2 still runs

# Summary at end shows which failed:
# ✅ Passed: 17
# ❌ Failed: 2
# ⚠️  Skipped: 0
```

### 3. Skipping Unavailable Tests

```bash
# If Python not installed → Skip backend tests (with warning)
if ! command -v python3 &> /dev/null; then
  echo "⚠️  Python3 not found - skipping backend tests"
  SKIPPED_TESTS=$((SKIPPED_TESTS + 9))
fi

# If Playwright not installed → Auto-install it
if ! npx playwright --version &> /dev/null; then
  echo "Installing Playwright..."
  npm install -D @playwright/test
fi
```

### 4. Comprehensive Logging

Every test run creates a detailed log:

```bash
# Log file location
/tmp/test_all_20260206_143022.log

# Contains:
# - Full test output
# - Timestamps
# - Error messages
# - Test command that was run
# - Environment info (Python/Node versions)
```

**GitHub Actions also saves:**
- Test logs (30 day retention)
- Playwright screenshots (if tests fail)
- Playwright videos (if tests fail)

### 5. Quick Feedback Loop

**Fast smoke test (30 seconds):**
```bash
./scripts/test_frontend_smoke.sh
# Just checks critical features exist
# Not as thorough, but super fast
```

**Full test suite (5-10 minutes):**
```bash
./scripts/test_all.sh
# Runs everything
# Thorough but slower
```

**GitHub Actions runs BOTH:**
- Smoke test runs in parallel (fast feedback)
- Full suite also runs (comprehensive)

---

## Expected Failure Scenarios (NOT BUGS)

### Scenario 1: API Keys Missing (CI Environment)

**What happens:**
```
❌ Backend: Claude Integration - FAILED
   Error: ANTHROPIC_API_KEY not set
```

**Solution:**
```bash
# Add to GitHub repository secrets:
Settings → Secrets → Actions → New repository secret
Name: ANTHROPIC_API_KEY
Value: sk-ant-xxx
```

### Scenario 2: External API Down (Transient)

**What happens:**
```
❌ Backend: Job Sources - FAILED
   Error: LinkedIn API timeout
```

**Solution:**
```bash
# Re-run the workflow (may be temporary)
# Or: Update test to use mock data for LinkedIn
```

### Scenario 3: New Feature Breaking Old Test

**What happens:**
```
❌ Frontend: PS101 Step 6 - FAILED
   Error: Button text changed from "Next" to "Continue"
```

**Solution:**
```bash
# Update test to match new button text:
# Old: await page.click('text=Next')
# New: await page.click('text=Continue')
```

**This is GOOD - test caught the change!**

---

## How to Use This System

### For Developers

**Before writing code:**
```bash
# 1. Pull latest tests
git pull origin main

# 2. Run tests to verify starting point
./scripts/test_all.sh

# 3. Write your code

# 4. Run tests again
./scripts/test_all.sh

# 5. If all pass, push
git push origin main
# (Pre-push hook automatically runs tests again)
```

**If tests fail locally:**
```bash
# 1. Check which test failed (output shows it)
# 2. Run just that test for faster iteration:
npx playwright test test-ps101-complete-flow.js --headed
# (--headed shows browser so you can see what's wrong)

# 3. Fix the issue
# 4. Re-run test
# 5. When green, push
```

**If tests pass locally but fail in CI:**
```bash
# 1. Download test artifacts from GitHub Actions
# 2. Check screenshots/videos for visual clues
# 3. Likely an environment difference:
#    - Missing API key
#    - Different Node/Python version
#    - Network issue
```

### For Reviewers

**When reviewing a PR:**
```
1. Check that "All Tests Passed" checkmark is green ✅
2. If red ❌ → DO NOT MERGE
3. Ask author to fix failing tests first
4. Only merge when ALL checks pass
```

### For Deployment

**Automated deployments only happen if tests pass:**
```
Git Push → Tests Run → ✅ Pass → Deploy to Production
                   ↓ ❌ Fail → BLOCK deployment
```

---

## Maintenance

### Adding a New Test

```bash
# 1. Create test file
# tests/test_new_feature.py (backend)
# test-new-feature.js (frontend)

# 2. Add to master test runner
# Edit scripts/test_all.sh:
run_test_suite \
  "Backend: New Feature" \
  "python3 -m pytest tests/test_new_feature.py -v" \
  "tests/test_new_feature.py"

# 3. Test it
./scripts/test_all.sh

# 4. Push - CI will automatically run it
```

### Disabling a Flaky Test (LAST RESORT)

```bash
# If a test is flaky (intermittent failures), fix it first
# If you MUST disable temporarily:

# Option 1: Skip in pytest
@pytest.mark.skip(reason="Flaky - investigating")
def test_flaky_feature():
    pass

# Option 2: Comment out in test runner
# run_test_suite \
#   "Backend: Flaky Test" \
#   "pytest test_flaky.py" \
#   "test_flaky.py"

# IMPORTANT: Create GitHub issue to fix it!
```

---

## Summary: The 3-Layer Defense

```
┌─────────────────────────────────────────────────────┐
│  Layer 1: Pre-Push Hook (Local)                    │
│  ✅ Runs before you push                            │
│  ✅ Fast feedback                                   │
│  ✅ Prevents bad commits                            │
└─────────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│  Layer 2: GitHub Actions CI (The Watcher)          │
│  ✅ Runs on every commit                            │
│  ✅ Independent verification                        │
│  ✅ Blocks merge if tests fail                      │
└─────────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│  Layer 3: Master Test Runner (Comprehensive)       │
│  ✅ Tests all 19 suites                             │
│  ✅ Backend + Frontend + Integration                │
│  ✅ Detailed logging                                │
└─────────────────────────────────────────────────────┘
```

**Result:** No code reaches production without passing ALL tests.

---

## FAQ

**Q: What if I need to deploy urgently and tests are failing?**

A: There's an emergency bypass, but it's logged:
```bash
SKIP_VERIFICATION=true ./scripts/deploy.sh all
# This is logged to .verification_audit.log
# Use sparingly - fix tests ASAP
```

**Q: How do I know if tests are running in CI?**

A: Check the GitHub Actions tab:
https://github.com/DAMIANSEGUIN/wimd-render-deploy/actions

**Q: Can I run just frontend or just backend tests?**

A: Yes:
```bash
# Just backend
python3 -m pytest tests/ -v

# Just frontend
npx playwright test test-ps101-*.js

# Just smoke test
./scripts/test_frontend_smoke.sh

# Everything
./scripts/test_all.sh
```

**Q: Tests are slow. Can I speed them up?**

A: Yes:
```bash
# Run tests in parallel (Playwright)
npx playwright test --workers=4

# Run only changed tests (pytest)
pytest --lf  # Last failed

# Use smoke test for quick checks
./scripts/test_frontend_smoke.sh  # 30 seconds
```

---

**Next:** Enable GitHub branch protection to require tests before merge:
```
Settings → Branches → main → Require status checks to pass
→ Select: "All Tests Passed (Required Check)"
```
