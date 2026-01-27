# Render Deployment Guide (GitHub-Based)

**Version:** 1.0
**Created:** 2026-01-05
**Strategy:** GitHub-based deployment (user decision D4)

---

## DEPLOYMENT STRATEGY

**Approved Strategy:** GitHub-based deployment

**Why GitHub vs CLI:**
- ✅ No 45MB upload timeout (CLI limitation)
- ✅ No CLI linking ambiguity issues
- ✅ Standard practice for Render
- ✅ Automatic deploys on git push
- ✅ Deployment history in Render dashboard
- ❌ Slightly slower first deploy (Render clones repo)

---

## USER SETUP (ONE-TIME)

**Step 1: Render Dashboard**
```
1. Go to render.app/dashboard
2. Select project: wimd-career-coaching
3. Click "+ New" → "GitHub Repo"
4. Connect: DAMIANSEGUIN/wimd-render-deploy
5. Set branch: main
6. Set root directory: / (default)
7. Save
```

**Step 2: Environment Variables**
```
All existing environment variables should remain:
- OPENAI_API_KEY
- CLAUDE_API_KEY
- DATABASE_URL
- PUBLIC_API_BASE
- PUBLIC_SITE_ORIGIN
- APP_SCHEMA_VERSION (should be "v2")
```

**Step 3: Build Configuration**
```
Render auto-detects FastAPI apps.
If needed, override in render.toml:
- Build command: pip install -r requirements.txt
- Start command: gunicorn api.index:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT
```

---

## DEPLOYMENT WORKFLOW

**Normal Deploy (Main Branch):**
```bash
# 1. Ensure you're on main
git checkout main

# 2. Merge feature branch
git merge claude/start-new-session-nB5Jo

# 3. Push to GitHub
git push origin main

# 4. Render auto-deploys
# Watch: render.app/project/PROJECTID/deployments
```

**Feature Branch Testing:**
```bash
# Render doesn't auto-deploy feature branches by default
# For testing, either:

# Option A: Merge to main (standard)
git checkout main && git merge feature-branch && git push

# Option B: Configure branch deploy in Render dashboard
# Project → Settings → Environments → Add "staging" environment
# Link staging to your feature branch
```

---

## POST-DEPLOYMENT VERIFICATION

**Check 1: Service Health**
```bash
curl https://what-is-my-delta-site-production.up.render.app/health
# Should return: {"ok":true, ...}
```

**Check 2: Config Endpoint**
```bash
curl https://what-is-my-delta-site-production.up.render.app/config
# Should return: {"apiBase":"...","schemaVersion":"v2"}
```

**Check 3: Database Connection**
```bash
# Check logs in Render dashboard
# Look for: "[STORAGE] ✅ PostgreSQL connection pool created"
# Should NOT see: "SQLite fallback"
```

---

## TROUBLESHOOTING

**Issue: Deploy stuck at "Building..."**
```
Cause: Large dependency install
Fix: Wait (first deploy takes 2-5 minutes)
Check: Render dashboard → Deployment → Build Logs
```

**Issue: Deploy fails with "ModuleNotFoundError"**
```
Cause: Missing dependency in requirements.txt
Fix: Add dependency, commit, push again
Check: requirements.txt includes all imports
```

**Issue: "503 Service Unavailable"**
```
Cause: App crashed on startup
Fix: Check Render → Deployment → Deploy Logs
Common causes:
  - Missing environment variable
  - Database connection failed
  - Import error
```

**Issue: Old code still running**
```
Cause: Render cached old deployment
Fix: Render dashboard → Deployments → Redeploy
```

---

## DEPLOYMENT CHECKLIST

**Before Pushing:**
- [ ] All tests pass locally
- [ ] No console.log / print debugging left in code
- [ ] Environment variables documented in .env.example
- [ ] No secrets committed to git
- [ ] Commit message follows convention
- [ ] Feature branch merged to main

**After Render Deploy:**
- [ ] Health endpoint returns {"ok":true}
- [ ] Config shows schemaVersion:"v2"
- [ ] Database connection active (PostgreSQL, not SQLite)
- [ ] Frontend can reach backend API
- [ ] No errors in Render logs

---

## ROLLBACK PROCEDURE

**If deployment breaks production:**

```bash
# Option 1: Revert via Git
git log --oneline -5  # Find last good commit
git revert HEAD  # Or: git revert abc1234
git push origin main
# Render auto-deploys the revert

# Option 2: Redeploy Previous via Render Dashboard
1. Render → Project → Deployments
2. Find last working deployment
3. Click "..." → "Redeploy"
```

---

## MONITORING

**Production Health:**
```bash
# Automated check (add to cron or monitoring service)
curl -f https://what-is-my-delta-site-production.up.render.app/health || echo "ALERT: Service down"
```

**Render Logs:**
```bash
# Via CLI (if configured)
render logs --tail 100

# Via Dashboard
Render → Project → Deployments → [Latest] → Deploy Logs
```

---

## COST MANAGEMENT

**Render Pricing:**
- Free tier: $5 credit/month
- Pro: $20/month + usage
- Usage: ~$0.000463/GB-hour for compute

**Cost Optimization:**
- Use GitHub deployment (no CLI upload charges)
- Monitor usage in Render dashboard
- Set up billing alerts in Render settings

---

## ENVIRONMENT-SPECIFIC URLS

**Production:**
- Backend: `https://what-is-my-delta-site-production.up.render.app`
- Frontend: `https://whatismydelta.com` (Netlify)

**Development:**
- Local: `http://localhost:8000` (FastAPI)
- Local Frontend: `mosaic_ui/index.html` (open in browser)

---

## RELATED DOCUMENTATION

- **Deployment Commands:** `DEPLOYMENT_TRUTH.md`
- **Main Dev Reference:** `CLAUDE.md`
- **Troubleshooting:** `TROUBLESHOOTING_CHECKLIST.md`
- **Cross-Agent Coordination:** `.ai-agents/CROSS_AGENT_PROTOCOL.md`

---

**END OF RAILWAY DEPLOYMENT GUIDE**

**Status:** GitHub-based deployment configured
**Next Deploy:** Merge feature branch → Push to main → Render auto-deploys
