# Deployment/Test Flow

**Version:** 1.0
**Effective Date:** 2025-11-18
**Status:** ACTIVE - CIC Approved
**Last Updated:** 2025-11-18T10:45Z

---

## Overview

This document defines the complete deployment and test workflow with clearly segmented roles for each AI agent. Each step references exact artifacts and scripts to ensure lockstep team coordination.

**Key Principle:** Process-driven execution with evidence-based handoffs between agents.

---

## Agent Role Summary

### SSE (Session System Engineer) - Codex GPT-5 CLI
- **Focus:** Session kickoff, strategy, deployment execution
- **Model:** GPT-5 (via Codex CLI)
- **Responsibilities:** Verification, deployment coordination, sign-off

### CIT (Codex in Terminal) - GPT-5.1-Codex-Mini
- **Focus:** Active troubleshooting, real-time diagnostics
- **Model:** GPT-5.1-Codex-Mini (via `codex --model gpt-5.1-codex-mini`)
- **Responsibilities:** Live debugging, evidence capture, tactical fixes

### Claude Code CLI - Sonnet 4.5
- **Focus:** Documentation stewardship, systems verification
- **Model:** Claude Sonnet 4.5
- **Responsibilities:** Protocol updates, release notes, audit verification

---

## Step 1: Session Kickoff – SSE (Codex GPT-5 CLI)

**Owner:** SSE (Codex GPT-5 CLI)

**Actions:**

1. **Run critical feature verification:**
   ```bash
   ./scripts/verify_deployment.sh
   ```

2. **Run PS101 continuity check:**
   ```bash
   ./Mosaic/PS101_Continuity_Kit/check_spec_hash.sh
   ```

3. **Check for latest handoff:**
   ```bash
   ls -t .ai-agents/handoff_*.json | head -1
   ```
   - If handoff exists: Read and acknowledge
   - Log receipt in `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/handoff_log.txt`

4. **Review latest release log:**
   - File: `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/deploy_logs/2025-11-18_ps101-qa-mode.md`
   - Note active `prod-YYYY-MM-DD` tag

5. **Confirm today's backup exists:**
   - Check for: `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/backups/site-backup_<YYYYMMDD>_<HHMMSS>Z.zip`
   - If missing: Trigger manual snapshot per `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/docs/COMMAND_CENTER_BACKUP_PLAN.md`
   - Command:
     ```bash
     TS=$(date -u +%Y%m%d_%H%M%SZ)
     zip -r backups/site-backup_${TS}.zip mosaic_ui frontend backend scripts docs .ai-agents
     ```

6. **Assign/confirm owners for open actions:**
   - Review: `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/TEAM_NOTE_DEPLOYMENT_FOLLOWUP_2025-11-18.md`
   - Assign tasks to CIT, Claude, or self
   - Note assignments in document

**Outputs:**
- Verification results logged
- Backup confirmed/created
- Handoff acknowledged
- Task assignments documented

**Handoff to:** CIT (if active troubleshooting needed) or Claude (if documentation work needed)

---

## Step 2: Active Troubleshooting – CIT (GPT-5.1-Codex-Mini)

**Owner:** CIT (Codex in Terminal with GPT-5.1-Codex-Mini)

**Start command:**
```bash
codex --model gpt-5.1-codex-mini
```

**Focus Areas:**

1. **Live debugging tasks:**
   - API_BASE warning investigation
   - Production auth probe issues
   - Runtime regressions
   - Any real-time production incidents

2. **Evidence capture:**
   - Console logs
   - Network traces
   - CodexCapture screenshots (via Command+Shift+Y)
   - Error messages

3. **Stash evidence paths in:**
   - Primary: `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md`
   - Or create new URGENT_* file if different issue

4. **Apply tactical fixes:**
   - Scripts modifications
   - Config adjustments
   - Code hotfixes (within CIT scope)

5. **Rerun verification locally:**
   ```bash
   ./scripts/verify_deployment.sh
   ```

