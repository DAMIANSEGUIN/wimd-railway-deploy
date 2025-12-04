# Setting Up Railway Auto-Deploy from GitHub

**Goal**: Configure Railway to automatically deploy when you push to `wimd-railway-deploy` repository.

**Current Issue**: Railway is not configured to watch this repository for changes.

---

## Option 1: Railway Dashboard (EASIEST - 2 minutes)

### Step 1: Access Railway Dashboard
1. Go to https://railway.app
2. Log in
3. Select project: **"wimd-career-coaching"**
4. Select service: **"what-is-my-delta-site"**

### Step 2: Check Current Source Configuration
1. Click on the service card
2. Go to **"Settings"** tab (in left sidebar)
3. Scroll to **"Source"** section
4. Check what's currently configured:
   - **If it shows a GitHub repo**: Note which one
   - **If it says "No source"**: Need to connect
   - **If it shows the wrong repo**: Need to update

### Step 3: Configure GitHub Integration

**If no source is configured:**
1. In "Source" section, click **"Connect GitHub"**
2. Authorize Railway to access your GitHub
3. Select repository: **"DAMIANSEGUIN/wimd-railway-deploy"**
4. Select branch: **"main"**
5. Click **"Connect"**

**If wrong source is configured:**
1. In "Source" section, click **"Disconnect"**
2. Wait for confirmation
3. Click **"Connect GitHub"**
4. Select repository: **"DAMIANSEGUIN/wimd-railway-deploy"**
5. Select branch: **"main"**
6. Click **"Connect"**

### Step 4: Enable Auto-Deploy
1. Still in "Settings" → "Source"
2. Look for **"Auto Deploy"** toggle
3. Make sure it's **ENABLED** (should be on by default)
4. If there's a branch selection, confirm it's **"main"**

### Step 5: Trigger Initial Deployment
1. Go back to "Deployments" tab
2. Click **"Deploy"** or **"New Deployment"** button
3. OR just push any commit to trigger it

### Step 6: Verify
1. Make a test change (or use existing commit 799046f)
2. Push to `origin main`
3. Watch Railway dashboard - should see new deployment start automatically
4. Check logs for successful build

---

## Option 2: Railway CLI (If You Have GitHub Token)

```bash
# Link Railway to the correct GitHub repo
railway link

# This will prompt you to:
# 1. Select project: wimd-career-coaching
# 2. Select service: what-is-my-delta-site

# Then configure source
railway service --source github \
  --repo DAMIANSEGUIN/wimd-railway-deploy \
  --branch main
```

**Note**: This requires Railway CLI to be authenticated and connected.

---

## Option 3: Webhook Setup (Manual)

If GitHub integration doesn't work, set up a webhook:

### In GitHub Repository Settings:
1. Go to: https://github.com/DAMIANSEGUIN/wimd-railway-deploy/settings/hooks
2. Click **"Add webhook"**
3. Payload URL: Get from Railway dashboard → Settings → Webhooks
4. Content type: `application/json`
5. Trigger: "Just the push event"
6. Active: ✓
7. Click **"Add webhook"**

---

## Verification After Setup

### Test Auto-Deploy:
```bash
# Make a trivial change
echo "# Test auto-deploy" >> README.md
git add README.md
git commit -m "Test: Verify Railway auto-deploy"
git push origin main

# Watch Railway dashboard
# Should see new deployment start within 30 seconds
```

### Check Logs:
```bash
# Via Railway dashboard
# Go to Deployments → Latest → View Logs

# Via CLI
railway logs --follow
```

---

## Expected Behavior After Setup

**When you push to `origin main`:**
1. GitHub sends webhook to Railway (within seconds)
2. Railway detects new commit
3. Railway starts new deployment automatically
4. Build process runs (install dependencies, etc.)
5. New version deploys (usually 2-5 minutes)
6. Old version remains active until new one is healthy
7. Traffic switches to new deployment

**You'll see in Railway dashboard:**
- New deployment appears in "Deployments" list
- Status changes: Queued → Building → Deploying → Active
- Logs show build and startup process

---

## Troubleshooting

### "Railway can't access my repository"
- **Fix**: Go to GitHub Settings → Applications → Railway → Grant access
- **Or**: Reinstall Railway GitHub app with correct permissions

### "Auto-deploy is enabled but not triggering"
- **Check 1**: Verify webhook exists in GitHub repo settings
- **Check 2**: Check webhook delivery logs (shows if webhook fired)
- **Check 3**: Railway may be rate-limited - wait 5 minutes and try again

### "Deployment fails immediately"
- **Check**: Railway logs for build errors
- **Common**: Missing environment variables (DATABASE_URL, API keys, etc.)
- **Fix**: Go to Railway Settings → Variables → Add missing vars

### "Wrong branch is deploying"
- **Fix**: Railway Settings → Source → Change branch to "main"
- **Verify**: Check which branch is selected in Source configuration

---

## Current Repository Structure

**Repository**: `DAMIANSEGUIN/wimd-railway-deploy`
- **Main branch**: Contains all production code
- **Latest commit**: 799046f (Day 1 blocker fixes)
- **Directory**: `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project`

**What Railway should watch:**
- Repo: `DAMIANSEGUIN/wimd-railway-deploy`
- Branch: `main`
- Path: Root (Railway will look for api/ directory)

---

## After Setup is Complete

1. **Trigger deployment of commit 799046f**:
   ```bash
   # Force push to trigger
   git commit --allow-empty -m "Trigger deployment"
   git push origin main
   ```

2. **Wait 2-5 minutes for deployment**

3. **Run integration tests**:
   ```bash
   # See POST_DEPLOYMENT_TESTING.md for full test suite
   curl https://whatismydelta.com/config | jq '.schemaVersion'
   # Should return: "v2"
   ```

4. **Verify auto-deploy works**:
   ```bash
   # Make a small change
   echo "# Auto-deploy verified" >> DEPLOYMENT_STATUS.md
   git add DEPLOYMENT_STATUS.md
   git commit -m "Verify: Auto-deploy working"
   git push origin main
   # Watch Railway - should auto-deploy
   ```

---

## Recommended Setup (Best Practice)

**For this project:**
- ✅ Enable auto-deploy from `main` branch
- ✅ Set Railway to use `wimd-railway-deploy` repository
- ✅ Keep all API keys in Railway environment variables (never in code)
- ✅ Use Railway's built-in health checks
- ✅ Enable automatic rollback on failed deployments

**Railway Settings to Configure:**
- Auto-deploy: **ON**
- Branch: **main**
- Root directory: **/** (default)
- Build command: Auto-detected from requirements.txt
- Start command: Auto-detected (uvicorn)
- Health check path: **/health**

---

## Next Steps After Setup

1. **Complete the GitHub integration setup** (Steps above)
2. **Trigger deployment** of commit 799046f
3. **Run integration tests** (POST_DEPLOYMENT_TESTING.md)
4. **Verify auto-deploy** works on next push
5. **Update CLAUDE.md** with confirmed deployment process

---

**Need help with any step? Let me know which option you're using and where you're stuck.**
