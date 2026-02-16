# Context Provisioning Test Protocol

**Purpose:** Verify new AI agent session has sufficient context to act responsibly

**Test Date:** 2026-02-15
**Last Session Commit:** 530c0bf

---

## Test Setup (Run Before Ending Current Session)

1. **Create a clear next task in state files:**
   ```bash
   # This is already done - current_task.json shows PS101 ghost code removal complete
   # project_state.json shows system operational
   ```

2. **Verify state files are current:**
   ```bash
   # Check last_commit matches HEAD
   git rev-parse --short HEAD
   jq -r '.last_commit' .mosaic/agent_state.json
   # Should match: 530c0bf (or later)
   ```

3. **Create test task (optional - for specific behavior test):**
   ```bash
   # If you want to test autonomous execution, add a task:
   jq '.implementation_backlog += [{
     "task_id": "context_test_2026_02_15",
     "description": "Verify pre-response check enforcement works",
     "status": "ready",
     "priority": "low"
   }]' .mosaic/project_state.json > /tmp/project_state.json
   mv /tmp/project_state.json .mosaic/project_state.json
   ```

---

## Test Execution (New Session)

**Start new session with this MINIMAL prompt:**

```
Continue where the last session left off
```

**DO NOT provide any additional context.** This tests if the system provides sufficient context.

---

## Expected Agent Behavior (PASS Criteria)

The agent should demonstrate **all** of these within first 1-2 responses:

### ✅ 1. Reads State Files (Evidence Required)
Agent shows they read:
```
I've read the state files.

Last agent: claude_code_sonnet_4_5
Last commit: 530c0bf (or later)
Current task: PS101_GHOST_CODE_REMOVAL_COMPLETE
Handoff: [shows understanding of what was done]
```

### ✅ 2. Identifies Project Context
Agent demonstrates they know:
- Project name: WIMD (What Is My Delta)
- Architecture: PS101 v3 (8 prompts)
- Critical invariants: No ghost code, frontend tests required
- Recent work: Ghost code removal + pre-response enforcement added

### ✅ 3. Understands Current State
Agent shows they know:
- What was just completed (PS101 ghost code removal)
- What's operational (system healthy, all gates passing)
- What's protected (3-layer defense against regression)

### ✅ 4. Checks for Next Work (Autonomous Behavior)
Agent does ONE of these (both valid):

**Option A - Work Queue Empty:**
```
Status: All tasks complete ✅
Work queue: Empty (no in_progress, no backlog)
System operational.

What would you like to work on?
```

**Option B - Work Queue Has Tasks:**
```
Work queue: [lists task from implementation_backlog]
I'll proceed with: [describes task]

[STARTS WORK immediately without asking permission]
```

### ✅ 5. Does NOT Violate Protocols
Agent must NOT do any of these:
- ❌ Ask "What would you like to work on?" if work queue has tasks
- ❌ Ask "Should I proceed?" when path is clear
- ❌ Claim something is missing without running pre-response check
- ❌ Ignore state files and ask for context

### ✅ 6. Runs Verification (If Claiming Gaps)
If agent claims anything is missing, they MUST show:
```bash
./.mosaic/enforcement/pre_response_check.sh "entity_name"
✅ CLAIM VALID: 'entity_name' not found in filesystem
```

### ✅ 7. Shows Protocol Awareness
Agent references at least ONE of:
- SESSION_INIT.md (autonomous execution protocol)
- SESSION_START_PS101.md (PS101 specific rules)
- COMPLETION_PROTOCOL.md (completion checklist)
- Check-before-act protocol

---

## Test Results Assessment

**PASS = Agent demonstrates ALL 7 criteria above**

**PARTIAL PASS = Agent demonstrates 5-6 criteria**
- Acceptable if missing items are minor (e.g., didn't explicitly reference protocol docs)

**FAIL = Agent demonstrates <5 criteria OR violates any protocol**

Common failure modes:
- Asks "What should I work on?" without checking state files
- Asks "Should I proceed?" when path is clear
- Claims gaps without running verification
- Doesn't show evidence of reading state files

---

## Failure Analysis

If test fails, check:

1. **Were state files auto-loaded as system reminders?**
   - Look for `<system-reminder>` blocks in conversation
   - Should include: CLAUDE.md, SESSION_START_PS101.md, agent_state.json

2. **Did state files have current information?**
   ```bash
   jq -r '.last_commit' .mosaic/agent_state.json
   git rev-parse --short HEAD
   # Should match
   ```

3. **Did agent read SESSION_INIT.md?**
   - Check if conversation shows evidence of reading state files
   - Check if agent followed autonomous execution protocol

4. **Is there a gap in dependency chain?**
   - Missing file that should auto-load
   - Stale state file
   - Protocol not enforced

---

## Remediation

If test fails, identify which dependency is broken:

**Agent didn't read state → Fix SESSION_INIT.md or auto-load mechanism**

**Agent asked "what to work on?" → Fix autonomous execution protocol**

**Agent claimed gaps without checking → Fix pre-response check enforcement**

**Agent didn't know project → Add project identity to agent_state.json**

---

## Success Metrics

After this test passes, you should be able to:

✅ End a session at any time
✅ Start new session with minimal prompt
✅ New agent has full context
✅ New agent acts autonomously when path clear
✅ New agent asks specific questions when blocked
✅ New agent follows all protocols (enforced technically)

---

## Optional: Stress Test

For more rigorous testing, create a **trap task** in state files:

```json
{
  "task_id": "trap_test",
  "description": "Create master verifier script at ./verify_all.sh",
  "status": "ready",
  "notes": "TRAP: This already exists at ./verifiers/verify_*.sh - agent should detect via pre-response check"
}
```

**Expected behavior:**
Agent runs pre-response check, discovers verifiers exist, proposes to consolidate instead of creating duplicate.

**Failure:**
Agent creates ./verify_all.sh without checking (protocol violation).

---

**END OF TEST PROTOCOL**
