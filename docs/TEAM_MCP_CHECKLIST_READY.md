# Team Alert: MCP v1.1 Master Checklist Ready

**For: Codex & Gemini**
**From: Claude Code**
**Date: 2025-12-09**
**Priority: URGENT - READ BEFORE CONTINUING ANY WORK**

---

## Critical Update: Previous Plans Incomplete

I made a significant planning error. The previous action plan and handoffs were **missing critical elements**:

1. ❌ **No baseline measurements** - Don't know current state to measure improvement
2. ❌ **No test-first approach** - Implementation before validation
3. ❌ **No failsafes** - Could break production without recovery path
4. ❌ **No destructive operation protection** - Could lose critical files
5. ❌ **Not regressive** - Couldn't track what's already done

## New Master Checklist (USE THIS NOW)

**File:** `docs/MCP_V1_1_MASTER_CHECKLIST.md`

**What's Different:**

- ✅ **Phase 0 added** - Baseline measurements, testing, failsafes FIRST
- ✅ **Regressive format** - Can mark items complete retroactively
- ✅ **Failsafe for every destructive operation** - Backups, rollbacks, feature flags
- ✅ **Test-driven** - Golden datasets and validation before implementation
- ✅ **Clear ownership** - Every task has "Owner: _____" to fill in
- ✅ **Go/No-Go gates** - Can't proceed without validation

---

## STOP: Before You Continue Any Work

### If You've Already Started Testing (Gemini)

1. ✅ **GOOD** - Testing first was the right approach
2. Update checklist: Mark Phase 0.4 items as complete if you created test dataset
3. Document what tests you've created: `.ai-agents/test_data/`
4. Continue with remaining Phase 0 tasks

### If You've Started Implementation (Codex)

1. ⛔ **PAUSE** - Need Phase 0 complete first (baseline + failsafes)
2. Review checklist Phase 0 requirements
3. Identify what measurements/backups are needed
4. Then resume implementation

### If You Haven't Started Yet

1. ✅ **GOOD** - Read the full checklist first
2. Start with Phase 0 tasks
3. Mark items complete as you go
4. Don't skip to Phase 1 until Phase 0 done

---

## Critical Phase 0 Tasks (BLOCKING ALL IMPLEMENTATION)

### Someone Needs To Do These First

**0.2 Baseline Measurements:**

- [ ] Measure current session start context size (~60KB expected)
- [ ] Document what files are currently loaded
- [ ] Test agent performance at 20-minute mark (prove problem exists)
- [ ] Create golden dataset for trigger detection

**0.3 Failsafe Infrastructure:**

- [ ] Create git tag `pre-mcp-v1.1-baseline` (one-command rollback)
- [ ] Create feature flag system (can disable MCP without code changes)
- [ ] Create rollback script (panic button)
- [ ] Document critical files that must NOT be deleted

**0.4 Test Framework:**

- [ ] Create test harness for session start
- [ ] Create test harness for trigger detection
- [ ] Create test harness for summarization quality

**Why This Matters:**

- We're modifying critical infrastructure that keeps agents functional
- Need baseline to measure improvement
- Need failsafes before making any destructive changes
- Need tests to validate changes don't break things

---

## What I'm Doing Now

**Task:** Phase 0 baseline measurements and failsafe setup
**Reason:** Can't proceed to implementation without this foundation
**Files:** Will create in `.ai-agents/baseline/` and `.ai-agents/backups/`

**After Phase 0 Complete:**

- Then start Phase 1 Task 1A (session macro reduction)
- Only after baseline + failsafes in place

---

## How to Use the Checklist

1. **Read full checklist** - Understand all phases
2. **Find Phase 0 tasks you can do** - Mark with your name
3. **Start Phase 0 work** - Baseline, tests, failsafes
4. **Mark items complete** - Add ✅, timestamp, your name
5. **Wait for Phase 0 completion** - Don't skip to Phase 1
6. **Phase 1 only after validation** - Go/No-Go gate

**Checkbox Format:**

```markdown
- [x] ✅ Task description (YourName, 2025-12-09 HH:MM - DONE)
- [x] 🔄 Task description (YourName, 2025-12-09 HH:MM - IN PROGRESS)
- [ ] ⛔ Task description (BLOCKED: reason)
```

---

## Why This Changed

**What Happened:**

- Damian pointed out my plan was missing testing and failsafes
- I treated this like greenfield when it's modifying critical production infrastructure
- I assigned implementation tasks without test-driven development
- I didn't account for destructive operations that could lose critical files

**What I Learned:**

- WIMD is a production system with real users
- Must read TROUBLESHOOTING_CHECKLIST.md before ANY changes (my role)
- Need baseline measurements to prove improvement
- Need failsafes before any destructive operations
- Test first, implement second

**What Changed:**

- Added Phase 0 (baseline + failsafes) before Phase 1 (implementation)
- Every destructive operation now has backup/rollback plan
- Test harnesses defined before implementation
- Regressive checklist format (can track what's done)

---

## Open Questions (Need Team Input)

1. **Who does baseline measurements?** (Phase 0.2)
   - Need someone to measure current 60KB context size
   - Need someone to test 20-minute degradation

2. **Who creates golden dataset?** (Phase 0.4)
   - Need sample messages with expected triggers
   - Gemini may have already started this?

3. **Who makes Go/No-Go decisions?** (Phase 1.5, 2.5, 3.5)
   - Damian? All agents consensus? Claude Code as lead?

---

## Critical Files Reference

**Read These (Priority Order):**

1. `docs/MCP_V1_1_MASTER_CHECKLIST.md` ← **START HERE (new)**
2. `docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md` (problem/solution)
3. `docs/MCP_IMMEDIATE_ACTION_PLAN.md` (now superseded by checklist)

**Outdated/Superseded:**

- `docs/MCP_IMMEDIATE_ACTION_PLAN.md` - Missing Phase 0, use checklist instead
- `docs/HANDOFF_TO_CODEX_GEMINI.md` - Missing failsafes, use checklist instead
- `docs/mcp_responses/SYNTHESIS.md` - Wrong framing (weeks not hours)

---

## Next Actions (Right Now)

**ALL AGENTS:**

1. Stop current work
2. Read `docs/MCP_V1_1_MASTER_CHECKLIST.md` in full
3. Identify Phase 0 tasks you can do
4. Mark tasks with your name
5. Start Phase 0 work
6. Update checklist as you complete tasks

**DO NOT:**

- Skip to Phase 1 implementation
- Modify critical files without backups
- Delete or overwrite existing docs
- Proceed without baseline measurements

---

## Apology

I should have done this planning correctly the first time. The previous plans put the project at risk by:

- Not measuring baseline before changes
- Not protecting against destructive operations
- Not requiring tests before implementation

This checklist fixes those gaps. Sorry for the confusion.

---

**END OF TEAM ALERT**

**Status:** Master checklist ready for team use
**Next:** Phase 0 tasks must be completed before any implementation
**File:** `docs/MCP_V1_1_MASTER_CHECKLIST.md`
