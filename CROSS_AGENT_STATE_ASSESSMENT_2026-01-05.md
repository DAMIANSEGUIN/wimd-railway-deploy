# Cross-Agent State Assessment: Mosaic Platform (2026-01-05)

**Created:** 2026-01-05 by Claude Code (Claude Desktop)
**Purpose:** Enable coordination between Claude Code (Desktop) and Claude (Cursor)
**Critical Issue:** File access divergence preventing effective cross-agent collaboration

---

## 🚨 CRITICAL FILE ACCESS DIVERGENCE PROBLEM

### The Problem

**Two AI agents are operating on the same repository with DIFFERENT file system paths:**

- **Claude Code (Desktop):** `/home/user/wimd-railway-deploy` (Linux container)
- **Claude (Cursor):** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project` (macOS local)

**Impact:**
- Documentation references break across agents
- Session handoffs include wrong paths
- Agents cannot verify each other's work
- Project coordination is impossible

### Immediate Evidence

```bash
# Claude Code sees:
pwd → /home/user/wimd-railway-deploy

# User's system (Cursor agent) sees:
# /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

# Git remote shows proxy:
origin → http://local_proxy@127.0.0.1:55743/git/DAMIANSEGUIN/wimd-railway-deploy
```

**This is NOT the same as the GitHub remote, indicating Claude Code is operating in a sandboxed/containerized environment.**

---

## 📊 CURRENT PROJECT STATE (Canonical)

### Repository Identity

```yaml
Repository: DAMIANSEGUIN/wimd-railway-deploy
Branch: claude/start-new-session-nB5Jo
Current Commit: 26bea5b (WIP: Pre-enforcement cleanup)
Production Tag: prod-2025-11-18 (commit: 31d099c)
Working Tree: Clean (no uncommitted changes)
Commits Ahead: 5 commits ahead of production tag
```

### Canonical Governance System

**System:** Mosaic Governance Core v1 (.mosaic/ directory)

```json
// .mosaic/session_start.json
{
  "version": 1,
  "ssot": "session_start",
  "canon_id": "DAMIANSEGUIN/wimd-railway-deploy:main:09c8c38326a363660cef7610558bfddc65fc5539"
}

