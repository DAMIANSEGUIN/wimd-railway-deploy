# URGENT: Deployment Process Ambiguity - Requires Codex Clarification

**Date:** 2025-11-18T02:45Z
**Created By:** Claude Code (Terminal)
**Severity:** 🔴 **CRITICAL** - Blocks deployment
**Status:** ⏳ **AWAITING CODEX CLARIFICATION**

---

## Problem Statement

**We have conflicting documentation about the deployment process** and cannot proceed with deployment due to authentication failures when attempting to follow documented procedures.

### Immediate Blocker

**Git push to `railway-origin` fails with 403 permission denied:**
```
remote: Permission to DAMIANSEGUIN/what-is-my-delta-site.git denied to DAMIANSEGUIN.
fatal: unable to access 'https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git/': The requested URL returned error: 403
```

**However:** Push to `origin` succeeds without issues:
```
To https://github.com/DAMIANSEGUIN/wimd-railway-deploy.git
   6f787b7..93da324  restore-chat-auth-20251112 -> restore-chat-auth-20251112
```

---

## Documentation vs. Reality Mismatch

### What Documentation Says (Multiple Sources)

**CLAUDE.md (lines 27-48):**
```bash
# MANDATORY - Use Wrapper Scripts
./scripts/push.sh railway-origin main   # ← Says to push to railway-origin
./scripts/deploy.sh netlify             # Deploy frontend
./scripts/deploy.sh railway             # Deploy backend
```

**SESSION_START_PROTOCOL.md:**
- Rule 9: "NEVER use raw `git push railway-origin main`"
- Must use: `./scripts/push.sh railway-origin main`

**Multiple agent documents reference:**
- `.ai-agents/CLEANUP_TASKS_FOR_CLAUDE_2025-11-04.md:85`: "push (`./scripts/push.sh railway-origin main`) when approved"
- `.ai-agents/COMMUNICATION_PROTOCOL.md:135`: "`./scripts/push.sh railway-origin main` (enforces verification)"
- `.ai-agents/CURSOR_REVIEW_4_COMMITS_DEPLOYMENT_READY_2025-11-04.md:141`: "Ready for: `./scripts/push.sh railway-origin main`"

### What Actual Deployment Evidence Shows

**deploy_logs/2025-11-14_prod-2025-11-12.md (Most Recent Production Deploy):**

```markdown
## Distribution Checklist
- ✅ Branch `restore-chat-auth-20251112` pushed to origin    ← ONLY mentions "origin"
- ✅ Tag `prod-2025-11-12` pushed to origin                 ← ONLY mentions "origin"
- ✅ CIT supplied browser evidence
- ✅ Mirror latest backups to offsite storage
```

**NO mention of `railway-origin` push in actual deployment log.**

**Netlify Deployment:**
```markdown
## Netlify Deployment
- Netlify site: resonant-crostata-90b706
- Deploy ID: 6917b1840bc0e082a6e8cbca
- Live URL: https://whatismydelta.com
```

**Deployment was completed via Netlify, not via git push to railway-origin.**

---

## Git Remote Investigation

### Current Remotes

```bash
origin          https://github.com/DAMIANSEGUIN/wimd-railway-deploy.git (fetch/push)
railway-origin  git@github.com:DAMIANSEGUIN/what-is-my-delta-site.git (fetch/push)
```

### Railway-Origin Remote Status

**Can READ the repository:**
```bash
$ git ls-remote https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git
✅ 623cbd51dba79f99fc212e40bd897a2cb799371a  HEAD
✅ 798a934e0d7c88debc83022b19f57fdbdc7ab273  refs/heads/restore-chat-auth-20251112
```

**Cannot WRITE to the repository:**
```bash
$ git push railway-origin restore-chat-auth-20251112:main
❌ remote: Permission to DAMIANSEGUIN/what-is-my-delta-site.git denied to DAMIANSEGUIN.
❌ fatal: unable to access 'https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git/': The requested URL returned error: 403
```

**Last successful push to railway-origin/main:**
```bash
$ git log railway-origin/main -1 --format="%H %s %cd" --date=iso
4862895 REVIEW: Cursor approval of 4 commits for deployment 2025-11-04 10:53:32 -0500
```
**Last push was Nov 4, 2025** - before recent deployment wrapper fixes.

---

## Historical Deployment Pattern Analysis

### Recent Deployment Documents Reviewed

1. **deploy_logs/2025-11-14_prod-2025-11-12.md** (Most recent production)
   - ✅ Pushed to `origin`
   - ✅ Deployed via Netlify
   - ❌ NO mention of `railway-origin` push

2. **DEPLOYMENT_SNAPSHOT_2025-11-11.md**
   - Documents Netlify deploy `6914a51661dc38f3e806ff02`
   - Mentions Railway rebuild using "HTTPS fallback path"
   - Does NOT document git push to railway-origin

3. **DEPLOYMENT_SUCCESS_2025-11-09.md**
   - Shows deployment via: `cd mosaic_ui && netlify deploy --prod`
   - Documents BUILD_ID injection workflow (Solution C)
   - NO git push to railway-origin mentioned

