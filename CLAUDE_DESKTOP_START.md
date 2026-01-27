# 🚀 Quick Start for Claude Desktop

**Project:** WIMD Render Deploy - Mosaic Platform
**Date:** 2025-11-28
**Your Role:** Full-stack development with persistent context

---

## 📂 Git Repository

**Clone or open:**

```bash
git clone https://github.com/DAMIANSEGUIN/wimd-render-deploy
cd wimd-render-deploy
git checkout phase1-incomplete
```

**Local path (if already cloned):**

```
/Users/damianseguin/WIMD-Deploy-Project
```

---

## 🎯 Immediate Priorities

### P0 - Critical Issues

1. **PS101 Hoisting Bug** (Primary Focus)
   - PS101 questionnaire doesn't advance due to function scope issue
   - Baseline: `backups/pre-ps101-fix_20251126_220704Z/`
   - Login ✅ Chat ✅ PS101 ❌

2. **Login Diagnostic Deployment**
   - Commit `b7e042c` has diagnostic endpoints
   - Needs deployment to Render with `ADMIN_DEBUG_KEY` env var

### P1 - High Priority

3. **Phase 1/2 Integration** (95% complete)
   - Just needs 3-line integration in IIFE
   - Will unblock modularization

4. **File Cleanup**
   - 30 uncommitted files need classification

---

## 📚 Essential Documentation

**Read these files IN ORDER:**

1. **`.ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md`** ← **START HERE**
   - Complete handoff from Gemini
   - Current status and priorities

2. **`AI_RESUME_STATE.md`**
   - Project state, critical issues, latest backup

3. **`.ai-agents/PS101_BASELINE_STATUS_2025-11-27.md`**
   - Details on PS101 hoisting bug and baseline

4. **`.ai-agents/GEMINI_PS101_FIX_APPROVAL_2025-11-26.md`**
   - Architectural guidance for PS101 fix

---

## 🔑 Key Information

### Production URLs

- **Frontend:** <https://whatismydelta.com> (Netlify) - ✅ Healthy
- **Backend:** <https://what-is-my-delta-site-production.up.render.app> (Render) - ✅ Healthy

### Current Branch

- **Branch:** `phase1-incomplete`
- **Status:** 30 uncommitted files
- **Remote:** `origin` (auto-deploys to Render on push to main)

### Deployment Commands

```bash
# ALWAYS use wrapper scripts (never raw git push):
./scripts/deploy.sh netlify    # Deploy frontend
./scripts/deploy.sh render    # Deploy backend
./scripts/deploy.sh all        # Deploy both

# Verify before deploy:
./scripts/verify_critical_features.sh
```

### Critical Rules

- ❌ Never use `git push origin main` directly
- ❌ Never use `netlify deploy --prod` directly
- ✅ Always use `./scripts/deploy.sh` wrapper
- ✅ Always verify before deploy

---

## 🏗️ Architecture Quick Reference

**Stack:**

- Frontend: Vanilla JS on Netlify
- Backend: FastAPI on Render
- Database: PostgreSQL (Render managed)
- Domain: whatismydelta.com

**Key Files:**

- `mosaic_ui/index.html` - Main frontend (4000+ lines, needs modularization)
- `frontend/index.html` - Mirror of mosaic_ui
- `api/index.py` - FastAPI backend
- `api/storage.py` - Database operations

**Current Issue:**

- `mosaic_ui/index.html` has PS101 hoisting bug (line ~2530 vs ~3759)
- Login works for new users, fails for existing user (<damian.seguin@gmail.com>)

---

## 💡 Getting Started

1. **Open the repository** in Claude Desktop
2. **Read** `.ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md`
3. **Check** current git status: `git status`
4. **Review** the PS101 hoisting issue details
5. **Ask questions** if anything is unclear

---

## 📞 Context You Have

With Claude Desktop's persistent context, you don't need to re-read everything each session. You'll build understanding as you work.

**Key advantages:**

- ✅ Continuous conversation across sessions
- ✅ Remember previous discussions about PS101, login, Phase 1
- ✅ No need for extensive handoff documentation
- ✅ Direct git access and file operations

---

## 🎬 First Action

**Suggested first command:**

```bash
# Navigate to project and check status
cd /Users/damianseguin/WIMD-Deploy-Project
git status
cat .ai-agents/HANDOFF_FOR_CLAUDE_2025-11-28.md
```

Then ask: "What should I work on first?" or start with PS101 hoisting bug.

---

**Welcome aboard! Your persistent context is your superpower.**
