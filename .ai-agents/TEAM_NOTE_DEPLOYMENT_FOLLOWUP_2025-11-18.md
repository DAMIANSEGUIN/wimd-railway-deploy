# Team Note — Deployment Follow-Up & Ownership  
**Date:** 2025-11-18  
**Author:** Codex (GPT-5 CLI)  

## Context
- Deployable commits: `6f65acb` (PS101 QA mode + CodexCapture docs) and `93da324` (.gitignore evidence folders)
- Deployment wrapper now blocked by `railway-origin` push requirement in legacy docs
- `./scripts/verify_critical_features.sh` warns about API_BASE relativity and prod auth reachability
- Latest site backup confirmed: `backups/site-backup_20251118_033032Z.zip`
- Handoff manifest: `.ai-agents/handoff_20251118_033457.json`

## Assigned Actions
1. **Process Clarification – Codex SSE / Docs team**
   - Decide whether `railway-origin` is still part of the official workflow.
   - If deprecated, update `CLAUDE.md`, `.ai-agents/SESSION_START_PROTOCOL.md`, `.ai-agents/COMMUNICATION_PROTOCOL.md`, and any URGENT notes to remove the requirement.
   - If required, provide working credentials/token path or alternate deploy mechanism and document it.

2. **Railway Remote Investigation – Terminal Codex**
   - Run `./scripts/push.sh railway-origin restore-chat-auth-20251112` to capture the exact failure log (already reproducible with HTTP 403) and note timestamps.
   - Inspect `scripts/push.sh` and Railway project settings to verify whether CI relies on that remote.
   - Report whether Railway auto-deploys from `origin`, SSH-only remote, or manual trigger.

3. **API_BASE / Auth Warning – Claude Code**
   - Trace API base configuration in `mosaic_ui/index.html`, `frontend/index.html`, and related env scripts for absolute URLs; ensure production builds use relative `/wimd`.
   - Hit the live site (CodexCapture flow if needed) to confirm authentication elements render; capture console/network evidence if the warning persists.
   - Log findings in `.ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md` (append section) or a new evidence note.

4. **Deployment Evidence & Backup – Netlify Runner**
   - Prepare to run `./scripts/deploy.sh netlify` once steps 1–3 resolve.
   - Before deploy: rerun `./scripts/verify_critical_features.sh`, confirm hash (`check_spec_hash.sh`), ensure same-day backup exists (follow the manual snapshot steps in `docs/COMMAND_CENTER_BACKUP_PLAN.md` if one is missing).
   - After deploy: append to `deploy_logs/` referencing actual commands and remove/confirm any `railway-origin` dependence.

5. **Documentation Sync – Docs + QA**
   - Once the official process is clarified, propagate the decision into: `deploy_logs/`, `docs/COMMAND_CENTER_BACKUP_PLAN.md`, `AI_AGENT_PROMPT.md`, and team notes referencing the old workflow.
   - Update `.verification_audit.log` with any intentional deviations from canonical PS101 manifest/footer alignment.

## Dependencies / Blocking Items
- Await SSE decision on `railway-origin` relevance before attempting production deployment.
- Authentication warning must be explained or resolved (live site evidence) prior to go/no-go.

## Reporting
- Each assignee should drop findings + timestamps into `.ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md` or a new dated note, then ping Codex SSE for confirmation.
