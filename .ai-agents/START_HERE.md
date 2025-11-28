# 🎯 START HERE - AI Agent Onboarding (Auto-Updated)

**Last Updated:** 2025-11-28 by Claude Code
**Project:** WIMD Railway Deploy - Mosaic Platform
**Working Directory:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project` OR `/home/user/wimd-railway-deploy`

---

## 🚨 MOST RECENT STATUS (UPDATED AUTOMATICALLY)

**Latest Critical Event:** Session Management System Deployed (2025-11-24)

**Status:** ✅ STABLE - Production healthy, AI team methodology operational

**Read These Files IN ORDER:**

1. **QUICK START:** `CLAUDE_DESKTOP_START.md` (root directory)
   - 30-second quick start guide
   - Essential commands
   - Your role and current tasks
   - Common operations

2. **COMPLETE HANDOFF:** `.ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md`
   - Full project context (as of 2025-11-28)
   - Recent work completed (session management, login diagnostic)
   - Current issues and blockers (login failure, health check)
   - Your available tasks (P1.2, P3.1)
   - Comprehensive troubleshooting guide

3. **MANDATORY PROTOCOL:** `.ai-agents/AGENT_PROTOCOL.md`
   - Your role: Infrastructure & Deployment Engineer
   - Communication protocol (SSEW format)
   - Handoff procedures
   - Safety rules and mandatory behaviors

4. **CURRENT STATUS:** `TEAM_STATUS.json` (root directory)
   - Active tasks
   - Work completed today
   - Task queue
   - Production status
   - Active warnings

---

## 📋 WHAT TO DO RIGHT NOW

### Step 1: Run Status Check (30 seconds)
```bash
# Navigate to project (if not already there)
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
# OR
cd /home/user/wimd-railway-deploy

# Get current status
./scripts/status.sh
```

### Step 2: Read Your Handoff Document (15 minutes)
```bash
# Quick start guide
cat CLAUDE_DESKTOP_START.md

# Complete handoff
cat .ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md

# Agent protocol
cat .ai-agents/AGENT_PROTOCOL.md
```

### Step 3: Review Current Tasks (2 minutes)
```bash
# Check team status
cat TEAM_STATUS.json

# Your available tasks:
# - P1.2: Update health check tooling (environment-aware)
# - P3.1: Classify uncommitted files
# - Wait for user instructions
```

### Step 4: Verify Production Health (1 minute)
```bash
# Frontend
curl https://whatismydelta.com/health

# Backend
curl https://what-is-my-delta-site-production.up.railway.app/health

# Both should return: {"ok":true,...}
```

### Current State (2025-11-28)
- ✅ Production is HEALTHY (all features working)
- ✅ Session management system operational
- ✅ Login diagnostic endpoints deployed (awaiting env var)
- ✅ Documentation consolidated
- ⚠️ Phase 1 modularization incomplete (in branch `phase1-incomplete`)
- ⚠️ Login issue for damian.seguin@gmail.com (diagnostic ready)
- ❌ DO NOT deploy Phase 1 code without integration

---

## 🗺️ PROJECT CONTEXT

### Architecture
- **Backend:** FastAPI on Railway (PostgreSQL database)
- **Frontend:** Vanilla JS on Netlify
- **API Proxy:** Netlify redirects to Railway (configured in netlify.toml)
- **Domain:** https://whatismydelta.com

### Key Directories
```
/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/
├── .ai-agents/          # AI agent communication and handoffs
├── mosaic_ui/           # Frontend source (deployed to Netlify)
├── api/                 # Backend source (deployed to Railway)
├── scripts/             # Deployment and verification scripts
├── Mosaic/              # PS101 continuity kit
├── docs/                # Documentation
└── frontend/            # Additional frontend docs
```

### Critical Files
- **CLAUDE.md** - Main architecture and status document
- **TROUBLESHOOTING_CHECKLIST.md** - Pre-flight checks
- **SELF_DIAGNOSTIC_FRAMEWORK.md** - Error handling patterns
- **netlify.toml** - API proxy configuration
- **requirements.txt** - Python dependencies

---

## 🔍 HOW TO FIND LATEST INFORMATION

### Method 1: Check This File First
This file (START_HERE.md) should be updated by each agent with:
- Latest critical event
- Date and time
- Links to relevant documentation
- Current project status

### Method 2: Find Most Recent Files
```bash
# Most recent markdown files (last 24 hours)
find .ai-agents -name "*.md" -mtime -1 -exec ls -lht {} \;

