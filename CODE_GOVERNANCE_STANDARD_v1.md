# Code Governance Standard v1.0

**ISO-Based Automated Enforcement Framework**

**Document Metadata:**

- Created: 2025-12-12 by Claude Code
- Based on: ISO/IEC 5055:2021, ISO/IEC 25010, Policy-as-Code industry standards
- Status: ACTIVE
- Enforcement: Automated via pre-commit hooks + CI/CD gates

---

## 1. PURPOSE

This standard defines machine-enforceable code quality and governance rules based on ISO/IEC 5055:2021 and industry-standard Policy-as-Code frameworks. All code written by AI agents MUST pass automated validation before commit.

---

## 2. SCOPE

Applies to:

- All Python code in `/api` directory
- All JavaScript code in `/frontend` and `/mosaic_ui` directories
- All shell scripts in `/scripts` directory
- All configuration files (JSON, YAML)

---

## 3. ISO/IEC 5055 QUALITY CHARACTERISTICS

### 3.1 Security

**Rule:** Code MUST NOT contain CWE (Common Weakness Enumeration) violations

**Automated Checks:**

```yaml
security_checks:
  - cwe_89: SQL Injection prevention
    enforcement: Parameterized queries only (%s placeholders)
    validator: pre-commit hook line 82-87

  - cwe_798: Hardcoded credentials prevention
    enforcement: No API keys in source code
    validator: pre-commit hook + git-secrets

  - cwe_259: Password management
    enforcement: Use password hashing (bcrypt/argon2)
    validator: Code review + static analysis
```

### 3.2 Reliability

**Rule:** Code MUST handle errors explicitly

**Automated Checks:**

```yaml
reliability_checks:
  - error_handling:
    enforcement: No bare except clauses
    validator: pre-commit hook line 92-98

  - context_management:
    enforcement: Use 'with get_conn() as conn:' pattern
    validator: pre-commit hook line 70-77

  - idempotency:
    enforcement: Use ON CONFLICT for database writes
    validator: Code review checklist
```

### 3.3 Performance Efficiency

**Rule:** Code MUST avoid known performance anti-patterns

**Automated Checks:**

```yaml
performance_checks:
  - n_plus_one_queries:
    enforcement: No queries in loops
    validator: Code review + profiling

  - resource_cleanup:
    enforcement: Context managers for file/DB operations
    validator: pre-commit hook line 70-77
```

### 3.4 Maintainability

**Rule:** Code MUST follow style guides

**Automated Checks:**

```yaml
maintainability_checks:
  - python_style:
    standard: PEP 8
    enforcement: Flake8 + Black formatter
    validator: CI/CD pipeline

  - javascript_style:
    standard: Airbnb style guide
    enforcement: ESLint
    validator: CI/CD pipeline

  - naming_conventions:
    enforcement: Descriptive names (no single letters except i,j,k in loops)
    validator: Code review
```

---

## 4. POLICY-AS-CODE ENFORCEMENT LAYERS

### 4.1 Layer 1: Pre-Commit Hooks (Immediate Enforcement)

**File:** `.git/hooks/pre-commit`
**Status:** Active
**Blocks:** Commits that violate rules

**Rules Enforced:**

1. Context manager pattern (line 70-77)
2. PostgreSQL syntax (line 80-87)
3. Error handling (line 92-98)
4. Cursor pattern (line 102-109)
5. Schema patterns (line 112-119)
6. Critical feature removal (line 130-168)
7. Metadata headers (line 59-67)
8. Command validation (line 13-56)

### 4.2 Layer 2: CI/CD Pipeline (Merge Gate)

**Status:** To be implemented
**Blocks:** Merges that violate rules

**Required Checks:**

```yaml
ci_cd_gates:
  - linting:
      python: flake8 --config=.flake8
      javascript: eslint --config=.eslintrc

  - formatting:
      python: black --check .
      javascript: prettier --check .

  - testing:
      unit_tests: pytest tests/ -v
      integration_tests: pytest tests/integration/ -v

  - security:
      dependency_scan: safety check
      secret_scan: git-secrets --scan

  - quality_gates:
      coverage_threshold: 80%
      complexity_threshold: 10 (cyclomatic)
```

### 4.3 Layer 3: Runtime Validation (Production Safety)

**Status:** Partially implemented (health checks)

