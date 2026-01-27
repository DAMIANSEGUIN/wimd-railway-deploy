# Render Auto-Deploy Diagnostic Checklist

**Issue:** GitHub → Render auto-deploy trigger not pulling latest code
**Status:** OPEN (Blocker #4 from TEAM_PLAYBOOK.md line 70)
**Last Updated:** 2025-12-04
**Evidence:** Commit `be8b21c` pushed to GitHub but not deployed to Render

---

## Current Situation

**What's Working:**

- ✅ Local scripts push to `origin/main` correctly (`scripts/deploy.sh` → `scripts/push.sh`)
- ✅ Render **restarts** when push occurs (webhook triggers container restart)
- ✅ Manual `render up` deployment works (workaround confirmed)

**What's Broken:**

- ❌ Render restarts but serves **OLD code** (doesn't pull from GitHub)
- ❌ New endpoints missing (e.g., `/api/ps101/extract-context` returns 404)

**Evidence:**

```bash
# Pushed at 15:45 UTC
git log origin/main --oneline -1
# Output: be8b21c chore: Ignore session_backups directory

# Render restarted at 15:43 UTC
curl https://what-is-my-delta-site-production.up.render.app/health | jq '.timestamp'
# Output: "2025-12-04T15:43:02.321480Z"

# But deployed code is OLD
curl https://what-is-my-delta-site-production.up.render.app/openapi.json | jq '.paths | keys[]' | grep ps101
# Output: "/wimd/start-ps101" (old endpoint only, not new /api/ps101/extract-context)
```

---

## Diagnostic Steps (User Must Perform)

### Step 1: Verify Render Deployment Source

**Terminal Command (Run First):**

```bash
# Get expected commit hash from GitHub
git log origin/main --oneline -1
# Output: be8b21c chore: Ignore session_backups directory
```

**Render Dashboard Navigation:**

1. Go to: <https://render.app/dashboard>
2. Click project: **"wimd-career-coaching"**
3. Click service: **"what-is-my-delta-site"**
4. Click tab: **"Deployments"** (left sidebar)
5. Click: **Most recent deployment** (top of list)

**What to Check:**
Look for a section labeled **"Source"** or **"Deployment Source"** showing:

- **Source type:** Should say "GitHub" (not "CLI" or "Manual")
- **Repository:** Should be `DAMIANSEGUIN/wimd-render-deploy`
- **Branch:** Should be `main`
- **Commit hash:** Should match `be8b21c` or newer (from terminal command above)

**Expected:** Commit hash **MATCHES** `be8b21c` or newer
**If mismatch:** Integration is broken (Render not pulling from GitHub)

**Screenshot needed:** Deployment details showing source + commit hash

---

### Step 2: Verify GitHub Integration Settings

**Render Dashboard Navigation:**

1. Go to: <https://render.app/dashboard>
2. Click project: **"wimd-career-coaching"**
3. Click tab: **"Settings"** (left sidebar)
4. Scroll down to section: **"Integrations"**

**What to Check:**

1. **Is "GitHub" listed?** Should see GitHub logo with status
2. **Status:** Should show "Connected" with green checkmark
3. Click button: **"Configure"** or **"Manage"** next to GitHub integration

**Inside GitHub Integration Settings:**

- **Repository access:** Look for `DAMIANSEGUIN/wimd-render-deploy` in authorized repos list
- **Auto Deploy:** Toggle should be **ON** (blue/enabled)
- **Branch filter:** Should show `main` (or "All branches" if no filter set)
- **Service connected:** Should show `what-is-my-delta-site`

**Expected:**

- ✅ GitHub shows "Connected"
- ✅ Auto-deploy toggle is ON
- ✅ Repository `DAMIANSEGUIN/wimd-render-deploy` is authorized
- ✅ Watching `main` branch

**If not connected:** Need to re-authorize GitHub app (see Fix 1)

**Screenshot needed:** Integration settings page showing GitHub connection status

---

### Step 3: Verify GitHub Webhook Configuration

**GitHub Navigation:**

1. Go to: <https://github.com/DAMIANSEGUIN/wimd-render-deploy>
2. Click tab: **"Settings"** (top right of repository)
3. Click: **"Webhooks"** (left sidebar under "Code and automation")

**What to Check:**
Look for Render webhook in the list (URL contains `render.app` or `render.com`)

**Click on the Render webhook to see details:**

- **Payload URL:** Should be active Render endpoint (contains `render.app`)
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

**If 4xx/5xx:** Webhook endpoint broken or Render not accepting payloads (see Fix 2)

**Screenshot needed:** Recent deliveries showing response codes + timestamps

---

### Step 4: Test with Noop Commit

**Purpose:** Trigger webhook and observe behavior in real-time

**Commands:**

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

# Create empty commit (no code changes)
git commit --allow-empty -m "test: Trigger Render webhook (diagnostic)"

# Push to origin/main
git push origin main

# Wait 2 minutes, then check Render deployment
```

**Observe:**

1. **GitHub Webhooks → Recent Deliveries:** New webhook delivery appears within 5 seconds
2. **Render Dashboard → Deployments:** New deployment appears within 1 minute
3. **Render Logs:** Watch for build/deploy activity

**Expected Behavior:**

- Webhook delivery: `200 OK`
- New deployment appears in Render
- Deployment pulls latest commit (the empty test commit)

**If webhook delivery succeeds BUT Render doesn't deploy:**

- Render is receiving webhook but ignoring it
- Possible causes:
  - Branch filter misconfigured (not watching `main`)
  - Auto-deploy disabled
  - Render bug (need support ticket)

**If webhook delivery fails (4xx/5xx):**

- GitHub can't reach Render webhook endpoint
- Possible causes:
  - Webhook URL outdated
  - Render service down
  - OAuth token expired

---

## Diagnostic Results Template

**Copy this and fill in after completing steps above:**

```markdown
## Render Auto-Deploy Diagnostic Results
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
- Render deployment triggered: [YES/NO]
- Deployment commit matches: [YES/NO]

### Conclusion
[Based on results above, write 1-2 sentences about what's broken]
```

---

## Common Fixes

### Fix 1: Re-authorize GitHub Integration

**If:** Integration shows "Not Connected" or webhook returns `401/403`

**Steps:**

1. Render Dashboard → Settings → Integrations
2. Click "Connect GitHub" or "Reconnect"
3. Authorize Render app in GitHub OAuth flow
4. Select repository: `DAMIANSEGUIN/wimd-render-deploy`
5. Confirm auto-deploy is enabled
6. Test with noop commit (Step 4)

---

### Fix 2: Recreate Webhook

**If:** Webhook returns `404` or doesn't exist

**Steps:**

1. GitHub → Repository → Settings → Webhooks
2. Delete existing Render webhook (if any)
3. Render Dashboard → Settings → Integrations → Disconnect GitHub
4. Render Dashboard → Settings → Integrations → Connect GitHub
5. Render will automatically create new webhook
6. Test with noop commit (Step 4)

---

### Fix 3: Manual Deployment Workaround (Temporary)

**If:** Above fixes don't work immediately and you need to deploy

**Command:**

```bash
# From project root
render up --detach

# Wait 2-3 minutes, then verify
curl https://what-is-my-delta-site-production.up.render.app/openapi.json | jq '.paths | keys[]' | grep ps101
# Should now show: "/api/ps101/extract-context"
```

**Note:** This is a **workaround**, not a fix. Auto-deploy should still be fixed.

---

### Fix 4: Render Support Ticket

**If:** All diagnostics pass (webhook delivers, integration connected) but Render still doesn't deploy

**This indicates a Render platform bug.**

**Template:**

```
Subject: GitHub auto-deploy not pulling latest code despite successful webhooks

Environment:
- Project: wimd-career-coaching
- Service: what-is-my-delta-site
- Repository: DAMIANSEGUIN/wimd-render-deploy
- Branch: main

Issue:
GitHub webhook deliveries show 200 OK responses, but Render deployments
don't pull the latest code from GitHub. The service restarts but serves
old code.

Evidence:
- Latest GitHub commit: be8b21c (pushed 2025-12-04 15:45 UTC)
- Latest Render deployment: Shows old commit [hash from Step 1]
- Webhook delivery: 200 OK (screenshot attached)
- Manual `render up` deployment works correctly

Steps taken:
- Re-authorized GitHub integration
- Verified auto-deploy enabled
- Tested with empty commit (webhook delivered, no deployment)

Request: Please investigate why Render is not pulling latest code from
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
- If webhook succeeds but no deploy → Render support ticket (Fix 4)
- In parallel → Use manual deployment workaround (Fix 3)

---

## Related Documents

- `TEAM_PLAYBOOK.md` line 70 - Blocker #4 documentation
- `RECURRING_BLOCKERS.md` #1A - Render auto-deploy pattern
- `DEPLOYMENT_TRUTH.md` - Canonical deployment documentation
- `scripts/deploy.sh` - Deployment wrapper (already correct)

---

**Status:** Awaiting user diagnostic results

**Last Updated:** 2025-12-04 by Claude Code