// .mosaic/authority_map.json
{
  "schema_version": "1.0",
  "repo": {
    "slug": "DAMIANSEGUIN/wimd-railway-deploy",
    "origin_ssh": "https://github.com/DAMIANSEGUIN/wimd-railway-deploy.git",
    "deploy_branch": "main"
  },
  "services": [
    {
      "name": "mosaic-frontend",
      "platform": "railway",
      "railway_project": "wimd-career-coaching",
      "railway_service": "mosaic-frontend"
    },
    {
      "name": "mosaic-backend",
      "platform": "railway",
      "railway_project": "wimd-career-coaching",
      "railway_service": "mosaic-backend"
    }
  ]
}
```

### Active Governance Documents (Tier 1)

**Decision Hierarchy (TEAM_PLAYBOOK_v2.md Section 5):**

1. `ENGINEERING_PRINCIPLES.md` (P01-P05: Singular Purpose, Declared Context, Minimal Complexity, Explicit Robustness, Syntactic Clarity)
2. User Intent
3. `Mosaic_Governance_Core_v1.md` (State machine: INIT → BUILD → DIAGNOSE → REPAIR → VERIFY → HANDOFF)
4. `TEAM_PLAYBOOK_v2.md` (Operational contract for all agents)
5. `SESSION_END_OPTIONS.md` (7 termination commands)
6. `SELF_DIAGNOSTIC_FRAMEWORK.md` (Error taxonomy and auto-triage)
7. `TROUBLESHOOTING_CHECKLIST.md` (Quick diagnostic filters)
8. `RECURRING_BLOCKERS.md` (Known obstacles - if exists)

### Documentation Inventory

**Total markdown files:** 500+ files
**Session-related docs:** 131 files
**.ai-agents/ docs:** 99 files

**This is documentation overload - multiple overlapping systems.**

---

## 🗂️ CONFLICTING SESSION START SYSTEMS (Root Cause Analysis)

### System A: AI_START_HERE.txt (Governance v2)

**Location:** Root directory
**Last Updated:** 2025-12-06
**Points to:**
- `Mosaic_Governance_Core_v1.md` ✅ EXISTS
- `TEAM_PLAYBOOK_v2.md` ✅ EXISTS
- `SESSION_START_v2.md` ❌ DOES NOT EXIST
- `SESSION_END_OPTIONS.md` ✅ EXISTS
- `.ai-agents/START_HERE.md` ❌ DOES NOT EXIST

**Status:** Partially broken - references missing files

### System B: CLAUDE.md Mandate

**Location:** Root directory
**Last Updated:** 2025-12-10
**Mandatory first action:**

```
Read: /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/SESSION_RESUME_PROMPT.md
```

**Problem:** This path is macOS-specific and DOES NOT WORK in Claude Code's Linux container.

**Actual file location (Claude Code):** `/home/user/wimd-railway-deploy/.ai-agents/SESSION_RESUME_PROMPT.md`

**Status:** Broken for cross-agent coordination

### System C: .mosaic/ Canonical System

**Location:** `.mosaic/` directory
**Last Updated:** 2025-12-06 (commit 09c8c38)
**Status:** Active but underutilized
**Files:**
- `session_start.json` - Canonical commit ID
- `authority_map.json` - Service definitions

**This is the ONLY system that is path-agnostic and machine-readable.**

### System D: SESSION_RESUME_PROMPT.md (Task-Specific)

**Location:** `.ai-agents/SESSION_RESUME_PROMPT.md`
**Last Updated:** 2025-12-15
**Content:** Railway Reset blocker (CLI linking ambiguity)
**Status:** Outdated - describes a stale task

---

## 🧩 CURRENT BLOCKERS (From Analysis)

### From SESSION_RESUME_PROMPT.md (Dec 15):

1. **Railway CLI Linking Ambiguity** - `railway list` sees project, `railway link` fails
2. **User Approval Missing** - Railway reset not approved
3. **PostgreSQL Scope Unknown** - Data loss risk unclear
4. **Service Name Undecided** - New service naming TBD

### From SESSION_HANDOFF_2025-12-15.md:

1. **Railway Deployment Timeout** - `railway up` exceeds 45MB upload limit
2. **Deployment Strategy Shift Needed** - Move from CLI to GitHub-based deploy

### From Recent Commits (Dec 2025):

1. **Governance Enforcement In Progress** - Commits show WIP state
2. **NARs Testing Handoff** - Testing documentation created but not executed
3. **Session Start Broken** - Multiple references to `/Users/damianseguin/...` paths

---

## 📋 RECOMMENDED IMPLEMENTATION PLAN

### Phase 1: Fix Cross-Agent Coordination (CRITICAL - Do First)

**Objective:** Enable both agents to access the same canonical state without path dependencies.

**Actions:**

1. **Create Path-Agnostic Session Start System**
   - Use `.mosaic/session_start.json` as single source of truth
   - All documentation uses relative paths from repo root (e.g., `.ai-agents/FILE.md`)
   - Never use absolute paths in handoff documents

2. **Create Canonical Session Start File**
   - File: `SESSION_START.md` (root directory)
   - Content: Auto-generated from `.mosaic/` JSON files
   - Updated by agents at session end using `HANDOFF` mode

3. **Update CLAUDE.md**
   - Remove macOS-specific path: `/Users/damianseguin/...`
   - Replace with: `Read: SESSION_START.md` (relative path)

4. **Create Cross-Agent Handoff Protocol**
   - File: `.ai-agents/CROSS_AGENT_PROTOCOL.md`
   - Define how agents communicate via git-committed files
   - Mandate relative paths only

### Phase 2: Consolidate Documentation

**Objective:** Reduce 131 session files to a single canonical system.

**Actions:**

1. **Archive Stale Documentation**
   - Move all files dated before 2025-12-01 to `docs_archive/`
   - Keep only active governance docs in root

2. **Create Documentation Map**
   - File: `DOCUMENTATION_MAP.md`
   - List all active docs with purpose and last update
   - Identify duplicates for deletion

3. **Implement Session State in .mosaic/**
   - Create `current_task.json` (replaces NEXT_TASK text docs)
   - Create `blockers.json` (machine-readable blocker list)
   - Create `session_log.jsonl` (append-only session history)

### Phase 3: Resolve Railway Deployment

**Objective:** Get the platform deployed and operational.

**Choose ONE deployment strategy:**

**Option A: GitHub-Based Deploy (Recommended)**
- Configure Railway service to watch GitHub repo
- Push commits to trigger deploys
- No local CLI upload needed
- Avoids 45MB timeout issue

**Option B: Fix CLI Deploy**
- Implement comprehensive `.railwayignore`
- Reduce upload size below 45MB
- Continue using `railway up`

**User decision required.**

---

## 🔧 IMMEDIATE ACTIONS FOR NEXT SESSION

### For Claude (Cursor):

1. **Read this file:** `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md`
2. **Verify file access:** Confirm you can access `.mosaic/session_start.json`
3. **Check path:** Is your working directory `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project`?
4. **Propose solution:** How should we handle the path divergence?

### For User (Damian):

1. **Verify git sync:** Ensure both agents see the same commits
2. **Choose deployment strategy:** Option A (GitHub) or Option B (CLI)?
3. **Approve consolidation plan:** Can we archive 100+ stale docs?
4. **Answer:** Should we create `.mosaic/current_task.json` as canonical state?

### For Both Agents (Coordination):

1. **Use relative paths:** All documentation uses paths relative to repo root
2. **Commit state changes:** After every session, commit state to `.mosaic/`
3. **Read .mosaic/ first:** Always check `.mosaic/session_start.json` before reading legacy docs
4. **Update this file:** Mark sections complete as work progresses

---

## 📐 ARCHITECTURAL DECISION: CANONICAL STATE SYSTEM

### Recommendation: Adopt .mosaic/ as Single Source of Truth

**Why:**

1. **Path-Agnostic:** JSON files work in any environment
2. **Machine-Readable:** No parsing ambiguity like markdown
3. **Version Controlled:** Git tracks all state changes
4. **Atomic Updates:** JSON can be validated before commit
5. **Already Exists:** System partially implemented (authority_map, session_start)

**Proposed .mosaic/ Structure:**

```
.mosaic/
├── authority_map.json       # Service definitions (EXISTS)
├── session_start.json        # Canonical commit (EXISTS)
├── current_task.json         # Active NEXT_TASK (NEW)
├── blockers.json             # Known blockers (NEW)
├── session_log.jsonl         # Append-only history (NEW)
└── agent_state.json          # Last agent + mode (NEW)
```

**Migration Path:**

1. Create new JSON files
2. Update CLAUDE.md to read from `.mosaic/`
3. Agents update JSON at session end
4. Archive old markdown session docs
5. Keep governance docs (TEAM_PLAYBOOK, etc.) as markdown

---

## 🧪 VALIDATION CHECKLIST

### Cross-Agent Coordination Test

**Test 1: File Access Parity**
- [ ] Claude Code can read `.mosaic/session_start.json`
- [ ] Claude (Cursor) can read `.mosaic/session_start.json`
- [ ] Both agents see the same file content

**Test 2: Relative Path Resolution**
- [ ] Documentation uses only relative paths (`.ai-agents/FILE.md`)
- [ ] No references to `/Users/damianseguin/...`
- [ ] No references to `/home/user/...`

**Test 3: State Synchronization**
- [ ] Agent A commits state to `.mosaic/current_task.json`
- [ ] Agent B reads state from `.mosaic/current_task.json`
- [ ] State matches exactly

### Documentation Consolidation Test

**Test 4: Single Entry Point**
- [ ] One canonical session start file exists
- [ ] All governance docs reference it
- [ ] No conflicting session start instructions

**Test 5: Archival Complete**
- [ ] Stale docs moved to `docs_archive/`
- [ ] Active docs <= 20 files in root
- [ ] `DOCUMENTATION_MAP.md` lists all active docs

---

## 📝 DECISION LOG

### Decision 1: Path Handling Strategy

**Options:**
- A) Use relative paths only (`.ai-agents/FILE.md`)
- B) Use environment variables (`$REPO_ROOT/.ai-agents/FILE.md`)
- C) Use symbolic links to normalize paths

**Recommendation:** Option A (relative paths)
**Rationale:** Simplest, works in all environments, no setup required
**User Decision:** [ ] PENDING

### Decision 2: Documentation Consolidation

**Options:**
- A) Archive all pre-2025-12-01 docs, keep ~20 active docs
- B) Delete all session docs, keep only governance docs
- C) Keep everything, create index

**Recommendation:** Option A (archive old, keep ~20)
**Rationale:** Preserves history, reduces confusion, enables audits
**User Decision:** [ ] PENDING

### Decision 3: Canonical State System

**Options:**
- A) Use `.mosaic/*.json` for all state (recommended)
- B) Use markdown with strict relative paths
- C) Use both (JSON for state, markdown for context)

**Recommendation:** Option C (hybrid)
**Rationale:** JSON for machine state, markdown for human context
**User Decision:** [ ] PENDING

### Decision 4: Railway Deployment Strategy

**Options:**
- A) GitHub-based deploy (no CLI upload)
- B) Fix CLI deploy with `.railwayignore`
- C) Use Railway CLI for backend, GitHub for frontend

**Recommendation:** Option A (GitHub-based)
**Rationale:** Avoids 45MB timeout, standard practice, easier to debug
**User Decision:** [ ] PENDING

---

## 🔗 QUICK REFERENCE

### Essential Files (Read These First)

1. **This file:** `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md`
2. **Governance:** `Mosaic_Governance_Core_v1.md`
3. **Operational:** `TEAM_PLAYBOOK_v2.md`
4. **Engineering:** `ENGINEERING_PRINCIPLES.md`
5. **State:** `.mosaic/session_start.json`

### Commands for Both Agents

```bash
# Verify you're in the right repo
git remote -v | grep wimd-railway-deploy

# Check current commit
git log --oneline -1

# Read canonical state
cat .mosaic/session_start.json

# List active blockers (when implemented)
cat .mosaic/blockers.json
```

### Cross-Agent Communication Protocol

**Agent A (Claude Code) ending session:**
1. Enter HANDOFF mode
2. Update `.mosaic/agent_state.json` with summary
3. Commit changes to branch
4. Push to origin

**Agent B (Claude Cursor) starting session:**
1. Pull latest commits
2. Read `.mosaic/agent_state.json`
3. Enter INIT mode
4. Confirm NEXT_TASK from `.mosaic/current_task.json`

---

## 📊 METRICS & STATUS

**Documentation Health:**
- Total docs: 500+ files ⚠️ (too many)
- Session docs: 131 files ⚠️ (redundant)
- Active governance: 8 files ✅ (good)
- Broken references: 3+ files ❌ (needs fix)

**Coordination Health:**
- Path-agnostic docs: 2 files ✅ (.mosaic/*.json)
- Path-dependent docs: 129+ files ❌ (broken cross-agent)
- Relative path docs: 0 files ❌ (needs creation)

**Blocker Status:**
- Railway deployment: BLOCKED (timeout + strategy unclear)
- CLI linking: BLOCKED (ambiguity unresolved)
- User approvals: BLOCKED (4 decisions pending)
- Cross-agent coordination: BLOCKED (path divergence)

---

## ⚠️ CRITICAL WARNINGS

### Warning 1: Do Not Create More Session Docs

**Problem:** 131 session-related docs already exist. Creating more adds to confusion.

**Solution:** Update `.mosaic/session_log.jsonl` instead of creating new markdown files.

### Warning 2: Do Not Use Absolute Paths

**Problem:** `/Users/damianseguin/...` only works on user's Mac. `/home/user/...` only works in Claude Code container.

**Solution:** Use relative paths from repo root: `.ai-agents/FILE.md`

### Warning 3: Do Not Skip .mosaic/ Update

**Problem:** If agents don't commit state to `.mosaic/`, the next agent has stale context.

**Solution:** Make `.mosaic/` update mandatory in HANDOFF mode (enforce via git hook).

### Warning 4: Do Not Deploy Without User Approval

**Problem:** Railway reset has data loss risk. Deployment strategy is unclear.

**Solution:** Wait for user to answer Decision 4 before any Railway commands.

---

## 🎯 SUCCESS CRITERIA

**This assessment is successful if:**

1. ✅ Both agents can read this file
2. ✅ User understands the path divergence problem
3. ✅ User makes 4 pending decisions (D1-D4)
4. ✅ Agents agree on next actions
5. ✅ No new session docs are created (use .mosaic/ instead)

**Next session should start with:**
- Read this file
- Read `.mosaic/session_start.json`
- Confirm decisions D1-D4
- Execute Phase 1 actions

---

**END OF ASSESSMENT**

**Status:** Ready for user review and cross-agent coordination
**Next Update:** After user decisions + Phase 1 completion
**Maintainer:** Both Claude Code and Claude (Cursor) - update collaboratively
