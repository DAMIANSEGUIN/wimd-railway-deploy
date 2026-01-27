# Render Migration Guide

**Created:** 2026-01-05
**Status:** IN PROGRESS
**Estimated Time:** 2 hours
**Current Step:** Database Backup

---

## MIGRATION CHECKLIST

- [x] Research completed - Render chosen as platform
- [x] render.yaml created
- [ ] **→ Database backup** (YOU ARE HERE)
- [ ] Render account setup
- [ ] Deploy to Render
- [ ] Import database
- [ ] Test deployment
- [ ] Update frontend
- [ ] Go live

---

## STEP 1: DATABASE BACKUP ⏱️ 10 minutes

### Prerequisites
Check if pg_dump is installed:
```bash
which pg_dump
```

If not installed:
```bash
# macOS
brew install postgresql

# Linux
sudo apt-get install postgresql-client
```

### Run Backup Script
```bash
cd ~/AI_Workspace/WIMD-Render-Deploy-Project
./scripts/backup_render_db.sh
```

**Expected Output:**
```
✅ Backup successful: backups/render_db_backup_TIMESTAMP.sql
```

**Backup Location:** `backups/render_db_backup_*.sql`

---

## STEP 2: CREATE RENDER ACCOUNT ⏱️ 5 minutes

1. Go to https://render.com
2. Click **"Get Started"**
3. Sign up with GitHub account
4. Authorize Render to access your repositories
5. Select repository: `DAMIANSEGUIN/wimd-render-deploy`

---

## STEP 3: DEPLOY TO RENDER ⏱️ 15 minutes

### Option A: Dashboard (Recommended)

1. **Commit render.yaml to repo:**
   ```bash
   git add render.yaml scripts/backup_render_db.sh
   git commit -m "feat(deploy): Add Render configuration for migration"
   git push origin main
   ```

2. **In Render Dashboard:**
   - Click **"New +"** → **"Blueprint"**
   - Select repository: `wimd-render-deploy`
   - Render will auto-detect `render.yaml`
   - Click **"Apply"**

3. **Set Environment Variables:**
   - Go to service → **Environment** tab
   - Add missing variables:
     - `OPENAI_API_KEY` (from Render)
     - `CLAUDE_API_KEY` (from Render)
   - `DATABASE_URL` will be auto-set by Render

4. **Deploy:**
   - Render will automatically build and deploy
   - Watch build logs for errors

### Option B: Manual Setup

If Blueprint doesn't work:

1. **Create Web Service:**
   - Dashboard → **"New +"** → **"Web Service"**
   - Connect repository: `wimd-render-deploy`
   - Name: `mosaic-backend`
   - Runtime: **Python 3**
   - Build Command: `cd backend && pip install -r requirements.txt`
   - Start Command: `cd backend && gunicorn api.index:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT`
   - Plan: **Starter ($7/month)**

2. **Create PostgreSQL Database:**
   - Dashboard → **"New +"** → **"PostgreSQL"**
   - Name: `mosaic-db`
   - Plan: **Starter ($7/month)**
   - Region: **Oregon** (same as web service)

3. **Link Database to Web Service:**
   - Go to web service → **Environment**
   - Add environment variable:
     - Key: `DATABASE_URL`
     - Value: Select **"mosaic-db"** from dropdown → **"Internal Connection String"**

4. **Add Other Environment Variables:**
   - `OPENAI_API_KEY`: (from Render)
   - `CLAUDE_API_KEY`: (from Render)
   - `PUBLIC_SITE_ORIGIN`: `https://whatismydelta.com`
   - `APP_SCHEMA_VERSION`: `v2`

---

## STEP 4: IMPORT DATABASE ⏱️ 20 minutes

### Get Render Database Connection String

1. Go to Render Dashboard → **mosaic-db**
2. Copy **"External Database URL"** (looks like: `postgresql://user:pass@host:port/db`)

### Import Backup

