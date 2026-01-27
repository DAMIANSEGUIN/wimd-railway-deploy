# Cross-Agent Solution Implementation Guide

**Created:** 2026-01-05 by Claude Code
**Purpose:** Concrete steps to fix cross-agent coordination
**Prerequisite:** Read `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md` first

---

## 🎯 THE SOLUTION: Three-Tier State Management

### Overview

**Problem:** Two agents, two file systems, one repository.

**Solution:** Three-tier state management with path-agnostic JSON + relative-path markdown + git as sync layer.

```
Tier 1: Machine State (.mosaic/*.json)     ← Single source of truth
   ↓
Tier 2: Human Context (*.md)               ← Documentation with relative paths
   ↓
Tier 3: Git Sync Layer                     ← Synchronization between agents
```

---

## 📋 IMPLEMENTATION PLAN

### Phase 1: Create Path-Agnostic State Files (30 minutes)

**Files to create in `.mosaic/` directory:**

#### File 1: `.mosaic/current_task.json`

```json
{
  "version": 1,
  "task_id": "mosaic-render-deploy-2026-01-05",
  "objective": "Fix cross-agent coordination and deploy Render services",
  "status": "blocked",
  "priority": "critical",
  "assigned_agent": "pending_user_decision",
  "created_at": "2026-01-05T00:00:00Z",
  "updated_at": "2026-01-05T00:00:00Z",
  "details": {
    "description": "Enable both Claude Code (Desktop) and Claude (Cursor) to work on the same repository without path conflicts. Deploy Mosaic platform to Render.",
    "success_criteria": [
      "Both agents can read the same state files",
      "All documentation uses relative paths",
      "Render backend deployed and responding",
      "Render frontend deployed and responding"
    ],
    "dependencies": [
      "User decision on deployment strategy",
      "Render CLI linking resolution",
      "Documentation consolidation approval"
    ]
  }
}
```

#### File 2: `.mosaic/blockers.json`

```json
{
  "version": 1,
  "updated_at": "2026-01-05T00:00:00Z",
  "blockers": [
    {
      "id": "B001",
      "title": "File Path Divergence",
      "severity": "critical",
      "status": "active",
      "description": "Claude Code sees /home/user/wimd-render-deploy, Claude (Cursor) sees /Users/damianseguin/WIMD-Deploy-Project",
      "impact": "Cross-agent coordination impossible",
      "solution": "Use relative paths only + .mosaic/ JSON state",
      "owner": "both_agents",
      "created_at": "2026-01-05T00:00:00Z"
    },
    {
      "id": "B002",
      "title": "Render Deployment Timeout",
      "severity": "high",
      "status": "active",
      "description": "render up times out due to 45MB upload size limit",
      "impact": "Cannot deploy via CLI",
      "solution": "Switch to GitHub-based deployment OR implement .renderignore",
      "owner": "user_decision_required",
      "created_at": "2025-12-15T00:00:00Z"
    },
    {
      "id": "B003",
      "title": "Render CLI Linking Ambiguity",
      "severity": "high",
      "status": "active",
      "description": "render list shows project, but render link fails with 'Project not found'",
      "impact": "Cannot use Render CLI commands",
      "solution": "User manual link via interactive CLI OR switch to GitHub deployment",
      "owner": "user_intervention_required",
      "created_at": "2025-12-15T00:00:00Z"
    },
    {
      "id": "B004",
      "title": "Documentation Overload",
      "severity": "medium",
      "status": "active",
      "description": "131 session-related docs + 500+ total markdown files",
      "impact": "Agents confused about canonical state",
      "solution": "Archive pre-2025-12-01 docs, consolidate to ~20 active docs",
      "owner": "user_approval_required",
      "created_at": "2026-01-05T00:00:00Z"
    }
  ]
}
```

#### File 3: `.mosaic/agent_state.json`

```json
{
  "version": 1,
  "last_agent": "claude_code_desktop",
  "last_mode": "DIAGNOSE",
  "last_session_end": "2026-01-05T00:00:00Z",
  "last_commit": "26bea5b",
  "next_agent": "claude_cursor",
  "handoff_message": "Created cross-agent assessment and solution docs. Waiting for user decisions on 4 items: path handling, doc consolidation, state system, deployment strategy.",
  "open_questions": [
    "Which deployment strategy? (GitHub-based vs CLI)",
    "Approve documentation archive?",
    "Use .mosaic/*.json as canonical state?"
  ]
}
```

