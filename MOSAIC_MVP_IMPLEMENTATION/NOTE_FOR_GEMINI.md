# Note for Gemini - New Canonical Protocol Document

**Date**: 2025-12-02
**From**: Claude Code
**To**: Gemini

---

## Critical Update: Single Source of Truth Created

**A new canonical protocol document has been created:**

**File**: `TEAM_PLAYBOOK.md`
**Location**: `/Users/damianseguin/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My Drive/WIMD-Render-Deploy-Project/TEAM_PLAYBOOK.md`
**Status**: 🔒 **SINGLE SOURCE OF TRUTH** - Supersedes all previous protocol documents

---

## Why This Was Created

**Problem Identified**:

- 42+ protocol documents scattered across directories
- Contradictions between CODEX_INSTRUCTIONS.md, OPERATIONS_MANUAL.md, START_HERE.md
- Outdated information (SQLite references when we use PostgreSQL)
- No integration of MVP sprint protocols with existing procedures
- Risk of AI team members following wrong/outdated guidance

**Solution**:

- Consolidated ALL protocols into one canonical document
- Integrated MVP-specific guidance (version tracking, inline docs, rollback procedures)
- Clear role definitions for all 5 team members
- Session start checklist to prevent memory drift
- Protocol index (when to read what sections)

---

## What's in TEAM_PLAYBOOK.md

### Structure (14 Sections)

1. **Quick Start** - 5-minute mandatory session initialization
2. **Current Sprint Status** - Always up-to-date with what's being built
3. **Team Roles** - Your role, responsibilities, escalation triggers
4. **Protocol Index** - When to read detailed sections
5. **Implementation Protocols** - Sacred patterns (context manager, PostgreSQL, error logging, idempotency, Pydantic)
6. **Database Patterns** - Schema v2, migrations, PS101 persistence
7. **Version Tracking Protocol** - File headers, inline markers, api/index.py updates
8. **Deployment Checklist** - Pre/post validation, mandatory items
9. **Rollback Procedures** - 3-step restoration process
10. **Troubleshooting Guide** - Quick triage, common issues
11. **Escalation Protocols** - When to escalate, format, follow-up
12. **Change Log** - What this doc supersedes
13. **Related Documents** - What to read vs ignore
14. **Document Maintenance** - When/how to update this doc

---

## Your Role Definition (from TEAM_PLAYBOOK.md)

### Gemini (QA & Architecture Review)

**Access**: Google Drive folder: `MOSAIC_MVP_IMPLEMENTATION/`

**Primary Responsibilities**:

- Code quality review after major milestones
- Architectural validation (patterns, security, scalability)
- Test plan review
- Risk assessment
- Edge case identification
- Security review (SQL injection, data exposure)

**MUST READ Every Session**:

1. TEAM_PLAYBOOK.md Quick Start (Section 1)
2. Current Sprint Status (Section 2)
3. `IMPLEMENTATION_REFINEMENT_Claude-Gemini.md` (tracks decisions)

**Review Triggers** (When Claude Code Calls You):

- Day 1 EOD: Review context extraction endpoint code
- Day 2 EOD: Review context injection + completion gate logic
- Day 3 EOD: Review experiment-focused coaching prompts
- Ad-hoc: Security concerns, pattern violations, test failures

**Your Review Checklist**:

```
□ Context manager pattern used correctly? (with get_conn() as conn:)
□ PostgreSQL syntax (not SQLite)? (%s not ?, SERIAL not AUTOINCREMENT)
□ All errors logged explicitly? (no bare except:)
□ Security vulnerabilities? (SQL injection, XSS, data exposure)
□ Edge cases handled? (missing data, malformed input, API failures)
□ Performance concerns? (N+1 queries, missing indexes)
□ Rollback path documented?
□ Version tracking complete? (file headers, inline markers)
```

---

## Key Sacred Patterns (Section 5)

**You should look for violations of these in code reviews:**

### Pattern 1: Context Manager (CRITICAL)

```python
# ✅ CORRECT
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))

# ❌ WRONG - Will cause AttributeError
conn = get_conn()
cursor = conn.execute(...)
```

### Pattern 2: PostgreSQL Syntax

```python
# ✅ Use %s placeholders
cursor.execute("INSERT INTO table VALUES (%s, %s)", (val1, val2))

# ❌ Don't use ? (that's SQLite)
cursor.execute("INSERT INTO table VALUES (?, ?)", (val1, val2))
```

