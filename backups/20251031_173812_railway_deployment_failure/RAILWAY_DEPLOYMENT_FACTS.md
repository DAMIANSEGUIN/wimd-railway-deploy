# Render Deployment - Known Facts

**Created:** 2025-10-31
**Purpose:** Single source of truth for Render deployment configuration
**DO NOT FORGET THESE FACTS**

---

## Critical Information

### Render Configuration

**Source Repository:** `DAMIANSEGUIN/what-is-my-delta-site`

- User shared this 3 times (2025-10-31)
- This is the repository Render actually deploys from
- NOT the same as our working directory (`wimd-render-deploy`)

**Working Directory:** `/Users/damianseguin/WIMD-Deploy-Project/`

- This is `DAMIANSEGUIN/wimd-render-deploy` repository
- We push to `render-origin` remote which points to `what-is-my-delta-site`

**Git Remotes:**

```
origin         → https://github.com/DAMIANSEGUIN/wimd-render-deploy.git
render-origin → https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git
```

**When we push to Render:**

```bash
git push render-origin main
```

This pushes to `DAMIANSEGUIN/what-is-my-delta-site`, which Render deploys.

---

## Current Deployment Status

**Last Known State:** FAILING
**Error:** `pip: command not found`
**Failed Attempts:** 13+ over 5 days
**Recent Fixes Attempted:**

1. Added `nixpacks.toml` with python311
2. Added `python311Packages.pip` to nixpacks.toml
3. Changed to `python -m pip` commands

**All failed** - Still getting pip not found

---

## NARs Diagnosis (2025-10-31 ~16:25)

**Root Cause Identified:**

- Render likely building from wrong directory
- OR buildpack caching issue
- Repository structure may be confusing auto-detection

**NARs Recommendation:**

1. Check Render Root Directory setting (may be pointing to `mosaic_ui/` instead of root)
2. Remove `nixpacks.toml` and let Render auto-detect from `requirements.txt`
3. Verify `requirements.txt` exists in Render repository root

**STATUS:** Recommendation NOT YET FOLLOWED

- Claude Code attempted 3 more nixpacks.toml fixes instead
- User called this out multiple times

---

## Next Action (Following NARs)

**DO THIS:**

1. Verify Render dashboard → Settings → Source → Root Directory
2. If set to subdirectory → Change to empty or `.`
3. Remove nixpacks.toml: `git rm nixpacks.toml`
4. Let Render auto-detect Python from requirements.txt
5. Push and monitor

**DO NOT:**

- ❌ Modify nixpacks.toml again
- ❌ Try more buildpack configurations
- ❌ Guess at solutions

---

## Repository Structure

**In `what-is-my-delta-site` repository:**

```
/
├── api/               # Backend Python code
├── requirements.txt   # Python dependencies (ROOT)
├── render.toml       # Render config (ROOT)
├── nixpacks.toml      # Currently causing issues (ROOT)
├── mosaic_ui/         # Frontend (Netlify deploys this)
└── frontend/          # Deprecated frontend directory
```

**Render SHOULD build from:** Repository root (to find `requirements.txt`)
**Render MIGHT be building from:** `mosaic_ui/` (would explain errors)

---

## Deployment Endpoints

**Backend (Render):**

- URL: `https://what-is-my-delta-site-production.up.render.app`
- Health: `https://what-is-my-delta-site-production.up.render.app/health`
- Currently: DOWN (service unavailable)

**Frontend (Netlify):**

- URL: `https://whatismydelta.com`
- Currently: UP (serving old `mosaic_ui/` code)

---

## Key Facts to Remember

1. **Source repository:** `DAMIANSEGUIN/what-is-my-delta-site` (Render deploys this)
2. **NARs provided diagnosis** - follow their guidance, don't improvise
3. **Check Render Root Directory setting** - likely the root cause
4. **Stop modifying nixpacks.toml** - it's not helping

---

**Last Updated:** 2025-10-31
**Next Update:** After following NARs recommendation
