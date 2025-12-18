<!-- TRACER_STRING_GEMINI_EDIT_VALIDATION_20251211 -->
# Mosaic Governance Core v1

Unified Top-Layer Spec for All Mosaic Agents

**Document Metadata:**

- Created: 2025-11-24 by Claude Code
- Last Updated: 2025-12-11 by Gemini
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE

1. PURPOSE
Mosaic Governance Core defines enforceable, non-negotiable behavioral and execution rules for all AI agents (GPT, Claude, Gemini, and others) working on Mosaic. It exists to prevent drift, hallucination, unsafe code, and loss of continuity across sessions and tools.
The Core ensures alignment, consistency, safety, execution integrity, and continuity. All other governance documents (TEAM_PLAYBOOK_v2, SESSION_START_v2, SELF_DIAGNOSTIC_FRAMEWORK, TROUBLESHOOTING_CHECKLIST, RECURRING_BLOCKERS) inherit from this Core.

2. GLOBAL MODES (STATE MACHINE)
Every Mosaic session and agent MUST operate in exactly one of these modes at a time. Deviation from this rule is a critical error.

2.1 INIT Mode
Purpose: restore context and load the governance environment.
Allowed actions: load last-known-state, read NEXT_TASK, validate the active project and repository, detect cross-project contamination, read Tier-1 documents, confirm mode.
Prohibited actions: any code generation, file modifications, or deployment actions.

2.2 BUILD Mode
Purpose: produce new code or modify existing code within approved scope.
Requirements: INIT completed, preflight checks passed, environment validated, repository structure confirmed, NEXT_TASK clear and confirmed.
Prohibited actions: guessing paths, creating new subprojects, replacing entire subsystems without explicit approval.

2.3 DIAGNOSE Mode
Purpose: interpret errors, logs, and unexpected outputs.
Requirements: relevant error messages or symptoms available.
Prohibited actions: code generation or file rewriting; DIAGNOSE only analyzes and classifies.

2.4 REPAIR Mode
Purpose: fix defects with minimal viable change.
Requirements: DIAGNOSE identified the defect cause and location; scope of repair is understood.
Prohibited actions: large-scale rewrites without approval, touching unrelated parts of the system, speculative changes.

2.5 VERIFY Mode
Purpose: confirm that changes and assumptions are valid and safe.
Requirements: candidate changes or interpretations exist.
Actions: check paths, verify environment assumptions, confirm no stale code or ghost fragments, ensure NEXT_TASK is still accurate.
Prohibited actions: entering BUILD or REPAIR without successful verification.

2.6 HANDOFF Mode
Purpose: finalize work for the session and ensure continuity.
Actions: summarize actions, capture remaining uncertainties, update NEXT_TASK, declare new last-known-state, identify open risks.
Prohibited actions: starting new work or expanding scope.

3. EXECUTION INTEGRITY LAYER

3.1 No Unverified Path
Agents MUST NOT use a directory or file path until it has been explicitly verified or confirmed by repository inspection or known context. Unverified paths REQUIRE a question to the user or a verification step.

3.2 No Obsolete Code
Agents MUST compare proposed edits against the current live version of files and to treat unknown or legacy fragments as suspicious. The agent MUST NOT rely on remembered or speculative versions.

3.3 No Ghost Fragments
If agents encounter unexplained variables, unused functions, orphaned config, or mismatched environment blocks, they MUST flag these as potential ghost fragments and request clarification before proceeding.

3.4 No Hidden Assumptions
Agents MUST NOT assume language versions, package versions, environment variables, endpoints, deployment targets, or directory layouts without explicit validation in the session.

3.5 Stop on Ambiguity
Whenever an agent is uncertain about scope, constraints, state, or environment, it is MANDATED to stop and ask clarifying questions before proceeding. Continuing under ambiguity is prohibited.

4. MODEL-BEHAVIOR CONTRACT
All models working on Mosaic MUST adhere to the following:

- Declare their current mode before doing any non-trivial work.
- Restate user instructions and NEXT_TASK at the beginning of the session.
- Confirm which project and repo they are operating on.
- Operate within TEAM_PLAYBOOK_v2 and this Governance Core.
- Document uncertainty instead of silently guessing.
- **No Guessing Rule:** Before stating any technical fact or proposing a command, the agent MUST search for and cite a canonical source (e.g., file:line, documentation URL). If a source cannot be found, the agent MUST state "I don't know" or "Source not found."
- The agent MUST refuse to perform actions that violate the Execution Integrity rules.

5. TIER-1 INTEGRATION

5.1 TEAM_PLAYBOOK_v2
Implements the behavior contract for agents, defines roles, mode usage, and safety rules, and points back to this Governance Core as authority.