**Runtime Checks:**

```yaml
runtime_validation:
  - health_endpoints:
      basic: /health
      comprehensive: /health/comprehensive

  - circuit_breakers:
      error_rate_threshold: 5%
      window: 5 minutes

  - database_validation:
      connection_check: on startup
      fallback: SQLite (ephemeral)
```

---

## 5. ENGINEERING PRINCIPLES (Project-Specific)

Based on `ENGINEERING_PRINCIPLES.md`:

### P01: Singular Purpose

**Test:** Every function has ONE verifiable purpose statement
**Enforcement:** Code review checklist

### P02: Declared Context

**Test:** Context block lists ALL dependencies
**Enforcement:** Code review checklist

### P03: Minimal Complexity

**Test:** Cyclomatic complexity ≤ 10
**Enforcement:** CI/CD pipeline (flake8-complexity)

### P04: Explicit Robustness

**Test:** Edge cases block + handling code present
**Enforcement:** Code review checklist

### P05: Syntactic Clarity

**Test:** Descriptive names, no implementation comments
**Enforcement:** Code review checklist

---

## 6. VALIDATION WORKFLOW

### Before Code Generation (AI Agent Protocol)

```yaml
pre_generation_protocol:
  step_1:
    action: Read relevant files
    verify: File paths exist

  step_2:
    action: Generate context block
    verify: All dependencies listed

  step_3:
    action: Generate edge_cases block
    verify: Failure modes identified

  step_4:
    action: Generate code
    verify: Follows patterns from section 7

  step_5:
    action: Self-validate against checklist
    verify: All checks pass before showing user
```

### Before Commit

```bash
# Automated by .git/hooks/pre-commit
./scripts/validate_metadata.sh
flake8 api/
black --check api/
pytest tests/ --quick
```

### Before Deploy

```bash
# Automated by CI/CD pipeline
./scripts/verify_critical_features.sh
pytest tests/ -v --cov --cov-report=html
safety check
```

---

## 7. CANONICAL CODE PATTERNS

### 7.1 Database Operations (PostgreSQL)

**CORRECT:**

```python
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute(
        "SELECT * FROM users WHERE email = %s",
        (email,)
    )
    result = cursor.fetchone()
```

**INCORRECT:**

```python
# ❌ No context manager
conn = get_conn()

# ❌ SQLite syntax
cursor.execute("SELECT * FROM users WHERE email = ?", (email,))

# ❌ Direct conn.execute()
conn.execute("SELECT * FROM users")
```

### 7.2 Error Handling

**CORRECT:**

```python
try:
    result = risky_operation()
except SpecificException as e:
    logger.error(f"Operation failed: {e}", exc_info=True)
    raise
```

**INCORRECT:**

```python
# ❌ Bare except
try:
    risky_operation()
except:
    pass

# ❌ No logging
try:
    risky_operation()
except Exception:
    return None
```

### 7.3 Idempotent Database Writes

**CORRECT:**

```python
cursor.execute("""
    INSERT INTO users (id, email, password_hash)
    VALUES (%s, %s, %s)
    ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash
""", (user_id, email, password_hash))
```

**INCORRECT:**

```python
# ❌ Non-idempotent
cursor.execute(
    "INSERT INTO users VALUES (%s, %s, %s)",
    (user_id, email, password_hash)
)
```

---

## 8. AUTOMATED VALIDATION SCRIPTS

### 8.1 Metadata Validation

**Script:** `scripts/validate_metadata.sh`
**Purpose:** Ensure governance docs have metadata headers
**Called by:** Pre-commit hook

### 8.2 Governance Purge Validation

**Script:** `scripts/validate_governance_purge.sh`
**Purpose:** Verify no "RECOMMENDED" or "user must enforce" language
**Called by:** Manual/CI

### 8.3 Feature Verification

**Script:** `scripts/verify_critical_features.sh`
**Purpose:** Confirm auth, PS101, core features present
**Called by:** Pre-commit hook + deploy script

---

## 9. QUALITY GATES (ISO 25010 Model)

### Functional Suitability

- [ ] All endpoints return expected responses
- [ ] Error cases handled gracefully
- [ ] Feature flags work correctly

### Performance Efficiency

- [ ] p95 latency < 500ms
- [ ] Database queries optimized
- [ ] No N+1 query patterns

### Compatibility

