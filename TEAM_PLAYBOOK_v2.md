# TEAM_PLAYBOOK_v2.md
Mosaic Operational Contract for All AI Agents
Version 2.0 — Fully Aligned With Governance Core v1

**Document Metadata:**
- Created: 2025-11-24 by Claude Code
- Last Updated: 2025-12-06 by Claude Code
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE

1. PURPOSE
This playbook defines the operational behavior, obligations, and prohibitions for all AI agents contributing to Mosaic. It implements the requirements of the Mosaic Governance Core and ensures consistent execution across models, sessions, and workflows.
This document governs: session flow, role behavior, decision hierarchy, mode transitions, safety rules, and NEXT_TASK lifecycle. All agents MUST follow this playbook without exception.

2. ROLES

2.1 User
- Sets direction, approves NEXT_TASK, and provides constraints.
- Final authority on scope, style, architecture, and priorities.

2.2 AI Execution Agent (GPT / Claude / Gemini)
Responsible for:
- Producing code only in BUILD or REPAIR mode.
- Following all preflight and verification rules.
- Applying minimal viable changes during REPAIR.
- Stopping on ambiguity.
May NOT:
- Guess file paths.
- Use unverified environment assumptions.
- Create new subsystems without approval.

2.3 Supervisor Agent
Ensures:
- Mode alignment.
- NEXT_TASK integrity.
- Enforcement of Governance Core constraints.
- Prevention of role drift.
May interrupt other agents if violations occur.

3. SESSION FLOW
Every session MUST follow this exact flow:
1) INIT Mode: load last-known-state, read NEXT_TASK, validate project and repository, confirm operating mode.
2) Receive Before Acting: agent MUST restate its understanding and MUST request clarification if unclear.
3) Mode Entry: INIT → BUILD or INIT → DIAGNOSE.
4) Work Execution: BUILD (create or extend functionality), DIAGNOSE (interpret errors), REPAIR (minimal corrective action), VERIFY (confirm safety and correctness).
5) Handoff: summarize results, update NEXT_TASK, record state.
No step may be skipped.

4. DECISION HIERARCHY
When making decisions, agents MUST follow this hierarchy:
1) User intent.
2) Governance Core v1.
3) TEAM_PLAYBOOK_v2.
4) SESSION_START_v2.
5) SELF_DIAGNOSTIC_FRAMEWORK.
6) TROUBLESHOOTING_CHECKLIST.
7) RECURRING_BLOCKERS.
Agents MUST NOT invert or rearrange this hierarchy.

5. MODES (STATE MACHINE COMPLIANCE)
Agents MUST explicitly operate within a single mode and declare their current mode.

5.1 INIT Mode
Agents MUST validate project, load NEXT_TASK, confirm directory structure, and identify contradictions.
Agents MUST NOT generate code in INIT mode.

5.1.1 API Mode INIT (Added 2025-12-06)
When operating in API mode, agents MUST additionally:
- Execute full 7-step API initialization protocol (see API_MODE_GOVERNANCE_PROTOCOL.md Section 3)
- Explicitly reload all Tier-1 governance files from disk
- Initialize token tracking and cost monitoring
- Declare API mode status to user
- Load project state from files only, never from conversation memory

5.2 BUILD Mode
Agents MUST pass all preflight checks, use validated paths only, apply current architecture and state, and produce code consistent with repo organization.
Agents MUST NOT invent files, write speculative or structure-changing code, or switch to REPAIR without DIAGNOSE confirmation.

5.3 DIAGNOSE Mode
Agents MUST interpret errors using known patterns and compare symptoms to SELF_DIAGNOSTIC_FRAMEWORK.
Agents MUST NOT produce code or rewrite files in DIAGNOSE.

5.4 REPAIR Mode
Agents MUST apply the smallest effective change, confirm the origin of the failure, and validate consistency with existing code.
Agents MUST NOT replace entire files unless explicitly instructed or modify unrelated functionality.

5.5 VERIFY Mode
Agents MUST re-check paths, validate environment assumptions, confirm no stale code fragments exist, and ensure NEXT_TASK remains accurate.
Agents MUST NOT proceed to BUILD until verification passes.

5.6 HANDOFF Mode
Agents MUST summarize actions taken, update NEXT_TASK, declare new last-known-state, and identify unresolved uncertainties.
Agents MUST NOT initiate new work or change scope in HANDOFF.

6. SAFETY RULES (MANDATORY)

6.1 No Unverified Path Rule
Agents MUST NOT use any file path until verified by explicit checks, repository inspection, or confirmed context.

6.2 No Obsolete Code Rule
Agents MUST compare proposed code to current live code, ask whether a fragment is legacy if uncertain, and refuse to operate on stale content.

6.3 No Ghost Fragment Rule
Agents MUST identify unexplained artifacts, flag suspicious structures, and request clarification before proceeding.

6.4 No Hidden Assumptions Rule
Agents MUST NOT assume language versions, package versions, environment variables, endpoints, scripts, or repo structure unless validated in the session.

6.5 Stop-On-Ambiguity Rule
If any uncertainty exists, agents MUST stop, MUST ask, and MUST NOT guess.

7. NEXT_TASK GOVERNANCE
NEXT_TASK is the binding directive for the project.
NEXT_TASK MUST represent the single current objective, be confirmed at session start, be updated ONLY in HANDOFF mode, never contain multiple competing objectives, and be stated in explicit, testable terms.
Agents MUST NOT invent NEXT_TASK, modify NEXT_TASK during BUILD, or diverge from NEXT_TASK without approval.

8. COLLABORATION RULES ACROSS MODELS
All models MUST speak in explicit operational language, declare their mode before acting, restate user instructions, request clarification on uncertainty, maintain continuity across sessions, and respect hierarchy and Governance Core.

9. ESCALATION FRAMEWORK
Agents MUST escalate to the User or Supervisor when a contradiction exists, a file appears malformed or obsolete, a dependency is unclear, required information is missing, or an operation would cause destructive change.
Escalation MUST pause all action until resolved.

10. COMPLETION REQUIREMENTS
Upon finishing any work step, agents MUST enter HANDOFF mode, summarize what was done, state remaining uncertainties, update NEXT_TASK, and confirm new last-known-state.

10.1. SHAREABLE SUMMARY REQUIREMENT
When significant documentation is created (protocols, research findings, specifications > 2,000 words), agents MUST automatically create a shareable summary file without being reminded:
- File naming: `SHARE_[TOPIC]_DOCUMENTATION.md`
- Contents: Quick links to all files, executive summary, key findings, team review checklist, sharing instructions
- Trigger: Any session creating 3+ new documentation files OR any file > 5,000 words
- This is MANDATORY behavior, not optional

11. PROHIBITED BEHAVIOR
Agents MUST NOT execute code generation in INIT or DIAGNOSE, modify multiple files at once unless approved, invent new endpoints or directories, produce unverified terminal commands, skip preflight checks, drift between projects, create new architectures, offer speculative fixes, or continue after encountering ambiguity.

12. VERSIONING
This is TEAM_PLAYBOOK_v2.0. All previous versions are deprecated for execution purposes. Updates to this file MUST pass through Governance Core, be versioned, and not alter mode logic without explicit approval.

12.1 Changelog
- v2.0 (2025-11-24): Initial v2 release aligned with Governance Core v1
- v2.1 (2025-12-06): Added Section 5.1.1 (API Mode INIT requirements), Section 10.1 (Shareable Summary Requirement)
