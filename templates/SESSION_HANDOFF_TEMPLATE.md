# EMERGENCY SESSION HANDOFF
**Session Limit Reached - Incomplete Task**

Generated: [YYYY-MM-DD HH:MM:SS]
Session Type: [Web Interface / API Mode]
Agent: [Claude / ChatGPT / Other]

---

## 1. CURRENT TASK STATUS: **INCOMPLETE**

### Task Description
[Describe what task was being worked on - be specific]

### Progress Completed
- [x] Step 1: [what was done]
- [x] Step 2: [what was done]
- [ ] Step 3: [what was NOT done yet] ← **STOPPED HERE**
- [ ] Step 4: [remaining work]
- [ ] Step 5: [remaining work]

### Completion Estimate
- Overall progress: [X]% complete
- Time spent: [X] minutes
- Estimated remaining: [X] minutes

---

## 2. WORK IN PROGRESS

### Files Modified (Not Yet Committed)
```
[File path 1] - [description of changes]
[File path 2] - [description of changes]
[File path 3] - [description of changes]
```

### Git Status
```bash
# Run: git status
[paste output here if available]
```

### Uncommitted Changes
- [ ] No uncommitted changes
- [x] Uncommitted changes exist (see above)

---

## 3. CURRENT STEP DETAIL

### Exact Stopping Point
[Describe the EXACT point where work stopped - e.g., "About to edit line 45 of api/index.py to add error handling"]

### Next Action (First Thing To Do)
[Be extremely specific - e.g., "Open api/index.py, locate the function `handle_request()` at line 42, add try/except block around database call"]

### Why This Approach
[Explain why this particular solution/approach was chosen, so resuming agent understands the reasoning]

---

## 4. CONTEXT TO PRESERVE

### Key Decisions Made This Session
1. [Decision 1 and rationale]
2. [Decision 2 and rationale]
3. [Decision 3 and rationale]

### Assumptions
- [Assumption 1 - e.g., "Assuming PostgreSQL connection is stable"]
- [Assumption 2]
- [Assumption 3]

### User Preferences Stated
- [Preference 1 - e.g., "User wants minimal changes to existing code"]
- [Preference 2]
- [Preference 3]

### Blockers/Issues Encountered
- [Blocker 1 - e.g., "Discovered that function X is called from 3 places, need to update all"]
- [Blocker 2]
- [Resolution attempts made]

---

## 5. CODE SNIPPETS IN PROGRESS

### Code Being Written (Not Yet Saved)
```python
# File: [filename]
# Location: [line number or function name]
# Status: [partially written / needs testing / ready to save]

[paste code snippet here]
```

### Alternative Approaches Considered
```
Approach 1: [description] - Rejected because [reason]
Approach 2: [description] - Chosen because [reason]
Approach 3: [description] - Might revisit if Approach 2 fails
```

---

## 6. VERIFICATION CHECKLIST (For Resuming Agent)

When resuming this task, the agent MUST:
- [ ] Read this entire emergency handoff document
- [ ] Verify current git status matches description above
- [ ] Verify files listed as modified still have expected changes
- [ ] Confirm with user the "Next Action" is still correct
- [ ] Ask if any context has changed since handoff
- [ ] Resume from exact stopping point (not restart from beginning)

---

## 7. RECOVERY INSTRUCTIONS

### For User:
1. Open new session (API mode recommended if web hit limit)
2. State: "Start Mosaic Session in API mode - resuming incomplete task"
3. Provide agent with this filename: `SESSION_HANDOFF_EMERGENCY_[timestamp].md`
4. Confirm details are still accurate
5. Authorize agent to continue

### For Agent:
1. Load this file during initialization (Step 4 of API mode protocol)
2. Note **INCOMPLETE** status prominently
3. Restate stopping point and next action to user
4. Get explicit confirmation before resuming work
5. Do NOT restart task from beginning - resume from exact stopping point

---

## 8. RELATED FILES

### Files to Read Before Resuming
- [Related file 1 - why it matters]
- [Related file 2 - why it matters]
- [Related file 3 - why it matters]

### Recent Session Handoffs (Context)
- [Previous handoff file - date] - [brief description of what was done]

---

## 9. ORIGINAL NEXT_TASK

**From TEAM_STATUS.json or user directive:**
```
[Copy original NEXT_TASK here for reference]
```

**Modified for this specific work:**
```
[If task was refined/scoped during session, note the modification]
```

---

## 10. SESSION METADATA

- Session started: [timestamp]
- Session ended: [timestamp] (emergency)
- Duration: [X] minutes
- Mode: [Web Interface / API]
- Model: [Claude Sonnet / GPT-4 / etc.]
- Interruption reason: [Session limit reached / Browser crash / Other]

---

## NOTES

[Any additional context, warnings, or observations that don't fit above categories]

---

**EMERGENCY HANDOFF COMPLETE**

This document should allow seamless resumption of work by any agent in any mode.

If resuming in different environment (web→API or API→web), extra care needed to:
- Verify file changes visible in new environment
- Reload all governance files (API mode requirement)
- Confirm git state before continuing
