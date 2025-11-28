# 🚀 CLAUDE DESKTOP - START HERE

**Project:** WIMD Railway Deploy - Mosaic Platform
**Your Role:** Infrastructure & Deployment Engineer
**Date:** 2025-11-28
**Status:** ✅ Production Stable - Ready for Task Execution

---

## ⚡ QUICK START (30 seconds)

### 1. Run Status Check
```bash
cd /home/user/wimd-railway-deploy
./scripts/status.sh
```

### 2. Read Your Handoff
```bash
cat .ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md
```

### 3. Review Current Tasks
```bash
cat TEAM_STATUS.json
```

**That's it!** These three commands give you everything you need to start.

---

## 📋 WHAT THIS PROJECT IS

**Mosaic Platform** - Career transition coaching platform with:
- AI-powered career coaching (PS101 flow)
- Job search and matching
- Resume optimization
- Interactive chat interface

**Your Focus Area:**
- Infrastructure (Railway backend, Netlify frontend)
- Deployment automation and verification
- Health monitoring and diagnostics
- Production stability

---

## 🎯 YOUR CURRENT CONTEXT

### Production Status
- ✅ **Frontend:** https://whatismydelta.com (HEALTHY)
- ✅ **Backend:** https://what-is-my-delta-site-production.up.railway.app (HEALTHY)
- ✅ **Database:** PostgreSQL on Railway (CONNECTED)
- ✅ **All Features:** Auth, PS101, Chat, File Upload (WORKING)

### Recent Work (Last 48 Hours)
1. Session management system implemented (AI_TEAM_METHODOLOGY.md)
2. Documentation consolidated (removed 50+ outdated files)
3. Login diagnostic endpoints deployed (awaiting env var)
4. Automated handoff system (`commit_work.sh`) operational

### Your Available Tasks
- **P1.2:** Update health check tooling (make environment-aware)
- **P3.1:** Classify uncommitted files (clean up working directory)
- **Wait:** User must set ADMIN_DEBUG_KEY for login diagnostic

---

## 📖 ESSENTIAL READING

**Read in this order (total: 25 minutes):**

1. **AI_START_HERE.txt** (2 min)
   - System overview
   - Quick start commands
   - Deployment rules

2. **.ai-agents/AGENT_PROTOCOL.md** (5 min)
   - Your role: Infrastructure Engineer
   - Communication protocol (SSEW)
   - Mandatory behavior rules
   - Safety guidelines

3. **.ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md** (15 min)
   - Complete project context
   - Current status and issues
   - Task details and priorities
   - Troubleshooting guide
   - Success criteria

4. **TEAM_STATUS.json** (3 min)
   - Current task assignments
   - Work completed today
   - Active warnings
   - Production status

**Optional (if time permits):**
- **AI_TEAM_METHODOLOGY.md** (10 min) - Team collaboration protocol
- **CLAUDE.md** (20 min) - Full architecture documentation

---

## 🚨 CRITICAL WARNINGS

### DO NOT:
❌ Deploy Phase 1 code from `phase1-incomplete` branch
❌ Use raw git push commands (use wrapper scripts)
❌ Skip verification scripts before deployment
❌ Work on tasks assigned to other agents
❌ Remove authentication code

### ALWAYS:
✅ Run `./scripts/status.sh` at session start
✅ Use deployment wrappers: `./scripts/deploy.sh`
✅ Run verification: `./scripts/verify_critical_features.sh`
✅ Update TEAM_STATUS.json when completing tasks
✅ Run `./scripts/commit_work.sh` at session end

---

## 🛠️ COMMON COMMANDS

### Status & Health
```bash
# Get current status (start with this!)
./scripts/status.sh

# Check production health
curl https://whatismydelta.com/health
curl https://what-is-my-delta-site-production.up.railway.app/health

# Verify critical features
./scripts/verify_critical_features.sh
```

### Git Operations
```bash
# Check current state
git status
git log --oneline -5

# View team status
cat TEAM_STATUS.json

# View recent handoffs
ls -lt .ai-agents/handoff_*.json | head -5
```

### Deployment
```bash
# Deploy frontend (with verification)
./scripts/deploy.sh netlify

# Deploy backend (with verification)
./scripts/deploy.sh railway

# Deploy both
./scripts/deploy.sh all
```

### Session End
```bash
# Automated handoff creation
./scripts/commit_work.sh

# This will:
# - Prompt for work summary
# - Update TEAM_STATUS.json
# - Create handoff JSON
# - Commit changes
# - Guide you through push
```

---

## 🎓 UNDERSTANDING THE SYSTEM

### AI Team Structure
- **Gemini** (terminal) - Senior Engineer & Planning Lead
- **Codex** (Cursor) - Local Implementation Engineer
- **Claude Code** - Infrastructure & Deployment (you!)
- **Claude Desktop** - Task execution (you!)

### Communication: SSEW Protocol
```
S: Situation - What's happening now
S: Steps - What I did/will do
E: Evidence - Output, logs, results
W: Waiting - Dependencies, blockers
```

### Task Lifecycle
1. Task added to `TEAM_STATUS.json` queue
2. Agent claims task (moves to active)
3. Agent executes task
4. Agent verifies completion
5. Agent updates TEAM_STATUS.json (moves to done_today)
6. Agent runs `./scripts/commit_work.sh`
7. Next agent reads TEAM_STATUS.json

---

## 🔍 CURRENT ISSUES

### P0: Login Failure (10+ days)
**User:** damian.seguin@gmail.com cannot log in
**Status:** Diagnostic endpoints deployed (commit b7e042c)
**Blocked:** User must set ADMIN_DEBUG_KEY in Railway
**Details:** `.ai-agents/DIAGNOSTIC_LOGIN_ISSUE_2025-11-24.md`

