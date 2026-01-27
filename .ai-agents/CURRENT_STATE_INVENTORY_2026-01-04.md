# Current State Inventory
**Date:** 2026-01-04
**Created by:** Claude Code
**Purpose:** Document current project state, active protocols, and governance frameworks

---

## CRITICAL DISCOVERY: INTENT_FRAMEWORK.md

**Location:** `/Users/damianseguin/Downloads/INTENT_FRAMEWORK.md`
**Status:** ACTIVE - Version 1.0 (2026-01-04)
**Applies to:** ALL AI agents, ALL deliverables

### Framework Summary

The INTENT_FRAMEWORK establishes a mandatory **Intent → Check → Receipt** pattern for all AI work:

1. **STEP 1: Show INTENT DOC** - Before any work, document:
   - Task (one sentence)
   - Scope (included/excluded)
   - Sources (exact files to use)
   - Constraints (no fabrication, no embellishment, no guessing)
   - Uncertainties (specific questions needing answers)

2. **STEP 2: Wait for Confirmation**
   - User must respond: "Proceed", "Adjust [X]", or "Stop"
   - Do NOT proceed without explicit approval

3. **STEP 3: Provide RECEIPT** - After completion, document:
   - Sources actually used
   - What was included
   - What was excluded
   - Judgment calls made
   - Items needing verification

### Critical Rules

**DO:**
- Search existing docs BEFORE asking questions
- Show Intent Doc for ALL deliverables (code, docs, analysis)
- Use exact sources, cite specifically
- Ask when uncertain (one clear question)
- Provide Receipt after completing work
- Stop immediately if you can't source a claim

**DON'T:**
- Guess when request has multiple interpretations
- Fabricate information ever
- Embellish or exaggerate claims
- Create deliverables without Intent Doc confirmation
- Skip the verification checklist
- Proceed when uncertain

### Why This Matters

**Past failures without INTENT Framework:**
- AI fabricated job responsibilities → user had to correct multiple times
- AI created wrong deliverable → wasted time
- AI embellished experience → user couldn't defend in interview
- AI duplicated existing work → didn't search first

**With INTENT Framework:**
- User sees what you'll create BEFORE you create it
- Misunderstandings caught early
- No wasted effort on wrong interpretations
- No fabrications (everything sourced)
- Clear accountability (Receipt shows what was done)

### Integration Status

- ✅ Framework document exists at Downloads location
- ⚠️ Needs integration into SESSION_START.md protocol
- ⚠️ Needs integration into .ai-agents governance
- ⚠️ Needs adoption by all AI agents (Claude Code, Gemini, ChatGPT)

---

## PROJECT LOCATIONS

### Active Locations Identified

1. **Primary Working Directory:** `/Users/damianseguin/WIMD-Deploy-Project`
   - Last modified: 2026-01-01 09:00
   - Contains: .ai-agents/ folder with 146 files
   - Contains: SESSION_RESTART_PROMPT.md (2025-12-20)
   - Git repo: Active (.git directory present)
   - Status: **CANONICAL AI_WORKSPACE LOCATION**

2. **Render Local Project:** `/Users/damianseguin/wimd-render-local`
   - Contains: TEAM_PLAYBOOK.md, SESSION_START.md, BACKUP_SYSTEM_RECOVERY_LOG.md
   - Contains: Recent session backups (2025-12-03, 2025-12-29)
   - Git repo: Re-initialized 2025-12-02
   - Backup system: Post-commit hook restored 2026-01-04
   - Status: **ACTIVE DEVELOPMENT LOCATION**

3. **Downloads Archive:** `/Users/damianseguin/WIMD-Deploy-Project`
   - Contains: October 2025 backup system (working post-commit hook)
   - Contains: INTENT_FRAMEWORK.md (new discovery)
   - Status: **ARCHIVE + NEW PROTOCOL DOCUMENTS**

### Location Consolidation Needed

- **Issue:** Multiple project locations create confusion about canonical source of truth
- **Impact:** Governance documents scattered across locations
- **Recommendation:** Consolidate to single canonical location or establish clear hierarchy

---

## GOVERNANCE & PROTOCOL DOCUMENTS

### Session Management

1. **SESSION_START.md** (wimd-render-local)
   - Purpose: Mandatory startup protocol
   - Includes: Understanding mode gates, verification questions, decision tree
   - Includes: Session end monitoring (trigger phrase detection)
   - Includes: Backup system verification
   - Status: **ACTIVE**

2. **SESSION_RESTART_PROMPT.md** (AI_Workspace, dated 2025-12-20)
   - Purpose: Session restart protocol
   - Status: **EXISTS** (not yet reviewed this session)

