# MOSAIC TEAM PLAYBOOK (Canonical Protocol)
**Version**: 2.0.0-mvp
**Last Updated**: 2025-12-03
**Status**: 🔒 **SINGLE SOURCE OF TRUTH**
**Supersedes**: All CODEX_INSTRUCTIONS.md, OPERATIONS_MANUAL.md v1.0, CODEX_HANDOFF_*.md

---

## ⚡ CRITICAL: Read This First

**If you are an AI starting a new session:**
1. Read the **Quick Start** section below (5 minutes)
2. Identify your role → Jump to your role section
3. Check **Current Sprint Status** → Understand what's active
4. Review **Protocol Index** → Know when to read what

**If you skip this, you WILL:**
- ❌ Break existing functionality
- ❌ Violate critical patterns (context manager, PostgreSQL syntax)
- ❌ Work on wrong priorities
- ❌ Duplicate work or contradict team members
- ❌ Deploy without proper tracking/rollback

---

## 📋 QUICK START (Read Every Session - 5 Minutes)

### Mandatory Session Initialization Checklist

**Complete these steps in order BEFORE doing ANY work:**

```
□ 1. Read this entire Quick Start section (you are here)
□ 2. Identify your role from Team Roles section below
□ 3. Read your role-specific "MUST READ Every Session" items
□ 4. Check Current Sprint Status (what's actively being built)
□ 5. Review Protocol Index (know when to read detailed protocols)
□ 6. Check for STOP conditions (blocking issues, incomplete migrations)
```

**Time required**: 5 minutes
**Cost of skipping**: Hours of wasted work + broken production

---

## 🎯 CURRENT SPRINT STATUS

**Active Sprint**: Mosaic Context-Aware Coaching MVP (3-Day Sprint)
**Sprint Goal**: Transform generic coaching into personalized coaching using PS101 context
**Current Phase**: ⚠️ Day 1 Fixes Complete - Deployment Blocked
**Sprint Start**: 2025-12-02
**Sprint End**: 2025-12-05 (Day 3 EOD)

### What's Happening Right Now

**Last Updated**: 2025-12-03
**Updated By**: Gemini
**Latest Commit References**:
- `6fc8eef` – refactor(scripts): Archive outdated scripts and document canonical workflow
- `71df141` – refactor(config): Consolidate Railway deployment configuration
- `ea5ffba` – docs: Add session handoff and quick status documents
- `15a31ac` – feat: Add nixpacks.toml to unblock Railway builds
- `799046f` – fix: Implement all Day 1 blocker fixes (auth, timeout, retry)

**CODE STATE (Source of Truth)**:
- Branch: `phase1-incomplete`
- Feature files: `api/ps101.py` (new), `api/settings.py`, `api/index.py`
- Deployment files: `nixpacks.toml`, `railway.toml` (canonical)

**BLOCKING ISSUES (CRITICAL - Address First)**:
1.  **[DEPLOYMENT][OPEN]** Schema version mismatch – `/config` in production still returns `\"v1\"`. The deployment is not reflecting the latest code (commit `71df141` or newer).
2.  **[AUTOMATION][OPEN]** GitHub → Railway auto-deploy trigger is not working. Pushes to `origin/main` do not trigger a new deployment.

**Resolved Day 1 Blockers** (still referenceable but closed):
- ~~[SECURITY] `/api/ps101/extract-context` lacks authentication~~ ✅ Resolved in 799046f
- ~~[RESILIENCE] Missing Claude API timeout~~ ✅ Resolved in 799046f
- ~~[RESILIENCE] Add retry/backoff on Claude API~~ ✅ Resolved in 799046f
- ~~[OBS] Schema constant not versioned~~ ✅ Code now reports `v2`, pending deployment verification

**LAST SESSION ACCOMPLISHED (2025-12-03)**:
- Consolidated conflicting Railway configuration files (`Procfile`, `railway.json` removed).
- Archived numerous outdated and redundant deployment/verification scripts.
- Updated `TEAM_PLAYBOOK.md` to define a canonical script workflow.
- Pushed all fixes and cleanup (commit `6fc8eef`) to `origin/main`.

### Decision Required (2025-12-03)
- **Option A – Finish deployment work first**: Manually deploy the latest commit in the Railway dashboard and verify the schema version is `v2`. Investigate and fix the GitHub auto-deploy trigger.
- **Option B – Parallelize**: Assign deployment cleanup to one owner while another begins Day 2 MVP tasks, accepting temporary production ambiguity.
- See `SESSION_HANDOFF_2025-12-03.md` for evidence backing both options.

**NEXT TASK**: A decision on Option A or B is required to unblock further work.

### What's NOT Changing (Do Not Touch)

- ✅ Existing authentication system
- ✅ Job search functionality
- ✅ Resume optimization features
- ✅ Frontend UI structure (Netlify deployment)
- ✅ Railway infrastructure configuration

### Sprint Documentation Pointers

**Detailed Implementation Plan**:
`MOSAIC_MVP_IMPLEMENTATION/IMPLEMENTATION_REFINEMENT_Claude-Gemini.md`
- Contains refined 3-day plan with hour-by-hour breakdown
- Tracks all decisions made (database schemas, migration approach)
- Includes Gemini's review feedback and enhancements

**Strategic Foundation**:
`MOSAIC_MVP_IMPLEMENTATION/WIMD_MVP_Analysis_Complete.md`
- Opus's comprehensive MVP analysis
- Explains WHY we're building this
- Defines MVP nucleus and deferred features

**Production Code Reference**:
`MOSAIC_MVP_IMPLEMENTATION/mosaic_context_bridge.py`
- Production-ready context extraction implementation
- Use as reference for endpoint development

### Sprint Status Updates

**Last Updated**: 2025-12-02 11:00 AM
**Last Milestone**: Documentation package created for team review
**Next Milestone**: Database schema migration + context extraction endpoint

---

## 👥 TEAM ROLES (Know Your Role)

### Claude Code (Implementation Lead)

**That's You If**: You're reading this in the terminal via `claude_code` command

**Access**:
- Full codebase read/write
- Railway deployment execution
- PostgreSQL database operations
- Git operations

**Primary Responsibilities**:
- Write code for MVP features
- Create database migrations
- Build API endpoints
- Execute Railway deployments
- Write inline documentation with version tracking
- Create backups before major changes
- Run tests locally and in production

**MUST READ Every Session**:
1. This Quick Start section (above)
2. Current Sprint Status (above)
3. Implementation Protocols (Section 5)
4. Database Patterns (Section 6)
5. Version Tracking Protocol (Section 7)

**MUST DO Before Any Code Changes**:
1. Create backup (git tag + folder copy)
2. Update START_HERE.md with backup pointer
3. Add version headers to modified files
4. Add inline change markers with dates
5. Test locally before deploying

**FORBIDDEN (Will Break Production)**:
- ❌ Using `conn = get_conn()` instead of `with get_conn() as conn:`
- ❌ Using SQLite syntax (?, AUTOINCREMENT) instead of PostgreSQL (%s, SERIAL)
- ❌ Deploying without creating backup first
- ❌ Skipping version tracking in file headers
- ❌ Silent exception handling (bare except blocks)
- ❌ Modifying authentication/security without team review

**When to Escalate**:
- Architectural decisions → OPUS or Gemini
- Unclear requirements → Human
- Tests fail >2 hours → Human + Gemini
- Security concerns → Human + Gemini immediately
- Scope creep detected → Human + OPUS

**Your Success Metrics**:
- ✅ All changes have version tracking
- ✅ All deployments have rollback paths
- ✅ Tests pass before deploy
- ✅ No context manager pattern violations
- ✅ No silent failures (all errors logged)

---

### Gemini (QA & Architecture Review)

