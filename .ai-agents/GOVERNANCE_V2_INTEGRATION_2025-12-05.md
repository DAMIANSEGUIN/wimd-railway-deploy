# Governance v2 Integration Complete - 2025-12-05

**From:** Claude Code
**To:** Gemini & Codex
**Date:** 2025-12-05
**Priority:** HIGH - Action Required

---

## 📢 IMPORTANT: Governance System Updated

The Mosaic project has been upgraded from Governance v1 to **Governance v2**. This is a **mandatory** change that affects how all AI agents (including you) must operate.

---

## ✅ What Was Done

### 1. New Governance Files Deployed (Project Root)

Four new governance files are now **active and mandatory**:

- **Mosaic_Governance_Core_v1.md** (6,825 bytes)
  - Top-level governance rules that ALL agents must follow
  - Defines modes: INIT, BUILD, DIAGNOSE, REPAIR, VERIFY, HANDOFF
  - Execution integrity rules (No Unverified Path, No Obsolete Code, etc.)

- **TEAM_PLAYBOOK_v2.md** (6,081 bytes)
  - Operational contract and behavior rules
  - Role definitions and decision hierarchy
  - Safety rules and prohibited behaviors

- **SESSION_START_v2.md** (3,408 bytes)
  - Required steps for starting any Mosaic session
  - INIT mode protocol
  - Preflight checks and governance confirmation

- **SESSION_END_OPTIONS.md** (2,183 bytes)
  - 7 session termination commands
  - SESSION_END, SESSION_HARD_STOP, SESSION_ABORT, etc.
  - Proper handoff procedures

### 2. Old Governance Files Archived

The old governance files have been moved to `deprecated/governance_v1/`:

- `deprecated/governance_v1/TEAM_PLAYBOOK.md` (old version)
- `deprecated/governance_v1/SESSION_START.md` (old version)

**DO NOT use these old files.** They are kept for reference only.

### 3. Documentation Updated

The following files now reference the new governance system:

- **`.ai-agents/START_HERE.md`**
  - Updated "Critical Files" section to list all 4 governance files
  - Updated "Last Updated" timestamp to 2025-12-05

- **`README.md`**
  - "Essential Documentation" section updated
  - Governance files listed as #1-4 priority

- **`AI_START_HERE.txt`**
  - Updated to "GOVERNANCE v2 IS NOW ACTIVE"
  - Lists all 4 files to read IN ORDER
  - System version bumped to 3.0

---

## 🎯 ACTION REQUIRED: What You Must Do

### For Your Next Session Start:

**YOU MUST READ THESE FILES IN ORDER:**

1. **Mosaic_Governance_Core_v1.md** - Read this FIRST
   - Understand the 6 modes (INIT, BUILD, DIAGNOSE, REPAIR, VERIFY, HANDOFF)
   - Learn the Execution Integrity rules
   - Know when to Stop on Ambiguity

2. **TEAM_PLAYBOOK_v2.md** - Read this SECOND
   - Understand your role and obligations
   - Learn the decision hierarchy
   - Know the prohibited behaviors

3. **SESSION_START_v2.md** - Read this THIRD
   - Follow this protocol at the start of EVERY session
   - Enter INIT mode before doing ANY work
   - Confirm project, read NEXT_TASK, acknowledge governance

4. **SESSION_END_OPTIONS.md** - Reference as needed
   - Use the correct termination command when ending sessions
   - Proper handoff procedures for multi-agent work

### Quick Start Command:

```bash
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
cat AI_START_HERE.txt
```

This will show you the updated protocol.

---

## 🔴 CRITICAL CHANGES FROM v1 TO v2

### 1. Mode System is Now Mandatory

You MUST explicitly declare your mode and operate within its constraints:

- **INIT Mode:** Restore context only - NO code generation
- **BUILD Mode:** Create/modify code - requires preflight checks
- **DIAGNOSE Mode:** Analyze errors - NO code changes
- **REPAIR Mode:** Fix defects with minimal changes
- **VERIFY Mode:** Confirm assumptions before proceeding
- **HANDOFF Mode:** End session and prepare for next agent

### 2. Stop-On-Ambiguity Rule

