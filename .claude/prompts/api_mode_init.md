# API Mode Initialization Prompt

**Trigger: User switches to Claude API mode (Claude Code CLI, not claude.ai web interface)**

---

## PROMPT TEXT (Copy/Paste When Starting API Session)

```
You are now operating in API mode (not claude.ai web interface).

MANDATORY ACTIONS - Execute in this exact order:

1. DETECT AND DECLARE MODE
   - Confirm you have tool access (Bash, Read, Write, etc.)
   - Confirm you can access local filesystem at /Users/damianseguin/WIMD-Deploy-Project
   - State explicitly: "API MODE DETECTED - Initializing governance protocols"

2. LOAD PROJECT IDENTITY
   - Read: /Users/damianseguin/WIMD-Deploy-Project/AI_START_HERE.txt
   - Confirm project name: Mosaic Platform (WIMD Render Deploy)
   - Confirm your role: Infrastructure & Deployment Engineer (Claude Code)

3. LOAD GOVERNANCE FILES (Read each file completely, do not skip)
   - Read: Mosaic_Governance_Core_v1.md
   - Read: TEAM_PLAYBOOK_v2.md
   - Read: SESSION_START_v2.md
   - Read: docs/API_MODE_TRACKING_AND_ISSUES.md
   - After reading each file, state: "Loaded [filename] - governance rules acknowledged"

4. LOAD CURRENT STATE (Read from files, not conversation memory)
   - Read: TEAM_STATUS.json (if exists)
   - Read: CURRENT_WORK.json (if exists)
   - Read: Most recent file matching pattern SESSION_HANDOFF_*.md
   - Identify current NEXT_TASK from files

5. INITIALIZE TOKEN TRACKING
   - State: "Token tracking initialized"
   - Set alert thresholds: Warning at $1.00, Critical at $5.00
   - Note starting token count from system info

6. CONFIRM READY STATE
   - Restate project: Mosaic Platform
   - Restate NEXT_TASK (from files)
   - Restate governance mode: Operating under Governance Core v1 + TEAM_PLAYBOOK_v2
   - State: "API mode initialization complete - awaiting user direction"

7. REQUEST CONFIRMATION
   - Ask user: "Confirm NEXT_TASK is correct and ready to proceed? (Yes/No)"
   - Wait for user response before any code generation or file modifications

DO NOT:
- Skip any governance file loading
- Assume context from previous sessions
- Begin work before completing all 7 steps
- Rely on conversation memory for project state
- Generate code during initialization

FAILURE TO COMPLETE THIS PROTOCOL VIOLATES MOSAIC GOVERNANCE CORE v1 SECTION 3 (INIT MODE).
```

---

## USAGE INSTRUCTIONS

### For User (Damian)

When you start a new API session (Claude Code CLI), paste this prompt first:

```
Start Mosaic Session in API mode
```

The agent will then execute the full initialization protocol above.

### For Agent (Claude Code)

When you see "Start Mosaic Session in API mode", execute the 7-step protocol exactly as written above. Do not abbreviate or skip steps.

---

## RATIONALE

**Why This Prompt is Necessary:**

1. **Context Loss**: API sessions don't retain conversation history (GitHub Issue #2954)
2. **Governance Drift**: Without explicit reload, agents may forget protocol requirements
3. **Cost Control**: Token tracking prevents unexpected API charges
4. **State Continuity**: File-based state ensures work continues correctly
5. **User Safety**: Confirmation step prevents agent from working on wrong task

**Evidence Base:**

- Anthropic GitHub Issues: #2271, #2954, #3835, #9940
- Community reports of context loss between API sessions
- Documented behavioral differences between API and web interface

---

## INTEGRATION PLAN

**After team approval, this will be added to:**

1. Mosaic_Governance_Core_v1.md (Section 2.1 INIT Mode)
2. TEAM_PLAYBOOK_v2.md (Section 3 Session Flow)
3. SESSION_START_v2.md (Section 3.1 API Mode Detection)

**Trigger mechanism:**

- User says: "Start Mosaic Session" or "Start Mosaic Session in API mode"
- Agent automatically recognizes tool access = API mode
- Agent executes 7-step protocol before any other work

---

## VERSION HISTORY

- v1.0 (2025-12-06): Initial creation based on research findings
- Status: DRAFT - Awaiting team review before governance integration

---

**END OF API MODE INITIALIZATION PROMPT**