**That's You If**: You're accessing via Google Drive MCP

**Access**:
- Google Drive folder: `MOSAIC_MVP_IMPLEMENTATION/`
- Read-only access to codebase via shared folders
- Can review code diffs and documentation

**Primary Responsibilities**:
- Code quality review after major milestones
- Architectural validation (patterns, security, scalability)
- Test plan review
- Risk assessment
- Edge case identification
- Security review (SQL injection, data exposure)

**MUST READ Every Session**:
1. This Quick Start section
2. Current Sprint Status
3. `IMPLEMENTATION_REFINEMENT_Claude-Gemini.md` (tracks decisions)

**Review Triggers** (When Claude Code Calls You):
- Day 1 EOD: Review context extraction endpoint code
- Day 2 EOD: Review context injection + completion gate logic
- Day 3 EOD: Review experiment-focused coaching prompts
- Ad-hoc: Security concerns, pattern violations, test failures

**Your Review Checklist**:
```
□ Context manager pattern used correctly?
□ PostgreSQL syntax (not SQLite)?
□ All errors logged explicitly?
□ Security vulnerabilities? (SQL injection, XSS, data exposure)
□ Edge cases handled? (missing data, malformed input, API failures)
□ Performance concerns? (N+1 queries, missing indexes)
□ Rollback path documented?
□ Version tracking complete?
```

**Handoff Protocol**:
1. Claude Code completes milestone → Creates review package
2. Claude Code updates `IMPLEMENTATION_REFINEMENT` doc with "Ready for Review" section
3. Gemini reviews code quality, security, edge cases
4. Gemini adds feedback to `IMPLEMENTATION_REFINEMENT` doc
5. Claude Code addresses feedback → Marks as resolved
6. Cycle repeats until Gemini approves

**Your Success Metrics**:
- ✅ No critical security issues reach production
- ✅ All edge cases identified before deployment
- ✅ Code follows established patterns
- ✅ Rollback procedures validated

---

### OPUS (Strategic Planning)

**That's You If**: You're Claude Opus accessed via Claude.ai

**Access**:
- Strategic planning documents
- MVP analysis and scope decisions
- Accessed via human (high token cost)

**Primary Responsibilities**:
- Define MVP strategy and scope
- Make "build vs defer" decisions
- High-level architecture design
- Strategic pivots when needed

**MUST READ Every Session**:
1. This Quick Start section
2. Your own prior work: `WIMD_MVP_Analysis_Complete.md`
3. Current Sprint Status

**When You're Called**:
- Strategic pivots needed (scope too large/small)
- Fundamental architectural questions
- Prioritization disputes
- Success criteria unclear

