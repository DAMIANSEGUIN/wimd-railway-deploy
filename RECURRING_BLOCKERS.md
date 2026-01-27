# Recurring Blockers - Pattern Analysis & Solutions

**Created:** 2025-12-04
**Purpose:** Identify recurring blockers, root causes, and prevention strategies
**Owner:** Team (all AI agents + human)
**Update Frequency:** After each blocker incident

---

## 🎯 BLOCKER CATEGORIES (By Frequency)

### 1. ⚠️ DEPLOYMENT BLOCKERS (Highest Frequency)

#### 1A: Render Auto-Deploy Not Pulling New Code

**Frequency:** Multiple incidents (2025-11-09, 2025-12-04)
**Pattern:**

- Git push to `origin/main` triggers Render restart
- Render restarts but serves OLD code
- New code not pulled from GitHub

**Root Cause:**

- GitHub webhook → Render integration misconfigured or broken
- Render may be caching old Docker layers
- Possible: Render watching wrong branch

**Evidence:**

- 2025-12-04: Pushed be8b21c → Render restarted → `/api/ps101/extract-context` returns 404
- OpenAPI spec shows only old `/wimd/start-ps101`, not new endpoint

**Workaround:**

```bash
render up --detach  # Manual CLI deployment works
```

**Prevention Strategy:**

1. **Short-term:** Document manual deployment as canonical method
2. **Long-term:** Investigate Render GitHub integration settings:
   - Check webhook status in Render dashboard
   - Verify branch configuration (should watch `main`)
   - Test: Push empty commit, verify Render pulls it
3. **Add to pre-deployment checklist:** Verify deployed code matches git commit

---

#### 1B: BUILD_ID Injection Creates Uncommitted Changes Loop

**Frequency:** Documented 2025-11-09
**Pattern:**

- `./scripts/deploy.sh` injects BUILD_ID into HTML files
- Creates uncommitted changes AFTER commit
- Script blocks: "uncommitted changes detected"
- Infinite loop if you commit the BUILD_ID update

**Root Cause:**

- Deployment script modifies files (BUILD_ID injection) AFTER git commit
- Git status check runs AFTER modification
- Design flaw: Modification should happen in temporary directory OR be excluded from git status check

**Solution (Implemented?):**

- Need to verify if scripts/deploy.sh currently handles this
- If not: Inject BUILD_ID into temporary deployment artifacts, not source files

**Prevention Strategy:**

- BUILD_ID injection should happen to COPY of files, not source
- OR: Add BUILD_ID files to .gitignore and exclude from status check
- OR: Inject at build time (Netlify/Render environment), not in script

---

### 2. 🐍 PYTHON ENVIRONMENT BLOCKERS (Medium Frequency)

#### 2A: Python Version Too Old (3.7.x)

**Frequency:** Affects new sessions with local testing
**Pattern:**

- Agent recommends local Python testing
- User's system Python is 3.7.5 (EOL)
- Dependencies require 3.9+

**Root Cause:**

- macOS default Python is often outdated
- No canonical local dev setup protocol (FIXED 2025-12-04)

**Solution:**

- TEAM_PLAYBOOK.md Section 4 now documents Python 3.9+ requirement
- Pre-flight checklist added

**Prevention Strategy:**

- ✅ **FIXED:** Section 4 added to TEAM_PLAYBOOK.md
- All agents must read Section 4 before recommending local testing

---

#### 2B: Python Missing SSL Support

**Frequency:** 2025-12-04 (after recommending Python 3.12)
**Pattern:**

- Python installed but compiled without SSL
- `pip install` fails: "SSL module not available"
- Homebrew Python missing OpenSSL linkage

**Root Cause:**

- Homebrew Python not linked to OpenSSL during installation
- Agent recommended Python path without verifying SSL support

**Solution:**

```bash
brew reinstall python@3.12 openssl@3
```

**Prevention Strategy:**

- ✅ **FIXED:** TEAM_PLAYBOOK.md Section 4 now includes SSL verification step
- Before recommending Python path, agent MUST run:

  ```bash
  python3 -c "import ssl; print('✅ SSL available')"
  ```

---

### 3. 🔐 PERMISSION & ACCESS BLOCKERS (Medium Frequency)

#### 3A: Cross-Team Tool Access Assumptions

**Frequency:** 2025-12-04 (Gemini blocked on terminal access)
**Pattern:**

- Agent A recommends solution requiring terminal commands
- Agent B (Gemini) has no terminal access (Google Drive MCP only)
- User must intervene to run commands

