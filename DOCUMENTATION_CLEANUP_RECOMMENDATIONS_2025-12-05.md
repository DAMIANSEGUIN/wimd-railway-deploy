# Documentation Cleanup Recommendations
**Date**: 2025-12-05
**Purpose**: Identify obsolete, incongruent, or duplicate documentation for removal
**Based On**: MOSAIC_DOCUMENTATION_AUDIT_2025-12-05.md + TEAM_PLAYBOOK.md current state
**Status**: PENDING USER APPROVAL BEFORE DELETION

---

## 🎯 CURRENT PROJECT SCOPE (As of 2025-12-04)

### Active Goals
1. **Mosaic Context-Aware Coaching MVP** (3-day sprint, Day 1 complete)
   - PS101 context extraction endpoint
   - Context-aware coaching system prompts
   - Database schema v2 (ps101_responses, user_contexts tables)

2. **Existing Stable Features** (Do Not Touch)
   - Authentication system
   - Job search functionality (12 free sources)
   - Resume optimization
   - Frontend UI (Netlify)
   - Railway infrastructure

3. **Current Blockers**
   - GitHub → Railway auto-deploy trigger not working
   - Schema version reporting mismatch (minor)

### Out of Scope / Deferred
- Advanced experiment tracking
- Full prompt library integration
- Job search enhancements
- Booking system
- Multi-tenancy
- Internationalization

---

## 🗑️ FILES RECOMMENDED FOR DELETION

### Category 1: CONFIRMED SUPERSEDED (Safe to Delete)

**TEAM_PLAYBOOK.md explicitly states these are superseded by v2.0.0:**

**Root Directory:**
- ❌ `OPERATIONS_MANUAL.md` - Superseded by TEAM_PLAYBOOK.md Section 5-11
  - **Reason**: TEAM_PLAYBOOK.md v2.0.0 consolidates all operations
  - **Action**: Move to `/deprecated/` with date stamp

**Docs Directory:**
- ❌ `docs/CODEX_INSTRUCTIONS.md` - Superseded by TEAM_PLAYBOOK.md Section 3
  - **Reason**: TEAM_PLAYBOOK.md Section 3 defines all team member roles
  - **Action**: Move to `/deprecated/`

- ❌ `docs/CODEX_HANDOVER_KIT.md` - Superseded by TEAM_PLAYBOOK.md + .ai-agents/HANDOFF_PROTOCOL.md
  - **Reason**: Handoff procedures now in TEAM_PLAYBOOK Section 3
  - **Action**: Move to `/deprecated/`

- ❌ `docs/CODEX_HANDOVER_README.md` - Superseded
  - **Reason**: Duplicate handoff documentation
  - **Action**: Move to `/deprecated/`

- ❌ `docs/OPERATIONS_MANUAL.md` - Superseded (duplicate of root OPERATIONS_MANUAL.md)
  - **Reason**: TEAM_PLAYBOOK.md supersedes
  - **Action**: Delete (already marked superseded)

**Status**: ✅ Safe to delete - explicitly marked as superseded

---

### Category 2: OBSOLETE BOOKING SYSTEM DOCS (Out of Scope)

**These documents relate to a booking system that is NOT in current project scope:**

**Root Directory:**
- ❌ None identified in root

**Planning Directory:**
- ❌ `Planning/BOOKING_SESSION_BACKUP_2025-10-25.md`
  - **Reason**: Booking system not in current MVP scope per TEAM_PLAYBOOK
  - **Last Modified**: 2025-10-25 (over 1 month old)
  - **Question**: Is booking system a future module or abandoned feature?
  - **Recommendation**: Move to `Planning/Archive_20251026/` (where other booking docs already are)

**Planning/Archive_20251026/ (Already Archived):**
- ✅ Already archived correctly:
  - `BOOKING_ENV_SETUP.md`
  - `BOOKING_IMPLEMENTATION_PLAN.md`
  - `BOOKING_REQUIREMENTS_ELICITATION.md`
  - `BOOKING_REQUIREMENTS_FINALIZED.md`
  - `BOOKING_SYSTEM_READY.md`

**Status**: ⚠️ **QUESTION FOR USER**: Is booking system a future module or permanently out of scope?

---

### Category 3: STALE DATED HANDOFFS (Historical, Low Value)

**These are dated handoff documents older than 2 weeks with no ongoing relevance:**

**.ai-agents Directory:**

**Handoffs from November (1-3 weeks old):**
- 🟡 `.ai-agents/HANDOFF_NETLIFY_RUNNER_2025-11-06.md` (29 days old)
  - **Reason**: Netlify deployment now stable, handoff complete
  - **Recommendation**: Move to `.ai-agents/archive/handoffs/2025-11/`

