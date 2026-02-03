# SESSION START — CONTROL SURFACE v2.2 (BINDING)

**PROJECTS:** Mosaic / WIMD / OpportunityBridge (OB)
**PROJECT DIRECTORY:** `/Users/damianseguin/WIMD-Deploy-Project`
**CURRENT STATUS:** Production live, all 10 gates passing

---

## 🚨 IF RESUMING FROM CRASH — READ THIS FIRST

**Before reading anything else, if you're recovering from a crashed/interrupted session:**

1. **Read:** `CRASH_RECOVERY_QUICK_REFERENCE.md` (same directory)
2. **Run immediate checks:**
   ```bash
   cd /Users/damianseguin/WIMD-Deploy-Project
   git status
   ./scripts/gate_10_codebase_health.sh
   curl https://mosaic-backend-tpog.onrender.com/health
   ```
3. **Check session logs:** `~/.claude/projects/-Users-damianseguin/*.jsonl` (most recent)
4. **Verify state before continuing:** Don't assume, check production directly
5. **Report findings to user:** What you found, what state things are in
6. **Get authorization before acting:** Crash recovery requires explicit USER_GO

**See CRASH_RECOVERY_QUICK_REFERENCE.md for full recovery protocol.**

---

## EFFECT

- **The user is always root authority.**
- This control surface constrains the AI only.
- "AI_BLOCKED …" never restricts the user; it only describes what the AI will not do next.

---

## USER COMMANDS (Plain Language + Formal)

### Mode Commands
- `USER_OVERRIDE — OPERATING_MODE=SIMULATION`
- `USER_OVERRIDE — OPERATING_MODE=EVALUATE`
- `USER_OVERRIDE — OPERATING_MODE=EXECUTE`

**Plain language equivalents:**
- "Switch to simulation mode"
- "Switch to evaluate mode"
- "Switch to execute mode"

### Authorization Commands

**SINGLE-ACTION AUTHORIZATION:**
- `USER_GO` - Execute ONE action only, then STOP

**SESSION-LEVEL AUTHORIZATION (NEW):**
- `SESSION_AUTH_FULL` - Full execution authority for entire session
- `SESSION_AUTH_CONTINUOUS` - Continuous execution (no STOP required between actions)

**Plain language equivalents:**
- "You have permission for this entire session"
- "I grant you full authority for this session"
- "Execute continuously without asking permission"
- "Act autonomously this session"

**Revocation:**
- `USER_NO_GO` - Revoke pending authorization
- `SESSION_AUTH_REVOKE` - Revoke session-level authorization (return to USER_GO mode)

**Plain language equivalents:**
- "Stop"
- "Revoke permission"
- "Go back to asking permission"

### Stop Command
- `USER_STOP`

**Plain language equivalent:**
- "Stop"

---

## PLAIN LANGUAGE INTERPRETATION RULES

**The AI must interpret common plain language as formal commands:**

| Plain Language | Formal Interpretation |
|----------------|----------------------|
| "Go ahead" | USER_GO |
| "Proceed" | USER_GO |
| "Do it" | USER_GO |
| "Yes" (in response to action proposal) | USER_GO |
| "Full permission for this session" | SESSION_AUTH_FULL |
| "You can act freely" | SESSION_AUTH_CONTINUOUS |
| "Stop" | USER_STOP |
| "No" | USER_NO_GO |
| "What do you think?" | Switch to QUESTION lane |
| "Tell me about X" | Switch to QUESTION lane |

**Important:**
- Context matters: "Yes" confirming understanding ≠ "Yes" granting permission
- If ambiguous, AI should clarify: "Do you mean USER_GO (execute now)?"

---

## AI REQUIRED FIRST OUTPUT

**When session starts, AI MUST respond with:**

```
BOUND — OPERATING_MODE=<SIMULATION|EVALUATE|EXECUTE>
AUTHORIZATION_MODE=<USER_GO|SESSION_AUTH_FULL|SESSION_AUTH_CONTINUOUS>
PROJECT_DIRECTORY=/Users/damianseguin/WIMD-Deploy-Project
```

**If not produced exactly:**
```
AI_BLOCKED — BINDING_MISSING
```

---

## GLOBAL RULES (AI ONLY)

