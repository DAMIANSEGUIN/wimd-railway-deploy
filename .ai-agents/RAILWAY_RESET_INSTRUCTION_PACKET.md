# Render Reset Instruction Packet

**Pre-Flight Protocol Compliance (TEAM_PLAYBOOK_v2 Section 4.1)**

**Created:** 2025-12-14
**Agent:** Claude Code (Sonnet 4.5)
**Mode:** INIT → BUILD (pending approval)
**Source Spec:** ChatGPT MOSAIC_RAILWAY_RESET_SPEC v1.0

---

## 1. TASK OBJECTIVE

**Primary Goal:** Establish single canonical Render service connected to correct GitHub repository

**Specific Outcomes:**

1. New Render service created pointing to `wimd-render-deploy` repo
2. Environment variables migrated intentionally (not blindly)
3. Service responds with verifiable runtime identity (`/__version` endpoint)
4. Frontend reconnected to new backend API
5. Legacy services decommissioned safely

---

## 2. STATE SUMMARY (Captured via PHASE 1 Forensic Confirmation)

### Current Render State

```yaml
projects_total: 7
  - wimd-career-coaching (canonical candidate)
  - wimd-career-coaching (duplicate entry)
  - wimd-api-250923-1842 (obsolete)
  - wimd-api-250923-1828 (obsolete)
  - lovely-blessing (obsolete)
  - fabulous-appreciation (obsolete)
  - luminous-acceptance (obsolete)

current_service:
  project: wimd-career-coaching
  service: what-is-my-delta-site
  environment: production
  status: not_responding (404)
  connected_repo: DAMIANSEGUIN/what-is-my-delta-site (WRONG)

desired_repo: DAMIANSEGUIN/wimd-render-deploy
```

### Git State

```yaml
remotes:
  origin: https://github.com/DAMIANSEGUIN/wimd-render-deploy.git (✅ active dev)
  render-origin: https://github.com/DAMIANSEGUIN/what-is-my-delta-site.git (❌ legacy)

divergence:
  legacy_repo_head: 623cbd5 (Nov 11)
  active_repo_head: 684dad3 (Dec 14)
  commits_behind: 26+
```

### Environment Variables (9 total)

```yaml
captured: /tmp/render_env_backup.json
variables:
  - APP_SCHEMA_VERSION: v2
  - CLAUDE_API_KEY: [REDACTED]
  - COACH_EMAIL: damian.seguin@gmail.com
  - COACH_GOOGLE_CALENDAR_ID: primary
  - DATABASE_URL: postgresql://...@postgres.render.internal:5432/render
  - GOOGLE_SERVICE_ACCOUNT_KEY: [JSON]
  - OPENAI_API_KEY: [REDACTED]
  - PAYPAL_CLIENT_ID: [REDACTED]
  - PAYPAL_CLIENT_SECRET: [REDACTED]
  - PAYPAL_MODE: live
```

### Frontend State

```yaml
provider: Netlify
status: live (✅ responding)
current_api: mosaic-platform.vercel.app (hardcoded, legacy)
needs_update: yes
```

---

## 3. APPLICABLE PROTOCOLS

### 3.1 Mosaic Governance Core v1 Compliance

**Current Mode:** INIT → BUILD (transition pending approval)

**Section 2.2 BUILD Mode Requirements:**

- [x] INIT completed (PHASE 1 forensic confirmation done)
- [ ] **Preflight checks passed** (THIS DOCUMENT)
- [ ] **Environment validated** (requires Gemini validation)
- [x] Repository structure confirmed (`git remote -v`)
- [ ] **NEXT_TASK clear and confirmed** (requires user approval)

**Section 3.1 No Unverified Path:**

- Status: ⚠️ UNVERIFIED - PostgreSQL service scope unknown
- Action: Must verify DATABASE_URL is project-level before proceeding

**Section 3.4 No Hidden Assumptions:**

- Assumption 1: PostgreSQL is project-level → ⚠️ REQUIRES VALIDATION
- Assumption 2: Env vars are service-specific → ⚠️ REQUIRES VALIDATION
- Assumption 3: Frontend API is hardcoded → ⚠️ REQUIRES CODE INSPECTION

