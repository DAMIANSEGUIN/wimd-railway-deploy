# MCP v1.1 Implementation - IMMEDIATE ACTION PLAN

**CRITICAL INFRASTRUCTURE - NOT OPTIMIZATION**

**Document Metadata:**

- Created: 2025-12-09 by Claude Code
- Status: ACTIVE - Ready for execution
- Timeline: **8-14 hours** across 3 phases
- Priority: **P0 - Fixes systemic 10-20 minute agent failure**

---

## SITUATION SUMMARY

**The Problem We're Solving:**

- Agents fail after 10-20 minutes due to context accumulation
- Attention budget degradation makes reasoning progressively worse
- Current 60KB governance loads compound the problem
- This is NOT about optimization - it's about fixing broken workflows

**Critical Context:**

- Full explanation in `docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md`
- Research evidence: "Lost in the Middle" paper, attention budget studies
- Proven solution: Four-layer memory model (working context, sessions, memory, artifacts)

---

## IMMEDIATE PRIORITIES (Next 2-4 Hours)

### Priority 1: Team Alignment (15 minutes) ✅ CLAUDE CODE

**Status:** IN PROGRESS

**Actions:**

1. ✅ Created critical infrastructure document
2. ✅ Identified wrong framing in Codex synthesis
3. ⏳ Creating this action plan
4. ⏳ Brief handoff notes for Codex and Gemini

**Deliverable:** All agents understand this is critical fix, not optional optimization

---

### Priority 2: Phase 1 Kickoff - Minimal Viable Context Engineering (4-6 hours)

**Goal:** Get working context from 60KB → 10KB with basic retrieval

#### Task 1A: Session Macro Reduction (CLAUDE CODE - 2 hours)

**File:** `scripts/start_session.sh`

**Current behavior:**

```bash
# Loads ALL governance docs into context (~60KB)
cat CLAUDE.md
cat TROUBLESHOOTING_CHECKLIST.md
cat SELF_DIAGNOSTIC_FRAMEWORK.md
cat docs/README.md
# ... etc
```

**Target behavior:**

```bash
# Load SUMMARIES with retrieval triggers
cat .ai-agents/session_context/GOVERNANCE_SUMMARY.md  # ~2KB
cat .ai-agents/session_context/RETRIEVAL_TRIGGERS.md  # ~1KB
cat .ai-agents/session_context/CURRENT_TASK.md        # ~1KB
# Total: ~5KB vs 60KB
```

**Implementation:**

1. Create `.ai-agents/session_context/` directory
2. Generate governance summary (schema-driven, with provenance)
3. Define 5 initial retrieval triggers:
   - Error detected → fetch TROUBLESHOOTING_CHECKLIST.md
   - Deployment keyword → fetch DEPLOYMENT_TRUTH.md
   - Database operation → fetch relevant storage patterns
   - Test failure → fetch test framework docs
   - Session start → current summaries only

**Success Criteria:**

- Session start context < 10KB
- Can still access full docs on demand
- No information loss (provenance to originals)

---

#### Task 1B: Structured Session Log (CODEX - 2-3 hours)

**File:** `.ai-agents/session_context/SESSION_LOG_SCHEMA.json`

**Current behavior:**

- Free-form conversation history grows unbounded
- No structure = hard to summarize or retrieve

**Target behavior:**

```json
{
  "session_id": "2025-12-09-claude-code-001",
  "events": [
    {
      "timestamp": "2025-12-09T14:30:00Z",
      "type": "user_message",
      "content": "Fix the auth bug",
      "tags": ["auth", "bug"]
    },
    {
      "timestamp": "2025-12-09T14:31:15Z",
      "type": "tool_call",
      "tool": "Read",
      "args": {"file_path": "api/auth.py"},
      "result_summary": "Found password hash function"
    },
    {
      "timestamp": "2025-12-09T14:35:00Z",
      "type": "state_change",
      "change": "bug_identified",
      "details": {"location": "api/auth.py:142", "root_cause": "bcrypt salt rounds"}
    },
    {
      "timestamp": "2025-12-09T14:40:00Z",
      "type": "commitment",
      "promise": "Will increase salt rounds to 12",
      "status": "pending"
    }
  ],
  "summary": {
    "task": "Fix auth bug",
    "status": "in_progress",
    "key_findings": ["bcrypt salt rounds too low"],
    "next_steps": ["Increase salt rounds", "Test with golden dataset"]
  }
}
```

