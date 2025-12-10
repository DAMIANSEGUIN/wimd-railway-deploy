# MCP v1.1 Integration — Team Review Summary

**Document Metadata:**
- Created: 2025-12-09 by Claude Code
- Audience: Codex (ChatGPT), Gemini, and all AI agents
- Status: REVIEW REQUIRED - DO NOT IMPLEMENT YET
- Full Plan: See `docs/MCP_V1_1_INTEGRATION_PLAN.md`

---

## 🎯 Quick Context

Damian has provided **Mosaic MCP v1.1** files for integration. This represents a **fundamental architecture change** to how we (AI agents) manage memory, context, and coordination.

**Current State:** Mosaic Governance v1.1.2 (file-based, manual coordination)
**Proposed State:** Mosaic MCP v1.1 (MCP servers, supervisor agents, automated context)

**Your Task:** Review this summary + the full integration plan, identify concerns, and provide feedback **BEFORE** any implementation begins.

---

## 📦 What We Received

**Location:** `docs/mosaic_mcp_v1_1/`

**Contents:**
- `README.md` - Master overview (7 lines)
- `00_bootstrap/` - Bootstrap kit, supervisor agent, MCP framework docs (all placeholders)
- `01_config/` - 4 empty JSON files (constraints, agent roles, retrieval triggers, summarization schema)

**Status:** ⚠️ **Skeleton only** - Documentation has placeholder references to "earlier conversation blocks" but no actual content. Config files are empty `{}`.

---

## 🔍 What MCP v1.1 Proposes to Change

### 1. **Memory & Context Management**
- **Current:** Agents load `.md` governance files each session manually
- **Proposed:** Agents query MCP servers for context dynamically
- **Impact:** Changes how we access governance, troubleshooting guides, etc.

### 2. **Agent Coordination**
- **Current:** Manual handoff notes between agents (honor system)
- **Proposed:** Supervisor agent routes tasks, enforces agent roles
- **Impact:** Changes how we coordinate across ChatGPT/Claude/Gemini

### 3. **Session Initialization**
- **Current:** `./scripts/start_session.sh` → load macro → read 5 governance files
- **Proposed:** Bootstrap kit → supervisor agent → MCP server queries
- **Impact:** Changes how sessions start and context is loaded

### 4. **Configuration-Driven Governance**
- **Current:** Hardcoded governance rules in markdown files
- **Proposed:** JSON-defined constraints, roles, retrieval triggers, summarization schemas
- **Impact:** More flexible but requires JSON schema design

---

## ⚠️ Key Concerns Identified

### Critical Questions (Need Answers Before Proceeding)

**Architecture:**
1. **Where do MCP servers run?** (Railway? Local? Separate service?)
2. **How do agents connect to MCP?** (HTTP API? WebSocket? Local socket?)
3. **What happens if MCP servers are down?** (Fallback to files? Fail?)
4. **Does this violate "LOCAL AUTHORITATIVE" principle?** (3-layer architecture: LOCAL → GDRIVE MASTER → MIRROR)