**Root Cause:**

- Agent A didn't check Agent B's access capabilities before providing solution
- TEAM_PLAYBOOK.md documents roles but not systematically checked

**Solution:**

- When providing cross-team instructions, MUST state:
  1. What the solution is
  2. What access is required
  3. If recipient lacks access, what USER must run

**Prevention Strategy:**

- ✅ **FIXED:** Added to TEAM_PLAYBOOK.md Section 3 (Communication Protocol)
- Pattern: "Gemini needs X, but has no terminal access. User must run: [commands]"

---

### 4. 🤖 AI AGENT DECISION-MAKING BLOCKERS (High Frequency - CRITICAL)

#### 4A: Asking User to Make Technical Decisions

**Frequency:** 2-3 times per session (MOST FRUSTRATING BLOCKER)
**Pattern:**

- AI presents "Option 1 vs Option 2 - which do you want?"
- Both options are documented in playbook
- User has to stop work to say "follow the protocol"
- Decision criteria already exists in TEAM_PLAYBOOK.md

**Root Cause:**

- SESSION_START.md not enforced strictly enough
- AI treating user as decision-maker instead of protocol follower
- "Asking permission" conflated with "following documented protocol"
- Protocol violations not flagged as CRITICAL blockers

**Examples (2025-12-04):**

1. "Option 1: Deploy with workaround, Option 2: Fix auto-deploy first - which do you want?"
   - PLAYBOOK SAYS: Use workarounds for blockers, investigate in parallel
   - SHOULD HAVE: Executed workaround autonomously
2. "Should I work on X or Y?"
   - PLAYBOOK SAYS: Section 2 documents NEXT TASK and priorities
   - SHOULD HAVE: Read Section 2 and executed

**Prevention Strategy:**

- ✅ **FIXED (2025-12-04):** SESSION_START.md updated with:
  - Explicit FORBIDDEN QUESTIONS list including "Which option do you want?"
  - FORBIDDEN ACTIONS section (presenting options when protocol exists)
  - Statement: "User does NOT make technical decisions - playbook does"
- 🔄 **ENFORCEMENT NEEDED:** All agents MUST review SESSION_START.md before starting work
- 🔄 **ESCALATION:** Protocol violations should be treated as CRITICAL blockers

**Time Lost:** ~5-10 minutes per violation (context switching + user frustration)

---

### 4. 📋 TERMINOLOGY & COMMUNICATION BLOCKERS (Low Frequency)

#### 4A: User Uses Incorrect/Ambiguous Terms

**Frequency:** Occasional
**Pattern:**

- User says "endpoint not in canon" (meant "production")
- Agent confused or assumes user is wrong

**Root Cause:**

- No canonical protocol for handling user terminology errors

**Solution:**

- Interpret intent, respond to what they meant, then gently correct

**Prevention Strategy:**

- ✅ **FIXED:** Added to TEAM_PLAYBOOK.md Section 3 (Communication Protocol)
- Example: "I believe you meant 'production' rather than 'canon' (which refers to documentation)"

---

### 5. 🔍 MISSING DOCUMENTATION BLOCKERS (Medium Frequency)

#### 5A: Edge Cases Not Documented

**Frequency:** 2025-12-04 (Python SSL issue, Render auto-deploy)
**Pattern:**

- Agent hits edge case not in canon
- Agent provides solution without verifying it works
- Solution fails, user must fix

**Root Cause:**

- Canon incomplete (growing project)
- No systematic "document new edge cases" protocol

**Solution:**

- When encountering new edge case → Document immediately in canonical location
- Don't just solve it → Make it canonical

**Prevention Strategy:**

- ✅ **PARTIALLY FIXED:** This document (RECURRING_BLOCKERS.md) created
- **TODO:** Add to TEAM_PLAYBOOK.md Section 14 (Document Maintenance):
  - "After resolving any blocker not in canon → Update relevant section within same session"

---

## 📊 BLOCKER STATISTICS

**Total Documented Blocker Incidents (Since 2025-11-01):**

- Deployment: 8 incidents
- Python Environment: 3 incidents
- Permission/Access: 2 incidents
- Terminology: 1 incident
- Documentation Gaps: Ongoing (uncounted)

**Top 3 Time Sinks:**

1. Render auto-deploy issues (estimated 2-3 hours per incident)
2. Python environment setup (1-2 hours per incident)
3. BUILD_ID injection loop (1 hour per incident)