**Implementation:**

1. Define event schema (7 required fields from article)
2. Create append-only log writer
3. Create session summarizer (schema-driven)
4. Integrate with broker script for Gemini

**Success Criteria:**

- All agent actions logged with structure
- Can reconstruct session state from log
- Summaries preserve causal steps, constraints, failures

---

#### Task 1C: Retrieval Trigger Detection (GEMINI - 1-2 hours)

**File:** `.ai-agents/session_context/trigger_detector.py`

**Purpose:** Detect when agent needs more context

**Implementation:**

```python
def detect_retrieval_triggers(user_message: str, agent_response: str) -> List[str]:
    """Detect which docs should be fetched"""

    triggers = []

    # Error pattern
    if any(word in user_message.lower() for word in ['error', 'failed', 'crash', 'bug']):
        triggers.append('TROUBLESHOOTING_CHECKLIST')

    # Deployment pattern
    if any(word in user_message.lower() for word in ['deploy', 'push', 'render', 'production']):
        triggers.append('DEPLOYMENT_TRUTH')

    # Database pattern
    if any(word in agent_response.lower() for word in ['database', 'postgresql', 'sqlite', 'query']):
        triggers.append('STORAGE_PATTERNS')

    # Test pattern
    if any(word in user_message.lower() for word in ['test', 'pytest', 'golden']):
        triggers.append('TEST_FRAMEWORK')

    # Context overflow (agent struggling)
    if len(agent_response.split()) > 1000:
        triggers.append('CONTEXT_ENGINEERING_GUIDE')

    return triggers
```

**Success Criteria:**

- Correctly detects 5 trigger types
- Low false positive rate (<10%)
- Integrated with broker script

---

## Phase 2: Multi-Agent Coordination (4-6 hours)

**Start only after Phase 1 proven working**

### Task 2A: Broker Integration (GEMINI)

- Broker script becomes MCP client
- Logs full context every turn
- Uses retrieval triggers to fetch docs

### Task 2B: Mirror Exports (CODEX)

- MCP exports summaries to `docs/mcp_exports/`
- File-based fallback for ChatGPT
- Provenance metadata in YAML front-matter

### Task 2C: Handoff Standardization (ALL)

- Use Codex's 7-field schema for handoffs
- Stop using free-form prose
- Structured commitments, constraints, failures

---

## Phase 3: Production Hardening (3-4 hours)

**Start only after Phase 2 stable**

### Task 3A: Observability

- `/debug dump-context` command
- Retrieval logs
- Context size tracking

### Task 3B: Failure Recovery

- Fallback always works (file-based)
- Stale export detection (>24h)
- Auto-revert to full loads if MCP down

### Task 3C: Success Metrics

- Context size reduction (target: >80%)
- Session duration improvement (10→30+ minutes)
- No regressions (golden dataset still passes)

---

## DELEGATION & HANDOFFS

### For Codex (Mirror Agent)

**Your Critical Tasks:**

1. **Session Log Schema** (Priority 1B above) - 2-3 hours
   - Define structured event log format
   - Implement schema-driven summarization
   - Your 7-field schema is perfect starting point

2. **File Export Design** (Phase 2B)
   - Design `docs/mcp_exports/` structure
   - Define provenance metadata format
   - Ensure ChatGPT can read without HTTP

**Context:** Read `docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md` for full problem statement

**Start with:** Session log schema definition

---

### For Gemini (API Mode Agent)

**Your Critical Tasks:**

1. **Retrieval Trigger Detection** (Priority 1C above) - 1-2 hours
   - Implement pattern matching for 5 trigger types
   - Test with sample user messages
   - Integrate with your broker script

2. **Broker MCP Integration** (Phase 2A)
   - Make broker script an MCP client
   - Log full context every turn (observability)
   - Use triggers to fetch additional docs

**Context:** Read `docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md` for full problem statement

**Start with:** Trigger detection implementation

---

### For Claude Code (Me)

**My Tasks:**

