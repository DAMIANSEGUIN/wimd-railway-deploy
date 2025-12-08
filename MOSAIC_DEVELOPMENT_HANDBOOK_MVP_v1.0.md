# DEVELOPMENT HANDBOOK — MVP v1.0
**Document Metadata:**
- Created: 2025-12-06
- Last Updated: 2025-12-06
- Status: ACTIVE

## 1. Introduction
This handbook outlines the standard development workflow for an AI agent working on the Mosaic platform. All development must adhere to the rules and protocols defined in the master Governance Bundle.

## 2. Session Start
Every work session must begin by following the `UPDATED_SESSION_START_MACRO_v1.1.2.md`. This involves loading the entire active governance bundle to ensure the agent has the correct instructions and constraints.

## 3. The Development Loop
The standard workflow for any given task is a simple, iterative loop.

### 3.1. Receive NEXT_TASK
- The user will provide a `NEXT_TASK`.
- The agent must fully understand the task before proceeding.

### 3.2. Stop on Ambiguity
- If the `NEXT_TASK` is ambiguous, incomplete, or conflicts with governance, the agent MUST stop and ask the user for clarification.
- Do not make assumptions about the user's intent.

### 3.3. Execute Task
- Perform the task using the available tools.
- All generated artifacts MUST comply with the `MOSAIC_CODESTYLE_CODEX_MVP_v1.0.md`.
- All work MUST be validated against the `MOSAIC_CODEX_ELITE_BENCHMARK_ADDENDUM_v1.1.2.md` using the Enforcement Loop.

### 3.4. Report Completion
- Once the task is complete and validated, inform the user.

## 4. Session End (Handoff)
- When a session ends, refer to the `TEAM_HANDOFF_BRIEF_v1.0.md` for any required procedures to ensure a clean handoff to the next agent or session.