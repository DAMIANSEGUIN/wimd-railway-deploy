# Terminal Agent Briefing: Cross-Agent Coordination Crisis

**From:** Claude (Cursor IDE)
**To:** Claude Code (Terminal)
**Date:** 2026-01-05
**Format:** Plain text / Markdown (terminal-friendly)
**Priority:** CRITICAL - READ BEFORE ANY WORK

---

## EXECUTIVE SUMMARY

**THE PROBLEM:**
Two AI agents (you in terminal, me in Cursor) are working on the same git repository but cannot coordinate effectively because documentation contains hardcoded absolute file paths that only work in one environment.

**YOUR ENVIRONMENT:**
- Tool: Claude Code (terminal/CLI)
- Working directory: Unknown (possibly `/home/user/wimd-render-deploy` based on previous sessions)
- Access method: Terminal commands, file operations
- Limited to: Current session context, cannot see Cursor IDE

**MY ENVIRONMENT:**
- Tool: Claude (Cursor IDE)
- Working directory: `/Users/damianseguin/WIMD-Deploy-Project`
- Access method: IDE, full file tree, git integration
- Limited to: What Cursor IDE provides

**THE CORE ISSUE:**
When documentation says "Read /Users/damianseguin/.../FILE.md", you cannot read it because that path doesn't exist in your environment. When it says "Read /home/user/.../FILE.md", I cannot read it because that path doesn't exist in my environment.

**IMPACT:**
- Session handoffs break (path references fail)
- Agents cannot verify each other's work
- Project coordination impossible
- Work gets duplicated or lost

**THE SOLUTION:**
Use ONLY relative paths (e.g., `.ai-agents/FILE.md`) and create path-agnostic JSON state files in `.mosaic/` directory that both agents can read regardless of environment.

---

## CURRENT PROJECT STATE (CANONICAL)

### Repository Identity
```yaml
Repository: DAMIANSEGUIN/wimd-render-deploy
Branch: claude/start-new-session-nB5Jo
Latest Commit: 7d7ac80 (docs(handoff): Create quick-share doc for Cursor agent)
Production Tag: prod-2025-11-18 (commit: 31d099c)
Commits Ahead: 7 commits since production tag
Working Tree: Clean (all changes committed)
```

### Git Remote Configuration
```bash
origin → https://github.com/DAMIANSEGUIN/wimd-render-deploy.git
```

### Active Branch
```
claude/start-new-session-nB5Jo (pushed to remote, ready for you to pull)
```

---

## WHAT I DID (PREVIOUS SESSION IN CURSOR)

I (Claude in Cursor) completed comprehensive analysis and created solution documents:

### Document 1: CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md
**Purpose:** Full analysis of the cross-agent coordination problem
**Location:** Root directory (relative path from repo root)
**Size:** ~15 KB, ~600 lines
**Contents:**
- Root cause analysis (path divergence problem)
- Current project state inventory
- Documentation system audit (131 session docs found)
- Conflicting session start systems analysis
- Current blockers list
- 4 critical decisions user must make
- Recommended implementation plan (7 phases)
- Architectural decision: adopt `.mosaic/` as single source of truth

### Document 2: CROSS_AGENT_SOLUTION_IMPLEMENTATION.md
**Purpose:** Concrete implementation steps to fix coordination
**Location:** Root directory
**Size:** ~20 KB, ~800 lines
**Contents:**
- Three-tier state management system design
- 7-phase implementation plan with time estimates
- JSON schema for `.mosaic/` state files
- Script to archive stale documentation (archive_stale_docs.sh)
- Cross-agent protocol rules (6 mandatory rules)
- Validation tests (4 test suites)
- Render deployment options (GitHub-based vs CLI-based)
- Implementation checklist with success criteria

### Document 3: SHARE_WITH_CURSOR_AGENT.md
**Purpose:** Quick-share summary (originally intended for Cursor, but relevant context)
**Location:** Root directory
**Size:** ~8 KB, ~300 lines
**Contents:**
- One-page brief of the problem
- Key insights from analysis
- Next steps overview
- Communication protocol

### Commits Made
```
e6bea25 - docs(critical): Create cross-agent coordination assessment and solution
7d7ac80 - docs(handoff): Create quick-share doc for Cursor agent
```

### Branch Pushed
```
Branch: claude/start-new-session-nB5Jo
Status: Pushed to origin, ready for you to pull
```

---