**Handoff trigger:**
When fix is ready OR more documentation required

**Handoff to:** Claude Code CLI

**Handoff includes:**
- Summary of diagnosis
- Evidence file paths
- Fix description
- Verification results
- Remaining work (if any)

**Format:**
```json
{
  "from": "CIT",
  "to": "Claude_Code_CLI",
  "timestamp": "2025-11-18T10:45Z",
  "issue": "API_BASE warning investigation",
  "diagnosis": "Summary here",
  "evidence": [
    "/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/evidence/console_logs_20251118.txt"
  ],
  "fix_applied": "Description of fix",
  "verification": "PASSED",
  "next_steps": "Documentation update needed"
}
```

---

## Step 3: Documentation & Systems Stewardship – Claude Code CLI (Sonnet 4.5)

**Owner:** Claude Code CLI (Sonnet 4.5)

**Responsibilities:**

### 3.1 Protocol/Doc Updates

**Files to maintain:**
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/SESSION_START_PROTOCOL.md`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/CLAUDE.md`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/DEPLOYMENT_AUDIT_CHECKLIST.md`

**Process:**
- Every change from CIT/SSE must be reflected in docs
- Cross-reference evidence bundles
- Ensure BUILD_ID references match reality

### 3.2 Release Notes Maintenance

**File:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/deploy_logs/2025-11-18_ps101-qa-mode.md` (or create new dated file)

**Include:**
- Deployment details
- Changes deployed
- Verification results
- Evidence references
- Tag information

### 3.3 Stage/Team Documents

**Files to update:**
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/STAGE*.md`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/TEAM_NOTE_*.md`

**Ensure:**
- Evidence bundles referenced
- BUILD_ID matches `manifest.can.json`
- All CIT outputs reviewed

### 3.4 Narrative-Level Verification

**Actions:**
- Review CIT fix descriptions
- Verify evidence paths exist and are accessible
- Cross-check deployment artifacts
- Run narrative-level verification (doc consistency)

### 3.5 Handoff Manifest Preparation

**Command:**
```bash
./scripts/create_handoff_manifest.sh > .ai-agents/handoff_$(date +%Y%m%d_%H%M%S).json
```

**Or manual format:**
```json
{
  "timestamp": "2025-11-18T10:45Z",
  "from": "Claude_Code_CLI",
  "to": "SSE",
  "session_summary": "Documentation updated post-CIT fix",
  "files_updated": [
    ".ai-agents/SESSION_START_PROTOCOL.md",
    "deploy_logs/2025-11-18_fix_summary.md"
  ],
  "verification": "Documentation audit complete",
  "ready_for_deploy": true
}
```

**Handoff to:** SSE (for deployment execution)

---

## Step 4: Deployment Execution – SSE (Codex) with CIT Support

**Owner:** SSE (Codex GPT-5 CLI)
**Support:** CIT (if blockers arise)

**Prerequisites:**
- CIT has cleared all blockers
- Claude has completed documentation audit
- Handoff manifest received

### 4.1 Push to Origin

**Command:**
```bash
./scripts/push.sh origin main
```

**Verification:**
- Check git push succeeded
- Note commit SHA

### 4.2 Deploy Frontend (if frontend changes)

**Command:**
```bash
./scripts/deploy.sh netlify
```

**Capture:**
- Netlify deploy ID
- Deploy URL
- Timestamp

### 4.3 Deploy Backend (if backend changes)

**Coordinate with CIT first** for additional evidence/tests

**Command:**
```bash
./scripts/deploy.sh railway
```

**Capture:**
- Railway deploy ID
- Service URL
- Timestamp

### 4.4 Follow Deployment Audit Checklist

