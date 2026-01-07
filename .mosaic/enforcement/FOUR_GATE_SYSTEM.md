# Four-Gate Failsafe Enforcement System

**Nuclear-level defense-in-depth for AI agent compliance**

**Created:** 2026-01-08
**Status:** ACTIVE
**Pattern:** Triple-redundant failsafe (like nuclear reactor safety)

---

## Overview

This project uses a **four-gate failsafe system** to ensure AI agents follow protocol. Each gate is **independent** - if one fails, the next catches it.

**Pattern:** Nuclear reactor safety model
- **Primary:** Control rods (stop reaction)
- **Secondary:** Emergency cooling (if rods fail)
- **Tertiary:** Containment vessel (if cooling fails)

**Applied to AI agents:**
- **Gate 1:** Session start validator (catch protocol skip)
- **Gate 2:** Behavior lint (catch forbidden phrases)
- **Gate 3:** Pre-commit hook (block bad commits)
- **Gate 4:** Cross-agent eval (Gemini verifies Claude's work)

---

## Gate 1: Session Start Validator

**When:** New AI agent session starts
**Enforced by:** Human (manual)
**Blocks:** Agents who skip startup protocol

### What It Checks

Validates agent's first response contains evidence of:
- ✅ State files read (Last agent:, Last commit:, Handoff message:)
- ✅ Latest handoff read (SESSION HANDOFF, WHAT WAS BUILT)
- ✅ Post-handoff validation run (POST-HANDOFF VALIDATION, tests passed)
- ✅ Git state checked (git log, git status, Recent commits:)
- ✅ Critical features verified (Authentication UI:, PS101 v2 flow:)

### How to Use

```bash
# Copy agent's first response
# Then run:
echo "agent response here" | python3 .mosaic/enforcement/gate_1_session_start.py

# OR from file:
cat agent_response.txt | python3 .mosaic/enforcement/gate_1_session_start.py
```

### If Gate Fails

Script auto-generates redirect message with:
- ❌ What evidence is missing
- 🔧 Exact commands to run
- 📖 Reference documents to read

**You paste this message to the agent** - forces compliance.

### Example Output

```
⛔ GATE 1 FAILURE: Session Start Protocol Violated
======================================================================

You did NOT execute mandatory startup commands from AI_AGENT_PROMPT.md.

MISSING EVIDENCE:
  ❌ State Files Read
  ❌ Post-Handoff Validation Run

──────────────────────────────────────────────────────────────────────

🔧 CORRECTIVE ACTION REQUIRED:

Execute these commands NOW and show their output:

# State Files Read
cat .mosaic/agent_state.json
cat .mosaic/blockers.json
cat .mosaic/current_task.json

# Post-Handoff Validation Run
python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff

──────────────────────────────────────────────────────────────────────

📖 REFERENCE DOCUMENTS:

  • .ai-agents/AI_AGENT_PROMPT.md (Steps 1-3 MANDATORY)
  • .mosaic/LATEST_HANDOFF.md (Previous session context)
  • .mosaic/agent_state.json

──────────────────────────────────────────────────────────────────────

⚠️  DO NOT ask 'what would you like me to work on' until you:
  1. Execute all commands above
  2. Show their output in your response
  3. Declare what you learned from reading state files

======================================================================
```

---

## Gate 2: Behavior Lint Validator

**When:** Any agent response
**Enforced by:** Human (manual)
**Blocks:** Forbidden behavioral patterns

### Forbidden Patterns

| Trigger Phrase | Requires Context | Violation Type | Severity |
|----------------|------------------|----------------|----------|
| "what would you like me to work on" | Last agent:, Last commit:, Handoff message: | ASKED_FOR_DIRECTION_WITHOUT_READING_STATE | CRITICAL |
| "work complete" | 6/6 tests passed, Validation tests passed | CLAIMED_COMPLETE_WITHOUT_VALIDATION | CRITICAL |
| "should i deploy" | Health check:, Production state: | ASKED_ABOUT_DEPLOY_WITHOUT_CHECKING_STATE | HIGH |
| "i'll update the" | INTENT:, Planning to, Going to | ACTION_WITHOUT_INTENT_DECLARATION | MEDIUM |

### How to Use

```bash
# Check any agent response
echo "agent response here" | python3 .mosaic/enforcement/gate_2_behavior_lint.py

# OR from file:
cat agent_response.txt | python3 .mosaic/enforcement/gate_2_behavior_lint.py
```

### If Gate Fails

Script auto-generates redirect with:
- ❌ What was said (forbidden phrase)
- 📖 Documents to read FIRST
- 📊 Deployment logs to check
- Evidence required before responding

### Example Output

```
⛔ GATE 2 FAILURE: Behavioral Protocol Violation
======================================================================

🚨 1 CRITICAL violation(s) detected

VIOLATION 1: ASKED_FOR_DIRECTION_WITHOUT_READING_STATE
Severity: CRITICAL
──────────────────────────────────────────────────────────────────────
❌ You said: "what would you like me to work on?"
   But you did NOT show:
     • Last agent:
     • Last commit:
     • Handoff message:
     • ✅ State files read

📖 READ THESE DOCUMENTS FIRST:
   cat .mosaic/agent_state.json
   cat .mosaic/LATEST_HANDOFF.md
   cat .ai-agents/AI_AGENT_PROMPT.md (Steps 1-3)

📊 CHECK DEPLOYMENT STATE:
   git log --oneline -5
   git status
   python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff

Then respond with EVIDENCE you read them and checked state.
======================================================================

⚠️  PROTOCOL REQUIREMENT:
  You cannot use forbidden phrases without showing required context.
  Read the docs, check deployment state, THEN respond with evidence.
```

---

## Gate 3: Pre-Commit Hook (Git)

**When:** Agent tries to commit
**Enforced by:** Git (automatic)
**Blocks:** Commits that violate rules

### What It Checks

1. **No absolute paths** in markdown (use relative paths)
2. **Context manager pattern** correct (`with get_conn() as conn:`)
3. **PostgreSQL syntax** (not SQLite)
4. **State file schema** valid JSON with required fields
5. **Agent state updated** when code changes
6. **No secrets** in commits
7. **Commit message format** (conventional commits)
8. **Gemini approval** exists (for handoff commits)

### How It Works

**Automatically runs** when agent does `git commit`.

If violations found:
- ❌ Commit is **PHYSICALLY BLOCKED**
- Shows violation details
- Links to reference docs
- Suggests fixes

Agent **cannot proceed** until violations are fixed.

### Example Output

```
🔒 MOSAIC ENFORCEMENT GATE - Pre-commit validation

📋 Gate 1: Checking for absolute paths in markdown files...
✅ No absolute paths in markdown files

📋 Gate 2: Checking Python context manager pattern...
✅ Context manager pattern correct

📋 Gate 3: Checking for SQLite syntax in Python files...
✅ No SQLite syntax violations

📋 Gate 4: Validating .mosaic/*.json schema...
✅ State files are valid JSON

📋 Gate 5: Checking if agent state was updated this session...
✅ Agent state updated

📋 Gate 6: Checking for secrets in commits...
✅ No secrets detected

📋 Gate 7: Checking commit message format...
✅ Commit message follows conventional format

📋 Gate 8: Checking for Gemini cross-agent approval...
✅ Gemini approved (verdict: APPROVE)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ALL GATES PASSED - Commit allowed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Gate 4: Gemini Cross-Agent Evaluation

**When:** Before marking work "complete"
**Enforced by:** Agent runs script (semi-automatic)
**Blocks:** Work that doesn't meet criteria

### Evaluation Criteria

Gemini evaluates Claude Code's work against:

1. ✅ Did agent run pre-handoff validation tests?
2. ✅ Do validation tests pass (6/6 or all ✅)?
3. ✅ Are state files correct (last_commit matches git HEAD)?
4. ✅ Is handoff_message meaningful (>50 chars, explains what was done)?
5. ✅ Are all commits pushed to origin/main?
6. ✅ Did agent follow INTENT framework?
7. ✅ No absolute paths in documentation?

### Verdict Options

- **APPROVE:** All critical criteria pass → Can commit
- **REQUEST_CHANGES:** Some failures, work is salvageable → Fix and re-run
- **REJECT:** Critical failures, work fundamentally broken → Major fixes needed

### How to Use

```bash
python3 .mosaic/enforcement/gate_4_gemini_eval.py
```

### Example Output

```
🔒 GATE 4: Cross-Agent Evaluation (Gemini)
======================================================================

📊 Generating work summary...
🤖 Calling Gemini for evaluation...

======================================================================
📊 GEMINI VERDICT: APPROVE
Score: 90/100
======================================================================

FEEDBACK:
EVALUATION RESULTS:

✅ Validation tests run: True
✅ State files correct: True
✅ Handoff meaningful: True
✅ Commits pushed: True

✅ GATE 4 PASSED: Gemini approved the work

💾 Verdict saved to /path/to/.mosaic/gemini_approval.json
```

### If Gemini Requests Changes

```
======================================================================
📊 GEMINI VERDICT: REQUEST_CHANGES
Score: 70/100
======================================================================

FEEDBACK:
EVALUATION RESULTS:

✅ Validation tests run: True
✅ State files correct: True
✅ Handoff meaningful: True
❌ Commits pushed: False

⚠️  GATE 4: Gemini requests changes

REQUIRED FIXES:
  - Push all commits to origin/main

Fix these issues and run gate_4_gemini_eval.py again
```

---

## Four-Gate Sequence (Example)

**Scenario:** New Claude Code session starts and immediately asks "what should I do?"

### Defense Layer 1: Gate 1 Catches It

```bash
# Human runs:
echo "what would you like me to work on?" | python3 .mosaic/enforcement/gate_1_session_start.py

# Output: ⛔ GATE 1 FAILURE with exact commands to run
# Human pastes redirect to agent
# Agent forced to execute commands
```

### Defense Layer 2: Gate 2 Catches It (if Gate 1 bypassed)

```bash
# Human runs:
echo "what would you like me to work on?" | python3 .mosaic/enforcement/gate_2_behavior_lint.py

# Output: ⛔ GATE 2 FAILURE with docs to read
# Human pastes redirect to agent
```

### Defense Layer 3: Gate 3 Catches It (if Gates 1 & 2 bypassed)

```bash
# Agent tries: git commit -m "work complete"
# Pre-commit hook runs automatically
# Output: ❌ COMMIT BLOCKED if violations exist
# Agent sees errors and must fix
```

### Defense Layer 4: Gate 4 Catches It (if Gates 1, 2, 3 bypassed)

```bash
# Agent runs: python3 .mosaic/enforcement/gate_4_gemini_eval.py
# Gemini evaluates work
# Output: REQUEST_CHANGES if criteria not met
# Agent must fix issues before commit
```

**Each gate is independent. Each gate provides corrective instructions.**

---

## Integration into AI_AGENT_PROMPT.md

### For Human (Top of Document)

```markdown
## ⚙️ FOR HUMAN: Four-Gate Enforcement System

**If agent violates protocol, run these gates:**

**GATE 1 - Session Start:**
echo "agent response" | python3 .mosaic/enforcement/gate_1_session_start.py

**GATE 2 - Behavior Lint:**
echo "agent response" | python3 .mosaic/enforcement/gate_2_behavior_lint.py

**If either fails, paste auto-generated redirect to agent.**
```

### For Agent (Handoff Section)

```markdown
**When you finish work (HANDOFF):**

STEP 0: RUN VALIDATION TESTS
python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff

STEP 0.5: GET GEMINI EVALUATION
python3 .mosaic/enforcement/gate_4_gemini_eval.py

If Gemini approves, proceed to commit.
Gate 3 (pre-commit hook) will run automatically.
```

---

## Success Metrics

**Measure effectiveness over next 10 sessions:**

1. **Gate 1 Activation Rate:** % of new sessions that violate protocol
   - Baseline: ~80% (before gates)
   - Target: <20% (with gates + enforcement)

2. **Gate 2 Violation Rate:** % of responses with forbidden phrases
   - Baseline: Unknown
   - Target: <10%

3. **Gate 3 Block Rate:** % of commits blocked by pre-commit hook
   - Baseline: Unknown
   - Target: <5% (most violations caught earlier)

4. **Gate 4 Approval Rate:** % of work approved by Gemini on first try
   - Baseline: N/A
   - Target: >70%

5. **Time to Recovery:** Minutes from violation to compliance
   - Baseline: 30-60 minutes (manual redirection)
   - Target: <5 minutes (auto-generated redirects)

---

## Maintenance

### Adding New Forbidden Patterns (Gate 2)

Edit `.mosaic/enforcement/gate_2_behavior_lint.py`:

```python
FORBIDDEN_PATTERNS = [
    {
        "trigger": "new forbidden phrase",
        "also_matches": ["alternate phrase 1", "alternate phrase 2"],
        "requires_context": ["required evidence 1", "required evidence 2"],
        "redirect_to_docs": ["doc1.md", "doc2.md"],
        "deployment_logs": ["command to check state"],
        "violation_type": "DESCRIPTIVE_NAME",
        "severity": "CRITICAL" | "HIGH" | "MEDIUM"
    },
    # ... existing patterns
]
```

### Adding New Gemini Criteria (Gate 4)

Edit `.mosaic/enforcement/gate_4_gemini_eval.py`:

```python
EVALUATION_CRITERIA = [
    {
        "name": "new_criterion",
        "question": "Did agent do X?",
        "evidence": ["string to look for", "or this"],
        # OR
        "check": "description of automated check"
    },
    # ... existing criteria
]
```

### Tightening Enforcement (Grace Period → Strict)

In `.mosaic/enforcement/pre-commit` (Gate 3), change Gate 8:

```bash
# FROM (grace period):
echo "   Proceeding without Gemini approval (not enforced yet)"
# Don't block yet - grace period

# TO (strict enforcement):
echo "   Gemini approval is REQUIRED for handoff commits"
VIOLATIONS=$((VIOLATIONS + 1))
```

---

## Comparison to Previous Attempts

| Approach | Type | Worked? | Why? |
|----------|------|---------|------|
| "MANDATORY" in docs | Behavioral | ❌ No | Agents ignore docs |
| Session start protocol | Behavioral | ❌ No | Agents skip steps |
| session-gate.sh | Technical | ⚠️ Partial | Created but not integrated |
| handoff_validation_tests.py | Technical | ⚠️ Partial | Created but loopholes exist |
| **Four-Gate System** | **Defense-in-depth** | **✅ Testing** | **Multiple independent layers** |

**Key Difference:**
- Previous: Single enforcement point (easy to bypass)
- Four-Gate: Multiple independent layers (one gate fails → next catches it)

---

## Files

- `.mosaic/enforcement/gate_1_session_start.py` - Session start validator
- `.mosaic/enforcement/gate_2_behavior_lint.py` - Behavior lint
- `.mosaic/enforcement/pre-commit` - Pre-commit hook (Gate 3 + Gate 8)
- `.mosaic/enforcement/gate_4_gemini_eval.py` - Gemini cross-agent eval
- `.mosaic/enforcement/handoff_validation_tests.py` - Pre/post handoff tests
- `.ai-agents/AI_AGENT_PROMPT.md` - Updated with gate instructions

---

**Last Updated:** 2026-01-08
**Status:** ACTIVE - Ready for testing
**Next:** Test complete system with new Claude Code session
