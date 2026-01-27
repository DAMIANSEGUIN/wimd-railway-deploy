# Render CLI Debug Status

**Created:** 2025-12-04
**Status:** UNRESOLVED - Blocked on deployment
**Severity:** CRITICAL

---

## Current Situation

**Problem:** Render CLI `render up --detach` hangs during indexing with "Permission denied (os error 13)"

**Impact:** Cannot deploy to production via CLI - blocking Day 1 security fix testing

---

## What We've Tried

### ✅ Fixed Issues

1. **version.json ownership** - Was owned by root, now fixed

   ```bash
   sudo chown damianseguin:staff ~/.render/version.json
   ```

   Result: Fixed but deployment still fails

2. **Updated diagnostic script** - Added Render CLI health checks
   - File: `scripts/diagnose_render_autodeploy.sh`
   - Now checks: CLI installation, permissions, connectivity

### ❌ Still Broken

1. **Render CLI hangs** during indexing phase
2. **qemu-system-alpha symlink broken** - Points to non-existent Cellar path

   ```
   /usr/local/bin/qemu-system-alpha -> ../Cellar/qemu/4.1.1/bin/qemu-system-alpha
   ```

   File doesn't exist at target

---

## Diagnostics Run

### Confirmed Working

- ✅ Git push to origin/main works
- ✅ Render CLI installed (v4.8.0)
- ✅ Render CLI can connect (`render status` works)
- ✅ ~/.render/ permissions correct (damianseguin:staff)

### Confirmed Broken

- ❌ Render auto-deploy (webhook triggers restart but doesn't pull new code)
- ❌ Render CLI manual deploy (hangs with permission error)
- ❌ New code NOT deployed (commit 16a10df, then 7387a63 noop test)
- ❌ `/api/ps101/extract-context` returns 404 (should exist)

---

## Evidence

### Timeline

1. **2025-12-04 15:45 UTC** - Pushed commit `be8b21c` to origin/main
2. **2025-12-04 23:10 UTC** - Render restarted (webhook triggered)
3. **2025-12-04 23:10 UTC** - Production still serving old code (404 on new endpoint)
4. **2025-12-05 00:54 UTC** - Pushed noop commit `7387a63` (diagnostic test)
5. **2025-12-05 00:54 UTC** - Render restarted again (webhook working)
6. **2025-12-05 00:55 UTC** - Still serving old code (auto-deploy confirmed broken)

### Render CLI Errors

```bash
$ render up --detach
Indexing...
Permission denied (os error 13)

$ sudo render up --detach
Indexing...
Compressed [====================] 100%
/usr/local/bin/qemu-system-alpha: IO error for operation on /usr/local/bin/qemu-system-alpha: No such file or directory (os error 2)
```

---

## Next Steps for Next Session

### Immediate Actions

1. **Trace Render CLI permission error** using macOS diagnostic tools:

   ```bash
   # Option 1: dtruss (requires sudo)
   sudo dtruss -f render up --detach 2>&1 | grep -E "EACCES|EPERM|Permission"

   # Option 2: fs_usage (requires sudo)
   sudo fs_usage -w -f filesystem render | head -50
   # Then run `render up --detach` in another terminal

   # Option 3: opensnoop (requires sudo)
   sudo opensnoop -n render
   # Then run `render up --detach` in another terminal
   ```

2. **Find and remove broken symlinks:**

   ```bash
   find . -type l ! -exec test -e {} \; -print
   ```

3. **Deploy via Render web dashboard** (workaround):
   - <https://render.app/dashboard>
   - Click: wimd-career-coaching → what-is-my-delta-site → Deployments
   - Click: "Deploy" button
   - Select: "Deploy latest commit" (should be `7387a63` or newer)

### Investigation Tasks

1. Check what Render CLI is trying to index (may be hitting broken symlinks)
2. Verify Render project settings in dashboard (auto-deploy enabled?)
3. Check GitHub webhook recent deliveries (response codes)
4. Consider reinstalling Render CLI if filesystem trace doesn't reveal issue

---

## Related Incidents (Logged in mosaic-diag)

```bash
# View all deployment incidents
python3 mosaic-diag/cli.py incidents --category deployment

# Latest incidents:
# cc597a79 - Render auto-deploy not pulling code (high severity)
# f0051476 - Render CLI permission error version.json (high severity) - RESOLVED
# 57a0d006 - Render CLI hangs during indexing (critical severity) - UNRESOLVED
```

---

## Code State

**Last successful commit:** `7387a63` (noop test commit)
**Uncommitted changes:**

- M mosaic-diag/diagnostics/incidents.jsonl (incident logs)
- M scripts/diagnose_render_autodeploy.sh (added CLI checks)

**Production state:**

- Code version: OLD (pre-be8b21c)
- Last restart: 2025-12-05 00:54:53 UTC
- Missing endpoints: `/api/ps101/extract-context`

---

## Workarounds Available

### Option 1: Render Web Dashboard (RECOMMENDED)

Manual deployment via web UI - bypasses CLI entirely

### Option 2: Fix Auto-Deploy

Complete diagnostic steps from `RAILWAY_AUTO_DEPLOY_DIAGNOSTIC.md`:

- Check Render deployment source (commit hash)
- Check GitHub integration settings (auto-deploy enabled?)
- Check GitHub webhook deliveries (response codes)

### Option 3: Fix Render CLI

Trace permission error with dtruss/fs_usage, fix underlying issue

---

**Status:** Waiting for user to run macOS diagnostic tools (dtruss/fs_usage/opensnoop) or deploy via web dashboard

**Blocker:** Cannot test Day 1 security fixes until code is deployed to production

**Estimated Time Lost:** ~2 hours debugging deployment issues

---

**Last Updated:** 2025-12-04 by Claude Code (session ending)
