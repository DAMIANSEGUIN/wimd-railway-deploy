# Railway Reset Validation Checklist

**Pre-Execution Review for Claude Code + Gemini**

**Created:** 2025-12-14
**Status:** DRAFT - Requires dual-agent validation
**Spec Source:** ChatGPT MOSAIC_RAILWAY_RESET_SPEC v1.0

---

## CRITICAL: DO NOT EXECUTE UNTIL BOTH AGENTS VALIDATE

This checklist must be verified by:

1. **Claude Code** - Technical validation
2. **Gemini** - Cross-check and testing verification

---

## VALIDATION MATRIX

### ✅ VALIDATED FACTS (From Terminal Evidence)

| Fact | Evidence Source | Status |
|------|----------------|--------|
| Railway has 7 projects total | `railway list` | ✅ CONFIRMED |
| Current service is `what-is-my-delta-site` | `railway status` | ✅ CONFIRMED |
| Current project is `wimd-career-coaching` | `railway status` | ✅ CONFIRMED |
| Service responds with 404 | `curl health endpoint` | ✅ CONFIRMED |
| Git remote `origin` = `wimd-railway-deploy` | `git remote -v` | ✅ CONFIRMED |
| Git remote `railway-origin` = `what-is-my-delta-site` | `git remote -v` | ✅ CONFIRMED |
| Railway watches `what-is-my-delta-site` repo | `git ls-remote railway-origin` | ✅ CONFIRMED |
| Current deployed commit: `96e711c1` (Nov 11) | Screenshot evidence | ✅ CONFIRMED |
| Current code HEAD: `684dad3` (Dec 14) | `git log` | ✅ CONFIRMED |
| 9+ environment variables exist | `railway variables` | ✅ CONFIRMED |
| PostgreSQL DATABASE_URL present | `railway variables` | ✅ CONFIRMED |

### ⚠️ ASSUMPTIONS TO TEST (Gemini Review Required)

| Assumption | Test Required | Risk If Wrong |
|------------|---------------|---------------|
| Creating new service won't break PostgreSQL | Check if DB is project-level or service-level | Data loss |
| Environment variables are service-specific | Check if vars are inherited or isolated | Security exposure |
| Frontend can be updated independently | Check Netlify deployment independence | Frontend breaks |
| `/__version` endpoint doesn't exist yet | Check codebase for existing implementation | Spec assumes missing feature |
| All 6 obsolete projects are safe to delete | Verify no hidden dependencies | Service disruption |
| Railway CLI can deploy without dashboard | Test `railway up` on current service | Deployment fails |

### 🔴 UNVALIDATED CLAIMS (Require Investigation)

| Claim | Investigation Needed | Blocker? |
|-------|---------------------|----------|
| "service identity is tainted" | What does this mean technically? | ❓ |
| "hidden inheritance" from legacy repo | Is this real or theoretical? | ❓ |
| Dashboard required for new service | Can CLI create services? Check docs | ⚠️ YES |
| Root directory must be explicit | Is default `/` sufficient? | ⚠️ MAYBE |
| Runtime must be self-identifying | Does current code have version endpoint? | ⚠️ YES |

---

## TESTING PROTOCOL (For Gemini)

### Test 1: PostgreSQL Scope

**Hypothesis:** PostgreSQL is project-level, not service-level

**Commands:**

```bash
# Check if DATABASE_URL is in project variables or service variables
railway variables --help
# Look for --project or --service flags

# Check Railway dashboard: Project Settings → Services
# See if PostgreSQL appears as separate service
```

**Expected:** PostgreSQL service visible at project level

**Risk:** If PostgreSQL is service-level and tied to `what-is-my-delta-site`, creating new service loses database access

**Validation Required:** ✅ CONFIRM or ❌ REJECT assumption

---

### Test 2: Environment Variable Inheritance

**Hypothesis:** Environment variables are service-specific (not inherited)

**Commands:**

```bash
# Backup current service vars
railway variables > /tmp/current_service_vars.txt

# Check if Railway CLI supports cross-service var inspection
railway variables --service what-is-my-delta-site
railway variables --service <any-other-service-if-exists>
```

**Expected:** Variables are isolated per service

**Risk:** If creating new service, must manually recreate all 9+ env vars

**Validation Required:** ✅ CONFIRM isolation

---

### Test 3: Codebase Version Endpoint

**Hypothesis:** `/__version` endpoint doesn't exist in current codebase

**Commands:**

```bash
# Search codebase for existing version endpoint
grep -r "/__version" /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/api/
grep -r "@app.get.*version" /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/api/

# Check FastAPI routes
cat /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/api/index.py | grep -A5 "version"
```

**Expected:** No existing `/__version` endpoint

**Risk:** If endpoint exists but not working, issue is different than spec assumes

**Validation Required:** ✅ CONFIRM missing or ❌ FOUND (update spec)

---

### Test 4: Railway CLI Service Creation

