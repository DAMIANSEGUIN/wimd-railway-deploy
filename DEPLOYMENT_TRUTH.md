# DEPLOYMENT TRUTH - SINGLE SOURCE OF AUTHORITY
**Created:** 2025-11-25 by Claude Code
**Last Verified:** 2025-11-25
**Status:** CANONICAL - All other docs must reference this file

---

## ⚠️ IF YOU ARE CONFUSED ABOUT DEPLOYMENT, READ THIS FIRST

This file resolves weeks of confusion. **This is the definitive answer.**

---

## THE CORRECT DEPLOYMENT PROCESS

```bash
# 1. Push to origin (GitHub)
git push origin main

# 2. Railway auto-deploys from GitHub
# (NO manual push to railway-origin needed)

# 3. For frontend, deploy to Netlify
netlify deploy --prod --dir mosaic_ui
```

**That's it. Nothing more complex.**

---

## HARD EVIDENCE

### Commit 302bc98 (Nov 17, 2025) Already Resolved This

**From commit message:**
> **Problem Found:**
> - CLAUDE.md said: 'push to railway-origin main'
> - Reality (Nov 9, 11, 14, 18 deploys): push to origin only
> - railway-origin is legacy remote with no write access
>
> **Root Cause:**
> - railway-origin (what-is-my-delta-site) is historical mirror
> - Railway deploys via CLI/API, not git push
> - Documentation never updated when process changed

### Remote Configuration

```
origin          https://github.com/DAMIANSEGUIN/wimd-railway-deploy.git
                ✅ ACTIVE - Primary repository
                ✅ Write access: YES
                ✅ Railway watches this repo

railway-origin  https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git
                ❌ LEGACY - Historical mirror
                ❌ Write access: NO (403 errors)
                ❌ NOT required for deployment
```

### Successful Deployments Since Nov 9, 2025

All used `origin` only:
- Nov 9: Deploy logs show origin-only
- Nov 11: Deploy logs show origin-only
- Nov 14: Deploy logs show origin-only
- Nov 17: Documentation audit completed
- Nov 18: Deploy log explicitly documents correct process
- Nov 24: Login diagnostic implementation

**Zero deployments used railway-origin.**

---

## WHY CONFUSION PERSISTED

### Timeline:
1. **Nov 3-9:** Wrapper scripts created (`scripts/deploy.sh`, `scripts/push.sh`)
2. **Scripts hardcoded:** `railway-origin` as deployment target
3. **Nov 17:** Documentation updated (CLAUDE.md, SESSION_START_PROTOCOL.md)
4. **Scripts NOT updated:** Still reference railway-origin
5. **Nov 25:** Scripts still broken, causing deployment failures

**The Problem:** Scripts lag behind documentation by 8 days.

---

## HOW RAILWAY ACTUALLY DEPLOYS

Railway does **NOT** deploy via git push.

Railway deploys via:
1. **GitHub Integration** - Railway service connected to `wimd-railway-deploy` repo
2. **Auto-deploy** - Watches `main` branch for changes
3. **Manual triggers** - Railway CLI (`railway up`) or Dashboard

**No `git push railway-origin` is involved.**

---

## WHAT NEEDS TO BE FIXED

### 1. Update `scripts/deploy.sh`
**Current (BROKEN):**
```bash
# Calls push.sh with railway-origin
./scripts/push.sh railway-origin main
```

**Should be:**
```bash
# Calls push.sh with origin
./scripts/push.sh origin main
```

### 2. Update `scripts/push.sh`
**Current (BROKEN):**
```bash
# Expects railway-origin as argument
./scripts/push.sh railway-origin main
```

**Should accept:**
```bash
# Uses origin by default
./scripts/push.sh origin main
```

### 3. Remove `railway-origin` from docs
- Any remaining references to railway-origin should say "LEGACY"
- Update to reference origin instead

---

## VERIFICATION CHECKLIST

Before considering this issue resolved:

- [ ] `scripts/deploy.sh` uses `origin`, not `railway-origin`
- [ ] `scripts/push.sh` uses `origin`, not `railway-origin`
- [ ] CLAUDE.md references this file as source of truth
- [ ] SESSION_START_PROTOCOL.md references this file
- [ ] Test: `./scripts/deploy.sh railway` completes without 403 error
- [ ] Test: Push to origin triggers Railway auto-deploy

---

## FOR AI AGENTS

**If you are uncertain about deployment:**

1. **Read this file first** - `DEPLOYMENT_TRUTH.md`
2. **Do not reference** wrapper scripts (they may be outdated)
3. **Do not reference** CLAUDE.md alone (it may be outdated)
4. **Use this process:**
   ```bash
   git push origin main
   # Railway auto-deploys
   ```

**If wrapper scripts fail:**
- They are outdated
- Use manual process above
- File bug: "Wrapper scripts not updated to match DEPLOYMENT_TRUTH.md"

---

## EVIDENCE LINKS

- **Commit 302bc98:** Documentation audit (Nov 17, 2025)
- **Commit 31d099c:** Deployment ambiguity documented (Nov 17, 2025)
- **Deploy log:** `deploy_logs/2025-11-18_ps101-qa-mode.md`
- **Audit checklist:** `.ai-agents/DEPLOYMENT_AUDIT_CHECKLIST.md`

---

## HOW TO UPDATE THIS FILE

Only update this file when:
1. **Deployment process actually changes** (verified by multiple successful deploys)
2. **New evidence emerges** (git logs, Railway dashboard, etc.)
3. **User confirms** process change

**Do not update based on:**
- Documentation in other files
- Assumptions
- "It should work this way"
- Wrapper script behavior

**Evidence first. Reality wins.**

---

## DEPLOYMENT PROCESS - CANONICAL REFERENCE

**Frontend (Netlify):**
```bash
git push origin main
netlify deploy --prod --dir mosaic_ui
```

**Backend (Railway):**
```bash
git push origin main
# Railway auto-deploys within 2-5 minutes
# Check: https://what-is-my-delta-site-production.up.railway.app/health
```

**No railway-origin push required.**
**No railway-origin push will work (403 error).**
**Do not attempt to push to railway-origin.**

---

**END OF CANONICAL REFERENCE**

---

## HISTORY OF THIS ISSUE

- **Weeks of confusion:** Multiple agents attempted railway-origin push
- **Nov 17:** Issue definitively resolved in commit 302bc98
- **Nov 17-25:** Wrapper scripts not updated, confusion continued
- **Nov 25:** This canonical document created to end confusion permanently

**Lesson:** Keep scripts in sync with documentation. Automate if possible.

---

**Last Updated:** 2025-11-25
**Next Review:** After next successful deployment
**Authority Level:** MAXIMUM - Overrides all other documentation if conflict exists