If you are uncertain about:
- File paths
- Project scope
- Environment state
- User intent

You MUST **STOP** and **ASK** - do NOT guess or assume.

### 3. No Unverified Path Rule

You MUST NOT use any file path until it has been:
- Explicitly verified by reading/checking
- Confirmed by repository inspection
- Validated in the current session

### 4. Receive Before Acting

At session start, you MUST:
1. Restate your understanding of the project
2. Restate the current NEXT_TASK
3. Declare your intended mode (BUILD or DIAGNOSE)
4. Ask for confirmation before proceeding

### 5. Session Termination Commands

When ending a session, use the appropriate command:
- `SESSION_END` - Standard termination
- `SESSION_HARD_STOP` - Strict boundary (no new tasks)
- `SESSION_HANDOFF` - Multi-agent handoff
- `SESSION_FREEZE` - End-of-day preservation
- `SESSION_ABORT` - Emergency stop

---

## 📊 Integration Verification

**Status:** ✅ COMPLETE

- All 4 new governance files present in project root
- Old files properly archived in `deprecated/governance_v1/`
- 26 references found across 7 documentation files
- No broken references detected

**Verification Command:**
```bash
ls -la *.md | grep -E "(Mosaic_Governance|TEAM_PLAYBOOK_v2|SESSION_START_v2|SESSION_END)"
```

---

## 💡 Why This Matters

**Previous issues caused by lack of governance:**
- Agents starting work without understanding project state
- Code changes without verification
- Guessing file paths and breaking things
- No clear handoff between agents
- Inconsistent behavior across sessions

**Governance v2 solves these by:**
- Enforcing explicit mode declarations
- Requiring verification before action
- Standardizing session start/end procedures
- Preventing ambiguous operations
- Creating clear multi-agent handoff protocols

---

## 📝 Notes for Specific Agents

### For Gemini (Terminal):
- You are the **Senior Software Engineer & Planning Lead**
- Your sessions MUST start with INIT mode
- Follow SESSION_START_v2.md protocol exactly
- When planning, declare your mode clearly
- Use SESSION_HANDOFF when passing work to other agents

### For Codex (Cursor):
- You are the **Local Implementation Engineer**
- Before writing ANY code, enter BUILD mode properly
- Run preflight checks (verify paths, environment)
- Follow the Context Manager pattern rules
- Use SESSION_END when your implementation is complete

---

## 🔗 Related Documentation

**Read after governance files:**
- `TROUBLESHOOTING_CHECKLIST.md` - Error prevention
- `SELF_DIAGNOSTIC_FRAMEWORK.md` - Error handling patterns
- `CLAUDE.md` - Architecture overview
- `.ai-agents/START_HERE.md` - Quick start guide

---

## ❓ Questions?

If you have questions about the new governance system:
1. Re-read the relevant governance file
2. Check SESSION_START_v2.md for clarification
3. Ask the user for guidance if still unclear

**DO NOT:**
- Ignore the governance files
- Use the old v1 files
- Operate without declaring your mode
- Skip the INIT mode at session start

---

## 📈 API Usage Note

This integration session used:
- **Tokens used:** 71,522 / 200,000 (35.8%)
- **Estimated cost:** ~$0.21

The new governance system should actually **reduce** token usage over time by:
- Preventing wasted work from wrong assumptions
- Reducing back-and-forth clarification
- Stopping errors before they happen

---

## ✅ Checklist for Your Next Session

```
□ Read Mosaic_Governance_Core_v1.md
□ Read TEAM_PLAYBOOK_v2.md
□ Read SESSION_START_v2.md
□ Read SESSION_END_OPTIONS.md
□ Enter INIT mode at session start
□ Confirm project and NEXT_TASK
□ Declare your intended mode
□ Request user confirmation before proceeding
□ Use proper SESSION_END command when done
```

---

**Document Name:** `GOVERNANCE_V2_INTEGRATION_2025-12-05.md`
**Location:** `.ai-agents/GOVERNANCE_V2_INTEGRATION_2025-12-05.md`
**Status:** Ready for Gemini & Codex review

---

**Claude Code out. 🎯**
