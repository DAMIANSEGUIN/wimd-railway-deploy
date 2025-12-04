# Team Documentation Reference

**Last Updated:** 2025-11-27T20:35:00Z
**Purpose:** Central index of all team documentation for handoffs

---

## Core Project Documentation

### Architecture & Status
- **`CLAUDE.md`** - System architecture, deployment commands, current status
- **`AI_RESUME_STATE.md`** - Current session state, bugs, resolutions, backups
- **`docs/README.md`** - Restart protocol, environment setup, deployment guide

### Quality & Debugging
- **`TROUBLESHOOTING_CHECKLIST.md`** - Pre-flight checks, error classification, debugging workflow
- **`SELF_DIAGNOSTIC_FRAMEWORK.md`** - Error taxonomy, playbooks, auto-triage system

---

## Team Handoff Documents (`.ai-agents/`)

### Gemini (Architecture/Planning)
- **`GEMINI_PS101_FIX_APPROVAL_2025-11-26.md`** - Architectural decision on PS101 scope fix
- **`FOR_GEMINI_PS101_TESTING_BUGS_2025-11-26.md`** - Bug report requiring architectural review
- **`CLAUDE_TO_GEMINI_PS101_RESOLUTION_2025-11-27.md`** - Resolution report with strategic questions

### Codex (Debugging/Testing)
- **`FOR_CODEX_PS101_DEBUGGING_2025-11-27.md`** - Debugging handoff with testing instructions
- **`CODEX_READ_THIS_FIRST.txt`** - Codex role and workflow overview
- **`CODEX_AGENT_WORKFLOW.md`** - Detailed debugging workflow
- **`CODEX_AGENT_BROWSER_GUIDE.md`** - Browser testing guide

### Claude Code (Implementation)
- **`FOR_GEMINI_PS101_HOISTING_ISSUE_2025-11-26.md`** - Original hoisting issue report
- **`CURRENT_BACKUP_REFERENCE.md`** - Always points to latest backup

---

## Backup Documentation

### Current Backups
- **`backups/post-restore_20251127_171057Z/BACKUP_MANIFEST.md`** - Latest (post-restoration)
- **`backups/pre-scope-fix_20251126_233100Z/BACKUP_MANIFEST.md`** - Pre-scope-fix (source)

### Backup Protocol
All backups include:
- Timestamped directory name (YYYYMMDD_HHMMSSZ)
- BACKUP_MANIFEST.md explaining what/why/how
- Affected files (mosaic_ui_index.html, frontend_index.html)

---

## Team Roles & Responsibilities

### Gemini - Strategic Planning & Architecture
**Reads:**
- Bug reports from Claude (`FOR_GEMINI_*`)
- Resolution reports from Claude (`CLAUDE_TO_GEMINI_*`)
- Architecture documentation (`CLAUDE.md`, `TROUBLESHOOTING_CHECKLIST.md`)

**Writes:**
- Architectural decisions (`GEMINI_*_APPROVAL_*.md`)
- Strategic guidance documents
- Implementation plan updates

**Does NOT:**
- Write code
- Debug runtime issues
- Deploy

### Claude Code - Implementation & Deployment
**Reads:**
- All project documentation
- Gemini's architectural decisions
- Codex's debugging findings

**Writes:**
- Code edits
- Bug reports for Gemini (`FOR_GEMINI_*.md`)
- Debugging handoffs for Codex (`FOR_CODEX_*.md`)
- Resolution reports (`CLAUDE_TO_GEMINI_*.md`)
- Backup manifests
- AI_RESUME_STATE.md updates

**Does:**
- File operations (read/edit/write)
- Git operations
- Deployment scripts
- Create backups

**Does NOT:**
- Make architectural decisions without approval
- Debug in browser (hands to Codex)

### Codex - Debugging & Testing
**Reads:**
- Debugging handoffs from Claude (`FOR_CODEX_*.md`)
- Project architecture docs
- Troubleshooting checklists

**Writes:**
- Debugging findings (`CODEX_DEBUGGING_FINDINGS_*.md`)
- Test results
- Console error reports

**Does:**
- Start local server
- Test in browser
- Inspect console errors
- Root cause analysis
- Recommend fixes

**Does NOT:**
- Implement fixes (reports to Claude)
- Make architectural decisions (escalates to Gemini)

---

## Handoff Protocol

### When Handing Off Work

**1. Create Handoff Document**
- File name: `FOR_[RECIPIENT]_[TOPIC]_[DATE].md`
- Include: Summary, context, specific task, deliverable format
- Location: `.ai-agents/`

**2. Update AI_RESUME_STATE.md**
- Current status
- Latest backup location
- Next steps
- Team member assignments

**3. Provide Chat Message**
Format:
```
[Your Role] completed [task]

Created:
- [handoff doc path]
- [backup path if applicable]

For [Next Role]:
- Read [specific file]
- Task: [clear action]
- Deliverable: [what to create]

Status: [COMPLETE/IN_PROGRESS/BLOCKED]
```

