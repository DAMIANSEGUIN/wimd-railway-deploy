# Agent Handoff - Structured Template
**MCP v1.1 Standardized Handoff Protocol**

**From:** [Agent Name]
**To:** [Next Agent / User]
**Date:** [YYYY-MM-DD HH:MM]
**Session ID:** [session_id]
**Task ID:** [task_id from gate system]

---

## 1. Causal Steps - Decision History

**What decisions led to this handoff?**

### Step 1: [Initial Analysis/Request]
- **Decision:** [What was decided]
- **Reasoning:** [Why this decision was made]
- **Alternatives Considered:** [Other options that were evaluated]
- **Chosen Because:** [Why this path was selected]

### Step 2: [Implementation Approach]
- **Decision:** [What was decided]
- **Reasoning:** [Why this decision was made]
- **Alternatives Considered:** [Other options]
- **Chosen Because:** [Rationale]

### Step 3: [Next Steps/Handoff]
- **Decision:** [Why handing off / what's next]
- **Reasoning:** [Why handoff is happening now]

---

## 2. Active Constraints - Governance Rules Applied

**What constraints governed this work?**

### Mandatory Constraints
- **Constraint:** [e.g., "Use context manager pattern for DB operations"]
  - **Source:** `TROUBLESHOOTING_CHECKLIST.md:line 234`
  - **Applied:** [Yes/No]
  - **How:** [Specific implementation detail]

- **Constraint:** [e.g., "PostgreSQL syntax only, no SQLite"]
  - **Source:** `SELF_DIAGNOSTIC_FRAMEWORK.md:line 156`
  - **Applied:** [Yes/No]
  - **How:** [Specific implementation detail]

### Recommended Constraints
- **Constraint:** [Optional pattern followed]
  - **Source:** [Document reference]
  - **Applied:** [Yes/No]
  - **Why/Why Not:** [Reasoning]

---

## 3. Failure Ledger - What Didn't Work

**Track all attempts, even failures**

### Attempt 1: [Description]
- **Tried:** [What was attempted]
- **Failed Because:** [Root cause]
- **Error:** [Error message if applicable]
- **Timestamp:** [When this failed]
- **Learned:** [What this taught us]

### Attempt 2: [Description]
- **Tried:** [What was attempted]
- **Failed Because:** [Root cause]
- **Error:** [Error message if applicable]
- **Timestamp:** [When this failed]
- **Learned:** [What this taught us]

---

## 4. Open Commitments - Promises/Deliverables

**What is still pending?**

### Commitment 1: [Deliverable Description]
- **Status:** [pending / in_progress / blocked / completed]
- **Due By:** [Timeline if applicable]
- **Dependencies:** [What this depends on]
- **Owner:** [Who is responsible]
- **Completion Criteria:** [How to verify it's done]

### Commitment 2: [Deliverable Description]
- **Status:** [pending / in_progress / blocked / completed]
- **Due By:** [Timeline if applicable]
- **Dependencies:** [What this depends on]
- **Owner:** [Who is responsible]
- **Completion Criteria:** [How to verify it's done]

---

## 5. Key Entities - Shorthand to Full References

**Map all abbreviations and shorthands**

```json
{
  "MCP": {
    "full_name": "Model Context Protocol",
    "type": "concept",
    "description": "System for reducing agent context size via on-demand retrieval",
    "location": "docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md"
  },
  "broker": {
    "full_name": "Document Retrieval Broker",
    "type": "module",
    "description": "Script that fetches docs based on trigger detection",
    "location": ".ai-agents/designs/BROKER_ARCHITECTURE.md"
  },
  "gate_system": {
    "full_name": "Task Completion Gate System",
    "type": "system",
    "description": "File-based coordination using .complete files",
    "location": ".ai-agents/scripts/check_gates.py"
  }
}
```

---

## 6. Dependencies - What Relies on What

**Track all dependency relationships**

### Depends On (Blockers)
- **Event/Task ID:** [evt_abc123 or task_2.3]
  - **Description:** [What this is]
  - **Status:** [complete / in_progress / pending]
  - **Blocks:** [What is blocked by this]

### Blocks (Downstream Impact)
- **Event/Task ID:** [evt_def456 or task_3.1]
  - **Description:** [What will be unblocked]
  - **Waiting For:** [What it needs from this handoff]

---

## 7. Provenance - Source Metadata

**Where did all information come from?**

### Session Summary
```json
{
  "source": "session_20251210_1400",
  "agent": "claude_code",
  "schema_version": "v1.0",
  "confidence": 1.0,
  "generated": "2025-12-10T14:30:00Z"
}
```

### Files Referenced
| File | Commit | Lines | Last Modified | Purpose |
|------|--------|-------|---------------|---------|
| `TROUBLESHOOTING_CHECKLIST.md` | `31d099c` | 1-673 | 2025-12-06 | Error prevention patterns |
| `SESSION_LOG_SCHEMA.json` | `current` | 1-197 | 2025-12-10 | Schema definition |
| `.ai-agents/scripts/check_gates.py` | `current` | 1-190 | 2025-12-09 | Gate checking logic |

### External Information
- **Source:** [API call, user input, etc.]
- **Retrieved:** [Timestamp]
- **Confidence:** [0-1 scale]
- **Verified:** [Yes/No/Partially]

---

## 8. Work Completed This Session

**What was accomplished?**

### Files Created
- `[file_path]` - [Purpose and key content]
- `[file_path]` - [Purpose and key content]

### Files Modified
- `[file_path]` - [What changed and why]
- `[file_path]` - [What changed and why]

### Tests Performed
- [x] Test 1: [Description] - ✅ PASSED
- [x] Test 2: [Description] - ✅ PASSED
- [ ] Test 3: [Description] - ⏳ PENDING

### Verification Status
- [x] Code runs without errors
- [x] Tests pass
- [x] Documentation updated
- [x] Follows governance constraints
- [ ] Deployed to production (if applicable)

---

## 9. Next Actions

**What should happen next?**

### Immediate (Next 30 minutes)
1. [Action 1] - [Who should do this]
2. [Action 2] - [Who should do this]
3. [Action 3] - [Who should do this]

### Short Term (Next Session)
1. [Action 1] - [Who should do this]
2. [Action 2] - [Who should do this]

### Blocked/Waiting
- **Waiting For:** [What is needed]
- **Who Provides:** [Person/agent responsible]
- **When Needed:** [Timeline]

---

## 10. Resumption Instructions

**How to continue this work?**

### For Next Agent
1. **Read these files first:**
   - [File 1] - [Why important]
   - [File 2] - [Why important]

2. **Check gate status:**
   ```bash
   python3 .ai-agents/scripts/check_gates.py [agent_name]
   ```

3. **Review open commitments** (Section 4 above)

4. **Start with:** [Specific first action]

### Context to Load
- Load session log: `.ai-agents/sessions/[session_id].jsonl`
- Review failures: Section 3 above
- Check dependencies: Section 6 above

### Verification Before Starting
- [ ] Git status clean (or changes understood)
- [ ] Environment variables set
- [ ] Tests passing
- [ ] Previous work verified

---

## 11. Questions / Uncertainties

**What needs clarification?**

### Open Questions
1. **Q:** [Question about approach/decision]
   - **Context:** [Why this matters]
   - **Options:** [Possible answers]
   - **Needs Input From:** [Who can answer]

2. **Q:** [Another question]
   - **Context:** [Why this matters]
   - **Options:** [Possible answers]
   - **Needs Input From:** [Who can answer]

### Assumptions Made
- **Assumption:** [What was assumed]
  - **Confidence:** [High/Medium/Low]
  - **Should Verify:** [Yes/No]
  - **How to Verify:** [Method]

---

## 12. Session Metrics

**Quantitative session data**

- **Duration:** [X minutes/hours]
- **Files Touched:** [Count]
- **Lines Added:** [Count]
- **Lines Removed:** [Count]
- **Tests Added:** [Count]
- **Tests Passing:** [X/Y]
- **Context Size at Start:** [KB]
- **Context Size at End:** [KB]

---

## Emergency Rollback

**How to undo this work if needed**

### Rollback Command
```bash
git revert [commit_hash]
# OR
git checkout [previous_commit]
```

### What Gets Reverted
- [File 1] → [Previous state]
- [File 2] → [Previous state]

### Side Effects of Rollback
- [Impact 1]
- [Impact 2]

---

**END OF STRUCTURED HANDOFF**

Generated by: [Agent Name]
Schema Version: v1.0 (MCP Session Log Compatible)
Next Agent: [Who should pick this up]
Priority: [P0/P1/P2]
