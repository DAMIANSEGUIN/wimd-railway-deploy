# Mosaic Governance Core v1
Unified Top-Layer Spec for All Mosaic Agents

**Document Metadata:**
- Created: 2025-11-24 by Claude Code
- Last Updated: 2025-12-06 by Claude Code
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE

1. PURPOSE
Mosaic Governance Core defines enforceable, non-negotiable behavioral and execution rules for all AI agents (GPT, Claude, Gemini, and others) working on Mosaic. It exists to prevent drift, hallucination, unsafe code, and loss of continuity across sessions and tools.
The Core ensures alignment, consistency, safety, execution integrity, and continuity. All other governance documents (TEAM_PLAYBOOK_v2, SESSION_START_v2, SELF_DIAGNOSTIC_FRAMEWORK, TROUBLESHOOTING_CHECKLIST, RECURRING_BLOCKERS) inherit from this Core.

2. GLOBAL MODES (STATE MACHINE)
Every Mosaic session and agent MUST operate in exactly one of these modes at a time.

2.1 INIT Mode
Purpose: restore context and load the governance environment.
Allowed actions: load last-known-state, read NEXT_TASK, validate the active project and repository, detect cross-project contamination, read Tier-1 documents, confirm mode.
Prohibited actions: any code generation, file modifications, or deployment actions.

2.1.1 API Mode Requirements (Added 2025-12-06)
When operating in API mode (Claude Code CLI, ChatGPT API, or similar terminal-based tools with local filesystem access), agents MUST execute additional initialization procedures to prevent context loss and protocol drift:
- Detect and declare API mode explicitly
- Load ALL Tier-1 governance files from disk (Mosaic_Governance_Core_v1.md, TEAM_PLAYBOOK_v2.md, SESSION_START_v2.md, SESSION_END_OPTIONS.md)
- Initialize token usage tracking and cost monitoring
- Load project state from files, never from conversation memory
- Reference: See API_MODE_GOVERNANCE_PROTOCOL.md for complete 7-step initialization procedure
- Rationale: API sessions do not persist context between terminal closures (documented issue: GitHub anthropics/claude-code#2954)

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
Agents MUST NOT use a directory or file path until it has been explicitly verified or confirmed by repository inspection or known context. Unverified paths require a question to the user or a verification step.

3.2 No Obsolete Code
Agents MUST compare proposed edits against the current live version of files and MUST treat unknown or legacy fragments as suspicious. They MUST NOT rely on remembered or speculative versions.

3.3 No Ghost Fragments
If agents encounter unexplained variables, unused functions, orphaned config, or mismatched environment blocks, they MUST flag these as potential ghost fragments and ask whether cleanup, archival, or removal is required before building on them.

3.4 No Hidden Assumptions
Agents MUST NOT assume language versions, package versions, environment variables, endpoints, deployment targets, or directory layouts without explicit validation in the session.

3.5 Stop on Ambiguity
Whenever an agent is uncertain about scope, constraints, state, or environment, it MUST stop and ask clarifying questions before proceeding. Continuing under ambiguity is prohibited.

4. MODEL-BEHAVIOR CONTRACT
All models working on Mosaic MUST:
- Declare their current mode before doing any non-trivial work.
- Restate user instructions and NEXT_TASK at the beginning of the session.
- Confirm which project and repo they are operating on.
- Operate within TEAM_PLAYBOOK_v2 and this Governance Core.
- Document uncertainty instead of silently guessing.
- Refuse to perform actions that violate the Execution Integrity rules.

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

5.7 API_MODE_GOVERNANCE_PROTOCOL (Added 2025-12-06)
Defines mandatory procedures for operating in API mode, including environment detection, token tracking, mode switching protocols, and proactive session boundary management. Prevents context loss and protocol drift when switching between web interface and API environments.

6. CORE FAILURE MODES AND COUNTERMEASURES
Each common failure in Mosaic maps to a Core rule.

Examples:
- Using wrong directories or local-only paths: prevented by No Unverified Path and VERIFY mode.
- Reusing obsolete scripts or config: prevented by No Obsolete Code and INIT + VERIFY.
- Losing project boundaries and switching context: prevented by explicit project validation in INIT and by mode declarations.
- Rewriting working code due to misdiagnosis: prevented by DIAGNOSE before REPAIR and Stop on Ambiguity.

7. NEXT_TASK GOVERNANCE
NEXT_TASK is the single active objective for Mosaic.
It MUST be:
- Explicit, testable, and scoped.
- Confirmed at session start.
- Updated only in HANDOFF mode.
- Used as the reference for deciding what to prioritize.
Agents MUST NOT invent or silently modify NEXT_TASK. Changes require acknowledgment and alignment with the user.

8. CROSS-MODEL CONSISTENCY
All models (GPT, Claude, Gemini, and others) must follow the same rules. Provider differences do not change the obligations under this Governance Core.
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

10.1 Changelog
- v1.0 (2025-11-24): Initial Governance Core v2 system established
- v1.1 (2025-12-06): Added Section 2.1.1 (API Mode Requirements), Section 5.3 (SESSION_END_OPTIONS), Section 5.7 (API_MODE_GOVERNANCE_PROTOCOL)
