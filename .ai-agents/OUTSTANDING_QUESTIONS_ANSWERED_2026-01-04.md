# Outstanding Questions - Answered
**Date:** 2026-01-04
**Status:** Complete answers based on existing documentation
**Source:** Review of SESSION_RESUME_PROMPT.md, TEAM_PLAYBOOK.md, SESSION_START.md, CLAUDE.md, and INTENT_FRAMEWORK.md

---

## QUESTION 1: Which SESSION_START protocol is canonical?

### Answer: Multiple protocols for different purposes

**SESSION_RESUME_PROMPT.md** (`/Users/damianseguin/WIMD-Deploy-Project/.ai-agents/SESSION_RESUME_PROMPT.md`)
- **Status:** CANONICAL for session restarts
- **Purpose:** Resume work from previous session with full context
- **Last Updated:** 2025-12-15
- **Authority:** CLAUDE.md explicitly states: "Read SESSION_RESUME_PROMPT.md BEFORE doing ANYTHING else"
- **Use When:** Starting any new session

**SESSION_START.md** (`/Users/damianseguin/wimd-render-local/SESSION_START.md`)
- **Status:** ACTIVE for local development enforcement
- **Purpose:** Gated startup protocol with understanding mode, verification questions, session end monitoring
- **Last Updated:** Recent (includes backup system verification added 2026-01-04)
- **Authority:** Mandatory reading for local development work
- **Use When:** Working in wimd-render-local location, local development sessions

**SESSION_RESTART_PROMPT.md** (`/Users/damianseguin/WIMD-Deploy-Project/SESSION_RESTART_PROMPT.md`)
- **Status:** OUTDATED - Specific to Dec 19 session
- **Purpose:** Historical record of Mosaic local enforcement activation attempt
- **Last Updated:** 2025-12-19
- **Authority:** Superseded by SESSION_RESUME_PROMPT.md
- **Use When:** Historical reference only

### Reconciliation Strategy

1. **Primary Protocol:** SESSION_RESUME_PROMPT.md (always read first)
2. **Supplement:** SESSION_START.md (for local development context)
3. **Integration:** Merge backup system verification from SESSION_START.md into SESSION_RESUME_PROMPT.md
4. **Archive:** Mark SESSION_RESTART_PROMPT.md as historical

---

## QUESTION 2: How to integrate INTENT_FRAMEWORK?

### Answer: Cross-cutting governance layer for all AI deliverables

**Integration Points Identified:**

1. **SESSION_RESUME_PROMPT.md** - Add INTENT framework requirement
   - Insert "Intent → Check → Receipt" pattern requirement
   - Add verification checklist item: "□ Shown Intent Doc for any deliverable"
   - Add to "CRITICAL REMINDERS" section

2. **TEAM_PLAYBOOK.md** - Update "MUST DO Before Any Code Changes"
   - Add: "0. Show Intent Doc (task, scope, sources, constraints, uncertainties)"
   - Add: "Wait for user confirmation (Proceed/Adjust/Stop)"
   - Add: "After completion, provide Receipt (sources used, judgment calls)"

3. **.ai-agents/ governance** - Create enforcement document
   - Location: `.ai-agents/INTENT_FRAMEWORK_ENFORCEMENT.md`
   - Purpose: How to validate INTENT pattern compliance
   - Integration: Reference from SESSION_RESUME_PROMPT.md

4. **Cross-Agent Adoption:**
   - Claude Code: MANDATORY (already aware via this session)
   - Gemini: Needs handoff document with INTENT framework
   - ChatGPT: Needs GDrive sync + handoff document

### Implementation Priority

**Immediate (This Session):**
- ✅ Copy INTENT_FRAMEWORK.md to AI_Workspace/.ai-agents/
- ✅ Update SESSION_RESUME_PROMPT.md to reference INTENT framework
- ✅ Document integration plan

**Short-Term (Next Session):**
- Update TEAM_PLAYBOOK.md with INTENT requirements
- Create handoff for Gemini with INTENT framework
- Test INTENT pattern on next deliverable

**Long-Term:**
- Create automated validation (check for Intent Doc before commits)
- Add Receipt generation to session_end.sh
- Integrate with pre-commit hooks

---

## QUESTION 3: Project location consolidation

### Answer: AI_Workspace is canonical, clear hierarchy established

**Canonical Location:**
```
/Users/damianseguin/WIMD-Deploy-Project
```

**Evidence:**
- CLAUDE.md header: "MANDATORY FIRST ACTION: Read .ai-agents/SESSION_RESUME_PROMPT.md"
- SESSION_RESUME_PROMPT.md: "Working Directory: /Users/damianseguin/WIMD-Deploy-Project"
- Git HEAD: 684dad3 (Dec 14) at AI_Workspace location
- .ai-agents/ folder: 146 files of governance documentation

**Location Hierarchy:**

1. **AI_Workspace** (PRIMARY)
   - Purpose: Active development, deployment, team coordination
   - Git repo: Yes (main branch, origin = wimd-render-deploy)
   - Status: CANONICAL
   - Use for: All code changes, Render deployment, session work

