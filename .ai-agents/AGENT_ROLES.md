# AI Agent Roles & Responsibilities

**Version:** 1.0
**Effective Date:** 2025-11-18
**Status:** ACTIVE - CIC Approved
**Last Updated:** 2025-11-18T09:45Z

---

## Overview

This document defines the roles, responsibilities, and handoff protocols for all AI agents working on the WIMD Railway Deploy Project. Role optimization implemented 2025-11-18 to leverage complementary model strengths and eliminate role conflicts.

---

## Active Team Members

### Codex Terminal (CIT) - Troubleshooting Specialist

**Model:** Haiku 4.5 (claude-haiku-4-5-20251001)

**Primary Responsibilities:**
- Active debugging and diagnosis during incidents
- Real-time evidence capture (console logs, network traces, error screenshots)
- Hands-on problem resolution and fix execution
- Fast iteration diagnostic loops
- Technical investigation of production issues

**Key Strengths:**
- Low latency for rapid troubleshooting cycles
- Fast model responses for quick diagnostic iteration
- Efficient at rapid problem isolation

**When to Engage CIT:**
- Production incidents requiring immediate diagnosis
- Active debugging sessions
- Evidence gathering during failures
- Real-time troubleshooting needed

**Handoff Protocol:**
- **To Claude Code CLI:** After fix is deployed, pass context for documentation audit
- **To CIC:** Escalate if code changes required beyond configuration fixes

**Model Switch (if needed mid-session):**
```bash
/model
# Select: claude-haiku-4-5-20251001
```

---

### Claude Code CLI - Systems Engineer + Documentation Steward

**Model:** Sonnet 4.5 (claude-sonnet-4-5-20250929)

**Primary Responsibilities:**
- Infrastructure verification and health checks
- Documentation quality enforcement and consistency
- Post-deploy audits and reconciliation
- Session protocol maintenance and updates
- Evidence-based documentation updates
- Cross-document consistency verification
- Natural language polish for handoffs and guides

**Key Strengths:**
- Superior natural language summarization
- Cross-referencing multiple documents for consistency
- Spotting documentation drift vs. operational reality
- Thorough post-mortem analysis

**When to Engage Claude Code CLI:**
- Post-deployment verification needed
- Documentation audit required
- Session protocol updates
- Infrastructure health checks
- Handoff manifest creation
- Multi-document consistency reviews

**Handoff Protocol:**
- **To CIT:** Pass active troubleshooting incidents requiring diagnosis
- **To CIC:** Escalate documentation policy questions or architectural decisions

