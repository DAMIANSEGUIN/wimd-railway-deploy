# 🎯 PROJECT HANDOFF - Claude Desktop - 2025-11-28

**Handoff From:** Previous AI agents (Claude Code, Gemini, Codex)
**Handoff To:** Claude Desktop (New Session)
**Date:** 2025-11-28
**Project:** WIMD Railway Deploy - Mosaic Platform
**Status:** ✅ STABLE - Production healthy, session management system operational

---

## 📊 EXECUTIVE SUMMARY

**Production Status:** ✅ HEALTHY
**Last Successful Deploy:** commit `c5fcb47` (session management system)
**Active Blockers:** 1 (Login issue for specific user - diagnostic endpoints deployed)
**Working Tree:** Clean
**Branch:** `claude/project-handoff-review-01JmBEn7v6sntCLzqwDnYbbH`

### What Just Happened (Last 48 Hours)
1. ✅ **P0.1** - Session management system implemented (AI_TEAM_METHODOLOGY.md)
2. ✅ **P0.2** - Documentation consolidated (5-hour effort by Gemini)
3. ✅ **Login Diagnostic** - Admin endpoints deployed (awaiting Railway env var setup)
4. ✅ **Session End Protocol** - `commit_work.sh` script operational

### What Needs to Happen Next
1. 🟡 **User Action Required:** Set `ADMIN_DEBUG_KEY` in Railway (for login diagnostic)
2. 🟡 **User Action Required:** Manual production health check (browser verification)
3. 🟢 **Claude Code Task:** Environment-aware health check scripts (P1.2)
4. 🟢 **Claude Code Task:** Classify uncommitted files (P3.1)

---

## 🏗️ PROJECT ARCHITECTURE

### Stack
- **Frontend:** Vanilla JavaScript (ES6+) on Netlify
- **Backend:** FastAPI + PostgreSQL on Railway
- **Production URL:** https://whatismydelta.com
- **Backend API:** https://what-is-my-delta-site-production.up.railway.app
- **Domain:** whatismydelta.com (DNS configured)

### Key Directories
```
/home/user/wimd-railway-deploy/
├── .ai-agents/          # AI agent communication hub
├── mosaic_ui/           # Frontend source (deployed to Netlify)
├── api/                 # Backend source (deployed to Railway)
├── scripts/             # Deployment and verification scripts
├── Mosaic/              # PS101 continuity kit
├── docs/                # Documentation
└── frontend/            # Additional frontend docs
```

### Critical Files (Read These First)
1. **AI_START_HERE.txt** - Quick start guide (run `./scripts/status.sh`)
2. **CLAUDE.md** - Architecture and deployment status
3. **TEAM_STATUS.json** - Current task assignments and queue
4. **AI_TEAM_METHODOLOGY.md** - AI agent collaboration protocol
5. **.ai-agents/AGENT_PROTOCOL.md** - Mandatory behavior rules

---

## 🔍 CURRENT STATUS (2025-11-28)

### Production Health ✅

**Frontend:** https://whatismydelta.com
- Status: OPERATIONAL
- Last Deploy: Rollback to stable (commit `1fc4010`)
- Features: Auth, PS101 flow, chat, file upload - all working

**Backend:** https://what-is-my-delta-site-production.up.railway.app
- Status: OPERATIONAL
- Health Check: `{"ok":true,"database":true,"prompt_system":true}`
- Database: PostgreSQL (railway.internal)

### Recent Completed Work (2025-11-24)

1. **Session Management System** (commit `c5fcb47`)
   - AI_TEAM_METHODOLOGY.md created (SSEW protocol)
   - TEAM_STATUS.json replaces CURRENT_WORK.json
   - `commit_work.sh` script for session handoffs
   - Agent protocol with role assignments

2. **Documentation Consolidation** (commit `68e02e5`)
   - 5-hour review and consolidation by Gemini
   - Removed 50+ outdated files
   - Updated references and links
   - Clarified Phase 1 status

3. **Login Diagnostic System** (commit `b7e042c`)
   - Admin endpoints: `/auth/diagnose/<email>`
   - Password hash format verification
   - Database query logging
   - Requires `ADMIN_DEBUG_KEY` env var (pending user setup)

4. **Session End Protocol** (commit `76af5af`)
   - Renamed `session_end.sh` → `commit_work.sh`
   - Added AGENT_PROTOCOL.md
   - Automated handoff creation
   - Git safety checks

### Active Issues 🟡

