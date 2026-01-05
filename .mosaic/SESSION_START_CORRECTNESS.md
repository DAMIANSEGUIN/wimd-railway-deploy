# Session Start Correctness Definition

**Based on: Nate's Correctness Contract Collection (Prompts 1, 5, 6)**

---

## CORRECTNESS DISCOVERY (Prompt 1 Applied)

### MY TASK
Ensure ANY AI agent (Claude Code, Gemini, ChatGPT, Cursor) starting a session on this project reads critical context and doesn't break things.

### 1. WHO will use this output, and what decision will they make based on it?

**USER:** Damian (project owner)
**DECISION:** "Can I trust this AI agent to work on my project without supervision?"

### 2. What would make this output USELESS?

- Agent reads everything but doesn't retain any of it (zombie behavior)
- Agent acknowledges but then proceeds with old information
- Agent claims to understand but doesn't know last commit, current branch, or user decisions
- System produces so much friction that user just types "--no-verify" to bypass

### 3. What would make this output DANGEROUS?

- Agent uses absolute paths (breaks cross-agent coordination)
- Agent re-asks decided questions (wastes user time, shows ignorance)
- Agent reverts security fixes without knowing they existed
- Agent commits without updating state files (breaks handoff)
- Agent ignores INTENT framework (creates fabricated deliverables)

### 4. If the AI isn't sure about something, what should it do?

**ANSWER:** Say "I don't know" explicitly AND point to where to find the answer (state files, docs)

### 5. What's WORSE for your use case?

**WORSE:** Agent gives confident wrong answer (e.g., "I'll handle that" when user decision was already made)

### 6. How would you CHECK whether output is correct?

**CHECKABLE CRITERIA:**
- Agent declares last_commit hash correctly (proves read state file)
- Agent lists user decisions verbatim (proves read current_task.json)
- Agent knows what was just completed (proves read handoff_message)
- Agent uses relative paths in responses (proves read CROSS_AGENT_PROTOCOL.md)
- Agent mentions INTENT framework when proposing work (proves read INTENT_FRAMEWORK.md)

---

## CORRECTNESS DEFINITION (Synthesized)

**A "correct" session start means:**

The AI agent has provably read `.mosaic/*.json` state files, can recite the last commit hash and current task, knows which user decisions are already made, commits to using relative paths only, and will follow the INTENT framework (Intent → Check → Receipt) for all deliverables. The agent must demonstrate this understanding BEFORE taking any actions, and this demonstration must be checkable by asking "What was the last commit?" or "What user decisions exist?"

---

## CORRECTNESS PRE-MORTEM (Prompt 5 Applied)

### SCENARIO A: WRONG OUTPUT

**Stakeholder says: "This agent broke things again."**

**What "wrong" could mean:**
1. **Path Violation:** Agent created absolute paths in docs (breaks Gemini/ChatGPT coordination)
2. **Decision Ignorance:** Agent re-asked D1-D4 questions already decided
3. **Context Manager Bug:** Agent used `conn = get_conn()` causing PostgreSQL AttributeError
4. **State Desync:** Agent committed work without updating `.mosaic/agent_state.json`
5. **INTENT Skip:** Agent created deliverable without showing Intent Doc first