**Hypothesis:** Dashboard is required to create new service (CLI can't do it)

**Commands:**

```bash
# Check Railway CLI docs
railway --help | grep -i service
railway service --help

# Look for 'create' or 'new' subcommands
```

**Expected:** No CLI command to create new service

**Risk:** If CLI can create service, we're using wrong tool

**Validation Required:** ✅ CONFIRM dashboard required

---

### Test 5: Frontend API Hardcoding

**Hypothesis:** Frontend has `mosaic-platform.vercel.app` hardcoded

**Commands:**

```bash
# Check frontend for API endpoint references
grep -r "mosaic-platform" /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/mosaic_ui/
grep -r "vercel.app" /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/mosaic_ui/
grep -r "apiBase" /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/mosaic_ui/

# Check Netlify config
cat /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/netlify.toml 2>/dev/null
```

**Expected:** Hardcoded legacy API URL found

**Risk:** Frontend won't connect to new service without code changes

**Validation Required:** ✅ CONFIRM hardcoded location

---

### Test 6: Obsolete Projects Safety

**Hypothesis:** All 6 non-canonical projects are safe to delete

**Commands:**

```bash
# For each obsolete project, check:
# 1. Last deployment date
# 2. Active services
# 3. Any traffic/logs

# This requires Railway dashboard access - cannot be done via CLI
```

**Expected:** No activity in past 30+ days

**Risk:** Deleting active project breaks something unknown

**Validation Required:** ⚠️ MANUAL REVIEW REQUIRED (dashboard only)

---

## SPEC AMBIGUITIES TO RESOLVE

### Ambiguity 1: "Service Identity Tainted"

**Spec Says:** "service_identity_is_tainted"

**Questions:**

- What technical property makes identity "tainted"?
- Is this about GitHub repo connection?
- Is this about deployment history?
- Is this about environment variables?

**Resolution Needed:** Define what "tainted" means in Railway terms

**Gemini Action:** Interpret or ask user for clarification

---

### Ambiguity 2: "Hidden Inheritance"

**Spec Says:** "This breaks legacy repo wiring and hidden inheritance"

**Questions:**

- What is being inherited?
- Where is it hidden?
- Is this Railway-specific behavior or general CI/CD pattern?

**Resolution Needed:** Identify concrete inheritance mechanism

**Gemini Action:** Research Railway service inheritance behavior

---

### Ambiguity 3: Root Directory Requirement

**Spec Says:** "root_directory: explicit_required"

**Questions:**

- Is default `/` explicit enough?
- Does Railway default to repo root if unspecified?
- Is there a specific path we should use?

**Resolution Needed:** Confirm correct root directory value

**Gemini Action:** Check Railway docs or test with current service config

---

## DEPENDENCY VALIDATION

### Dependency 1: Netlify Frontend

**Status:** ✅ LIVE (validated via curl)

**Dependencies:**

- API endpoint URL (currently hardcoded to Vercel)
- No authentication dependency confirmed

**Validation Required:**

- Can frontend be updated independently? ✅ YES (separate deployment)
- Will frontend break during backend migration? ⚠️ LIKELY (API URL change)

**Mitigation:** Update frontend API URL before testing

---

### Dependency 2: PostgreSQL Database

**Status:** ⚠️ UNKNOWN SCOPE

**Critical Questions:**

- Is PostgreSQL a separate Railway service? (check dashboard)
- Is DATABASE_URL project-level or service-level?
- Will new service have access to same database?

**Validation Required:**

- ⚠️ MUST CONFIRM before proceeding with new service creation

**Blocker:** If DB is service-level, data migration required

---

### Dependency 3: GitHub Repository Connection

**Status:** ✅ CONFIRMED MISALIGNED

**Facts:**

- Current service watches: `what-is-my-delta-site`
- Current development repo: `wimd-railway-deploy`
- Repos diverged Nov 11+ (26+ commits difference)

**Validation Required:**

- ✅ CONFIRMED need to reconnect to correct repo

---

## RISK ASSESSMENT

### 🔴 HIGH RISK: Database Access Loss

**Scenario:** PostgreSQL is tied to `what-is-my-delta-site` service

**Impact:** New service can't access existing data

**Mitigation Required:**

1. Confirm PostgreSQL is project-level service
2. If service-level, export data before migration
3. Test DATABASE_URL access from new service before cutover

**Validation Status:** ⚠️ NOT YET VALIDATED

---

### 🟡 MEDIUM RISK: Environment Variable Loss

**Scenario:** Creating new service doesn't inherit env vars

**Impact:** Must manually recreate 9+ environment variables

**Mitigation Required:**

1. ✅ COMPLETE - Backed up to `/tmp/railway_env_backup.json`
2. Document required vars in spec
3. Verify backup is complete before service deletion

**Validation Status:** ✅ MITIGATED (backup exists)

---

### 🟡 MEDIUM RISK: Frontend Downtime

**Scenario:** Frontend hardcoded to legacy API, new backend has different URL

**Impact:** Frontend breaks until updated and redeployed

**Mitigation Required:**

1. Identify exact API URL in frontend code
2. Update to new Railway service URL
3. Redeploy frontend after backend is verified
4. Consider API proxy/redirect during migration

**Validation Status:** ⚠️ REQUIRES CODE INSPECTION

---

### 🟢 LOW RISK: Obsolete Project Deletion

**Scenario:** Deleting old projects breaks unknown dependency

**Impact:** Some legacy system stops working

**Mitigation Required:**

1. Review each project in dashboard before deletion
2. Check for any recent activity/logs
3. Archive project settings before deletion
4. Delete one at a time, monitor for issues

**Validation Status:** ✅ SAFE (Phase 7 is last, can be skipped)

---

## REQUIRED VALIDATIONS CHECKLIST

**Before proceeding to PHASE 2, Gemini must validate:**

### Critical (Blockers)

- [ ] **PostgreSQL scope confirmed** (project-level vs service-level)
- [ ] **DATABASE_URL accessibility** from new service tested/confirmed
- [ ] **Environment variables** inheritance behavior documented
- [ ] **Frontend API endpoint** location identified in code

### Important (High Priority)

- [ ] **`/__version` endpoint** existence checked in codebase
- [ ] **Railway CLI capabilities** confirmed (service creation = dashboard only)
- [ ] **Root directory requirement** clarified (default vs explicit)
- [ ] **Obsolete projects** reviewed in dashboard (no recent activity)

### Nice to Have (Low Priority)

- [ ] **"Service identity tainted"** concept clarified
- [ ] **"Hidden inheritance"** mechanism identified
- [ ] **Legacy repo relationship** fully documented

---

## GEMINI VALIDATION PROTOCOL

**Gemini, please execute the following:**

### Step 1: Run All Tests (Test 1-6 above)

**Document results in format:**

```
Test X: [PASS/FAIL/UNCLEAR]
Evidence: [command output or observation]
Conclusion: [what this means for spec]
```

### Step 2: Resolve Ambiguities

**For each ambiguity, provide:**

- Your interpretation
- Evidence supporting interpretation
- Recommendation (proceed / modify spec / ask user)

### Step 3: Validate Risk Mitigations

**For each HIGH/MEDIUM risk:**

- Confirm risk is real
- Verify mitigation exists
- Identify any gaps

### Step 4: Final Go/No-Go

**Provide explicit recommendation:**

- ✅ PROCEED - All critical validations passed
- ⚠️ PROCEED WITH MODIFICATIONS - Spec needs updates
- 🛑 HALT - Critical blocker found

---

## CLAUDE CODE VALIDATION SUMMARY

**What I've validated so far:**

- ✅ CLI scope and service mappings (PHASE 1 complete)
- ✅ Environment variables backed up to `/tmp/railway_env_backup.json`
- ✅ Git remote configuration confirmed
- ✅ Service 404 status confirmed
- ✅ Repository divergence identified (26+ commits, wrong repo)

**What I cannot validate without Gemini:**

- ⚠️ PostgreSQL service scope (requires dashboard inspection)
- ⚠️ `/__version` endpoint existence (requires codebase search)
- ⚠️ Frontend API hardcoding location (requires code inspection)
- ⚠️ Railway CLI service creation limits (requires doc review)
- ⚠️ Obsolete project safety (requires dashboard review)

**Blocking Questions for User (if Gemini can't resolve):**

1. Is PostgreSQL a separate Railway service at project level?
2. Should we preserve `what-is-my-delta-site` service or delete it?
3. What should the new canonical service be named?
4. Do you want gradual migration or clean-slate replacement?

---

## NEXT STEPS

**For User:**

1. Share this checklist with Gemini
2. Wait for Gemini's validation report
3. Review any blocking questions Gemini escalates
4. Approve or modify spec based on validation results

**For Gemini:**

1. Execute all tests (Test 1-6)
2. Resolve ambiguities (Ambiguity 1-3)
3. Validate risks and mitigations
4. Provide Go/No-Go recommendation

**For Claude Code:**

1. Wait for Gemini validation
2. Do NOT proceed to PHASE 2 until approved
3. Be ready to modify spec based on findings

---

## APPROVAL GATE

**This spec SHALL NOT proceed to execution until:**

- [ ] Gemini completes validation checklist
- [ ] All critical validations marked ✅ PASS
- [ ] User approves final spec (with any modifications)
- [ ] Both agents agree on execution plan

**Signature Required:**

- [ ] Claude Code: Ready to execute (pending validation)
- [ ] Gemini: Validation complete, recommend [GO/NO-GO]
- [ ] User: Approved to proceed

---

**END OF VALIDATION CHECKLIST**

**Status:** Awaiting Gemini validation
**Next Action:** Share with Gemini for testing/review
**Blocker:** Do not execute PHASE 2 until this checklist is complete
