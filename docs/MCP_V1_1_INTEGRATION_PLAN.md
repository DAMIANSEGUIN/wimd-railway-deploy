# Mosaic MCP v1.1 Integration Plan — DRAFT FOR TEAM REVIEW

**Document Metadata:**

- Created: 2025-12-09 by Claude Code
- Status: DRAFT - PENDING TEAM REVIEW
- Impact Level: CRITICAL - Full project reconfiguration required
- Location: docs/mosaic_mcp_v1_1/

---

## 🚨 ATTENTION ALL AI AGENTS

**DO NOT IMPLEMENT** any changes from this plan until:

1. Full team review completed
2. Conflicts identified and resolved
3. Migration strategy approved
4. Rollback plan documented

This is a **DISCOVERY AND PLANNING PHASE ONLY**.

---

## Executive Summary

Mosaic MCP v1.1 introduces a **Model Context Protocol (MCP)** architecture that fundamentally changes how AI agents:

- Maintain memory and context across sessions
- Coordinate with each other (supervisor/worker model)
- Retrieve and summarize governance documents
- Enforce constraints and agent roles

**Current State:** Mosaic Governance v1.1.2 (file-based, session macros, manual agent coordination)

**Target State:** Mosaic MCP v1.1 (MCP servers, supervisor agent, automated context retrieval)

**Risk Assessment:** HIGH - This is a foundational architecture change affecting all AI agent workflows.

---

## Phase 1: Discovery (IN PROGRESS)

### 1.1 Files Received and Placed

**Location:** `/docs/mosaic_mcp_v1_1/`

```
mosaic_mcp_v1_1/
├── README.md
├── 00_bootstrap/
│   ├── MOSAIC_MCP_BOOTSTRAP_KIT.md (placeholder - references missing content)
│   ├── SUPERVISOR_AGENT.md (placeholder - references missing content)
│   └── MCP_FRAMEWORK.md (placeholder - references missing content)
└── 01_config/
    ├── constraints.json (empty - needs population)
    ├── agent_roles.json (empty - needs population)
    ├── retrieval_triggers.json (empty - needs population)
    └── summarization_schema.json (empty - needs population)
```

**Status:** ⚠️ Documentation placeholders only, no actual implementation content or schemas yet.

### 1.2 Current Governance Architecture Inventory

**Active Governance Documents (v1.1.2):**

- `META_GOVERNANCE_CANON_MVP_v1.0.md` - Core governance principles
- `GLOBAL_META_INSTRUCTION_v2.0.md` - Global agent instructions
- `MOSAIC_CODESTYLE_CODEX_MVP_v1.0.md` - Code style rules
- `MOSAIC_CODEX_ELITE_BENCHMARK_ADDENDUM_v1.1.2.md` - Quality benchmarks
- `UPDATED_SESSION_START_MACRO_v1.1.2.md` - Session initialization sequence
- `TROUBLESHOOTING_CHECKLIST.md` - Error prevention & debugging
- `SELF_DIAGNOSTIC_FRAMEWORK.md` - Architecture-specific error handling
- `CLAUDE.md` - Main project documentation
- `DEPLOYMENT_TRUTH.md` - Deployment procedures

**Current Session Start Flow:**

1. Run `./scripts/start_session.sh`
2. Agent loads `UPDATED_SESSION_START_MACRO_v1.1.2.md`
3. Macro references 5 core governance files
4. Agent confirms MODE: OPTION A active
5. Agent acknowledges 3-layer architecture (LOCAL → GDRIVE MASTER → GDRIVE MIRROR)

**Current Memory/Context Strategy:**

- File-based: All context loaded from markdown files each session
- No persistent memory across sessions
- No inter-agent communication protocol
- Manual handoff notes (e.g., `HANDOFF_NOTE_CLAUDE_CODE_2025-11-24.md`)

---

## Phase 2: Gap Analysis (NEXT STEP)

### 2.1 Key Questions to Answer

**Architecture:**

- How does MCP server architecture fit with current Railway/Netlify deployment?
- Where do MCP servers run? (local? Railway? separate service?)
- How do supervisor agents coordinate with Claude Code CLI?
- What happens to current session start scripts?

**Memory & Context:**

- How does MCP context retrieval replace current file loading?
- What happens to existing governance markdown files?
- How are retrieval triggers defined and monitored?
- What's the migration path for existing context?

**Agent Coordination:**

