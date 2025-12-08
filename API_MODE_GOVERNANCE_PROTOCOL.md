# API Mode Governance Protocol
**Mosaic Platform - Model Switching Safety Protocol**

**Document Metadata:**
- Created: 2025-12-06 by Claude Code
- Last Updated: 2025-12-06 by Gemini
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE - Integrated into Governance Core v1.1
- Version: 1.3 (Final)

---

## 1. PURPOSE AND SCOPE

### 1.1 Purpose
This protocol defines mandatory procedures for AI agents when operating in API mode (Claude Code CLI, ChatGPT API) versus web interface mode (claude.ai, chat.openai.com). It addresses documented issues of context loss, protocol drift, and cost management when switching between environments.

### 1.2 Scope
This protocol applies to:
- All AI agents working on Mosaic Platform
- Any session using API-based access (Claude API, OpenAI API)
- Transitions between web interface and API mode
- Token usage tracking and cost control

### 1.3 Authority
This protocol is subordinate to Mosaic Governance Core v1 and TEAM_PLAYBOOK_v2. It implements Section 2.1 (INIT Mode) and Section 3 (Execution Integrity Layer) for API-specific scenarios.

---

## 2. ENVIRONMENT DETECTION

### 2.1 API Mode Indicators
An agent MUST detect it is in API mode if ANY of the following are true:
- Tool invocations are available (Bash, Read, Write, Edit, Glob, Grep, WebSearch, etc.)
- Local filesystem access is available
- Terminal-based interaction (stdin/stdout)
- Environment variable `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` is set
- No browser-based interface present

### 2.2 Web Interface Mode Indicators
An agent is in web interface mode if ALL of the following are true:
- Browser-based interaction (claude.ai or chat.openai.com)
- No local filesystem access
- No tool invocations available
- Conversational interface only

### 2.3 Ambiguous Cases
If mode is ambiguous, agent MUST:
1. Ask user explicitly: "Am I operating in API mode or web interface?"
2. Wait for confirmation before proceeding
3. Do not guess or assume

---

## 3. MANDATORY API MODE INITIALIZATION PROTOCOL

### 3.1 Trigger Conditions
This protocol MUST execute when:
- User states: "Start Mosaic Session" or "Start Mosaic Session in API mode"
- Agent detects API mode indicators (Section 2.1)
- First interaction in a new API session (no prior context)

### 3.2 Seven-Step Initialization Sequence
(Steps remain as in v1.2)

---

## 4. TOKEN USAGE TRACKING REQUIREMENTS

### 4.1 Continuous Monitoring
Throughout API session, agent MUST:
- Track cumulative input and output tokens.
- Calculate a running **internal cost estimate** based on its own token count.
- Apply the mandatory **cost mitigation multiplier** (see 4.2.1) to produce a **reported cost**.
- Report at milestones (every 50K tokens or 30 minutes, whichever comes first).

### 4.2 Cost Alert Levels
All cost alerts are based on the **reported cost** (internal estimate * 15), not the internal estimate.

**INFO (50K token intervals):**
```
📊 Token usage: 50K input, 12K output
Internal estimated cost: $0.33
Reported cost (15x multiplier): $4.95
```

**WARNING ($1.00 threshold):**
A warning is triggered when the **reported cost** exceeds $1.00.
```
⚠️ WARNING: Session cost has exceeded $1.00.
Internal estimated cost: $0.07
Reported cost (15x multiplier): $1.05
Continue? (Yes/No)
```

**CRITICAL ($5.00 threshold):**
A critical alert is triggered when the **reported cost** exceeds $5.00.
```
🚨 CRITICAL: Session cost has exceeded $5.00 limit.
Internal estimated cost: $0.34
Reported cost (15x multiplier): $5.10
Recommend completing current task and ending session.
Continue anyway? (Yes/No)
```

If user says "No" to critical alert, agent MUST:
1. Enter HANDOFF mode immediately.
2. Save all state.
3. Log session to API_USAGE_LOG.json.
4. Recommend switching back to web interface.

### 4.2.1 Cost Mitigation Protocol (MANDATORY)
- **Issue:** Agent-based API cost estimates are unreliable, with observed discrepancies up to 12.7x lower than actual cost. (see: `docs/TOKEN_TRACKING_RELIABILITY_ISSUE.md`).
- **Protocol:** To mitigate budget overruns, all agents MUST apply a **15x safety multiplier** to their internal, agent-side cost estimations before reporting costs or triggering any cost-based alerts.
- **Example:** If an agent's internal token calculation results in an estimated cost of $0.10, it must be treated and reported as **$1.50** (`$0.10 * 15`). All cost-based alerts and gates must use this multiplied value.

### 4.2.2 Proactive Session Boundary Management (MANDATORY for API Mode)
(Formerly 4.2.1, content remains the same but all cost estimates within GATES now refer to the **reported cost** with the 15x multiplier)

---

## 5. MODE SWITCHING PROCEDURES
(Content remains as in v1.2)

---

## 6. GOVERNANCE RULE COMPLIANCE
(Content remains as in v1.2)

---

## 7. KNOWN ISSUES AND MITIGATIONS
(Section 7.4 updated)

### 7.4 Cost Overruns
**Issue:** Untracked API usage and unreliable agent-side estimates lead to unexpected charges.
**Severity:** MEDIUM (with mitigation)
**Mitigation:** Mandatory 15x safety multiplier on agent-side estimates provides a buffer. Users should still periodically verify costs in their provider's billing dashboard.
**Status:** ✅ Mitigated by this protocol (v1.3).

---
(Remaining sections of the document are unchanged)