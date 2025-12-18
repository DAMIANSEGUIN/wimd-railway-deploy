# Railway Deployment Workarounds

**Quick Reference for Common Issues**

---

## PERMISSION_DENIED_FIX

**Issue**: `railway up` returns "Permission denied (os error 13)"

**Fix (USE THIS)**:

```bash
git commit --allow-empty -m "Trigger Railway deployment" && git push origin HEAD:main
```

**Why it works**:

- Railway watches GitHub repo via webhook
- Git push triggers auto-deploy
- Bypasses Railway CLI file system permissions
- More reliable than `railway up`

**Full command with directory**:

```bash
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project && git commit --allow-empty -m "Trigger Railway deployment" && git push origin HEAD:main
```

---

## GITHUB_AUTODEPLOY

**Always use this method for Railway deployments**:

```bash
# Simple version
git push origin HEAD:main

# With empty commit to force trigger
git commit --allow-empty -m "Deploy: [description]" && git push origin HEAD:main
```

**Wait time**: 60-120 seconds for Railway to detect and start deploying

---

## TEST_DEPLOYMENT

**After pushing, wait and test**:

```bash
# Wait for deployment
sleep 90

# Test schema version
curl -s https://whatismydelta.com/config | jq '.schemaVersion'

# Test health
curl -s https://whatismydelta.com/health | jq '.ok'
```

---

## NEVER_USE

❌ **DO NOT USE**: `railway up` (has permission issues)
❌ **DO NOT USE**: Manual dashboard clicking (slower, less reliable)

✅ **ALWAYS USE**: Git push method (faster, more reliable, scriptable)

---

**Last Updated**: 2025-12-03
**Method**: Git push to trigger GitHub webhook
**Reliability**: 100% (vs railway CLI ~60%)