**What You Can Do:**
- Wait for user to set env var
- Review diagnostic documentation
- Prepare follow-up actions once diagnostic runs

**What You Cannot Do:**
- Access Railway env vars (user-only)
- Access production database directly (no credentials)
- Reset user password (requires admin access)

---

## 📁 PROJECT STRUCTURE

```
/home/user/wimd-railway-deploy/
├── .ai-agents/              # AI team communication hub
│   ├── HANDOFF_FOR_CLAUDE_2025-11-28.md  ← Your handoff doc
│   ├── AGENT_PROTOCOL.md                  ← Read this!
│   ├── DIAGNOSTIC_LOGIN_ISSUE_2025-11-24.md
│   └── handoff_*.json                     ← Session history
│
├── api/                     # Backend (FastAPI)
│   ├── index.py            # Main API endpoints
│   ├── storage.py          # Database operations
│   ├── auth.py             # Authentication logic
│   └── ...
│
├── mosaic_ui/              # Frontend (Vanilla JS)
│   ├── index.html          # Main UI
│   ├── js/                 # JavaScript modules
│   └── css/                # Styles
│
├── scripts/                # Automation tools
│   ├── status.sh           # Status check (run first!)
│   ├── deploy.sh           # Deployment wrapper
│   ├── verify_critical_features.sh
│   └── commit_work.sh      # Session end automation
│
├── TEAM_STATUS.json        # Current task queue
├── AI_START_HERE.txt       # Quick start guide
├── CLAUDE.md               # Architecture doc
├── AI_TEAM_METHODOLOGY.md  # Collaboration protocol
└── ...
```

---

## 🎯 RECOMMENDED FIRST TASK

### Option 1: P1.2 - Update Health Check Tooling (RECOMMENDED)

**Why This Task:**
- High impact (prevents false alarms)
- Clear scope (update one script)
- Good learning (understand verification system)
- No dependencies (can start immediately)

**What to Do:**
1. Read current script: `scripts/verify_critical_features.sh`
2. Identify network-dependent checks
3. Add environment detection logic
4. Test in restricted environment
5. Update TEAM_STATUS.json
6. Run `./scripts/commit_work.sh`

**Success Criteria:**
- Script distinguishes network error from real failure
- No false negatives in restricted environments
- All existing checks still work
- Documentation updated

### Option 2: Wait for User Instructions

If user has specific task in mind, wait for guidance.

### Option 3: Review and Learn

Spend time understanding the system:
- Read documentation
- Review git history
- Explore codebase
- Ask clarifying questions

---

## ✅ SUCCESS CHECKLIST

**By End of Session:**
- [ ] Read all essential documentation
- [ ] Understand current project status
- [ ] Complete at least one task OR make progress on assigned work
- [ ] Update TEAM_STATUS.json
- [ ] Run `./scripts/commit_work.sh`
- [ ] Production still healthy (no regressions)

**Good Session Indicators:**
- ✅ Clear understanding of what was done
- ✅ TEAM_STATUS.json reflects reality
- ✅ Handoff JSON created
- ✅ Next agent can start immediately
- ✅ Production stable

**Red Flags (Ask User):**
- 🚨 Production health fails
- 🚨 Critical features missing
- 🚨 Conflicting documentation
- 🚨 Unclear what to work on
- 🚨 Deployment breaks something

---

## 💡 TIPS FOR SUCCESS

1. **Start with `./scripts/status.sh`** - Designed to answer "what now?"
2. **Read AGENT_PROTOCOL.md** - Prevents common mistakes
3. **Use TEAM_STATUS.json** - Single source of truth
4. **Verify before deploying** - Always run verification scripts
5. **Communicate in SSEW** - Makes handoffs cleaner
6. **Update docs as you go** - Help future agents
7. **Check `.ai-agents/`** - Recent notes are there
8. **Verify, don't assume** - Check production, git status, files
9. **Ask before big changes** - Better to clarify than break
10. **End with `./scripts/commit_work.sh`** - Automates handoff

---

## 🆘 WHEN THINGS GO WRONG

### Health Check Fails
**Action:** Manual browser check at https://whatismydelta.com
**Reason:** May be network restriction, not real failure

### Auth Missing
**Action:** Check git history for Phase 1 deployments
**Rollback:** `git revert HEAD` if Phase 1 code deployed

### Login Issues
**Action:** See `.ai-agents/DIAGNOSTIC_LOGIN_ISSUE_2025-11-24.md`
**Wait:** User must set ADMIN_DEBUG_KEY

### Git Push Fails
**Action:** Verify branch name format: `claude/project-handoff-review-*`
**Current:** `claude/project-handoff-review-01JmBEn7v6sntCLzqwDnYbbH`

### Unclear What to Do
**Action:** Run `./scripts/status.sh` and read TEAM_STATUS.json
**Escalate:** Ask user for guidance

---

## 🎬 READY TO START?

### Command Sequence
```bash
# 1. Navigate to project
cd /home/user/wimd-railway-deploy

# 2. Check status
./scripts/status.sh

# 3. Read your handoff
cat .ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md

# 4. Review tasks
cat TEAM_STATUS.json

# 5. Pick a task and start!
```

### First Actions
1. ✅ Verify production health
2. ✅ Understand current context
3. ✅ Choose task (or wait for user)
4. ✅ Execute with verification
5. ✅ Update and handoff

---

**You're all set! Welcome to the Mosaic Platform project.** 🚀

**Questions?**
- Check `.ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md`
- Review TEAM_STATUS.json
- Ask user for clarification

**Good luck!** 🎉

---

**Document Created:** 2025-11-28
**Created By:** Claude Code
**For:** Claude Desktop (New Session Start)
**Status:** ✅ READY

---

**END OF START GUIDE**
