# 🚨 MANDATORY AGENT BRIEFING - READ BEFORE ANY ACTIONS

**⚠️ ENFORCEMENT: You MUST read this entire document before executing ANY commands, making ANY code changes, or reading ANY other files.**

**Failure to read this briefing WILL result in destructive consequences:**
- Breaking cross-agent coordination system
- Reverting critical security fixes
- Creating absolute path references that break for other agents
- Ignoring user decisions already made
- Duplicating work already completed

---

## CRITICAL: Current State (2026-01-05)

**Branch:** `claude/start-new-session-nB5Jo` (feature branch)
**Last Commit:** `ac20aed` (docs: Update session state - all work complete)
**Status:** Implementation complete, NOT YET DEPLOYED
**Next Action Required:** Merge to main → Deploy to production

### What Was Just Completed

**Major Implementation (Jan 5, 2026):**
1. Cross-agent coordination system (7-phase implementation)
2. Path-agnostic state management (`.mosaic/*.json` files)
3. INTENT Framework integration (Intent → Check → Receipt pattern)
4. Mosaic MVP security fixes (Claude API timeout + retry)
5. Documentation consolidation (DOCUMENTATION_MAP.md)
6. Render deployment guide (GitHub-based strategy)

**User Decisions Already Made (DO NOT RE-ASK):**
- D1: Use relative paths only → **YES** (approved)
- D2: Archive old session docs → **YES** (approved)
- D3: .mosaic/ JSON as canonical state → **YES** (approved)
- D4: GitHub-based Render deployment → **YES** (approved)

**Blockers Resolved:**
- B002: Render deployment timeout → Resolved (GitHub strategy)
- B003: Render CLI linking → Resolved (no longer needed)
- B004: Documentation overload → Resolved (archived + map)

---

## 🔴 MANDATORY FIRST ACTIONS (IN THIS ORDER)

**Before doing ANYTHING else, execute these commands:**

```bash
# 1. Verify you're in the right directory
pwd
# Should be: /Users/damianseguin/WIMD-Deploy-Project

# 2. Check current branch
git branch --show-current
# Should be: claude/start-new-session-nB5Jo OR main

# 3. Read canonical state (MANDATORY)
cat .mosaic/current_task.json
cat .mosaic/blockers.json
cat .mosaic/agent_state.json
cat .mosaic/session_log.jsonl

# 4. Check working tree status
git status

# 5. Review recent commits
git log --oneline -5
```

**After reading state files, read these documents IN ORDER:**

1. `.mosaic/agent_state.json` - Last agent, current task, handoff message
2. `.mosaic/blockers.json` - Known blockers and resolutions
3. `.ai-agents/CROSS_AGENT_PROTOCOL.md` - 7 mandatory rules
4. `.ai-agents/INTENT_FRAMEWORK.md` - Intent → Check → Receipt pattern
5. `DOCUMENTATION_MAP.md` - Canonical documentation index
6. `RAILWAY_DEPLOYMENT_GUIDE.md` - Deployment instructions

**Only AFTER reading these 6 files should you proceed with any work.**

---

## 🚫 ABSOLUTE PROHIBITIONS (NEVER DO THESE)

### 1. NEVER Use Absolute Paths
```
❌ WRONG: /Users/damianseguin/WIMD-Deploy-Project/api/index.py
✅ CORRECT: api/index.py
```

**Why:** Other AI agents (Gemini, ChatGPT) work in different environments. Absolute paths break cross-agent coordination.

### 2. NEVER Skip INTENT Framework
Before creating ANY deliverable (code, docs, analysis):
1. **Show INTENT DOC** (Task, Scope, Sources, Constraints, Uncertainties)
2. **Wait for user confirmation** (Proceed/Adjust/Stop)
3. **Provide RECEIPT** (What was done, sources used, judgment calls)

**Why:** Prevents fabrication, ensures alignment, maintains quality.

### 3. NEVER Modify These Files Without Reading State First
- `CLAUDE.md` - Main reference (read `.mosaic/*.json` first)
- `TEAM_PLAYBOOK_v2.md` - Team contract (INTENT is now step 0)
- `.ai-agents/CROSS_AGENT_PROTOCOL.md` - Coordination rules
- `.mosaic/*.json` - State files (authoritative source of truth)

### 4. NEVER Re-Ask Decided Questions
User has already decided:
- Relative paths only (YES)
- Archive old docs (YES)
- .mosaic/ JSON canonical (YES)
- GitHub deployment (YES)

**Re-asking these wastes user time and shows you didn't read this briefing.**

