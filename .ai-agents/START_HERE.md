# 🎯 START HERE - AI Agent Onboarding (Auto-Updated)

**Last Updated:** 2025-11-27 by Codex (terminal) via Claude/Gemini
**Project:** WIMD Railway Deploy - Mosaic Platform
**Working Directory:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project`

---

## 🚨 MOST RECENT STATUS (UPDATED AUTOMATICALLY)

**Latest Critical Event:** PS101 baseline locked; login/chat stable, PS101 still blocked by hoisting bug (2025-11-27)

**Status:** ⚠️ PARTIALLY STABLE – Login & Chat OK; PS101 blocked on `handleStepAnswerInput` scope/hoisting issue

**Read These Files IN ORDER:**

1. **TODAY’S BASELINE:** `.ai-agents/PS101_BASELINE_STATUS_2025-11-27.md`
   - Defines current working baseline (pre-ps101-fix backup)
   - Confirms: Login ✅, Chat ✅, PS101 ❌ (hoisting bug)
   - Explains why `pre-scope-fix` and `post-restore` backups are not usable baselines

2. **DOC INDEX:** `.ai-agents/TEAM_DOCUMENTATION_REFERENCE.md`
   - Points to backup manifests and handoff docs
   - Summarizes current recovery plan status

3. **LATEST INCIDENT (HISTORICAL):** `.ai-agents/FINAL_STATUS_2025-11-21_EVENING.md`
   - Timeline of Nov 21 Phase 1 failure and rollback

4. **TECHNICAL DETAILS (PHASE 1):** `.ai-agents/CRITICAL_ISSUE_PHASE1_BREAKS_UI_2025-11-21.md`
   - Root cause and lessons from the Phase 1 modularization incident

5. **MANDATORY PROTOCOL:** `.ai-agents/SESSION_START_PROTOCOL.md`
   - Critical alerts
   - Session initialization and operating rules

---

## 📋 WHAT TO DO RIGHT NOW

### Step 1: Run Session Start Protocol
```bash
# Navigate to project
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

# Run verification
./scripts/verify_critical_features.sh

# Check PS101 continuity
./Mosaic/PS101_Continuity_Kit/check_spec_hash.sh

# Review recent activity
git log -5 --oneline
```

### Step 2: Understand Current State
- ✅ Website is WORKING (rollback complete)
- ✅ Railway backend healthy
- ✅ Netlify frontend deployed
- ⚠️ Phase 1 modularization incomplete (in branch `phase1-incomplete`)
- ❌ DO NOT deploy Phase 1 code without Phase 2 integration

### Step 3: Check for User Instructions
Look for recent files:
```bash
ls -lht /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/*.md | head -10
ls -lht /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/*.md | head -10
```

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
