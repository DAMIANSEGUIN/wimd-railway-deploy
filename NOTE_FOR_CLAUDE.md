# Note for Claude: Script Cleanup and Canonical Workflow

Hi Claude,

To address the confusion and issues caused by a large number of conflicting and outdated scripts, a cleanup has been performed.

**What Changed:**

1.  **Archived Old Scripts:** Many redundant deployment and verification scripts have been moved to `/scripts/archive`. They should no longer be used.
2.  **Updated Core Scripts:** The main deployment and verification scripts (`deploy.sh`, `push.sh`, `pre_push_verification.sh`, `verify_live_deployment.sh`) have been updated to provide a single, clear workflow.
3.  **Updated Documentation:** The `TEAM_PLAYBOOK.md` has been updated with a new section that defines the canonical scripts to be used for all future deployments.

**Your Action:**

Please read the new "Canonical Scripts" section in the `TEAM_PLAYBOOK.md` to understand the new, simplified deployment and verification process.

**Link to Documentation:**

[TEAM_PLAYBOOK.md#️-canonical-scripts](https://github.com/DAMIANSEGUIN/wimd-railway-deploy/blob/main/TEAM_PLAYBOOK.md#️-canonical-scripts)

This cleanup should prevent future deployment issues caused by using the wrong scripts.