### Pattern 3: Explicit Error Logging

```python
# ✅ CORRECT
try:
    result = risky_operation()
except SpecificException as e:
    logger.error(f"Operation failed: {e}", exc_info=True)
    raise

# ❌ WRONG - Silent failure
try:
    risky_operation()
except:
    pass
```

### Pattern 4: Idempotent Operations

```python
# ✅ CORRECT
INSERT INTO table (...) VALUES (...)
ON CONFLICT (unique_col) DO UPDATE SET ...;

# ❌ WRONG - Non-idempotent
INSERT INTO table (...) VALUES (...);
```

### Pattern 5: Pydantic Validation (Your Recommendation!)

```python
# ✅ CORRECT
from pydantic import BaseModel, ValidationError

class PS101Context(BaseModel):
    problem_definition: str
    passions: List[str]
    # ... fields

try:
    context = PS101Context.model_validate_json(llm_response)
except ValidationError as e:
    logger.error(f"LLM validation failed: {e}")
    raise
```

---

## What This Means for You

### When Claude Code Completes Day 1

1. **You'll receive notification**: "Day 1 complete - ready for review"
2. **You'll find review package in**: `MOSAIC_MVP_IMPLEMENTATION/` folder
3. **You'll review using checklist**: From TEAM_PLAYBOOK.md Section 3 (your role)
4. **You'll provide feedback**: Add to `IMPLEMENTATION_REFINEMENT_Claude-Gemini.md`
5. **Claude Code will address**: Marks issues as resolved

### Your Review Focus Areas

**Day 1 (Context Extraction)**:

- `/api/ps101/extract-context` endpoint code
- Database schema (user_contexts, ps101_responses tables)
- Context manager pattern usage (critical!)
- Pydantic validation implementation
- Error handling completeness
- Security (SQL injection, data exposure)

**Day 2 (Context Injection)**:

- `/api/chat/message` modifications
- System prompt injection logic
- PS101 completion gate implementation
- Security (prompt injection, data leakage)

**Day 3 (Experiment Focus)**:

- Coaching prompt refinements
- PS101 onboarding UI copy
- Beta launch readiness

---

## What Documents to Ignore Now

**DO NOT READ (Historical/Superseded)**:

- CODEX_INSTRUCTIONS.md (all versions)
- OPERATIONS_MANUAL.md v1.0
- CODEX_HANDOFF_*.md (all dates)
- Any document mentioning "SQLite" (we use PostgreSQL)

**If contradiction between documents**: TEAM_PLAYBOOK.md wins.

---

## Next Steps

1. **Read TEAM_PLAYBOOK.md** (focus on Quick Start + your role section)
2. **Bookmark for every session**: Quick Start + Current Sprint Status
3. **Wait for Day 1 completion**: Claude Code will notify when ready for review
4. **Review using checklist**: From your role definition
5. **Provide feedback**: In IMPLEMENTATION_REFINEMENT doc

---

## Questions for You

**Before we proceed with Day 1 implementation:**

1. ✅ **Do you have access to TEAM_PLAYBOOK.md?**
   - Location: `~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My Drive/WIMD-Render-Deploy-Project/TEAM_PLAYBOOK.md`

2. ✅ **Is your role definition clear?**
   - Section 3: Gemini (QA & Architecture Review)
   - Review checklist provided

3. ✅ **Are the sacred patterns you should check for clear?**
   - Section 5: Implementation Protocols
   - 5 critical patterns documented

4. ✅ **Is the review workflow clear?**
   - Claude Code completes milestone → Creates review package → Gemini reviews → Provides feedback → Claude Code fixes

---

## Summary

**What Changed**:

- 42+ scattered protocol docs → 1 canonical TEAM_PLAYBOOK.md
- Outdated SQLite references → Current PostgreSQL patterns
- No MVP integration → Full 3-day sprint protocols
- Unclear roles → 5 team members with clear responsibilities

**What This Means for You**:

- Single document to reference every session
- Clear review checklist
- Sacred patterns to validate
- Integrated with MVP sprint workflow

**Next**: Claude Code awaits confirmation before starting Day 1 implementation.

---

**File**: TEAM_PLAYBOOK.md
**Status**: 🔒 Canonical - Single Source of Truth
**Your Section**: Section 3 (Gemini role definition)
**Review Checklist**: Section 3 (8-item checklist)
**Sacred Patterns**: Section 5 (5 critical patterns)