- 🟡 `.ai-agents/NETLIFY_RUNNER_FILE_REFERENCE_2025-11-06.md` (29 days old)
  - **Reason**: Related to above handoff
  - **Recommendation**: Move to `.ai-agents/archive/handoffs/2025-11/`

- 🟡 `.ai-agents/NETLIFY_RUNNER_START_HERE_2025-11-06.md` (29 days old)
  - **Reason**: Related to above handoff
  - **Recommendation**: Move to `.ai-agents/archive/handoffs/2025-11/`

- 🟡 `.ai-agents/DEPLOYMENT_ATTEMPT_2_2025-11-07.md` (28 days old)
  - **Reason**: Deployment now stable
  - **Recommendation**: Move to `.ai-agents/archive/deployments/2025-11/`

- 🟡 `.ai-agents/DEPLOYMENT_STATUS_2025-11-07.md` (28 days old)
  - **Reason**: Current status in DEPLOYMENT_STATUS.md (root)
  - **Recommendation**: Move to `.ai-agents/archive/deployments/2025-11/`

- 🟡 `.ai-agents/SESSION_RECOVERY_2025-11-07_1712.md` (28 days old)
  - **Reason**: Session recovered, no longer relevant
  - **Recommendation**: Move to `.ai-agents/archive/sessions/2025-11/`

- 🟡 `.ai-agents/SESSION_SUMMARY_2025-11-07_1601.md` (28 days old)
  - **Reason**: Old session summary
  - **Recommendation**: Move to `.ai-agents/archive/sessions/2025-11/`

- 🟡 `.ai-agents/SESSION_RESTART_PROMPT_2025-11-07.md` (28 days old)
  - **Reason**: Old restart prompt
  - **Recommendation**: Move to `.ai-agents/archive/sessions/2025-11/`

- 🟡 `.ai-agents/DEPLOYMENT_LOOP_DIAGNOSIS_2025-11-09.md` (26 days old)
  - **Reason**: Loop issue resolved
  - **Recommendation**: Move to `.ai-agents/archive/deployments/2025-11/`

- 🟡 `.ai-agents/DEPLOYMENT_SUCCESS_2025-11-09.md` (26 days old)
  - **Reason**: Deployment now routine
  - **Recommendation**: Move to `.ai-agents/archive/deployments/2025-11/`

- 🟡 `.ai-agents/TEST_FAILURE_DIAGNOSIS_2025-11-09.md` (26 days old)
  - **Reason**: Tests passing now
  - **Recommendation**: Move to `.ai-agents/archive/testing/2025-11/`

- 🟡 `.ai-agents/SESSION_BACKUP_2025-11-09_1635.md` (26 days old)
  - **Reason**: Old backup
  - **Recommendation**: Move to `.ai-agents/archive/sessions/2025-11/`

- 🟡 `.ai-agents/INITAPP_UNDEFINED_ISSUE_2025-11-09.md` (26 days old)
  - **Reason**: Issue resolved
  - **Recommendation**: Move to `.ai-agents/archive/issues/2025-11/`

- 🟡 `.ai-agents/DEPLOYMENT_SNAPSHOT_2025-11-11.md` (24 days old)
  - **Reason**: Old snapshot
  - **Recommendation**: Move to `.ai-agents/archive/deployments/2025-11/`

- 🟡 `.ai-agents/SESSION_SUMMARY_2025-11-12.md` (23 days old)
  - **Reason**: Old session summary
  - **Recommendation**: Move to `.ai-agents/archive/sessions/2025-11/`

- 🟡 `.ai-agents/SESSION_SUMMARY_2025-11-13.md` (22 days old)
  - **Reason**: Old session summary
  - **Recommendation**: Move to `.ai-agents/archive/sessions/2025-11/`

**Status**: ✅ Safe to archive (not delete) - move to dated archive subdirectories

---

### Category 4: DUPLICATE PHASE_1_BOUNDARIES (Incomplete Placeholder)

**Root Directory:**
- ⚠️ `PHASE_1_BOUNDARIES.md`
  - **Status**: "DRAFT (Gemini)" - Never completed, just a placeholder template
  - **Last Modified**: 2025-11-25
  - **Current State**: Empty template with instructions to fill in
  - **Issue**: Phase 1 boundaries are NOW defined in TEAM_PLAYBOOK.md Section 2 "What's NOT Changing"
  - **Question**: Is this document still needed or is TEAM_PLAYBOOK.md sufficient?
  - **Recommendation**: DELETE - scope now defined in TEAM_PLAYBOOK.md