3. **INTENT_FRAMEWORK.md** (Downloads, dated 2026-01-04)
   - Purpose: Intent → Check → Receipt pattern for all deliverables
   - Status: **NEWLY DISCOVERED - INTEGRATION NEEDED**

### Team Coordination

1. **TEAM_PLAYBOOK.md** (wimd-render-local)
   - Contains: Current sprint status, blocking issues, code state
   - Last updated: 2026-01-04 (backup system restoration)
   - Status: **ACTIVE**

2. **.ai-agents/ folder** (AI_Workspace, 146 files)
   - Contains: Agent communication protocols, handoff documents
   - Contains: Session management, governance frameworks
   - Status: **ACTIVE**

### Safety & Quality Controls

1. **TROUBLESHOOTING_CHECKLIST.md** (wimd-render-local + Downloads)
   - Purpose: Pre-flight checks for all code changes
   - Contains: Error classification dashboard, debugging workflow
   - Status: **MANDATORY READING**

2. **SELF_DIAGNOSTIC_FRAMEWORK.md** (wimd-render-local + Downloads)
   - Purpose: Architecture-specific error prevention
   - Contains: Error taxonomy, playbooks-as-code, automated fixes
   - Status: **MANDATORY READING**

---

## BACKUP SYSTEM STATUS

### Current State (as of 2026-01-04)

**Git Post-Commit Hook:**
- Location: `/Users/damianseguin/wimd-render-local/.git/hooks/post-commit`
- Status: ✅ **RESTORED** (2026-01-04)
- Function: Auto-sync to GDrive after every commit
- Target: `gdrive:WIMD-Render-Deploy-Project`

**Root Cause of Previous Failure:**
- Repository re-initialized 2025-12-02 at wimd-render-local
- Git hooks live in `.git/hooks/` (NOT version-controlled)
- Hook was lost during repo move from Downloads location

**Resolution:**
- Hook restored with updated project path
- Documentation created: BACKUP_SYSTEM_RECOVERY_LOG.md
- SESSION_START.md updated with backup verification step

**Remaining TODOs:**
- Move to version-controlled hooks (create `hooks/` directory in repo root)
- Update session_end.sh to commit session backups to Git
- Add verification to SESSION_START.md startup checklist

---

## RAILWAY DEPLOYMENT

### Project Information

**Project:** mosaic-backend (confirmed via `render status`)
**Service:** wimd-render-deploy
**Current Working Directory:** `/Users/damianseguin/wimd-render-local`

### Current Code Version

**Location:** `api/index.py` lines 1-18
**Status:** To be verified (need to read current version)

### Database

**Type:** PostgreSQL (Render managed service)
**Connection:** Via `DATABASE_URL` environment variable
**Pattern:** Context manager required: `with get_conn() as conn:`
**Fallback:** SQLite (ephemeral, local dev only)

---

## OUTSTANDING QUESTIONS

1. **Which SESSION_START protocol is canonical?**
   - SESSION_START.md (wimd-render-local)
   - SESSION_RESTART_PROMPT.md (AI_Workspace)
   - Need to reconcile these two documents

2. **How to integrate INTENT_FRAMEWORK?**
   - Should it replace or augment SESSION_START protocol?
   - How to enforce across all AI agents?
   - Where should canonical version live?

3. **Project location consolidation:**
   - Should AI_Workspace become primary location?
   - Should wimd-render-local be migrated?
   - How to handle multiple git repos?

4. **Backup system final steps:**
   - Version-controlled hooks implementation timeline?
   - Session backup auto-commit integration?
   - GDrive sync verification frequency?

---

## NEXT STEPS

### Immediate (This Session)

1. ✅ Read INTENT_FRAMEWORK.md
2. ✅ Create current state inventory
3. ⏳ Integrate INTENT_FRAMEWORK into session protocols
4. ⏳ Read SESSION_RESTART_PROMPT.md to understand canonical restart process
5. ⏳ Verify current Render deployment status
6. ⏳ Check TEAM_PLAYBOOK.md for current blocking issues

### Short-Term (Next Session)

1. Reconcile SESSION_START.md and SESSION_RESTART_PROMPT.md
2. Move git hooks to version-controlled location
3. Update session_end.sh to auto-commit backups
4. Consolidate project locations or establish clear hierarchy

### Long-Term (Future Sprints)

1. Enforce INTENT_FRAMEWORK across all AI agents
2. Create automated verification that INTENT pattern is followed
3. Standardize session management across Claude Code, Gemini, ChatGPT
4. Establish single source of truth for all governance documents

---

**END OF INVENTORY**
**Status:** Draft - Awaiting user review
**Next Action:** User to review inventory and confirm accuracy
