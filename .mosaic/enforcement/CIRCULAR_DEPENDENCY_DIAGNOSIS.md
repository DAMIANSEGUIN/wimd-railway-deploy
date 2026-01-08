# Circular Dependency Root Cause Analysis

**Problem:** agent_state.json cannot stay in sync with git HEAD due to circular dependency.

**Date:** 2026-01-08
**Severity:** CRITICAL - Breaks handoff validation

---

## The Circular Dependency

### Current (Broken) Workflow

```
1. Agent does work (edits files)
   → git status: modified files

2. Agent commits work
   → Commit A created
   → git HEAD = A

3. Agent runs pre-handoff validation
   → Test: agent_state.json:last_commit == git HEAD?
   → FAIL: agent_state.json still has old commit

4. Agent updates agent_state.json
   → Set last_commit = A
   → git status: modified .mosaic/agent_state.json

5. Agent commits state update
   → Commit B created
   → git HEAD = B

6. NOW: agent_state.json (inside commit B) says last_commit=A
   BUT: git HEAD = B

7. Next session runs post-handoff validation
   → Test: agent_state.json:last_commit == git HEAD?
   → FAIL: state says A, HEAD is B
```

### Why It's Circular

**To make agent_state.json:last_commit match git HEAD:**
- You must update agent_state.json
- Updating creates a git commit
- Creating a commit changes git HEAD
- Therefore agent_state.json can NEVER match the commit it's inside

**This is mathematically impossible to solve** with the current workflow.

---

## Evidence

### Instance 1: 2026-01-08 (This Session)

```bash
# I did work, created commits
# Final commit: 7ebfc97

# I updated agent_state.json to say last_commit: 7ebfc97
# Committed that update → created commit 7bfab97

# Result:
# - agent_state.json (inside 7bfab97) says: last_commit: 7ebfc97
# - git HEAD = 7bfab97
# - State out of sync by one commit
```

### Instance 2: Earlier Today

Pre-handoff validation gave warning:
```
⚠️  WARNINGS (non-blocking):
  - HEAD is agent_state.json update commit (expected pattern)
```

I called this "expected pattern" and allowed it.
**This was wrong** - it's a sign the system is broken.

---

## Why Previous "Fixes" Failed

### Fix Attempt 1: Warning Instead of Failure

```python
if files_changed == ['.mosaic/agent_state.json']:
    self.warnings.append("HEAD is agent_state.json update commit (expected pattern)")
```

**Result:** I ignored the warning and proceeded anyway.

### Fix Attempt 2: Accept One-Commit Lag

Logic: "If HEAD is agent_state.json-only update, allow last_commit to be HEAD~1"

**Problem:** Still creates permanent one-commit lag between sessions.

---

## Root Cause

**The fundamental flaw:** Trying to store the current commit hash INSIDE the repository.

**Analogy:** A file trying to contain its own checksum.
- To update the checksum, you change the file
- Changing the file invalidates the checksum
- Circular dependency

---

## Possible Solutions

### Option 1: Don't Track last_commit at All ✅ RECOMMENDED

**Change:**
- Remove `last_commit` from agent_state.json
- Validation uses `git rev-parse HEAD` directly
- Track `last_session_end` timestamp instead

**Pros:**
- Eliminates circular dependency completely
- Simpler state file
- Git is already the source of truth

**Cons:**
- Less explicit state tracking
- Need to query git for commit info

**Validation becomes:**
```python
# OLD (broken):
state['last_commit'] == git_head

# NEW (works):
# Just check git directly, don't store in state
git_head = subprocess.check_output(['git', 'rev-parse', 'HEAD'])
# State file tracks session end time instead
```

### Option 2: One Atomic Commit (All Changes Together) ✅ ALSO VALID

**Change:**
- Update agent_state.json BEFORE final commit
- Commit work + state update TOGETHER in one commit
- No separate "state update" commits

**Workflow:**
```bash
# 1. Do all work
# 2. Update agent_state.json (don't commit yet)
# 3. Commit EVERYTHING together
git add -A
git commit -m "feat: description of work"
# Now state and code are in same commit - no lag
```

**Pros:**
- Keeps explicit last_commit tracking
- One atomic commit (cleaner history)

**Cons:**
- Requires strict workflow discipline
- Agent must remember to update state BEFORE committing

### Option 3: Track "last_work_session_end" Timestamp

**Change:**
- Don't track commit at all
- Track session end timestamp
- Use git log to find commits since last timestamp

**Pros:**
- No circular dependency
- Still have session tracking

**Cons:**
- Timestamp-based queries less reliable than commit-based

### Option 4: External State Tracking

**Change:**
- Don't store last_commit in the repo
- Store in external system (GitHub API, database, etc.)
- Query external system for state

**Pros:**
- Eliminates circular dependency
- Can store commit after it's created

**Cons:**
- Adds external dependency
- More complex

---

## Recommended Solution: Hybrid Approach

**Combine Option 1 + Option 2:**

1. **Remove last_commit from agent_state.json** (eliminates circular dependency)
2. **Enforce one atomic commit workflow** (cleaner)
3. **Track last_session_end timestamp** (for session boundaries)
4. **Use git log directly** for commit history

**Updated agent_state.json schema:**
```json
{
  "version": 1,
  "last_agent": "claude_code_sonnet_4_5",
  "last_mode": "HANDOFF",
  "last_session_start": "2026-01-08T00:00:00Z",
  "last_session_end": "2026-01-08T02:00:00Z",
  "current_agent": "HANDOFF",
  "current_task": "...",
  "handoff_message": "...",
  "briefing_acknowledgment": {...},
  "user_decisions": {...},
  "implementation_progress": {...}
}
```

**Validation becomes:**
```python
# No more last_commit checks
# Instead: Check git directly

git_head = get_git_head()
git_pushed = check_commits_pushed()

# Validate:
# - All commits pushed to origin/main
# - State file updated this session (check mtime)
# - Handoff message meaningful
```

---

## Next Steps

1. ✅ Write design document (this file)
2. ✅ Submit to Gemini for validation (Gate 4)
3. ✅ Implement validated solution
4. ✅ Test with validation scripts
5. ⏳ Get Gemini final approval

---

**Status:** IMPLEMENTED - Solution deployed and tested
**Implementation Date:** 2026-01-08

## Implementation Summary

**Changes Made:**

1. **agent_state.json** - Removed `last_commit` field
2. **handoff_validation_tests.py** - Updated `test_production_state_matches_claims()` to only check commits pushed
3. **pre-commit hook** - Removed `last_commit` from required fields validation
4. **gate_4_gemini_eval.py** - Updated all logic to validate required fields instead of comparing last_commit

**Test Results:**

```bash
# Pre-handoff validation
📊 PRE-HANDOFF RESULTS: 6/6 tests passed
✅ All pre-handoff tests passed

# Gate 4 evaluation
📊 GEMINI VERDICT: APPROVE
Score: 90/100
✅ State files correct: True
✅ Commits pushed: True
```

**Circular Dependency:** ✅ ELIMINATED

- No more last_commit tracking in agent_state.json
- Git is queried directly: `git rev-parse HEAD`
- No perpetual one-commit lag
- Validation now checks: commits pushed, state fields present, handoff meaningful

**Awaiting:** Final Gemini approval before declaring complete
