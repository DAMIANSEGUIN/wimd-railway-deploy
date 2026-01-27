# Render Reset - Parallel Preparation Tasks

**Work completed while Gemini validates**

**Created:** 2025-12-14
**Status:** DRAFT - Awaiting approval to implement

---

## 1. VERSION ENDPOINT IMPLEMENTATION (READY TO CODE)

### Current Status

- ❌ `/__version` endpoint does NOT exist in codebase
- Location to add: `api/index.py` after line 108 (where `app = FastAPI()` is defined)

### Implementation Ready

```python
# Add to api/index.py after line 108

import subprocess
from datetime import datetime

@app.get("/__version")
async def version_info():
    """Runtime identity endpoint for deployment verification"""
    try:
        # Get git SHA
        git_sha = subprocess.check_output(
            ['git', 'rev-parse', 'HEAD'],
            cwd=Path(__file__).parent.parent
        ).decode().strip()
    except Exception:
        git_sha = os.getenv("RAILWAY_GIT_COMMIT_SHA", "unknown")

    return {
        "git_sha": git_sha[:8],
        "git_sha_full": git_sha,
        "build_timestamp": datetime.utcnow().isoformat() + "Z",
        "environment": os.getenv("RAILWAY_ENVIRONMENT", "unknown"),
        "python_version": f"{os.sys.version_info.major}.{os.sys.version_info.minor}.{os.sys.version_info.micro}",
        "service_name": "mosaic-backend",
        "status": "healthy"
    }
```

### Deployment Verification Test

```bash
# After deployment, test with:
curl https://NEW_SERVICE_URL/__version

# Expected response:
{
  "git_sha": "684dad3d",
  "git_sha_full": "684dad3d4428194d67b18bc8c784ab87d895615a",
  "build_timestamp": "2025-12-14T...",
  "environment": "production",
  "python_version": "3.11.x",
  "service_name": "mosaic-backend",
  "status": "healthy"
}
```

**Ready to implement:** ✅ YES (pending approval)

---

## 2. FRONTEND API ENDPOINT UPDATE (LOCATIONS IDENTIFIED)

### Current API References Found

**Primary Location (ACTIVE):**

```
File: mosaic_ui/index.html
Line 6: --api:'https://mosaic-platform.vercel.app'  (CSS variable - LEGACY)
Line 1954: apiBase = 'https://what-is-my-delta-site-production.up.render.app';  (JavaScript - CURRENT)
```

**Config Fallback:**

```
Lines 1937-1938: Config endpoint fallback
  'https://what-is-my-delta-site-production.up.render.app/config',
  'https://whatismydelta.com/config'
```

### Update Required

**Change 1: Line 1954** (Primary API base)

```javascript
// BEFORE:
apiBase = 'https://what-is-my-delta-site-production.up.render.app';

// AFTER (once new service deployed):
apiBase = 'https://NEW_SERVICE_NAME-production.up.render.app';
```

**Change 2: Line 6** (CSS variable - cleanup)

```css
/* BEFORE: */
--api:'https://mosaic-platform.vercel.app'

/* AFTER: */
--api:'https://NEW_SERVICE_NAME-production.up.render.app'
```

**Change 3: Lines 1937-1938** (Config fallback)

```javascript
// BEFORE:
'https://what-is-my-delta-site-production.up.render.app/config',

// AFTER:
'https://NEW_SERVICE_NAME-production.up.render.app/config',
```

**Total Changes:** 3 lines in `mosaic_ui/index.html`

**Ready to implement:** ✅ YES (need new service URL first)

---

## 3. ENVIRONMENT VARIABLE MIGRATION PLAN

### Variables to Recreate (10 total)

From `/tmp/render_env_backup.json`:

```bash
# Critical (App won't start without these):
APP_SCHEMA_VERSION=v2
OPENAI_API_KEY=[from backup]
CLAUDE_API_KEY=[from backup]
DATABASE_URL=[Render will auto-provide if PostgreSQL is project-level]

# Important (Features degraded without these):
COACH_EMAIL=damian.seguin@gmail.com
COACH_GOOGLE_CALENDAR_ID=primary
GOOGLE_SERVICE_ACCOUNT_KEY=[JSON from backup]

# Payment Integration (Optional for MVP):
PAYPAL_CLIENT_ID=[from backup]
PAYPAL_CLIENT_SECRET=[from backup]
PAYPAL_MODE=live
```