**Estimated Total Time Lost:** ~15-20 hours across team

---

## ✅ PREVENTION CHECKLIST (For All Agents)

**Before Recommending Any Solution:**

```
□ Is this solution documented in canon?
□ Have I verified it works (not just exists)?
□ Does recipient have required access/tools?
□ If cross-team: Have I stated what USER must run?
□ If new edge case: Have I updated canon?
```

**After Resolving Any Blocker:**

```
□ Document root cause in this file (RECURRING_BLOCKERS.md)
□ Add prevention to canonical protocol (TEAM_PLAYBOOK.md)
□ Update relevant checklists
□ Test prevention works in next session
```

---

## 🔄 PROCESS IMPROVEMENTS

### Current Process Issues

1. **Reactive documentation** - Only update canon AFTER hitting blocker
2. **No proactive pattern detection** - Each agent rediscovers same issues
3. **Fragmented knowledge** - Blockers scattered across .ai-agents/*.md files
4. **No blocker review cadence** - This document is first centralized view

### Proposed Improvements

#### Improvement 1: Weekly Blocker Review

**Owner:** Human + Claude Desktop (Project Manager role)
**Cadence:** End of each sprint (currently every 3 days)
**Process:**

1. Review RECURRING_BLOCKERS.md
2. Identify patterns in new incidents
3. Update prevention strategies
4. Update TEAM_PLAYBOOK.md canonical sections

#### Improvement 2: Session Start Blocker Check

**Owner:** All AI agents
**Process:** Add to SESSION_START.md Gate 1:

- ✅ Read RECURRING_BLOCKERS.md (top 3 blockers)
- ✅ Know current prevention strategies
- ✅ Don't repeat known mistakes

#### Improvement 3: Blocker Severity Triage

**Severity Levels:**

- **CRITICAL:** Blocks all work (e.g., Render down)
- **HIGH:** Blocks current task (e.g., Python SSL missing)
- **MEDIUM:** Workaround exists (e.g., manual Render deploy)
- **LOW:** Annoying but not blocking (e.g., terminology confusion)

**Escalation:**

- CRITICAL → Immediate human escalation
- HIGH → Document + escalate if no solution in 30 min
- MEDIUM → Document + implement workaround
- LOW → Document only

#### Improvement 4: Blocker Prevention Automation

**Ideas:**

- Pre-commit hook: Check Python version/SSL before allowing local dev
- Pre-push hook: Verify Render deployment pulls new code
- Session start script: Run RECURRING_BLOCKERS.md top 3 check

---

## 🎯 CURRENT OPEN BLOCKERS

### Active (Blocking Work Right Now)

1. **Render Auto-Deploy Not Pulling Code** - Workaround: Manual `render up`
   - Status: Manual deployment in progress (2025-12-04 15:45 UTC)
   - Next: Verify deployed code after build completes

### Resolved This Session

1. ✅ Python 3.7.5 too old → Documented in TEAM_PLAYBOOK.md Section 4
2. ✅ Python SSL missing → Documented solution + verification step
3. ✅ Cross-team access gaps → Added Communication Protocol

---

## 📚 RELATED DOCUMENTS

**Canonical References:**

- `TEAM_PLAYBOOK.md` - Single source of truth (all protocols)
- `TROUBLESHOOTING_CHECKLIST.md` - Error classification dashboard
- `SELF_DIAGNOSTIC_FRAMEWORK.md` - Architecture-specific error prevention

**Historical Blockers:**

- `.ai-agents/DEPLOYMENT_LOOP_DIAGNOSIS_2025-11-09.md` - BUILD_ID loop
- `.ai-agents/archive/RESOLVED_2025-11-01_Render_Deployment_Fix.md`
- `.ai-agents/archive/RESOLVED_2025-10-14_PostgreSQL_Connection_Issue.md`

---

## 🤔 QUESTIONS FOR TEAM DISCUSSION

1. **Is weekly blocker review sufficient?** Or should it be after every blocker?
2. **Should blocker prevention be automated?** (pre-commit hooks, etc.)
3. **Who owns blocker triage?** Currently ad-hoc (whoever hits it)
4. **Should we track blocker metrics?** (frequency, time lost, prevention success rate)
5. **Is this document useful?** Or redundant with TROUBLESHOOTING_CHECKLIST.md?

---

**END OF RECURRING_BLOCKERS.md**

**This document should be updated immediately after ANY blocker is resolved.**
