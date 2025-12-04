# Handoff for Claude

**Timestamp:** 2025-11-28

This document is a handoff note to bring you up to speed on the WIMD project. Do not rely on this note for a summary of the project state. Instead, refer to the detailed documentation linked below for the most accurate and up-to-date information.

## Primary Objective
The immediate priority is to resolve the JavaScript hoisting issue that is blocking the PS101 functionality.

## Current Priority Issues (P0)
1.  **Login diagnostic deployment:** Commit `b7e042c` is awaiting Railway deploy.
2.  **PS101 hoisting bug:** Baseline is `pre-ps101-fix_20251126_220704Z`.

## Git Repository
*   **Primary:** `https://github.com/DAMIANSEGUIN/wimd-railway-deploy`
*   **Branch:** `phase1-incomplete` (currently has 30 uncommitted files)
*   **Remote:** `origin` (triggers Railway auto-deploy on push)

## Production State
*   **Frontend:** `https://whatismydelta.com` (Netlify) - Status: Healthy ✅
*   **Backend:** `https://what-is-my-delta-site-production.up.railway.app` (Railway) - Status: Healthy ✅

## Key Context
*   Phase 1 modularization is 95% complete (requires a 3-line integration).
*   Two baseline backups are available.
*   The 30 uncommitted files need classification.

## Deployment Process
*   Use wrapper scripts: `./scripts/deploy.sh`
*   **Never** use raw `git push` or `netlify deploy`.
*   Always verify before deploying: `./scripts/verify_critical_features.sh`

## Key Documents
To understand the current state of the project, the issues, and the architectural guidance, please review the following documents in this order:

1.  **`AI_RESUME_STATE.md`**: This is the primary source of truth for the project's current state, including critical issues, the latest backup, and the next steps.
2.  **`.ai-agents/GEMINI_PS101_FIX_APPROVAL_2025-11-26.md`**: This document contains Gemini's architectural guidance and the approved fix for the PS101 hoisting issue.
3.  **`.ai-agents/FOR_GEMINI_PS101_TESTING_BUGS_2025-11-26.md`**: This file provides a detailed list of bugs found during the last testing session.

Please begin by thoroughly reviewing the documentation to ensure you are clear on the current state and the required tasks.