**Current Working Directory:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project`

---

### Codex in Cursor (CIC) - Lead Developer

**Primary Responsibilities:**
- Feature implementation and code development
- Deployment execution and coordination
- Code review and technical oversight
- Agent workflow orchestration
- Strategic technical decisions
- Integration of agent outputs into codebase

**Key Strengths:**
- Feature development and implementation
- Technical execution and deployment
- Team coordination and decision-making

**When to Engage CIC:**
- Code changes required
- Deployment approval needed
- Agent coordination required
- Strategic technical decisions
- Architectural questions

**Coordination Role:**
- Receives escalations from CIT and Claude Code CLI
- Approves role changes and workflow modifications
- Final authority on deployment decisions

---

## Role Separation Rationale

### Problem Solved
Prior to 2025-11-18, both CIT and Claude Code CLI operated as terminal agents with overlapping troubleshooting responsibilities, causing role confusion.

### Solution
**Sequential Workflow:**
1. **CIT (Haiku 4.5):** Fast diagnosis and fix execution
2. **Claude Code CLI (Sonnet 4.5):** Thorough documentation and verification

**Result:** Complementary strengths, no overlap
- CIT = Speed (active troubleshooting)
- Claude Code CLI = Depth (documentation quality)

### Evidence
**2025-11-18 Documentation Audit** (Claude Code CLI):
- Identified railway-origin deployment ambiguity
- Synchronized 4+ documents (CLAUDE.md, SESSION_START_PROTOCOL.md, etc.)
- Created evidence-based resolution
- **Pattern:** Natural language cross-referencing strength

**2025-11-14 Manual Testing** (CIT):
- Auth modal verification
- Chat conversation testing
- PS101 prompt testing
- **Pattern:** Fast hands-on execution

---

## Handoff Triggers & Workflows

### CIT → Claude Code CLI
**Trigger:**
- Fix has been deployed
- Incident resolved, documentation needed
- Evidence captured, needs summarization

**Handoff includes:**
- Incident timeline
- Fix description
- Evidence files/paths
- Verification results

**Example:**
```json
{
  "from": "CIT",
  "to": "Claude_Code_CLI",
  "trigger": "fix_deployed",
  "context": {
    "incident": "PS101 chat not advancing",
    "fix": "Added callJson() wrapper for session headers",
    "evidence": [".ai-agents/evidence/console_capture_2025-11-12.log"],
    "verification": "PASSED"
  },
  "request": "Document fix and update relevant protocols"
}
```

---

### Claude Code CLI → CIT
**Trigger:**
- Active troubleshooting incident detected
- Production issue requiring diagnosis
- Real-time debugging needed

**Handoff includes:**
- Symptoms observed
- Affected systems/endpoints
- Initial investigation results
- Relevant documentation context

**Example:**
```json
{
  "from": "Claude_Code_CLI",
  "to": "CIT",
  "trigger": "production_incident",
  "context": {
    "symptom": "Health endpoint returning 503",
    "affected": "/health/comprehensive",
    "investigation": "Recent deploy 20min ago, no code changes",
    "docs": ["deploy_logs/2025-11-18_ps101-qa-mode.md"]
  },
  "request": "Diagnose health check failure, capture logs"
}
```

---

### CIT or Claude Code CLI → CIC
**Trigger:**
- Code changes required beyond configuration
- Architectural decision needed
- Role/protocol changes proposed
- Deployment approval required

**Handoff includes:**
- Problem summary
- Proposed solution options
- Agent recommendation
- Risk assessment

**Example:**
```json
{
  "from": "Claude_Code_CLI",
  "to": "CIC",
  "trigger": "role_change_proposal",
  "context": {
    "proposal": "Agent role optimization",
    "document": ".ai-agents/TEAM_NOTE_ROLE_OPTIMIZATION_2025-11-18.md",
    "recommendation": "Approve CIT model switch to Haiku 4.5"
  },
  "request": "Review and approve role changes"
}
```

---

## Model Selection Rationale

### CIT: Haiku 4.5
**Why:**
- Fast iteration critical for diagnostic loops
- Low latency reduces troubleshooting time
- Cost-efficient for high-frequency operations

**When to Switch:**
- Default for all CIT sessions
- Switch mid-session via `/model` if needed
- Escalate to Sonnet if complex reasoning required

---

### Claude Code CLI: Sonnet 4.5
**Why:**
- Superior natural language capabilities
- Better cross-document consistency checking
- Thorough analysis for documentation audits

**When to Use:**
- Default for all Claude Code CLI sessions
- Post-deploy documentation reviews
- Multi-document synchronization tasks
- Session protocol updates

---

## Escalation Paths

### Technical Issues
```
CIT (diagnosis) → Claude Code CLI (verification) → CIC (code changes)
```

### Documentation Issues
```
Claude Code CLI (audit) → CIC (approval) → All agents (implementation)
```

### Role/Process Changes
```
Any agent (proposal) → CIC (review/approval) → All agents (adoption)
```

---

## Success Metrics

**If role optimization is working:**
- ✅ Faster troubleshooting cycles (CIT speed advantage)
- ✅ Higher documentation quality (Claude Code CLI focus)
- ✅ Clear handoff protocols followed
- ✅ No role confusion between terminal agents
- ✅ Better model strength utilization

**Review frequency:** Quarterly or after major incidents

---

## Session Start Requirements

**Every agent MUST:**
1. Read this document at session start
2. Identify role explicitly in first message
3. Follow handoff protocols when transitioning work
4. Update relevant documentation after completing tasks
5. Log session activity in `.ai-agents/session_log.txt`

---

## Change Log

### 2025-11-18 - Initial Role Optimization
- **Proposal:** `.ai-agents/TEAM_NOTE_ROLE_OPTIMIZATION_2025-11-18.md`
- **Approved by:** CIC
- **Changes:**
  - CIT model: Haiku 4.5 (speed optimization)
  - Claude Code CLI: Expanded to Documentation Steward role
  - Formal handoff protocols established
  - SESSION_START_PROTOCOL.md updated with roles

---

## References

**Key Documents:**
- `.ai-agents/SESSION_START_PROTOCOL.md` - Mandatory session start checklist
- `.ai-agents/COLLABORATION_PROTOCOL.md` - Human-AI interaction rules
- `.ai-agents/TEAM_NOTE_ROLE_OPTIMIZATION_2025-11-18.md` - Role optimization proposal
- `CLAUDE.md` - Project context and architecture
- `TROUBLESHOOTING_CHECKLIST.md` - Diagnostic procedures

**Model Documentation:**
- Haiku 4.5: https://www.anthropic.com/news/claude-sonnet-4-5
- Sonnet 4.5: https://www.anthropic.com/news/claude-sonnet-4-5
- Model switching: https://support.claude.com/en/articles/11940350-claude-code-model-configuration

---

**END OF AGENT ROLES DOCUMENT**

**Version:** 1.0
**Maintained by:** Claude Code CLI (Documentation Steward)
**Last Review:** 2025-11-18
**Next Review:** 2026-02-18 (or after major incidents)
