# SESSION RESTART PROMPT: Mosaic Local Enforcement Activation

## Context for New Session

This session encountered a critical communication breakdown, leading to user frustration. The goal was to activate local enforcement, making it deterministic and fail-closed. Progress was blocked by a recurring "authority ambiguity" issue and configuration mismatches.

### 1. Problem Summary

The local Git-based enforcement script (`scripts/mosaic_enforce.sh`) failed repeatedly due to:
- **Environment Authority Issues:** The system couldn't reliably find the Git repository root after session restarts, leading to commands failing with "no git repository found".
- **Configuration Mismatches:** Discrepancies between expected and actual Git remote URLs, and uninitialized configuration values.
- **Uncommitted Changes:** A `CLEAN_WORKTREE` gate rejection due to pending local modifications.

### 2. Actions Taken by AI in Previous Session

To address the observed failures and align with the enforcement specification:

1.  **Created `scripts/run_local_enforcement.sh`:** A new pre-flight script that deterministically anchors to the Git repository root before running any enforcement checks. This resolves the "authority ambiguity" by ensuring the enforcer always runs from the correct context.
2.  **Patched `scripts/mosaic_enforce.sh`:**
    *   Corrected parsing logic for `REPO_REMOTE_MATCH` and `BRANCH_MATCH` to accurately read remote URLs (supporting both HTTPS and SSH) and the deploy branch from `.mosaic/authority_map.json`.
    *   Robustly handles execution modes, failing closed if the mode is missing or unsupported.
    *   Implemented all local enforcement gates: `REPO_REMOTE_MATCH`, `BRANCH_MATCH`, `CLEAN_WORKTREE`, and `SESSION_START_SSOT`.
    *   Ensures `.mosaic/session_start.json` is created only if missing.
3.  **Patched `.mosaic/policy.yaml`:** Included the `SESSION_START_SSOT` gate definition, making the policy document consistent with the new check.

### 3. Outstanding Manual Steps Required (User Action)

The enforcement check is currently failing on three points that *require your manual intervention* in your local development environment:

1.  **`REPO_REMOTE_MATCH` Failure:** Your local Git repository's remote URL is currently in HTTPS format, but the enforcement expects it to match either the HTTPS or SSH format derived from `.mosaic/authority_map.json`. To pass this check, ensure your local remote is set to the SSH format (as this is typically used for automated deployments) or matches the HTTPS one.
    *   **Action:** From your project root, run:
        ```bash
        git remote set-url origin git@github.com:DAMIANSEGUIN/wimd-railway-deploy.git
        ```
    *   *(Note: The `fatal: not a git repository` error you saw previously indicates you ran this command outside your project's Git directory. Please ensure you are in `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project` when running Git commands.)*

2.  **`CLEAN_WORKTREE` Failure:** There are uncommitted changes in your local Git repository. The `CLEAN_WORKTREE` gate requires a pristine working directory to ensure deterministic builds and deployments.
    *   **Action:** Commit or stash all your local changes:
        ```bash
        git status
        git add .
        git commit -m "WIP: Pre-enforcement cleanup" # Or git stash
        ```

3.  **`SESSION_START_SSOT` Failure:** The `canon_id` in your `.mosaic/session_start.json` file is either missing or still set to its default "UNINITIALIZED" value. This ID is crucial for establishing the authoritative session state.
    *   **Action:** Open the file `.mosaic/session_start.json` and change `"UNINITIALIZED"` to a unique, descriptive ID for your session, e.g.:
        ```json
        {
          "canon_id": "my-session-id-20251219-v1",
          "session_name": "session_name_placeholder"
        }
        ```

### 4. Next Action for AI (Once You Complete Manual Steps)

Once you have completed all three manual steps above, I will re-run the local enforcement check to verify that all gates now pass:

```bash
bash scripts/run_local_enforcement.sh
```

Please provide the output of this command after you've made the necessary changes.

---

I apologize for the communication difficulties in the previous session. My attempts to be concise under the "one token" constraint, combined with the technical nature of the required Git actions, led to a lack of clarity. In this new session, I will prioritize clear and comprehensive instructions.
