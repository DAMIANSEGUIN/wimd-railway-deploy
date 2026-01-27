# CRITICAL: Git Remote Rename Required

## Issue
Git remote named `render-origin` is **misleading** and causes confusion.

**Current state**:
```bash
render-origin → https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git
```

**Actual deployment platform**: **Render** (NOT Render)

---

## Impact

### Confusion Points
1. **Developer confusion**: Name implies Render deployment
2. **Documentation mismatch**: Code/docs reference Render, but backend is on Render
3. **Maintenance risk**: Future devs may push to wrong remote or misunderstand architecture
4. **Pre-push hook logic**: Hook refers to "render-origin" as production

### Affected Files
- `.git/hooks/pre-push` (references "render-origin")
- `netlify.toml` (redirects to Render URLs, should be Render)
- Session documentation (now corrected)

---

## Required Action

### Step 1: Rename Git Remote
```bash
# From project root
cd /Users/damianseguin/WIMD-Deploy-Project

# Rename the remote
git remote rename render-origin render-origin

# Verify
git remote -v
# Should show:
# render-origin    https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git (fetch)
# render-origin    https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git (push)
```

### Step 2: Update Pre-Push Hook
```bash
# Edit .git/hooks/pre-push
# Replace all instances of "render-origin" with "render-origin"

# Line 21: Change
if [[ "$remote" == "render-origin" ]]; then
# To:
if [[ "$remote" == "render-origin" ]]; then

# Line 23: Change
echo "✅ Pushing to PRODUCTION (render-origin)"
# To:
echo "✅ Pushing to PRODUCTION (render-origin)"

# Update help text references
```

### Step 3: Update Backend URLs in netlify.toml
```bash
# Check current Render backend URL
# Then update all redirects in netlify.toml from:
https://what-is-my-delta-site-production.up.render.app
# To your actual Render backend URL, e.g.:
https://your-app-name.onrender.com
```

### Step 4: Update Documentation
Files to update:
- `CLAUDE.md` - Replace Render references with Render
- `docs/README.md` - Update deployment platform info
- `frontend/CLAUDE.md` - Update backend references
- Any other docs referencing Render

---

## Verification Checklist

After renaming:
- [ ] `git remote -v` shows `render-origin` (not `render-origin`)
- [ ] Pre-push hook references `render-origin`
- [ ] `netlify.toml` redirects point to Render URLs
- [ ] Test push: `git push render-origin main`
- [ ] Verify Netlify deployment triggered
- [ ] Test backend API connectivity through redirects
- [ ] Update all documentation references

---

## One-Line Fix Script

```bash
# Quick rename (run from repo root)
git remote rename render-origin render-origin && \
sed -i '' 's/render-origin/render-origin/g' .git/hooks/pre-push && \
echo "✅ Renamed remote and updated pre-push hook. Update netlify.toml manually."
```

---

## Why This Matters

**Without this fix**:
- Developers will be confused about deployment platform
- Pre-push hook messaging is misleading
- Backend URL redirects may break if Render URLs become invalid
- Session handoffs will perpetuate incorrect assumptions

**With this fix**:
- Clear, accurate naming matches actual infrastructure
- Pre-push hook gives correct deployment platform info
- Documentation aligns with reality
- Future maintenance is easier

---

**Priority**: HIGH
**Effort**: 5 minutes
**Impact**: Prevents ongoing confusion and potential deployment errors

**Inject this into**:
- Next session start checklist
- Pre-deployment verification
- Onboarding documentation for new developers

**Created**: 2026-01-23 (Option A session)
**Status**: PENDING ACTION