### When Receiving Handoff

**1. Read Required Docs (in order)**
- AI_RESUME_STATE.md
- Your handoff document (FOR_[YOU]_*.md)
- Related context docs

**2. Confirm Understanding**
Reply with:
- What you understand the task to be
- What you'll deliver
- Any blockers

**3. Execute & Document**
- Do the work
- Create deliverable (findings/code/decisions)
- Update AI_RESUME_STATE.md
- Create next handoff if needed

---

## Current State (2025-11-27 20:35Z)

**Active Issue:** PS101 hoisting error - function not advancing
**Status:** TESTING PHASE - Gemini's systematic recovery plan in progress

**Current Deployment:**
- **Restored Backup:** `pre-ps101-fix_20251126_220704Z`
- **Location:** `mosaic_ui/index.html`
- **Server:** Running on http://localhost:3000 (PID 27327)
- **Dummy File Created:** `mosaic_ui/js/main.js` (prevents 404 error)

**Test Results (User Verified):**
- ✅ Login: Works
- ✅ Chat: Works (UI functional)
- ❌ PS101: Does NOT forward (known hoisting error - `handleStepAnswerInput` line 3759 called from line 2530)

**Recovery Plan Progress (Gemini's Directive):**
- ✅ Step 1: Safe test environment created
- ✅ Step 2: Test `pre-ps101-fix` backup (Login/Chat verified working)
- ⏳ Step 3: Test `pre-scope-fix` backup (PS101 advancement) - PENDING
- ⏳ Step 4: Gemini architectural decision - PENDING

**Key Documents for Current Session:**
- **`.ai-agents/GEMINI_RECOVERY_PLAN_2025-11-27.md`** - Gemini's authoritative recovery plan
- **`.ai-agents/FOR_GEMINI_CRITICAL_REGRESSION_2025-11-27.md`** - Claude's incident report to Gemini
- **`.ai-agents/EMERGENCY_USER_DIRECTIVE_2025-11-27.md`** - User's emergency directive
- **`.ai-agents/DEPLOYMENT_PROTOCOL_MANDATORY.md`** - New mandatory protocols to prevent recurrence
- **`CRITICAL_RESTART_CONTEXT.md`** - Root cause analysis and lessons learned
- **`AI_RESUME_STATE.md`** - Current session state (may be outdated, use this doc instead)

**Backup Locations:**
- **Working (Login/Chat):** `backups/pre-ps101-fix_20251126_220704Z/`
- **Testing (PS101):** `backups/pre-scope-fix_20251126_233100Z/` (Step 3 pending)
- **Test Environment:** `temp_test_environment/` (Gemini created)

**Next Actions:**
- Awaiting Gemini's directive for Step 3 (test second backup for PS101 advancement)
- Once baseline chosen: Fix hoisting issue OR merge functionality from both backups
- User verification required before any deployment

**Waiting For:**
- **Gemini:** Step 3 testing instructions OR final architectural decision based on test results

**📋 THIS DOCUMENT:** `.ai-agents/TEAM_DOCUMENTATION_REFERENCE.md`
- **Read this first** when starting any session
- Always has current state, key documents, and next actions
- Updated after major handoffs

---

## Version Control & Rollback

**Last Known Working Version:**
- **Git Tag:** `prod-2025-11-18`
- **Commit:** `31d099c`
- **Restore Command:** `git checkout prod-2025-11-18`

**Check Current Version:**
```bash
git describe --tags --abbrev=0
```

**List Production Tags:**
```bash
git tag -l "prod-*" --sort=-version:refname | head -5
```

**Create New Production Tag (after verified deployment):**
```bash
git tag prod-$(date +%Y-%m-%d)
git push origin prod-$(date +%Y-%m-%d)
```

**See Full Details:** Check `TROUBLESHOOTING_CHECKLIST.md` → "LAST KNOWN WORKING VERSION" section

---

## Quick Reference Commands

**Start session:**
```bash
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
cat AI_RESUME_STATE.md
```

**For Codex:**
```bash
python3 local_dev_server.py
# Open http://localhost:3000 in browser
```

**Create backup:**
```bash
BACKUP_DIR="backups/[purpose]_$(date -u +%Y%m%d_%H%M%S)Z"
mkdir -p "$BACKUP_DIR"
cp mosaic_ui/index.html "$BACKUP_DIR/mosaic_ui_index.html"
# Create BACKUP_MANIFEST.md
```

**Restore backup:**
```bash
cp backups/[backup_dir]/mosaic_ui_index.html mosaic_ui/index.html
```

---

**This document maintained by:** Claude Code
**Review frequency:** After each major handoff
**Questions?** Check AI_RESUME_STATE.md for current status