```bash
# Set Render DB URL
export RENDER_DB_URL="postgresql://..."  # Paste from Render

# Import backup
psql "$RENDER_DB_URL" < backups/render_db_backup_*.sql

# Verify import
psql "$RENDER_DB_URL" -c "SELECT COUNT(*) FROM users;"
psql "$RENDER_DB_URL" -c "SELECT COUNT(*) FROM sessions;"
```

**Expected:** Row counts should match Render database

### Troubleshooting Import

If import fails with "database does not exist":
```bash
# Create database first
psql "$RENDER_DB_URL" -c "CREATE DATABASE mosaic;"

# Then import
psql "$RENDER_DB_URL" < backups/render_db_backup_*.sql
```

---

## STEP 5: TEST DEPLOYMENT ⏱️ 15 minutes

### Get Render Service URL

In Render Dashboard → **mosaic-backend** → Copy URL (e.g., `https://mosaic-backend.onrender.com`)

### Test Endpoints

```bash
# Set URL
export RENDER_URL="https://mosaic-backend.onrender.com"

# Test health check
curl "$RENDER_URL/health"
# Expected: {"ok": true, "status": "healthy", ...}

# Test config
curl "$RENDER_URL/config"
# Expected: {"apiBase": "...", "schemaVersion": "v2"}

# Test database connection
curl "$RENDER_URL/auth/me" -H "Authorization: Bearer test"
# Expected: 401 Unauthorized (but proves DB is connected)
```

### Check Logs

In Render Dashboard → **mosaic-backend** → **Logs** tab:
- Look for: `"Startup complete"`
- No errors about database connection
- No NumPy import errors

---

## STEP 6: UPDATE FRONTEND ⏱️ 10 minutes

### Find Frontend API Configuration

```bash
# Search for API_BASE or API URL in frontend
grep -r "render.app" . --include="*.js" --include="*.html"
grep -r "API_BASE" . --include="*.js" --include="*.html"
```

### Update API URLs

**Location:** Likely in:
- `index.html` (check `<script>` tags)
- `mosaic_ui/index.html`
- Frontend JavaScript files

**Change:**
```javascript
// OLD
const API_BASE = "https://what-is-my-delta-site-production.up.render.app"

// NEW
const API_BASE = "https://mosaic-backend.onrender.com"
```

### Deploy Frontend Update

```bash
git add .
git commit -m "feat(frontend): Update API URL to Render deployment"
git push origin main
```

If frontend is on Netlify:
- Netlify will auto-deploy from GitHub push
- Wait 1-2 minutes for deploy
- Check Netlify dashboard for deploy status

---

## STEP 7: VERIFY PRODUCTION ⏱️ 15 minutes

### Test from Frontend

1. Open https://whatismydelta.com
2. Open browser DevTools → **Console** tab
3. Test features:
   - [ ] Page loads without errors
   - [ ] Can register new account
   - [ ] Can login
   - [ ] Chat interface works
   - [ ] File upload works
   - [ ] PS101 flow works

### Monitor Logs

Keep Render logs open:
- Render Dashboard → **mosaic-backend** → **Logs**
- Watch for errors during frontend testing
- Verify no database connection issues

### Test Critical Endpoints

```bash
# Health check
curl https://whatismydelta.com/health
# or: curl https://mosaic-backend.onrender.com/health

# Test with actual user (if you have test credentials)
curl -X POST https://mosaic-backend.onrender.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

---

## STEP 8: CLEANUP ⏱️ 10 minutes

### Archive Render Configuration

```bash
mkdir -p archive/render_2026-01-05
mv nixpacks.toml archive/render_2026-01-05/
mv render.toml archive/render_2026-01-05/
mv render_*.txt archive/render_2026-01-05/

git add archive/
git commit -m "chore: Archive Render configuration files"
git push origin main
```

### Update Documentation

Update `CLAUDE.md`:
```markdown
## Deployment