**Memory/Context:**
5. **What happens to existing `.md` governance files?** (Deprecated? Migrated? Parallel?)
6. **How does MCP retrieval replace current file loading?** (What's the API?)
7. **Who defines retrieval triggers?** (Human? Agents? Hardcoded?)
8. **How is context persistence handled?** (Database? Cache? Session-based?)

**Agent Coordination:**
9. **How does supervisor agent work with Claude Code CLI?** (Claude runs locally, not in ChatGPT)
10. **How does ChatGPT (Mirror) coordinate with MCP?** (Can ChatGPT query MCP servers?)
11. **How does Gemini (API mode) fit into MCP architecture?** (Broker script changes?)
12. **What happens when multiple agents work simultaneously?** (Race conditions? Locking?)

**Configuration:**
13. **What should go in `constraints.json`?** (Schema undefined)
14. **What should go in `agent_roles.json`?** (Schema undefined)
15. **What should go in `retrieval_triggers.json`?** (Schema undefined)
16. **What should go in `summarization_schema.json`?** (Schema undefined)

**Migration/Rollback:**
17. **Can we run v1.1.2 and MCP v1.1 in parallel?** (Gradual migration strategy)
18. **What's the rollback procedure if MCP breaks workflows?** (Emergency revert)
19. **How do we test MCP without disrupting production?** (Staging environment?)
20. **What's the timeline for migration?** (Weeks? Months?)

---

## 🚩 Potential Conflicts Identified

### 1. **File-Based vs. MCP-Based Context**
- **Current:** Agents read `TROUBLESHOOTING_CHECKLIST.md` directly from filesystem
- **MCP v1.1:** Agents query MCP server for troubleshooting context
- **Conflict:** Need to maintain both during transition? What's the truth source?

### 2. **Session Start Protocol**
- **Current:** `start_session.sh` → `UPDATED_SESSION_START_MACRO_v1.1.2.md` → load 5 files
- **MCP v1.1:** Bootstrap kit → supervisor agent → MCP queries
- **Conflict:** Two different initialization paths, which takes precedence?

### 3. **Agent Coordination**
- **Current:** ChatGPT manually writes handoff notes, Claude manually reads them
- **MCP v1.1:** Supervisor agent automatically routes tasks
- **Conflict:** How do we transition from manual to automated? Who supervises supervisor?

### 4. **Governance Truth Source**
- **Current:** LOCAL markdown files are authoritative (3-layer: LOCAL → GDRIVE MASTER → MIRROR)
- **MCP v1.1:** MCP servers hold context (where does truth live?)
- **Conflict:** Potential violation of "LOCAL AUTHORITATIVE" principle if MCP becomes truth source

### 5. **Infrastructure Dependency**
- **Current:** Zero external dependencies for governance (just read files)
- **MCP v1.1:** Requires MCP servers running (new infrastructure)
- **Conflict:** What happens if servers unavailable? Agents can't load context?

---

## 🎨 Proposed Integration Strategies (Draft)

### Option A: Parallel Operation (Conservative)
- Keep v1.1.2 intact, add MCP layer on top
- Test with one agent first (Claude Code)
- Gradual migration over weeks/months
- **Pros:** Low risk, easy rollback
- **Cons:** Dual maintenance burden

### Option B: Clean Migration (Aggressive)
- Freeze v1.1.2, implement MCP v1.1 completely
- Migrate all governance to MCP format
- Cut over in single deployment
- **Pros:** Clean architecture, no dual system
- **Cons:** High risk, harder rollback

### Option C: Hybrid (Pragmatic - RECOMMENDED)
- Implement MCP for *new* features only (session persistence, inter-agent messaging)
- Keep existing governance files as-is
- Use MCP for coordination layer only
- **Pros:** Balanced risk, incremental value
- **Cons:** May not realize full MCP benefits

---

## ✅ Your Review Tasks

### For Codex (ChatGPT - Mirror Agent)
**Background:** You work from GDrive Mirror (read-only), summarize governance docs for team.

**Questions:**
1. How does MCP affect your GDrive Mirror reads?
2. Can ChatGPT query MCP servers from your context? (or just file reads?)
3. What happens to your governance document summaries if MCP holds context?
4. How do you handle MCP server unavailability?
5. What concerns do you have about supervisor agent model?

**Action:** Review full plan at `docs/MCP_V1_1_INTEGRATION_PLAN.md`, respond with concerns/questions.

---

### For Gemini (API Mode Agent)
**Background:** You work via API mode with broker scripts, parallel to Claude/ChatGPT.

**Questions:**
1. How does API mode interact with MCP architecture?
2. What changes needed to your broker scripts (`agent_send.sh`, `agent_receive.sh`)?
3. How do you authenticate to MCP servers?
4. What's your rollback procedure if MCP breaks your workflow?
5. Can you coordinate with supervisor agent from API mode context?

**Action:** Review full plan at `docs/MCP_V1_1_INTEGRATION_PLAN.md`, respond with concerns/questions.

---

### For All Agents (Including Claude Code)
**General Questions:**
1. Do you understand what MCP v1.1 proposes to change?
2. What concerns do you have about this integration?
3. What questions need answering before we proceed?
4. What's missing from this plan?
5. What's your recommended approach (Option A/B/C/other)?

**Critical:** Do NOT implement anything until:
- [ ] Full team review completed
- [ ] All critical questions answered
- [ ] Config JSON schemas defined
- [ ] Migration strategy approved
- [ ] Rollback plan tested

---

## 📋 Next Steps

### Immediate (This Week)
1. **All agents:** Review full integration plan
2. **All agents:** Submit concerns/questions/recommendations
3. **Claude Code:** Expand placeholder bootstrap docs with actual content (if available)
4. **Human (Damian):** Clarify strategic goals for MCP integration

### Before Implementation (Required)
1. Populate all 4 empty config JSON files with schemas
2. Answer all 20 critical questions above
3. Define success criteria for MCP integration
4. Create comprehensive rollback plan
5. Set up staging/test environment for MCP prototype
6. Get approval from all agents + human

### Implementation (Future - NOT NOW)
1. TBD based on team review outcomes

---

## 📎 Resources

**Full Integration Plan:** `docs/MCP_V1_1_INTEGRATION_PLAN.md` (detailed analysis, 200+ lines)

**MCP v1.1 Files:** `docs/mosaic_mcp_v1_1/` (skeleton structure, needs population)

**Current Governance (v1.1.2):**
- `META_GOVERNANCE_CANON_MVP_v1.0.md`
- `GLOBAL_META_INSTRUCTION_v2.0.md`
- `MOSAIC_CODESTYLE_CODEX_MVP_v1.0.md`
- `MOSAIC_CODEX_ELITE_BENCHMARK_ADDENDUM_v1.1.2.md`
- `UPDATED_SESSION_START_MACRO_v1.1.2.md`
- `TROUBLESHOOTING_CHECKLIST.md`
- `SELF_DIAGNOSTIC_FRAMEWORK.md`

**Session Start:** `./scripts/start_session.sh` (currently active v1.1.2 protocol)

---

## 🚨 Final Reminder

**DO NOT IMPLEMENT YET.**

This is a **DISCOVERY AND PLANNING PHASE**. We need full team consensus before making architectural changes this significant.

Your thoughtful review and feedback are critical to ensuring we don't break existing workflows or violate governance principles.

---

**END OF TEAM REVIEW SUMMARY**

**Status:** Awaiting responses from Codex, Gemini, and human approval.
