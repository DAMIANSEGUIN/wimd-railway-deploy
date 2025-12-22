# SESSION START PROTOCOL - SELF-DOCUMENTING

**Auto-Updated:** This document is automatically updated at session end
**Last Update:** 2025-12-22T18:30:00Z
**Updated By:** Claude Code

---

## MANDATORY FIRST ACTION

**Read project state:**

```bash
cat .mosaic/project_state.json
```

This file contains all session start answers automatically.

---

## CURRENT STATE (Auto-Populated)

**Current Phase:** ENFORCEMENT_ACTIVATION - COMPLETE
**Current Stage:** All local enforcement gates passing
**Next Phase:** CI_MODE_ENFORCEMENT - PENDING

**Gates Status:**
- ✅ REPO_REMOTE_MATCH: PASS
- ✅ BRANCH_MATCH: PASS
- ✅ CLEAN_WORKTREE: PASS
- ✅ SESSION_START_SSOT: PASS

**Blocking Issues:** None

**Next Step:** Implement CI mode enforcement (see `.mosaic/project_state.json` for detailed implementation steps)

---

## INITIALIZATION PROTOCOL

### Step 1: Load Current State

```bash
# Read project state
STATE=$(cat .mosaic/project_state.json)

# Extract current phase
CURRENT_PHASE=$(echo $STATE | jq -r '.current_phase.phase_id')
PHASE_STATUS=$(echo $STATE | jq -r '.current_phase.status')

# Extract next phase
NEXT_PHASE=$(echo $STATE | jq -r '.next_phase.phase_id')
NEXT_STEPS=$(echo $STATE | jq -r '.next_phase.implementation_steps')
```

### Step 2: Verify Environment

```bash
# Run local enforcement to verify gates
bash scripts/run_local_enforcement.sh
```

### Step 3: Identify Next Task

The next task is ALWAYS in `.mosaic/project_state.json` under `next_phase.implementation_steps`.

Find the first step with `"status": "PENDING"` and dependencies met.

---

## QUESTIONS THAT NO LONGER NEED ANSWERS

These are answered by reading `.mosaic/project_state.json`:

❌ **What is the current code version?**
→ Read: `git_commit` field

❌ **How many blocking issues exist?**
→ Read: `blocking_issues` array length

❌ **What is the rollback path?**
→ Read: `session_history` for last known good commit

❌ **What pattern MUST I use for database operations?**
→ Read: `TROUBLESHOOTING_CHECKLIST.md` (linked from governance)

❌ **What should I work on?**
→ Read: `next_phase.implementation_steps` - first PENDING step with dependencies met

❌ **What's the current phase?**
→ Read: `current_phase.phase_id` and `current_phase.status`

---

## DECISION TREE

```
START SESSION
  │
  ├─> Read .mosaic/project_state.json
  │
  ├─> Check current_phase.status
  │     ├─> "COMPLETE" → Proceed to next_phase
  │     └─> "IN_PROGRESS" → Resume current_phase
  │
  ├─> Check blocking_issues.length
  │     ├─> > 0 → Work on blocking issues first
  │     └─> = 0 → Proceed to next task
  │
  ├─> Find next task in next_phase.implementation_steps
  │     └─> First step where status="PENDING" AND dependencies met
  │
  └─> BEGIN WORK (no questions needed)
```

---

## SESSION END PROTOCOL

**When user says "ending session" or similar:**

Run this script (it updates `.mosaic/project_state.json` automatically):

```bash
./scripts/session_end.sh
```

The script MUST:
1. Prompt for session summary
2. Update `project_state.json` with:
   - Current git commit
   - Phase completion status
   - Updated implementation steps status
   - New blocking issues (if any)
   - Session history entry
3. Commit the updated `project_state.json`

---

## ENFORCEMENT RULES

### ❌ FORBIDDEN QUESTIONS

- "What should I work on?" → Read `.mosaic/project_state.json`
- "What's the priority?" → Read `next_phase.implementation_steps` order
- "Where do I start?" → Read first PENDING step
- "What's the current state?" → Read `current_phase` field

### ✅ ALLOWED QUESTIONS

- "I read project_state.json but step X has unclear dependencies - can you clarify?"
- "The next step requires Y but I found Z in the codebase - which is correct?"

---

## GOVERNANCE DOCUMENTS HIERARCHY

1. `.mosaic/project_state.json` - **CURRENT STATE** (auto-updated)
2. `docs/MOSAIC_CANON_GOVERNANCE_REWRITE__DETERMINISTIC_GATES.md` - **CANONICAL SPEC**
3. `Mosaic_Governance_Core_v1.md` - **AGENT BEHAVIOR**
4. `TEAM_PLAYBOOK_v2.md` - **OPERATIONAL PROCEDURES**
5. `TROUBLESHOOTING_CHECKLIST.md` - **ERROR PATTERNS**
6. `SELF_DIAGNOSTIC_FRAMEWORK.md` - **ERROR PREVENTION**

---

## EXAMPLE SESSION START

```bash
# Agent starts session
$ cat .mosaic/project_state.json

# Output shows:
# current_phase: "ENFORCEMENT_ACTIVATION" (COMPLETE)
# next_phase: "CI_MODE_ENFORCEMENT" (PENDING)
# next_steps: [
#   { "step_id": "1", "description": "Create GitHub Actions workflow", "status": "PENDING" }
# ]

# Agent immediately knows:
# - Current phase is complete
# - Next phase is CI mode enforcement
# - First task is: Create GitHub Actions workflow
# - No blocking issues

# Agent proceeds WITHOUT asking user "what should I work on?"
```

---

## SELF-UPDATING MECHANISM

**At session end, the agent MUST:**

1. Run `./scripts/session_end.sh`
2. Script prompts for:
   - What was accomplished?
   - Did phase complete?
   - Which steps are now COMPLETE?
   - Any new blocking issues?
   - Agent name?
3. Script updates `.mosaic/project_state.json`:
   - Increment completed steps
   - Mark phase as COMPLETE if all steps done
   - Add session history entry
   - Update last_updated timestamp
4. Script commits the changes
5. Next session reads updated state automatically

---

**END OF SESSION START PROTOCOL**