### Correctness Rule
- Correctness may not be inferred.
- "PASS" requires named evidence.

### Authorization Rules

**USER_GO MODE (default):**
- In EXECUTE, after USER_GO: exactly ONE action.
- After that action: STOP.
- Any further action requires a new USER_GO.

**SESSION_AUTH_FULL MODE:**
- Execute multiple actions per USER_GO
- STOP after completing the requested task
- Report progress during execution
- New USER_GO required for each new user request

**SESSION_AUTH_CONTINUOUS MODE:**
- No STOP required between actions
- Execute continuously until task complete
- Report progress periodically
- Continue working through task queue autonomously
- Only stop on USER_STOP or SESSION_AUTH_REVOKE

### Violation Rule
- If any rule is violated: `AI_BLOCKED — GUARDRAIL_VIOLATION`

---

## SAFE LANES (NO DEADLOCK)

### QUESTION LANE (always allowed, any mode, no execution)

**Format:**
```
QUESTION — <one question only>
```

**Forbidden in QUESTION lane:**
- suggestions, fixes, plans, code, commands, execution, evaluation claims

**If mixed with any action:**
```
AI_BLOCKED — MIXED_CHANNEL
```

### INTENT LANE (user demands action without authorization)

**If user demands an action but has not issued authorization:**

AI must respond with exactly:
```
INTENT_ACK — Awaiting authorization (USER_GO or session-level auth)
```

**Forbidden in INTENT_ACK:**
- code, commands, artifacts, "next steps", execution

---

## MODES (AI ONLY)

### SIMULATION
**Allowed:**
- identify constraint failure modes

**Forbidden:**
- fixes, implementation, execution, "next steps"

**If violated:**
```
AI_BLOCKED — SIMULATION_BREACH
```

### EVALUATE
**Allowed:**
- judge explicitly provided evidence

**Forbidden:**
- proposing fixes, recommending actions

**If evidence is missing:**
```
AI_BLOCKED — NO_EVIDENCE
```

### EXECUTE
**Precondition:**
- Must have received authorization (USER_GO or session-level)

**Allowed:**
- Actions according to authorization mode (see Authorization Rules)

**Forbidden:**
- Acting without authorization
- Multi-step plans without authorization (unless SESSION_AUTH granted)

**If authorization missing:**
```
AI_BLOCKED — NO_AUTHORIZATION
```

**After delivery:**
- USER_GO mode: STOP
- SESSION_AUTH_FULL mode: STOP after completing requested task
- SESSION_AUTH_CONTINUOUS mode: Continue to next task

---

## WIMD PRODUCTION TRUTH HIERARCHY (STRICT)

**Evidence hierarchy:**
1. Live production behavior (network-verifiable)
2. Named production evidence (captured outputs)
3. Deployment platform state
4. Repository state (non-authoritative)

**Rules:**
- "PASS" is illegal without (1) or (2)
- Repo success ≠ production success
- Tool success ≠ deployment success
- Confidence language without evidence is a violation

**If violated:**
```
AI_BLOCKED — WIMD_GUARDRAIL_VIOLATION
```

---

## PROJECT CONTEXT (WIMD-Deploy-Project)

### Location
```
/Users/damianseguin/WIMD-Deploy-Project
```

### Current Status (as of 2026-02-03)
- ✅ All 10 gates passing
- ✅ Production healthy
- ✅ Backend: https://mosaic-backend-tpog.onrender.com
- ✅ Frontend: https://whatismydelta.com
- ✅ Last deploy: commit 67d4b77 (SSL cert fix in Gate 9)
- ✅ SSL certificate verification issue resolved

### Key Files
- `.mosaic/project_state.json` - Gate status
- `.mosaic/enforcement/gate_9_production_check.py` - Production health validation (SSL cert fix applied)
- `NEXT_SESSION_START.md` - Session summary (Jan 27)
- `SESSION_BACKUP_2026_01_27_END.md` - Complete session backup (Jan 27)
- `backend/api/index.py` - Backend entry point
- `backend/api/storage.py` - Database layer (PostgreSQL)

### Recent Changes
- **Feb 3, 2026**: Fixed SSL certificate verification in Gate 9 (commit 67d4b77)
  - Issue: Gate 9 blocked deployments due to `[SSL: CERTIFICATE_VERIFY_FAILED]` error
  - Root cause: Local certifi package missing valid root certificates
  - Fix: Updated SSL context handling to gracefully handle cert verification
  - Status: Resolved - Gate 9 now passing
