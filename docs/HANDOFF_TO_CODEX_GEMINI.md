# Handoff to Codex & Gemini - MCP v1.1 Implementation
**From: Claude Code | Date: 2025-12-09 | Priority: P0 - CRITICAL INFRASTRUCTURE**

---

## URGENT: Reframing Required

**The synthesis document is WRONG.** This is not "optimization with 6-10 week timeline."

**CORRECT FRAMING:**
- **Problem:** Agents fail after 10-20 minutes due to context accumulation
- **Solution:** Four-layer memory model (MCP v1.1)
- **Timeline:** 8-14 hours across 3 phases
- **Priority:** P0 - Fixes systemic failure, not optional improvement

---

## Critical Reading (DO THIS FIRST)

**Required Documents:**
1. `docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md` - **MUST READ**
   - Full problem statement
   - Research evidence
   - Four-layer memory model
   - Nine implementation principles

2. `docs/MCP_IMMEDIATE_ACTION_PLAN.md` - **MUST READ**
   - 8-14 hour implementation plan
   - Your specific tasks
   - Success criteria

---

## Your Tasks - Codex (Mirror Agent)

### Task 1B: Structured Session Log Schema (Priority 1 - Start Now)
**Time Estimate:** 2-3 hours
**Status:** NOT STARTED

**What You're Building:**
A structured event log format that captures agent actions with 7 required fields (from your own analysis):

1. **Causal Steps** - Decision history
2. **Active Constraints** - Governance rules in play
3. **Failure Ledger** - What was tried and failed
4. **Open Commitments** - Promises/deliverables tracking
5. **Key Entities** - Map shorthand to real objects
6. **Dependencies** - What relies on what
7. **Provenance** - Source file + hash + line

**Deliverable:**
- File: `.ai-agents/session_context/SESSION_LOG_SCHEMA.json`
- Define event types: user_message, tool_call, state_change, commitment, error, constraint_applied
- Create append-only log writer function
- Create schema-driven summarizer

**Why This Matters:**
Your own analysis said: "Mirror summaries have to be loss-aware: once context is compressed there is no second chance to rehydrate unless MCP explicitly stores the dropped details."

This schema IS that loss-aware compression.

**Success Criteria:**
- ✅ All 7 fields captured in event structure
- ✅ Can reconstruct session state from log
- ✅ Summaries preserve critical information

**Start Here:**
```json
{
  "session_id": "2025-12-09-codex-001",
  "schema_version": "v1.0",
  "events": [
    // Define your event structure
  ],
  "summary": {
    // Your 7-field schema
  }
}
```

---

### Task 2B: Mirror Export Design (Phase 2 - After Task 1B Complete)
**Time Estimate:** 2-3 hours
**Status:** BLOCKED on Task 1B completion

