# Documentation Map

**Version:** 1.0
**Created:** 2026-01-05
**Purpose:** Central index of all canonical documentation

---

## 🚀 SESSION START (READ FIRST)

**Primary Entry Point:**
1. `.mosaic/current_task.json` - Current objective and decisions
2. `.mosaic/blockers.json` - Known blockers
3. `.mosaic/agent_state.json` - Last agent handoff
4. `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md` - Full context
5. `TERMINAL_AGENT_BRIEFING.md` - Implementation details

**Secondary:**
6. `.ai-agents/INTENT_FRAMEWORK.md` - Intent → Check → Receipt pattern
7. `.ai-agents/CROSS_AGENT_PROTOCOL.md` - Coordination rules
8. `Mosaic_Governance_Core_v1.md` - State machine & governance

---

## 📋 GOVERNANCE & PROTOCOLS

| Document | Status | Purpose |
|----------|--------|---------|
| `Mosaic_Governance_Core_v1.md` | ✅ CANONICAL | Top-level governance, state machine |
| `TEAM_PLAYBOOK_v2.md` | ✅ CANONICAL | Operational contract for all agents |
| `ENGINEERING_PRINCIPLES.md` | ✅ CANONICAL | Technical foundation (P01-P05) |
| `.ai-agents/INTENT_FRAMEWORK.md` | ✅ CANONICAL | Intent → Check → Receipt (mandatory) |
| `.ai-agents/CROSS_AGENT_PROTOCOL.md` | ✅ CANONICAL | 7 rules for cross-agent coordination |
| `SESSION_END_OPTIONS.md` | ✅ ACTIVE | 7 termination commands |

---

## 🛠️ DEVELOPMENT & TROUBLESHOOTING

| Document | Status | Purpose |
|----------|--------|---------|
| `TROUBLESHOOTING_CHECKLIST.md` | ✅ ACTIVE | Pre-flight checks, diagnostic filters |
| `SELF_DIAGNOSTIC_FRAMEWORK.md` | ✅ ACTIVE | Error taxonomy, playbooks-as-code |
| `CLAUDE.md` | ✅ ACTIVE | Main development reference |
| `DEPLOYMENT_TRUTH.md` | ✅ ACTIVE | Deployment commands & procedures |

---

## 🔍 CROSS-AGENT COORDINATION

| Document | Status | Purpose |
|----------|--------|---------|
| `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md` | ✅ CANONICAL | Root cause analysis, full context |
| `CROSS_AGENT_SOLUTION_IMPLEMENTATION.md` | ✅ CANONICAL | Implementation details, JSON schemas |
| `TERMINAL_AGENT_BRIEFING.md` | ✅ CANONICAL | Terminal-specific instructions |
| `SHARE_WITH_CURSOR_AGENT.md` | ✅ REFERENCE | Quick-share summary |

---

## 📊 STATE MANAGEMENT (.mosaic/)

| File | Type | Purpose |
|------|------|---------|
| `.mosaic/current_task.json` | State | Current objective, user decisions |
| `.mosaic/blockers.json` | State | Known blockers & resolutions |
| `.mosaic/agent_state.json` | State | Last agent, handoff message |
| `.mosaic/session_log.jsonl` | Log | Append-only session history |
| `.mosaic/authority_map.json` | Config | Repo & service identity |
| `.mosaic/session_start.json` | Config | Session start configuration |
| `.mosaic/policy.yaml` | Config | Governance policy |

**Why JSON?** Path-agnostic, machine-readable, works in any environment.

---

## ⚠️ DEPRECATED / SUPERSEDED

| Document | Status | Reason | Replaced By |
|----------|--------|--------|-------------|
| `SESSION_RESUME_PROMPT.md` | ⚠️ OUTDATED | Uses absolute paths | `.mosaic/agent_state.json` |
| `NEXT_SESSION_PROMPT.md` | ⚠️ OUTDATED | Jan 4 session end | `.mosaic/current_task.json` |
| `AI_START_HERE.txt` | ⚠️ BROKEN | Points to non-existent files | `CLAUDE.md` |
| `SESSION_START_v2.md` | ❌ MISSING | Referenced but doesn't exist | `SESSION_START.md` |
| `.ai-agents/START_HERE.md` | ❌ MISSING | Referenced but doesn't exist | `.mosaic/*.json` |

**Rule:** If a document uses absolute paths (`/Users/...` or `/home/...`), it's deprecated.

---

## 📁 PROJECT STRUCTURE

```
/
├── .mosaic/                  # ✅ Canonical state (JSON)
│   ├── current_task.json
│   ├── blockers.json
│   ├── agent_state.json
│   └── session_log.jsonl
│
├── .ai-agents/               # ✅ Agent protocols
│   ├── INTENT_FRAMEWORK.md
│   └── CROSS_AGENT_PROTOCOL.md
│
├── api/                      # Backend code
├── mosaic_ui/                # Frontend code
├── scripts/                  # Automation scripts
├── docs/                     # General documentation
│
├── CLAUDE.md                 # ✅ Main dev reference
├── TEAM_PLAYBOOK_v2.md       # ✅ Operational contract
├── Mosaic_Governance_Core_v1.md  # ✅ Top-level governance
│
└── docs_archive/             # Historical docs (pre-2025-12-01)
    └── sessions_2025/
```

---

## 🎯 FINDING WHAT YOU NEED

**I need to start a session:**
→ Read `.mosaic/current_task.json` + `.mosaic/agent_state.json`

**I need to understand governance:**
→ Read `Mosaic_Governance_Core_v1.md` + `TEAM_PLAYBOOK_v2.md`

**I need to deploy:**
→ Read `DEPLOYMENT_TRUTH.md` + `CLAUDE.md` deployment section

**I need to debug:**
→ Read `TROUBLESHOOTING_CHECKLIST.md` + `SELF_DIAGNOSTIC_FRAMEWORK.md`

**I need to understand cross-agent coordination:**
→ Read `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md` + `.ai-agents/CROSS_AGENT_PROTOCOL.md`

**I need to create a deliverable:**
→ Read `.ai-agents/INTENT_FRAMEWORK.md` (mandatory: Intent → Check → Receipt)

**I hit a blocker:**
→ Update `.mosaic/blockers.json` + check `TEAM_PLAYBOOK_v2.md` Section 5

---

## 🔄 KEEPING THIS MAP UPDATED

**When creating new canonical docs:**
1. Add entry to appropriate section above
2. Mark status: ✅ CANONICAL, ✅ ACTIVE, ⚠️ OUTDATED, or ❌ DEPRECATED
3. Update `.mosaic/agent_state.json` to note the change
4. Commit with message: `docs: Update DOCUMENTATION_MAP.md`

**When deprecating docs:**
1. Move status to DEPRECATED section
2. Specify what replaced it
3. Consider moving to `docs_archive/`

---

**END OF DOCUMENTATION MAP**
**Version:** 1.0
**Maintainer:** All AI agents (update as needed)