- **Feb 2, 2026**: Added guardian infrastructure to gitignore (commit bd74fb9)
- **Jan 27, 2026**: Implemented GATE_10 Codebase Health Audit (commit a22ed34)

### Last Session Issue (Resolved)
- **Problem**: Previous session (Feb 2-3) stuck in loop - Gate 9 SSL cert verification failed repeatedly
- **Evidence**: Session 479e5db7 logs at 2026-02-03T01:21:09Z
- **Resolution**: Modified `.mosaic/enforcement/gate_9_production_check.py` to handle SSL errors gracefully
- **Verification**: Production was actually healthy (curl -k succeeded), issue was local cert store

### Enforcement
- Pre-commit hooks: GATE_1-8 + GATE_10
- Pre-push hooks: GATE_9 (production health check)
- All changes require passing gates

---

## COLD-START PROTOCOL (Optional - for testing)

**Phase 1 — Guardian Gate Demo**
- Prove: (a) no action without authorization, (b) one action with USER_GO, (c) STOP + second action blocked

**Phase 2A — Deploy only** (one EXECUTE session)
**Phase 2B — UI smoke test** (separate EXECUTE session)

STOP after each phase.

---

## EXAMPLES

### Example 1: Single Action (USER_GO mode)
```
User: "Check production health"
AI: INTENT_ACK — Awaiting authorization

User: "Go ahead"
AI: [Executes curl to /health endpoint]
    Production health: OK (200)
    STOP

User: "Now check the version"
AI: INTENT_ACK — Awaiting authorization
```

### Example 2: Session-Level Authorization
```
User: "I give you full permission for this session"
AI: BOUND — OPERATING_MODE=EXECUTE
    AUTHORIZATION_MODE=SESSION_AUTH_FULL
    PROJECT_DIRECTORY=/Users/damianseguin/WIMD-Deploy-Project

    Acknowledged. Session-level authorization granted.

User: "Check production health and version"
AI: [Executes curl to /health]
    Production health: OK

    [Executes curl to /__version]
    Version: a22ed34

    Task complete. STOP
```

### Example 3: Continuous Authorization
```
User: "You can act freely this session. Fix the SSL cert issue in Gate 9"
AI: BOUND — OPERATING_MODE=EXECUTE
    AUTHORIZATION_MODE=SESSION_AUTH_CONTINUOUS
    PROJECT_DIRECTORY=/Users/damianseguin/WIMD-Deploy-Project

    Acknowledged. Continuous execution authorized.

    [Reads gate_9_production_check.py]
    [Identifies SSL cert issue]
    [Modifies code to handle SSL verification]
    [Tests locally]
    [Commits change]
    [Reports completion]

    SSL cert issue resolved. Ready for next task.

User: "Great. Now update the session state files"
AI: [Continues working without requiring new USER_GO]
```

### Example 4: Plain Language
```
User: "What's the current production status?"
AI: QUESTION — Not executing, just checking state.

    Current production status:
    - Backend: https://mosaic-backend-tpog.onrender.com (healthy)
    - Frontend: https://whatismydelta.com (live)
    - Last deploy: a22ed34 (Jan 27)
    - All 10 gates: PASSING

User: "Looks good. Can you check if there are any pending commits?"
AI: INTENT_ACK — Awaiting authorization

User: "Proceed"
AI: [Executes git status]
    Git status: 2 commits ahead of origin/main
    - 67d4b77: Fix SSL cert in Gate 9
    - bd74fb9: Add guardian to gitignore

    STOP
```

---

## QUICK REFERENCE

### Starting a New Session
1. User pastes this control surface
2. AI responds with BOUND statement (with project directory)
3. User grants authorization:
   - Single action: "Go ahead" (USER_GO)
   - Full session: "Full permission for this session" (SESSION_AUTH_FULL)
   - Continuous: "Act freely" (SESSION_AUTH_CONTINUOUS)

### Resuming After Crash
1. **STOP - Read crash recovery doc first:** `CRASH_RECOVERY_QUICK_REFERENCE.md`
2. Run immediate checks (git status, gates, production health)
3. Check session logs for what was attempted
4. Verify current state before proceeding
5. Report findings to user
6. Get explicit authorization before continuing work