**File:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/DEPLOYMENT_AUDIT_CHECKLIST.md`

**Required steps:**
1. ✅ Capture backup info (backup filename, path)
2. ✅ Record Netlify deploy ID
3. ✅ Record Railway deploy ID (if applicable)
4. ✅ Verify BUILD_ID in live UI matches commit
5. ✅ Run post-deploy verification:
   ```bash
   ./scripts/verify_live_deployment.sh
   ```
6. ✅ Update release log with all IDs and verification results

### 4.5 Update Release Log

**File:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/deploy_logs/2025-11-18_ps101-qa-mode.md` (or create new)

**Required sections:**
- Deployment summary
- Netlify/Railway IDs
- BUILD_ID verification
- Verification results
- Evidence references

---

## Step 5: Post-Deploy/Handoff – Claude Code CLI

**Owner:** Claude Code CLI (Sonnet 4.5)

**Actions:**

### 5.1 Append Results to Deploy Log

**File:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/deploy_logs/2025-11-18_ps101-qa-mode.md`

**Add:**
- Final deployment status
- All verification results
- Evidence bundle paths
- Any issues encountered
- Resolution status

### 5.2 Update Session Protocol References

**Files:**
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/SESSION_START_PROTOCOL.md`
  - Update production references (lines 8-11)
  - Update latest release log pointer
  - Update latest backup reference

### 5.3 Ensure Audit Trail Complete

**Files to verify:**
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.verification_audit.log`
  - Contains all verification steps
  - Timestamps accurate
  - Results documented

- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/handoff_*.json`
  - Latest handoff manifest created
  - Reflects current state
  - All tasks documented

### 5.4 SSE Review & Sign-Off

**Owner:** SSE (Codex GPT-5 CLI)

**Final checks:**
1. Review Claude's documentation updates
2. Confirm all tasks recorded in handoff manifest
3. Verify session log entries complete
4. Sign off on deployment completion

**Sign-off format:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SSE sign-off: Deployment complete, documentation verified" >> .ai-agents/session_log.txt
```

---

## Role Segmentation Summary

### SSE (Codex GPT-5 CLI)
- **Strategy:** Session kickoff, coordination, deployment execution
- **Deployments:** Owns git push, netlify/railway deploys
- **Sign-off:** Final approval and verification

### CIT (GPT-5.1-Codex-Mini)
- **Real-time diagnostics:** Live debugging, evidence capture
- **Fixes:** Tactical code/config/script fixes
- **Speed:** Fast iteration on GPT-5.1-Codex-Mini

### Claude Code CLI (Sonnet 4.5)
- **Documentation:** Protocol updates, release notes, audit trails
- **Verification:** Cross-document consistency, narrative review
- **Audit:** Ensures evidence matches reality

---

## Critical File Paths Reference

### Scripts
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/scripts/verify_critical_features.sh`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/scripts/verify_live_deployment.sh`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/scripts/push.sh`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/scripts/deploy.sh`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/Mosaic/PS101_Continuity_Kit/check_spec_hash.sh`

### Documentation
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/SESSION_START_PROTOCOL.md`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/DEPLOYMENT_AUDIT_CHECKLIST.md`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/AGENT_ROLES.md`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/CLAUDE.md`

### Logs & Evidence
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/session_log.txt`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/handoff_log.txt`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.verification_audit.log`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/evidence/`

### Handoffs
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/handoff_*.json`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/URGENT_*.md`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/TEAM_NOTE_*.md`

### Deploy Logs
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/deploy_logs/2025-11-18_ps101-qa-mode.md`
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/deploy_logs/` (all dated logs)

### Backups
- `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/backups/site-backup_*.zip`

---

## Process-Driven Execution

**Key Principle:** Every step references exact artifacts and scripts. No assumptions, no skipped steps.

**Evidence-Based:** All handoffs include specific file paths to evidence.

**Lockstep Coordination:** Agents move sequentially through workflow, each step verifiable.

**Audit Trail:** Complete documentation from kickoff through sign-off.

---

**END OF DEPLOYMENT/TEST FLOW**

**Version:** 1.0
**Maintained by:** Claude Code CLI (Documentation Steward)
**Last Updated:** 2025-11-18T10:45Z
**Next Review:** After first deployment using this flow