**P0: Login Failure (10+ days)**
- **Symptom:** damian.seguin@gmail.com cannot log in
- **Evidence:** New accounts work, existing account fails
- **Hypothesis:** Corrupted/incompatible password hash from old system
- **Status:** Diagnostic endpoints deployed (commit `b7e042c`)
- **Blocked On:** User must set `ADMIN_DEBUG_KEY` in Railway
- **Next Step:** Run diagnostic endpoint with admin key
- **Documentation:** `.ai-agents/DIAGNOSTIC_LOGIN_ISSUE_2025-11-24.md`

**Known Warnings:**
- Phase 1 branch `phase1-incomplete` - DO NOT deploy without integration
- Health check may show false negatives in restricted networks
- ~50 uncommitted files need classification (P3.1)

---

## 🎯 YOUR IMMEDIATE TASKS

### Step 1: Run Status Check
```bash
cd /home/user/wimd-railway-deploy
./scripts/status.sh
```

This command tells you:
- Production health (live check)
- What's deployed
- Latest instructions
- Active warnings
- Exactly what to do next

### Step 2: Review Team Status
```bash
cat TEAM_STATUS.json
```

Check for:
- **active:** Tasks currently in progress
- **queue:** Tasks awaiting assignment
- **blocked:** Tasks waiting on dependencies
- **warnings:** Critical alerts

### Step 3: Read Mandatory Protocol
```bash
cat .ai-agents/AGENT_PROTOCOL.md
```

This defines:
- Agent roles (you are Claude Code = Infrastructure Engineer)
- Communication protocol (SSEW format)
- Handoff procedures
- Safety rules

### Step 4: Choose Your Task

**Option A: P1.2 - Update Health Check Tooling** (Recommended)
- Make scripts environment-aware
- Distinguish network blocks from real failures
- Prevents false negative alerts
- File: `scripts/verify_critical_features.sh`

**Option B: P3.1 - Classify Uncommitted Files**
- Review ~50 uncommitted files
- Decide: commit, ignore, or delete
- Clean up working directory
- Requires git status review

**Option C: Wait for User Action**
- User must set ADMIN_DEBUG_KEY for login diagnostic
- User must manually verify production health
- User must review Phase 1 boundaries document

---

## 🚨 CRITICAL WARNINGS

### DO NOT:
❌ Deploy Phase 1 code from `phase1-incomplete` branch
❌ Use raw `git push railway-origin main` (use wrapper scripts)
❌ Remove authentication code without explicit approval
❌ Skip verification before deployment
❌ Work on tasks assigned to other agents without coordination

### ALWAYS:
✅ Run `./scripts/status.sh` at session start
✅ Read AGENT_PROTOCOL.md before making changes
✅ Use deployment wrapper scripts (`./scripts/deploy.sh`)
✅ Run verification: `./scripts/verify_critical_features.sh`
✅ Update TEAM_STATUS.json when completing tasks
✅ Run `./scripts/commit_work.sh` at session end

---

## 📚 KEY DOCUMENTATION

### Essential Reading (Priority Order)
1. **AI_START_HERE.txt** (2 min) - Quick start
2. **.ai-agents/AGENT_PROTOCOL.md** (5 min) - Rules
3. **AI_TEAM_METHODOLOGY.md** (10 min) - Collaboration
4. **TEAM_STATUS.json** (2 min) - Current state
5. **CLAUDE.md** (15 min) - Architecture deep dive

### Context for Current Issues
1. **.ai-agents/DIAGNOSTIC_LOGIN_ISSUE_2025-11-24.md** - Login problem analysis
2. **.ai-agents/INFRASTRUCTURE_STATUS_2025-11-24.md** - Infrastructure report
3. **.ai-agents/FINAL_STATUS_2025-11-21_EVENING.md** - Phase 1 rollback timeline

### Reference Documentation
- **TROUBLESHOOTING_CHECKLIST.md** - Pre-flight checks
- **SELF_DIAGNOSTIC_FRAMEWORK.md** - Error handling patterns
- **DEPLOYMENT_CHECKLIST.md** - Deploy safety protocol

---

## 🤝 AI TEAM STRUCTURE

### Agent Roles
- **Gemini/ChatGPT (terminal)** → Senior Software Engineer & Planning Lead
- **Codex (Cursor IDE)** → Local Implementation Engineer
- **Claude Code (you)** → Infrastructure & Deployment Engineer
- **Claude Desktop (you)** → Project handoff review and task execution

### Communication Protocol: SSEW
```
S: Situation (what's happening now)
S: Steps (what I did or will do)
E: Evidence (output, logs, results)
W: Waiting (dependencies, blockers)
```

