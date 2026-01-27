# Governance Rebuild Prompt

**Issue Statement for AI Agent Session**

---

## THE PROBLEM

Current governance documentation is written in **human language telling AI to follow rules**, when it should be **machine-readable standards enforced automatically**.

**Root Cause:**
A non-technical user is writing prose instructions ("agents MUST...") to tell AI agents how to write code, instead of referencing established ISO standards and industry-standard automated enforcement frameworks.

**This is backwards.**

---

## WHAT WE HAVE NOW (WRONG APPROACH)

```markdown
# Current: Mosaic_Governance_Core_v1.md
"Agents MUST NOT use a directory or file path until it has been explicitly verified..."
"Agents MUST compare proposed edits against the current live version..."
"Whenever an agent is uncertain, it MUST stop and ask..."
```

**Problem:** These are aspirational statements, not enforceable rules. AI agents can ignore them.

---

## WHAT WE NEED (CORRECT APPROACH)

Reference **canonical industry standards** that already define code quality:

1. **ISO/IEC 5055:2021** - Automated source code quality measures
   - Security (CWE violations)
   - Reliability (error handling)
   - Performance (anti-patterns)
   - Maintainability (style guides)

2. **Policy-as-Code (PaC)** - Industry standard for governance enforcement
   - Open Policy Agent (OPA)
   - Declarative rules in Rego/YAML
   - Automated validation at commit/merge

3. **Standard Linters** - Established tooling
   - Python: Pylint, Flake8, Black
   - JavaScript: ESLint, Prettier
   - Pre-commit hooks + CI/CD gates

---

## THE FIX

**Replace prose governance with:**

1. **CODE_GOVERNANCE_STANDARD_v1.md** ✅ Created
   - References ISO 5055, ISO 25010
   - Maps to CWE (Common Weakness Enumeration)
   - Defines automated validation layers
   - Lists canonical code patterns

2. **Automated Enforcement Stack:**
   - Layer 1: Pre-commit hooks (active)
   - Layer 2: CI/CD pipeline (to implement)
   - Layer 3: Runtime validation (partial)

3. **Tool Configuration Files:**
   - `.flake8` - Python linting rules
   - `pyproject.toml` - Black formatter config
   - `.eslintrc` - JavaScript linting rules
   - `.pylintrc` - Advanced Python checks

---

## SPECIFIC TASKS FOR NEXT SESSION

### Task 1: Implement CI/CD Quality Gates

```yaml
# .github/workflows/quality.yml or similar
required_checks:
  - flake8 (PEP 8 compliance)
  - black (code formatting)
  - pylint (static analysis)
  - safety (dependency security)
  - pytest (unit tests, coverage ≥ 80%)
```

### Task 2: Add Linter Configuration Files

- Create `.flake8` with max-complexity=10
- Create `pyproject.toml` for Black
- Create `.pylintrc` for Pylint
- Create `.eslintrc` for JavaScript

### Task 3: Rewrite Governance to Reference Standards

Update governance docs to say:

- "Code MUST comply with ISO/IEC 5055:2021 Section X"
- "Validation enforced by: [specific tool/script]"
- "See CODE_GOVERNANCE_STANDARD_v1.md Section Y"

Instead of:

- "Agents MUST..."
- "This is MANDATORY..."
- "No exceptions..."

### Task 4: Create Compliance Verification Script

```bash
#!/bin/bash
# scripts/verify_compliance.sh
# Runs full ISO 5055 compliance check

flake8 api/ --max-complexity=10
black --check api/
pylint api/
safety check
pytest tests/ --cov --cov-fail-under=80
```

---

## KEY PRINCIPLE

**Stop writing human instructions for AI agents.**

**Start referencing machine-enforceable industry standards.**

User should not be telling AI how to code - ISO, CWE, PEP 8, and industry linters already define that.

User should only be:

1. Pointing to the canonical standards (ISO 5055, Policy-as-Code)
2. Configuring automated tools (Flake8, Pylint, ESLint)
3. Enforcing at commit/merge gates (pre-commit hooks, CI/CD)

---

## FILES CREATED

- ✅ `CODE_GOVERNANCE_STANDARD_v1.md` - ISO-based standard with automated enforcement layers
- ✅ Updated `Mosaic_Governance_Core_v1.md` - Removed API mode from mandatory flow
- ✅ Updated `TEAM_PLAYBOOK_v2.md` - Removed API mode from mandatory flow
- ✅ Updated `scripts/start_session.sh` - Simplified, removed mode detection

---

## FILES TO CREATE NEXT

- [ ] `.flake8` - Python linting configuration
- [ ] `pyproject.toml` - Black formatter + tool config
- [ ] `.pylintrc` - Advanced Python static analysis
- [ ] `.eslintrc.json` - JavaScript linting rules
- [ ] `scripts/verify_compliance.sh` - Full compliance check script
- [ ] `.github/workflows/quality.yml` - CI/CD quality gates

---

## REFERENCE DOCUMENTATION

**Created This Session:**

- `/Users/damianseguin/WIMD-Deploy-Project/CODE_GOVERNANCE_STANDARD_v1.md`

**Existing Standards:**

- ISO/IEC 5055:2021 - <https://www.it-cisq.org/standards/code-quality-standards/>
- ISO/IEC 25010 - <https://iso25000.com/en/iso-25000-standards/iso-25010>
- CWE (Common Weakness Enumeration) - <https://cwe.mitre.org/>
- PEP 8 - <https://peps.python.org/pep-0008/>
- Airbnb JavaScript Style Guide - <https://github.com/airbnb/javascript>

**Enforcement Tools:**

- Flake8 - <https://flake8.pycqa.org/>
- Black - <https://black.readthedocs.io/>
- Pylint - <https://pylint.org/>
- ESLint - <https://eslint.org/>
- Open Policy Agent - <https://www.openpolicyagent.org/>

---

**PROMPT FOR NEXT SESSION:**

```
Read: /Users/damianseguin/WIMD-Deploy-Project/.ai-agents/GOVERNANCE_REBUILD_PROMPT.md

Context: We're replacing human-written governance prose with machine-enforceable ISO standards.

Your task:
1. Implement CI/CD quality gates (flake8, black, pylint, safety, pytest)
2. Create linter configuration files (.flake8, pyproject.toml, .pylintrc, .eslintrc)
3. Create scripts/verify_compliance.sh - full ISO 5055 compliance check
4. Update governance docs to reference CODE_GOVERNANCE_STANDARD_v1.md instead of prose rules

Reference: CODE_GOVERNANCE_STANDARD_v1.md (already created - read this first)

Goal: Automated enforcement at commit/merge, not relying on AI self-discipline.
```

---

**END OF GOVERNANCE REBUILD PROMPT**
