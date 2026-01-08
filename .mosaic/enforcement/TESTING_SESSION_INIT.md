# SESSION_INIT Protocol Testing Guide

**Purpose:** Verify SESSION_INIT.md exists and will prevent "what would you like to work on?" protocol failure.

---

## Quick Start

**Run this at the start of EVERY new session:**

```bash
python3 .mosaic/enforcement/test_session_init.py
```

**Expected output:**
```
✅ Tests passed: 8
❌ Tests failed: 0

✅ All SESSION_INIT protocol tests passed!

This means:
- SESSION_INIT.md exists and is comprehensive
- AI_AGENT_PROMPT.md references it as Step 0
- State files exist and have current task info
- New Claude sessions should NOT ask 'what to work on?'
- New Claude sessions should read state and continue task
```

**If any tests fail:**
```
❌ Tests failed: 1

❌ FAILURES:
  - [Specific failure message]

Next steps:
1. Review failures above
2. Fix SESSION_INIT.md or state files
3. Re-run this test
```

---

## What Gets Tested

### Test 1: SESSION_INIT.md Exists
- **Tests:** File `.mosaic/SESSION_INIT.md` exists and is readable
- **Should:** PASS (file must exist)
- **Failure:** File missing or unreadable

### Test 2: SESSION_INIT.md is Substantial
- **Tests:** File is at least 5KB (comprehensive guide, not stub)
- **Should:** PASS (file must be detailed)
- **Failure:** File too small (incomplete)

### Test 3: SESSION_INIT.md Has Required Content
- **Tests:** File contains all required elements:
  - "NEVER ASK" prohibition
  - "what to work on?" anti-pattern
  - "protocol failure" recognition
  - "Read state files" instruction
  - References to state files (agent_state.json, current_task, handoff_message)
  - "Should I proceed?" correct question
  - CHECKLIST section
  - ANTI-PATTERNS section
  - CORRECT PATTERN section
- **Should:** PASS (all 11 elements present)
- **Failure:** Missing key content

### Test 4: AI_AGENT_PROMPT.md References SESSION_INIT
- **Tests:** AI_AGENT_PROMPT.md has:
  - "Step 0" section
  - Reference to SESSION_INIT.md
  - Command to read file (`cat .mosaic/SESSION_INIT.md`)
  - "FIRST" emphasis
  - "protocol failure" mention
- **Should:** PASS (SESSION_INIT properly integrated)
- **Failure:** Not referenced in prompt

### Test 5: Referenced State Files Exist
- **Tests:** Files exist:
  - `.mosaic/agent_state.json`
  - `.mosaic/current_task.json`
  - `.mosaic/blockers.json`
- **Should:** PASS (state files present)
- **Failure:** State files missing

### Test 6: State Files are Valid JSON
- **Tests:** All state files parse as valid JSON
- **Should:** PASS (no syntax errors)
- **Failure:** JSON parse errors

### Test 7: agent_state.json Has Required Fields
- **Tests:** agent_state.json contains:
  - `current_task` field (not empty)
  - `handoff_message` field (substantial, >50 chars)
  - `last_agent` field
- **Should:** PASS (new session knows what to work on)
- **Failure:** Missing fields or empty content
- **Warning:** If current_task empty or handoff_message too short

### Test 8: MANDATORY_AGENT_BRIEFING.md Exists
- **Tests:** File `.mosaic/MANDATORY_AGENT_BRIEFING.md` exists
- **Should:** PASS (referenced by SESSION_INIT)
- **Failure:** File missing

---

## Understanding Test Results

### All Tests Pass
```
✅ Tests passed: 8
❌ Tests failed: 0
```
**Meaning:** SESSION_INIT protocol is correctly configured. New Claude sessions should automatically read state and continue work.

### Warnings (Non-Blocking)
```
⚠️  Warnings: 1
  - current_task is empty (new session won't know what to work on)
```
**Meaning:** Tests pass but there's a potential issue. New sessions might not have enough context.

**Action:** Update agent_state.json with meaningful current_task.

