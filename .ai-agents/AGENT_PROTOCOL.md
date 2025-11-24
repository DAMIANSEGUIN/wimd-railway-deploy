# Agent Protocol - MANDATORY RULES

**All AI agents must follow these rules. No exceptions.**

---

## Rule 1: When User Asks a Question - ANSWER, DON'T ACT

**User asks:** "Should we rename session_end.sh?"

❌ **WRONG:**
```
[Agent immediately runs: git mv session_end.sh commit_work.sh]
```

✅ **CORRECT:**
```
Analysis: session_end.sh name causes confusion (Gemini interpreted as shutdown signal)

Recommendation: Rename to commit_work.sh

Impact: Need to update references in docs, scripts

Approve to proceed?
```

**Rule:**
- User question = they want discussion/recommendation
- Wait for explicit approval before making changes
- Exception: User says "do it" or "proceed" or "yes"

---

## Rule 2: When New Documentation is Created - READ IT

**Scenario:** Another agent creates/updates documentation

**You must:**
1. Read the file before taking next action
2. If file is referenced in TEAM_STATUS.json or commit message, it's mandatory reading
3. Don't guess what it says - actually read it

**Examples of mandatory reading:**
- New protocol docs (.ai-agents/*.md)
- Updated methodology (AI_TEAM_METHODOLOGY.md)
- New coordination files (TEAM_STATUS.json format changes)
- Any file mentioned in "Read this: [filename]" instructions

**How to know if you should read:**
- Check commit messages for "Created X" or "Updated X"
- Check TEAM_STATUS.json for doc references
- If unsure, ask user: "Should I read X before proceeding?"

---

## Rule 3: When You Complete Work - GENERATE SHAREABLE NOTE

**MANDATORY: Every completed task requires a shareable note for user to send to other agents.**

### Format:

```markdown
# [Task ID] Complete - [Date]

**Agent:** [Your name]
**Commit:** [hash]

## What Was Done
- [Bullet points of actual changes made]

## Files Changed
- path/to/file1.ext
- path/to/file2.ext

## What Other Agents Need to Know
- [Any breaking changes, new protocols, files to read]

## Next Task
- [Who should work on what next, from TEAM_STATUS.json queue]

---
**Share this note with the team.**
```

### Example:

```markdown
# P0.2 Complete - 2025-11-24

**Agent:** Gemini
**Commit:** a1b2c3d

## What Was Done
- Consolidated session documentation into status.sh/commit_work.sh pattern
- Marked old handoff docs as deprecated
- Updated AI_START_HERE.txt to point to new system

## Files Changed
- .ai-agents/SESSION_START_PROTOCOL.md (deprecated notice added)
- .ai-agents/HANDOFF_PROTOCOL.md (deprecated notice added)
- AI_START_HERE.txt (simplified to one command)
- scripts/README.md (updated for new flow)

## What Other Agents Need to Know
- Old CURRENT_WORK.json pattern is deprecated
- New pattern: TEAM_STATUS.json (lean coordination)
- Read: TEAM_STATUS.json format in scripts/commit_work.sh

## Next Task
- P0.3: User confirms methodology (User reviews AI_TEAM_METHODOLOGY.md)
- P1.1: User manually checks production health

---
**Share this note with the team.**
```

### When to Generate This Note

**Always generate after:**
- Completing assigned task from TEAM_STATUS.json
- Fixing a bug
- Creating new documentation/protocol
- Making architectural changes
- Any work that other agents need to know about

**Don't generate for:**
- Just reading files (unless asked to report findings)
- Asking clarifying questions
- Running status.sh

---

## Rule 4: Use `commit_work.sh` Only When Actually Done

**Do NOT run `commit_work.sh` if:**
- You're not sure if task is complete
- You hit a blocker
- You're just pausing to think
- User hasn't confirmed the work is acceptable

**DO run `commit_work.sh` when:**
- Task from TEAM_STATUS.json is 100% complete
- All files committed, tests pass
- You've generated the shareable note (Rule 3)

**Format for answering the 3 questions:**
1. Task ID: (e.g., "P0.2", "bug-fix-login", "feature-search")
2. Status: "done" (if complete), "blocked" (if stuck), "in-progress" (if continuing later)
3. Blocker: (only if status = blocked, explain what's blocking you)

---

## Rule 5: Interpreting Script Names

**Don't assume script names mean "do this now"**

- `commit_work.sh` = "Run when you finish your assigned task"
- `status.sh` = "Run at session start to see current state"
- `verify_critical_features.sh` = "Run before deploying"

**Script names are tools, not commands.**

If you're unsure when to run a script, check:
1. The script's header comments
2. Documentation references
3. Ask user: "When should I run X?"

---

## Rule 6: Session Lifecycle

**Start of session:**
```bash
./scripts/status.sh
# Read TEAM_STATUS.json
# Identify your assigned task
# Begin work
```

**During work:**
- Make commits as you go (normal git workflow)
- Update user on blockers immediately
- Don't run commit_work.sh yet

**End of work (task complete):**
1. Generate shareable note (Rule 3)
2. Run `./scripts/commit_work.sh`
3. Answer 3 questions
4. Push commits

**The note comes BEFORE commit_work.sh, not after.**

---

## Enforcement

**These rules are mandatory because:**
- User shouldn't be intermediary between agents
- Other agents need clear handoffs
- Changes need documentation
- Questions need discussion before action

**If you skip these rules:**
- Other agents get confused
- Work gets duplicated
- Context gets lost
- User has to manually intervene

---

## Quick Reference

| Situation | Action |
|-----------|--------|
| User asks question | Answer + recommend, wait for approval |
| New doc created | Read it before next action |
| Task complete | Generate note, then run commit_work.sh |
| Hit blocker | Tell user immediately, don't guess |
| Unsure if done | Ask user, don't run commit_work.sh |
| See script name | Read header comments, don't assume |

---

**END OF PROTOCOL**
