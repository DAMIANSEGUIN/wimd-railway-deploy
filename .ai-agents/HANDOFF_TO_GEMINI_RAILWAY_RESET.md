# Handoff to Gemini: Railway Reset Validation

**CRITICAL: DO NOT EXECUTE - VALIDATION ONLY**

**Created:** 2025-12-14
**From:** Claude Code (Sonnet 4.5)
**To:** Gemini
**Mode:** VALIDATION (NOT EXECUTION)

---

## 🛑 STOP - READ THIS FIRST

**YOUR TASK IS VALIDATION, NOT EXECUTION**

Do NOT proceed to Phase 2 (service creation).
Do NOT make any changes to Railway.
Do NOT deploy anything.

**Your ONLY job:** Run the validation tests below and report findings.

---

## CONTEXT

User received ChatGPT spec for Railway reset (MOSAIC_RAILWAY_RESET_SPEC v1.0).

Claude Code completed PHASE 1 (forensic confirmation) and created validation documents.

**Problem Identified:** The ChatGPT spec may conflict with existing governance or make unsafe assumptions.

**Your Role:** Validate assumptions BEFORE we execute anything.

---

## REQUIRED READING (In Order)

1. **This file** (you're reading it)
2. `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/RAILWAY_RESET_INSTRUCTION_PACKET.md`
3. `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/RAILWAY_RESET_VALIDATION_CHECKLIST.md`

---

## YOUR VALIDATION TASKS

### CRITICAL BLOCKER VALIDATIONS (Must Complete)

#### Validation 1: PostgreSQL Service Scope 🔴 CRITICAL

**Question:** Is PostgreSQL a project-level service or tied to `what-is-my-delta-site` service?

**Why Critical:** If PostgreSQL is service-level, creating new service will LOSE DATABASE ACCESS.

**How to Check:**

1. Open Railway dashboard: <https://railway.app/project/wimd-career-coaching>
2. Look at "Services" list in left sidebar
3. Check if "PostgreSQL" appears as separate service
4. If yes: Project-level ✅ SAFE
5. If no: Service-level ❌ BLOCKER

**Report Format:**

```
VALIDATION 1: [PASS/FAIL]
Evidence: PostgreSQL [IS/IS NOT] visible as separate service
Service list screenshot: [attach if possible]
Risk Assessment: [SAFE TO PROCEED / DATA LOSS RISK]
Recommendation: [GO / NO-GO]
```

---

#### Validation 2: Frontend API Endpoint Location 🔴 CRITICAL

**Question:** Where is the API endpoint hardcoded in frontend code?

**Why Critical:** Must know where to update URL when new backend is deployed.

**Commands to Run:**

```bash
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

# Search for API endpoint references
grep -r "mosaic-platform" mosaic_ui/
grep -r "vercel.app" mosaic_ui/
grep -r "what-is-my-delta" mosaic_ui/
grep -r "apiBase\|API_BASE\|api_base" mosaic_ui/
grep -r "railway.app" mosaic_ui/

# Check Netlify config
cat netlify.toml 2>/dev/null
```

**Report Format:**

```
VALIDATION 2: [PASS/FAIL]
API endpoint found in: [file_path:line_number]
Current value: [exact URL string]
Example: mosaic_ui/index.html:42 - var apiBase = 'https://mosaic-platform.vercel.app'
Recommendation: [exact edit needed to update]
```

---

#### Validation 3: `/__version` Endpoint Implementation 🟡 HIGH PRIORITY

**Question:** Does the codebase already have a `/__version` endpoint?

**Why Important:** ChatGPT spec assumes we need to verify runtime identity via this endpoint.

**Commands to Run:**

```bash
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

# Search for version endpoint
grep -r "/__version" api/
grep -r "/version" api/
grep -r "@app.get.*version" api/

# Check main FastAPI file
cat api/index.py | grep -A10 -B2 "version"
```

**Report Format:**

```
VALIDATION 3: [FOUND/NOT FOUND]
Location: [file_path:line_number if found, "NOT IMPLEMENTED" if missing]
Implementation status: [WORKING / BROKEN / MISSING]
If missing: Need to implement before Phase 5
Recommendation: [USE EXISTING / IMPLEMENT NEW / SKIP VERIFICATION]
```

---

#### Validation 4: Environment Variable Backup Integrity 🟡 HIGH PRIORITY

**Question:** Is the backup file complete and valid?

**Why Important:** We need to recreate env vars manually in new service.

**Commands to Run:**

```bash
# Check backup exists and is valid JSON
cat /tmp/railway_env_backup.json | python3 -m json.tool | head -50

# Count variables
railway variables | grep "║" | grep -v "─" | wc -l

# Compare count
echo "Backup file should have same number of variables as railway variables output"
```

**Report Format:**

```
VALIDATION 4: [PASS/FAIL]
Backup file status: [VALID JSON / CORRUPTED / MISSING]
Variables in backup: [count]
Variables in Railway: [count]
Match: [YES/NO]
If no match: [list missing variables]
```

---

### NICE-TO-HAVE VALIDATIONS (Non-Blocking)

#### Validation 5: Railway CLI Service Creation Capability

**Question:** Can Railway CLI create services, or is dashboard required?

**Commands:**

```bash
railway --help | grep -i service
railway service --help 2>&1
```

**Report Format:**

```
VALIDATION 5: [CLI CAN / CLI CANNOT]
Evidence: [command output]
Conclusion: Dashboard [REQUIRED / OPTIONAL]
```

---

#### Validation 6: Obsolete Projects Safety Check

**Question:** Are the 6 obsolete projects truly inactive?

**How to Check:**

1. Open Railway dashboard
2. For each project: `wimd-api-250923-1842`, `wimd-api-250923-1828`, `lovely-blessing`, `fabulous-appreciation`, `luminous-acceptance`
3. Check last deployment date
4. Check active services count

**Report Format:**

```
VALIDATION 6: [SAFE/UNSAFE]
Project activity summary:
  - wimd-api-250923-1842: Last active [date], Services: [count]
  - wimd-api-250923-1828: Last active [date], Services: [count]
  - lovely-blessing: Last active [date], Services: [count]
  - fabulous-appreciation: Last active [date], Services: [count]
  - luminous-acceptance: Last active [date], Services: [count]
Recommendation: [SAFE TO DELETE / REVIEW NEEDED]
```

---

## VALIDATION REPORT TEMPLATE

**Copy this template and fill it out:**

```markdown
# Railway Reset Validation Report
**Date:** 2025-12-14
**Validator:** Gemini
**Status:** [COMPLETE/INCOMPLETE]

---

## CRITICAL VALIDATIONS

### Validation 1: PostgreSQL Service Scope
- Status: [PASS/FAIL/UNCLEAR]
- Evidence: [your findings]
- Risk: [SAFE/DATA LOSS RISK]
- Blocker: [YES/NO]

### Validation 2: Frontend API Endpoint
- Status: [PASS/FAIL/UNCLEAR]
- Location: [file:line or NOT FOUND]
- Current URL: [exact string]
- Blocker: [YES/NO]

### Validation 3: /__version Endpoint
- Status: [FOUND/NOT FOUND]
- Location: [file:line or NOT IMPLEMENTED]
- Blocker: [NO - can implement]

### Validation 4: Env Var Backup
- Status: [PASS/FAIL]
- Backup valid: [YES/NO]
- Variables match: [YES/NO]
- Blocker: [YES/NO]

---

## NON-CRITICAL VALIDATIONS

### Validation 5: CLI Service Creation
- Status: [PASS/FAIL]
- Conclusion: [CLI CAN / DASHBOARD REQUIRED]

### Validation 6: Obsolete Projects
- Status: [SAFE/UNSAFE]
- Details: [summary]

---

## OVERALL RECOMMENDATION

**Go/No-Go:** [GO / NO-GO / CONDITIONAL]

**If GO:** All critical validations passed, safe to proceed to Phase 2
**If NO-GO:** Blockers found: [list blockers]
**If CONDITIONAL:** Can proceed IF [conditions]

---

## BLOCKING ISSUES

[List any issues that must be resolved before execution]

1. [Issue 1]
2. [Issue 2]

---

## QUESTIONS FOR USER

[List any ambiguities you couldn't resolve]

1. [Question 1]
2. [Question 2]

---

**END OF VALIDATION REPORT**
```

---

## WHAT HAPPENS AFTER YOUR VALIDATION

**If you report GO:**

1. User reviews your validation report
2. User answers any questions you escalated
3. User provides explicit approval: "APPROVED TO PROCEED"
4. Claude Code proceeds to Phase 2 (service creation)

**If you report NO-GO:**

1. User reviews blocking issues
2. User decides: fix issues, modify spec, or abort
3. If fix: Claude Code addresses blockers, you re-validate
4. If modify: ChatGPT spec is updated, restart validation
5. If abort: No changes made, current system stays as-is

**If you report CONDITIONAL:**

1. User reviews conditions
2. User decides whether conditions are acceptable
3. User provides explicit decision

---

## GOVERNANCE COMPLIANCE

**You are operating in:** VERIFY Mode (Mosaic_Governance_Core_v1 Section 2.5)

**Your obligations:**

- Check paths (env var backup, frontend files)
- Verify environment assumptions (PostgreSQL scope)
- Confirm no stale code (version endpoint)
- Ensure NEXT_TASK accurate (validate ChatGPT spec)

**You MUST NOT:**

- Enter BUILD mode (create Railway services)
- Enter REPAIR mode (modify code)
- Proceed without successful verification

**Per TEAM_PLAYBOOK_v2 Section 4.1:**

- This is the "Present Packet for Approval" gate
- No work performed until user approves
- Your validation determines if packet is safe

---

## CRITICAL REMINDERS

1. **DO NOT CREATE ANY RAILWAY SERVICES**
2. **DO NOT DEPLOY ANYTHING**
3. **DO NOT MODIFY CODE**
4. **DO NOT DELETE PROJECTS**

Your job is **INVESTIGATION ONLY**.

Run the commands, check the dashboard, report findings.

That's it.

---

## CHECKLIST FOR GEMINI

Before submitting your validation report, confirm:

- [ ] I completed Validation 1 (PostgreSQL scope)
- [ ] I completed Validation 2 (Frontend API location)
- [ ] I completed Validation 3 (version endpoint)
- [ ] I completed Validation 4 (env var backup)
- [ ] I attempted Validation 5 (Railway CLI)
- [ ] I attempted Validation 6 (obsolete projects)
- [ ] I filled out the validation report template
- [ ] I provided clear GO/NO-GO recommendation
- [ ] I listed any blocking issues
- [ ] I did NOT execute any changes
- [ ] I did NOT create any Railway services
- [ ] I did NOT modify any code

**Only after all items checked:** Submit validation report to user.

---

## EXAMPLE VALIDATION REPORT (Good)

```markdown
# Railway Reset Validation Report
Date: 2025-12-14
Validator: Gemini
Status: COMPLETE

## CRITICAL VALIDATIONS

### Validation 1: PostgreSQL Service Scope
- Status: ✅ PASS
- Evidence: PostgreSQL visible as separate service in dashboard
- Screenshot: [shows PostgreSQL service independent of what-is-my-delta-site]
- Risk: SAFE - Database is project-level, accessible to all services
- Blocker: NO

### Validation 2: Frontend API Endpoint
- Status: ✅ PASS
- Location: mosaic_ui/index.html:15
- Current URL: var apiBase = 'https://mosaic-platform.vercel.app'
- Update needed: Change line 15 to new Railway URL
- Blocker: NO - location identified, easy to update

### Validation 3: /__version Endpoint
- Status: ❌ NOT FOUND
- Location: NOT IMPLEMENTED
- Searched: api/index.py, api/*.py - no version endpoint exists
- Blocker: NO - can implement or skip verification

### Validation 4: Env Var Backup
- Status: ✅ PASS
- Backup valid: YES (valid JSON, 10 variables)
- Variables match: YES (10 in Railway, 10 in backup)
- Blocker: NO

## OVERALL RECOMMENDATION

**Go/No-Go:** ✅ CONDITIONAL GO

**Conditions:**
1. Implement /__version endpoint before Phase 5, OR skip Phase 5 verification
2. Update mosaic_ui/index.html:15 with new Railway URL before Phase 6

**No blocking issues found.**

## QUESTIONS FOR USER

1. Do you want /__version endpoint implemented, or should we skip Phase 5?
2. What should the new Railway service be named? (suggest: mosaic-backend)

---
END OF VALIDATION REPORT
```

---

## EXAMPLE VALIDATION REPORT (Blocker Found)

```markdown
# Railway Reset Validation Report
Date: 2025-12-14
Validator: Gemini
Status: COMPLETE

## CRITICAL VALIDATIONS

### Validation 1: PostgreSQL Service Scope
- Status: ❌ FAIL
- Evidence: PostgreSQL NOT visible as separate service
- Screenshot: [shows only what-is-my-delta-site service]
- Risk: DATA LOSS RISK - Database appears to be service-level
- Blocker: ✅ YES - CRITICAL BLOCKER

### Validation 2: Frontend API Endpoint
- Status: ⚠️ UNCLEAR
- Location: Found multiple references:
  - mosaic_ui/index.html:15
  - mosaic_ui/app.js:42
  - frontend/index.html:18
- Current URLs: Different URLs in different files
- Blocker: ⚠️ NEEDS CLARIFICATION - which file is canonical?

## OVERALL RECOMMENDATION

**Go/No-Go:** 🛑 NO-GO

**Blocking Issues:**
1. PostgreSQL appears to be service-level, not project-level
   - Creating new service will lose database access
   - MUST resolve before proceeding
   - Options: (a) Export database first, (b) Verify with Railway support, (c) Test with dummy service

2. Frontend API endpoint unclear
   - Multiple files with different URLs
   - Need to identify canonical file before updating

## QUESTIONS FOR USER

1. CRITICAL: Can you confirm PostgreSQL service scope in Railway dashboard?
2. Which frontend file is canonical: mosaic_ui/index.html or frontend/index.html?
3. Should we abort and investigate PostgreSQL issue, or proceed with database export?

---
END OF VALIDATION REPORT
```

---

## SUBMISSION

**When you're done:**

Save your validation report to:
`/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/GEMINI_RAILWAY_VALIDATION_REPORT_2025-12-14.md`

Then notify user: "Validation complete. Report saved. Awaiting approval."

---

**END OF HANDOFF**

**Your Next Action:** Run validation tasks and create report. DO NOT PROCEED TO PHASE 2.