- [ ] PostgreSQL syntax only (no SQLite)
- [ ] Browser support: Chrome 55+, Firefox 52+, Safari 10.1+

### Usability

- [ ] Error messages are actionable
- [ ] API responses include error codes

### Reliability

- [ ] Health checks functional
- [ ] Auto-restart on failure
- [ ] Data persistence guaranteed

### Security

- [ ] No hardcoded credentials
- [ ] Parameterized SQL queries
- [ ] Password hashing (bcrypt)

### Maintainability

- [ ] PEP 8 compliant (Python)
- [ ] ESLint compliant (JavaScript)
- [ ] Code coverage ≥ 80%

### Portability

- [ ] Environment variables for config
- [ ] No absolute paths in code
- [ ] Docker-compatible

---

## 10. COMPLIANCE VERIFICATION

### Self-Check Before Code Delivery

AI agents MUST verify:

```yaml
compliance_checklist:
  security:
    - No SQL injection vulnerabilities (CWE-89)
    - No hardcoded secrets (CWE-798)
    - Password hashing used (CWE-259)

  reliability:
    - All errors logged explicitly
    - Context managers used for resources
    - Idempotent operations

  performance:
    - No N+1 queries
    - Resource cleanup guaranteed

  maintainability:
    - Style guide compliance (PEP 8 / Airbnb)
    - Descriptive naming
    - Complexity ≤ 10
```

### Automated Verification (CI/CD)

```bash
#!/bin/bash
# scripts/verify_compliance.sh

echo "Running ISO 5055 compliance checks..."

# Security
safety check || exit 1
git-secrets --scan || exit 1

# Reliability
pytest tests/ -v || exit 1

# Performance
pytest tests/performance/ --benchmark || exit 1

# Maintainability
flake8 api/ --max-complexity=10 || exit 1
black --check api/ || exit 1

echo "✅ All compliance checks passed"
```

---

## 11. ENFORCEMENT ESCALATION

### Level 1: Warning (Advisory)

- Code review findings
- Style guide violations
- Non-critical complexity

**Action:** Document in PR comments

### Level 2: Block (Mandatory)

- Pre-commit hook failures
- Security vulnerabilities
- Critical feature removal

**Action:** Prevent commit until fixed

### Level 3: Rollback (Critical)

- Production failures
- Data loss risk
- Security breach

**Action:** Automatic rollback + incident response

---

## 12. TOOL CONFIGURATION

### 12.1 Flake8 (.flake8)

```ini
[flake8]
max-line-length = 100
max-complexity = 10
exclude = .git,__pycache__,venv,.venv
ignore = E203,W503
```

### 12.2 Black (pyproject.toml)

```toml
[tool.black]
line-length = 100
target-version = ['py39']
exclude = '''
/(
    \.git
  | \.venv
  | __pycache__
)/
'''
```

### 12.3 Pylint (.pylintrc)

```ini
[MASTER]
jobs=4

[MESSAGES CONTROL]
disable=C0111,R0903

[FORMAT]
max-line-length=100

[DESIGN]
max-args=7
max-locals=15
```

---

## 13. REFERENCES

**ISO Standards:**

- ISO/IEC 5055:2021 - Automated source code quality measures
- ISO/IEC 25010:2011 - Software quality model
- ISO/IEC 27001 - Information security management

**Industry Standards:**

- CWE - Common Weakness Enumeration (<https://cwe.mitre.org/>)
- OWASP Top 10 - Web application security risks
- PEP 8 - Python style guide
- Airbnb JavaScript Style Guide

**Policy-as-Code:**

- Open Policy Agent (OPA) - <https://www.openpolicyagent.org/>
- Pylint - <https://pylint.org/>
- Flake8 - <https://flake8.pycqa.org/>
- ESLint - <https://eslint.org/>

**Project Files:**

- ENGINEERING_PRINCIPLES.md - P01-P05 principles
- TROUBLESHOOTING_CHECKLIST.md - Operational checks
- SELF_DIAGNOSTIC_FRAMEWORK.md - Error taxonomy
- .git/hooks/pre-commit - Active enforcement

---

## 14. VERSION HISTORY

- v1.0 (2025-12-12): Initial standard based on ISO 5055, ISO 25010, Policy-as-Code frameworks

---

**END OF CODE GOVERNANCE STANDARD**
