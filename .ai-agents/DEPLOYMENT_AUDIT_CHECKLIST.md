# Deployment Audit Checklist
**Updated:** 2025-11-18  
**Owner:** Codex (release lead)  

Use this checklist every time we deploy (frontend, backend, or both). Record answers in the deploy log entry for the release (`deploy_logs/YYYY-MM-DD_<description>.md`) and attach supporting evidence (console captures, gate output, screenshots).

---

## 1. Pre-flight Verification
1. ✅ `./scripts/verify_deployment.sh` (exit code 0). Note any warnings (API_BASE, production auth probe) and confirm they match the known baseline.
2. ✅ `./Mosaic/PS101_Continuity_Kit/check_spec_hash.sh` (spec hash logged).
3. ✅ Backup present:
   - Does `/backups/site-backup_<today>.zip` exist (UTC date)?
   - If not, run the manual snapshot procedure from `docs/COMMAND_CENTER_BACKUP_PLAN.md` and record the new filename.
4. ✅ Working tree clean (`git status --short` empty). If not, stash or commit before proceeding.
5. ✅ Release log prepared: create or identify `deploy_logs/<new entry>.md` and prefill metadata (commit SHA, BUILD_ID, target environment).

## 2. Push & Deployment Commands
> **Wrapper scripts only.** Raw `git push`, `netlify deploy`, or `railway up` are forbidden.

1. ✅ Push latest changes:
   ```bash
   ./scripts/push.sh origin main
   ```
   - Confirm verification gate output archived.
2. ✅ Deploy frontend (if applicable):
   ```bash
   ./scripts/deploy.sh netlify
   ```
   - Record Netlify deploy ID + live URL.
3. ✅ Deploy backend (if applicable):
   ```bash
   ./scripts/deploy.sh railway
   ```
   - Record Railway deploy ID / CLI output.
4. ✅ Combined deploy:
   ```bash
   ./scripts/deploy.sh all
   ```
   (Use only if both tiers changed.)

## 3. Post-deploy Validation
1. ✅ Compare BUILD_ID rendered in the UI footer with the value injected by `inject_build_id.js` and documented in `manifest.can.json`.
2. ✅ Run targeted smoke tests:
   - Authentication modal appears + dismisses.
   - PS101 flow accessible (QA Mode toggle confirmed if relevant).
   - Chat entry point renders and network calls reach `/wimd`.
3. ✅ Capture evidence (CodexCapture or equivalent):
   - Screenshot of live site with BUILD_ID visible.
   - Console/network logs showing successful API calls.
4. ✅ Update `deploy_logs/<entry>.md` with:
   - Commands executed + timestamps.
   - Verification outputs (hashes, warnings, backups).
   - Netlify/Railway deploy IDs and links.
   - Known follow-up actions or caveats.
5. ✅ Tag release if production:
   ```bash
   git tag prod-YYYY-MM-DD <commit>
   ./scripts/push.sh origin prod-YYYY-MM-DD
   ```

## 4. Handoff & Audit Trail
1. ✅ Append summary to `.verification_audit.log` (pending automation). Include gate output path, deploy log filename, and evidence bundle.
2. ✅ Update any relevant team notes or urgent docs.
3. ✅ Create/refresh handoff manifest (`./scripts/create_handoff_manifest.sh`) if ending session.
4. ✅ Confirm backups + deploy logs are referenced in your final session message.

---

**Reminder:** `railway-origin` is a legacy mirror and NOT part of the deployment workflow. If a document references it, update the doc or report the mismatch. This checklist is the source of truth until superseded by a new release directive.