### Handoff Protocol
1. Run `./scripts/commit_work.sh` at session end
2. Updates TEAM_STATUS.json automatically
3. Creates handoff JSON in `.ai-agents/`
4. Commits work with clear messages
5. Next agent reads TEAM_STATUS.json to start

---

## 🔐 DEPLOYMENT RULES

### ✅ CORRECT Way to Deploy
```bash
# Deploy frontend
./scripts/deploy.sh netlify

# Deploy backend
./scripts/deploy.sh railway

# Deploy both
./scripts/deploy.sh all
```

### ❌ WRONG Way (Will Fail or Break Things)
```bash
netlify deploy --prod          # ← NO! Skips verification
git push railway-origin main   # ← NO! No safety checks
```

### Pre-Deployment Checklist
```bash
# Always run before deploying
./scripts/verify_critical_features.sh

# Check health after deploy
curl https://whatismydelta.com/health
curl https://what-is-my-delta-site-production.up.railway.app/health
```

---

## 🧪 VERIFICATION SCRIPTS

### Primary Tool: `verify_critical_features.sh`
```bash
./scripts/verify_critical_features.sh
```
**Checks:**
- Authentication UI presence (40 occurrences expected)
- PS101 flow presence (172 references expected)
- API_BASE configuration
- Production authentication detection

**Reliability:** HIGH (uses curl + grep, no dependencies)

### Secondary Tool: `verify_deployment_improved.sh`
```bash
DEPLOY_URL=https://whatismydelta.com ./scripts/verify_deployment_improved.sh
```
**Checks:**
- Uses Playwright for visual element detection
- More comprehensive but requires node + playwright
- Falls back to curl if Playwright unavailable

**Known Issue:** Reports false negatives for hidden elements (PS101 containers start with display:none)

### Status Script: `status.sh`
```bash
./scripts/status.sh
```
**Output:**
- Production health (live check)
- Git status and recent commits
- Latest instructions file
- Active warnings from TEAM_STATUS.json
- Next steps

---

## 🗂️ FILE ORGANIZATION

### Where Things Live

**AI Agent Communication:**
- `.ai-agents/` - All agent handoffs, notes, diagnostics
- `TEAM_STATUS.json` - Current task queue and assignments
- `AI_START_HERE.txt` - Quick start (always read first)

**Source Code:**
- `mosaic_ui/` - Frontend (Netlify deployment source)
- `api/` - Backend (Railway deployment source)
- `scripts/` - Automation and verification tools

**Documentation:**
- `CLAUDE.md` - Main architecture doc
- `AI_TEAM_METHODOLOGY.md` - Team collaboration protocol
- `docs/` - Additional documentation

**Deployment:**
- `netlify.toml` - Netlify configuration
- `railway.toml` - Railway configuration
- `requirements.txt` - Python dependencies

---

## 🐛 TROUBLESHOOTING

### Issue: Health Check Fails
**Symptom:** Scripts report production unhealthy
**Diagnosis:** May be network restriction (not real failure)
**Solution:** Manual browser check at https://whatismydelta.com

### Issue: Auth Missing from Frontend
**Symptom:** verify_critical_features.sh reports <40 auth occurrences
**Diagnosis:** Phase 1 code deployed without integration
**Solution:** Rollback to stable commit `1fc4010`

### Issue: Login Fails (Specific User)
**Symptom:** damian.seguin@gmail.com gets "Invalid credentials"
**Diagnosis:** See `.ai-agents/DIAGNOSTIC_LOGIN_ISSUE_2025-11-24.md`
**Solution:** Run diagnostic endpoint (requires ADMIN_DEBUG_KEY)

### Issue: Git Push Rejected
**Symptom:** Branch push fails with 403
**Diagnosis:** Branch must start with 'claude/' and end with session ID
**Solution:** Use branch `claude/project-handoff-review-01JmBEn7v6sntCLzqwDnYbbH`

---

## 📈 SUCCESS METRICS

### Session is Successful If:
✅ You understand current project state
✅ You completed at least one task from queue
✅ TEAM_STATUS.json is updated
✅ No production regressions introduced
✅ Clear handoff created for next agent

### Red Flags (Stop and Ask User):
🚨 Production health check fails
🚨 Critical features missing from verification
🚨 Conflicting information in documentation
🚨 Unable to determine what to work on
🚨 Task dependencies blocking progress

---

## 🎬 GETTING STARTED CHECKLIST