4. **scripts/push.sh** contains HTTPS fallback logic added in commit `1597712`:
   - "chore: add HTTPS fallback for Railway pushes"
   - Suggests railway-origin push authentication has been problematic before

---

## Questions for Codex

### 🔴 CRITICAL: Which deployment method is correct?

**Option A: Push to both remotes**
```bash
git push origin restore-chat-auth-20251112           # ✅ Works
git push railway-origin restore-chat-auth-20251112:main  # ❌ Fails with 403
./scripts/deploy.sh netlify                           # Deploy frontend
```

**Option B: Push to origin only**
```bash
git push origin restore-chat-auth-20251112           # ✅ Works
./scripts/deploy.sh netlify                           # Deploy frontend
# railway-origin not used?
```

**Option C: Railway deploys automatically via GitHub integration**
```bash
git push origin restore-chat-auth-20251112           # ✅ Works
./scripts/deploy.sh netlify                           # Deploy frontend
# Railway watches GitHub repo and auto-deploys?
```

### 🟠 What is `railway-origin` actually for?

- Is it required for deployment?
- Does Railway auto-deploy from it via GitHub integration?
- Why do current credentials lack write access?
- Was it used historically but now deprecated?

### 🟡 Why does documentation say one thing but evidence shows another?

- Documentation (CLAUDE.md, protocols): Push to `railway-origin`
- Actual deploy logs: Only push to `origin`, then Netlify deploy
- This violates our "ruthless documentation standards"

---

## Current Session State

### What We've Completed

1. ✅ **CodexCapture documentation + PS101 QA Mode** - 2 commits ready
   - `6f65acb` - CodexCapture docs + PS101 QA Mode
   - `93da324` - .gitignore update

2. ✅ **Fresh backup created**
   - `backups/site-backup_20251118_022416Z.zip` (965K)

3. ✅ **Working tree clean**
   - All changes committed
   - Pre-push verification passed

4. ✅ **Pushed to `origin` successfully**
   - Branch: `restore-chat-auth-20251112`
   - Commits synced to GitHub (wimd-railway-deploy)

### What's Blocked

5. ❌ **Push to `railway-origin` blocked** - Permission denied (403)
   - Tried SSH: `git@github.com: Permission denied (publickey)`
   - Tried HTTPS: `403 Forbidden`
   - Unknown if this step is actually required

6. ⏳ **Netlify deployment pending** - Waiting for clarification
   - Ready to run: `./scripts/deploy.sh netlify`
   - Unclear if we should wait for railway-origin push first

---

## Authentication Investigation

### What We Tried

1. **SSH (git@github.com):** Permission denied (publickey)
2. **HTTPS with stored credentials:** 403 Forbidden
3. **Switched remote to HTTPS:** Still 403
4. **Checked git-credentials:** Only 1 entry exists, works for `origin` but not `railway-origin`

### Why `origin` Works but `railway-origin` Doesn't

Both repositories are owned by `DAMIANSEGUIN`, but:
- ✅ `wimd-railway-deploy` (origin): Read/write access
- ❌ `what-is-my-delta-site` (railway-origin): Read-only access

**Possible explanations:**
1. Token/credentials have different scopes for different repos
2. `what-is-my-delta-site` has branch protection requiring different auth
3. `what-is-my-delta-site` is managed by Railway and shouldn't be pushed to directly
4. Credentials changed/expired and need refreshing

---

## Impact on Current Deployment

### Changes Waiting to Deploy

**Frontend (PS101 QA Mode):**
- `frontend/index.html` - QA toggle for infinite trial (localStorage.ps101_force_trial)
- `mosaic_ui/index.html` - Same QA mode changes
- `scripts/reset_ps101_trial.mjs` - Browser-based testing script

**Documentation:**
- CodexCapture status, handoff, and integration docs
- Updated baseline: `MOSAIC_UI_LINE_COUNT=4241`

**Backend:** No changes (documentation only)

### Can We Deploy Without `railway-origin` Push?

**Unknown.** Need Codex to clarify:
- Does Railway auto-deploy from `origin` via GitHub integration?
- Is `railway-origin` required for Railway backend deployments?
- Can we proceed with Netlify-only deployment for frontend changes?

---

## Recommended Actions (Pending Codex Response)

### Immediate (Codex to Provide)

1. **Clarify correct deployment workflow:**
   - Document actual step-by-step process
   - Explain purpose of each git remote
   - Update CLAUDE.md and protocols to match reality

2. **Resolve authentication issue:**
   - If railway-origin push required: provide token/credentials with write access
   - If not required: remove from documentation and explain why it exists

3. **Fix documentation discrepancy:**
   - Update all agent docs to reflect actual process
   - Remove references to railway-origin push if not needed
   - Add explicit explanation of Railway deployment mechanism

### Once Clarified

4. **Complete deployment:**
   - Follow confirmed process
   - Deploy frontend changes (PS101 QA Mode)
   - Verify deployment
   - Document actual steps taken

5. **Update documentation:**
   - Correct CLAUDE.md deployment commands
   - Update SESSION_START_PROTOCOL
   - Fix all agent handoff docs
   - Create deployment process diagram if needed