# Most recent files in project root
ls -lht *.md | head -5

# Files modified today
find . -name "*.md" -mtime 0 -not -path "./node_modules/*"
```

### Method 3: Check Git History
```bash
# Last 10 commits with dates
git log -10 --pretty=format:"%h - %an, %ar : %s"

# Files changed in last commit
git diff --name-only HEAD~1

# Recent commit messages
git log --oneline -20
```

### Method 4: Look for Dated Files
```bash
# Files with today's date in name
ls -1 *$(date +%Y-%m-%d)* .ai-agents/*$(date +%Y-%m-%d)*

# Files from November 21 (last known incident)
ls -1 *2025-11-21* .ai-agents/*2025-11-21*
```

---

## ⚠️ CRITICAL WARNINGS

### DO NOT:
- ❌ Deploy Phase 1 code from branch `phase1-incomplete` without integration
- ❌ Use raw `git push` or `netlify deploy` commands (use wrapper scripts)
- ❌ Remove authentication code without explicit approval
- ❌ Replace files without checking for feature loss
- ❌ Skip verification scripts before deployment

### ALWAYS:
- ✅ Run `./scripts/verify_critical_features.sh` before ANY deployment
- ✅ Read SESSION_START_PROTOCOL.md at session start
- ✅ Check this START_HERE.md file for latest updates
- ✅ Use deployment wrapper scripts (./scripts/deploy.sh)
- ✅ Update this file when major events occur

---

## 📞 ESCALATION PATHS

**If you find:**
- Critical features missing → STOP and alert user
- Verification scripts failing → DO NOT proceed with tasks
- Conflicting information in docs → Ask user for clarification
- This file is outdated (>3 days old) → Update it after reading recent files

**User Communication:**
- Ask: "Should I update START_HERE.md with current session info?"
- Confirm: "I found [X] dated [Y]. Is this the latest information?"
- Clarify: "I see conflicting info in [A] and [B]. Which is current?"

---

## 🔄 UPDATE PROTOCOL

**When to update this file:**
1. After any critical incident (production down, rollback, etc.)
2. After completing major features or phases
3. When file is >3 days old and you start a new session
4. When user asks "update START_HERE"

**What to update:**
1. "Last Updated" timestamp at top
2. "Latest Critical Event" section
3. "Read These Files IN ORDER" links
4. "Current State" bullets
5. Add new warnings or critical info

**How to update:**
```bash
# Read current version
cat .ai-agents/START_HERE.md

# Update using Edit tool with new information

# Commit the update
git add .ai-agents/START_HERE.md
git commit -m "Update START_HERE.md - [brief description]"
```

---

## 📚 LEARNING FROM PAST ISSUES

### Issue: AI Can't Find Latest Context
**Problem:** Each session, AI asks "where should I start?"
**Root Cause:** No single source of truth for latest status
**Solution:** This file + automatic update protocol

### Issue: Incomplete Work Gets Deployed
**Problem:** Phase 1 deployed without integration → broke UI
**Root Cause:** No clear "deployment ready" signal
**Solution:** Feature flags + verification scripts + this file's warnings

### Issue: Documentation Gets Stale
**Problem:** READMEs reference outdated issues
**Root Cause:** No update reminder in workflow
**Solution:** Update protocol in this file + session end checklist

---

## 🎯 SUCCESS CRITERIA

**This file is working if:**
- ✅ AI agents can start session in <2 minutes
- ✅ Latest critical info is in first 50 lines
- ✅ Links point to actual existing files
- ✅ "Last Updated" is within last 3 days
- ✅ User doesn't have to explain project history

**This file needs update if:**
- ❌ "Last Updated" >3 days old
- ❌ "Latest Critical Event" doesn't match reality
- ❌ File links are broken
- ❌ User has to provide context not in this file

---

**AI Agent:** Read this entire file, then proceed to SESSION_START_PROTOCOL.md
**Human:** If this file is outdated, tell the AI: "Update START_HERE.md first"