**Section 3.5 Stop on Ambiguity:**

- **AMBIGUITY DETECTED:** "Service identity tainted" - unclear technical meaning
- **AMBIGUITY DETECTED:** "Hidden inheritance" - undefined mechanism
- **ACTION:** Halting for clarification per governance requirement

### 3.2 TEAM_PLAYBOOK_v2 Compliance

**Section 4.1 Pre-Flight Instruction Protocol:**

- [x] Step 1: State Capture (PHASE 1 completed)
- [x] Step 2: Context Synthesis (governance reviewed)
- [x] Step 3: Instruction Packet Generation (THIS DOCUMENT)
- [ ] **Step 4: Present for Approval** (BLOCKING GATE)
- [ ] Step 5: Generate and Validate (after approval only)

**Section 5 Decision Hierarchy:**

1. ENGINEERING_PRINCIPLES.md - Not consulted yet (⚠️ TODO)
2. User Intent - Stated via ChatGPT spec
3. Mosaic_Governance_Core_v1.md - Reviewed (✅)
4. TEAM_PLAYBOOK_v2.md - Reviewed (✅)

**Hierarchy Violation Risk:** ChatGPT spec may contradict governance if not validated

### 3.3 CODE_GOVERNANCE_STANDARD_v1 Compliance

**Section 2 Scope:**

- Render deployment is NOT code change
- Pre-commit hooks NOT applicable to infrastructure work
- ✅ No code governance violations expected

---

## 4. SUCCESS CRITERIA

### Validation Phase (Pre-Execution)

- [ ] PostgreSQL confirmed as project-level service (not service-specific)
- [ ] DATABASE_URL accessible from new service verified
- [ ] Environment variable inheritance behavior documented
- [ ] Frontend API endpoint location identified in codebase
- [ ] `/__version` endpoint implementation requirement confirmed
- [ ] All governance ambiguities resolved
- [ ] User approves instruction packet

### Execution Phase (Post-Approval)

- [ ] New service created in Render dashboard
- [ ] Service connected to `wimd-render-deploy` repo
- [ ] Environment variables recreated intentionally (all 9+)
- [ ] First deployment succeeds via `render up`
- [ ] `/__version` endpoint returns valid response
- [ ] Frontend updated to point to new backend
- [ ] Frontend deployment succeeds
- [ ] End-to-end test passes (frontend → backend → database)
- [ ] Legacy services archived/deleted safely

### Verification Phase (Runtime)

- [ ] Health endpoint returns 200 OK
- [ ] `/__version` matches deployed git SHA
- [ ] PostgreSQL queries succeed from new service
- [ ] Frontend makes successful API calls to new backend
- [ ] No 404 or 500 errors in logs
- [ ] Render auto-deploy triggers on git push

---

## 5. FAILURE MODES

### High-Severity Failures (System Down)

**FM-1: PostgreSQL Access Loss**

- **Symptom:** DATABASE_URL not accessible from new service
- **Root Cause:** PostgreSQL is service-level, not project-level
- **Prevention:** Validate PostgreSQL scope BEFORE creating new service
- **Mitigation:** Export database, create new PostgreSQL service, import data
- **Rollback:** Cannot rollback - requires data migration

**FM-2: Environment Variable Loss**

- **Symptom:** New service missing critical env vars
- **Root Cause:** Variables not inherited, manual recreation incomplete
- **Prevention:** Backup completed (`/tmp/render_env_backup.json`)
- **Mitigation:** Restore from backup file
- **Rollback:** Re-enter variables manually (reversible)

**FM-3: Frontend Disconnection**

- **Symptom:** Frontend gets 404 from backend
- **Root Cause:** API URL not updated in frontend code
- **Prevention:** Identify and update API endpoint BEFORE deploying frontend
- **Mitigation:** Redeploy frontend with corrected URL
- **Rollback:** Revert frontend deployment (reversible)

### Medium-Severity Failures (Degraded Service)

**FM-4: Deployment Timeout**