**Status**: ⚠️ **QUESTION FOR USER**: Delete PHASE_1_BOUNDARIES.md (empty template) since scope is in TEAM_PLAYBOOK?

---

### Category 5: INCOMPLETE/PLACEHOLDER DOCUMENTS

**Root Directory:**
- ⚠️ `AI_RESUME_STATE.md`
  - **Last Modified**: 2025-11-24
  - **Status**: May be stale (11 days old)
  - **Question**: Is this actively maintained or historical?
  - **Recommendation**: Review contents - if not current, archive

**Status**: ⚠️ **NEEDS REVIEW** - May or may not be current

---

### Category 6: DEPRECATED CURSOR-SPECIFIC DOCS (Multiple Related)

**docs Directory:**

The following docs are Cursor-specific and may be superseded by TEAM_PLAYBOOK.md Section 3 (Team Roles):

- ⚠️ `docs/CURSOR_TEAM_README.md`
  - **Question**: Is Cursor still an active team member?
  - **Current TEAM_PLAYBOOK**: Lists Claude Code, Gemini, OPUS, GPT-4, Claude Desktop (no Cursor)
  - **Recommendation**: If Cursor is no longer active, move to `/deprecated/cursor/`

- ⚠️ `docs/CURSOR_ROLE_NOTE.md`
  - **Same as above**

- ⚠️ `docs/CURSOR_AGENT_PROMPT_PS101_V2.md`
  - **Same as above**

- ⚠️ `docs/CURSOR_FIXES_REQUIRED.md`
  - **Same as above**

- ⚠️ `docs/CURSOR_UI_BUG_REPORT_2025-11-03.md`
  - **Dated**: 2025-11-03 (32 days old)
  - **Recommendation**: Move to archive if bug resolved

**.ai-agents Directory:**
- ⚠️ `.ai-agents/CURSOR_COMPLETION_SUMMARY_2025-11-05.md` (30 days old)
- ⚠️ `.ai-agents/CURSOR_REVIEW_4_COMMITS_DEPLOYMENT_READY_2025-11-04.md` (31 days old)
- ⚠️ `.ai-agents/CURSOR_REVIEW_CLEANUP_PLAN_2025-11-04.md` (31 days old)
- ⚠️ `.ai-agents/CURSOR_REVIEW_DOCUMENTATION_DISCIPLINE_CHANGES_2025-11-04.md` (31 days old)
- ⚠️ `.ai-agents/CURSOR_REVIEW_PS101_BUILD_ID_INTEGRATION_2025-11-04.md` (31 days old)
- ⚠️ `.ai-agents/CURSOR_ACKNOWLEDGMENT_DOCUMENTATION_DISCIPLINE_2025-11-04.md` (31 days old)
- ⚠️ `.ai-agents/NOTE_FOR_CURSOR_AND_TERMINAL_CODEX_2025-11-05.md` (30 days old)
- ⚠️ `.ai-agents/PS101_PROTOCOL_ACKNOWLEDGMENT_CURSOR_2025-11-04.md` (31 days old)
- ⚠️ `.ai-agents/CLEANUP_TASKS_FOR_CLAUDE_2025-11-04.md` (31 days old)

**Status**: ⚠️ **QUESTION FOR USER**: Is Cursor still an active team member? If not, archive all Cursor docs.

---

### Category 7: OUTDATED API KEYS DOC

**Root Directory:**
- ⚠️ `api_keys.md`
  - **Last Modified**: 2025-10-07 (59 days old - nearly 2 months)
  - **Issue**: API keys documentation from October may be stale
  - **Question**: Are API keys current or have they been rotated?
  - **Recommendation**: Review and update or delete if superseded by env_template.txt

**Status**: ⚠️ **NEEDS REVIEW** - May contain outdated key references

---

### Category 8: UNKNOWN STATUS TEXT FILES

**Root Directory:**
- ⚠️ `AI_DETAILED_PROMPT.txt` (no modification date available)
  - **Question**: Is this currently used or historical?
  - **Recommendation**: Review contents

- ⚠️ `AI_SHORT_PROMPT.txt` (no modification date available)
  - **Question**: Is this currently used or historical?
  - **Recommendation**: Review contents

- ⚠️ `AI_START_HERE.txt` (no modification date available)
  - **Question**: Is this currently used or superseded by SESSION_START.md?
  - **Recommendation**: Review contents

- ⚠️ `SESSION_START_PROMPT.txt` (no modification date available)
  - **Question**: Is this currently used or superseded by SESSION_START.md?
  - **Recommendation**: Review contents

