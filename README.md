**Document Metadata:**

- Created: 2024-09-15 by Multiple Contributors
- Last Updated: 2025-12-06 by Gemini
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE - Entry point for all agents

# 🚦 MOSAIC Project - Quick Start

## 🎯 FOR AI AGENTS: MANDATORY SESSION START

**🚨 STOP - Before doing ANYTHING, read this file:**

```bash
cat .ai-agents/AI_AGENT_PROMPT.md
```

**This prompt contains:**
- Required state files to read FIRST (.mosaic/*.json)
- Verification steps you MUST execute
- Protocol acknowledgments required
- Absolute prohibitions (paths, patterns, actions)

**THEN run the session gate:**

```bash
./.mosaic/enforcement/session-gate.sh
```

**Why this matters:**
- Prevents breaking cross-agent coordination
- Ensures you know current state (last commit, user decisions, blockers)
- Enforces relative paths (breaks for other agents if you use absolute)
- Validates critical features are preserved

**If you skip these steps, you WILL break things.**

---

## FAST GUIDE: Which Repo Do I Use?

LOCAL (edit here):
  /Users/damianseguin/AI_Workspace/WIMD-Railway_Deploy_Project

GDRIVE MASTER (authoritative cloud):
  Located in Google Drive under Mosaic/Master

GDRIVE CONSULTING MIRROR (LLM-only):
  Located in Google Drive under Mosaic/Consulting_Mirror

Manual Sync (run anytime):
  /Users/damianseguin/.local/bin/google-drive-sync.sh

Core Rule: Only LOCAL is editable.
All other copies are generated via sync.

---

## 🔄 Restart Protocol (For Humans)

Run this to begin every session:

```zsh
/Users/damianseguin/restart_wimd.sh
```

The script auto-loads APP_URL from wimd_config.sh (asks once, then saves), runs update_status.sh, logs to DEPLOY_STATUS_NOTE.md, and prints the last 10 lines.

---

## 📊 Latest Diagnostics & Protocols (2025-11-02)

### System Status: 🟢 GREEN

- **Feature Completeness:** 92% (11/12 operational)
- **Backend Error Rate:** 0%
- **Critical Features:** 100% working
- **Latest Diagnostic:** `.ai-agents/FINAL_DIAGNOSTIC_20251102.md`

### Essential Documentation

1. **`Mosaic_Governance_Core_v1.md`** - Top-level governance rules (ALL AGENTS)
2. **`TEAM_PLAYBOOK_v2.md`** - Operational contract and behavior rules
3. **`SESSION_START_v2.md`** - Session initialization protocol
4. **`SESSION_END_OPTIONS.md`** - Session termination commands
5. **`CLAUDE.md`** - Main architecture overview and deployment status
6. **`TROUBLESHOOTING_CHECKLIST.md`** - Error prevention workflows
7. **`SELF_DIAGNOSTIC_FRAMEWORK.md`** - Architecture-specific error handling
8. **`.ai-agents/START_HERE.md`** - Quick start guide for AI agents

### Safety Protocols (MANDATORY)

**Before ANY code changes:**

```bash
./scripts/verify_critical_features.sh
```

**After ANY deployment:**

```bash
# 1. Verify features
./scripts/verify_critical_features.sh

# 2. Check backend health
curl https://what-is-my-delta-site-production.up.railway.app/health/comprehensive

# 3. For major changes: Full diagnostic
# See .ai-agents/FINAL_DIAGNOSTIC_20251102.md for template
```

**Why?** Prevents incidents like 2025-11-01 auth removal (commit 890d2bc).

### Contingency System

- **Pre-commit hooks:** Block feature removal (`.git/hooks/pre-commit`)
- **Verification scripts:** Automated checks (`scripts/verify_critical_features.sh`)
- **Handoff protocol:** Agent transition procedures (`.ai-agents/HANDOFF_PROTOCOL.md`)
- **Session start:** Mandatory verification (`.ai-agents/SESSION_START_PROTOCOL.md`)

---

# 📝 WIMD Railway Deploy – Context Note

> Action on Restart: run ~/restart_wimd.sh (auto-logs status; URL saved in wimd_config.sh)

## Required Env Vars (Railway → Variables)

OPENAI_API_KEY=sk-xxx
CLAUDE_API_KEY=sk-ant-xxx
PUBLIC_SITE_ORIGIN=<https://whatismydelta.com>
PUBLIC_API_BASE=<https://what-is-my-delta-site-production.up.railway.app>
DATABASE_URL=
SENTRY_DSN=
APP_SCHEMA_VERSION=v1

## Dependencies (requirements.txt)

- fastapi
- uvicorn
- gunicorn
- httpx
- pydantic
- pydantic-settings
- python-multipart (CRITICAL: Required for file uploads)

## API Endpoints

- `GET /health` — basic health probe
- `GET /config` — returns `{ apiBase, schemaVersion }`
- `GET /prompts/active` — returns `{ active }` (may be null until a CSV is ingested)

## Verify Deploy

```zsh
# Test Railway API directly
curl https://what-is-my-delta-site-production.up.railway.app/health
curl https://what-is-my-delta-site-production.up.railway.app/config

# Run verification scripts
./scripts/predeploy_sanity.sh
./scripts/verify_deploy.sh "$PUBLIC_API_BASE"
```

## Local Development (RECOMMENDED FOR DEBUGGING)

```zsh
# Set environment variables
export OPENAI_API_KEY="your_key_here"
export CLAUDE_API_KEY="your_key_here"
export PUBLIC_SITE_ORIGIN="https://whatismydelta.com"
export APP_SCHEMA_VERSION="v1"

# Install dependencies
pip3 install --user -r requirements.txt

# Start local server
python3 -m uvicorn api.index:app --host 0.0.0.0 --port 8000

# Test locally
curl http://localhost:8000/health
curl http://localhost:8000/config
curl http://localhost:8000/prompts/active
```

## One-Shot Fresh Deploy (New Railway Project)

- Run to create a brand-new Railway project, set variables, and deploy:

  ```zsh
  ./scripts/one_shot_new_deploy.sh
  ```

- Notes:
  - It does not delete your existing Railway project; it creates a new one with a timestamped name.
  - You’ll be prompted for variables based on `.env.example`.
  - After deploy, copy the service URL to `PUBLIC_API_BASE` as needed and re-run `./scripts/verify_deploy.sh`.
  - If you want to remove the old service/project, do so from the Railway dashboard to avoid accidental data loss.

## Railway Variables (_Build vs Runtime)

- In the Railway service → Variables, ensure each variable is:
  - Scoped to the correct environment (e.g., Production)
  - Marked "Available during deploy" so Nixpacks can access it at build time
- Typical vars: `OPENAI_API_KEY`, `CLAUDE_API_KEY`, `PUBLIC_API_BASE`, `PUBLIC_SITE_ORIGIN`, `APP_SCHEMA_VERSION`

If build fails with "secret NAME: not found":

- The variable likely isn’t marked "Available during deploy" or isn’t defined for this service/environment.
- Toggle it on and redeploy.

# Force rebuild: 1759167655

# PostgreSQL connection test

# PostgreSQL connection retry