#### File 4: `.mosaic/session_log.jsonl` (append-only)

```jsonl
{"timestamp":"2026-01-05T00:00:00Z","agent":"claude_code_desktop","mode":"DIAGNOSE","action":"analyzed_documentation_systems","files_read":["AI_START_HERE.txt","CLAUDE.md","SESSION_RESUME_PROMPT.md","Mosaic_Governance_Core_v1.md"],"outcome":"identified_path_divergence_issue"}
{"timestamp":"2026-01-05T00:01:00Z","agent":"claude_code_desktop","mode":"BUILD","action":"created_cross_agent_assessment","files_created":["CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md"],"outcome":"comprehensive_assessment_ready"}
{"timestamp":"2026-01-05T00:02:00Z","agent":"claude_code_desktop","mode":"BUILD","action":"created_solution_implementation","files_created":["CROSS_AGENT_SOLUTION_IMPLEMENTATION.md"],"outcome":"implementation_guide_ready"}
```

---

### Phase 2: Update CLAUDE.md to Use Relative Paths (5 minutes)

**Current (BROKEN):**

```markdown
**🚨 MANDATORY FIRST ACTION ON EVERY SESSION:**

```bash
Read: /Users/damianseguin/WIMD-Deploy-Project/.ai-agents/SESSION_RESUME_PROMPT.md
```
```

**Replacement (PATH-AGNOSTIC):**

```markdown
**🚨 MANDATORY FIRST ACTION ON EVERY SESSION:**

```bash
# Step 1: Read canonical state (path-agnostic, works for all agents)
cat .mosaic/current_task.json
cat .mosaic/blockers.json
cat .mosaic/agent_state.json

# Step 2: Read cross-agent assessment
cat CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md

# Step 3: Enter INIT mode and confirm task
# (See TEAM_PLAYBOOK_v2.md Section 3 for INIT protocol)
```

**Read these files in order (all relative paths):**
1. `.mosaic/current_task.json` (Current objective)
2. `.mosaic/blockers.json` (Known blockers)
3. `.mosaic/agent_state.json` (Last agent state)
4. `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md` (Full context)
5. `Mosaic_Governance_Core_v1.md` (Governance rules)
```

---

### Phase 3: Create Cross-Agent Protocol (10 minutes)

**File:** `.ai-agents/CROSS_AGENT_PROTOCOL.md`

```markdown
# Cross-Agent Protocol

**Version:** 1.0
**Applies to:** All AI agents (Claude Code, Claude Cursor, Gemini, ChatGPT)

## Rule 1: All Paths Must Be Relative

**NEVER use:**
- `/Users/damianseguin/...` (macOS-specific)
- `/home/user/...` (Linux container-specific)
- `C:\Users\...` (Windows-specific)

**ALWAYS use:**
- `.ai-agents/FILE.md` (relative to repo root)
- `./scripts/deploy.sh` (relative to current directory)
- `../docs/README.md` (relative traversal)

## Rule 2: State is in .mosaic/

**Before reading any documentation, read these in order:**
1. `.mosaic/current_task.json` (what are we doing?)
2. `.mosaic/blockers.json` (what's blocking us?)
3. `.mosaic/agent_state.json` (who was here last?)

## Rule 3: Update State on Every HANDOFF

**When entering HANDOFF mode, update these files:**
1. `.mosaic/agent_state.json` (your agent name, mode, handoff message)
2. `.mosaic/session_log.jsonl` (append one JSON line)
3. `.mosaic/blockers.json` (add/remove/update blockers)
4. `.mosaic/current_task.json` (update status, if changed)

## Rule 4: Commit State Changes

**After updating .mosaic/ files:**
```bash
git add .mosaic/
git commit -m "chore(state): Update agent state [AGENT_NAME]"
git push origin HEAD
```

## Rule 5: Verify Sync Before Starting

**At session start, verify you have latest state:**
```bash
git pull origin $(git branch --show-current)
cat .mosaic/agent_state.json
```

## Rule 6: No New Session Docs

**NEVER create:**
- `SESSION_HANDOFF_2026-XX-XX.md`
- `SESSION_SUMMARY_2026-XX-XX.md`
- `NEXT_SESSION_PROMPT.md`

**INSTEAD update:**
- `.mosaic/agent_state.json`
- `.mosaic/session_log.jsonl`
```

