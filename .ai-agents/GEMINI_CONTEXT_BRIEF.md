## Gemini Context Brief

- **Project:** Mosaic web app (Next.js/React, Node). Source root at `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project`.
- **Deploy:** Frontend via Netlify (`resonant-crostata-90b706`), backend via Railway (legacy remote). Verification scripts live in `/scripts`; key logs under `deploy_logs/`.
- **Current focus:** `API_BASE` must remain relative (`/wimd`), but `./scripts/verify_critical_features.sh` still warns about absolute paths and reportedly missing prod authentication UI elements; these warnings appear after the PS101 QA Mode deploy (`deploy_logs/2025-11-18_ps101-qa-mode.md`).
- **Build info:** `spec sha 7795ae25`, commit `31d099cc21a03d221bfb66381a0b8e4445b04efc`, branch `restore-chat-auth-20251112`.
- **Evidence:** Check `frontend/index.html`, `mosaic_ui/index.html`, `scripts/verify_critical_features.sh`, and `.ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md` for logs/notes before proposing fixes.
