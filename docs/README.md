# 🚦 WIMD Render Deploy – Restart Protocol

Run this to begin every session:

```zsh
~/restart_wimd.sh
```

The script auto-loads APP_URL from wimd_config.sh (asks once, then saves), runs update_status.sh, logs to DEPLOY_STATUS_NOTE.md, and prints the last 10 lines.

---

# 📝 WIMD Render Deploy – Context Note

> Action on Restart: run ~/restart_wimd.sh (auto-logs status; URL saved in wimd_config.sh)

## Required Env Vars (Render → Environment)

OPENAI_API_KEY=sk-xxx
CLAUDE_API_KEY=sk-ant-xxx
PUBLIC_SITE_ORIGIN=<https://whatismydelta.com>
PUBLIC_API_BASE=<https://mosaic-backend-tpog.onrender.com>
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
# Test Render API directly
curl https://mosaic-backend-tpog.onrender.com/health
curl https://mosaic-backend-tpog.onrender.com/config

# Run verification scripts
./scripts/predeploy_sanity.sh
./scripts/verify_deploy.sh "https://mosaic-backend-tpog.onrender.com"
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

## Render Deployment

**Automatic via GitHub Integration:**
- Render watches the `wimd-render-deploy` repository
- Push to `origin/main` triggers auto-deploy (2-5 minutes)
- Monitor deployment: https://dashboard.render.com

**Manual Deploy (if needed):**
```zsh
# Using Render CLI
render services list
render deploy
```

## Render Variables (Build vs Runtime)

- In the Render service → Environment, ensure each variable is:
  - Added to the service environment
  - Marked as available during build if needed at build time
- Typical vars: `OPENAI_API_KEY`, `CLAUDE_API_KEY`, `PUBLIC_API_BASE`, `PUBLIC_SITE_ORIGIN`, `APP_SCHEMA_VERSION`

If build fails with "secret NAME: not found":
- The variable likely isn't defined for this service/environment
- Add it in the Render dashboard and redeploy

# Force rebuild: 1759167655