---

### Phase 4: Archive Stale Documentation (20 minutes)

**Script:** `scripts/archive_stale_docs.sh`

```bash
#!/bin/bash
# Archive all session docs older than 2025-12-01

ARCHIVE_DIR="docs_archive/sessions_2025"
CUTOFF_DATE="2025-12-01"

mkdir -p "$ARCHIVE_DIR"

# Find and move stale session docs
find . -maxdepth 1 -name "SESSION*.md" -type f | while read file; do
  file_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || stat -c "%y" "$file" | cut -d' ' -f1)

  if [[ "$file_date" < "$CUTOFF_DATE" ]]; then
    echo "Archiving $file (dated $file_date)"
    mv "$file" "$ARCHIVE_DIR/"
  fi
done

# Same for .ai-agents/ directory
find .ai-agents/ -name "SESSION*.md" -type f | while read file; do
  file_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || stat -c "%y" "$file" | cut -d' ' -f1)

  if [[ "$file_date" < "$CUTOFF_DATE" ]]; then
    echo "Archiving $file (dated $file_date)"
    mkdir -p "$ARCHIVE_DIR/.ai-agents/"
    mv "$file" "$ARCHIVE_DIR/.ai-agents/"
  fi
done

echo "Archive complete: $(ls -1 $ARCHIVE_DIR | wc -l) files moved"
```

**Run:**
```bash
chmod +x scripts/archive_stale_docs.sh
./scripts/archive_stale_docs.sh
```

---

### Phase 5: Create Documentation Map (15 minutes)

**File:** `DOCUMENTATION_MAP.md`

```markdown
# Mosaic Documentation Map

**Last Updated:** 2026-01-05
**Purpose:** Single source of truth for all active documentation

## Tier 1: State (Machine-Readable)

| File | Purpose | Updated By | Format |
|------|---------|------------|--------|
| `.mosaic/current_task.json` | Active NEXT_TASK | Agents in HANDOFF | JSON |
| `.mosaic/blockers.json` | Known blockers | Agents in HANDOFF | JSON |
| `.mosaic/agent_state.json` | Last agent state | Agents in HANDOFF | JSON |
| `.mosaic/session_log.jsonl` | Session history | Agents in HANDOFF | JSONL |
| `.mosaic/authority_map.json` | Service definitions | User/Architect | JSON |
| `.mosaic/session_start.json` | Canonical commit | System | JSON |

## Tier 2: Governance (Human + Machine)

| File | Purpose | Last Updated | Status |
|------|---------|--------------|--------|
| `ENGINEERING_PRINCIPLES.md` | P01-P05 principles | 2025-12-06 | ACTIVE |
| `Mosaic_Governance_Core_v1.md` | State machine rules | 2025-12-11 | ACTIVE |
| `TEAM_PLAYBOOK_v2.md` | Operational contract | 2025-12-11 | ACTIVE |
| `SESSION_END_OPTIONS.md` | 7 termination commands | 2025-12-05 | ACTIVE |
| `SELF_DIAGNOSTIC_FRAMEWORK.md` | Error taxonomy | 2025-12-06 | ACTIVE |
| `TROUBLESHOOTING_CHECKLIST.md` | Diagnostic filters | 2025-12-06 | ACTIVE |

## Tier 3: Architecture & Implementation

| File | Purpose | Last Updated | Status |
|------|---------|--------------|--------|
| `CLAUDE.md` | Project overview | 2025-12-10 | ACTIVE |
| `DEPLOYMENT_TRUTH.md` | Deployment reference | 2025-11-25 | ACTIVE |
| `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md` | Current state | 2026-01-05 | ACTIVE |
| `CROSS_AGENT_SOLUTION_IMPLEMENTATION.md` | This file | 2026-01-05 | ACTIVE |
| `.ai-agents/CROSS_AGENT_PROTOCOL.md` | Agent coordination | 2026-01-05 | ACTIVE |

## Tier 4: Archived (Reference Only)

| Directory | Contents | Archive Date |
|-----------|----------|--------------|
| `docs_archive/sessions_2025/` | Session docs pre-2025-12-01 | 2026-01-05 |
| `deprecated/` | Governance v1 | 2025-12-06 |
| `backups/` | Emergency backups | Various |

## Reading Order for New Agents

1. `.mosaic/current_task.json`
2. `.mosaic/blockers.json`
3. `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md`
4. `Mosaic_Governance_Core_v1.md`
5. `TEAM_PLAYBOOK_v2.md`
6. `ENGINEERING_PRINCIPLES.md`
7. Project-specific docs (CLAUDE.md, etc.)
```

