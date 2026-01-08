# 🚨 SESSION INITIALIZATION - READ THIS FIRST

**CRITICAL:** Read this ENTIRE file before saying ANYTHING to the user.

---

## ❌ NEVER ASK "WHAT TO WORK ON"

**PROHIBITION:** DO NOT ask the user "What would you like to work on?"

**WHY:** The state files already tell you what to work on. Asking this question is a **protocol failure** that wastes user time.

---

## ✅ WHAT TO DO INSTEAD

**1. Read state files IMMEDIATELY:**
```bash
cat .mosaic/agent_state.json
cat .mosaic/current_task.json
cat .mosaic/LATEST_HANDOFF.md
```

**2. Extract current task:**
- Current task: `[from agent_state.json: current_task field]`
- Handoff message: `[from agent_state.json: handoff_message field]`
- Next steps: `[from LATEST_HANDOFF.md]`

**3. State what you'll work on:**
```
I've read the state files. Current task: [describe task].
Handoff message: [summarize handoff].

I will continue by: [specific next action].

Should I proceed?
```

**4. Wait for user confirmation**

---

## 🔴 REQUIRED FIRST ACTIONS (IN ORDER)

Before saying ANYTHING to the user, complete these steps:

### Step 1: Read State Files
```bash
cat .mosaic/agent_state.json
cat .mosaic/blockers.json
cat .mosaic/current_task.json
cat .mosaic/LATEST_HANDOFF.md
```

### Step 2: Run Validation
```bash
python3 .mosaic/enforcement/test_session_init.py  # Verify SESSION_INIT protocol
python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff
./.mosaic/enforcement/session-gate.sh
./scripts/verify_critical_features.sh
./.mosaic/enforcement/test_gates.sh  # Verify enforcement working
```

### Step 3: Acknowledge Protocols
```bash
cat .ai-agents/CROSS_AGENT_PROTOCOL.md  # 7 mandatory rules
cat .ai-agents/INTENT_FRAMEWORK.md     # Intent → Check → Receipt
cat TEAM_PLAYBOOK_v2.md                 # Pre-Flight Instruction Protocol
```

### Step 4: Declare Understanding
State to user:
```
✅ State files read
   Last agent: [name]
   Current task: [task]
   Handoff: [summary]

✅ Validation passed
   Post-handoff: X/Y tests passed
   Session gate: [status]
   Critical features: [status]

✅ Protocols acknowledged
   Rule 1: Relative paths only
   Rule 7: INTENT framework for all deliverables

I will continue by: [specific action]

Should I proceed?
```

---

## 📋 CHECKLIST (Complete Before First Message)

```
□ Read .mosaic/agent_state.json
□ Read .mosaic/current_task.json
□ Read .mosaic/LATEST_HANDOFF.md
□ Run SESSION_INIT protocol test
□ Run post-handoff validation
□ Run session-gate.sh
□ Understand what previous agent accomplished
□ Know what task to continue
□ State specific next action
□ Ask "Should I proceed?" (NOT "What to work on?")
```

---

## 🎯 CURRENT STATE (Auto-Generated)

**Run these commands to get current state:**
```bash
# Current task
jq -r '.current_task' .mosaic/agent_state.json

# Handoff message
jq -r '.handoff_message' .mosaic/agent_state.json

# Last agent
jq -r '.last_agent' .mosaic/agent_state.json

# Implementation progress
jq -r '.implementation_progress' .mosaic/agent_state.json
```

---

## 🚫 ANTI-PATTERNS (NEVER DO THESE)

❌ **Asking "What would you like to work on?"**
- State files tell you what to work on
- This wastes user time
- Indicates you didn't read state files

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

## ✅ CORRECT PATTERN (EXAMPLE)

```
[Agent reads state files silently]

Agent: I've read the state files. The previous agent (claude_code_sonnet_4_5)
completed fixing the circular dependency in the validation system.

Current task: Gate 8 enforcement was just fixed to use ML-style blocking
instead of behavioral warnings.

Handoff message indicates all validation tests passed (8/8 gates working).

I will continue by creating SESSION_INIT.md to fix the "what would you
like to work on" protocol failure as discussed.

Should I proceed?
```

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
- ❌ "What to work on?" → User frustrated, must repeat context
- ✅ "I'll continue [specific action]" → User confident, work proceeds

**Coordination Impact:**
- ❌ Asking → Previous agent's work ignored
- ✅ Continuing → Seamless handoffs

**Time Impact:**
- ❌ Asking → 2-5 minutes wasted explaining context
- ✅ Continuing → Immediate productive work

---

## ⚡ QUICK START (30 Seconds)

```bash
# 1. Read state (5s)
cat .mosaic/agent_state.json

# 2. Run validation (10s)
python3 .mosaic/enforcement/test_session_init.py
python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff

# 3. Declare (15s)
# [State what you learned and what you'll do]

# 4. Ask confirmation
# "Should I proceed?"
```

---

**Last Updated:** 2026-01-08
**Status:** ACTIVE - Read this file FIRST in every new session
**Enforcement:** ML-style - validation tests check you read state files

---

**END OF SESSION INIT**

Now read: `.mosaic/MANDATORY_AGENT_BRIEFING.md`
