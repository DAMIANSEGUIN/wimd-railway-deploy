# .ai-agents Archive Directory

**Purpose**: Historical archive of dated handoffs, diagnostics, and session documentation
**Created**: 2025-12-05
**Policy**: Organized by type and date for easy navigation

## Directory Structure

```
archive/
├── handoffs/
│   ├── 2025-11/  (November dated handoffs)
│   └── 2025-12/  (December dated handoffs)
├── deployments/
│   ├── 2025-11/  (November deployment logs)
│   └── 2025-12/  (December deployment logs)
├── sessions/
│   ├── 2025-11/  (November session summaries)
│   └── 2025-12/  (December session summaries)
├── testing/
│   ├── 2025-11/  (November test diagnostics)
│   └── 2025-12/  (December test diagnostics)
└── issues/
    ├── 2025-11/  (November issue reports)
    └── 2025-12/  (December issue reports)
```

## What Gets Archived

**Handoffs**: Dated handoff documents older than 2 weeks
**Deployments**: Deployment snapshots, diagnostics, and status reports
**Sessions**: Session summaries, recovery logs, and restart prompts
**Testing**: Test failure diagnostics and results
**Issues**: Issue reports and diagnostics

## Retention Policy

- Keep current month + previous 2 months (rolling 90-day window)
- Archive older files beyond 90 days to compressed backup
- Delete files older than 180 days unless flagged for long-term retention

## Archived Files (2025-11)

### Handoffs (3 files)
- HANDOFF_NETLIFY_RUNNER_2025-11-06.md
- NETLIFY_RUNNER_FILE_REFERENCE_2025-11-06.md
- NETLIFY_RUNNER_START_HERE_2025-11-06.md

### Deployments (5 files)
- DEPLOYMENT_ATTEMPT_2_2025-11-07.md
- DEPLOYMENT_STATUS_2025-11-07.md
- DEPLOYMENT_LOOP_DIAGNOSIS_2025-11-09.md
- DEPLOYMENT_SUCCESS_2025-11-09.md
- DEPLOYMENT_SNAPSHOT_2025-11-11.md
- DIAGNOSTIC_REPORT_20251102.md
- FINAL_DIAGNOSTIC_20251102.md
- FINDINGS_SUMMARY.md

### Sessions (8 files)
- SESSION_RECOVERY_2025-11-07_1712.md
- SESSION_SUMMARY_2025-11-07_1601.md
- SESSION_RESTART_PROMPT_2025-11-07.md
- SESSION_BACKUP_2025-11-09_1635.md
- SESSION_SUMMARY_2025-11-12.md
- SESSION_SUMMARY_2025-11-13.md
- SESSION_SUMMARY_20251102.md
- STAGE1_CURRENT_STATE_2025-11-05.md
- STAGE2_ACTION_PLAN_2025-11-05.md
- STAGE2_DIAGNOSIS_2025-11-05.md
- STAGE3_VERIFICATION_2025-11-05.md
- SITUATIONAL_REPORT_2025-11-05.md

### Testing (1 file)
- TEST_FAILURE_DIAGNOSIS_2025-11-09.md

### Issues (1 file)
- INITAPP_UNDEFINED_ISSUE_2025-11-09.md

---

**Total Archived**: 30 files from November 2025
**Backup**: /Users/damianseguin/AI_Workspace/WIMD-Pre-Cleanup-Backup-2025-12-05.tar.gz