### Failures (Blocking)
```
❌ Tests failed: 1
  - SESSION_INIT.md missing: Prohibition against asking 'what to work on?'
```
**Meaning:** SESSION_INIT.md is incomplete or incorrect.

**Action:** Add missing content to SESSION_INIT.md.

---

## Integration with Session Start

**Add to session start protocol (AI_AGENT_PROMPT.md Step 2):**

```bash
# Validate SESSION_INIT protocol
python3 .mosaic/enforcement/test_session_init.py
```

**Why:** Verifies that if you're starting a new session, you have all the information needed to continue work without asking "what to work on?"

---

## Manual Verification (For Humans)

**To verify new Claude sessions follow protocol:**

1. **Start a new Claude session** (new terminal, new browser tab, etc.)

2. **Observe first message from Claude**

   ✅ **CORRECT:**
   ```
   I've read the state files. Current task: [specific task].
   Handoff message: [summary of previous work].

   I will continue by: [specific next action].

   Should I proceed?
   ```

   ❌ **INCORRECT (Protocol Failure):**
   ```
   Hello! What would you like to work on?
   ```

3. **If Claude asks "what to work on?":**
   - This is a protocol failure
   - Claude did NOT read SESSION_INIT.md
   - Paste SESSION_INIT.md contents or remind Claude to read `.mosaic/SESSION_INIT.md`

---

## What SESSION_INIT Protocol Prevents

### Before (Protocol Failure)
```
User: [starts new session]
Claude: "Hello! What would you like to work on today?"
User: [frustrated] "Read the state files! The task is documented!"
Claude: "Let me read agent_state.json..."
[5 minutes wasted]
```

### After (Protocol Working)
```
User: [starts new session]
Claude: "I've read the state files. Current task: Fix Gate 8 enforcement.
Previous agent completed validation tests. I'll continue by updating
pre-commit hook. Should I proceed?"
User: "Yes" [immediately productive]
```

---

## Troubleshooting

### Test fails: "SESSION_INIT.md doesn't exist"
```bash
# Verify file location
ls -la .mosaic/SESSION_INIT.md

# If missing, it was deleted or not committed
git log --all --full-history -- .mosaic/SESSION_INIT.md

# Restore from git
git checkout origin/main -- .mosaic/SESSION_INIT.md
```

### Test fails: "SESSION_INIT.md too small"
```bash
# Check file size
wc -c .mosaic/SESSION_INIT.md

# Should be >5000 bytes (5KB)
# If smaller, file was truncated or is incomplete
```

### Test fails: "Missing required element: [X]"
```bash
# Check what's missing
grep -i "[keyword]" .mosaic/SESSION_INIT.md

# If not found, add the missing section
# Use git to see what changed:
git diff .mosaic/SESSION_INIT.md
```

### Test warns: "current_task is empty"
```bash
# Check current task
jq -r '.current_task' .mosaic/agent_state.json

# If empty or generic, update with specific task
# Edit .mosaic/agent_state.json to add meaningful current_task
```

---

## Success Criteria

✅ **Protocol working** when:
- Test suite passes (8/8 tests)
- No warnings (or only non-critical warnings)
- New Claude sessions immediately state what they'll work on
- New Claude sessions DON'T ask "what to work on?"

❌ **Protocol broken** when:
- Any test fails
- current_task is empty
- New Claude sessions ask "what to work on?"
- New Claude sessions don't read state files

---

## Files Tested

- `.mosaic/SESSION_INIT.md` - Main protocol file
- `.ai-agents/AI_AGENT_PROMPT.md` - Must reference SESSION_INIT as Step 0
- `.mosaic/agent_state.json` - Must have current_task and handoff_message
- `.mosaic/current_task.json` - Must exist
- `.mosaic/blockers.json` - Must exist
- `.mosaic/MANDATORY_AGENT_BRIEFING.md` - Must exist

---

**Last Updated:** 2026-01-08
**Status:** ACTIVE - Run this test in every new session
**Enforcement:** ML-style - test blocks if protocol broken (exit code 1)

---

**END OF SESSION_INIT TESTING GUIDE**