- How does supervisor agent model replace current manual handoffs?
- What's the protocol for Claude Code ↔ ChatGPT coordination?
- How are agent roles enforced vs. current honor system?
- What happens when multiple agents work simultaneously?

**Configuration:**

- What should go in `constraints.json`?
- How do we define agent roles in `agent_roles.json`?
- What triggers should be in `retrieval_triggers.json`?
- What schema for `summarization_schema.json`?

**Rollback Strategy:**

- Can we run MCP v1.1 and v1.1.2 in parallel during migration?
- What's the quick rollback procedure if MCP breaks workflows?
- How do we preserve existing governance during transition?

### 2.2 Potential Conflicts (Preliminary)

**File-Based vs. MCP-Based Context:**

- Current: Agents read `.md` files directly
- MCP v1.1: Agents query MCP servers for context
- Conflict: Need to maintain both during transition?

**Session Start Protocol:**

- Current: `./scripts/start_session.sh` → loads macro → reads files
- MCP v1.1: Bootstrap kit → supervisor agent → MCP servers
- Conflict: Two different initialization paths

**Agent Coordination:**

- Current: Manual handoff notes, no enforcement
- MCP v1.1: Supervisor agent routes tasks, enforces roles
- Conflict: Need supervisor agent infrastructure

**Governance Truth Source:**

- Current: Local markdown files are authoritative
- MCP v1.1: MCP servers hold context, unclear where truth lives
- Conflict: Could violate "LOCAL AUTHORITATIVE" principle

---

## Phase 3: Integration Strategy (TO BE DESIGNED)

### 3.1 Proposed Approach (Draft)

**Option A: Parallel Operation (Conservative)**

1. Keep existing v1.1.2 governance intact
2. Stand up MCP servers alongside
3. Add MCP layer on top of existing files
4. Test with one agent (Claude Code) first
5. Gradual migration once proven stable
6. Deprecate old system only when fully validated

**Option B: Clean Migration (Aggressive)**

1. Freeze current governance state (tag/snapshot)
2. Implement MCP v1.1 completely
3. Migrate all governance docs to MCP format
4. Update all session scripts
5. Train all agents on new protocol
6. Cut over in single deployment

**Option C: Hybrid (Pragmatic - RECOMMENDED)**

1. Implement MCP servers for *new* memory/context features
2. Keep existing governance files as-is
3. Use MCP for inter-agent communication only
4. Use MCP for session persistence (new capability)
5. Leave session start macros unchanged
6. Gradual enhancement over time

### 3.2 Critical Path Items

**Before Any Implementation:**

- [ ] Full team review of this plan
- [ ] Populate empty config JSON files with actual schemas
- [ ] Expand placeholder bootstrap docs with full content
- [ ] Identify which MCP features we actually need vs. nice-to-have
- [ ] Define success criteria for MCP integration
- [ ] Create comprehensive rollback plan
- [ ] Test MCP concept with minimal prototype first

**Infrastructure Needs:**

- [ ] Where do MCP servers run? (Railway service? Local? Separate?)
- [ ] How do agents connect to MCP servers? (HTTP? WebSocket? Local socket?)
- [ ] What's the authentication model for MCP access?
- [ ] How do we handle MCP server downtime/unavailability?
- [ ] What's the backup/recovery strategy for MCP-stored context?

**Documentation Needs:**

- [ ] MCP server setup guide
- [ ] Updated session start protocol (v2.0)
- [ ] Agent role definitions and enforcement rules
- [ ] Context retrieval trigger catalog
- [ ] Summarization schema documentation
- [ ] Troubleshooting guide for MCP issues
- [ ] Migration playbook for each agent type

---

## Phase 4: Risk Mitigation (TO BE DEVELOPED)

### 4.1 Known Risks

**HIGH RISK:**

- Breaking existing agent workflows during migration
- Loss of context/memory if MCP servers fail
- Violating "LOCAL AUTHORITATIVE" principle of 3-layer architecture
- Increased complexity without clear benefit
- Dependency on external MCP infrastructure

**MEDIUM RISK:**

- Learning curve for all AI agents (Claude, ChatGPT, Gemini)
- Potential latency/performance issues with MCP queries
- Configuration drift between agents
- Debugging complexity with new supervisor layer

**LOW RISK:**

- JSON schema validation issues
- Documentation update overhead
- Rollback testing insufficient

### 4.2 Mitigation Strategies (To Be Defined)

- TBD based on team review

---