- **Symptom:** `render up` hangs or times out
- **Root Cause:** Build failure, missing dependencies, syntax error
- **Prevention:** Test build locally first (`render up --detach`)
- **Mitigation:** Check Render logs, fix build issue, redeploy
- **Rollback:** Delete new service, use old service temporarily

**FM-5: Runtime Identity Missing**

- **Symptom:** `/__version` endpoint returns 404
- **Root Cause:** Endpoint not implemented in codebase
- **Prevention:** Check codebase for endpoint BEFORE expecting it
- **Mitigation:** Add endpoint implementation, redeploy
- **Rollback:** Continue without version endpoint (non-critical feature)

### Low-Severity Failures (Operational Issues)

**FM-6: Legacy Service Deletion Error**

- **Symptom:** Cannot delete obsolete project
- **Root Cause:** Active resources or dependencies
- **Prevention:** Check project status before deletion
- **Mitigation:** Archive instead of delete, resolve dependencies
- **Rollback:** Deleted projects cannot be restored (prevention critical)

---

## 6. GOVERNANCE ALIGNMENT ANALYSIS

### ChatGPT Spec vs Mosaic Governance Core

| ChatGPT Spec Section | Governance Core Requirement | Alignment | Action |
|---------------------|----------------------------|-----------|--------|
| Phase 1: Forensic Confirmation | Section 2.1 INIT Mode | ✅ ALIGNED | Completed |
| Phase 2: Service Declaration | Section 2.2 BUILD Mode | ⚠️ REQUIRES APPROVAL | Present packet to user |
| "No action without clear service scope" | Section 3.1 No Unverified Path | ✅ ALIGNED | Verify PostgreSQL scope |
| "Fail fast on ambiguity" | Section 3.5 Stop on Ambiguity | ✅ ALIGNED | Clarify "tainted identity" |
| "Never preserve unknown state" | Section 3.3 No Ghost Fragments | ✅ ALIGNED | Intentional env var recreation |
| "Terminal is primary authority" | Section 4 Model-Behavior Contract | ✅ ALIGNED | Use CLI over dashboard |
| "Runtime is authoritative over UI" | Section 2.5 VERIFY Mode | ✅ ALIGNED | `/__version` verification |

### Conflicts Detected

**Conflict 1: Dashboard Requirement**

- **ChatGPT Spec:** "requires_dashboard: true" for service creation
- **Governance Core:** Section 2.2 prohibits "guessing paths" but doesn't prohibit dashboard use
- **Resolution:** ✅ NO CONFLICT - Dashboard is acceptable for service creation

**Conflict 2: Preflight Approval Gate**

- **ChatGPT Spec:** Proceeds to execution after Phase 1
- **Governance Core:** Section 4.1 requires user approval before generating artifacts
- **Resolution:** ⚠️ BLOCKING - Must get user approval for instruction packet (THIS DOCUMENT)

**Conflict 3: Mode Declaration**

- **ChatGPT Spec:** No explicit mode declaration
- **Governance Core:** Section 4 requires agents to "Declare their current mode"
- **Resolution:** ✅ RESOLVED - Mode declared as "INIT → BUILD (pending approval)"

---

## 7. REQUIRED VALIDATIONS (Gemini Tasks)

### Critical Path Validations (Must Pass)

**Validation 1: PostgreSQL Service Scope**

```bash
# Check Render dashboard: Project Settings → Services
# Expected: PostgreSQL appears as separate service (project-level)
# Risk: If service-level, data will be inaccessible from new service
```

**Status:** ⚠️ NOT VALIDATED
**Blocker:** YES - Cannot proceed without confirmation

**Validation 2: Environment Variable Inheritance**

```bash
# Test creating dummy service and checking if vars inherit
# Expected: Variables are service-specific (not inherited)
# Risk: If inherited, may expose secrets to wrong services
```

**Status:** ⚠️ NOT VALIDATED
**Blocker:** NO - Backup exists, can recreate manually

**Validation 3: Frontend API Endpoint Location**

```bash
# Search codebase for API endpoint references
grep -r "mosaic-platform" /Users/damianseguin/WIMD-Deploy-Project/mosaic_ui/
grep -r "apiBase\|API_BASE\|api_base" /Users/damianseguin/WIMD-Deploy-Project/mosaic_ui/
```