**Platform:** Render (migrated 2026-01-05)
**Backend URL:** https://mosaic-backend.onrender.com
**Frontend URL:** https://whatismydelta.com (Netlify)
**Database:** PostgreSQL (Render managed)

**Previous:** Render (deprecated due to platform issues)
```

### Cancel Render Subscription

1. Go to Render Dashboard
2. Project settings → **Danger Zone**
3. **Delete Project** (after confirming everything works on Render)

**WAIT:** Keep Render running for 24-48 hours as backup

---

## ROLLBACK PLAN

If Render deployment fails:

### Quick Rollback
```bash
# Revert frontend API URL
git revert HEAD
git push origin main
```

Render will still be running and frontend will reconnect.

### Full Rollback
1. Keep Render project active
2. Don't delete Render database
3. Frontend can switch back to Render URL instantly

---

## SUCCESS CRITERIA

Migration is complete when:

- [x] render.yaml created
- [ ] Database backed up
- [ ] Render account created
- [ ] Service deployed to Render
- [ ] Database imported to Render
- [ ] Health check passes: `curl /health` → `{"ok":true}`
- [ ] Frontend API URL updated
- [ ] All features tested and working
- [ ] No errors in Render logs for 15+ minutes
- [ ] Render can be safely deleted

---

## COST COMPARISON

**Render (before migration):**
- Usage-based: ~$10-20/month (estimated)
- Unreliable deployment

**Render (after migration):**
- Web Service: $7/month
- PostgreSQL: $7/month
- Total: $14/month (predictable)
- Reliable deployment

**Savings:** Potentially $6/month + no more debugging time

---

## TROUBLESHOOTING

### Issue: Render build fails

**Check:**
- Is `backend/requirements.txt` in repo?
- Are all dependencies listed?
- Check build logs for specific error

**Fix:**
- Ensure `rootDir: backend` in render.yaml
- Verify requirements.txt has no typos

### Issue: Health check fails on Render

**Check:**
- Is gunicorn starting?
- Is PORT environment variable set? (Render sets automatically)
- Check logs for startup errors

**Fix:**
- Verify start command in render.yaml
- Check if `startup_checks.py` is causing issues
- Temporarily disable startup checks if needed

### Issue: Database import fails

**Check:**
- Is backup file valid? `head backups/render_db_backup_*.sql`
- Does Render DB exist?
- Are credentials correct?

**Fix:**
- Re-export from Render
- Verify RENDER_DB_URL format
- Check Render DB status in dashboard

### Issue: Frontend can't reach backend

**Check:**
- Is Render service running?
- Is health check passing?
- Are CORS settings correct?

**Fix:**
- Verify API_BASE URL in frontend
- Check Render service logs
- Ensure FastAPI CORS middleware is configured

---

## NEXT STEPS AFTER MIGRATION

1. **Monitor for 24 hours**
   - Watch Render logs
   - Check error rates
   - Monitor user feedback

2. **Performance tuning**
   - Adjust worker count if needed
   - Monitor response times
   - Scale plan if traffic increases

3. **Set up monitoring**
   - Configure Render alerts
   - Add uptime monitoring (UptimeRobot, etc.)
   - Set up log aggregation if needed

4. **Delete Render**
   - After 48 hours of stable Render operation
   - Download final backup before deletion
   - Cancel subscription

---

## SUPPORT RESOURCES

**Render:**
- Docs: https://render.com/docs
- Community: https://community.render.com
- Support: support@render.com (Starter plan includes email support)

**Migration Help:**
- Render Python Guide: https://render.com/docs/deploy-fastapi
- Render PostgreSQL: https://render.com/docs/databases
- Render Blueprint: https://render.com/docs/blueprint-spec

---

**END OF MIGRATION GUIDE**

**Current Status:** Ready to begin - run backup script first
**Time Remaining:** ~2 hours
**Risk Level:** LOW (can rollback easily)