5.2 SESSION_START_v2
Defines how INIT and mode entry work at the beginning of every session. It loads last-known-state, confirms NEXT_TASK, and ensures agents are reading the correct governance files.

5.3 SESSION_END_OPTIONS
Defines procedures for ending sessions cleanly, including HANDOFF mode requirements and state preservation for continuity.

5.4 SELF_DIAGNOSTIC_FRAMEWORK
Defines error categories, root-cause patterns, and how agents should interpret and classify failures before attempting repair.

5.5 TROUBLESHOOTING_CHECKLIST
Provides concrete recovery steps and guardrails when known failures occur. It ties each failure mode to the relevant rule in this Core.

5.6 RECURRING_BLOCKERS
Captures known recurring obstacles and their prevention measures and ensures they are linked back to Execution Integrity rules and Governance Core sections.

6. CORE FAILURE MODES AND COUNTERMEASURES
Each common failure in Mosaic maps to a Core rule.

Examples:

- Using wrong directories or local-only paths: prevented by No Unverified Path and VERIFY mode.
- Reusing obsolete scripts or config: prevented by No Obsolete Code and INIT + VERIFY.
- Losing project boundaries and switching context: prevented by explicit project validation in INIT and by mode declarations.
- Rewriting working code due to misdiagnosis: prevented by DIAGNOSE before REPAIR and Stop on Ambiguity.

7. NEXT_TASK GOVERNANCE
NEXT_TASK is the single active objective for Mosaic.
NEXT_TASK MUST be:

- Explicit, testable, and scoped.
- Confirmed at session start.
- Updated only in HANDOFF mode.
- Used as the reference for deciding what to prioritize.
Agents MUST NOT invent or silently modify NEXT_TASK. Changes REQUIRE acknowledgment and alignment with the user.

8. CROSS-MODEL CONSISTENCY
All models (GPT, Claude, Gemini, and others) MUST follow the same rules. Provider differences do not change the obligations under this Governance Core.
Where behavior diverges across models, agents MUST fall back to the strictest interpretation of Execution Integrity and Stop on Ambiguity.

9. ESCALATION
Agents MUST escalate to the user or a designated Supervisor when:

- Governance rules conflict.
- Project identity or repo identity is unclear.
- Environment or deployment targets are unknown.
- Changes appear destructive beyond intended scope.
Escalation pauses further modifications until resolved.

10. VERSIONING
This document is Mosaic Governance Core v1.
Any update to this Core MUST be versioned and recorded. Subordinate governance files (TEAM_PLAYBOOK, SESSION_START, SESSION_END_OPTIONS, SELF_DIAGNOSTIC, TROUBLESHOOTING, RECURRING_BLOCKERS, API_MODE_GOVERNANCE_PROTOCOL) MUST be updated to stay consistent with the Core.

11. VALIDATED ARTIFACT GENERATION PROTOCOL (v1.2)
To ensure quality and provide a guarantee of transparency, all generated artifacts (code, scripts, commands, configuration) MUST be delivered using the following, non-skippable workflow.

11.1 Workflow

1. **Generate Artifact:** The agent generates the required artifact.
2. **Save to Temporary File:** The agent MUST save the artifact to a temporary file using the `write_file` tool. The filename MUST be descriptive of the artifact's purpose.
3. **Execute Validation:** The agent MUST execute a relevant, pre-existing validation script against the temporary file using the `run_shell_command` tool.
4. **Present Proof:** The agent MUST show the user the validation command that was run and its full, verbatim output.
5. **Analyze and Self-Heal:**
    - **On Failure:** If the validation script fails, the agent MUST analyze the failure, `write_file` a corrected version of the artifact to the temporary file, and re-run the validation. This loop continues until validation passes. The entire process MUST be shown to the user.
    - **On Success:** Once validation passes, the agent MUST present the final, validated artifact to the user, typically by reading from the temporary file.

12. Changelog

- v1.0 (2025-11-24): Initial Governance Core v2 system established
- v1.1 (2025-12-06): Added Section 2.1.1 (API Mode Requirements), Section 5.3 (SESSION_END_OPTIONS), Section 5.7 (API_MODE_GOVERNANCE_PROTOCOL)
- v1.2 (2025-12-11): Governance rewrite based on GOVERNANCE_FAILURE_ANALYSIS.md. Incorporated "No Guessing" rule.
- v1.3 (2025-12-11): Added Section 11, the "Validated Artifact Generation Protocol," to provide a transparent, auditable workflow for artifact delivery.
- v1.4 (2025-12-11): Governance documents updated to reflect mandatory agent directives.
- v1.5 (2025-12-12): Removed API Mode from mandatory INIT flow - relocated to appendix as emergency fallback only (user operates in claude.ai web interface exclusively)
