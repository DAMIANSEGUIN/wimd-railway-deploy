# Session Resume Prompt

**Copy-paste this to Claude Code to resume exactly where we left off**

**Last Updated:** 2025-12-15
**Status:** Railway Reset - Critical CLI Blocker - Awaiting User Intervention

---

## 🛑 IMMEDIATE CONTEXT

**Where We Are:**

- User received Railway reset spec from ChatGPT (MOSAIC_RAILWAY_RESET_SPEC v1.0)
- Claude Code completed PHASE 1 (forensic confirmation)
- Claude Code created validation handoff for Gemini
- **Critical Railway CLI linking ambiguity detected (see RAILWAY_CLI_AMBIGUITY_REPORT.md for details), blocking further CLI-based operations.**
- **HALTED at governance approval gate (TEAM_PLAYBOOK_v2 Section 4.1) and CLI functionality.**

**Critical State:**

- Railway deployment is BROKEN (wrong GitHub repo connected)
- Current service watches: `what-is-my-delta-site` (legacy repo)
- Development happens in: `wimd-railway-deploy` (26+ commits not deployed)
- PostgreSQL status: UNKNOWN (needs Gemini validation) - **Validation blocked by CLI ambiguity.**

---

## PROMPT FOR NEXT SESSION

```
Read this file: /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/SESSION_RESUME_PROMPT.md

Current task: Railway Reset (ChatGPT spec execution)

Your role: Resolve Railway CLI linking ambiguity, then proceed with Railway Reset validation.

CRITICAL: DO NOT proceed with validations or Phase 2 without:
1. Railway CLI linking ambiguity resolved.
2. User explicit approval.

Reference CLI ambiguity report: .ai-agents/RAILWAY_CLI_AMBIGUITY_REPORT.md
Reference version endpoint clarification: .ai-agents/VERSION_ENDPOINT_CLARIFICATION.md
```

---

## SESSION STATE

### ✅ COMPLETED

**Phase 1: Forensic Confirmation**

- Railway CLI scope verified: `wimd-career-coaching` project, `what-is-my-delta-site` service
- 7 Railway projects detected (6 obsolete)
- Git remotes confirmed: origin (active) vs railway-origin (legacy)
- Service status: 404 (not responding)
- Environment variables backed up: `/tmp/railway_env_backup.json`
- Repository divergence confirmed: 26+ commits not deployed

**Documentation Created:**

- ✅ `.ai-agents/RAILWAY_RESET_INSTRUCTION_PACKET.md` (governance-compliant pre-flight)
- ✅ `.ai-agents/HANDOFF_TO_GEMINI_RAILWAY_RESET.md` (validation tasks for Gemini)
- ✅ `.ai-agents/RAILWAY_RESET_VALIDATION_CHECKLIST.md` (comprehensive validation matrix)
- ⚠️ `.ai-agents/RAILWAY_RESET_PREPARATION.md` (over-engineered, may ignore)
- ✅ `.ai-agents/RAILWAY_CLI_AMBIGUITY_REPORT.md` (critical CLI issue)
- ✅ `.ai-agents/VERSION_ENDPOINT_CLARIFICATION.md` (clarification on /__version)

### ⏳ IN PROGRESS (BLOCKING)

**Primary Blocker:** Railway CLI linking ambiguity

- `railway list` sees `wimd-career-coaching`.
- `railway link -p "wimd-career-coaching"` reports "Project not found".
- This blocks all CLI-based operations within the correct project context.

**Gemini Validation Tasks (BLOCKED):**

- All 6 validation tasks are blocked by the above CLI ambiguity.

### ⏸️ PENDING (AWAITING APPROVAL)

**Phase 2-7 Execution:**

- Phase 2: Create new Railway service (dashboard action)
- Phase 3: Migrate environment variables
- Phase 4: Deploy via terminal
- Phase 5: Verify runtime identity
- Phase 6: Update frontend API endpoint
- Phase 7: Decommission legacy services

---

## BLOCKERS

### 🛑 CRITICAL BLOCKERS (Must Resolve Before Proceeding)

1. **Railway CLI Linking Ambiguity**
    - **Description:** `railway list` detects `wimd-career-coaching`, but `railway link -p "wimd-career-coaching"` fails ("Project not found").
    - **Impact:** Prevents CLI-based operations within the project, blocking Gemini's validation tasks and subsequent deployment phases.
    - **Resolution:** Requires user intervention to resolve the CLI linking issue (e.g., manual link via interactive CLI, investigation of duplicate projects, or user linking the project and handing back control).