## DOCUMENTATION CRISIS (ANALYSIS RESULTS)

### The Numbers
- **Total markdown files:** 500+ files in repository
- **Session-related docs:** 131 files with "SESSION", "START", "HANDOFF", or "RESUME" in name
- **Active governance docs:** 8 files (ENGINEERING_PRINCIPLES.md, Mosaic_Governance_Core_v1.md, TEAM_PLAYBOOK_v2.md, etc.)
- **Broken references:** 3+ files referencing non-existent paths or files

### The Problem
**Multiple overlapping session start systems exist:**

**System A: AI_START_HERE.txt**
- Last updated: 2025-12-06
- Points to: SESSION_START_v2.md ❌ DOES NOT EXIST
- Points to: .ai-agents/START_HERE.md ❌ DOES NOT EXIST
- Status: PARTIALLY BROKEN

**System B: CLAUDE.md mandate**
- Says: "Read /Users/damianseguin/.../.ai-agents/SESSION_RESUME_PROMPT.md"
- Problem: macOS-specific path, doesn't work in terminal environment
- Status: BROKEN FOR CROSS-AGENT

**System C: .mosaic/ canonical system**
- Files: session_start.json, authority_map.json
- Status: ACTIVE, path-agnostic (JSON), machine-readable
- Problem: Underutilized, not documented as primary system

**System D: SESSION_RESUME_PROMPT.md**
- Location: .ai-agents/SESSION_RESUME_PROMPT.md
- Last updated: 2025-12-15
- Content: Render reset blocker (CLI linking ambiguity)
- Status: OUTDATED, describes stale task from December

---

## CANONICAL GOVERNANCE (WHAT STILL WORKS)

### Decision Hierarchy (TEAM_PLAYBOOK_v2.md Section 5)
1. **ENGINEERING_PRINCIPLES.md** - P01-P05 principles (Singular Purpose, Declared Context, Minimal Complexity, Explicit Robustness, Syntactic Clarity)
2. **User Intent** - Damian's explicit instructions
3. **Mosaic_Governance_Core_v1.md** - State machine (INIT → BUILD → DIAGNOSE → REPAIR → VERIFY → HANDOFF)
4. **TEAM_PLAYBOOK_v2.md** - Operational contract
5. **SESSION_END_OPTIONS.md** - 7 termination commands
6. **SELF_DIAGNOSTIC_FRAMEWORK.md** - Error taxonomy
7. **TROUBLESHOOTING_CHECKLIST.md** - Diagnostic filters

### Active State Machine (Mosaic_Governance_Core_v1.md)
```
Modes: INIT → BUILD → DIAGNOSE → REPAIR → VERIFY → HANDOFF

Current mode (this session): HANDOFF (me) → INIT (you)
```

### .mosaic/ System (Path-Agnostic State)
```json
// .mosaic/session_start.json
{
  "version": 1,
  "ssot": "session_start",
  "canon_id": "DAMIANSEGUIN/wimd-render-deploy:main:09c8c38..."
}

// .mosaic/authority_map.json
{
  "schema_version": "1.0",
  "repo": {
    "slug": "DAMIANSEGUIN/wimd-render-deploy",
    "origin_ssh": "https://github.com/DAMIANSEGUIN/wimd-render-deploy.git",
    "deploy_branch": "main"
  },
  "services": [
    {"name": "mosaic-frontend", "platform": "render", ...},
    {"name": "mosaic-backend", "platform": "render", ...}
  ]
}
```

---

## CRITICAL BLOCKERS (PRIORITIZED)

### 🔴 CRITICAL (Blocks ALL Work)

**BLOCKER 1: File Path Divergence**
- **Description:** Documentation uses environment-specific absolute paths
- **Impact:** Cross-agent coordination impossible
- **Solution:** Use relative paths + .mosaic/ JSON state (documented in solution implementation guide)
- **Status:** Solution designed, awaiting user approval
- **Owner:** Both agents + user decision