**Status**: ⚠️ **NEEDS REVIEW** - Unknown if current or obsolete

---

### Category 9: PLANNING DIRECTORY UNKNOWNS

**Planning Directory:**
- ⚠️ `Planning/00_READ_TWICE_PROTOCOL.md` (no modification date)
  - **Question**: Is this still relevant or superseded by SESSION_START.md gate system?
  - **Recommendation**: Review contents

- ⚠️ `Planning/AUTOSAVE_PROTOCOL_TRACKING.md` (no modification date)
  - **Question**: Is autosave protocol currently in use?
  - **Recommendation**: Review contents

**Status**: ⚠️ **NEEDS REVIEW** - Unknown if current or obsolete

---

### Category 10: ARCHIVED NAR TASKS (Historical)

**Planning/NAR_Archive Directory:**
- 🟡 `Planning/NAR_Archive/NAR_RAILWAY_DEBUG_V1.md`
  - **Status**: In archive directory
  - **Recommendation**: Keep in archive (already properly archived)

- 🟡 `Planning/NAR_Archive/NAR_TASK_DRAGGABLE_COMPLETED.md`
  - **Status**: In archive directory
  - **Recommendation**: Keep in archive (already properly archived)

**Status**: ✅ Properly archived - no action needed

---

### Category 11: OLD DIAGNOSTIC REPORTS (November)

**.ai-agents Directory:**
- 🟡 `.ai-agents/DIAGNOSTIC_REPORT_20251102.md` (33 days old)
  - **Status**: Comprehensive diagnostic from Nov 2
  - **Recommendation**: Keep for historical reference OR move to archive

- 🟡 `.ai-agents/FINAL_DIAGNOSTIC_20251102.md` (33 days old)
  - **Status**: Final diagnostic from Nov 2
  - **Recommendation**: Keep for historical reference OR move to archive

- 🟡 `.ai-agents/FINDINGS_SUMMARY.md` (33 days old)
  - **Status**: Findings summary from Nov 2
  - **Recommendation**: Keep for historical reference OR move to archive

- 🟡 `.ai-agents/SESSION_SUMMARY_20251102.md` (33 days old)
  - **Status**: Session summary from Nov 2
  - **Recommendation**: Move to archive

**Status**: 🟡 **OPTIONAL ARCHIVE** - Keep if historical diagnostics are valuable, otherwise archive

---

### Category 12: OLD STAGE DOCUMENTS (November)

**.ai-agents Directory:**
- 🟡 `.ai-agents/STAGE1_CURRENT_STATE_2025-11-05.md` (30 days old)
- 🟡 `.ai-agents/STAGE2_ACTION_PLAN_2025-11-05.md` (30 days old)
- 🟡 `.ai-agents/STAGE2_DIAGNOSIS_2025-11-05.md` (30 days old)
- 🟡 `.ai-agents/STAGE3_VERIFICATION_2025-11-05.md` (30 days old)
- 🟡 `.ai-agents/SITUATIONAL_REPORT_2025-11-05.md` (30 days old)

**Status**: 🟡 **OPTIONAL ARCHIVE** - Historical staging documents from Nov 5

---

## 📊 SUMMARY OF RECOMMENDATIONS

### Confirmed Safe to Delete/Archive

| Category | Count | Action | Risk Level |
|----------|-------|--------|------------|
| **Superseded Docs** | 5 | Move to `/deprecated/` | ✅ SAFE |
| **Stale Dated Handoffs** | 15 | Move to `.ai-agents/archive/` by date | ✅ SAFE |
| **Old Diagnostics** | 4 | Move to `.ai-agents/archive/` | ✅ SAFE |
| **Old Stage Docs** | 5 | Move to `.ai-agents/archive/` | ✅ SAFE |

**Total**: 29 files safe to archive

### Requires User Decision

| Category | Count | Question | Risk Level |
|----------|-------|----------|------------|
| **Booking System Docs** | 1 | Future module or abandoned? | ⚠️ MEDIUM |
| **PHASE_1_BOUNDARIES.md** | 1 | Delete empty template? | ⚠️ LOW |
| **Cursor Docs** | 11 | Is Cursor still active? | ⚠️ MEDIUM |
| **Unknown Status .txt Files** | 4 | Still in use? | ⚠️ MEDIUM |
| **Planning Unknowns** | 2 | Still relevant? | ⚠️ MEDIUM |
| **api_keys.md** | 1 | Keys current? | ⚠️ HIGH |
| **AI_RESUME_STATE.md** | 1 | Still maintained? | ⚠️ LOW |