2. **User Approval Missing**
    - User must review instruction packet.
    - User must answer open questions (service name, migration strategy).
    - User must provide explicit: "APPROVED TO PROCEED".

### ⚠️ MEDIUM BLOCKERS (Can Work Around - After CLI Resolved)

1. **Gemini Validation Report Missing**
    - Gemini must complete 6 validation tasks (currently blocked by CLI ambiguity).
    - Gemini must provide GO/NO-GO recommendation.

2. **PostgreSQL Scope Unknown**
    - If service-level: DATA LOSS RISK.
    - If project-level: SAFE to proceed.
    - Validation 1 must confirm before service creation (currently blocked by CLI ambiguity).

3. **Frontend API Location Unconfirmed**
    - Found at `mosaic_ui/index.html:1954`.
    - Needs Gemini confirmation (currently blocked by CLI ambiguity).
    - Can proceed with assumption if high confidence.

4. **Service Name Undecided**
    - ChatGPT spec doesn't specify.
    - Suggested: `mosaic-backend`.
    - User must decide before Phase 2.

---

## GOVERNANCE COMPLIANCE

**Current Mode:** DIAGNOSE (due to CLI ambiguity) -> HALTED.

**TEAM_PLAYBOOK_v2 Section 4.1 Compliance:**

- ✅ Step 1: State Capture (PHASE 1 complete, CLI ambiguity reported)
- ✅ Step 2: Context Synthesis (governance reviewed, new blocker identified)
- ✅ Step 3: Instruction Packet Generated (RAILWAY_RESET_INSTRUCTION_PACKET.md)
- ⏳ Step 4: **BLOCKING GATE** - Awaiting user intervention for CLI, then approval.
- ⏸️ Step 5: Generate and Validate (after CLI fixed and approval only)

**Mosaic_Governance_Core_v1 Section 3.5:**

- ✅ Stopped on ambiguity ("CLI linking ambiguity", "service identity tainted", "hidden inheritance")
- ✅ No unverified paths used (PostgreSQL scope validation required, but blocked)
- ✅ No hidden assumptions (documented all assumptions in validation checklist)

---

## CRITICAL FILES

**Must Read on Session Start:**

1. This file (SESSION_RESUME_PROMPT.md)
2. `.ai-agents/RAILWAY_CLI_AMBIGUITY_REPORT.md` (details critical CLI issue)
3. `.ai-agents/HANDOFF_TO_GEMINI_RAILWAY_RESET.md` (original validation tasks - currently blocked)
4. `.ai-agents/RAILWAY_RESET_INSTRUCTION_PACKET.md` (full execution plan)

**Reference (Optional):**

- `.ai-agents/RAILWAY_RESET_VALIDATION_CHECKLIST.md` (detailed validation matrix)
- `.ai-agents/VERSION_ENDPOINT_CLARIFICATION.md` (clarification on /__version)

**Ignore (Over-Engineered):**

- `.ai-agents/RAILWAY_RESET_PREPARATION.md` (too complex, created during instability)

---

## QUICK REFERENCE

**Working Directory:**

```
/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
```

**Current Git State:**

```
HEAD: 684dad3 (Dec 14)
Branch: main
Remote origin: wimd-railway-deploy (correct repo)
Remote railway-origin: what-is-my-delta-site (legacy, wrong repo)
```

**Railway State:**

```
Project: wimd-career-coaching
Service: what-is-my-delta-site (404, not responding)
PostgreSQL: Unknown scope (awaiting validation - BLOCKED by CLI ambiguity)
Env vars backup: /tmp/railway_env_backup.json (10 variables)
```

**Deployment Issue:**

```
Railway watches: what-is-my-delta-site repo (wrong)
Should watch: wimd-railway-deploy repo (correct)
Commits not deployed: 26+ (since Nov 11)
```

---

## NEXT ACTIONS (IN ORDER)

### For Claude Code (You)

**If restarting fresh session:**

1. Read this file completely.
2. Address the Railway CLI linking ambiguity first (see `CRITICAL BLOCKERS` above).
3. **DO NOT proceed with validations or Phase 2 until the CLI ambiguity is resolved and user approval is received.**

**After CLI ambiguity resolved AND user approval received:**