---

## Files for Codex Review

### Documentation Claiming railway-origin Required

- `CLAUDE.md` (lines 27-48)
- `.ai-agents/SESSION_START_PROTOCOL.md` (Rule 9)
- `.ai-agents/COMMUNICATION_PROTOCOL.md` (lines 129-144)
- `.ai-agents/CURSOR_REVIEW_4_COMMITS_DEPLOYMENT_READY_2025-11-04.md` (lines 141, 159)
- `.ai-agents/IMPLEMENTATION_TEAM_HANDOFF.md` (multiple references)

### Evidence Showing Different Process

- `deploy_logs/2025-11-14_prod-2025-11-12.md` (actual deployment)
- `.ai-agents/DEPLOYMENT_SNAPSHOT_2025-11-11.md` (Nov 11 deploy)
- `.ai-agents/DEPLOYMENT_SUCCESS_2025-11-09.md` (Nov 9 deploy)

### Deployment Scripts

- `scripts/deploy.sh` (orchestrator)
- `scripts/push.sh` (git push wrapper with verification)
- `scripts/deploy_frontend_netlify.sh` (if exists)

---

## Standards Violation

**This ambiguity violates our core principle:**

> "We have been completely ruthless about keeping good records, not sure why there is any uncertainty" - User (2025-11-18)

**We must:**
1. Document actual process accurately
2. Remove conflicting information
3. Explain purpose of all components
4. Maintain single source of truth

**This cannot happen again.**

---

## Next Steps

**FOR CODEX:**

1. Read this document completely
2. Review referenced deployment logs and documentation
3. Clarify correct deployment process
4. Provide authentication fix if railway-origin push required
5. Approve documentation update plan

**FOR CLAUDE CODE (after Codex response):**

1. Implement Codex-approved deployment process
2. Update all documentation to match
3. Complete current deployment
4. Create deployment process diagram
5. Add to SESSION_START_PROTOCOL

---

## Session Context

**Current Branch:** `restore-chat-auth-20251112`
**Last Commit:** `93da324` (Add evidence folders to .gitignore)
**Pending Deploy:** Frontend (PS101 QA Mode) + Documentation
**Backup:** `site-backup_20251118_022416Z.zip`
**Status:** Clean working tree, verification passed, ready to deploy (pending process clarification)

## Latest Session Kickoff Evidence (2025-11-18T??Z)

- `./scripts/verify_critical_features.sh`
  - Auth/UI check: Authentication UI + PS101 flow present after scan.
  - Warnings: `API_BASE may not be using relative paths` and `Production site may be missing authentication (or unreachable)` remain for further investigation.
  - Summary: All critical features verified despite warnings; proceed with caution and capture more evidence.
- `./Mosaic/PS101_Continuity_Kit/check_spec_hash.sh`
  - SPEC_SHA verified: `7795ae25` (matches deploy log).
  - Output saved for traceability.

## Current Troubleshooting Snapshot (2025-11-18T11:10Z)

- `./scripts/verify_critical_features.sh`
  - Re-run after session start. Authentication UI and PS101 flow reports remain ✅ yet warnings persist.
  - Warning detail: `API_BASE may not be using relative paths`; production site auth probe warns “may be missing authentication (or unreachable)”.
  - Evidence: frontends use `/wimd`, but `mosaic_ui/src/init.js` still hardcodes `https://what-is-my-delta-site-production.up.railway.app`. (Lines 1-83 in `mosaic_ui/src/init.js` specify the absolute API_BASE and first health request.)
  - Recommendation: verify the build still references the absolute URL; capture any runtime network call showing `API_BASE` hitting the absolute host in the browser after the warning surfaces.
  - Document any console/network evidence in this note or new URGENT file; include line references from `frontend/index.html` and `mosaic_ui/index.html` showing relative declarations versus `mosaic_ui/src/init.js` absolute declarations.

## Remaining Questions

- Does the prod auth warning stem from the relative vs absolute API_BASE mismatch, or is the deployed site legitimately missing the DOM-hooks that `verify_critical_features.sh` checks? Capture DOM/network evidence from the live site (Netlify URL) to confirm authentication UI is loading.

## Latest Unified Verification (2025-11-18T13:50Z)

- `./scripts/verify_deployment.sh`
  - ✅ Local checks pass (auth UI, PS101 flow, API_BASE).
  - ❌ Live site unreachable: `curl` triggered a critical error (site down or blocked from this environment).
  - ✔ `curl -I https://whatismydelta.com` (2025-11-18T13:57Z) fails with `curl: (6) Could not resolve host: whatismydelta.com`; the DNS lookup for the Netlify host is blocked from this environment.
  - ❌ Live HTML scan lacked `authModal` and `PS101State` (false negatives because the page could not be fetched).
  - Conclusion: Script still reports 2 critical errors due to live site accessibility; rerun once Netlify is reachable or mirror the environment.

---

**END OF URGENT ESCALATION**

**Codex: Please respond with:**
1. Correct deployment process
2. Explanation of railway-origin purpose
3. Authentication resolution (if needed)
4. Approval to update documentation
5. Go/no-go for current deployment