### 5. NEVER Commit Without Context Manager Pattern
All database operations MUST use:
```python
✅ CORRECT:
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))

❌ WRONG:
conn = get_conn()
cursor = conn.execute("...")  # Causes AttributeError!
```

### 6. NEVER Deploy Without Testing
Before any deployment:
- Run validation tests
- Check health endpoint locally
- Verify PostgreSQL connection (not SQLite fallback)
- Review git diff

---

## ⚡ DANGEROUS PATTERNS (HIGH RISK)

### Pattern 1: Ignoring Session State
**Symptom:** Agent starts work without reading `.mosaic/*.json`
**Consequence:** Duplicates work, breaks handoffs, ignores blockers
**Prevention:** ALWAYS read state files FIRST

### Pattern 2: Using Old Documentation
**Symptom:** Agent reads SESSION_RESUME_PROMPT.md or old SESSION*.md files
**Consequence:** Acts on outdated information, misses critical changes
**Prevention:** Use DOCUMENTATION_MAP.md to find current docs

### Pattern 3: Creating Absolute Path References
**Symptom:** Agent writes `/Users/damianseguin/...` in docs
**Consequence:** Breaks for all other agents (Gemini, ChatGPT, future Claude sessions)
**Prevention:** ALWAYS use relative paths (api/index.py, not /Users/.../api/index.py)

### Pattern 4: Skipping Pre-Flight Checks
**Symptom:** Agent makes code changes without running TROUBLESHOOTING_CHECKLIST.md checks
**Consequence:** Introduces bugs, breaks context manager pattern, wrong SQL syntax
**Prevention:** Read TROUBLESHOOTING_CHECKLIST.md before ANY code change

### Pattern 5: Deploying Without Verification
**Symptom:** Agent pushes to main without checking health endpoint
**Consequence:** Production down, data loss, user impact
**Prevention:** Follow RAILWAY_DEPLOYMENT_GUIDE.md deployment checklist

---

## 📋 QUICK REFERENCE CHECKLIST

**Before ANY action, verify:**

```
□ Read .mosaic/agent_state.json (last agent, current task, handoff)
□ Read .mosaic/blockers.json (known blockers, resolutions)
□ Read .mosaic/current_task.json (user decisions, objective)
□ Checked git status (branch, working tree state)
□ Reviewed recent commits (git log -5)
□ Understand what was just completed (see "What Was Just Completed" above)
□ Know what user has already decided (D1-D4 above)
□ Read CROSS_AGENT_PROTOCOL.md (7 rules)
□ Read INTENT_FRAMEWORK.md (mandatory pattern)
```

**Before code changes, verify:**

```
□ Read TROUBLESHOOTING_CHECKLIST.md
□ Using context manager pattern? (with get_conn() as conn:)
□ Using PostgreSQL syntax? (%s, SERIAL, cursor first)
□ Errors logged explicitly? (not swallowed)
□ Operations idempotent? (ON CONFLICT, check before insert)
□ Rollback path exists? (git revert, feature flag)
□ Tested locally? (golden dataset, manual test)
```

**Before deployment, verify:**

```
□ Read RAILWAY_DEPLOYMENT_GUIDE.md
□ All tests pass locally
□ Health endpoint returns 200
□ PostgreSQL connected (not SQLite fallback)
□ No secrets in commits
□ Commit message follows convention
□ Feature branch ready to merge to main
```

---

## 🎯 CURRENT OBJECTIVE & NEXT STEPS

**Current Objective:**
Deploy cross-agent coordination system to production

**Pending Actions:**
1. Merge `claude/start-new-session-nB5Jo` to `main`
2. Push to GitHub (`git push origin main`)
3. Monitor Render deployment (auto-triggers on push)
4. Verify health endpoints
5. Update `.mosaic/agent_state.json` with deployment status

**DO NOT PROCEED with deployment without explicit user approval.**

---

## 🔍 HOW TO VERIFY YOU UNDERSTAND

If you've read this briefing, you should be able to answer:

1. **Q:** What branch are we on?
   **A:** `claude/start-new-session-nB5Jo` (feature branch, not yet merged to main)

2. **Q:** What are the 4 user decisions already made?
   **A:** D1: Relative paths (YES), D2: Archive docs (YES), D3: .mosaic/ JSON (YES), D4: GitHub deploy (YES)

3. **Q:** What files must you read FIRST before any action?
   **A:** `.mosaic/current_task.json`, `.mosaic/blockers.json`, `.mosaic/agent_state.json`

4. **Q:** What pattern is mandatory for ALL deliverables?
   **A:** INTENT Framework (Intent → Check → Receipt)