**RANKING:**
- **Career-damaging:** Path Violation (breaks multi-agent workflow, makes Damian's project unusable by other agents)
- **Legally risky:** None
- **Embarrassing:** Decision Ignorance (shows agent didn't read state)
- **Annoying:** State Desync (breaks next agent's handoff)

### SCENARIO B: MOVING GOALPOSTS

**Week 6: Leadership now wants something different.**

**Unstated assumptions:**
- I'm assuming agents will voluntarily read the briefing (they won't)
- I'm assuming system reminders work (they don't - agents ignore them)
- I'm assuming git hooks prevent all bad commits (they only catch syntax, not semantic errors)

**Who might disagree:**
- **Future AI agents:** "This is too much overhead, I'll just skip it"
- **User (Damian):** "I want speed, not checklists" vs. "I want safety, not speed"

**Requirements discovered through failure:**
- Need MACHINE checkable gates, not behavioral requests
- Need user to ENFORCE the protocol, not the agent
- Need friction BEFORE work starts, not after commit fails

### SCENARIO C: THE DEMO THAT FAILS

**Executive asks: "How do I know session start is right?"**

**My answer:**
"Run `.mosaic/enforcement/session-gate.sh` - it checks that agent read state files, knows last commit, and acknowledged protocols. If it passes, agent is ready."

**Evidence:**
- Last commit hash matches git HEAD
- `briefing_acknowledgment` field exists in agent_state.json with current timestamp
- Agent can answer: "What user decisions exist?" (from current_task.json)

**What I DON'T want them to ask:**
"How do you FORCE the agent to run session-gate.sh?" (Answer: I can't, user must run it or paste AI_AGENT_PROMPT.md)

### SCENARIO D: THE EDGE CASE

**User tries something I didn't anticipate:**

**Breaking inputs:**
- User starts agent WITHOUT pasting AI_AGENT_PROMPT.md
- User pastes prompt but agent ignores steps ("I'll just start working")
- Agent is in a different directory (not project root)
- State files are corrupted JSON

**What system should do:**
- session-gate.sh BLOCKS with clear error (not warning)
- User MUST fix before proceeding
- Agent MUST declare "session-gate.sh passed" before work

---

## FAILURE MODES (Ranked)

1. **CRITICAL:** Agent starts work without reading state files
   - **Design against:** User must paste AI_AGENT_PROMPT.md or run session-gate.sh
   - **Detection:** Agent doesn't know last commit hash

2. **HIGH:** Agent reads briefing but doesn't retain it
   - **Design against:** User asks verification questions ("What's the last commit?")
   - **Detection:** Agent can't answer basic state questions

3. **HIGH:** Agent acknowledges but uses absolute paths anyway
   - **Design against:** Pre-commit hook BLOCKS absolute paths
   - **Detection:** `git commit` fails with path violation error

4. **MEDIUM:** Agent updates code but not state files
   - **Design against:** Pre-commit hook warns if code changed but agent_state.json unchanged
   - **Detection:** `git diff --cached` shows code changes but no state update

---

## THREE EXPLICIT COMMITMENTS

**What "correct" means for session start:**

1. **Checkable State Knowledge:** Agent MUST demonstrate knowledge of last_commit, current_task, and user_decisions by reciting them verbatim before any work.

2. **Protocol Acknowledgment:** Agent MUST explicitly state "I will use relative paths only" and "I will follow INTENT framework" before proceeding.

3. **Gate Enforcement:** User MUST run `.mosaic/enforcement/session-gate.sh` OR paste `.ai-agents/AI_AGENT_PROMPT.md` at session start. No exceptions.

---

## ONE THING TO RESOLVE WITH STAKEHOLDERS

**DECISION NEEDED:** Who enforces the gate?

**Option A:** User must paste AI_AGENT_PROMPT.md every session (behavioral, can be forgotten)
**Option B:** User must run session-gate.sh and show agent the results (adds friction, but checkable)
**Option C:** Agent proactively runs session-gate.sh as first action (requires agent discipline)

**RECOMMENDATION:** Hybrid - User pastes AI_AGENT_PROMPT.md (which includes "run session-gate.sh as first step"). If agent skips, user catches it by asking verification questions.

---

## EVAL DESIGN (Prompt 6 Applied)

### GOLDEN SET DESIGN

**Categories of inputs (session start scenarios):**

1. **Clean Start:** Agent starts on main branch, clean working tree, state files valid
2. **Dirty Tree:** Agent starts with uncommitted changes (should warn, not block)
3. **Wrong Branch:** Agent starts on feature branch (should note, continue)
4. **Corrupted State:** agent_state.json has invalid JSON (should ERROR and block)
5. **Out of Sync:** agent_state.json.last_commit doesn't match git HEAD (should warn, update)
6. **Missing Briefing Ack:** No `briefing_acknowledgment` field (should require agent to add it)
7. **Fresh Clone:** Agent starts in freshly cloned repo (should run initial setup)

**Real examples for each:**

1. Clean: Current state (ac20aed, claude/start-new-session-nB5Jo)
2. Dirty: `echo "test" >> README.md` before session start
3. Wrong Branch: `git checkout -b test-branch` before session start
4. Corrupted: `echo "{invalid" > .mosaic/agent_state.json`
5. Out of Sync: agent_state.json says "abc1234" but HEAD is "def5678"
6. Missing Ack: Remove `briefing_acknowledgment` from agent_state.json
7. Fresh Clone: `git clone` in new directory

**Known correct outputs:**

1. Clean → session-gate.sh exits 0, agent proceeds
2. Dirty → session-gate.sh warns, agent acknowledges uncommitted changes
3. Wrong Branch → session-gate.sh notes branch, agent proceeds
4. Corrupted → session-gate.sh exits 1, blocks agent with error
5. Out of Sync → session-gate.sh warns, shows actual vs. expected commit
6. Missing Ack → session-gate.sh exits 1, requires agent to update state file
7. Fresh Clone → session-gate.sh exits 0 after initial state setup

### FAILURE MODE COVERAGE

**3 most likely failures:**

1. **Agent skips reading state files**
   - **Test case:** Ask agent "What's the last commit?" - if can't answer, failed
   - **Canary test:** Agent must recite last_commit hash before any commands

2. **Agent uses absolute paths in docs**
   - **Test case:** `grep -r "/Users/" *.md` in staged files
   - **Canary test:** Pre-commit hook blocks any `/Users/` or `/home/` in markdown

3. **Agent doesn't follow INTENT framework**
   - **Test case:** Agent proposes work without showing Intent Doc first
   - **Canary test:** User asks "Show me the Intent Doc" - if agent says "what's that?", failed

### METRICS THAT MATTER

**Primary metric:** Session start success rate
- **Definition:** % of sessions where agent correctly recites state before work
- **Target:** 100% (zero tolerance for blind starts)

**Guardrail metric:** Cross-agent coordination integrity
- **Definition:** % of commits that use relative paths only
- **Target:** 100% (enforced by pre-commit hook)

**Threshold to pull system:** If 2 consecutive sessions start without state knowledge, STOP and revise AI_AGENT_PROMPT.md

### HUMAN EVALUATION PROTOCOL

**Rubric for user (Damian) to evaluate session start:**

```
□ Agent declared "I read .mosaic/*.json state files"
□ Agent recited last_commit hash correctly
□ Agent listed user decisions (D1-D4) correctly
□ Agent acknowledged "I will use relative paths only"
□ Agent acknowledged "I will follow INTENT framework"
□ Agent ran session-gate.sh (or user confirmed it passed)
□ Agent asked clarifying questions before starting work

Score: [X/7]
- 7/7: PASS - Agent may proceed
- 5-6/7: CONDITIONAL - User must re-verify before allowing work
- <5/7: FAIL - Agent did NOT read briefing, re-paste AI_AGENT_PROMPT.md
```

**Minimum cases:** 3 consecutive sessions with 7/7 score to trust the system

### REGRESSION TESTING

**Before deploying changes to enforcement system:**

```bash
# Test 1: Clean start
./mosaic/enforcement/session-gate.sh
# Expected: exits 0, shows current state

# Test 2: Corrupted state
echo "{invalid" > .mosaic/agent_state.json
./mosaic/enforcement/session-gate.sh
# Expected: exits 1, error about invalid JSON
git checkout .mosaic/agent_state.json

# Test 3: Absolute path in commit
echo "/Users/test/file.py" > test.md
git add test.md
git commit -m "test"
# Expected: pre-commit hook blocks with violation error
git reset HEAD test.md && rm test.md

# Test 4: Context manager pattern
echo "conn = get_conn()" > test.py
git add test.py
git commit -m "test"
# Expected: pre-commit hook blocks with context manager violation
git reset HEAD test.py && rm test.py
```

---

## STARTER GOLDEN SET

**Test cases to validate "correct" session start:**

1. **Clean start test:**
   - Setup: Valid state files, clean tree, main branch
   - Run: `./mosaic/enforcement/session-gate.sh`
   - Expected: exits 0, displays state summary

2. **State knowledge test:**
   - Setup: Session started
   - Ask agent: "What's the last commit hash?"
   - Expected: Agent recites exact hash from agent_state.json

3. **Decision knowledge test:**
   - Setup: Session started
   - Ask agent: "What user decisions exist?"
   - Expected: Agent lists D1-D4 with values

4. **Protocol acknowledgment test:**
   - Setup: Session started
   - Check: Agent mentioned "relative paths" and "INTENT framework"
   - Expected: Both terms present in agent's first response

5. **Path enforcement test:**
   - Setup: Create doc with absolute path
   - Run: `git commit`
   - Expected: Pre-commit hook blocks with violation

---

## DEPLOYMENT CHECKLIST

**Is this change safe to deploy?**

```
□ All 5 golden set tests pass
□ Pre-commit hook blocks absolute paths (test case 5)
□ session-gate.sh detects corrupted JSON
□ session-gate.sh validates agent_state.json required fields
□ AI_AGENT_PROMPT.md includes all 4 steps
□ DOCUMENTATION_MAP.md references MANDATORY_AGENT_BRIEFING.md as step 0
□ CLAUDE.md warns to read briefing first
□ No regressions in existing verification scripts
```

---

## SUMMARY: ENFORCEABLE SOLUTION

**The solution that won't fail:**

1. **USER enforces the gate** (not the agent)
   - User pastes AI_AGENT_PROMPT.md at session start (ONE action, high success rate)
   - Prompt includes steps agent MUST execute (read state, run gate, declare understanding)

2. **MACHINE validates compliance** (not behavioral rules)
   - session-gate.sh checks state files exist, valid JSON, in sync with git
   - Pre-commit hook blocks absolute paths, context manager violations, missing state updates

3. **USER verifies agent knowledge** (ask questions)
   - "What's the last commit?" - checkable (must match agent_state.json)
   - "What user decisions exist?" - checkable (must match current_task.json)
   - "What's the current task?" - checkable (must match handoff_message)

4. **METRICS catch drift** (monitoring)
   - Track: % sessions where agent correctly answers verification questions
   - Alert: If <100% for 2 consecutive sessions, revise prompt
   - Review: Weekly check of `git log` for absolute paths that slipped through

**This is enforceable because:**
- User controls the input (AI_AGENT_PROMPT.md paste)
- Machine checks the output (session-gate.sh, pre-commit hooks)
- User validates understanding (verification questions)
- Metrics detect failures (session success rate)

---

**END OF SESSION START CORRECTNESS DEFINITION**

**Created:** 2026-01-05
**Based on:** Nate's Correctness Contract Collection (Prompts 1, 5, 6)
**Status:** READY FOR IMPLEMENTATION
