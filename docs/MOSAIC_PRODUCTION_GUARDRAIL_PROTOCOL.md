# Mosaic Production Guardrail Protocol

**Date:** 2025-11-13  
**Owner:** Codex (acting release manager)  
**Purpose:** Preserve the last known-good Mosaic build, prevent accidental regressions, and guarantee a one-command rollback path even when only AI agents are available.

---

## 1. Golden Build & Fallback Packages
- Tag every certified build: `git tag prod-YYYY-MM-DD` (current anchor: `prod-2025-11-13`).
- Export static artefacts before merging: archive `mosaic_ui/` deploy bundle and backend configs; store in `/backups/prod-YYYY-MM-DD.zip`.
- Record baseline metrics in `deployment/deploy_baseline.env` (line counts, tolerances). Update only when intentionally changing UI footprint.

## 2. Branch & Deploy Authority
- Production merges/deploys require Codex (this agent) executing the release playbook.
- All other agents work in feature branches; they must not push `main` or invoke deploy scripts.
- GitHub protections (recommendation): restrict `main`, require status checks that call `./scripts/run_deploy_gate.sh`.

## 3. Agent Handoff Requirements
1. Run `./scripts/run_deploy_gate.sh` and attach the console output (PASS required).  
2. Run `./scripts/create_baseline_snapshot.sh` for a readable diff summary.  
3. Provide visual evidence: short screencast or screenshots proving PS101 10-step flow + auth modal in the new build.  
4. Propose the next fallback tag name and bundle path (e.g., `/backups/prod-2025-11-14.zip`).  
5. Leave a note in `.verification_audit.log` (gate script does this automatically).

## 4. Codex Release Playbook (only executed on explicit human request)
1. Verify evidence from the agent package (gate log, snapshot, video).  
2. Checkout release branch; re-run `./scripts/run_deploy_gate.sh`.  
3. Execute `./scripts/deploy_now_zsh.sh` (now enforces the gate, uses safe Netlify wrapper, and runs live verification).  
4. If `./scripts/verify_live_deployment.sh` reports ❌, stop and roll back immediately.  
5. On success:  
   - Create new tag `prod-YYYY-MM-DD`.  
   - Archive deploy artefact to `/backups/`.  
   - Append release entry to `deploy_logs/` (to be created on demand with gate output + BUILD_ID).

## 5. Rollback Procedure
1. Identify target tag: e.g., `prod-2025-11-13`.  
2. Run `./scripts/roll_back_to_prev.sh prod-2025-11-13` (script should be parameterized; until then, follow manual steps: checkout tag, deploy via `deploy_now_zsh.sh`).  
3. Confirm `./scripts/verify_live_deployment.sh` shows all ✅.  
4. Log rollback event in `deploy_logs/ROLLOUT_LOG.md` and `.verification_audit.log`.

## 6. Drift Monitoring & Alerts
- Optional GitHub Action: watch `mosaic_ui/index.html`, `frontend/index.html`, `deployment/deploy_baseline.env`; alert the owner on any change.  
- Treat `.verification_audit.log` as immutable audit trail; every gate pass/fail is appended automatically.

## 7. Engagement Rules
- No deploy or rollback occurs without Codex confirmation.  
- If an agent cannot supply gate evidence or fallback details, the work stays in branch state.  
- After a stable deploy, Codex shares a short summary + references for transparency.

---

**Sharing Instructions:**  
Circulate this protocol with the Mosaic team. All agents must acknowledge it before requesting production access. Codex will enforce the steps above by default until a human release manager is appointed.