5. **Q:** What's the correct way to reference files in documentation?
   **A:** Relative paths only (api/index.py, NOT /Users/.../api/index.py)

6. **Q:** What's the correct database pattern?
   **A:** `with get_conn() as conn:` (context manager, NOT `conn = get_conn()`)

7. **Q:** What blockers have been resolved?
   **A:** B002 (Render timeout), B003 (CLI linking), B004 (doc overload)

8. **Q:** What was just completed on Jan 5, 2026?
   **A:** Cross-agent coordination system (7 phases), INTENT integration, security fixes, docs

**If you cannot answer these, re-read this briefing before proceeding.**

---

## 🆘 IF YOU'RE STUCK

**Before asking the user, check:**
1. `.mosaic/agent_state.json` - What was the handoff message?
2. `.mosaic/blockers.json` - Is this a known blocker?
3. `DOCUMENTATION_MAP.md` - Is there a doc that answers this?
4. `TROUBLESHOOTING_CHECKLIST.md` - Is this a known error?

**When escalating to user:**
- State what you've read (this briefing + which state files)
- State what you understand (current objective, recent work)
- State what's unclear (specific question)
- State what you propose (options, recommendations)

---

## ⚖️ GOVERNANCE STATE MACHINE

**Current Mode:** BUILD (implementation complete, awaiting deployment)

**State Machine:**
```
INIT → BUILD → DIAGNOSE → REPAIR → VERIFY → HANDOFF
```

**Current State:** BUILD (complete) → VERIFY (pending)

**Next Transition:** VERIFY (after deployment) → HANDOFF (update state for next agent)

---

## 📊 ARCHITECTURE QUICK REFERENCE

**Stack:**
- Frontend: Vanilla JavaScript (Netlify)
- Backend: FastAPI + PostgreSQL (Render)
- LLM: OpenAI GPT-4, Anthropic Claude
- State: `.mosaic/*.json` files

**Deployment:**
- Method: GitHub-based (auto-deploy on push to main)
- Backend: Render watches `origin` (wimd-render-deploy)
- Frontend: Netlify deployment (resonant-crostata-90b706)

**Critical Files:**
- `api/index.py` - FastAPI app
- `api/ai_clients.py` - LLM clients (RECENTLY UPDATED: timeout + retry)
- `api/storage.py` - Database operations (context manager pattern required)
- `CLAUDE.md` - Main dev reference
- `.mosaic/*.json` - State files (authoritative)

---

## 🎓 LEARNING FROM PAST MISTAKES

**Past incidents prevented by this briefing:**

1. **Nov 1, 2025:** Auth system accidentally removed (didn't check pre-flight)
2. **Dec 15, 2025:** Render CLI linking failed (wrong deployment strategy)
3. **Jan 4, 2026:** Multiple agents broke coordination (absolute paths)
4. **Jan 5, 2026:** Agent forgot INTENT framework (didn't read Jan 4 analysis)

**This briefing prevents these by:**
- Mandatory state file reading FIRST
- Explicit prohibition list
- Dangerous pattern awareness
- Pre-flight checklists

---

## ✅ ACKNOWLEDGMENT REQUIRED

**To proceed, you MUST:**

1. Read this entire briefing (you are here)
2. Execute "MANDATORY FIRST ACTIONS" commands
3. Read the 6 required documents (in order)
4. Answer the 8 verification questions (mentally)
5. State to the user: "I have read MANDATORY_AGENT_BRIEFING.md and executed all required actions. Ready to proceed with [specific next step]."

**DO NOT skip acknowledgment. This prevents destructive actions.**

---

## 🔗 RELATED DOCUMENTS

- **State Files:** `.mosaic/current_task.json`, `.mosaic/blockers.json`, `.mosaic/agent_state.json`
- **Protocols:** `.ai-agents/CROSS_AGENT_PROTOCOL.md`, `.ai-agents/INTENT_FRAMEWORK.md`
- **Documentation:** `DOCUMENTATION_MAP.md`, `CLAUDE.md`
- **Deployment:** `RAILWAY_DEPLOYMENT_GUIDE.md`
- **Troubleshooting:** `TROUBLESHOOTING_CHECKLIST.md`, `SELF_DIAGNOSTIC_FRAMEWORK.md`

---

**END OF MANDATORY BRIEFING**

**Status:** Implementation complete, deployment pending user approval
**Last Updated:** 2026-01-05T16:52:00Z
**Last Commit:** ac20aed (docs: Update session state - all work complete)
**Branch:** claude/start-new-session-nB5Jo

**⚠️ If you did not read this entire document, STOP and read it now.**