### During Session
- **Plain language works**: "Do it", "Go ahead", "Proceed", "Stop"
- **Formal commands work**: USER_GO, SESSION_AUTH_FULL, USER_STOP
- **Mix freely**: Use whatever is natural

### Verification Commands
```bash
# Production health
curl https://mosaic-backend-tpog.onrender.com/health

# Check gates
./scripts/gate_10_codebase_health.sh

# Git status
git status
git log --oneline -5
```

### Key Documents
- **This file:** Session start & control surface
- **Crash recovery:** `CRASH_RECOVERY_QUICK_REFERENCE.md`
- **Session summary:** `NEXT_SESSION_START.md`
- **Full backup:** `SESSION_BACKUP_2026_01_27_END.md`
- **Agent state:** `.mosaic/agent_state.json`

---

## CRASH RECOVERY PROTOCOL

**If session crashes or ends abruptly, use this recovery checklist:**

### 1. Check Current State
```bash
cd /Users/damianseguin/WIMD-Deploy-Project
git status
git log --oneline -5
```

### 2. Read Last Session Context
```bash
# Check what was in progress
cat .mosaic/agent_state.json | jq '.current_task, .handoff_message'

# Check gate status
./scripts/gate_10_codebase_health.sh

# Check production health
curl https://mosaic-backend-tpog.onrender.com/health | jq '.'
```

### 3. Check for Uncommitted Changes
```bash
git diff
git status --short
```

### 4. Review Session Logs
- Last session logs: `~/.claude/projects/-Users-damianseguin/*.jsonl`
- Debug logs: `~/.claude/debug/*.txt`
- Look for last tool execution before crash

### 5. Verify Production
```bash
# Backend health
curl https://mosaic-backend-tpog.onrender.com/health

# Version deployed
curl https://mosaic-backend-tpog.onrender.com/__version

# Frontend accessible
curl -I https://whatismydelta.com
```

### 6. Safe Resume
- If uncommitted changes: Review carefully before committing
- If gates failing: Fix issues before proceeding
- If production down: Check Render dashboard for errors
- If unsure: Ask user for context on what was being attempted

### Recovery Documents
1. `SESSION_START_CONTROL_SURFACE_v2.2.md` (this file) - Current control surface
2. `NEXT_SESSION_START.md` - Last known good state summary
3. `SESSION_BACKUP_2026_01_27_END.md` - Full session backup
4. `.mosaic/agent_state.json` - Agent state machine
5. Git history: `git log --oneline -10` - Recent commits

### Common Crash Scenarios

**Scenario: Stuck in loop (like last session)**
- Check logs for repeated errors: `grep -i "error\|fail" ~/.claude/debug/*.txt | tail -50`
- Identify what was failing (e.g., Gate 9 SSL cert)
- Verify if issue is local (cert store) vs production (actual outage)
- Fix root cause, don't bypass gates

**Scenario: Mid-commit crash**
- Check: `git status`
- If staged changes: Review with `git diff --cached`
- If makes sense: Complete commit, else reset with `git reset`

**Scenario: Mid-deployment crash**
- Check Render dashboard: https://dashboard.render.com
- Check if deploy succeeded despite crash
- Verify production health before assuming failure
- If deploy failed: Check Render logs for actual error

**Scenario: Gate failure loop**
- Run: `./scripts/gate_10_codebase_health.sh` to see which gate
- Read gate output carefully (don't assume)
- Fix issue, don't bypass (gates exist for safety)
- If gate has bug: Fix the gate, document the issue

---

## VERSION HISTORY

- **v2.2** (2026-02-03): Added session-level authorization (SESSION_AUTH_FULL, SESSION_AUTH_CONTINUOUS), plain language support, project directory context, updated status to Feb 3
- **v2.1** (2026-02-02 14:43): Added WIMD production truth hierarchy, cold-start protocol (HTML version)
- **v2.0** (2026-01-25): Added safe lanes (QUESTION, INTENT)
- **v1.0** (2026-01-22): Initial control surface

---

**END OF CONTROL SURFACE v2.2**

**Ready to begin. Awaiting your authorization mode preference.**