2. **wimd-render-local** (SECONDARY)
   - Purpose: Backup system development, local testing
   - Git repo: Yes (re-initialized Dec 2)
   - Status: SPECIALIZED
   - Use for: Backup system work, session_backups/, local dev testing

3. **Downloads** (ARCHIVE)
   - Purpose: Historical archive, protocol discovery
   - Git repo: Yes (October 2025 state preserved)
   - Status: READ-ONLY
   - Use for: Historical reference, protocol source documents

**No Consolidation Needed:**
- Locations serve different purposes
- Clear hierarchy prevents confusion
- Backup system requires separate location (wimd-render-local)
- Archive preserves historical working state

**Current Working Directory Verification:**
```bash
pwd  # Should show: /Users/damianseguin/WIMD-Deploy-Project
```

---

## QUESTION 4: Backup system final steps

### Answer: Version-controlled hooks + session backup integration

**Current State (as of 2026-01-04):**
- ✅ Post-commit hook restored at wimd-render-local
- ✅ Hook syncs to GDrive after commits
- ✅ Documentation created (BACKUP_SYSTEM_RECOVERY_LOG.md)
- ✅ SESSION_START.md updated with verification step

**Remaining TODOs from BACKUP_SYSTEM_RECOVERY_LOG.md:**

**TODO 1: Move to version-controlled hooks**
```bash
# Execute at wimd-render-local location
mkdir -p hooks
cp .git/hooks/post-commit hooks/post-commit
ln -sf ../../hooks/post-commit .git/hooks/post-commit
git add hooks/
git commit -m "Add version-controlled backup system hooks"
git push
```

**Benefits:**
- ✅ Hooks survive git clone
- ✅ Hooks tracked in version control
- ✅ Team members get hooks automatically
- ✅ Easy to update (edit hooks/post-commit, commit, push)

**TODO 2: Update session_end.sh to commit backups**
```bash
# Add to end of scripts/session_end.sh
echo "📤 Committing session backup to Git..."
git add session_backups/$TIMESTAMP/
git commit -m "Session backup: $TIMESTAMP" --no-verify
git push origin main

echo "✅ Session backup committed and synced to GDrive"
```

**Result:**
- ✅ Session backups committed to Git
- ✅ Git commit triggers post-commit hook
- ✅ Post-commit hook syncs to GDrive
- ✅ Claude.ai/ChatGPT can access backups

**TODO 3: Add verification to SESSION_RESUME_PROMPT.md**
```markdown
**Session Start Verification:**
□ Backup system active (test -x .git/hooks/post-commit)
□ If broken: Read BACKUP_SYSTEM_RECOVERY_LOG.md
□ GDrive sync log exists (/tmp/gdrive-sync.log)
□ Session backups directory exists (session_backups/)
```

**Timeline:**
- **Immediate:** Document TODOs (COMPLETE - this document)
- **Next Session (wimd-render-local work):** Implement TODO 1 (version-controlled hooks)
- **Next Session (wimd-render-local work):** Implement TODO 2 (session_end.sh update)
- **This Session:** Implement TODO 3 (update SESSION_RESUME_PROMPT.md)

---

## QUESTION 5: Current blocking issues to address

### Answer: Two critical blockers from different contexts

**BLOCKER GROUP A: Render Reset (From SESSION_RESUME_PROMPT.md)**

**Status:** CRITICAL - Blocking all Render work
**Last Updated:** 2025-12-15

1. **Render CLI Linking Ambiguity** (CRITICAL)
   - Description: `render list` detects `wimd-career-coaching`, but `render link -p "wimd-career-coaching"` fails
   - Impact: Prevents CLI-based operations, blocks all deployment work
   - Resolution: Requires user intervention (manual link via interactive CLI)
   - Source: `.ai-agents/RAILWAY_CLI_AMBIGUITY_REPORT.md`

2. **User Approval Missing for Render Reset**
   - User must review Render reset instruction packet
   - User must answer open questions (service name, migration strategy)
   - User must provide explicit: "APPROVED TO PROCEED"

**BLOCKER GROUP B: Mosaic MVP (From TEAM_PLAYBOOK.md)**

**Status:** SECURITY/RESILIENCE - Address after Render reset
**Last Updated:** 2025-12-03

1. **[SECURITY]** `/api/ps101/extract-context` lacks authentication
   - Source: `MOSAIC_MVP_IMPLEMENTATION/GEMINI_DAY_1_REVIEW.md`
   - Impact: API endpoint exposed without auth check
   - Priority: HIGH

2. **[RESILIENCE]** Claude API call needs timeout
   - Source: `MOSAIC_MVP_IMPLEMENTATION/GEMINI_DAY_1_REVIEW.md`
   - Impact: Hanging requests if Claude API slow
   - Priority: MEDIUM

3. **[RESILIENCE]** Claude API call needs retry logic with exponential backoff
   - Source: `MOSAIC_MVP_IMPLEMENTATION/GEMINI_DAY_1_REVIEW.md`
   - Impact: Fails on transient errors
   - Priority: MEDIUM

