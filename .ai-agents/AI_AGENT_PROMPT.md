# AI Agent Initialization Prompt

**Copy/paste this at the start of EVERY new AI agent session (Claude Code, Gemini, ChatGPT, Cursor)**

---

## ⚙️ FOR HUMAN: Four-Gate Enforcement System

**If agent violates protocol, run these gates to auto-generate corrective instructions:**

**GATE 1 - Session Start Validator** (catch agents who skip startup protocol):
```bash
# Copy agent's first response and check it
echo "agent response here" | python3 .mosaic/enforcement/gate_1_session_start.py
# OR: cat agent_response.txt | python3 .mosaic/enforcement/gate_1_session_start.py
```

**GATE 2 - Behavior Lint** (catch forbidden phrases without context):
```bash
# Check any agent response for violations
echo "agent response here" | python3 .mosaic/enforcement/gate_2_behavior_lint.py
```

**If either gate fails, paste the auto-generated redirect message to the agent.**

Gates 3 and 4 run automatically during git commits.

---

## 🤖 FOR AI AGENT: Mandatory Protocol

You are working on the Mosaic Platform project. This project has strict protocols to prevent breaking critical features and ensure cross-agent coordination.

**🚨 MANDATORY FIRST ACTIONS - Do these IN ORDER before ANY other work:**

## Step 0: Read Session Initialization (FIRST!)

**CRITICAL:** Read this BEFORE saying anything to the user:

```bash
cat .mosaic/SESSION_INIT.md
```

**This file prevents the "what would you like to work on?" protocol failure.**

It tells you:
- ❌ NEVER ask "what to work on?" (state files tell you)
- ✅ What to do instead (read state, declare understanding, proceed)
- 📋 Complete checklist to follow

**After reading SESSION_INIT.md, proceed to Step 1.**

## Step 1: Read Current State (Path-Agnostic)

```bash
# Read these 5 state files FIRST (works in any environment):
cat .mosaic/agent_state.json
cat .mosaic/blockers.json
cat .mosaic/current_task.json
cat .mosaic/MANDATORY_AGENT_BRIEFING.md
cat .mosaic/LATEST_HANDOFF.md  # Latest session handoff (if exists)
```

**Declare what you learned:**
```
✅ State files read
   Last agent: [from agent_state.json]
   Last commit: [from agent_state.json]
   Current task: [from agent_state.json]
   Handoff message: [from agent_state.json]
   Known blockers: [count from blockers.json]
   User decisions on record: [list from current_task.json]
```

## Step 2: Run Session Start Verification

**🚨 FIRST: Validate previous agent's handoff (ML-style enforcement)**

```bash
python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff
```

**This test validates:**
- All state files are readable and valid JSON
- Previous agent left a meaningful handoff_message
- session-gate.sh passes without errors
- No missing files referenced in docs
- Production state is determinable from state files

**If validation FAILS:**
- ❌ Previous agent's handoff was incomplete
- ✅ Document the failure in session notes
- ✅ Fix the broken state before proceeding

---

**Then run standard verification:**

```bash
./.mosaic/enforcement/session-gate.sh
./scripts/verify_critical_features.sh
git status
git log --oneline -3
```

**Declare verification results:**
```
✅ Handoff validation: PASSED (previous agent's work verified)
✅ Critical features verified:
   - Authentication UI: [count] references
   - PS101 v2 flow: [count] references
   - API configuration: [status]
   - Current branch: [branch name]
   - Working tree: [clean/dirty]
   - Recent commits: [last 3 commit hashes]

I acknowledge these features MUST BE PRESERVED.
```

## Step 3: Acknowledge Cross-Agent Protocol

**Read these protocol files:**
- `.ai-agents/CROSS_AGENT_PROTOCOL.md` - 7 MANDATORY rules (especially: use RELATIVE PATHS ONLY)
- `.ai-agents/INTENT_FRAMEWORK.md` - Intent → Check → Receipt (mandatory pattern)
- `TEAM_PLAYBOOK_v2.md` - Pre-Flight Instruction Protocol

**Declare protocol understanding:**
```
✅ Cross-Agent Protocol acknowledged
   Rule 1: I will ONLY use relative paths (api/index.py, NOT /Users/.../api/index.py)
   Rule 7: I will use INTENT framework (Intent → Check → Receipt) for all deliverables

✅ User decisions already made (I will NOT re-ask):
   - D1: Use relative paths only → [YES/NO from current_task.json]
   - D2: Archive old docs → [YES/NO]
   - D3: .mosaic/ JSON canonical → [YES/NO]
   - D4: Deployment strategy → [value]

✅ Known blockers status:
   [List resolved/open blockers from blockers.json]
```

## Step 4: If Verification FAILS

```
❌ CRITICAL: Verification failed
🚨 I will NOT proceed until this is resolved

Issues found:
- [List specific failures]

Human action required: [specific steps needed]
```

**Full protocol files to reference:**

- `.mosaic/MANDATORY_AGENT_BRIEFING.md` - Prohibitions, dangerous patterns, context
- `.ai-agents/SESSION_START_PROTOCOL.md` - Full session start procedure
- `.ai-agents/HANDOFF_PROTOCOL.md` - Agent handoff procedures
- `TROUBLESHOOTING_CHECKLIST.md` - Pre-flight checks for code changes
- `DOCUMENTATION_MAP.md` - Central index of all docs

