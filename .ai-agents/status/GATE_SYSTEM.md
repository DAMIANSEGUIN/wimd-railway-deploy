# MCP Gate-Based Coordination System

**Purpose:** Enable autonomous agent coordination without human intervention

---

## How It Works

Each agent monitors `.ai-agents/status/*.complete` files to determine their next task.

### Gate File Format

**Filename:** `<phase>_<task>_<agent>.complete`

**Content:**
```json
{
  "task": "phase1_task1c",
  "agent": "gemini",
  "completed_at": "2025-12-10T10:15:00Z",
  "deliverables": [
    ".ai-agents/session_context/trigger_detector.py",
    "tests/test_trigger_detector.py"
  ],
  "validation_status": "passed",
  "next_gate": "phase1_validation"
}
```

---

## Phase 1 Gates

### Gate 1: Task 1A Complete (Claude Code)
**File:** `phase1_task1a_claude.complete`
**Triggers:** Nothing (waits for Task 1C)

### Gate 2: Task 1C Complete (Gemini)
**File:** `phase1_task1c_gemini.complete`
**Triggers:** Phase 1 validation (Claude Code checks both 1A + 1C done)

### Gate 3: Phase 1 Validation Complete (Claude Code)
**File:** `phase1_validation.complete`
**Triggers:** Phase 2 Task 2.1 (Gemini starts broker work)

---

## Phase 2 Gates

### Gate 4: Task 2.1 Complete (Gemini)
**File:** `phase2_task2.1_gemini.complete`
**Triggers:** Task 2.2 (structured logging - Codex or Claude)

### Gate 5: Task 2.2 Complete
**File:** `phase2_task2.2_<agent>.complete`
**Triggers:** Task 2.3 (handoff protocols - all agents)

---

## Agent Responsibilities

### On Session Start, Each Agent Must:

1. **Check for their trigger:**
   ```bash
   ls .ai-agents/status/*.complete
   ```

2. **Read MCP Master Checklist:**
   - Find their next incomplete task
   - Check if dependencies (gates) are satisfied

3. **If gates satisfied:**
   - Execute the task
   - Write completion gate file
   - Update master checklist

4. **If gates NOT satisfied:**
   - Report status
   - Wait (do nothing)

---

## Implementation

### For Each Agent

**On every session start, run:**

```bash
#!/bin/bash
# .ai-agents/scripts/check_my_gates.sh

AGENT_NAME="$1"  # "claude", "gemini", "codex"

# Find my next task
NEXT_TASK=$(python3 .ai-agents/scripts/get_next_task.py "$AGENT_NAME")

if [ "$NEXT_TASK" = "none" ]; then
    echo "✅ No tasks assigned to $AGENT_NAME"
    exit 0
fi

# Check if dependencies met
DEPS_MET=$(python3 .ai-agents/scripts/check_dependencies.py "$NEXT_TASK")

if [ "$DEPS_MET" = "true" ]; then
    echo "🚀 Starting: $NEXT_TASK (dependencies satisfied)"
    # Agent proceeds with task
else
    echo "⏳ Waiting: $NEXT_TASK (dependencies not met)"
    echo "   Missing: $(cat /tmp/missing_deps)"
    exit 0
fi
```

---

## Master Checklist Integration

The **single source of truth** is:
`docs/MCP_V1_1_MASTER_CHECKLIST.md`

Each task has:
- **Assigned agent**
- **Dependencies** (which gates must exist)
- **Deliverables** (what to create)
- **Next gate** (what file to write on completion)

---

## Example: Gemini's Next Task

**Current state:**
- ✅ `phase1_task1a_claude.complete` exists
- ✅ `phase1_task1c_gemini.complete` exists
- ✅ `phase1_validation.complete` exists (just created)

**Gemini checks:**
```python
next_task = get_next_task("gemini")
# Returns: "phase2_task2.1_broker_integration"

deps = get_dependencies("phase2_task2.1_broker_integration")
# Returns: ["phase1_validation.complete"]

deps_met = check_dependencies(deps)
# Returns: True (phase1_validation.complete exists)

# → Gemini auto-starts Phase 2 Task 2.1
```

**No human intervention needed.**

---

## Benefits

1. **Autonomous:** Agents self-coordinate
2. **Declarative:** Master checklist defines workflow
3. **Observable:** Status directory shows progress
4. **Reversible:** Delete gate files to re-trigger
5. **Zero human overhead:** You just check final results

---

## Implementation Priority

**Critical for Phase 2:**
- Create gate files for completed Phase 1 tasks
- Implement `get_next_task.py` and `check_dependencies.py`
- Update master checklist with gate specifications

**This should have been done in Phase 1.** Implementing now.