4. **[MINOR]** Schema version reporting shows v1 instead of v2 in `/config` endpoint
   - Source: `MOSAIC_MVP_IMPLEMENTATION/GEMINI_DAY_1_REVIEW.md`
   - Impact: Incorrect version display
   - Priority: LOW

### Work Order Priority

1. **FIRST:** Resolve Render CLI linking (requires user intervention)
2. **SECOND:** Complete Render reset (after user approval)
3. **THIRD:** Address Mosaic MVP blocking issues (security/resilience)
4. **FOURTH:** Implement backup system final steps (version-controlled hooks)

---

## QUESTION 6: Render deployment current state

### Answer: Deployment BROKEN - wrong GitHub repo connected

**Current State (From SESSION_RESUME_PROMPT.md):**

**Git State:**
```
HEAD: 684dad3 (Dec 14, 2025)
Branch: main
Remote origin: wimd-render-deploy (CORRECT repo)
Remote render-origin: what-is-my-delta-site (LEGACY, wrong repo)
```

**Render State:**
```
Project: wimd-career-coaching
Service: what-is-my-delta-site (404, not responding)
PostgreSQL: Unknown scope (awaiting validation - BLOCKED by CLI ambiguity)
Env vars backup: /tmp/render_env_backup.json (10 variables)
```

**Deployment Issue:**
```
Render watches: what-is-my-delta-site repo (WRONG)
Should watch: wimd-render-deploy repo (CORRECT)
Commits not deployed: 26+ (since Nov 11, 2025)
```

**Root Cause:**
- Render service connected to wrong GitHub repository
- Development happens in wimd-render-deploy (26+ commits)
- Render watches what-is-my-delta-site (legacy repo, no new commits)
- Result: Production is stale, 1.5 months behind

**Resolution Plan:**
- Phase 1: ✅ COMPLETE (forensic confirmation)
- Phase 2-7: BLOCKED (awaiting Render CLI fix + user approval)
- See: `.ai-agents/RAILWAY_RESET_INSTRUCTION_PACKET.md` for full plan

---

## QUESTION 7: Working directory for this session

### Answer: AI_Workspace is correct location

**Canonical Working Directory:**
```
/Users/damianseguin/WIMD-Deploy-Project
```

**Verification:**
```bash
pwd
# Should output: /Users/damianseguin/WIMD-Deploy-Project
```

**If in wrong location:**
```bash
cd /Users/damianseguin/WIMD-Deploy-Project
```

**Evidence:**
- SESSION_RESUME_PROMPT.md specifies this location
- CLAUDE.md references .ai-agents/ at this location
- Git HEAD (684dad3) at this location
- All recent work happens here

---

## SUMMARY: All Questions Answered

| Question | Answer | Source | Status |
|----------|--------|--------|--------|
| 1. Which SESSION_START canonical? | SESSION_RESUME_PROMPT.md (AI_Workspace) | CLAUDE.md, SESSION_RESUME_PROMPT.md | ✅ CLEAR |
| 2. How to integrate INTENT_FRAMEWORK? | Cross-cutting governance layer, integrate into protocols | INTENT_FRAMEWORK.md | ✅ PLAN DEFINED |
| 3. Project location consolidation? | AI_Workspace is canonical (no consolidation needed) | SESSION_RESUME_PROMPT.md, CLAUDE.md | ✅ CLEAR |
| 4. Backup system final steps? | Version-controlled hooks + session_end.sh updates | BACKUP_SYSTEM_RECOVERY_LOG.md | ✅ PLAN DEFINED |
| 5. Current blocking issues? | Render CLI + 4 Mosaic MVP issues | SESSION_RESUME_PROMPT.md, TEAM_PLAYBOOK.md | ✅ IDENTIFIED |
| 6. Render deployment state? | BROKEN - wrong repo connected, 26+ commits not deployed | SESSION_RESUME_PROMPT.md | ✅ DIAGNOSED |
| 7. Working directory? | AI_Workspace canonical location | SESSION_RESUME_PROMPT.md | ✅ CONFIRMED |

---

## NEXT ACTIONS

**For User:**
1. Review this answers document
2. Decide: Address Render CLI blocker OR continue with other work
3. If Render reset: Resolve CLI linking ambiguity, provide approval
4. If other work: Specify priority (INTENT framework integration, Mosaic MVP fixes, backup system)

**For Claude Code (This Session):**
1. ✅ Complete current state inventory
2. ✅ Answer all outstanding questions (THIS DOCUMENT)
3. ⏳ Await user direction on priority
4. ⏳ Implement INTENT_FRAMEWORK integration (if prioritized)
5. ⏳ Update SESSION_RESUME_PROMPT.md with backup verification (if prioritized)

---

**END OF ANSWERS DOCUMENT**
**Status:** All questions answered with evidence
**Confidence:** HIGH (all answers sourced from existing documentation)
**Recommendation:** User should review and confirm priority for next work
