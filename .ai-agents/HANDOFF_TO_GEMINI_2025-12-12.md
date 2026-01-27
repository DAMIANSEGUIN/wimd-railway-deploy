# Handoff to Gemini - ISO-Based Governance Implementation

**Session Date:** 2025-12-12
**From:** Claude Code (Sonnet 4.5)
**To:** Gemini
**Status:** Ready for Testing & Validation

---

## WHAT WAS DONE

Replaced **prose governance** ("Agents MUST...") with **ISO-based automated enforcement** (pre-commit hooks, CI/CD gates, industry-standard tools).

**Core Problem Solved:**

- User was writing human-language instructions to tell AI how to code
- Should reference ISO standards + automated tools instead
- Old approach: relies on AI self-discipline (doesn't work)
- New approach: technical enforcement at commit/merge gates (actually works)

---

## QUICK START FOR GEMINI

### Step 1: Read These Files (In Order)

1. **CODE_GOVERNANCE_STANDARD_v1.md**
   - ISO-based standard with automated enforcement layers
   - References ISO/IEC 5055:2021, ISO/IEC 25010, CWE
   - Defines what quality means (machine-readable)

2. **GOVERNANCE_REBUILD_PROMPT.md** (in `.ai-agents/`)
   - Problem statement: why prose governance failed
   - Solution: Policy-as-Code with ISO standards
   - Task list for implementation

3. **.pre-commit-config.yaml**
   - 16 automated pre-commit hooks
   - Blocks commits that violate quality rules
   - Installed and active

4. **pyproject.toml**
   - Tool configurations (ruff, black, pytest, coverage)
   - Quality thresholds (coverage ≥80%, complexity ≤10)

5. **.github/workflows/quality.yml**
   - CI/CD pipeline with 7 quality gates
   - Blocks merges that violate standards

6. **scripts/verify_compliance.sh**
   - Full ISO 5055 compliance check
   - Run before deployment

---

## ENFORCEMENT STACK (3 LAYERS)

### Layer 1: Pre-Commit Hooks ✅ ACTIVE

**Blocks:** Commits that violate rules
**File:** `.pre-commit-config.yaml`

**What It Enforces:**

- ✅ Ruff linting (PEP 8 + security + complexity)
- ✅ Black formatting
- ✅ GitLeaks (secret detection)
- ✅ Bandit (security - CWE violations)
- ✅ MyPy (type checking)
- ✅ PostgreSQL context manager pattern
- ✅ No SQLite syntax in PostgreSQL code
- ✅ Critical feature preservation

**How to Use:**

```bash
# Pre-commit runs automatically on `git commit`
# To run manually on all files:
/Users/damianseguin/Library/Python/3.7/bin/pre-commit run --all-files

# To run on staged files only:
git add .
git commit -m "Your message"
# Pre-commit runs automatically, blocks if violations found
```

### Layer 2: CI/CD Pipeline ✅ READY

**Blocks:** Merges that violate rules
**File:** `.github/workflows/quality.yml`

**7 Quality Gates:**

1. Python quality (ruff, black, mypy, bandit)
2. Tests + coverage (≥80%)
3. Security scans (gitleaks, secrets)
4. Complexity checks (≤10 cyclomatic)
5. Mosaic patterns enforcement
6. Documentation quality
7. Summary gate

**Status:** Will activate when you push to GitHub (already configured)

### Layer 3: Manual Compliance Check ✅ READY

**Use:** Before deployment
**File:** `scripts/verify_compliance.sh`

**How to Run:**

```bash
cd /Users/damianseguin/WIMD-Deploy-Project
./scripts/verify_compliance.sh
```

**What It Checks:**

- Security (Bandit, GitLeaks, Safety)
- Reliability (patterns, error handling)
- Performance (complexity ≤10)
- Maintainability (ruff, black, tests, coverage ≥80%)

---

## YOUR TESTING TASKS

### Task 1: Verify Pre-Commit Hooks Work

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

# Test 1: Check pre-commit is installed
/Users/damianseguin/Library/Python/3.7/bin/pre-commit --version
# Expected: "pre-commit 2.21.0" or similar

# Test 2: Run all hooks manually
/Users/damianseguin/Library/Python/3.7/bin/pre-commit run --all-files
# Expected: Some hooks may fail (that's OK - shows enforcement works)

# Test 3: Check what hooks are active
/Users/damianseguin/Library/Python/3.7/bin/pre-commit run --list
# Expected: List of ~16 hooks
```

### Task 2: Install Missing Tools (If Needed)

```bash
# Install Python quality tools
pip3 install --user ruff black mypy bandit safety pytest pytest-cov radon

# Verify installations
ruff --version
black --version
bandit --version

# Note: Some tools (gitleaks, shellcheck) are optional
# Pre-commit will install them automatically when needed
```

### Task 3: Run Compliance Verification

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

# Run full ISO 5055 compliance check
./scripts/verify_compliance.sh

# Expected output:
# - Section 1: Security checks
# - Section 2: Reliability checks
# - Section 3: Performance checks
# - Section 4: Maintainability checks
# - Section 5: Critical features
# - Summary: PASS or FAIL with details
```

### Task 4: Test Enforcement on Real Code

```bash
# Create a test file with a violation
cat > api/test_violation.py << 'EOF'
# This should fail multiple checks

def bad_function():
    conn = get_conn()  # ❌ Wrong pattern
    cursor = conn.execute("SELECT * FROM users WHERE id = ?", (1,))  # ❌ SQLite syntax
    try:
        risky_operation()
    except:  # ❌ Bare except
        pass  # ❌ No logging
EOF

# Try to commit it
git add api/test_violation.py
git commit -m "Test enforcement"

# Expected: Pre-commit hooks BLOCK the commit with error messages

# Clean up
rm api/test_violation.py
git reset HEAD
```

### Task 5: Verify Correct Patterns Pass

```bash
# Create a test file with correct patterns
cat > api/test_correct.py << 'EOF'
"""Test module with correct patterns."""
import logging

logger = logging.getLogger(__name__)

def good_function():
    """Fetch user with correct pattern."""
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE id = %s", (1,))
        return cursor.fetchone()
EOF

# Try to commit it
git add api/test_correct.py
git commit -m "Test correct patterns"

# Expected: Pre-commit hooks PASS, commit succeeds

# Clean up
git reset --soft HEAD~1
rm api/test_correct.py
```

---

## TESTING CHECKLIST

**Before You Start:**

- [ ] Read CODE_GOVERNANCE_STANDARD_v1.md
- [ ] Read GOVERNANCE_REBUILD_PROMPT.md
- [ ] Understand the 3 enforcement layers

**Pre-Commit Hooks:**

- [ ] Verify pre-commit installed: `/Users/damianseguin/Library/Python/3.7/bin/pre-commit --version`
- [ ] Run all hooks manually: `/Users/damianseguin/Library/Python/3.7/bin/pre-commit run --all-files`
- [ ] List active hooks: `/Users/damianseguin/Library/Python/3.7/bin/pre-commit run --list`
- [ ] Test violation blocking (Task 4)
- [ ] Test correct patterns pass (Task 5)

**Compliance Script:**

- [ ] Run: `./scripts/verify_compliance.sh`
- [ ] Verify all 5 sections execute
- [ ] Check for any missing tools
- [ ] Review pass/fail summary

**Tool Installations:**

- [ ] Install: `pip3 install --user ruff black mypy bandit safety pytest pytest-cov radon`
- [ ] Verify: `ruff --version && black --version && bandit --version`

**CI/CD (Optional - Requires GitHub Push):**

- [ ] Review `.github/workflows/quality.yml`
- [ ] Understand the 7 quality gates
- [ ] (Will activate on next push to GitHub)

---

## EXPECTED RESULTS

### ✅ Success Indicators

**Pre-Commit Hooks:**

- Hooks run automatically on `git commit`
- Violations block commits with clear error messages
- Correct code passes all checks

**Compliance Script:**

- All 5 sections execute without errors
- Final summary shows: "✅ ALL QUALITY GATES PASSED"
- Or shows specific failures with remediation steps

**Tool Ecosystem:**

- Ruff, Black, Bandit installed and working
- Pre-commit framework operational
- No missing critical dependencies

### ⚠️ Known Issues / Acceptable Failures

**Some Pre-Commit Hooks May Skip:**

- GitLeaks: Requires separate installation (optional)
- ShellCheck: Requires separate installation (optional)
- MyPy: May show warnings on untyped code (non-blocking)

**Compliance Script Warnings:**

- "⚠️ Tool not installed" - Install tools with pip3
- Coverage warnings - Expected if tests don't exist yet
- Radon warnings - OK if not installed

**These are informational, not critical.**

---

## TROUBLESHOOTING

### Issue: "pre-commit: command not found"

**Solution:**

```bash
# Use full path
/Users/damianseguin/Library/Python/3.7/bin/pre-commit run --all-files

# Or add to PATH
export PATH="/Users/damianseguin/Library/Python/3.7/bin:$PATH"
```

### Issue: "Hook failed" with Python errors

**Solution:**

```bash
# Install missing Python packages
pip3 install --user ruff black mypy bandit

# Re-run pre-commit
/Users/damianseguin/Library/Python/3.7/bin/pre-commit run --all-files
```

### Issue: "GitLeaks not found"

**Solution:**

```bash
# GitLeaks is optional, skip it or install:
# brew install gitleaks  (macOS)
# Or remove from .pre-commit-config.yaml if not needed
```

### Issue: Compliance script fails on tests

**Solution:**

```bash
# Expected if tests don't exist yet
# Tests requirement: coverage ≥ 80%
# For now, focus on pre-commit hooks working
```

---

## WHAT TO REPORT BACK

### Required Information

1. **Pre-Commit Status:**
   - [ ] Installed? (version number)
   - [ ] Hooks list? (output of `--list`)
   - [ ] Test run result? (pass/fail/warnings)

2. **Compliance Script Status:**
   - [ ] Executable? (`./scripts/verify_compliance.sh` runs)
   - [ ] Output summary? (copy final pass/fail section)
   - [ ] Missing tools? (list any tools not installed)

3. **Test Results:**
   - [ ] Violation blocking works? (Task 4 result)
   - [ ] Correct patterns pass? (Task 5 result)
   - [ ] Any unexpected failures?

4. **Tool Ecosystem:**
   - [ ] Ruff installed? (version)
   - [ ] Black installed? (version)
   - [ ] Bandit installed? (version)
   - [ ] Any installation issues?

### Format Your Report Like This

```markdown
## Gemini Testing Report - 2025-12-12

### Pre-Commit Hooks
- Status: ✅ WORKING / ❌ FAILED / ⚠️ PARTIAL
- Version: pre-commit 2.21.0
- Active hooks: 16 (list output below)
- Test violation blocking: ✅ Worked as expected
- Test correct patterns: ✅ Passed all checks

### Compliance Script
- Status: ✅ WORKING / ❌ FAILED / ⚠️ PARTIAL
- Security checks: ✅ PASS
- Reliability checks: ✅ PASS
- Performance checks: ⚠️ WARNING (radon not installed)
- Maintainability checks: ✅ PASS
- Overall result: ✅ PASSED with warnings

### Tool Installation
- Ruff: ✅ v0.6.8
- Black: ✅ v24.10.0
- Bandit: ✅ v1.7.10
- MyPy: ✅ v1.11.2
- Pytest: ✅ v8.0.0
- Missing tools: GitLeaks (optional)

### Issues Encountered
1. [Issue description]
   - Error message: [paste error]
   - Resolution: [what you did]

2. [Next issue...]

### Recommendations
- [Any suggestions for improvements]
- [Anything unclear in docs]
- [Missing documentation]
```

---

## NEXT STEPS AFTER TESTING

### If Tests Pass ✅

1. **Start Using Enforcement:**
   - All commits now require passing pre-commit checks
   - Run `./scripts/verify_compliance.sh` before deployments
   - CI/CD will activate on next GitHub push

2. **Update Old Governance Docs:**
   - Move prose files to `DEPRECATED_PROSE_GOVERNANCE/`
   - Update references to point to `CODE_GOVERNANCE_STANDARD_v1.md`
   - Remove "MUST/SHOULD" language from active docs

3. **Optional Enhancements:**
   - Add more custom hooks for Mosaic-specific patterns
   - Increase coverage threshold to 90% (when tests exist)
   - Add pre-push hooks for additional safety

### If Tests Fail ❌

1. **Document Failures:**
   - Copy full error messages
   - Note which tools/hooks failed
   - Include your environment details

2. **Report to User:**
   - Include testing report (format above)
   - List blocking issues vs. warnings
   - Suggest next debugging steps

3. **Wait for Guidance:**
   - Don't modify enforcement configs without approval
   - User may need to adjust thresholds
   - Claude Code may need to fix issues

---

## FILES REFERENCE

**Key Files Created:**

```
/Users/damianseguin/WIMD-Deploy-Project/
├── .pre-commit-config.yaml          # Pre-commit hooks config
├── pyproject.toml                   # Tool configurations
├── CODE_GOVERNANCE_STANDARD_v1.md   # ISO-based standard
├── .github/workflows/quality.yml    # CI/CD quality gates
├── scripts/verify_compliance.sh     # ISO 5055 compliance check
├── .ai-agents/
│   ├── GOVERNANCE_REBUILD_PROMPT.md # Issue statement
│   └── HANDOFF_TO_GEMINI_2025-12-12.md  # This file
└── DEPRECATED_PROSE_GOVERNANCE/
    └── README.md                    # Why prose governance deprecated
```

**Old Pre-Commit Hook:**

```
.git/hooks/pre-commit.legacy         # Backed up automatically
```

---

## QUESTIONS TO ASK USER

If anything is unclear or broken:

1. **Tool Installation Issues:**
   - "Should I install GitLeaks/ShellCheck or skip those hooks?"
   - "Is it OK to use pip3 --user for installations?"

2. **Threshold Adjustments:**
   - "Coverage requirement is 80%, but no tests exist - should I lower it temporarily?"
   - "Complexity threshold is 10 - is that too strict for existing code?"

3. **Enforcement Scope:**
   - "Should enforcement apply to scripts/ directory too?"
   - "Are there any files we should exclude from checks?"

4. **CI/CD:**
   - "Do you want CI/CD to run on every push or only PRs?"
   - "Should failed quality gates block deployment completely?"

---

## FINAL NOTES FOR GEMINI

**Key Principles:**

1. **Enforcement is now technical, not aspirational** - Pre-commit hooks block bad code, not markdown documents
2. **Reference ISO standards, not prose** - CODE_GOVERNANCE_STANDARD_v1.md points to ISO 5055, CWE, PEP 8
3. **Tools do the work** - Ruff, Black, Bandit enforce standards automatically
4. **User shouldn't write governance prose** - Point to industry standards instead

**Testing Philosophy:**

- Don't just check if tools run - **verify they actually block bad code**
- Test both violation cases (should fail) and correct cases (should pass)
- Report warnings separately from failures
- Suggest improvements based on what you discover

**Remember:**

- This is a pivot from "hope AI follows rules" to "enforce rules automatically"
- Some rough edges are expected - report them
- User wants technical enforcement, not more documentation

---

**Good luck with testing! Report back with findings.**

**- Claude Code**
