# AI Agent Session Start Protocol

**MANDATORY: Every AI agent MUST run this at session start**

> Codex Reset Protocol → When invoked, re-run Steps 1–5 below.  
> Restate Present State → Desired Outcome, and re-log the session.

> **Current production references (2025-11-18T03:05Z):**  
> • Latest release log: `deploy_logs/2025-11-18_ps101-qa-mode.md` (PS101 QA Mode deploy)  
> • New production tag recorded: `prod-2025-11-18` @ commit `31d099cc21a03d221bfb66381a0b8e4445b04efc` (push pending—verify in git before tagging again)  
> • Latest site snapshot: `backups/site-backup_20251118_033032Z.zip`

## Agent Roles & Responsibilities

**ACTIVE TEAM (as of 2025-11-18):**

### Codex Terminal (CIT) - Troubleshooting Specialist
- **Model:** Haiku 4.5 (claude-haiku-4-5-20251001)
- **Primary Focus:** Active debugging, evidence capture, hands-on fixes
- **Strengths:** Fast diagnostic iterations, real-time problem resolution
- **Handoff:** Pass to Claude Code CLI for post-incident documentation

### Claude Code CLI - Systems Engineer + Documentation Steward
- **Model:** Sonnet 4.5 (claude-sonnet-4-5-20250929)
- **Primary Focus:** Infrastructure verification, documentation quality, post-deploy audits
- **Strengths:** Natural language summarization, cross-document consistency
- **Handoff:** Pass to CIT for active troubleshooting incidents

### Codex in Cursor (CIC) - Lead Developer
- **Primary Focus:** Implementation, deployment, code review
- **Strengths:** Feature development, technical execution
- **Coordination:** Orchestrates agent workflows

**Reference:** See `.ai-agents/TEAM_NOTE_ROLE_OPTIMIZATION_2025-11-18.md` for full rationale

---

## Step 1: Identify Yourself (FIRST MESSAGE)

```
I am [AGENT_NAME] starting session at [TIMESTAMP]

Running session start protocol...
```

## Step 2: Run Critical Feature Verification

**BEFORE reading any other files or taking any actions:**

```bash
./scripts/verify_critical_features.sh
```

**Expected output (current known-good run):**
```
✅ Authentication UI present
✅ PS101 flow present
⚠️  WARNING: API_BASE may not be using relative paths
⚠️  WARNING: Production site may be missing authentication (or unreachable)
✅ All critical features verified
```

> ⚠️ **Heads-up:** Until API_BASE is converted to a relative path and the production auth probe is fully automated, the script intentionally emits the two warnings shown above. Treat them as informational as long as the script exits with status `0`. If the script exits non-zero or emits additional warnings/errors, stop and escalate.

**If verification FAILS:**
- ❌ STOP immediately
- Do NOT proceed with any tasks
- Report to human: "Critical feature missing - verification failed"
- Wait for human to resolve before proceeding

## Step 2b: Confirm PS101 Continuity Kit Alignment

**Mandatory for Cursor and Claude_Code before continuing:**

1. Review the quick-start in `Mosaic/PS101_Continuity_Kit/README_NOTE_FOR_BUILD_TEAM.md` so the current manifest expectations are top of mind.
2. Run the hash check to confirm the working tree matches the canonical spec bundle:
   ```bash
   ./Mosaic/PS101_Continuity_Kit/check_spec_hash.sh
   ```
3. If the script reports drift, stop immediately, document the variance, and escalate for resolution before making further changes.
4. When preparing a deploy or reviewing a handoff, ensure the footer `BUILD_ID` rendered in the UI matches the value defined by `inject_build_id.js` and recorded in `manifest.can.json`.

## Step 3: Check for Handoff

**Look for handoff manifest:**

```bash
HANDOFF=$(ls -t .ai-agents/handoff_*.json 2>/dev/null | head -1)
```

**If handoff file exists (`HANDOFF` non-empty):**
- Read the handoff manifest
- Verify outgoing agent completed checklist
- Acknowledge all critical features listed
- Log handoff receipt in `.ai-agents/handoff_log.txt`

**If NO handoff file (fresh session):**
- Create session start marker:
  ```bash
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Session start: [AGENT_NAME]" >> .ai-agents/session_log.txt
  ```
- Review the newest file in `deploy_logs/` (e.g., run `ls -t deploy_logs/*.md | head -1`) and note the active `prod-YYYY-MM-DD` tag recorded there.
- Verify a current backup exists before you touch files:
  - Look for `/backups/site-backup_<today>.zip`. `<today>` uses UTC date (e.g., 20251118).
  - If none exists, create one manually following the steps in `docs/COMMAND_CENTER_BACKUP_PLAN.md` Section 5:
    ```bash
    TS=$(date -u +%Y%m%d_%H%M%SZ)
    zip -r backups/site-backup_${TS}.zip mosaic_ui frontend backend scripts docs .ai-agents
    ```
    (Adjust folders as needed; goal is a full working-tree snapshot.)
  - Log the backup filename/path in your first session message.