**Critical features that CANNOT be removed:**

1. Authentication UI (authModal, loginForm, registerForm)
2. PS101 v2 flow (PS101State references)
3. API_BASE = '' configuration (relative paths)
4. Chat interface
5. File upload functionality

**Operating rules (ABSOLUTE PROHIBITIONS):**

- ✅ ALWAYS use relative paths in documentation (api/index.py, NOT /Users/.../api/index.py)
- ✅ ALWAYS use context manager pattern for database (`with get_conn() as conn:`)
- ✅ ALWAYS use PostgreSQL syntax (%s, SERIAL, not ? or AUTOINCREMENT)
- ✅ ALWAYS follow INTENT framework (Intent → Check → Receipt)
- ✅ Run `./scripts/verify_critical_features.sh` before EVERY deploy
- ✅ Never remove critical features without explicit human approval
- ✅ Never use `git commit --no-verify` without approval
- ✅ Never re-ask user decisions already in `.mosaic/current_task.json`
- ✅ Never replace files (like copying frontend → mosaic_ui) without checking for feature loss
- ✅ Follow pre-commit hook warnings (they block destructive changes)
- ✅ Run deployment verification checklist after every deploy
- ❌ NEVER create absolute paths in documentation (breaks cross-agent coordination)
- ❌ NEVER use `conn = get_conn()` directly (causes AttributeError)
- ❌ NEVER skip reading `.mosaic/*.json` state files first

**Pre-commit hook installed:**

- Blocks commits that remove authentication
- Blocks commits that remove PS101 flow
- Blocks database anti-patterns
- You will see errors if you try to commit breaking changes

**When you finish work (HANDOFF):**

**🚨 STEP 0: RUN VALIDATION TESTS (ML-STYLE ENFORCEMENT) - DO NOT SKIP**

```bash
python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff
```

**This test suite BLOCKS handoff until:**
- All state files exist and are valid JSON
- Production state claims match git reality (no unpushed work)
- All referenced files actually exist
- Git status is clean OR uncommitted changes are documented
- Blockers marked "resolved" have evidence

**If tests FAIL:**
- ❌ DO NOT mark work "complete"
- ❌ DO NOT tell user "ready for handoff"
- ✅ Fix the failures first
- ✅ Run tests again until passing

**This is TECHNICAL enforcement (tests block you), not behavioral (docs ask you to check).**

---

**🚨 STEP 0.5: GET GEMINI CROSS-AGENT EVALUATION (GATE 4)**

```bash
python3 .mosaic/enforcement/gate_4_gemini_eval.py
```

**Gemini evaluates your work against:**
- Did you run validation tests?
- Do validation tests pass?
- Are state files correct (last_commit matches git HEAD)?
- Is handoff_message meaningful (>50 chars)?
- Are commits pushed to origin/main?
- Did you follow INTENT framework?
- No absolute paths in docs?

**If Gemini verdict is REQUEST_CHANGES or REJECT:**
- ❌ DO NOT commit
- ✅ Read Gemini's feedback (shown in output)
- ✅ Fix required issues
- ✅ Run gate_4_gemini_eval.py again

**If Gemini verdict is APPROVE:**
- ✅ Gemini approval saved to `.mosaic/gemini_approval.json`
- ✅ Gate 3 (pre-commit hook) will verify approval exists
- ✅ Proceed to commit

---

**After validation tests PASS and Gemini APPROVES:**

1. Update `.mosaic/agent_state.json`:
   - Set `last_commit` to current git HEAD
   - Update `handoff_message` with what was done and what's next
   - Update `implementation_progress` if applicable
   - Add `briefing_acknowledgment` with current timestamp

2. Update `.mosaic/session_log.jsonl` (append only):
   ```json
   {"timestamp":"[ISO 8601]","agent":"[your name]","mode":"[HANDOFF]","action":"[what you did]","outcome":"[result]"}
   ```

3. Update `.mosaic/blockers.json` if you resolved any blockers

4. Commit your work with conventional commit format:
   ```bash
   git add -A
   git commit -m "type(scope): description"
   ```

   **GATE 3 (Pre-Commit Hook) will automatically:**
   - Verify Gemini approval exists
   - Run final validation checks
   - Block commit if anything fails

5. Tell human: "Work complete. Validation tests passed. Gemini approved. State files updated. Ready for next agent."

**Session log:**

- Your actions are logged in `.mosaic/session_log.jsonl` (append-only, JSONL format)
- State is tracked in `.mosaic/agent_state.json` (current state)
- Handoffs use the `handoff_message` field in agent_state.json

---

**🚨 ACKNOWLEDGMENT REQUIRED:**

Before proceeding with any work, you MUST:
1. Execute Steps 1-3 above (read state, verify features, acknowledge protocols)
2. Declare your understanding of current state and user decisions
3. State what you're about to work on
4. Wait for human confirmation before proceeding

**This acknowledgment is machine-enforceable via the user's first message to you.**
