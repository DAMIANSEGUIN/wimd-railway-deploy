# CRASH RECOVERY — Quick Reference

**Last Updated:** 2026-02-03
**Project:** /Users/damianseguin/WIMD-Deploy-Project

---

## IMMEDIATE CHECKS (Run First)

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

# What was I working on?
git status
git log --oneline -3

# Are gates passing?
./scripts/gate_10_codebase_health.sh

# Is production healthy?
curl https://mosaic-backend-tpog.onrender.com/health
```

---

## CURRENT STATE (as of last successful session)

**Date:** 2026-02-03
**Status:** ✅ All systems operational
**Last Commit:** 67d4b77 (SSL cert fix in Gate 9)
**Production:** https://mosaic-backend-tpog.onrender.com (healthy)
**Frontend:** https://whatismydelta.com (live)

**Recent Issue Resolved:**
- Gate 9 SSL certificate verification was failing
- Caused deployment loop (couldn't push due to prod health check failure)
- Fixed in commit 67d4b77
- Root cause: Local certifi package, not actual production issue

---

## WHERE TO FIND CONTEXT

1. **Control Surface:** `SESSION_START_CONTROL_SURFACE_v2.2.md`
2. **Session Summary:** `NEXT_SESSION_START.md`
3. **Full Backup:** `SESSION_BACKUP_2026_01_27_END.md`
4. **Agent State:** `.mosaic/agent_state.json`
5. **Session Logs:** `~/.claude/projects/-Users-damianseguin/*.jsonl` (most recent)
6. **Debug Logs:** `~/.claude/debug/*.txt`

---

## WHAT WAS THE LAST SESSION TRYING TO DO?

**Check session logs:**
```bash
# Find most recent session file
ls -lt ~/.claude/projects/-Users-damianseguin/*.jsonl | head -1

# Read last few entries (look for tool calls before crash)
tail -100 ~/.claude/projects/-Users-damianseguin/[session-id].jsonl | grep -i "tool_use\|error"
```

**Check git for uncommitted work:**
```bash
git diff  # Uncommitted changes
git diff --cached  # Staged changes
git stash list  # Stashed work
```

---

## VERIFICATION CHECKLIST

```
□ Git status clean or understood?
□ All 10 gates passing?
□ Production health check passing?
□ Version endpoint matches expected commit?
□ No errors in Render logs?
□ Frontend accessible?
□ Backend API responding?
```

**Run verification:**
```bash
# Full gate check
./scripts/gate_10_codebase_health.sh

# Production endpoints
curl https://mosaic-backend-tpog.onrender.com/health
curl https://mosaic-backend-tpog.onrender.com/__version
curl -I https://whatismydelta.com

# Git status
git status
git log --oneline -5
```

---

## COMMON ISSUES & FIXES

### Issue: "Gate 9 failing with SSL error"
**Diagnosis:**
```bash
python3 .mosaic/enforcement/gate_9_production_check.py
```
**If SSL cert error:**
- This is LOCAL cert store issue, not production
- Check production directly: `curl https://mosaic-backend-tpog.onrender.com/health`
- If production healthy, the gate needs fixing (not production)

**Fix applied:** commit 67d4b77

---

### Issue: "Stuck in deployment loop"
**Check:**
```bash
git log --oneline -3  # What was trying to deploy?
git status  # Uncommitted changes blocking push?
```
**If pre-push hook blocking:**
- Read hook output carefully
- Fix actual issue (don't bypass)
- Verify production state independently

---

### Issue: "Uncommitted changes from crashed session"
**Review:**
```bash
git diff  # What was changed?
git status  # What was staged?
```
**Decision tree:**
- If makes sense + tests pass → Commit
- If incomplete/broken → `git reset --hard HEAD`
- If unsure → Ask user

---

### Issue: "Don't know what I was working on"
**Reconstruct:**
1. Read `.mosaic/agent_state.json` → `current_task` field
2. Read last session log entries
3. Read `git log -5` commit messages
4. Check `NEXT_SESSION_START.md` for work queue
5. Ask user if still unclear

---

## SAFE RESUME PROCEDURE

1. **Verify current state** (run all checks above)
2. **Understand what was attempted** (session logs, git diff)
3. **Assess damage** (gates passing? production healthy?)
4. **Clean up if needed** (reset bad changes, fix issues)
5. **Communicate status to user** (what you found, what you recommend)
6. **Get authorization** (USER_GO or session-level) before proceeding

---

## EMERGENCY CONTACTS

**Production URLs:**
- Backend: https://mosaic-backend-tpog.onrender.com
- Frontend: https://whatismydelta.com
- Render Dashboard: https://dashboard.render.com
- Netlify Dashboard: https://app.netlify.com

**Key Files:**
- Entry point: `backend/api/index.py`
- Database: `backend/api/storage.py`
- Gates: `.mosaic/enforcement/gate_*.py`
- Scripts: `scripts/gate_10_codebase_health.sh`

---

## LAST KNOWN GOOD STATE

**Commit:** 67d4b77
**Date:** 2026-02-03
**Status:** All gates passing, production healthy
**Branch:** main
**Remote:** origin/main (2 commits ahead)

**What works:**
- ✅ Production backend responding
- ✅ Production frontend accessible
- ✅ All 10 gates passing
- ✅ SSL cert issue resolved
- ✅ No active blockers

**Pending:**
- 2 commits ahead of origin (need to push)
- Commits: 67d4b77 (SSL fix), bd74fb9 (gitignore update)

---

**When in doubt:** Stop, verify state, ask user for context.
**Don't assume:** Check production directly, don't trust logs alone.
**Don't bypass gates:** If gate failing, fix the issue, don't skip the gate.
