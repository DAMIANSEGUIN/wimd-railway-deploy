# DEPRECATED: Prose Governance Documents

**Status:** ARCHIVED
**Date:** 2025-12-12
**Reason:** Replaced with ISO-based automated enforcement

---

## Why These Files Are Deprecated

These governance documents were written as **human-readable prose** with instructions like:

- "Agents MUST..."
- "This is MANDATORY..."
- "No exceptions..."

**Problem:** AI agents can ignore prose. These are aspirational statements, not enforceable rules.

---

## What Replaced Them

**New Governance System:**

1. **CODE_GOVERNANCE_STANDARD_v1.md**
   - References ISO/IEC 5055:2021 (automated code quality)
   - References ISO/IEC 25010 (software quality model)
   - Maps to CWE (Common Weakness Enumeration)
   - Defines 3 automated enforcement layers

2. **Automated Enforcement Stack:**
   - `.pre-commit-config.yaml` - Pre-commit hooks (immediate)
   - `.github/workflows/quality.yml` - CI/CD gates (merge)
   - `pyproject.toml` - Tool configuration (ruff, black, pytest)
   - `scripts/verify_compliance.sh` - Full ISO compliance check

3. **Industry-Standard Tools:**
   - Ruff (Python linting - PEP 8 + security)
   - Black (code formatting)
   - Bandit (security scanning - CWE violations)
   - GitLeaks (secret detection)
   - Pytest + Coverage (test enforcement ≥80%)
   - Radon (complexity checking ≤10)

---

## Key Principle Change

**Old Approach (Wrong):**

```markdown
# Mosaic_Governance_Core_v1.md
"Agents MUST NOT use a directory or file path until verified..."
```

**New Approach (Correct):**

```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: check-postgres-patterns
      entry: python -c "import sys; ... sys.exit(1 if violation else 0)"
```

---

## Archived Files

These files have been moved here and are **no longer authoritative**:

- `Mosaic_Governance_Core_v1.md` (prose version)
- `TEAM_PLAYBOOK_v2.md` (prose version)
- `SESSION_START_v2.md` (if existed)
- Any other "MUST/SHOULD" governance prose

---

## For Reference Only

Keep these files for historical context, but **DO NOT use them for governance**.

All governance is now enforced by:

1. Pre-commit hooks (blocks commits that violate rules)
2. CI/CD pipeline (blocks merges that violate rules)
3. ISO standards (defines what quality means)

---

**See:** `/CODE_GOVERNANCE_STANDARD_v1.md` for current governance