---

## 🧪 VALIDATION TESTS

### Test 1: Cross-Agent File Access

**For Claude Code (Desktop):**
```bash
cat .mosaic/current_task.json
# Should return valid JSON
```

**For Claude (Cursor):**
```bash
cat .mosaic/current_task.json
# Should return SAME JSON as Claude Code
```

**Success Criteria:** Both agents see identical content.

---

### Test 2: Relative Path Resolution

**For both agents:**
```bash
# Test 1: Read from root
cat CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md | head -5

# Test 2: Read from subdirectory
cat .ai-agents/CROSS_AGENT_PROTOCOL.md | head -5

# Test 3: Verify no absolute paths in docs
grep -r "/Users/damianseguin" *.md .ai-agents/*.md
# Should return NOTHING

grep -r "/home/user" *.md .ai-agents/*.md
# Should return NOTHING (except this file as example)
```

**Success Criteria:** No absolute paths found.

---

### Test 3: State Update Round-Trip

**Agent A (Claude Code) writes state:**
```bash
# Update agent_state.json
cat > .mosaic/agent_state.json <<EOF
{
  "version": 1,
  "last_agent": "claude_code_desktop",
  "last_mode": "VERIFY",
  "last_session_end": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_commit": "$(git rev-parse --short HEAD)",
  "next_agent": "claude_cursor",
  "handoff_message": "Test message for cross-agent validation"
}
EOF

# Commit and push
git add .mosaic/agent_state.json
git commit -m "test(state): Agent A writes state"
git push origin HEAD
```

**Agent B (Claude Cursor) reads state:**
```bash
# Pull latest
git pull origin $(git branch --show-current)

# Read state
cat .mosaic/agent_state.json | jq '.handoff_message'
# Should output: "Test message for cross-agent validation"
```

**Success Criteria:** Agent B sees Agent A's message.

---

### Test 4: Documentation Archival

**Run archival script:**
```bash
./scripts/archive_stale_docs.sh
```

**Verify:**
```bash
# Count remaining session docs
find . -maxdepth 1 -name "SESSION*.md" | wc -l
# Should be < 10

# Count archived docs
find docs_archive/sessions_2025/ -name "*.md" | wc -l
# Should be > 50
```

**Success Criteria:** Old docs archived, root directory clean.

---

## 🚀 DEPLOYMENT: Choosing Render Strategy

### Option A: GitHub-Based Deployment (RECOMMENDED)

**Advantages:**
- No 45MB upload limit
- Standard Render practice
- Easier to debug (deployment logs in dashboard)
- Works from any machine (no CLI needed)

**Implementation:**

1. **In Render Dashboard:**
   - Go to project: `wimd-career-coaching`
   - Click service: `mosaic-backend` (or create new)
   - Settings → Connect to GitHub repo
   - Select: `DAMIANSEGUIN/wimd-render-deploy`
   - Branch: `main`
   - Root directory: `/` (or `/api` if backend is in subdirectory)

2. **Deploy:**
   ```bash
   # From local machine (any agent)
   git add .
   git commit -m "feat: Deploy backend to Render"
   git push origin main

   # Render automatically deploys
   # Check deployment in Render dashboard
   ```

3. **Verify:**
   ```bash
   # Wait 2-5 minutes for deploy
   curl https://mosaic-backend.up.render.app/health
   # Should return: {"ok": true, ...}
   ```

**User Action Required:**
- Connect GitHub repo in Render dashboard
- Configure environment variables (DATABASE_URL, API keys, etc.)

---

### Option B: Fix CLI Deployment (Fallback)

**Advantages:**
- Deploy from local machine
- Faster iteration (no git push needed)

**Disadvantages:**
- 45MB upload limit
- Requires Render CLI linking fix
- Only works from one machine

**Implementation:**

1. **Create comprehensive `.renderignore`:**
   ```
   .git/
   .venv/
   venv/
   node_modules/
   __pycache__/
   .pytest_cache/
   .mypy_cache/
   docs_archive/
   backups/
   *.md
   .ai-agents/
   deprecated/
   temp_governance_docs/
   ```