## Step 4: Review Recent Activity

**Check last 5 commits:**
```bash
git log -5 --oneline
```

**Check for urgent files:**
```bash
ls -1 URGENT_* FOR_*_AGENT*.md 2>/dev/null
```

**If urgent files exist:**
- Read them BEFORE proceeding with other tasks
- These files contain critical information from previous sessions

**Scan shared Stage/Team notes:**
```bash
ls -1t .ai-agents/STAGE*.md .ai-agents/TEAM_NOTE_*.md 2>/dev/null | head
```
- Re-read any document updated since your last session (compare timestamps or `git diff --stat HEAD@{1}`).
- Update the relevant Stage file with an acknowledgment line (e.g., `Cursor Acknowledged: ✅`) before moving on.

**Check system status documents:**
```bash
cat .ai-agents/CODEXCAPTURE_STATUS.md  # CodexCapture extension status
```
- Review current state of CodexCapture extension (updated 2025-11-17)
- Capture location: `~/Downloads/CodexAgentCaptures/`
- Repair script: `bash ~/scripts/codexcapturerepair.sh`
- Use Command+Shift+Y to trigger captures

## Step 5: Declare Readiness

**Only after completing steps 1-4, declare:**

```
✅ Session start protocol complete
✅ Critical features verified
✅ [Handoff received / Fresh session]
✅ Recent activity reviewed

Ready to proceed with tasks.

Current critical features confirmed:
- Authentication: [PRESENT/MISSING]
- PS101 v2: [PRESENT/MISSING]
- API Integration: [CONFIGURED/NEEDS-ATTENTION]
```

## Step 6: Operating Rules

**Throughout this session, I will:**

1. ✅ Run `./scripts/verify_critical_features.sh` BEFORE any deployment
2. ✅ Never remove authentication without explicit approval
3. ✅ Never replace files without checking for feature loss
4. ✅ Follow pre-commit hooks (never use --no-verify without approval)
5. ✅ Run `DEPLOYMENT_AUDIT_CHECKLIST.md` after deploys
6. ✅ Create handoff manifest before ending session if requested
7. ✅ Confirm the PS101 manifest/footer alignment before approving a review or initiating a deploy; log any intentional variances in `.verification_audit.log`.
8. ✅ Update all impacted documentation (notes, checklists, manifests) before declaring a task complete; summarize changes in the relevant handoff or audit log.
9. ✅ **NEVER use raw `git push` or deployment commands - use wrapper scripts:**
   - Use `./scripts/push.sh origin main` instead of `git push origin main`
   - Use `./scripts/deploy.sh netlify` instead of `netlify deploy --prod`
   - Use `./scripts/deploy.sh railway` to deploy backend
   - Use `./scripts/deploy.sh all` to deploy both frontend and backend
   - **Note:** `railway-origin` remote is legacy (no write access) - NOT required for deployment
10. ✅ **NEVER declare issues "fixed" or "resolved" without USER CONFIRMATION:**
   - Git commits saying "fix" ≠ issue is resolved
   - Code changes ≠ feature working
   - No errors in logs ≠ user-facing feature working
   - **ONLY the human operator can confirm features work in production**
   - Before archiving investigation files, get explicit user approval
   - Before closing issues, wait for user testing confirmation
   - **Rule:** "Fixed" means user verified, not AI assumed

**If I fail to follow these rules:**
- Pre-commit hook will BLOCK the commit
- Human will be notified of violation
- Session may be terminated and handed off to another agent

## Emergency Override

**Only use with explicit human approval:**

If human says "EMERGENCY OVERRIDE: [reason]", I may bypass verification ONCE, but must:
1. Document override reason in commit message
2. Add tag: [EMERGENCY-OVERRIDE]
3. Run full verification immediately after override action
4. Create recovery plan if verification fails

## Session End Protocol

**Before ending session (if requested):**

```bash
./scripts/create_handoff_manifest.sh > .ai-agents/handoff_$(date +%Y%m%d_%H%M%S).json
```

**Declare session end:**
```
Session ending. Handoff manifest created.
Next agent should read: .ai-agents/handoff_[TIMESTAMP].json
```

---

## Quick Reference Card

**Session Start Checklist:**
```
□ Identify self
□ Run ./scripts/verify_critical_features.sh
□ Run PS101 continuity hash check
□ Check for handoff manifest
□ Review recent commits
□ Read urgent files
□ Declare readiness
□ Begin work
```

**Before Every Deploy:**
```
□ Run ./scripts/verify_critical_features.sh
□ Confirm manifest.can.json + footer BUILD_ID alignment
□ Verify no critical features removed
□ Follow deployment checklist
□ Monitor post-deploy for 5 minutes
□ Update documentation + audit log entries
```

**Before Session End:**
```
□ Run ./scripts/create_handoff_manifest.sh
□ Commit or document WIP
□ Create handoff file
□ Log session end
```