## Phase 5: Rollback Plan (CRITICAL - TO BE COMPLETED)

### 5.1 Emergency Rollback Procedure

**If MCP v1.1 breaks production workflows:**

```bash
# 1. Revert to last known good governance state
git checkout prod-2025-12-09  # Tag before MCP integration

# 2. Re-run existing session start
./scripts/start_session.sh

# 3. Verify governance loaded
# Agent should see: "Active Mode: OPTION A, Benchmark Addendum: v1.1.2"

# 4. Document what broke
# Add to ROLLBACK_INCIDENT_LOG.md
```

**Rollback Success Criteria:**

- [ ] Session start macro loads correctly
- [ ] All 5 core governance files accessible
- [ ] Agent can read TROUBLESHOOTING_CHECKLIST.md
- [ ] Agent can read SELF_DIAGNOSTIC_FRAMEWORK.md
- [ ] 3-layer architecture intact (LOCAL → GDRIVE MASTER → MIRROR)

---

## Next Steps for Team Review

### Team Members to Review (All AI Agents + Human)

**Reviewers:**

- [ ] Damian (Human) - Strategic approval
- [ ] Claude Code (Local agent) - Technical feasibility
- [ ] ChatGPT (Mirror agent) - Mirror compliance
- [ ] Gemini (API mode agent) - Integration concerns

### Review Questions

**For All Reviewers:**

1. Do you understand what MCP v1.1 proposes to change?
2. What concerns do you have about this integration?
3. What questions need answering before we proceed?
4. What's missing from this plan?
5. What's your recommended approach (Option A/B/C/other)?

**For Claude Code (This Agent):**

1. Can you work with MCP servers from CLI context?
2. What happens to your current session start workflow?
3. How do you coordinate with supervisor agents?
4. What tools/libraries needed for MCP integration?

**For ChatGPT (Mirror Agent):**

1. How does MCP affect your GDrive Mirror reads?
2. Can you query MCP servers from ChatGPT context?
3. What happens to your governance document summaries?
4. How do you handle MCP server unavailability?

**For Gemini (API Mode Agent):**

1. How does API mode interact with MCP architecture?
2. What changes to your broker scripts?
3. How do you authenticate to MCP servers?
4. What's your rollback procedure?

**For Damian:**

1. What problem are we trying to solve with MCP?
2. Is current v1.1.2 governance insufficient?
3. What capabilities justify this complexity?
4. What's your risk tolerance for this migration?
5. Timeline expectations?

---

## Appendix A: MCP v1.1 Files Inventory

**Full file listing:**

```
docs/mosaic_mcp_v1_1/
├── README.md (7 lines, master overview)
├── 00_bootstrap/
│   ├── MOSAIC_MCP_BOOTSTRAP_KIT.md (3 lines, placeholder)
│   ├── SUPERVISOR_AGENT.md (3 lines, placeholder)
│   └── MCP_FRAMEWORK.md (3 lines, placeholder)
└── 01_config/
    ├── constraints.json (1 line: {})
    ├── agent_roles.json (1 line: {})
    ├── retrieval_triggers.json (1 line: {})
    └── summarization_schema.json (1 line: {})
```

**Status:** Skeleton only, needs content population.

---

## Appendix B: Current Governance File Map

**Core Governance (v1.1.2):**

```
Root level (project folder):
├── META_GOVERNANCE_CANON_MVP_v1.0.md (1,858 bytes)
├── GLOBAL_META_INSTRUCTION_v2.0.md (222 bytes)
├── MOSAIC_CODESTYLE_CODEX_MVP_v1.0.md (1,423 bytes)
├── MOSAIC_CODEX_ELITE_BENCHMARK_ADDENDUM_v1.1.2.md (1,477 bytes)
├── UPDATED_SESSION_START_MACRO_v1.1.2.md (1,196 bytes)
├── TROUBLESHOOTING_CHECKLIST.md (14,741 bytes)
├── SELF_DIAGNOSTIC_FRAMEWORK.md (32,015 bytes)
├── CLAUDE.md (16,090 bytes)
└── DEPLOYMENT_TRUTH.md (6,115 bytes)

Scripts:
└── scripts/start_session.sh (executable)
```

**Status:** Fully functional, actively used.

---

## Document History

- 2025-12-09: Initial draft created by Claude Code
- Status: AWAITING TEAM REVIEW
- Next Update: After team review cycle complete

---

**END OF INTEGRATION PLAN - AWAITING REVIEW**