2. **Fix Render CLI linking:**
   ```bash
   # Manual link via interactive prompt
   render link
   # Select: wimd-career-coaching
   # Select service: mosaic-backend
   ```

3. **Deploy:**
   ```bash
   render up
   # Should upload < 45MB now
   ```

**User Action Required:**
- Run `render link` interactively
- Test upload size: `render up --dry-run`

---

## 📊 IMPLEMENTATION CHECKLIST

### Phase 1: Create State Files ✅
- [ ] `.mosaic/current_task.json` created
- [ ] `.mosaic/blockers.json` created
- [ ] `.mosaic/agent_state.json` created
- [ ] `.mosaic/session_log.jsonl` created (empty is OK)

### Phase 2: Update CLAUDE.md ✅
- [ ] Removed absolute paths (`/Users/damianseguin/...`)
- [ ] Added `.mosaic/` read instructions
- [ ] Uses only relative paths

### Phase 3: Create Protocol ✅
- [ ] `.ai-agents/CROSS_AGENT_PROTOCOL.md` created
- [ ] 6 rules documented
- [ ] Example commands included

### Phase 4: Archive Docs ✅
- [ ] `scripts/archive_stale_docs.sh` created
- [ ] Script executed
- [ ] Docs moved to `docs_archive/sessions_2025/`
- [ ] Root directory has < 20 active docs

### Phase 5: Documentation Map ✅
- [ ] `DOCUMENTATION_MAP.md` created
- [ ] All active docs listed
- [ ] Reading order specified

### Phase 6: Validation ✅
- [ ] Test 1: Both agents read same JSON ✅
- [ ] Test 2: No absolute paths in docs ✅
- [ ] Test 3: State update round-trip works ✅
- [ ] Test 4: Archival script works ✅

### Phase 7: Render Deployment ⏳
- [ ] User chooses Option A or B
- [ ] Render configured (GitHub or CLI)
- [ ] Backend deployed
- [ ] Frontend deployed
- [ ] Health checks pass

---

## 🎯 SUCCESS CRITERIA

**Implementation is complete when:**

1. ✅ Both agents can read `.mosaic/*.json` files
2. ✅ All documentation uses relative paths only
3. ✅ No references to `/Users/...` or `/home/user/...` exist
4. ✅ Session docs are archived (< 20 active docs in root)
5. ✅ `DOCUMENTATION_MAP.md` lists all active docs
6. ✅ Render deployment succeeds (backend + frontend)
7. ✅ Cross-agent state update round-trip works
8. ✅ User approves all 4 decisions (D1-D4)

**Next session should:**
- Start with reading `.mosaic/*.json`
- No longer have path divergence issues
- Have clear canonical state
- Be able to execute deployment

---

## 🔄 AGENT HANDOFF TEMPLATE

**Use this template when ending a session:**

```json
{
  "version": 1,
  "last_agent": "YOUR_AGENT_NAME (claude_code_desktop | claude_cursor | gemini | chatgpt)",
  "last_mode": "YOUR_CURRENT_MODE (INIT | BUILD | DIAGNOSE | REPAIR | VERIFY | HANDOFF)",
  "last_session_end": "TIMESTAMP (ISO 8601)",
  "last_commit": "GIT_COMMIT_HASH (short)",
  "next_agent": "NEXT_AGENT_NAME (or 'user_decision')",
  "handoff_message": "Brief summary of what you did and what's next",
  "open_questions": [
    "List any questions for user",
    "Or next agent"
  ]
}
```

**Example:**

```json
{
  "version": 1,
  "last_agent": "claude_code_desktop",
  "last_mode": "HANDOFF",
  "last_session_end": "2026-01-05T12:00:00Z",
  "last_commit": "abc1234",
  "next_agent": "claude_cursor",
  "handoff_message": "Created .mosaic/ state system and cross-agent protocol. Ready for doc archival and Render deployment.",
  "open_questions": [
    "User: Choose deployment strategy (GitHub vs CLI)?",
    "User: Approve doc archival script?"
  ]
}
```

---

**END OF IMPLEMENTATION GUIDE**

**Next Steps:**
1. User reviews both assessment + solution docs
2. User makes 4 decisions (path handling, doc consolidation, state system, deployment)
3. Execute Phase 1-5 (create state files, update docs, archive)
4. Execute Phase 6 (validation tests)
5. Execute Phase 7 (Render deployment with chosen strategy)

**Status:** Ready for user approval and execution
