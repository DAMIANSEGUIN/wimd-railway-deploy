# Railway Auto-Deploy Diagnostic Checklist

**Issue:** GitHub → Railway auto-deploy trigger not pulling latest code
**Status:** OPEN (Blocker #4 from TEAM_PLAYBOOK.md line 70)
**Last Updated:** 2025-12-04
**Evidence:** Commit `be8b21c` pushed to GitHub but not deployed to Railway

---

## Current Situation

**What's Working:**
- ✅ Local scripts push to `origin/main` correctly (`scripts/deploy.sh` → `scripts/push.sh`)
- ✅ Railway **restarts** when push occurs (webhook triggers container restart)
- ✅ Manual `railway up` deployment works (workaround confirmed)

**What's Broken:**
- ❌ Railway restarts but serves **OLD code** (doesn't pull from GitHub)
- ❌ New endpoints missing (e.g., `/api/ps101/extract-context` returns 404)

**Evidence:**
```bash
# Pushed at 15:45 UTC
git log origin/main --oneline -1
# Output: be8b21c chore: Ignore session_backups directory

# Railway restarted at 15:43 UTC
curl https://what-is-my-delta-site-production.up.railway.app/health | jq '.timestamp'
# Output: "2025-12-04T15:43:02.321480Z"

# But deployed code is OLD
curl https://what-is-my-delta-site-production.up.railway.app/openapi.json | jq '.paths | keys[]' | grep ps101
# Output: "/wimd/start-ps101" (old endpoint only, not new /api/ps101/extract-context)
```

---

## Diagnostic Steps (User Must Perform)

### Step 1: Verify Railway Deployment Source

**Terminal Command (Run First):**
```bash
# Get expected commit hash from GitHub
git log origin/main --oneline -1
# Output: be8b21c chore: Ignore session_backups directory
```

**Railway Dashboard Navigation:**
1. Go to: https://railway.app/dashboard
2. Click project: **"wimd-career-coaching"**
3. Click service: **"what-is-my-delta-site"**
4. Click tab: **"Deployments"** (left sidebar)
5. Click: **Most recent deployment** (top of list)

**What to Check:**
Look for a section labeled **"Source"** or **"Deployment Source"** showing:
- **Source type:** Should say "GitHub" (not "CLI" or "Manual")
- **Repository:** Should be `DAMIANSEGUIN/wimd-railway-deploy`
- **Branch:** Should be `main`
- **Commit hash:** Should match `be8b21c` or newer (from terminal command above)

**Expected:** Commit hash **MATCHES** `be8b21c` or newer
**If mismatch:** Integration is broken (Railway not pulling from GitHub)

**Screenshot needed:** Deployment details showing source + commit hash

---

### Step 2: Verify GitHub Integration Settings

**Railway Dashboard Navigation:**
1. Go to: https://railway.app/dashboard
2. Click project: **"wimd-career-coaching"**
3. Click tab: **"Settings"** (left sidebar)
4. Scroll down to section: **"Integrations"**

**What to Check:**
1. **Is "GitHub" listed?** Should see GitHub logo with status
2. **Status:** Should show "Connected" with green checkmark
3. Click button: **"Configure"** or **"Manage"** next to GitHub integration

**Inside GitHub Integration Settings:**
- **Repository access:** Look for `DAMIANSEGUIN/wimd-railway-deploy` in authorized repos list
- **Auto Deploy:** Toggle should be **ON** (blue/enabled)
- **Branch filter:** Should show `main` (or "All branches" if no filter set)
- **Service connected:** Should show `what-is-my-delta-site`

**Expected:**
- ✅ GitHub shows "Connected"
- ✅ Auto-deploy toggle is ON
- ✅ Repository `DAMIANSEGUIN/wimd-railway-deploy` is authorized
- ✅ Watching `main` branch

**If not connected:** Need to re-authorize GitHub app (see Fix 1)

**Screenshot needed:** Integration settings page showing GitHub connection status

---

### Step 3: Verify GitHub Webhook Configuration

**GitHub Navigation:**
1. Go to: https://github.com/DAMIANSEGUIN/wimd-railway-deploy
2. Click tab: **"Settings"** (top right of repository)
3. Click: **"Webhooks"** (left sidebar under "Code and automation")

**What to Check:**
Look for Railway webhook in the list (URL contains `railway.app` or `railway.com`)

**Click on the Railway webhook to see details:**
- **Payload URL:** Should be active Railway endpoint (contains `railway.app`)
- **Content type:** Should be `application/json`
- **Events:** Should include "Pushes" or "Just the push event"
- **Active:** Green checkmark (webhook is active)

**Click tab: "Recent Deliveries"** (at top of webhook details page)

Find the most recent delivery (timestamp around 15:45 UTC when you pushed `be8b21c`):
- **Response code:** Should be `200` or `201` (success)
- **If 4xx or 5xx:** Webhook delivery failing

**Expected:**
- ✅ Webhook exists and is active
- ✅ Recent deliveries show `200` or `201` response codes
- ✅ Delivery timestamp matches your push time

**If 4xx/5xx:** Webhook endpoint broken or Railway not accepting payloads (see Fix 2)

**Screenshot needed:** Recent deliveries showing response codes + timestamps

---

### Step 4: Test with Noop Commit

**Purpose:** Trigger webhook and observe behavior in real-time

**Commands:**
```bash
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

# Create empty commit (no code changes)
git commit --allow-empty -m "test: Trigger Railway webhook (diagnostic)"

# Push to origin/main
git push origin main

# Wait 2 minutes, then check Railway deployment
```

**Observe:**
1. **GitHub Webhooks → Recent Deliveries:** New webhook delivery appears within 5 seconds
2. **Railway Dashboard → Deployments:** New deployment appears within 1 minute
3. **Railway Logs:** Watch for build/deploy activity

**Expected Behavior:**
- Webhook delivery: `200 OK`
- New deployment appears in Railway
- Deployment pulls latest commit (the empty test commit)

**If webhook delivery succeeds BUT Railway doesn't deploy:**
- Railway is receiving webhook but ignoring it
- Possible causes:
  - Branch filter misconfigured (not watching `main`)
  - Auto-deploy disabled
  - Railway bug (need support ticket)

**If webhook delivery fails (4xx/5xx):**
- GitHub can't reach Railway webhook endpoint
- Possible causes:
  - Webhook URL outdated
  - Railway service down
  - OAuth token expired

---

## Diagnostic Results Template

**Copy this and fill in after completing steps above:**

```markdown
## Railway Auto-Deploy Diagnostic Results
**Date:** 2025-12-04
**Performed by:** [Your name]

### Step 1: Deployment Source
- Source type: [GitHub/Manual/Other]
- Repository: [name]
- Branch: [name]
- Latest deployment commit: [hash]
- Expected commit (from GitHub): be8b21c
- **Match:** [YES/NO]

### Step 2: GitHub Integration
- Integration status: [Connected/Not Connected]
- Auto-deploy enabled: [YES/NO]
- Repository authorized: [YES/NO]
- Branch filter: [value]

### Step 3: GitHub Webhook
- Webhook exists: [YES/NO]
- Webhook active: [YES/NO]
- Recent delivery response codes: [200/4xx/5xx]
- Latest delivery timestamp: [time]
- Latest push timestamp: [time]
- **Delivery occurred:** [YES/NO]

### Step 4: Noop Commit Test
- Webhook delivery: [SUCCESS/FAILED] (response code: [code])
- Railway deployment triggered: [YES/NO]
- Deployment commit matches: [YES/NO]

### Conclusion
[Based on results above, write 1-2 sentences about what's broken]
```

---

## Common Fixes

### Fix 1: Re-authorize GitHub Integration

**If:** Integration shows "Not Connected" or webhook returns `401/403`

**Steps:**
1. Railway Dashboard → Settings → Integrations
2. Click "Connect GitHub" or "Reconnect"
3. Authorize Railway app in GitHub OAuth flow
4. Select repository: `DAMIANSEGUIN/wimd-railway-deploy`
5. Confirm auto-deploy is enabled
6. Test with noop commit (Step 4)

---

### Fix 2: Recreate Webhook

**If:** Webhook returns `404` or doesn't exist

**Steps:**
1. GitHub → Repository → Settings → Webhooks
2. Delete existing Railway webhook (if any)
3. Railway Dashboard → Settings → Integrations → Disconnect GitHub
4. Railway Dashboard → Settings → Integrations → Connect GitHub
5. Railway will automatically create new webhook
6. Test with noop commit (Step 4)

---

### Fix 3: Manual Deployment Workaround (Temporary)

**If:** Above fixes don't work immediately and you need to deploy

**Command:**
```bash
# From project root
railway up --detach

# Wait 2-3 minutes, then verify
curl https://what-is-my-delta-site-production.up.railway.app/openapi.json | jq '.paths | keys[]' | grep ps101
# Should now show: "/api/ps101/extract-context"
```

**Note:** This is a **workaround**, not a fix. Auto-deploy should still be fixed.

---

### Fix 4: Railway Support Ticket

**If:** All diagnostics pass (webhook delivers, integration connected) but Railway still doesn't deploy

**This indicates a Railway platform bug.**

**Template:**
```
Subject: GitHub auto-deploy not pulling latest code despite successful webhooks

Environment:
- Project: wimd-career-coaching
- Service: what-is-my-delta-site
- Repository: DAMIANSEGUIN/wimd-railway-deploy
- Branch: main

Issue:
GitHub webhook deliveries show 200 OK responses, but Railway deployments
don't pull the latest code from GitHub. The service restarts but serves
old code.

Evidence:
- Latest GitHub commit: be8b21c (pushed 2025-12-04 15:45 UTC)
- Latest Railway deployment: Shows old commit [hash from Step 1]
- Webhook delivery: 200 OK (screenshot attached)
- Manual `railway up` deployment works correctly

Steps taken:
- Re-authorized GitHub integration
- Verified auto-deploy enabled
- Tested with empty commit (webhook delivered, no deployment)

Request: Please investigate why Railway is not pulling latest code from
GitHub repository despite receiving webhook events.
```

---

## Next Actions

**For User:**
1. Complete Steps 1-4 above
2. Fill in Diagnostic Results Template
3. Share results with team (Codex, Gemini, Claude Code)
4. Apply appropriate fix based on results

**For Team:**
- If webhook failing → Re-authorize integration (Fix 1 or 2)
- If webhook succeeds but no deploy → Railway support ticket (Fix 4)
- In parallel → Use manual deployment workaround (Fix 3)

---

## Related Documents

- `TEAM_PLAYBOOK.md` line 70 - Blocker #4 documentation
- `RECURRING_BLOCKERS.md` #1A - Railway auto-deploy pattern
- `DEPLOYMENT_TRUTH.md` - Canonical deployment documentation
- `scripts/deploy.sh` - Deployment wrapper (already correct)

---

**Status:** Awaiting user diagnostic results

**Last Updated:** 2025-12-04 by Claude Code
