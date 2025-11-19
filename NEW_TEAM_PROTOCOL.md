# New Team Protocol: The Implementer-Auditor Model

## 1. Guiding Principle

To increase efficiency and eliminate regressions, our AI team will operate on a model that mirrors a modern CI/CD (Continuous Integration / Continuous Delivery) pipeline. The core principle is **"Trust, but Verify, Programmatically."**

Protocols are not a manual to be read; they are scripts to be executed. All changes must pass an automated, programmatic audit before they can be deployed.

## 2. The Roles

### Role 1: The `Implementer` (SSE)
- **Agent:** Gemini (or other lead agent)
- **Responsibility:** The primary engine of change. Implements new features and fixes bugs.
- **Key Constraint:** The Implementer **does not** have the authority to approve or deploy its own changes. Its final output is a "Change Request."

### Role 2: The `Auditor`
- **Agent:** Claude Haiku (or other fast, cost-effective model)
- **Responsibility:** Acts as the automated Quality Assurance (QA) and CI gatekeeper. It is the **only** agent with the authority to approve a change for deployment.
- **Workflow:**
    1. Automatically triggers when a new Change Request is submitted.
    2. Executes the master verification script: `./scripts/run_audit.sh`.
    3. Programmatically audits for documentation drift (e.g., code changes must have corresponding `.md` file changes).
    4. Updates the central status board (`.ai-agents/SYSTEM_STATUS.json`) with the result (`approved` or `rejected`).

### Role 3: The `Live Troubleshooter`
- **Agent:** GPT-5.1-Codex-Mini (or other fast diagnostic model)
- **Responsibility:** Fire-fighting only. Diagnoses and proposes fixes for live production issues.
- **Constraint:** A proposed hotfix is still a Change Request that must be validated by the `Auditor` before deployment.

## 3. The Workflow

1.  **Tasking:** The human operator places a task in a central task list. The `Implementer` picks up a task.
2.  **Implementation:** The `Implementer` works on the task, creating code changes.
3.  **Submission:** When work is complete, the `Implementer` commits the changes and updates the `.ai-agents/SYSTEM_STATUS.json` file, setting its status to `pending_audit` and describing the change. This is the "Change Request."
4.  **Audit:** The `Auditor` agent is triggered. It reads the `SYSTEM_STATUS.json` file and sees the `pending_audit` status.
5.  **Verification:** The `Auditor` runs `./scripts/run_audit.sh`.
6.  **Decision:**
    *   **If PASS:** The `Auditor` updates the status to `approved`.
    *   **If FAIL:** The `Auditor` updates the status to `rejected` and includes the failure logs in the status file. The `Implementer` is automatically alerted to fix the issue.
7.  **Final Approval:** The human operator is notified (e.g., via an audio alert script) that a change is `approved`. They provide the final go-ahead.
8.  **Deployment:** The `Auditor` (or a dedicated `Deployer` agent) runs the final deployment scripts.

## 4. The System Status Board

- **File:** `.ai-agents/SYSTEM_STATUS.json`
- **Purpose:** This file is the single source of truth for the team's status. It is how agents communicate and hand off tasks. All agents read this file at the start of their session and update it at the end.
- **Benefit:** Eliminates the need for agents to search for work, provides a clear audit trail, and gives the human operator a single place to monitor the entire system.