**Status:** ⚠️ NOT VALIDATED
**Blocker:** YES - Must know where to update API URL

**Validation 4: `/__version` Endpoint Implementation**

```bash
# Search codebase for existing version endpoint
grep -r "/__version\|/version" /Users/damianseguin/WIMD-Deploy-Project/api/
cat /Users/damianseguin/WIMD-Deploy-Project/api/index.py | grep -i version
```

**Status:** ⚠️ NOT VALIDATED
**Blocker:** NO - Can implement if missing

### Nice-to-Have Validations (Non-Blocking)

**Validation 5: Render CLI Service Creation**

```bash
render --help | grep -i "service"
render service --help | grep -i "create\|new"
```

**Expected:** No CLI command for service creation (dashboard required)
**Status:** ⚠️ NOT VALIDATED
**Blocker:** NO - Spec already assumes dashboard required

**Validation 6: Obsolete Projects Activity**

```bash
# Check Render dashboard for each obsolete project:
# - Last deployment date
# - Active services count
# - Recent logs/activity
```

**Expected:** No activity in past 30+ days
**Status:** ⚠️ NOT VALIDATED
**Blocker:** NO - Can skip deletion if uncertain

---

## 8. APPROVAL GATE

**This instruction packet SHALL NOT proceed to execution until:**

### User Approval Required

- [ ] User confirms understanding of success criteria
- [ ] User approves failure modes and rollback plans
- [ ] User acknowledges governance compliance requirements
- [ ] User provides clarification on spec ambiguities:
  - [ ] What does "service identity tainted" mean technically?
  - [ ] What should new canonical service be named?
  - [ ] Should `what-is-my-delta-site` be preserved or deleted?
  - [ ] Is gradual migration acceptable, or clean-slate required?

### Gemini Validation Required

- [ ] Gemini completes Validation 1 (PostgreSQL scope) - ✅ PASS / ❌ FAIL
- [ ] Gemini completes Validation 2 (env var inheritance) - ✅ PASS / ❌ FAIL
- [ ] Gemini completes Validation 3 (frontend API location) - ✅ PASS / ❌ FAIL
- [ ] Gemini completes Validation 4 (`/__version` endpoint) - ✅ PASS / ❌ FAIL
- [ ] Gemini provides Go/No-Go recommendation

### Governance Compliance Required

- [x] TEAM_PLAYBOOK_v2 Section 4.1 Pre-Flight Protocol followed
- [x] Mosaic_Governance_Core_v1 Section 3.5 Stop on Ambiguity respected
- [ ] User approval obtained (BLOCKING)
- [ ] All critical validations passed (BLOCKING)

---

## 9. EXECUTION SEQUENCE (Post-Approval)

**Only execute after all approval gates passed:**

### Phase 2: Service Creation (Dashboard)

```markdown
1. Open Render dashboard: https://render.app/project/wimd-career-coaching
2. Click "New Service"
3. Select "GitHub Repo"
4. Choose: DAMIANSEGUIN/wimd-render-deploy
5. Branch: main
6. Root directory: / (or as specified by user)
7. Service name: [USER TO SPECIFY]
8. Confirm creation
```

### Phase 3: Environment Rehydration (Terminal)

```bash
# Restore environment variables from backup
cat /tmp/render_env_backup.json | while read line; do
  # Manual recreation required - Render CLI doesn't support bulk import
  render variables set KEY=VALUE --service [NEW_SERVICE_NAME]
done
```

### Phase 4: Deployment (Terminal)

```bash
# Deploy to new service
render up --detach --service [NEW_SERVICE_NAME]

# Monitor logs
render logs --service [NEW_SERVICE_NAME]
```

### Phase 5: Runtime Verification (Terminal)

```bash
# Get service URL from Render
NEW_SERVICE_URL=$(render status --service [NEW_SERVICE_NAME] | grep "URL")

# Test version endpoint
curl -s ${NEW_SERVICE_URL}/__version

# Expected response:
# {
#   "git_sha": "684dad3...",
#   "build_timestamp": "2025-12-14T...",
#   "environment": "production"
# }
```