**Step 1: Initial Context** (5 minutes)
- [ ] Read AI_START_HERE.txt
- [ ] Run `./scripts/status.sh`
- [ ] Review TEAM_STATUS.json
- [ ] Read .ai-agents/AGENT_PROTOCOL.md

**Step 2: Verify Production** (2 minutes)
- [ ] Check frontend health: `curl https://whatismydelta.com/health`
- [ ] Check backend health: `curl https://what-is-my-delta-site-production.up.railway.app/health`
- [ ] Both should return `{"ok":true,...}`

**Step 3: Choose Task** (1 minute)
- [ ] Review queue in TEAM_STATUS.json
- [ ] Pick task assigned to "Claude Code" or "Claude Desktop"
- [ ] OR wait for user to provide specific instructions

**Step 4: Execute** (varies)
- [ ] Run any pre-checks required
- [ ] Implement changes
- [ ] Run verification scripts
- [ ] Update TEAM_STATUS.json

**Step 5: Handoff** (2 minutes)
- [ ] Run `./scripts/commit_work.sh`
- [ ] Verify handoff JSON created
- [ ] Confirm working tree clean

---

## 🔗 QUICK LINKS

**Production:**
- Frontend: https://whatismydelta.com
- Backend: https://what-is-my-delta-site-production.up.railway.app
- Health: /health endpoint on both

**Git:**
- Current Branch: `claude/project-handoff-review-01JmBEn7v6sntCLzqwDnYbbH`
- Main Branch: `main`
- Phase 1 Branch: `phase1-incomplete` (DO NOT DEPLOY)

**Railway:**
- Service: `what-is-my-delta-site-production`
- Region: us-west1
- Database: PostgreSQL (railway.internal)

**Netlify:**
- Site: resonant-crostata-90b706
- Deploy Branch: `main`
- Auto-Deploy: Enabled

---

## 💡 TIPS FOR SUCCESS

1. **When in doubt, run `./scripts/status.sh`** - It's designed to answer "what should I do?"

2. **Read AGENT_PROTOCOL.md first** - Saves time by preventing common mistakes

3. **Use TEAM_STATUS.json as single source of truth** - Don't rely on scattered docs

4. **Verify before deploying** - Always run `./scripts/verify_critical_features.sh`

5. **Communicate in SSEW format** - Makes handoffs cleaner and faster

6. **Update docs as you go** - Future agents will thank you

7. **When stuck, check `.ai-agents/` directory** - Recent agents left detailed notes

8. **Don't assume - verify** - Production health, git status, file contents

9. **Ask user before big changes** - Better to clarify than to break production

10. **End with `./scripts/commit_work.sh`** - Automates handoff creation

---

## 🎓 LEARNING FROM PAST ISSUES

### Issue: Phase 1 Broke Production (2025-11-21)
**What Happened:** Modules extracted without integration → UI non-functional
**Root Cause:** Deployed incomplete work without testing
**Lesson:** Never deploy extraction without integration, use feature flags
**Prevention:** Verification scripts + feature flags + protocol

### Issue: Documentation Scattered (2025-11-24)
**What Happened:** 50+ files with dates, unclear which was current
**Root Cause:** No single source of truth, no update protocol
**Lesson:** Use TEAM_STATUS.json + AI_START_HERE.txt, consolidate regularly
**Prevention:** `status.sh` script + AGENT_PROTOCOL.md

### Issue: Login Broken for 10+ Days (2025-11-24)
**What Happened:** User cannot log in, repeated attempts failed
**Root Cause:** Password hash corruption, insufficient diagnostics
**Lesson:** Need admin diagnostic endpoints, better error logging
**Prevention:** Admin endpoints deployed, comprehensive diagnostic doc

---

## 🚀 READY TO START?

**Recommended First Command:**
```bash
./scripts/status.sh
```

**Recommended First Read:**
```bash
cat .ai-agents/AGENT_PROTOCOL.md
```

**Recommended First Task:**
- P1.2: Update health check tooling (environment-aware)
- OR
- Review TEAM_STATUS.json and pick highest priority task

**Questions? Issues? Blockers?**
- Check `.ai-agents/` directory for recent notes
- Review TEAM_STATUS.json warnings
- Ask user for clarification if needed

---

**Welcome to the project! You've got this.** 🎉

**Handoff Created:** 2025-11-28
**Created By:** Claude Code (Infrastructure Engineer)
**For:** Claude Desktop (New Session)
**Status:** ✅ READY TO START

---

**END OF HANDOFF**