### Migration Script (Manual Execution)

```bash
# After new service created, run these commands:

# Get service name from user
NEW_SERVICE="mosaic-backend"  # or as specified by user

# Set critical variables
render variables set APP_SCHEMA_VERSION=v2 --service $NEW_SERVICE
render variables set OPENAI_API_KEY="<value_from_backup>" --service $NEW_SERVICE
render variables set CLAUDE_API_KEY="<value_from_backup>" --service $NEW_SERVICE

# DATABASE_URL should auto-populate if PostgreSQL is project-level
# If not, copy from backup:
# render variables set DATABASE_URL="<value_from_backup>" --service $NEW_SERVICE

# Set coach variables
render variables set COACH_EMAIL=damian.seguin@gmail.com --service $NEW_SERVICE
render variables set COACH_GOOGLE_CALENDAR_ID=primary --service $NEW_SERVICE
render variables set GOOGLE_SERVICE_ACCOUNT_KEY='<json_from_backup>' --service $NEW_SERVICE

# Set payment variables (optional)
render variables set PAYPAL_CLIENT_ID="<value_from_backup>" --service $NEW_SERVICE
render variables set PAYPAL_CLIENT_SECRET="<value_from_backup>" --service $NEW_SERVICE
render variables set PAYPAL_MODE=live --service $NEW_SERVICE

# Verify all variables set
render variables --service $NEW_SERVICE
```

**Ready to execute:** ✅ YES (after Phase 2 service creation)

---

## 4. DEPLOYMENT VERIFICATION CHECKLIST

### Pre-Deployment Checks

```bash
# 1. Verify git is clean and on correct branch
git status
git log --oneline -1

# Expected: On main branch, HEAD at 684dad3 or later

# 2. Verify environment backup exists
cat /tmp/render_env_backup.json | python3 -m json.tool | head -20

# Expected: Valid JSON with 10 variables

# 3. Verify Render CLI is authenticated
render whoami

# Expected: Logged in as damian.seguin@gmail.com
```

### Post-Deployment Checks

```bash
# 1. Check service status
render status --service $NEW_SERVICE

# Expected: Shows service running

# 2. Get service URL
render status --service $NEW_SERVICE | grep -i url

# 3. Test health endpoint
curl https://$NEW_SERVICE_URL/health

# Expected: {"ok": true, ...}

# 4. Test version endpoint
curl https://$NEW_SERVICE_URL/__version

# Expected: {"git_sha": "684dad3d", ...}

# 5. Test database connection
curl https://$NEW_SERVICE_URL/health

# Expected: "database": {"connected": true, "type": "postgresql"}
```

### Frontend Verification

```bash
# 1. Update mosaic_ui/index.html (3 lines)
# 2. Deploy to Netlify
netlify deploy --prod --dir mosaic_ui

# 3. Test frontend
open https://whatismydelta.com

# 4. Check browser console
# Expected: No CORS errors, API calls succeed

# 5. Test end-to-end flow
# - Register new user
# - Login
# - Complete PS101 questionnaire
# - Test chat/coach interaction
```

---

## 5. ROLLBACK PROCEDURES (READY TO EXECUTE)

### If New Service Fails to Start

```bash
# Check logs for error
render logs --service $NEW_SERVICE | tail -100

# Common issues:
# - Missing env var: Add it via render variables set
# - Database connection: Verify DATABASE_URL present
# - Build failure: Check for syntax errors in code
```

### If Frontend Breaks

```bash
# Revert frontend to previous deployment
# In Netlify dashboard: Deployments → Previous deploy → Publish

# Or redeploy with old URL:
git checkout mosaic_ui/index.html  # revert changes
netlify deploy --prod --dir mosaic_ui
```

### If Database Inaccessible

```bash
# Verify PostgreSQL service exists at project level
render status

# If DATABASE_URL missing, add manually:
render variables set DATABASE_URL="postgresql://postgres:PASSWORD@postgres.render.internal:5432/render" --service $NEW_SERVICE

# Test connection:
curl https://$NEW_SERVICE_URL/health | grep database
```

### Nuclear Rollback (Abort Everything)

```bash
# Delete new service via Render dashboard
# Keep old service running
# No changes to frontend needed (already pointing to old service)

# Result: Back to original state, no data loss
```