### Phase 6: Frontend Update (Code + Deployment)

```bash
# Update API endpoint in frontend code
# [LOCATION TO BE DETERMINED BY VALIDATION 3]

# Deploy frontend
netlify deploy --prod --dir mosaic_ui
```

### Phase 7: Legacy Decommission (Dashboard)

```bash
# Archive then delete obsolete projects one by one
# Only after new service is verified working
```

---

## 10. ROLLBACK PLAN

**If execution fails at any phase:**

### Phase 2 Failure (Service Creation)

- **Action:** Delete new service from dashboard
- **Impact:** None - old service still running
- **Recovery:** Fix issue, retry creation

### Phase 3 Failure (Environment Variables)

- **Action:** Restore missing vars from `/tmp/render_env_backup.json`
- **Impact:** Service won't start without vars
- **Recovery:** Re-enter variables manually

### Phase 4 Failure (Deployment)

- **Action:** Check Render logs, fix build issue
- **Impact:** New service not running (old service unaffected)
- **Recovery:** Fix code, redeploy

### Phase 5 Failure (Verification)

- **Action:** Check if `/__version` endpoint exists in code
- **Impact:** Cannot verify runtime identity (non-critical)
- **Recovery:** Implement endpoint or skip verification

### Phase 6 Failure (Frontend)

- **Action:** Revert frontend deployment on Netlify
- **Impact:** Frontend broken (backend working)
- **Recovery:** Fix API URL, redeploy

### Phase 7 Failure (Decommission)

- **Action:** Leave obsolete projects in place
- **Impact:** Clutter in Render account (no functional impact)
- **Recovery:** Clean up later manually

**CRITICAL:** All phases except Phase 7 are reversible without data loss

---

## 11. OPEN QUESTIONS FOR USER

**Before proceeding, please answer:**

1. **Service Name:** What should the new canonical service be named?
   - Suggested: `mosaic-backend` (clear, canonical)
   - Alternative: Keep `what-is-my-delta-site` name, delete old one first

2. **Migration Strategy:** Gradual or clean-slate?
   - Gradual: Run old service until new is verified, then switch
   - Clean-slate: Delete old service immediately after new is created

3. **Spec Ambiguities:**
   - What does "service identity tainted" mean in Render terms?
   - What is "hidden inheritance" referring to technically?

4. **Risk Tolerance:** How do you want to handle PostgreSQL validation?
   - Conservative: Gemini confirms scope before any service creation
   - Moderate: Proceed if Gemini finds high confidence it's project-level
   - Aggressive: Create service and test DATABASE_URL access live

---

## 12. GEMINI VALIDATION TASK

**Gemini, please execute:**

1. Run Validation 1-4 (see Section 7)
2. Document results in format:

   ```
   Validation X: [PASS/FAIL/UNCLEAR]
   Evidence: [command output]
   Risk: [high/medium/low]
   Recommendation: [proceed/modify/halt]
   ```

3. Provide final Go/No-Go recommendation
4. Escalate any blocking issues to user

---

## 13. FINAL RECOMMENDATION

**Claude Code Assessment:**

**Current Status:** ⚠️ **HALT - AWAITING APPROVAL**

**Reasons:**

1. Governance requires user approval before BUILD mode (Section 4.1 Gate)
2. Critical validations incomplete (PostgreSQL scope, frontend API location)
3. Spec ambiguities unresolved ("tainted identity", "hidden inheritance")
4. User questions unanswered (service name, migration strategy)

**Next Actions:**

1. User reviews this instruction packet
2. Gemini completes validation tasks
3. User answers open questions
4. User provides explicit approval: "APPROVED TO PROCEED"
5. Only then: Proceed to PHASE 2 execution

**Do NOT proceed without explicit user approval.**

---

**END OF INSTRUCTION PACKET**

**Status:** Draft - Awaiting User Approval + Gemini Validation
**Gate:** BLOCKING - Cannot proceed to BUILD mode
**Compliance:** ✅ TEAM_PLAYBOOK_v2 Section 4.1 satisfied