**Total**: 21 files require user review

---

## 🎬 RECOMMENDED ACTIONS

### Phase 1: Immediate (No Risk)

**Archive superseded documents:**
```bash
# Create deprecated directory
mkdir -p /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/deprecated/2025-12

# Move superseded files
mv OPERATIONS_MANUAL.md deprecated/2025-12/
mv docs/CODEX_INSTRUCTIONS.md deprecated/2025-12/
mv docs/CODEX_HANDOVER_KIT.md deprecated/2025-12/
mv docs/CODEX_HANDOVER_README.md deprecated/2025-12/
mv docs/OPERATIONS_MANUAL.md deprecated/2025-12/

# Create README explaining deprecation
cat > deprecated/2025-12/README.md <<EOF
# Deprecated Documentation - December 2025

These files have been superseded by TEAM_PLAYBOOK.md v2.0.0 as of 2025-12-02.

They are kept for historical reference only. DO NOT use these documents.

Refer to TEAM_PLAYBOOK.md for current canonical protocols.
EOF
```

**Archive stale dated handoffs:**
```bash
# Create archive structure
mkdir -p .ai-agents/archive/{handoffs,deployments,sessions,testing,issues}/{2025-11,2025-12}

# Move files (list provided in script below)
# ... (full script available on request)
```

### Phase 2: User Review Required

**Questions for User:**

1. **Booking System**: Is this a future module or permanently out of scope?
   - If future: Keep `Planning/BOOKING_SESSION_BACKUP_2025-10-25.md`
   - If abandoned: Move to archive

2. **Cursor Agent**: Is Cursor still an active team member?
   - If no: Archive all 11 Cursor-related documents
   - If yes: Keep and update

3. **PHASE_1_BOUNDARIES.md**: Delete empty template?
   - Scope is now in TEAM_PLAYBOOK.md Section 2
   - Recommend: DELETE

4. **Text Files**: Are these still in use?
   - `AI_DETAILED_PROMPT.txt`
   - `AI_SHORT_PROMPT.txt`
   - `AI_START_HERE.txt`
   - `SESSION_START_PROMPT.txt`
   - Recommend: Review contents, delete if superseded by SESSION_START.md

5. **api_keys.md**: Are these keys current or rotated?
   - Last updated October 7 (59 days ago)
   - Recommend: Review and update or delete if superseded by env_template.txt

6. **Planning Unknowns**: Still relevant?
   - `Planning/00_READ_TWICE_PROTOCOL.md`
   - `Planning/AUTOSAVE_PROTOCOL_TRACKING.md`

### Phase 3: Optional Optimization

**Archive old diagnostics and stage docs** (29 additional files)
- These are historical and may be useful for reference
- If not needed, can be archived to reduce clutter

---

## 🚨 SAFETY PROTOCOL

**BEFORE DELETING ANY FILES:**

1. ✅ Create timestamped backup:
   ```bash
   cd /Users/damianseguin/AI_Workspace
   tar -czf WIMD-Pre-Cleanup-Backup-2025-12-05.tar.gz WIMD-Railway-Deploy-Project/
   ```

2. ✅ Verify backup created successfully:
   ```bash
   ls -lh WIMD-Pre-Cleanup-Backup-2025-12-05.tar.gz
   ```

3. ✅ Upload backup to Google Drive (per previous audit requirement)

4. ✅ Get user approval for each category before proceeding

5. ✅ Move files to archive first, delete only after 30-day retention period

---

## 📋 APPROVAL CHECKLIST

**User must approve before proceeding:**

- [ ] Phase 1: Archive superseded documents (5 files) - APPROVED / REJECTED
- [ ] Phase 1: Archive stale dated handoffs (15 files) - APPROVED / REJECTED
- [ ] Phase 2: Answer booking system question
- [ ] Phase 2: Answer Cursor agent question
- [ ] Phase 2: Answer PHASE_1_BOUNDARIES deletion
- [ ] Phase 2: Answer text files status
- [ ] Phase 2: Answer api_keys.md status
- [ ] Phase 2: Answer planning unknowns status
- [ ] Phase 3: Archive old diagnostics (4 files) - APPROVED / REJECTED
- [ ] Phase 3: Archive old stage docs (5 files) - APPROVED / REJECTED
- [ ] Safety: Backup created and verified - CONFIRMED

---

**END OF CLEANUP RECOMMENDATIONS**

**Next Steps**:
1. User reviews and answers questions
2. User approves deletion categories
3. Execute cleanup with approved items only
4. Update MOSAIC_DOCUMENTATION_AUDIT_2025-12-05.md with post-cleanup state