---

## 6. COST ANALYSIS

### Current State (Old Service)

- Service: what-is-my-delta-site (running but not responding)
- PostgreSQL: Active (project-level assumed)
- Cost: $X/month (current Render plan)

### New State (After Migration)

- Service: mosaic-backend (new, replacing old)
- PostgreSQL: Same (shared at project level)
- Obsolete services: 6 projects to delete (no cost savings unless active)

### Cost Impact

- No additional cost (replacing service, not adding)
- Possible savings: Delete obsolete projects if they have active resources
- Database: No change (same PostgreSQL service)

---

## 7. TIMELINE ESTIMATE

**Assuming all validations pass:**

| Phase | Task | Duration | Dependencies |
|-------|------|----------|--------------|
| 2 | Create service (dashboard) | 5 min | User action |
| 3 | Set environment variables | 10 min | Phase 2 complete |
| 4 | Deploy via Render CLI | 5-10 min | Phase 3 complete |
| 5 | Verify version endpoint | 2 min | Phase 4 complete |
| 6 | Update + deploy frontend | 10 min | Phase 5 complete |
| 7 | Delete obsolete projects | 15 min | Phase 6 complete |

**Total Execution Time:** ~45-60 minutes (excludes validation)

**Critical Path:** Validation → User approval → Execution
**Blocker:** Gemini validation (current)

---

## 8. SUCCESS CRITERIA (MEASURABLE)

### Service Health

- [ ] `curl $NEW_SERVICE_URL/health` returns 200 OK
- [ ] `curl $NEW_SERVICE_URL/__version` returns valid JSON with git SHA
- [ ] Health endpoint shows `"database": {"connected": true}`
- [ ] No errors in Render logs (past 100 lines)

### Frontend Integration

- [ ] Frontend loads without console errors
- [ ] API calls succeed (no 404/CORS errors)
- [ ] User registration works
- [ ] User login works
- [ ] Chat/coach interaction works

### Data Persistence

- [ ] New user created in database
- [ ] User can login after logout
- [ ] Session data persists across page refreshes

### Deployment Automation

- [ ] `git push origin main` triggers Render auto-deploy
- [ ] New commits deploy automatically (no manual render up needed)

---

## 9. GEMINI VALIDATION INTEGRATION

**Validation Results Needed Before Implementation:**

| Preparation Item | Depends On Validation | Status |
|------------------|----------------------|--------|
| Version endpoint code | Validation 3 (endpoint check) | ⏳ Awaiting |
| Frontend API update | Validation 2 (location check) | ⏳ Awaiting |
| Env var migration script | Validation 4 (backup check) | ⏳ Awaiting |
| Database connection test | Validation 1 (PostgreSQL scope) | ⏳ Awaiting |

**If Gemini reports:**

- ✅ GO → Implement all preparation items
- ⚠️ CONDITIONAL → Implement with modifications
- 🛑 NO-GO → Do not implement, resolve blockers first

---

## 10. NEXT ACTIONS (Post-Validation)

**Once Gemini reports GO and user approves:**

1. **Implement version endpoint** (5 min)

   ```bash
   # Add code to api/index.py
   git add api/index.py
   git commit -m "feat: Add /__version endpoint for deployment verification"
   ```

2. **Wait for user to create service** (dashboard action)
   - User creates service via Render dashboard
   - User confirms service name and URL
   - User confirms GitHub repo connected

3. **Migrate environment variables** (10 min)
   - Run migration script (Section 3)
   - Verify all variables present

4. **Deploy to new service** (10 min)

   ```bash
   render up --detach --service $NEW_SERVICE
   render logs --service $NEW_SERVICE
   ```

5. **Update frontend** (10 min)
   - Update 3 lines in mosaic_ui/index.html
   - Deploy to Netlify
   - Test end-to-end

6. **Verify success** (5 min)
   - Run success criteria checklist (Section 8)
   - Confirm all checks pass

7. **Decommission legacy** (15 min)
   - Archive old service settings
   - Delete obsolete projects
   - Clean up git remotes

**Total: ~60 minutes execution after approval**

---

**END OF PREPARATION DOCUMENT**

**Status:** READY - Awaiting Gemini validation + user approval
**Next Blocker:** Gemini validation report
