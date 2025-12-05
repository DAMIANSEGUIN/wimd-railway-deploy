# Railway CLI Debug Status

**Created:** 2025-12-04
**Status:** UNRESOLVED - Blocked on deployment
**Severity:** CRITICAL

---

## Current Situation

**Problem:** Railway CLI `railway up --detach` hangs during indexing with "Permission denied (os error 13)"

**Impact:** Cannot deploy to production via CLI - blocking Day 1 security fix testing

---

## What We've Tried

### ✅ Fixed Issues
1. **version.json ownership** - Was owned by root, now fixed
   ```bash
   sudo chown damianseguin:staff ~/.railway/version.json
   ```
   Result: Fixed but deployment still fails

2. **Updated diagnostic script** - Added Railway CLI health checks
   - File: `scripts/diagnose_railway_autodeploy.sh`
   - Now checks: CLI installation, permissions, connectivity

### ❌ Still Broken
1. **Railway CLI hangs** during indexing phase
2. **qemu-system-alpha symlink broken** - Points to non-existent Cellar path
   ```
   /usr/local/bin/qemu-system-alpha -> ../Cellar/qemu/4.1.1/bin/qemu-system-alpha
   ```
   File doesn't exist at target

---

## Diagnostics Run

### Confirmed Working:
- ✅ Git push to origin/main works
- ✅ Railway CLI installed (v4.8.0)
- ✅ Railway CLI can connect (`railway status` works)
- ✅ ~/.railway/ permissions correct (damianseguin:staff)

### Confirmed Broken:
- ❌ Railway auto-deploy (webhook triggers restart but doesn't pull new code)
- ❌ Railway CLI manual deploy (hangs with permission error)
- ❌ New code NOT deployed (commit 16a10df, then 7387a63 noop test)
- ❌ `/api/ps101/extract-context` returns 404 (should exist)

---

## Evidence

### Timeline:
1. **2025-12-04 15:45 UTC** - Pushed commit `be8b21c` to origin/main
2. **2025-12-04 23:10 UTC** - Railway restarted (webhook triggered)
3. **2025-12-04 23:10 UTC** - Production still serving old code (404 on new endpoint)
4. **2025-12-05 00:54 UTC** - Pushed noop commit `7387a63` (diagnostic test)
5. **2025-12-05 00:54 UTC** - Railway restarted again (webhook working)
6. **2025-12-05 00:55 UTC** - Still serving old code (auto-deploy confirmed broken)

### Railway CLI Errors:
```bash
$ railway up --detach
Indexing...
Permission denied (os error 13)

$ sudo railway up --detach
Indexing...
Compressed [====================] 100%
/usr/local/bin/qemu-system-alpha: IO error for operation on /usr/local/bin/qemu-system-alpha: No such file or directory (os error 2)
```

---

## Next Steps for Next Session

### Immediate Actions:
1. **Trace Railway CLI permission error** using macOS diagnostic tools:
   ```bash
   # Option 1: dtruss (requires sudo)
   sudo dtruss -f railway up --detach 2>&1 | grep -E "EACCES|EPERM|Permission"

   # Option 2: fs_usage (requires sudo)
   sudo fs_usage -w -f filesystem railway | head -50
   # Then run `railway up --detach` in another terminal

   # Option 3: opensnoop (requires sudo)
   sudo opensnoop -n railway
   # Then run `railway up --detach` in another terminal
   ```

2. **Find and remove broken symlinks:**
   ```bash
   find . -type l ! -exec test -e {} \; -print
   ```

3. **Deploy via Railway web dashboard** (workaround):
   - https://railway.app/dashboard
   - Click: wimd-career-coaching → what-is-my-delta-site → Deployments
   - Click: "Deploy" button
   - Select: "Deploy latest commit" (should be `7387a63` or newer)

### Investigation Tasks:
1. Check what Railway CLI is trying to index (may be hitting broken symlinks)
2. Verify Railway project settings in dashboard (auto-deploy enabled?)
3. Check GitHub webhook recent deliveries (response codes)
4. Consider reinstalling Railway CLI if filesystem trace doesn't reveal issue

---

## Related Incidents (Logged in mosaic-diag)

```bash
# View all deployment incidents
python3 mosaic-diag/cli.py incidents --category deployment

# Latest incidents:
# cc597a79 - Railway auto-deploy not pulling code (high severity)
# f0051476 - Railway CLI permission error version.json (high severity) - RESOLVED
# 57a0d006 - Railway CLI hangs during indexing (critical severity) - UNRESOLVED
```

---

## Code State

**Last successful commit:** `7387a63` (noop test commit)
**Uncommitted changes:**
- M mosaic-diag/diagnostics/incidents.jsonl (incident logs)
- M scripts/diagnose_railway_autodeploy.sh (added CLI checks)

**Production state:**
- Code version: OLD (pre-be8b21c)
- Last restart: 2025-12-05 00:54:53 UTC
- Missing endpoints: `/api/ps101/extract-context`

---

## Workarounds Available

### Option 1: Railway Web Dashboard (RECOMMENDED)
Manual deployment via web UI - bypasses CLI entirely

### Option 2: Fix Auto-Deploy
Complete diagnostic steps from `RAILWAY_AUTO_DEPLOY_DIAGNOSTIC.md`:
- Check Railway deployment source (commit hash)
- Check GitHub integration settings (auto-deploy enabled?)
- Check GitHub webhook deliveries (response codes)

### Option 3: Fix Railway CLI
Trace permission error with dtruss/fs_usage, fix underlying issue

---

**Status:** Waiting for user to run macOS diagnostic tools (dtruss/fs_usage/opensnoop) or deploy via web dashboard

**Blocker:** Cannot test Day 1 security fixes until code is deployed to production

**Estimated Time Lost:** ~2 hours debugging deployment issues

---

**Last Updated:** 2025-12-04 by Claude Code (session ending)