**What You DON'T Do**:
- ❌ Implementation details (that's Claude Code)
- ❌ Code review (that's Gemini)
- ❌ Tactical debugging (that's team)

**Handoff Protocol**:
1. Human escalates strategic question to you
2. You provide strategic analysis + recommendation
3. Human approves direction
4. Claude Code implements your recommendation

**Your Success Metrics**:
- ✅ MVP scope remains focused
- ✅ Strategic decisions clear and documented
- ✅ Team unblocked on high-level questions

---

### GPT-4 (Architectural Reviewer)

**That's You If**: You're GPT-4 accessed via ChatGPT or API

**Access**:
- Code snippets provided by human
- Database schema designs
- Security review requests

**Primary Responsibilities**:
- Database schema validation (normalization, indexes, foreign keys)
- Security review (SQL injection, data exposure)
- Architectural pattern validation
- Scalability assessment

**MUST READ When Called**:
1. This Quick Start section (provided by human)
2. Code snippets provided for review
3. Context about what's being built

**Review Triggers**:
- After Day 1: Database schema review
- After Day 2: Context injection security review
- Ad-hoc: Architectural questions

**Your Review Checklist**:
```
□ Database schema normalized correctly?
□ Indexes on foreign keys?
□ SQL injection vulnerabilities?
□ Race conditions possible?
□ Scalability concerns? (N+1 queries, missing pagination)
□ Error handling comprehensive?
□ API design RESTful and intuitive?
```

**Handoff Protocol**:
1. Human provides you code snippets + context
2. You review for architecture, security, scalability
3. You provide findings with specific line references
4. Human relays to Claude Code
5. Claude Code fixes issues

**Your Success Metrics**:
- ✅ Database schema sound and scalable
- ✅ No security vulnerabilities
- ✅ Architectural patterns appropriate

---

### Claude Desktop (Project Manager)

**That's You If**: You're Claude accessed via Claude Desktop app

**Access**:
- Team coordination
- Cross-AI communication
- Status tracking

**Primary Responsibilities**:
- Daily check-ins (EOD summaries)
- Blocker resolution coordination
- Status reporting to human
- Bridging communication between AIs

**MUST READ Every Session**:
1. This Quick Start section
2. Current Sprint Status
3. Latest updates in `IMPLEMENTATION_REFINEMENT` doc

**Daily Workflow**:
- **Morning**: Check if any blockers from previous day
- **Throughout Day**: Monitor progress, coordinate handoffs
- **EOD**: Collect status from Claude Code, report to human

**Status Report Format**:
```markdown
## Day X Status Report

**Completed**:
- [✅] Task 1
- [✅] Task 2

**In Progress**:
- [🔄] Task 3 (50% complete, on track)

**Blocked**:
- [🚫] Task 4 (Blocked by: database schema decision)

**Tomorrow's Plan**:
- [ ] Task 5
- [ ] Task 6

**Risks/Concerns**:
- Risk 1: Description
- Risk 2: Description
```

**Handoff Protocol**:
1. EOD: Request status from Claude Code
2. Compile status report
3. Report to human
4. If blockers: Coordinate escalation to appropriate team member

**Your Success Metrics**:
- ✅ Daily status reports delivered
- ✅ Blockers escalated within 2 hours
- ✅ Team coordination smooth

---

## 📚 PROTOCOL INDEX (When to Read What)

### Every Session Start (All Roles):
- ✅ **Quick Start** (this section - 5 min)
- ✅ **Current Sprint Status** (Section 2)
- ✅ **Your Role Definition** (Section 3)

### Before Writing Any Code (Claude Code):
- ✅ **Implementation Protocols** (Section 5)
- ✅ **Database Patterns** (Section 6)
- ✅ **Version Tracking Protocol** (Section 7)

### Before Deploying to Railway (Claude Code):
- ✅ **Deployment Checklist** (Section 8)
- ✅ **Rollback Procedures** (Section 9)

### When Reviewing Code (Gemini, GPT-4):
- ✅ **Implementation Protocols** (Section 5 - know what to look for)
- ✅ **Database Patterns** (Section 6 - validate patterns)

### When Stuck or Blocked (All Roles):
- ✅ **Troubleshooting Guide** (Section 10)
- ✅ **Escalation Protocols** (Section 11)

### When Starting a New Sprint (All Roles):
- ✅ **Current Sprint Status** (Section 2 - updated at sprint start)
- ✅ **Sprint documentation** (links in Current Sprint Status)

---

## 📜 CANONICAL SCRIPTS

To reduce confusion from a large number of outdated and conflicting scripts, the deployment and verification process has been consolidated. The following scripts are the canonical, blessed scripts to be used for deployment and verification.

All other scripts have been moved to `scripts/archive` for historical purposes and should not be used.

### Deployment
- **`scripts/deploy.sh`**: The main deployment wrapper. This is the entry point for all deployments.
  - **Usage**: `./scripts/deploy.sh <railway|netlify|all>`

### Verification
- **`scripts/verify_live_deployment.sh`**: The canonical script for verifying the live production deployment. It is called by `scripts/deploy.sh` after a deployment.
  - **Usage**: `./scripts/verify_live_deployment.sh`

### Supporting Scripts (used by the canonical scripts)
- **`scripts/push.sh`**: A wrapper for `git push` that runs pre-push verification. Called by `deploy.sh`.
- **`scripts/pre_push_verification.sh`**: A script that runs sanity checks before pushing to production. Called by `push.sh`.
- **`scripts/deploy_frontend_netlify.sh`**: Deploys the frontend to Netlify. Called by `deploy.sh`.
- **`scripts/predeploy_sanity.sh`**: Performs basic sanity checks. Called by `pre_push_verification.sh`.

---

## 5️⃣ IMPLEMENTATION PROTOCOLS

### Sacred Patterns (NEVER VIOLATE - Production Will Break)

#### Pattern 1: Database Context Manager (CRITICAL)

```python
# ✅ CORRECT - ALWAYS USE THIS EXACT PATTERN
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    result = cursor.fetchone()

# ❌ WRONG - WILL CAUSE AttributeError: 'ConnectionPool' object has no attribute 'execute'
conn = get_conn()
cursor = conn.execute(...)  # CRASHES
result = cursor.fetchone()
```

**Why This Exists**:
- PostgreSQL connection pool returns pool object, NOT connection
- Context manager (`with`) acquires actual connection from pool
- Calling methods directly on pool object causes AttributeError
- This is the #1 cause of production failures in this codebase

**Enforcement**:
- Pre-commit hook scans for `conn = get_conn()` pattern
- Code review by Gemini checks every database operation
- Deployment will be rolled back if violations found in logs

**If You Violate This**:
- Production API returns 500 errors
- Database operations fail silently or loudly
- Immediate rollback required
- All changes reverted until fixed

**Correct Pattern Details**:
```python
# Get connection from pool via context manager
with get_conn() as conn:
    # Now conn is actual connection, not pool
    cursor = conn.cursor()  # ✅ Works

    # Always use %s placeholders (PostgreSQL)
    cursor.execute(
        "INSERT INTO users (email, name) VALUES (%s, %s)",
        (email, name)  # ✅ Tuple of values
    )

    # Commit is automatic on context exit if no exception
    # Rollback is automatic if exception occurs
```

**Historical Context**:
- Migrated from SQLite (direct connection) to PostgreSQL (connection pool)
- Old pattern: `conn = get_conn()` worked with SQLite
- New pattern: MUST use `with get_conn() as conn:` for PostgreSQL
- See TROUBLESHOOTING_CHECKLIST.md "CONTEXT_MANAGER_BUG" for full details

---

#### Pattern 2: PostgreSQL Syntax (NOT SQLite)

```python
# ✅ CORRECT - PostgreSQL placeholders
cursor.execute(
    "INSERT INTO table (col1, col2) VALUES (%s, %s)",
    (val1, val2)
)

# ❌ WRONG - SQLite placeholders (will cause syntax error)
cursor.execute(
    "INSERT INTO table (col1, col2) VALUES (?, ?)",
    (val1, val2)
)
```

```sql
-- ✅ CORRECT - PostgreSQL auto-increment
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL
);

-- ❌ WRONG - SQLite auto-increment (will fail)
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL
);
```

**Why This Exists**:
- Migrated from SQLite to PostgreSQL in October 2025
- Some docs/code may still reference old SQLite patterns
- PostgreSQL syntax is incompatible with SQLite syntax

**Key Differences**:
| Feature | PostgreSQL | SQLite |
|---------|-----------|--------|
| Placeholder | `%s` | `?` |
| Auto-increment | `SERIAL` | `AUTOINCREMENT` |
| Get connection | `with get_conn()` | `get_conn()` direct |
| Boolean type | `BOOLEAN` | `INTEGER` (0/1) |
| JSON type | `JSONB` | `TEXT` |

**Enforcement**:
- Grep checks before deploy: `grep -r "?" api/*.py` should return nothing in SQL strings
- Grep checks before deploy: `grep -r "AUTOINCREMENT" migrations/` should return nothing
- Tests run against PostgreSQL (not SQLite)

---

#### Pattern 3: Explicit Error Logging (No Silent Failures)

```python
# ✅ CORRECT - Explicit logging with context
import logging
logger = logging.getLogger(__name__)

try:
    result = risky_operation(user_id)
except SpecificException as e:
    logger.error(
        f"Operation failed for user {user_id}: {e}",
        exc_info=True,  # Includes full traceback
        extra={"user_id": user_id, "operation": "context_extraction"}
    )
    # Either re-raise or return fallback
    raise

# ❌ WRONG - Silent failure (undebuggable)
try:
    risky_operation()
except:
    pass  # ERROR: Silent failure

# ❌ WRONG - Bare except (catches everything including KeyboardInterrupt)
try:
    risky_operation()
except Exception:
    print("Error occurred")  # ERROR: Not logged, just printed
```

**Why This Exists**:
- Silent failures are impossible to debug in production
- Railway logs are the only way to diagnose production issues
- Print statements don't appear in Railway logs (use logger)

**Logging Best Practices**:
```python
# Import at module level
import logging
logger = logging.getLogger(__name__)

# Different log levels
logger.debug("Detailed info for debugging")
logger.info("Normal operation milestone")
logger.warning("Something unexpected but handled")
logger.error("Operation failed", exc_info=True)
logger.critical("System cannot continue")

# Include context
logger.error(
    f"Context extraction failed",
    extra={
        "user_id": user_id,
        "ps101_complete": ps101_complete,
        "error_type": type(e).__name__
    }
)
```

**Enforcement**:
- Code review checks for bare `except:` blocks
- Grep checks: `grep -r "except:" api/*.py` should only show specific exceptions
- If error not logged, production debugging is impossible

---

#### Pattern 4: Idempotent Database Operations

```python
# ✅ CORRECT - Idempotent insert
cursor.execute("""
    INSERT INTO user_contexts (user_id, context_data, extracted_at)
    VALUES (%s, %s, NOW())
    ON CONFLICT (user_id)
    DO UPDATE SET
        context_data = EXCLUDED.context_data,
        extracted_at = NOW()
""", (user_id, json.dumps(context)))

# ❌ WRONG - Non-idempotent (fails on duplicate)
cursor.execute("""
    INSERT INTO user_contexts (user_id, context_data)
    VALUES (%s, %s)
""", (user_id, json.dumps(context)))
# Will fail with IntegrityError if user_id already exists
```

**Why This Exists**:
- Operations may be retried (network failures, timeouts)
- Same request shouldn't fail on retry
- Data consistency ensured

**Idempotent Patterns**:
```sql
-- Insert or update
INSERT INTO table (...) VALUES (...)
ON CONFLICT (unique_col) DO UPDATE SET ...;

-- Update or insert (check first)
UPDATE table SET ... WHERE id = %s;
-- If rowcount = 0, then INSERT

-- Delete is naturally idempotent
DELETE FROM table WHERE id = %s;
-- Succeeds even if row doesn't exist
```

---

#### Pattern 5: Pydantic Validation for LLM Responses

```python
# ✅ CORRECT - Validate LLM output with Pydantic
from pydantic import BaseModel, Field, ValidationError
from typing import List

class ExperimentIdea(BaseModel):
    idea: str
    smallest_version: str

class PS101Context(BaseModel):
    problem_definition: str
    passions: List[str] = Field(default_factory=list)
    skills: List[str] = Field(default_factory=list)
    secret_powers: List[str] = Field(default_factory=list)
    proposed_experiments: List[ExperimentIdea] = Field(default_factory=list)
    internal_obstacles: List[str] = Field(default_factory=list)
    external_obstacles: List[str] = Field(default_factory=list)
    key_quotes: List[str] = Field(default_factory=list)

# Extract context from Claude API
response_text = claude_api_call(prompt)

# Parse and validate
try:
    context = PS101Context.model_validate_json(response_text)
except ValidationError as e:
    logger.error(f"LLM output validation failed: {e}")
    # Return fallback or retry
    raise

# ❌ WRONG - No validation (brittle)
import json
context = json.loads(response_text)  # May fail, may be malformed
# No guarantee context has expected fields
```

**Why This Exists**:
- LLM responses are inherently unreliable
- Model updates from Anthropic/OpenAI can break parsing
- Pydantic provides clear error messages
- Graceful degradation possible with validation

**Gemini's Recommendation**:
> "The primary technical risk is LLM brittleness. While the prompt is well-crafted, this is an inherently brittle integration point. Adding a validation step using a Pydantic model would add another layer of robustness."

---

#### Pattern 6: Script Lifecycle Management (CRITICAL)

To prevent configuration drift and script chaos, a strict lifecycle for scripts must be followed. When a script is updated or replaced, the new script must be in place and verified before the old one is removed.

**Once the replacement is confirmed to be working, the outdated script *must* be immediately archived to `scripts/archive` or deleted.**

This ensures that only canonical, in-use scripts are present in the active project directories.

---

### Version Tracking (Every Modified File)

**See Section 7 for full Version Tracking Protocol**

Every file you modify MUST include:
1. Updated file header with version, date, changes
2. Inline change markers around modified code
3. Rollback path documented
4. Updated API_VERSION in api/index.py

**Non-negotiable**: If version tracking missing, deployment will be rejected.

---

## 6️⃣ DATABASE PATTERNS

### Current Schema Version

**Version**: v2 (MVP - Context Extraction)
**Migration**: 20251202_add_context_tables.sql
**Rollback**: 20251202_rollback.sql

### Schema v1 (Existing - Do Not Modify)

**Tables**:
- `users` - User accounts (id, email, password_hash, created_at)
- `sessions` - User sessions (id, user_id, user_data JSONB, created_at, last_active, expires_at)
- `wimd_outputs` - Delta analysis results
- `job_matches` - Job search results
- `resume_versions` - Resume optimization history
- `file_uploads` - Uploaded resumes/documents

**Do NOT Modify**: These tables support existing functionality (auth, job search, resume optimization)

### Schema v2 (Adding in MVP)

#### Table: ps101_responses

**Purpose**: Persist PS101 responses across sessions (currently session-only)

**Schema**:
```sql
CREATE TABLE IF NOT EXISTS ps101_responses (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    step INTEGER NOT NULL,
    prompt_index INTEGER NOT NULL,
    response TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ps101_user ON ps101_responses(user_id);
CREATE INDEX IF NOT EXISTS idx_ps101_timestamp ON ps101_responses(timestamp);
```

**Why This Exists**:
- PS101 responses currently stored in `sessions.user_data` JSONB (ephemeral)
- Session expires → PS101 data lost
- Cannot extract context after user logs out/back in
- Cannot analyze PS101 patterns across users

**Usage Pattern**:
```python
# Record PS101 response (replaces session-only storage)
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO ps101_responses (user_id, step, prompt_index, response, timestamp)
        VALUES (%s, %s, %s, %s, NOW())
    """, (user_id, step, prompt_index, response))
    conn.commit()

# Retrieve all responses for context extraction
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT step, prompt_index, response, timestamp
        FROM ps101_responses
        WHERE user_id = %s
        ORDER BY step, prompt_index
    """, (user_id,))
    responses = cursor.fetchall()
```

---

#### Table: user_contexts

**Purpose**: Store extracted context from Claude API for personalized coaching

**Schema**:
```sql
CREATE TABLE IF NOT EXISTS user_contexts (
    user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    context_data JSONB NOT NULL,
    extracted_at TIMESTAMP DEFAULT NOW(),
    extraction_model TEXT DEFAULT 'claude-sonnet-4-20250514',
    extraction_prompt_version TEXT DEFAULT 'v1.0'
);

CREATE INDEX IF NOT EXISTS idx_contexts_extracted ON user_contexts(extracted_at);
```

**Why This Exists**:
- Stores structured context extracted from PS101 responses
- Used to personalize coaching system prompts
- Tracks which model/prompt version used (enables A/B testing, debugging)

**Context Data Structure** (JSONB):
```json
{
  "problem_definition": "One sentence capturing core challenge",
  "passions": ["Interest 1", "Interest 2"],
  "skills": ["Skill 1", "Skill 2"],
  "secret_powers": ["Hidden strength they undervalue"],
  "proposed_experiments": [
    {
      "idea": "Direction they mentioned exploring",
      "smallest_version": "Tiny testable version"
    }
  ],
  "internal_obstacles": ["Fear 1", "Self-doubt 2"],
  "external_obstacles": ["Constraint 1", "Constraint 2"],
  "key_quotes": ["Powerful phrase from their answers"]
}
```

**Usage Pattern**:
```python
# Store extracted context
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO user_contexts (user_id, context_data, extracted_at)
        VALUES (%s, %s, NOW())
        ON CONFLICT (user_id)
        DO UPDATE SET
            context_data = EXCLUDED.context_data,
            extracted_at = NOW()
    """, (user_id, json.dumps(context)))
    conn.commit()

# Retrieve context for coaching
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT context_data
        FROM user_contexts
        WHERE user_id = %s
    """, (user_id,))
    result = cursor.fetchone()
    context = result[0] if result else None
```

---

### PS101 Completion Tracking

**Approach**: Infer completion from `user_contexts` table existence

**Logic**:
```python
def has_completed_ps101(user_id: str) -> bool:
    """Check if user has completed PS101 (has extracted context)"""
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT EXISTS(
                SELECT 1 FROM user_contexts WHERE user_id = %s
            )
        """, (user_id,))
        return cursor.fetchone()[0]
```

**Why This Approach**:
- Completion = context extracted (functional definition)
- No additional column needed in users table
- Simpler schema, fewer migrations

**Alternative**: Add `ps101_completed` boolean to users table (not chosen, but viable if requirements change)

---

### Migration Management

**Location**: `migrations/YYYYMMDD_description.sql`
**Naming**: Date + brief description (e.g., `20251202_add_context_tables.sql`)
**Rollback**: Every migration has corresponding rollback script

**Migration Template**:
```sql
-- MIGRATION: 20251202_add_context_tables.sql
-- VERSION: 2.0.0-mvp-day1
-- PHASE: MVP Day 1 - Context Extraction
-- AUTHOR: Claude Code
-- DATE: 2025-12-02
-- ROLLBACK: Run 20251202_rollback.sql

-- PURPOSE: Add tables for persistent PS101 storage and context extraction
-- DEPENDENCIES: Existing users table
-- IMPACTS: None (additive only, no existing data affected)

-- [Table definitions here]

-- VERIFICATION QUERIES:
-- Check tables created:
SELECT table_name FROM information_schema.tables
WHERE table_name IN ('ps101_responses', 'user_contexts');

-- Check indexes created:
SELECT indexname FROM pg_indexes
WHERE tablename IN ('ps101_responses', 'user_contexts');
```

**Rollback Template**:
```sql
-- ROLLBACK: 20251202_rollback.sql
-- REVERTS: 20251202_add_context_tables.sql
-- VERSION: Reverts from v2.0.0 back to v1.0.0

-- WARNING: This will delete all PS101 responses and user contexts
-- BACKUP: Ensure Railway PostgreSQL backup exists before running

DROP TABLE IF EXISTS user_contexts CASCADE;
DROP TABLE IF EXISTS ps101_responses CASCADE;

-- VERIFICATION:
SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_name='user_contexts'
); -- Should return: false
```

---

### Database Testing

**Before Deploying Migration**:
```bash
# 1. Test migration locally
psql $DATABASE_URL < migrations/20251202_add_context_tables.sql

# 2. Verify tables created
psql $DATABASE_URL -c "\dt ps101_responses user_contexts"

# 3. Test rollback
psql $DATABASE_URL < migrations/20251202_rollback.sql

# 4. Verify tables dropped
psql $DATABASE_URL -c "\dt ps101_responses user_contexts"
# Should return: no rows

# 5. Re-apply migration for actual deploy
psql $DATABASE_URL < migrations/20251202_add_context_tables.sql
```

**Integration with init_db()**:
```python
# api/storage.py
def init_db() -> None:
    """Initialize database schema (idempotent)"""
    with get_conn() as conn:
        cursor = conn.cursor()

        # v1 tables (existing)
        cursor.execute("""CREATE TABLE IF NOT EXISTS users ...""")
        cursor.execute("""CREATE TABLE IF NOT EXISTS sessions ...""")
        # ... other v1 tables

        # v2 tables (MVP)
        cursor.execute("""CREATE TABLE IF NOT EXISTS ps101_responses ...""")
        cursor.execute("""CREATE TABLE IF NOT EXISTS user_contexts ...""")

        conn.commit()
```

---

## 7️⃣ VERSION TRACKING PROTOCOL

### Why Version Tracking Exists

**Problem Without It**:
- AI in new session doesn't know what changed
- Rollback is guessing which files to restore
- Can't trace when bug was introduced
- Multiple AIs make conflicting changes

**Solution**:
Every file carries its own change history inline.

---

### File Header Template

**Add to EVERY file you create or modify:**

```python
"""
MODULE: api/ps101.py
PURPOSE: PS101 context extraction and persistence
VERSION: 2.0.0-mvp-day1
SCHEMA_VERSION: v2
LAST_MODIFIED: 2025-12-02
MODIFIED_BY: Claude Code
SPRINT: MVP Context-Aware Coaching (Day 1)

CHANGES_THIS_VERSION:
  - Added /api/ps101/extract-context endpoint
  - Added Pydantic validation for context structure
  - Integrated with user_contexts table
  - Changed PS101 storage from session-only to database persistence

DEPENDENCIES:
  - anthropic library (Claude API)
  - pydantic (validation)
  - storage.get_conn (database)
  - ps101_responses table (must exist)
  - user_contexts table (must exist)

ROLLBACK_PATH:
  - Code: api_backup_20251202-103000/ps101.py
  - Database: migrations/20251202_rollback.sql
  - Git tag: backup-20251202-103000

TESTING:
  - tests/test_context_extraction.py
  - Golden dataset: 10 sample PS101 completions
  - Success criteria: 100% valid JSON responses
"""
```

---

### Inline Change Markers

**For significant code blocks:**

```python
# ===================================================================
# [CHANGE] 2025-12-02 - Claude Code - MVP Day 1
# ADDED: Context extraction endpoint
# PREVIOUS STATE: PS101 flow was session-only, no persistence
# NEW STATE: PS101 responses persist to database, context extracted via Claude API
# ROLLBACK: Remove this entire function, revert to session-based storage
# TESTING: See tests/test_context_extraction.py
# ===================================================================

@app.post("/api/ps101/extract-context")
async def extract_context(user_id: str):
    """Extract structured context from PS101 responses using Claude API

    VERSION: 1.0.0
    ADDED: 2025-12-02 (MVP Day 1)
    AUTHOR: Claude Code

    Args:
        user_id: User ID to extract context for

    Returns:
        Structured context JSON following PS101Context schema

    Raises:
        404: User not found or PS101 not completed
        422: Validation error (malformed LLM response)
        500: Extraction failed (LLM error, database error)

    DEPENDENCIES:
        - anthropic library
        - user_contexts table must exist
        - ps101_responses table must exist
        - CLAUDE_API_KEY environment variable

    TESTING:
        curl -X POST http://localhost:8000/api/ps101/extract-context \
          -H "Content-Type: application/json" \
          -d '{"user_id": "test-user-123"}'
    """

    # [BLOCK 1] Fetch PS101 responses from database
    # Added: 2025-12-02
    # Previous: Fetched from session.user_data
    # Now: Fetches from ps101_responses table (persistent)
    with get_conn() as conn:  # ✅ Using sacred context manager pattern
        cursor = conn.cursor()
        cursor.execute("""
            SELECT step, prompt_index, response
            FROM ps101_responses
            WHERE user_id = %s
            ORDER BY step, prompt_index
        """, (user_id,))
        responses = cursor.fetchall()
    # [END BLOCK 1]

    # [BLOCK 2] Claude API extraction
    # Added: 2025-12-02
    # Uses: claude-sonnet-4-20250514
    # Fallback: If model deprecated, update to latest Sonnet in anthropic docs
    client = anthropic.Anthropic(api_key=os.getenv("CLAUDE_API_KEY"))
    # ... extraction logic
    # [END BLOCK 2]

    # [BLOCK 3] Pydantic validation
    # Added: 2025-12-02
    # Purpose: Ensure LLM output matches expected schema
    # Gemini's recommendation: "Adding Pydantic validation adds robustness layer"
    try:
        context = PS101Context.model_validate_json(response_text)
    except ValidationError as e:
        logger.error(f"LLM output validation failed: {e}")
        raise HTTPException(status_code=422, detail="Malformed LLM response")
    # [END BLOCK 3]

    return context.model_dump()

# ===================================================================
# [END CHANGE] 2025-12-02
# ===================================================================
```

---

### Update api/index.py (API Version)

**Required before every deployment:**

```python
# api/index.py

"""
MOSAIC Platform API - Entry Point
VERSION: 2.0.0-mvp-day1
SCHEMA_VERSION: v2
LAST_DEPLOY: 2025-12-02 10:30 AM
DEPLOYMENT_STATUS: Day 1 - Context Extraction Added

CHANGE HISTORY:
  v2.0.0-mvp-day1 (2025-12-02):
    - Added /api/ps101/extract-context endpoint
    - Added user_contexts table (schema v2)
    - Added ps101_responses table (schema v2)
    - PS101 data now persists across sessions
    - Context extraction via Claude API working

  v1.0.0 (2025-10-07):
    - Initial production deployment
    - Job search, resume optimization, PS101 flow
    - Schema v1: users, sessions, wimd_outputs, job_matches, resume_versions, file_uploads
"""

# API VERSION (exposed via /health endpoint)
API_VERSION = "2.0.0-mvp-day1"
SCHEMA_VERSION = "v2"
MVP_PHASE = "Day 1 - Context Extraction"
LAST_MODIFIED = "2025-12-02"

# ... rest of api/index.py
```

---

### Automated Version Update Script

**Location**: `scripts/update_version.sh`

```bash
#!/bin/bash
# scripts/update_version.sh
# Automated version tracking updates

VERSION=$1
PHASE=$2
CHANGES=$3

if [ -z "$VERSION" ] || [ -z "$PHASE" ]; then
    echo "Usage: ./scripts/update_version.sh VERSION PHASE CHANGES"
    echo "Example: ./scripts/update_version.sh 2.0.0-mvp-day1 'Day 1 Complete' 'Context extraction endpoint working'"
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "🔄 Updating version to $VERSION..."

# 1. Update api/index.py
sed -i.bak "s/API_VERSION = .*/API_VERSION = \"$VERSION\"/" api/index.py
sed -i.bak "s/MVP_PHASE = .*/MVP_PHASE = \"$PHASE\"/" api/index.py
sed -i.bak "s/LAST_MODIFIED = .*/LAST_MODIFIED = \"$(date +%Y-%m-%d)\"/" api/index.py

# 2. Update START_HERE.md MVP section
sed -i.bak "s/Status\*\*: .*/Status**: $PHASE/" START_HERE.md
sed -i.bak "s/Current\*\*: \`api\/\` .*/Current**: \`api\/\` (git tag: backup-$TIMESTAMP)/" START_HERE.md
sed -i.bak "s/Last Backup\*\*: .*/Last Backup**: api_backup_$TIMESTAMP/" START_HERE.md

# 3. Create git tag
git add .
git commit -m "$PHASE - $CHANGES"
git tag -a "backup-$TIMESTAMP" -m "$PHASE - $CHANGES"

echo "✅ Version updated to $VERSION"
echo "📌 Git tagged: backup-$TIMESTAMP"
echo "💾 Update START_HERE.md and api/index.py"
```

**Usage**:
```bash
# After Day 1 complete
./scripts/update_version.sh \
  "2.0.0-mvp-day1" \
  "Day 1 Complete - Context Extraction Working" \
  "Context extraction endpoint returns 100% valid JSON, database schema deployed"
```

---

### Version Tracking Checklist

**Before committing ANY code:**

```
□ File headers updated (VERSION, LAST_MODIFIED, CHANGES_THIS_VERSION)
□ Inline change markers added ([CHANGE] ... [END CHANGE])
□ Rollback path documented in header
□ api/index.py version updated (API_VERSION, MVP_PHASE)
□ START_HERE.md updated with backup pointer
□ Git tag created (backup-YYYYMMDD-HHMMSS)
□ Backup folder created (api_backup_YYYYMMDD-HHMMSS)
```

**If ANY item unchecked → Deployment rejected**

---

## 8️⃣ DEPLOYMENT CHECKLIST

### Pre-Deployment Checklist (MANDATORY)

**Complete ALL items before `git push railway-origin main`:**

```
TESTS:
□ All tests pass locally (pytest tests/ -v)
□ Golden dataset tests pass (pytest tests/test_golden_dataset.py)
□ Database migration tested locally
□ Rollback tested locally
□ Health check returns 200 locally (curl localhost:8000/health)

VERSION TRACKING:
□ File headers updated with version/date/changes
□ Inline change markers added
□ api/index.py version updated
□ START_HERE.md updated with backup pointer

BACKUP:
□ Git backup tag created (backup-YYYYMMDD-HHMMSS)
□ Code backup folder created (api_backup_YYYYMMDD-HHMMSS)
□ Database schema saved (schema_v2_backup.sql)

VALIDATION:
□ Context manager pattern used correctly (no conn = get_conn())
□ PostgreSQL syntax used (no ?, no AUTOINCREMENT)
□ All errors logged explicitly (no bare except:)
□ Pydantic validation on LLM responses

APPROVAL:
□ Human approval received (even with session approval)
□ Gemini code review complete (if milestone)
□ GPT-4 architecture review complete (if schema change)

DOCUMENTATION:
□ IMPLEMENTATION_REFINEMENT doc updated with status
□ Rollback path documented
□ Testing instructions documented
```

**If ANY item unchecked → DO NOT DEPLOY**

---

### Deployment Commands

**Standard Deployment**:
```bash
# 1. Ensure on correct branch
git branch  # Should show: main or mvp-day1

# 2. Final commit with all changes
git add .
git commit -m "[MVP Day 1] Context extraction endpoint + schema v2"

# 3. Create backup tag
git tag -a backup-$(date +%Y%m%d-%H%M%S) -m "Pre-deploy backup: Day 1 context extraction"

# 4. Push to Railway
git push railway-origin main

# 5. Monitor deployment
railway logs --follow
```

**Emergency Rollback Deployment**:
```bash
# If production broken, rollback immediately
git checkout backup-20251202-103000  # Last working tag
git push railway-origin HEAD:main --force

# Run database rollback if schema changed
psql $DATABASE_URL < migrations/20251202_rollback.sql
```

---

### Post-Deployment Validation

**Run IMMEDIATELY after deploy (within 5 minutes):**

```bash
# 1. Health check
curl https://whatismydelta.com/health
# Should return: {"ok": true, "version": "2.0.0-mvp-day1", ...}

# 2. Verify version deployed
curl https://whatismydelta.com/health | jq '.deployment.git_commit'
# Should return: Latest commit hash

# 3. Verify database schema
psql $DATABASE_URL -c "SELECT table_name FROM information_schema.tables WHERE table_name IN ('user_contexts', 'ps101_responses');"
# Should return: Both tables

# 4. Test new endpoint
curl -X POST https://whatismydelta.com/api/ps101/extract-context \
  -H "Content-Type: application/json" \
  -d '{"user_id": "test-user-123"}'
# Should return: 404 (user not found) or 200 (context extracted)

# 5. Monitor logs for 5 minutes
railway logs --follow
# Watch for: Errors, warnings, unexpected behavior
```

**If ANY validation fails → Rollback immediately (see Section 9)**

---

### Deployment Failure Triage

**If deployment fails:**

```bash
# 1. Check build logs
railway logs | grep ERROR

# 2. Common failures and fixes
#    - "psycopg2" error → DATABASE_URL not set or wrong format
#    - "Module not found" → Missing dependency in requirements.txt
#    - "Syntax error" → Python syntax error in code
#    - "Port already in use" → Railway port config issue (shouldn't happen)

# 3. Check environment variables
railway variables | grep -E "DATABASE_URL|CLAUDE_API_KEY|OPENAI_API_KEY"

# 4. If unclear, rollback and investigate locally
git checkout backup-20251202-103000
git push railway-origin HEAD:main --force
```

---

## 9️⃣ ROLLBACK PROCEDURES

### When to Rollback (Immediately)

**Rollback if ANY of these occur:**

- ❌ Health check returns 500 error
- ❌ Database operations failing (context manager violations)
- ❌ New endpoint returns errors for valid requests
- ❌ Existing functionality broken (auth, job search, resume)
- ❌ Railway logs show repeated errors
- ❌ Context extraction <100% success rate (Day 1 blocker)

**DO NOT wait to investigate - rollback first, investigate second**

---

### Rollback Procedure (3 Steps)

#### Step 1: Identify Last Working State

```bash
# Option A: Check START_HERE.md
cat START_HERE.md | grep "Last Backup"
# Output: Last Backup**: api_backup_20251202-103000

# Option B: Check git tags
git tag -l | grep backup | tail -5
# Output: Shows last 5 backup tags

# Option C: Check Railway deployment history
railway deployments
# Shows last successful deployment
```

**Result**: Identify tag/backup to restore (e.g., `backup-20251202-103000`)

---

#### Step 2: Restore Code

```bash
# Option A: Restore from backup folder
BACKUP_DIR="api_backup_20251202-103000"
if [ -d "$BACKUP_DIR" ]; then
    echo "Restoring from $BACKUP_DIR..."
    cp -r "$BACKUP_DIR"/* api/
    git add api/
    git commit -m "[ROLLBACK] Restored from $BACKUP_DIR"
    git push railway-origin main
fi

# Option B: Revert to git tag
TAG="backup-20251202-103000"
git checkout $TAG
git push railway-origin HEAD:main --force
```

**Result**: Code restored to last working state, Railway re-deploys

---

#### Step 3: Restore Database (If Schema Changed)

```bash
# Check if rollback migration exists
ROLLBACK_SCRIPT=$(ls -1t migrations/*_rollback.sql 2>/dev/null | head -1)

if [ -f "$ROLLBACK_SCRIPT" ]; then
    echo "Rolling back database with $ROLLBACK_SCRIPT..."
    psql $DATABASE_URL < "$ROLLBACK_SCRIPT"

    # Verify rollback
    psql $DATABASE_URL -c "SELECT table_name FROM information_schema.tables WHERE table_name IN ('user_contexts', 'ps101_responses');"
    # Should return: no rows (tables dropped)
else
    echo "No rollback migration found - schema unchanged"
fi
```

**Result**: Database schema reverted to previous version

---

### Post-Rollback Validation

**Verify restoration successful:**

```bash
# 1. Health check
curl https://whatismydelta.com/health
# Should return: {"ok": true, "version": "1.0.0", ...}

# 2. Test existing functionality
curl https://whatismydelta.com/config
# Should return: Config without errors

# 3. Verify database accessible
psql $DATABASE_URL -c "SELECT COUNT(*) FROM users;"
# Should return: Count without error

# 4. Monitor logs for 5 minutes
railway logs --follow
# Should show: No errors, normal operation
```

**If validation passes → Rollback successful, investigate issue locally**

---

### Document Rollback in START_HERE.md

```bash
# Update START_HERE.md to reflect rollback
cat >> START_HERE.md <<EOF

## Rollback History

**2025-12-02 10:45 AM - Rolled back from v2.0.0-mvp-day1**
- Reason: Context extraction endpoint returning 500 errors
- Restored to: backup-20251202-103000 (v1.0.0)
- Database: Rolled back schema v2 → v1
- Issue: Context manager pattern violation in ps101.py line 45
- Fix required: Review TEAM_PLAYBOOK Section 5 Pattern 1 before re-deploying
EOF
```

---

## 🔟 TROUBLESHOOTING GUIDE

### Quick Triage (3 Minutes)

**When something breaks, run these 4 commands:**

```bash
# 1. Health check
curl https://whatismydelta.com/health
# Look for: "ok": false, error messages, version mismatch

# 2. Recent logs
railway logs --tail 100 | grep -E "ERROR|WARNING|CRITICAL"
# Look for: Python exceptions, database errors, API failures

# 3. Database connection
railway logs | grep -i "storage\|postgres"
# Look for: "PostgreSQL connection pool created" (good) or "SQLite" (bad - fallback active)

# 4. Recent deployments
git log --oneline -5
# Look for: What changed recently
```

**Time: 3 minutes**
**Result: Identify error category (database, LLM, syntax, config)**

---

### Error Classification

**See TROUBLESHOOTING_CHECKLIST.md for complete classification**

**Quick reference:**

| Symptom | Category | First Action |
|---------|----------|--------------|
| 500 errors after deploy | Code Bug | Check logs for exception, rollback if critical |
| "AttributeError: 'ConnectionPool'" | Context Manager Violation | Rollback immediately, fix pattern |
| "syntax error at or near" | SQLite Syntax in PostgreSQL | Rollback, fix to PostgreSQL syntax |
| 404 on new endpoint | Endpoint Not Registered | Verify FastAPI route decorator, restart |
| Slow responses | Performance | Check database queries for N+1, missing indexes |
| "Invalid API key" | Config Error | Verify Railway environment variables |
| All endpoints broken | Infrastructure | Check Railway status, database connection |

---

### Common Issues & Solutions

#### Issue 1: Context Manager Pattern Violation

**Symptoms**:
```
AttributeError: 'ConnectionPool' object has no attribute 'execute'
AttributeError: 'ConnectionPool' object has no attribute 'cursor'
```

**Cause**: Using `conn = get_conn()` instead of `with get_conn() as conn:`

**Solution**:
```bash
# 1. Rollback immediately (production broken)
git checkout backup-20251202-103000
git push railway-origin HEAD:main --force

# 2. Find violations locally
grep -rn "conn = get_conn()" api/
# Example output: api/ps101.py:45: conn = get_conn()

# 3. Fix violations
# Change: conn = get_conn()
# To:     with get_conn() as conn:

# 4. Test locally before re-deploying
pytest tests/ -v
```

**Prevention**: Pre-commit hook checks for this pattern

---

#### Issue 2: LLM Extraction Fails Validation

**Symptoms**:
```
ValidationError: 1 validation error for PS101Context
  problem_definition
    Field required [type=missing, input_value={...}, input_type=dict]
```

**Cause**: Claude API returned JSON missing required fields or malformed

**Solution**:
```python
# Add fallback handling in extract_context endpoint
try:
    context = PS101Context.model_validate_json(response_text)
except ValidationError as e:
    logger.error(f"LLM validation failed: {e}", extra={"response": response_text})

    # Fallback 1: Retry with refined prompt
    response_text = retry_extraction_with_clarification(ps101_responses)
    context = PS101Context.model_validate_json(response_text)

    # Fallback 2: Manual fallback ("Wizard of Oz")
    # See Gemini's Suggestion 3 in IMPLEMENTATION_REFINEMENT doc
```

**Prevention**: Gemini's suggestion - use Pydantic validation (implemented)

---

#### Issue 3: PS101 Data Not Persisting

**Symptoms**:
- User completes PS101
- User logs out
- User logs back in
- PS101 data missing / user forced to restart

**Cause**: PS101 responses still stored in session (ephemeral), not database

**Solution**:
```python
# Check current storage location
# api/ps101_flow.py
def record_ps101_response(session_data: Dict[str, Any], step: int, response: str):
    # ❌ Current: Only stores in session
    session_data["ps101_responses"].append({...})

    # ✅ Fix: Also persist to database
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO ps101_responses (user_id, step, prompt_index, response)
            VALUES (%s, %s, %s, %s)
        """, (user_id, step, prompt_index, response))
        conn.commit()
```

**Prevention**: Day 1 implementation includes this fix

---

### Escalation Decision Tree

```
Issue occurs
    ↓
Can I fix in <30 minutes?
    ├─ YES → Fix it, test, document
    └─ NO → Is it blocking MVP Day 1?
        ├─ YES → Escalate to Human + Gemini immediately
        └─ NO → Document issue, continue other work, escalate EOD
```

---

## 1️⃣1️⃣ ESCALATION PROTOCOLS

### When to Escalate (Decision Matrix)

| Issue Type | Escalate To | Urgency | Why |
|------------|-------------|---------|-----|
| **Production down** | Human | Immediate | Need approval for emergency rollback |
| **Architectural decision** | OPUS or Gemini | High | Strategic/design choice needed |
| **Security vulnerability** | Human + Gemini | Immediate | Critical risk |
| **Database schema unclear** | GPT-4 | Medium | Need schema validation |
| **Tests fail >2 hours** | Human + Gemini | High | Blocking progress |
| **Scope creep detected** | Human + OPUS | High | Strategic realignment needed |
| **Context manager violation** | Rollback + Gemini | Immediate | Production breaking pattern |
| **LLM extraction <100%** | Gemini | High | Day 1 blocker (success criteria) |
| **Unclear requirements** | Human | Medium | Need clarification |
| **Performance degradation** | Gemini | Medium | Code review needed |

---

### Escalation Format

**When escalating, provide:**

```markdown
## Escalation: [Brief Title]

**Issue**: One sentence describing the problem
**Impact**: What's broken or blocked
**Urgency**: Immediate / High / Medium
**Context**: What I was doing when issue occurred

**What I've Tried**:
1. Action 1 - Result
2. Action 2 - Result
3. Action 3 - Result

**Specific Question**: What decision/guidance do I need?

**Relevant Files**:
- File 1: path/to/file (lines X-Y)
- File 2: path/to/file (lines X-Y)

**Logs** (if applicable):
```
[Paste relevant error logs]
```

**Recommended Next Steps** (my opinion):
- Option A: [description]
- Option B: [description]
```

**Example**:
```markdown
## Escalation: Context Extraction Validation Failing 30% of Time

**Issue**: LLM extraction returns invalid JSON 3 out of 10 test runs
**Impact**: Blocks Day 1 completion (need 100% success rate)
**Urgency**: High
**Context**: Testing /api/ps101/extract-context with golden dataset

**What I've Tried**:
1. Refined extraction prompt (added more examples) - 70% success → 80%
2. Added Pydantic validation (catches errors) - Still fails 20%
3. Increased max_tokens from 1500 to 2000 - No improvement

**Specific Question**: Should we:
A) Activate "Wizard of Oz" fallback (manual JSON for beta users)
B) Spend more time refining prompt (risk timeline)
C) Add retry logic with prompt clarification

**Relevant Files**:
- api/ps101.py (lines 45-120) - extract_context endpoint
- mosaic_context_bridge.py (reference implementation)

**Logs**:
```
ValidationError: 1 validation error for PS101Context
  proposed_experiments.0.smallest_version
    Field required [type=missing]
```

**Recommended Next Steps**:
Option A (Wizard of Oz) - Recommended by Gemini, de-risks timeline
- Manually create JSON for 5 beta users
- Continue perfecting automation in parallel
- Validates UX while fixing technical issue
```

---

### Follow-Up After Escalation

**Once guidance received:**

1. ✅ Acknowledge receipt
2. ✅ Clarify any uncertainties
3. ✅ Implement guidance
4. ✅ Report back when resolved
5. ✅ Document decision in IMPLEMENTATION_REFINEMENT doc

**Example**:
```markdown
## Escalation Resolution: Context Extraction Validation

**Guidance Received**: Activate Wizard of Oz fallback (Human + Gemini approved)
**Implementation**:
- Created manual_context_creation.py script
- Processed 5 beta user PS101 responses manually
- Stored in user_contexts table
- Unblocked Day 2 work

**Parallel Work**:
- Continue refining extraction prompt
- Target: 100% automation before Day 3

**Status**: RESOLVED - Day 2 can proceed
```

---

## 1️⃣2️⃣ CHANGE LOG (This Document)

### v2.0.0-mvp (2025-12-02) - CURRENT

**Purpose**: Consolidate all protocol documents for MVP sprint

**Changes**:
- ✅ Integrated MVP sprint protocols (3-day implementation)
- ✅ Added version tracking standards (inline docs, file headers)
- ✅ Consolidated role definitions (5 team members: Claude Code, Gemini, OPUS, GPT-4, Claude Desktop)
- ✅ Added deployment checklists (pre/post validation)
- ✅ Added rollback procedures (3-step process)
- ✅ Added sacred patterns (context manager, PostgreSQL syntax, error logging, idempotency, Pydantic validation)
- ✅ Added database patterns (schema v2, migration management)
- ✅ Added troubleshooting guide (quick triage, common issues)
- ✅ Added escalation protocols (decision matrix, format)

**Supersedes**:
- CODEX_INSTRUCTIONS.md (all versions)
- OPERATIONS_MANUAL.md v1.0
- CODEX_HANDOFF_*.md (all dates)
- Protocol fragments in START_HERE.md (retained but superseded)

**Authority**: This document is now the single source of truth

---

### v1.0.0 (2025-10-10) - Historical

**Purpose**: Initial protocol documentation

**Changes**:
- Initial role definitions (3-AI system)
- Basic deployment procedures
- Handoff protocols

**Status**: Superseded by v2.0.0-mvp

---

## 1️⃣3️⃣ RELATED DOCUMENTS

### DO Read These (Current & Active)

**For Current MVP Sprint:**
- `MOSAIC_MVP_IMPLEMENTATION/IMPLEMENTATION_REFINEMENT_Claude-Gemini.md` - Detailed 3-day sprint plan with decisions
- `MOSAIC_MVP_IMPLEMENTATION/WIMD_MVP_Analysis_Complete.md` - Strategic foundation (Opus's MVP analysis)
- `MOSAIC_MVP_IMPLEMENTATION/mosaic_context_bridge.py` - Production code reference

**For Technical Details:**
- `TROUBLESHOOTING_CHECKLIST.md` - Error classification dashboard, debugging workflows
- `SELF_DIAGNOSTIC_FRAMEWORK.md` - Architecture-specific error prevention

**For Current State:**
- `START_HERE.md` - Session initialization (still active, but protocol details superseded by this doc)
- `CLAUDE.md` - Current production architecture overview
- `docs/README.md` - Deployment configuration

---

### DO NOT Read These (Historical / Superseded)

**Superseded by This Document:**
- CODEX_INSTRUCTIONS.md (all copies in root, docs/, frontend/docs/, backend/, mosaic_ui/)
- OPERATIONS_MANUAL.md v1.0 (all copies)
- CODEX_HANDOFF_2025-09-30.md through CODEX_HANDOFF_2025-10-09.md (all dates)
- CODEX_HANDOVER_KIT.md (all copies)
- PROTOCOL_ENFORCEMENT_PLAN.md
- Any document referencing "SQLite" (we use PostgreSQL now)

**If Contradiction**: This document (TEAM_PLAYBOOK.md) wins.

---

## 1️⃣4️⃣ DOCUMENT MAINTENANCE

### When to Update This Document

**Immediate update required if:**
- New team member added
- Critical pattern changes (e.g., database connection method)
- New sprint starts (update Current Sprint Status)
- Major architectural change
- Protocol violation causes production incident

**Update process:**
1. Claude Code proposes change in PR format
2. Gemini reviews for consistency
3. Human approves
4. Update version in header (v2.1.0, v2.2.0, etc.)
5. Update CHANGE LOG section
6. Announce to team in Claude Desktop

---

### Review Cadence

**Every sprint start** (currently: every 3 days):
- Review Current Sprint Status section
- Update sprint-specific documentation pointers
- Archive completed sprint docs

**Every month**:
- Review role definitions (still accurate?)
- Review sacred patterns (still relevant?)
- Review escalation protocols (working well?)

**After major incident**:
- Document incident in troubleshooting guide
- Add new pattern if needed
- Update rollback procedures if gaps found

---

## 📞 QUICK REFERENCE CARD (Print This)

```
┌─────────────────────────────────────────────────────────┐
│  MOSAIC TEAM PLAYBOOK - QUICK REFERENCE                │
│  Version: 2.0.0-mvp                                     │
│  Updated: 2025-12-02                                    │
└─────────────────────────────────────────────────────────┘

🚨 STARTING A SESSION?
  → Read Quick Start (Section 1)
  → Check Current Sprint Status (Section 2)
  → Review your role's "MUST READ" items

💻 WRITING CODE?
  → Sacred patterns MUST be followed (Section 5)
  → Context manager: with get_conn() as conn:
  → PostgreSQL syntax: %s not ?, SERIAL not AUTOINCREMENT
  → Explicit logging: No bare except:
  → Pydantic validation for LLM responses

🚀 DEPLOYING?
  → Complete checklist (Section 8)
  → Create backup FIRST
  → Update version tracking
  → Test locally
  → Get human approval

🔥 PRODUCTION BROKEN?
  → Rollback immediately (Section 9)
  → Investigate after restoration
  → Document in START_HERE.md

❓ STUCK OR BLOCKED?
  → Troubleshooting guide (Section 10)
  → Escalation protocols (Section 11)
  → Don't wait >2 hours to escalate

📋 REMEMBER:
  ✅ This doc supersedes ALL other protocol docs
  ✅ If contradiction → THIS ONE WINS
  ✅ Version tracking is mandatory
  ✅ Sacred patterns protect production
  ✅ Rollback first, investigate second

┌─────────────────────────────────────────────────────────┐
│  CONTACT: See Section 3 for role-based escalation      │
└─────────────────────────────────────────────────────────┘
```

---

**END OF TEAM PLAYBOOK**

**Remember**:
- ✅ Read this every session start
- ✅ Follow sacred patterns always
- ✅ Create backups before changes
- ✅ Rollback first if production breaks
- ✅ Escalate when stuck

**Status**: 🔒 **CANONICAL - SINGLE SOURCE OF TRUTH**
