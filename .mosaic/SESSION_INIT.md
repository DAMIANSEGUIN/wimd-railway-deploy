# 🚨 SESSION INITIALIZATION - READ THIS FIRST

**CRITICAL:** Read this ENTIRE file before saying ANYTHING to the user.

---

## 🎯 AUTONOMOUS EXECUTION PROTOCOL

**DEFAULT MODE: AUTONOMOUS EXECUTION**

When the path forward is clear from state files:
1. Read state files
2. Understand what to do
3. State your plan briefly
4. **EXECUTE IMMEDIATELY** (don't wait for permission)

**Only interrupt the user when:**
- ❌ **BLOCKER:** Something prevents progress (missing info, broken dependency, failed validation)
- ❌ **AMBIGUITY:** Task description unclear, requirements missing
- ❌ **MULTIPLE APPROACHES:** Need user preference between valid options
- ❌ **APPROVAL REQUIRED:** Protocol explicitly requires user approval (EnterPlanMode, destructive operations)

---

## ❌ NEVER ASK "WHAT TO WORK ON"

**PROHIBITION:** DO NOT ask the user "What would you like to work on?"

**WHY:** The state files already tell you what to work on. Asking this question is a **protocol failure** that wastes user time.

---

## ✅ CORRECT PATTERN: READ → STATE → EXECUTE

**1. Read state files IMMEDIATELY (silently):**
```bash
cat .mosaic/agent_state.json
cat .mosaic/current_task.json
cat .mosaic/LATEST_HANDOFF.md
```

**2. Extract current task:**
- Current task: `[from agent_state.json: current_task field]`
- Handoff message: `[from agent_state.json: handoff_message field]`
- Success criteria: `[from current_task.json: success_criteria]`
- In progress: `[from current_task.json: in_progress]`

**3. Assess if path is clear:**

**IF PATH IS CLEAR:**
```
I've read the state files.

Current task: [brief task description]
Status: [summarize what's done vs pending]

I'll continue by: [specific action 1, 2, 3]

[IMMEDIATELY START WORK - don't wait for permission]
```

**IF PATH IS UNCLEAR:**
```
I've read the state files.

Current task: [task description]

⚠️ BLOCKER: [specific issue preventing progress]
- Option A: [approach 1]
- Option B: [approach 2]

Which approach would you prefer?
```

---

## 🔴 REQUIRED FIRST ACTIONS (IN ORDER)

Before saying ANYTHING to the user, complete these steps:

### Step 1: Read State Files (Silent)
```bash
cat .mosaic/agent_state.json
cat .mosaic/blockers.json
cat .mosaic/current_task.json
cat .mosaic/LATEST_HANDOFF.md
```

### Step 2: Run Validation (Silent, check status)
```bash
python3 .mosaic/enforcement/test_session_init.py
python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff
./.mosaic/enforcement/session-gate.sh
./scripts/verify_critical_features.sh
./.mosaic/enforcement/test_gates.sh
```

### Step 3: Assess Path Forward
Ask yourself:
- ✅ Do I know what task to work on?
- ✅ Is the next action clear from state files?
- ✅ Are there any blockers?
- ✅ Is there only one valid approach?

**IF ALL YES:** Execute autonomously (Step 4a)
**IF ANY NO:** Ask specific question (Step 4b)

### Step 4a: AUTONOMOUS EXECUTION (Path Clear)
```
✅ State files read - [X/Y tests passed]

Current task: [brief description]
Completed: [list completed items]
In progress: [current work]

I'll continue by:
1. [Specific action 1]
2. [Specific action 2]
3. [Specific action 3]

[IMMEDIATELY USE TOOLS TO START WORK]
```

### Step 4b: ASK QUESTION (Path Unclear)
```
✅ State files read - [X/Y tests passed]

Current task: [brief description]

⚠️ [BLOCKER/AMBIGUITY/CHOICE]:
[Explain specific issue]

[Ask specific question about blocker/ambiguity/choice]
```

---

## 📋 CHECKLIST (Complete Before First Message)

```
□ Read .mosaic/agent_state.json
□ Read .mosaic/current_task.json
□ Read .mosaic/LATEST_HANDOFF.md
□ Read .mosaic/blockers.json
□ Run validation tests (note status)
□ Understand what previous agent accomplished
□ Know what task to continue
□ Assess: Is path forward clear?
  ├─ YES: State plan → Execute immediately
  └─ NO: State blocker → Ask specific question
```

---

## 🚫 ANTI-PATTERNS (NEVER DO THESE)

❌ **Asking "What would you like to work on?"**
- State files tell you what to work on
- This wastes user time
- Indicates you didn't read state files

❌ **Asking "Should I proceed?" when path is clear**
- If state files show clear next steps: EXECUTE
- Don't waste user time asking permission for obvious work
- Only ask when STUCK (blocker/ambiguity/choice)

❌ **Starting work without reading state**
- Duplicates completed work
- Ignores blockers
- Breaks coordination

❌ **Ignoring handoff message**
- Previous agent left critical context
- Missing this causes errors

❌ **Not running validation tests**
- Can't verify previous agent's work succeeded
- May start from broken state

---

## ✅ CORRECT PATTERNS (EXAMPLES)

### Example 1: Autonomous Execution (Clear Path)

```
I've read the state files. Validation: 5/5 post-handoff tests passed.

Current task: Complete production hardening and validation system
Completed: Gate 9 created (5/5 tests pass), state files updated
In progress: Fix SESSION_INIT protocol, integrate Gate 9 into pre-push hook

I'll continue by:
1. Rewriting SESSION_INIT.md for autonomous execution
2. Updating CLAUDE.md Step 0 with new protocol
3. Integrating Gate 9 into .mosaic/enforcement/pre-push hook
4. Running end-to-end deployment test

[STARTS WORK IMMEDIATELY WITH TodoWrite + Edit/Write tools]
```

### Example 2: Ask Question (Path Unclear - Multiple Approaches)

```
I've read the state files. Validation: 5/5 post-handoff tests passed.

Current task: Optimize database query performance
Issue: Multiple optimization strategies available

⚠️ MULTIPLE APPROACHES:
- Option A: Add indexes (faster queries, slower writes)
- Option B: Implement query caching (faster reads, stale data risk)
- Option C: Database connection pooling (better concurrency, more memory)

Which approach would you prefer, or should I implement all three?
```

### Example 3: Ask Question (Blocker)

```
I've read the state files. Validation: 5/5 post-handoff tests passed.

Current task: Deploy backend to production
Blocker identified: Railway credentials missing

⚠️ BLOCKER: Cannot deploy to Railway
- DATABASE_URL not set in environment
- RAILWAY_TOKEN missing

Could you provide the Railway project credentials, or should I set up a new deployment target?
```

---

## 🎯 WHEN TO ASK VS WHEN TO EXECUTE

### ✅ EXECUTE AUTONOMOUSLY (Don't Ask)

- Next steps clearly documented in state files
- Success criteria defined
- No blockers present
- Only one valid approach
- Standard operation (no approval protocol)
- User previously approved work ("proceed", "yes", "approve all actions")

### ❌ ASK QUESTION (Don't Execute)

- **Blocker:** Missing information, broken dependency, failed validation
- **Ambiguity:** Task description unclear, requirements undefined
- **Multiple approaches:** Need user preference (e.g., which library to use)
- **Destructive operation:** Deleting data, force push, irreversible change
- **Approval required:** EnterPlanMode, major architecture change
- **New request:** User just gave new task (summarize and confirm understanding)

---

## 🔗 FULL DOCUMENTATION

After reading this file, read these (in order):
1. `.mosaic/MANDATORY_AGENT_BRIEFING.md` - Prohibitions, dangerous patterns
2. `.ai-agents/CROSS_AGENT_PROTOCOL.md` - 7 mandatory rules
3. `.ai-agents/INTENT_FRAMEWORK.md` - Intent → Check → Receipt
4. `CLAUDE.md` - Architecture overview
5. `DOCUMENTATION_MAP.md` - Canonical index

---

## 🎓 WHY THIS MATTERS

**User Experience Impact:**
- ❌ "Should I proceed?" when path clear → User annoyed, time wasted
- ✅ "I'll do X, Y, Z [starts work]" → User confident, work proceeds

**Coordination Impact:**
- ❌ Asking permission for obvious work → Friction, slow progress
- ✅ Autonomous execution → Seamless handoffs, efficient work

**Time Impact:**
- ❌ Permission-seeking → 2-5 minutes wasted per task
- ✅ Autonomous execution → Immediate productive work

**Trust Impact:**
- ❌ Always asking → User thinks AI can't work independently
- ✅ Execute when clear, ask when stuck → User trusts AI judgment

---

## ⚡ QUICK START (30 Seconds)

```bash
# 1. Read state (5s)
cat .mosaic/agent_state.json
cat .mosaic/current_task.json

# 2. Run validation (10s)
python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff

# 3. Assess path (5s)
# Is next action clear? Yes → Execute. No → Ask.

# 4. Execute or Ask (10s)
# Path clear: State plan + start work immediately
# Path unclear: State blocker + ask specific question
```

---

## 📊 DECISION TREE

```
START
  │
  ├─> Read state files
  │
  ├─> Run validation
  │
  ├─> Assess: Is path forward clear?
  │     │
  │     ├─> YES: Next action clear from state
  │     │     │
  │     │     └─> State plan briefly
  │     │         EXECUTE IMMEDIATELY
  │     │         Report progress as you work
  │     │
  │     └─> NO: Blocker/Ambiguity/Choice
  │           │
  │           └─> State specific issue
  │               Ask targeted question
  │               Wait for user response
  │
  └─> [User provides input]
        │
        └─> Execute with clarification
```

---

**Last Updated:** 2026-01-09 (Autonomous Execution Protocol)
**Status:** ACTIVE - Read this file FIRST in every new session
**Enforcement:** ML-style - validation tests check you read state files
**Key Change:** Default is AUTONOMOUS EXECUTION, not permission-seeking

---

**END OF SESSION INIT**

Now read: `.mosaic/MANDATORY_AGENT_BRIEFING.md`