**BLOCKER 2: User Decisions Pending**
- **Description:** 4 critical architectural decisions need user approval
- **Decisions:**
  - D1: Use relative paths only? (Recommended: YES)
  - D2: Archive 100+ old session docs? (Recommended: YES)
  - D3: Use .mosaic/*.json as canonical state? (Recommended: YES)
  - D4: Render deployment strategy - GitHub-based or CLI? (Recommended: GitHub)
- **Impact:** Cannot proceed with implementation without approval
- **Status:** Waiting for user input
- **Owner:** User (Damian)

### 🟡 HIGH PRIORITY (Blocks Deployment)

**BLOCKER 3: Render Deployment Timeout**
- **Description:** `render up` times out due to 45MB upload size limit
- **Impact:** Cannot deploy via Render CLI
- **Solution:** Switch to GitHub-based deployment OR implement comprehensive .renderignore
- **Status:** Blocked by user decision D4
- **Owner:** User decision required

**BLOCKER 4: Render CLI Linking Ambiguity**
- **Description:** `render list` shows project, but `render link` fails with "Project not found"
- **Impact:** Cannot use Render CLI commands
- **Solution:** User manual link via interactive CLI OR switch to GitHub deployment
- **Status:** Blocked by user decision D4
- **Owner:** User intervention required
- **Note:** This blocker becomes irrelevant if D4 = GitHub-based deployment

### 🟢 MEDIUM PRIORITY (Can Work Around)

**BLOCKER 5: Documentation Overload**
- **Description:** 131 session docs + 500+ total markdown files create confusion
- **Impact:** Agents waste time reading stale docs, cannot find canonical state
- **Solution:** Archive pre-2025-12-01 docs to docs_archive/sessions_2025/
- **Status:** Blocked by user decision D2
- **Owner:** Either agent can execute after approval

**BLOCKER 6: PostgreSQL Scope Unknown**
- **Description:** Unclear if PostgreSQL is service-level or project-level in Render
- **Impact:** Data loss risk if service is deleted/recreated
- **Solution:** Validate via Render CLI or dashboard before any destructive operations
- **Status:** LOW PRIORITY (only matters if we recreate Render service)
- **Owner:** Either agent, low urgency

---

## THE SOLUTION (ARCHITECTURAL DESIGN)

### Three-Tier State Management System

**Tier 1: Machine State (.mosaic/*.json)**
- **Purpose:** Path-agnostic, machine-readable canonical state
- **Files:**
  - `current_task.json` - Active NEXT_TASK (replaces markdown docs)
  - `blockers.json` - Known blockers list (replaces markdown docs)
  - `agent_state.json` - Last agent + handoff message (replaces SESSION_HANDOFF_*.md)
  - `session_log.jsonl` - Append-only session history (replaces SESSION_SUMMARY_*.md)
- **Why JSON:** Works in any environment, no path dependencies, machine-parseable, version controlled

**Tier 2: Human Context (*.md with relative paths)**
- **Purpose:** Human-readable documentation and context
- **Rules:**
  - ONLY use relative paths (e.g., `.ai-agents/FILE.md`)
  - NEVER use absolute paths (`/Users/...` or `/home/user/...`)
  - Reference files from repo root
- **Example:** "Read .ai-agents/CROSS_AGENT_PROTOCOL.md" ✅ works everywhere

**Tier 3: Git Sync Layer**
- **Purpose:** Synchronization mechanism between agents
- **Protocol:**
  1. Agent A updates .mosaic/*.json files
  2. Agent A commits and pushes to branch
  3. Agent B pulls latest commits
  4. Agent B reads .mosaic/*.json to get Agent A's state
  5. Agent B continues work from handoff point

### Cross-Agent Communication Protocol

**Agent ending session (HANDOFF mode):**
```bash
# 1. Update state
cat > .mosaic/agent_state.json <<EOF
{
  "version": 1,
  "last_agent": "YOUR_AGENT_NAME",
  "last_mode": "HANDOFF",
  "last_session_end": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_commit": "$(git rev-parse --short HEAD)",
  "next_agent": "NEXT_AGENT_NAME",
  "handoff_message": "Brief summary of what you did"
}
EOF

# 2. Append to session log
echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"agent\":\"YOUR_AGENT\",\"action\":\"completed_task\",\"outcome\":\"success\"}" >> .mosaic/session_log.jsonl

# 3. Commit state
git add .mosaic/
git commit -m "chore(state): Update agent state [YOUR_AGENT]"
git push origin HEAD
```

**Agent starting session (INIT mode):**
```bash
# 1. Pull latest state
git pull origin $(git branch --show-current)

# 2. Read state
cat .mosaic/current_task.json    # What am I doing?
cat .mosaic/blockers.json         # What's blocking me?
cat .mosaic/agent_state.json      # What did last agent do?

# 3. Enter INIT mode and confirm task
# (See TEAM_PLAYBOOK_v2.md for INIT protocol)
```

---

## 7-PHASE IMPLEMENTATION PLAN (DETAILED)

### PHASE 1: Create Path-Agnostic State Files (30 minutes)

**Create .mosaic/current_task.json:**
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
    "description": "Enable both Claude Code (Terminal) and Claude (Cursor) to work on the same repository without path conflicts. Deploy Mosaic platform to Render.",
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

**Create .mosaic/blockers.json:**
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
      "description": "Claude Code (terminal) and Claude (Cursor) see different absolute paths",
      "solution": "Use relative paths only + .mosaic/ JSON state",
      "owner": "both_agents"
    },
    {
      "id": "B002",
      "title": "Render Deployment Timeout",
      "severity": "high",
      "status": "active",
      "description": "render up times out due to 45MB upload size limit",
      "solution": "Switch to GitHub-based deployment OR .renderignore",
      "owner": "user_decision_required"
    },
    {
      "id": "B003",
      "title": "Render CLI Linking Ambiguity",
      "severity": "high",
      "status": "active",
      "description": "render link fails with 'Project not found'",
      "solution": "User manual link OR GitHub deployment",
      "owner": "user_intervention_required"
    },
    {
      "id": "B004",
      "title": "Documentation Overload",
      "severity": "medium",
      "status": "active",
      "description": "131 session docs + 500+ total files",
      "solution": "Archive pre-2025-12-01 docs",
      "owner": "user_approval_required"
    }
  ]
}
```

**Create .mosaic/agent_state.json:**
```json
{
  "version": 1,
  "last_agent": "claude_cursor",
  "last_mode": "HANDOFF",
  "last_session_end": "2026-01-05T00:00:00Z",
  "last_commit": "7d7ac80",
  "next_agent": "claude_code_terminal",
  "handoff_message": "Created cross-agent assessment and solution docs. Pushed to branch claude/start-new-session-nB5Jo. Waiting for user decisions on 4 items.",
  "open_questions": [
    "D1: Use relative paths only?",
    "D2: Archive old session docs?",
    "D3: Use .mosaic/*.json as canonical state?",
    "D4: Render deployment strategy?"
  ]
}
```

**Create .mosaic/session_log.jsonl:**
```jsonl
{"timestamp":"2026-01-05T00:00:00Z","agent":"claude_cursor","mode":"DIAGNOSE","action":"analyzed_documentation_systems","outcome":"identified_path_divergence"}
{"timestamp":"2026-01-05T00:01:00Z","agent":"claude_cursor","mode":"BUILD","action":"created_assessment_docs","files":["CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md","CROSS_AGENT_SOLUTION_IMPLEMENTATION.md","SHARE_WITH_CURSOR_AGENT.md"],"outcome":"comprehensive_documentation_ready"}
{"timestamp":"2026-01-05T00:02:00Z","agent":"claude_cursor","mode":"HANDOFF","action":"pushed_to_branch","branch":"claude/start-new-session-nB5Jo","outcome":"ready_for_terminal_agent"}
```

### PHASE 2: Update CLAUDE.md (5 minutes)

**Replace this section in CLAUDE.md:**
```markdown
**🚨 MANDATORY FIRST ACTION ON EVERY SESSION:**

```bash
Read: /Users/damianseguin/WIMD-Deploy-Project/.ai-agents/SESSION_RESUME_PROMPT.md
```
```

**With this:**
```markdown
**🚨 MANDATORY FIRST ACTION ON EVERY SESSION:**

```bash
# Step 1: Read canonical state (path-agnostic)
cat .mosaic/current_task.json
cat .mosaic/blockers.json
cat .mosaic/agent_state.json

# Step 2: Read cross-agent assessment
cat CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md
```

**Read these files in order (all relative paths):**
1. `.mosaic/current_task.json` - Current objective
2. `.mosaic/blockers.json` - Known blockers
3. `.mosaic/agent_state.json` - Last agent state
4. `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md` - Full context
5. `Mosaic_Governance_Core_v1.md` - Governance rules
```

### PHASE 3: Create Cross-Agent Protocol (10 minutes)

**Create .ai-agents/CROSS_AGENT_PROTOCOL.md:**
```markdown
# Cross-Agent Protocol

**Version:** 1.0
**Applies to:** Claude Code (Terminal) and Claude (Cursor)

## Rule 1: All Paths Must Be Relative
- NEVER: `/Users/damianseguin/...` or `/home/user/...`
- ALWAYS: `.ai-agents/FILE.md` or `./scripts/deploy.sh`

## Rule 2: State is in .mosaic/
- Before any work: Read .mosaic/current_task.json, .mosaic/blockers.json, .mosaic/agent_state.json

## Rule 3: Update State on HANDOFF
- Update .mosaic/agent_state.json
- Append to .mosaic/session_log.jsonl
- Commit and push

## Rule 4: Commit State Changes
```bash
git add .mosaic/
git commit -m "chore(state): Update agent state [AGENT_NAME]"
git push origin HEAD
```

## Rule 5: Verify Sync Before Starting
```bash
git pull origin $(git branch --show-current)
cat .mosaic/agent_state.json
```

## Rule 6: No New Session Docs
- DON'T create: SESSION_HANDOFF_*.md
- DO update: .mosaic/agent_state.json
```

### PHASE 4: Archive Stale Docs (20 minutes)

**Create scripts/archive_stale_docs.sh:**
```bash
#!/bin/bash
# Archive all session docs older than 2025-12-01

ARCHIVE_DIR="docs_archive/sessions_2025"
CUTOFF_DATE="2025-12-01"
mkdir -p "$ARCHIVE_DIR"

find . -maxdepth 1 -name "SESSION*.md" -type f | while read file; do
  file_date=$(stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1)
  if [[ "$file_date" < "$CUTOFF_DATE" ]]; then
    echo "Archiving $file"
    mv "$file" "$ARCHIVE_DIR/"
  fi
done

echo "Archive complete"
```

**Run it:**
```bash
chmod +x scripts/archive_stale_docs.sh
./scripts/archive_stale_docs.sh
```

### PHASE 5: Create Documentation Map (15 minutes)

**Create DOCUMENTATION_MAP.md** (see CROSS_AGENT_SOLUTION_IMPLEMENTATION.md for full content)

### PHASE 6: Validation Tests (10 minutes)

**Test 1: Cross-agent file access**
```bash
cat .mosaic/current_task.json
# Should return valid JSON
```

**Test 2: No absolute paths**
```bash
grep -r "/Users/damianseguin" *.md .ai-agents/*.md
grep -r "/home/user" *.md .ai-agents/*.md
# Should return nothing
```

**Test 3: State update round-trip** (requires coordination with other agent)

### PHASE 7: Render Deployment (30 minutes)

**Option A: GitHub-Based (RECOMMENDED)**
```bash
# User configures in Render dashboard:
# - Connect GitHub repo: DAMIANSEGUIN/wimd-render-deploy
# - Branch: main
# - Root directory: /

# Then deploy via git:
git push origin main
# Render auto-deploys
```

**Option B: CLI-Based (if user chooses)**
```bash
# Create .renderignore
# Fix render link
# render up
```

---

## 4 CRITICAL USER DECISIONS NEEDED

### D1: Path Handling Strategy
- **Question:** Use relative paths only in all documentation?
- **Recommendation:** YES
- **Impact:** Enables cross-agent coordination
- **User decision:** [ ] PENDING

### D2: Documentation Consolidation
- **Question:** Archive 100+ old session docs (pre-2025-12-01)?
- **Recommendation:** YES
- **Impact:** Reduces confusion, keeps only ~20 active docs
- **User decision:** [ ] PENDING

### D3: Canonical State System
- **Question:** Use .mosaic/*.json as single source of truth?
- **Recommendation:** YES
- **Impact:** Path-agnostic state, machine-readable, version controlled
- **User decision:** [ ] PENDING

### D4: Render Deployment Strategy
- **Question:** GitHub-based or CLI-based deployment?
- **Recommendation:** GitHub-based (avoids 45MB timeout, standard practice)
- **Impact:** Determines how we deploy to production
- **User decision:** [ ] PENDING

---

## IMMEDIATE ACTIONS FOR YOU (CLAUDE CODE TERMINAL)

### Step 1: Verify Access (2 minutes)
```bash
# Confirm you're in the right repo
git remote -v | grep wimd-render-deploy

# Check current branch
git branch --show-current

# Pull latest commits from Cursor agent
git pull origin claude/start-new-session-nB5Jo
```

### Step 2: Read Assessment Docs (15 minutes)
```bash
# Read the full assessment
cat CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md | less

# Read the solution implementation
cat CROSS_AGENT_SOLUTION_IMPLEMENTATION.md | less

# Read current state
cat .mosaic/session_start.json
cat .mosaic/authority_map.json
```

### Step 3: Verify Understanding (5 minutes)
Answer these questions for the user:
- Can you read the assessment docs?
- Do you agree with the analysis?
- Can you execute the 7-phase implementation plan?
- What is your current working directory? (run `pwd`)

### Step 4: Await User Decisions
- Wait for user to answer D1-D4
- Do NOT proceed with implementation until approved

---

## SUCCESS CRITERIA

**This coordination fix is successful when:**

1. ✅ Both agents can read .mosaic/*.json files
2. ✅ No documentation contains absolute paths
3. ✅ Session handoffs work via git commits
4. ✅ Both agents can update state and see each other's changes
5. ✅ Render backend deployed and responding
6. ✅ Render frontend deployed and responding

---

## VALIDATION COMMANDS

**Run these to verify everything works:**

```bash
# Verify git sync
git log --oneline -3
# Should show commits from Cursor agent

# Verify you can read state files
cat .mosaic/session_start.json
cat .mosaic/authority_map.json

# Verify no absolute paths in key docs
grep "/Users/damianseguin" CLAUDE.md
# Should return nothing

# Verify relative paths work
cat .ai-agents/CROSS_AGENT_PROTOCOL.md
# Should display file contents
```

---

## QUICK REFERENCE

**Essential files to read (in order):**
1. This file (TERMINAL_AGENT_BRIEFING.md)
2. CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md
3. CROSS_AGENT_SOLUTION_IMPLEMENTATION.md
4. .mosaic/session_start.json
5. Mosaic_Governance_Core_v1.md

**Commands you'll need:**
```bash
# Sync with other agent
git pull origin claude/start-new-session-nB5Jo

# Read state
cat .mosaic/current_task.json
cat .mosaic/blockers.json
cat .mosaic/agent_state.json

# Update state (when your session ends)
# See Phase 1 for JSON templates

# Commit state
git add .mosaic/
git commit -m "chore(state): Update [YOUR_AGENT]"
git push origin HEAD
```

---

## WARNINGS

### ⚠️ DO NOT:
- Create new SESSION_*.md files (use .mosaic/ instead)
- Use absolute paths in any documentation
- Deploy to Render without user approval on D4
- Skip reading the two comprehensive assessment docs
- Assume your file paths work for Cursor agent

### ✅ DO:
- Use relative paths exclusively
- Update .mosaic/ files at session end
- Commit state changes to git
- Wait for user decisions on D1-D4
- Coordinate with Cursor agent via git

---

## APPENDIX: .mosaic/ FILE SCHEMAS

### current_task.json Schema
```typescript
{
  version: 1,
  task_id: string,              // Unique identifier
  objective: string,            // What we're trying to achieve
  status: "pending" | "active" | "blocked" | "completed",
  priority: "low" | "medium" | "high" | "critical",
  assigned_agent: string,       // Which agent owns this
  created_at: ISO8601,
  updated_at: ISO8601,
  details: {
    description: string,
    success_criteria: string[],
    dependencies: string[]
  }
}
```

### blockers.json Schema
```typescript
{
  version: 1,
  updated_at: ISO8601,
  blockers: [
    {
      id: string,               // B001, B002, etc.
      title: string,
      severity: "low" | "medium" | "high" | "critical",
      status: "active" | "resolved" | "deferred",
      description: string,
      impact: string,
      solution: string,
      owner: string,
      created_at: ISO8601
    }
  ]
}
```

### agent_state.json Schema
```typescript
{
  version: 1,
  last_agent: "claude_cursor" | "claude_code_terminal" | "gemini" | "chatgpt",
  last_mode: "INIT" | "BUILD" | "DIAGNOSE" | "REPAIR" | "VERIFY" | "HANDOFF",
  last_session_end: ISO8601,
  last_commit: string,          // Git commit hash (short)
  next_agent: string,
  handoff_message: string,
  open_questions: string[]
}
```

### session_log.jsonl Schema (one JSON per line)
```typescript
{
  timestamp: ISO8601,
  agent: string,
  mode: string,
  action: string,
  files_read?: string[],
  files_created?: string[],
  files_modified?: string[],
  outcome: string
}
```

---

**END OF TERMINAL AGENT BRIEFING**

**Status:** Ready for your review and execution
**Next Action:** Read assessment docs, verify sync, await user decisions
**Coordinator:** Claude (Cursor) - available for questions via user relay
