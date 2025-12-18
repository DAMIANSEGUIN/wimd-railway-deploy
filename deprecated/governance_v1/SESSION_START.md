# SESSION START PROTOCOL

**Author**: Claude Code
**Created**: 2025-12-03
**Context**: Minimal gated startup to prevent "what should I work on" questions
**Purpose**: Enforce understanding before action
**Status**: Active - MANDATORY FOR ALL TEAM MEMBERS

---

## 🚨 CRITICAL: SESSION END MONITORING (ACTIVE ALL SESSION)

**YOU MUST MONITOR FOR THESE PHRASES IN EVERY USER MESSAGE:**

**Trigger Phrases:**

- "ending session"
- "end session"
- "session end"
- "wrap up"
- "that's all"
- "done for today"

**When ANY trigger phrase detected:**

1. **STOP** current work immediately
2. **RUN** `./scripts/session_end.sh` (no permission needed)
3. **PROMPT** user interactively for:
   - What was accomplished this session?
   - What should next session do?
   - Any new blocking issues?
   - Your AI name?
4. **COMPLETE** script execution
5. **CONFIRM** "Session end complete. Backup created at session_backups/[timestamp]/"

**This is AUTOMATIC. This is MANDATORY. This is NOT NEGOTIABLE.**

If you fail to detect session end trigger, the session state will NOT be saved and next session will start from stale state.

---

## GATE 1: UNDERSTANDING MODE (MANDATORY)

You are now in **UNDERSTANDING MODE**. You may NOT write code, create files, or propose solutions until you pass all gates.

### Required Actions (Complete in Order)

**□ 1. Read `TEAM_PLAYBOOK.md` Section 1 (Quick Start) - 5 minutes**

**□ 2. Read `TEAM_PLAYBOOK.md` Section 2 (Current Sprint Status) - 2 minutes**

- Note the "BLOCKING ISSUES" section
- Note the "CODE STATE" section
- Check `api/index.py` lines 1-18 for current version

**□ 3. Read current blocking issue sources:**

- `MOSAIC_MVP_IMPLEMENTATION/GEMINI_DAY_1_REVIEW.md`

**□ 4. Read MANDATORY safety documents:**

- `TROUBLESHOOTING_CHECKLIST.md` (scan error taxonomy)
- `SELF_DIAGNOSTIC_FRAMEWORK.md` (scan sacred patterns)

---

## GATE 2: VERIFICATION (PROVE UNDERSTANDING)

**You must answer these questions before proceeding:**

### Q1: What is the current code version?

**Where to find answer**: `api/index.py` lines 1-18

### Q2: How many BLOCKING ISSUES exist right now?

**Where to find answer**: `TEAM_PLAYBOOK.md` Section 2 "BLOCKING ISSUES"

### Q3: What is the rollback path if you break something?

**Where to find answer**: `api/index.py` lines 1-18 ROLLBACK_PATH

### Q4: What pattern MUST you use for database operations?

**Where to find answer**: `TROUBLESHOOTING_CHECKLIST.md` Code Pattern Filters

---

## GATE 3: DECISION TREE (WHAT TO WORK ON)

### IF Blocking Issues > 0

→ **WORK ON BLOCKING ISSUES FIRST**
→ Do NOT ask "what should I work on"
→ Address them in priority order: SECURITY > RESILIENCE > MINOR

### IF Blocking Issues = 0

→ **Check "NEXT TASK" in TEAM_PLAYBOOK.md Section 2**
→ Do NOT ask "what should I work on"
→ Work on the documented next task

### IF you're unclear about a task

→ **READ the source document listed in TEAM_PLAYBOOK.md**
→ Example: "see IMPLEMENTATION_REFINEMENT_Claude-Gemini.md"
→ Do NOT ask user to explain - read the documentation first

### IF documentation is unclear after reading

→ **STATE what you read and what specific part is unclear**
→ Do NOT say "I don't know what to work on"
→ Say "I read [document X, section Y], but [specific question]"

---

## ENFORCEMENT RULES

### ❌ FORBIDDEN QUESTIONS (AUTOMATIC PROTOCOL VIOLATION)

- "What should I work on?"
- "What's the priority?"
- "Where do I start?"
- "Which option do you want?" (when both options are documented in playbook)
- "Should I do X or Y?" (when decision criteria exists in playbook)

**CRITICAL: User does NOT make technical decisions. Playbook documents decision criteria. If you ask user to choose, you are violating protocol.**

### ✅ ALLOWED QUESTIONS (After reading docs)

- "I read [X], but [specific unclear part] - can you clarify?"
- "The playbook says [criteria], but I found [exception] - how should I proceed?"

### ❌ FORBIDDEN ACTIONS (AUTOMATIC PROTOCOL VIOLATION)

- Asking user to decide between technical options when playbook has decision criteria
- Asking user for priorities when TEAM_PLAYBOOK.md Section 2 documents priorities
- Presenting "Option 1 vs Option 2" when one is clearly the workaround and playbook says "use workarounds for blockers"

### 🚫 SESSION WILL BE STOPPED IF

- You ask forbidden questions
- You ask user to make decisions that are documented in playbook
- You skip reading required documents
- You propose code changes before passing gates
- You claim confusion without citing what you read
- You present options to user instead of executing based on documented protocol

---

## GATE PASSAGE CONFIRMATION

**When you've completed all gates, report:**

```
GATES PASSED:
✅ Read TEAM_PLAYBOOK.md Sections 1 & 2
✅ Read blocking issue sources
✅ Read safety documents (TROUBLESHOOTING_CHECKLIST, SELF_DIAGNOSTIC_FRAMEWORK)
✅ Verified current code version: [VERSION]
✅ Verified blocking issues count: [NUMBER]
✅ Verified rollback path: [PATH]

READY TO WORK ON:
[Blocker #X] or [Next Task from playbook]

CONFIRMATION: I will NOT ask "what should I work on" - it's documented in TEAM_PLAYBOOK.md Section 2.
```

---

## TL;DR (Minimal Version for Copy-Paste)

**Every session start:**

1. Read `TEAM_PLAYBOOK.md` Sections 1 & 2
2. Check blocking issues in Section 2
3. If blockers exist: work on them (priority: SECURITY > RESILIENCE > MINOR)
4. If no blockers: work on "NEXT TASK" in Section 2
5. Never ask "what should I work on" - it's always in Section 2

**Current code state**: Always check `api/index.py` lines 1-18

**Rollback if you break things**: See `api/index.py` ROLLBACK_PATH

---

---

## SESSION END TRIGGER

**When user says "ending session" or similar:**

Run this command:

```bash
./scripts/session_end.sh
```

This will:

1. Backup critical files (JSON configs, Python files) to `session_backups/[timestamp]/`
2. Prompt you for session summary
3. Update `TEAM_PLAYBOOK.md` Section 2 with current state
4. Record git commit hash and backup location

**DO NOT end session without running this script.**

---

**END OF SESSION START PROTOCOL**