1. ✅ **Team Alignment** - Create this action plan
2. **Session Macro Reduction** (Priority 1A above) - 2 hours NEXT
   - Refactor `scripts/start_session.sh`
   - Create governance summary files
   - Implement retrieval on demand

3. **Coordination** (Ongoing)
   - Answer questions
   - Review implementations
   - Ensure agents have what they need

**Current Status:** 44K/200K tokens used, ~3-4 hours remaining this session

**Next Action:** Start Task 1A immediately after finishing this plan

---

## SUCCESS CRITERIA (How We Know It's Working)

### Phase 1 Success

- ✅ Session start context < 10KB (down from 60KB)
- ✅ Can still retrieve full docs when needed
- ✅ 5 retrieval triggers working correctly
- ✅ Structured session log capturing events
- ✅ No false positives in trigger detection

### Phase 2 Success

- ✅ All 3 agents using structured summaries
- ✅ Handoffs use 7-field schema (not prose)
- ✅ Mirror has file exports (no HTTP dependency)
- ✅ Broker logs full context (observability)

### Phase 3 Success

- ✅ Agents work 30+ minutes without degradation (up from 10-20)
- ✅ Context bloat eliminated
- ✅ Golden dataset still passes (no regressions)
- ✅ Fallback works (can disable MCP, still functional)

---

## RISK MITIGATION

### Risk: We Break Current Workflows

**Mitigation:** Feature flag + immediate rollback

- Add `MCP_ENABLED` flag (default: false)
- Test Phase 1 with flag off first
- Enable incrementally per agent

### Risk: Information Loss in Summaries

**Mitigation:** Provenance + audit trail

- Every summary links to source (file + hash + lines)
- Can always retrieve original
- Schema ensures critical fields preserved

### Risk: Retrieval Adds Latency

**Mitigation:** Async fetch + caching

- Fetch docs in parallel
- Cache frequently accessed summaries
- Target: <500ms retrieval latency

### Risk: Session Ends Before Completion

**Mitigation:** This action plan + clear handoffs

- Structured task delegation
- Each agent can continue independently
- Session state preserved in structured log

---

## TIMELINE & MILESTONES

**Today (2025-12-09):**

- ✅ Critical infrastructure doc created
- ⏳ Action plan finalized (this document)
- ⏳ Task 1A started: Session macro reduction
- Target: Phase 1 kickoff by end of session

**Next Session:**

- Complete Phase 1 tasks (all 3 agents)
- Validate with real workflow test
- Go/No-Go decision for Phase 2

**Within 48 Hours:**

- Phase 2 complete (multi-agent coordination)
- Handoffs standardized
- Mirror exports working

**Within 1 Week:**

- Phase 3 complete (production hardening)
- Success metrics validated
- MCP proven in production

---

## OPEN QUESTIONS (Need Damian's Input)

1. **Budget for MCP server hosting?**
   - Phase 1-2: Local only (free)
   - Phase 3: Render deployment ($5-10/month)
   - Answer: Can defer to Phase 3

2. **Risk tolerance for production testing?**
   - Use feature flag to enable incrementally?
   - Or test in staging first?
   - Answer: Feature flag approach recommended

3. **Priority vs. other work?**
   - Is this P0 or can it wait?
   - Answer: P0 - fixes core systemic failure

---

## NEXT ACTIONS (Immediate - Next 30 Minutes)

1. **Claude Code (Me):**
   - Finish this plan
   - Create handoff notes for Codex/Gemini
   - Start Task 1A: Session macro reduction

2. **Codex:**
   - Read critical infrastructure doc
   - Start Task 1B: Session log schema
   - Define 7-field event structure

3. **Gemini:**
   - Read critical infrastructure doc
   - Start Task 1C: Trigger detection
   - Implement pattern matching

---

**STATUS: READY TO EXECUTE**

This is a **critical infrastructure fix**, not an optimization. The 8-14 hour timeline is realistic because:

- We're not building complex orchestration
- We're implementing proven patterns (from article)
- We're doing minimal viable version first
- Each phase validates before proceeding

**Token budget:** 156K remaining = 3-4 quality hours this session
**Plan:** Start Phase 1 Task 1A immediately, delegate 1B/1C to team

---

**END OF ACTION PLAN**