1. Proceed with Gemini validation tasks as per `HANDOFF_TO_GEMINI_RAILWAY_RESET.md`.
2. Execute Phase 2-7 per `RAILWAY_RESET_INSTRUCTION_PACKET.md`.
3. Update this file with progress.
4. Mark phases complete in todo list.

### For Gemini

**Task:** Currently blocked by Railway CLI linking ambiguity. Awaiting user intervention to resolve CLI.

### For User

**Waiting on you for:**

1. **CRITICAL:** Resolve the Railway CLI linking ambiguity. This might involve:
    - Manually linking the project using the interactive `railway link` command (`railway link`).
    - Investigating if a duplicate project entry in `railway list` is causing the issue.
    - Linking the project and then handing control back to me (Gemini).
2. Review Gemini's validation report when ready (after CLI fixed).
3. Answer questions (service name, migration strategy, PostgreSQL risk).
4. Provide explicit approval: "APPROVED TO PROCEED".

---

## OPEN QUESTIONS (USER MUST ANSWER)

1. **CRITICAL:** How should the Railway CLI linking ambiguity be resolved?
    - Confirm if you can manually link the `wimd-career-coaching` project.
    - Confirm if there are any duplicate entries in `railway list` that might interfere.
2. **Service Name:** What should the new canonical Railway service be named?
    - Suggestion: `mosaic-backend`
    - Alternative: Keep `what-is-my-delta-site` (delete old one first)
3. **Migration Strategy:** Gradual or clean-slate?
    - Gradual: Run both services until new is verified, then switch
    - Clean-slate: Delete old immediately after new is created
4. **PostgreSQL Risk:** How to handle if validation shows service-level scope?
    - Conservative: Export database before creating service
    - Moderate: Verify with Railway support first
    - Aggressive: Create service and test DATABASE_URL access live
5. **Spec Ambiguities:** What do these mean?
    - "Service identity tainted" - what technical property?
    - "Hidden inheritance" - what mechanism?

---

## WHAT WENT RIGHT THIS SESSION

1. ✅ Followed governance (halted at primary blocker)
2. ✅ Created clear handoff for Gemini (explicitly highlighting new blocker)
3. ✅ Backed up critical data (env vars)
4. ✅ Identified deployment root cause (wrong repo connection)
5. ✅ Discovered and reported critical Railway CLI linking ambiguity, preventing wasted effort.

## WHAT WENT WRONG THIS SESSION

1. ❌ Entered an unproductive loop waiting for previous validation inputs, due to an undiscovered primary blocker.
2. ❌ My initial validation plan was rendered moot by the CLI ambiguity, indicating a need for more comprehensive initial diagnostic steps before planning validations.

## LESSONS FOR NEXT SESSION

1. **Prioritize diagnosis of CLI/tooling issues first, even before starting validations.**
2. **STOP when a critical tooling ambiguity is identified.**
3. **Focus on resolving the most fundamental blockers before proceeding with dependent tasks.**
4. **Assume nothing about CLI functionality; always verify critical commands.**

---

## CRITICAL REMINDERS

### For Claude Code

- 🛑 **DO NOT** create new Railway services without approval
- 🛑 **DO NOT** deploy anything without approval
- 🛑 **DO NOT** modify code without approval
- 🛑 **DO NOT** proceed to Phase 2 until **CLI linking ambiguity resolved** and both gates clear:
  - ✅ Gemini validation report complete (GO recommendation - after CLI fixed)
  - ✅ User explicit approval received

### For Gemini

- ✅ **DO** await user intervention to resolve CLI linking ambiguity.
- ✅ **DO** run all 6 validation tests *after* CLI linking is resolved.
- ✅ **DO** provide GO/NO-GO recommendation *after* validations.
- ✅ **DO** escalate blocking issues to user.
- 🛑 **DO NOT** execute Phase 2 or any deployment actions.
- 🛑 **DO NOT** proceed with validations until CLI linking is resolved.

### For User

- You control the approval gate AND the resolution of the CLI blocker.
- Both agents are blocked until you resolve the CLI issue and approve.
- Gemini's report will help you make informed decisions, but it is currently blocked.
- You can modify spec, abort, or approve as-is.

---

**END OF SESSION RESUME PROMPT**

**Status:** Railway Reset - Critical CLI Blocker - Awaiting User Intervention
**Next Session:** Read this file, resolve CLI ambiguity, then proceed with Railway Reset.
**Governance:** Halted at TEAM_PLAYBOOK_v2 Section 4.1 approval gate due to CLI ambiguity.