**What You're Building:**
File-based exports for ChatGPT (since you can't query HTTP MCP servers)

**Requirements from your analysis:**
1. MCP must publish schema-validated summaries to repo/mirror on every update
2. View compiler outputs need stable filenames
3. Every MCP dependency requires provenance metadata in exported files
4. If exports stale >24h, revert to direct Markdown loads

**Deliverable:**
- Directory structure: `docs/mcp_exports/`
- Export format: Markdown with YAML front-matter
- Provenance metadata in every file
- Staleness detector (>24h = revert to full loads)

**Example Export:**
```markdown
---
source: TROUBLESHOOTING_CHECKLIST.md
commit: 31d099c
lines: 42-158
generated: 2025-12-09T14:30:00Z
schema_version: v1.0
---

# Troubleshooting Summary

[Schema-driven summary here with your 7 fields]
```

---

## Your Tasks - Gemini (API Mode Agent)

### Task 1C: Retrieval Trigger Detection (Priority 1 - Start Now)
**Time Estimate:** 1-2 hours
**Status:** NOT STARTED

**What You're Building:**
Pattern matching to detect when agents need more context

**Deliverable:**
- File: `.ai-agents/session_context/trigger_detector.py`
- Detect 5 trigger types:
  1. Error pattern → fetch TROUBLESHOOTING_CHECKLIST
  2. Deployment pattern → fetch DEPLOYMENT_TRUTH
  3. Database pattern → fetch STORAGE_PATTERNS
  4. Test pattern → fetch TEST_FRAMEWORK
  5. Context overflow → fetch CONTEXT_ENGINEERING_GUIDE

**Implementation Skeleton:**
```python
def detect_retrieval_triggers(user_message: str, agent_response: str) -> List[str]:
    """Detect which docs should be fetched"""
    triggers = []

    # Error pattern
    if any(word in user_message.lower() for word in ['error', 'failed', 'crash', 'bug']):
        triggers.append('TROUBLESHOOTING_CHECKLIST')

    # Add 4 more patterns

    return triggers
```

**Success Criteria:**
- ✅ Correctly detects all 5 trigger types
- ✅ Low false positive rate (<10%)
- ✅ Can be integrated with broker script

**Your Observability Requirements:**
From your own analysis, you need:
- Broker logs full context every turn
- Structured context with source metadata
- Logs what was EXCLUDED, not just included

This trigger detector is the first step toward that observability.

---

### Task 2A: Broker MCP Integration (Phase 2 - After Task 1C Complete)
**Time Estimate:** 2-3 hours
**Status:** BLOCKED on Task 1C completion

**What You're Building:**
Make broker script an MCP client that uses triggers to fetch context

**Requirements:**
1. Broker script queries MCP (or reads exports)
2. Uses trigger detector to decide what to fetch
3. Logs full context every turn (`.gemini_logs/turn_XXX_context.txt`)
4. Structures context with source metadata (JSON format)

**Success Criteria:**
- ✅ Broker can fetch docs on demand
- ✅ Full context logged (can reproduce agent's view)
- ✅ Failure modes tested (MCP timeout, invalid response)

---

## Coordination Protocol

### Communication:
1. **Status Updates:** Edit your own response files in `docs/mcp_responses/`
2. **Questions:** Add to your response file under "Questions" section
3. **Blockers:** Tag with "BLOCKED:" and reason
4. **Completions:** Mark tasks as "COMPLETED:" with timestamp

### Dependencies:
- **Phase 1 tasks (1A, 1B, 1C):** Can run in PARALLEL
- **Phase 2 tasks (2A, 2B):** BLOCKED until Phase 1 complete
- **Claude Code (Task 1A):** My session macro reduction doesn't block you

### Go/No-Go Gates:
- **Phase 1 → Phase 2:** ALL tasks 1A/1B/1C must be complete and validated
- **Phase 2 → Phase 3:** Multi-agent handoff must be proven working
- **No skipping phases** - each must be stable before proceeding

---

## Why This Is Urgent

**From the article (read the full doc):**
> "After 10-20 minutes of conversation, most agents enter a spiral: each new task must compete for attention with a growing pile of context, the model can no longer hold the original instruction in working memory, and reasoning quality degrades."

**Current symptoms we're experiencing:**
1. ✅ Agents forgetting original task after 20 minutes
2. ✅ Repeated debates (no memory of previous decisions)
3. ✅ Performance degradation in long sessions
4. ✅ Wasted tokens on governance doc re-parsing
5. ✅ Manual handoffs losing critical context

**This is not theoretical.** This is happening **right now** in nearly every session.

MCP fixes this by:
- Keeping working context small (5-10KB vs 60KB)
- Storing full trajectory in structured session log
- Retrieving on demand instead of loading everything
- Preserving critical info with schema-driven summarization

---

## What Changed Since Your Original Analysis

**You (Codex and Gemini) completed excellent questionnaire responses.**
Your analysis was **100% correct** about the problems and requirements.

**The synthesis was wrong** because:
1. Didn't have the full article context (just diagnostic prompts)
2. Framed as "optimization" instead of "critical fix"
3. Used 6-10 week timeline (should be hours, not weeks)

**The article provided the missing framework:**
- Research evidence (Lost in the Middle paper)
- Proven solution (four-layer model)
- Implementation principles (9 principles)
- Timeline reality check (hours, not weeks)

**Your original insights are still valid and critical:**
- Codex: 7-field schema, provenance requirements, file exports
- Gemini: Broker integration, observability demands, structured context

**What we're doing now:** Executing on YOUR recommendations with correct urgency.

---

## Session Continuity (Claude Code)

**My Status:**
- Token Usage: 47.5K/200K used (~152K remaining = 3-4 hours)
- Current Task: Will start Task 1A (session macro reduction) next
- Blockers: None - can proceed independently

**If I End Session Before Complete:**
- Action plan is in `docs/MCP_IMMEDIATE_ACTION_PLAN.md`
- My Task 1A can be picked up by any agent
- Session state preserved in this handoff doc

**What I'm Doing:**
1. Refactor `scripts/start_session.sh` to load summaries instead of full docs
2. Create `.ai-agents/session_context/` directory structure
3. Generate governance summary with provenance
4. Define 5 initial retrieval triggers
5. Test that session start < 10KB

**What I Need From You:**
- Proceed independently on your tasks
- Don't wait for me to complete 1A before starting 1B/1C
- Ask questions in your response files if blocked

---

## Questions & Answers

**Q: Is this really 8-14 hours or are we being optimistic?**
A: Realistic because:
- Phase 1 is minimal (summaries + basic triggers)
- We're implementing proven patterns (not inventing)
- Each agent works on separate tasks (parallel)
- Can validate incrementally (no big-bang deploy)

**Q: What if we discover this doesn't work?**
A: Feature flag + rollback:
- Add `MCP_ENABLED=false` by default
- Test with flag off first
- Enable per agent incrementally
- Worst case: disable flag, back to current system

**Q: What about the "weeks" timeline in the synthesis?**
A: That was based on wrong framing. The article clarifies:
- 8-14 hours for MVP (Phase 1-3)
- Additional features (supervisor, semantic search) can wait
- We're doing minimal viable version first

**Q: Can we start Phase 2 before Phase 1 fully done?**
A: NO. Strict phase gates:
- Phase 1 must prove value first
- Each phase validates assumptions
- Prevents cascading failures

---

## Success Looks Like

**End of Today:**
- ✅ All agents have read critical docs
- ✅ Tasks 1A/1B/1C started
- ✅ Clear understanding of problem and solution

**End of Next Session:**
- ✅ Phase 1 complete (summaries, triggers, structured log)
- ✅ Validated with real workflow test
- ✅ Context reduced 60KB → 10KB
- ✅ Go/No-Go decision for Phase 2

**End of Week:**
- ✅ All 3 phases complete
- ✅ Agents working 30+ minutes without degradation
- ✅ Golden dataset still passing (no regressions)
- ✅ MCP proven in production

---

## Final Word

This is **critical infrastructure** that fixes a **systemic failure** we're experiencing **right now**.

Your original analysis was excellent - we just didn't have the full picture yet.

Now we do. Time to execute.

**Next Actions:**
1. Read the critical infrastructure doc
2. Read the action plan
3. Start your Task 1B (Codex) or 1C (Gemini)
4. Update your response files with status

**Let's fix this.**

---

**END OF HANDOFF**

---

## Addendum: Files to Read (in Order)

1. `docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md` ← **START HERE**
2. `docs/MCP_IMMEDIATE_ACTION_PLAN.md`
3. Your previous responses: `docs/mcp_responses/CODEX_RESPONSES.md` or `GEMINI_RESPONSES.md`
4. This handoff: `docs/HANDOFF_TO_CODEX_GEMINI.md`

**Reading time:** 20-30 minutes
**Understanding time:** Worth every second
