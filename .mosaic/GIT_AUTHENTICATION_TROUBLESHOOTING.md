# Git Authentication Troubleshooting

**Created:** 2026-01-05
**Last Issue:** Git push authentication failure

---

## CORRECT GIT PUSH CREDENTIALS

When `git push origin main` prompts for credentials:

```bash
Username for 'https://github.com': DAMIANSEGUIN
Password for 'https://DAMIANSEGUIN@github.com': <GitHub Personal Access Token>
```

**CRITICAL:**
- **Username:** Your GitHub username (`DAMIANSEGUIN`)
- **Password:** Your GitHub Personal Access Token (starts with `ghp_...`)
- **NOT:** Your macOS admin password
- **NOT:** Your GitHub login password

---

## GitHub Personal Access Token Setup

**Location:** https://github.com/settings/tokens

**Required Scopes:**
- ✅ `repo` (full control of private repositories)
- ✅ `workflow` (update GitHub Actions workflows)

**Token Type:** Classic (not Fine-grained)

**Steps:**
1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token" → "Generate new token (classic)"
3. Note: "Git operations for wimd-railway-deploy"
4. Expiration: 90 days (or your preference)
5. Check scopes: `repo` + `workflow`
6. Click "Generate token"
7. **Copy the token immediately** (you can't see it again)
8. **Never paste it in chat/logs** (security risk)

---

## Common Authentication Issues

### Issue 1: Token Embedded in URL
**Symptom:** Prompt shows `Password for 'https://ghp_XXX@github.com'`

**Cause:** Token got embedded in git remote URL

**Fix:**
```bash
git remote set-url origin https://github.com/DAMIANSEGUIN/wimd-railway-deploy.git
git remote -v  # Verify URL is clean
```

### Issue 2: Using Wrong Password
**Symptom:** "Invalid username or token"

**Cause:** Entered macOS password or GitHub login password instead of token

**Fix:** Use your Personal Access Token (not any other password)

### Issue 3: Cached Invalid Credentials
**Symptom:** Git never prompts, but push fails with "authentication failed"

**Cause:** Old/invalid token cached in credential store

**Fix:**
```bash
# Clear macOS keychain
git credential-osxkeychain erase << EOF
protocol=https
host=github.com

EOF

# Clear credential file
rm -f ~/.git-credentials

# Next push will prompt for new credentials
git push origin main
```

### Issue 4: Token Lacks Workflow Scope
**Symptom:** "refusing to allow a Personal Access Token to create or update workflow"

**Cause:** Token created without `workflow` scope checked

**Fix:**
1. Delete the token on GitHub
2. Create new token with BOTH `repo` + `workflow` scopes
3. Clear cached credentials (see Issue 3)
4. Push again with new token

### Issue 5: Token Exposed in Chat/Logs
**Symptom:** You accidentally pasted your token in chat

**Fix (IMMEDIATE):**
1. Go to GitHub → Settings → Tokens
2. Find and DELETE the exposed token
3. Create NEW token (same scopes)
4. Use new token for push
5. Never share tokens (they grant full repo access)

---

## Verifying Current Setup

```bash
# Check remote URLs (should NOT contain tokens)
git remote -v

# Should show:
# origin  https://github.com/DAMIANSEGUIN/wimd-railway-deploy.git (fetch)
# origin  https://github.com/DAMIANSEGUIN/wimd-railway-deploy.git (push)

# Check credential helpers
git config --list | grep credential

# Common values:
# credential.helper=osxkeychain  (macOS default)
# credential.helper=store        (saves to ~/.git-credentials)
```

---

## Push Workflow (Step-by-Step)

**From Terminal (not Claude Code):**

```bash
# 1. Navigate to project
cd <your-project-directory>

# 2. Verify you're on main branch
git branch --show-current

# 3. Check what will be pushed
git log origin/main..main --oneline

# 4. Push to GitHub
git push origin main

# 5. When prompted:
Username for 'https://github.com': DAMIANSEGUIN
Password for 'https://DAMIANSEGUIN@github.com': <paste your token>

# 6. Git will cache the credentials for future pushes
```

---

## Why Terminal Instead of Claude Code?

**Claude Code cannot handle interactive credential prompts.**

Git needs to:
1. Display prompt to terminal
2. Wait for user input
3. Capture sensitive input (hidden)

Claude Code's bash tool:
- Executes commands non-interactively
- Cannot display prompts to user
- Cannot capture interactive input

**Solution:** Always run `git push` from your own Terminal when credentials are needed.

---

## Repository Remote URLs

**Current setup:**
- `origin`: https://github.com/DAMIANSEGUIN/wimd-railway-deploy.git (main repo, triggers Railway)
- `railway-origin`: https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git (legacy)

**Which to use:**
- Push to `origin` (wimd-railway-deploy) - Railway watches this repo
- `railway-origin` is no longer actively used

---

## Emergency: "I'm Completely Locked Out"

**If all authentication fails:**

```bash
# Option 1: Use SSH instead of HTTPS
# (Requires SSH key setup on GitHub)
git remote set-url origin git@github.com:DAMIANSEGUIN/wimd-railway-deploy.git
git push origin main

# Option 2: Push from GitHub Desktop
# (GUI handles authentication)
# Download: https://desktop.github.com

# Option 3: Manual upload
# 1. Create new branch on GitHub website
# 2. Upload changed files via web interface
# 3. Create Pull Request
# 4. Merge via web interface
```

---

**END OF GIT AUTHENTICATION TROUBLESHOOTING**

**For git push issues, always reference this document first.**
