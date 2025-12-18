# MCP v1.1 Implementation - Master Checklist

**Critical Infrastructure - Regressive Plan with Failsafes**

**Document Metadata:**

- Created: 2025-12-09 by Claude Code
- Status: ACTIVE - Living document
- Update Protocol: Any agent marks items complete as work progresses
- Priority: P0 - Critical infrastructure fix for 10-20 minute agent failure

---

## How to Use This Checklist

1. **Check status before starting work** - Item may already be complete
2. **Mark completed items** - Add ✅, timestamp, and agent name
3. **Mark in-progress items** - Add 🔄, timestamp, and agent name
4. **Mark blocked items** - Add ⛔, reason, and what's needed to unblock
5. **Update this doc** - Don't let it go stale, it's our source of truth

---

## Pre-Implementation (Phase 0) - TESTING & VALIDATION

### 0.1 Documentation Review

- [x] ✅ Critical infrastructure doc created (Claude Code, 2025-12-09 14:00)
  - File: `docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md`
- [x] ✅ Action plan created (Claude Code, 2025-12-09 14:30)
  - File: `docs/MCP_IMMEDIATE_ACTION_PLAN.md`
- [x] ✅ Team handoff created (Claude Code, 2025-12-09 15:00)
  - File: `docs/HANDOFF_TO_CODEX_GEMINI.md`
- [x] ✅ Session state documented (Claude Code, 2025-12-09 15:15)
  - File: `docs/SESSION_STATE_2025_12_09.md`
- [x] ✅ Master checklist created (Claude Code, 2025-12-09 15:30)
  - File: `docs/MCP_V1_1_MASTER_CHECKLIST.md` (this file)

### 0.2 Baseline Measurements (CRITICAL - DO FIRST)

- [x] ✅ **Measure current session start context size** (Claude Code, 2025-12-09 16:00 - DONE)
  - Command: `wc -c CLAUDE.md TROUBLESHOOTING_CHECKLIST.md SELF_DIAGNOSTIC_FRAMEWORK.md docs/README.md`
  - Expected: ~60KB
  - Actual: **65,919 bytes (64.4 KB)**
  - **Why:** Need baseline to validate improvement

- [x] ✅ **Document current session start files loaded** (Claude Code, 2025-12-09 16:00 - DONE)
  - List all files loaded by `scripts/start_session.sh`
  - Create manifest: `.ai-agents/baseline/SESSION_START_MANIFEST.md`
  - Files: CLAUDE.md (16KB), TROUBLESHOOTING_CHECKLIST.md (14KB), SELF_DIAGNOSTIC_FRAMEWORK.md (31KB), docs/README.md (3KB)
  - **Why:** Know what we're summarizing

- [ ] **Test current agent performance at 10-20 minute mark**
  - Start fresh session, work for 20 minutes
  - Document: Quality degradation, forgotten context, repeated debates
  - Save transcript: `.ai-agents/baseline/20MIN_BASELINE_SESSION.md`
  - Owner: _____ (who does this?)
  - **Why:** Prove the problem exists, measure improvement later

- [ ] **Create golden dataset for trigger detection**
  - File: `.ai-agents/test_data/TRIGGER_TEST_DATASET.json`
  - Format:

    ```json
    [
      {
        "user_message": "The deployment failed with a 500 error",
        "expected_triggers": ["error", "deployment"],
        "should_not_trigger": ["database", "test"]
      },
      // ... 20+ test cases
    ]
    ```

  - Owner: _____ (who does this?)
  - **Why:** Can't validate trigger detector without test data

- [ ] **Validate governance docs are complete**
  - Check: CLAUDE.md, TROUBLESHOOTING_CHECKLIST.md, SELF_DIAGNOSTIC_FRAMEWORK.md
  - Verify: All critical constraints documented
  - Document gaps: `.ai-agents/baseline/GOVERNANCE_GAPS.md` if any
  - Owner: _____ (who does this?)
  - **Why:** Summaries can't include what isn't documented

### 0.3 Failsafe Infrastructure (BEFORE ANY CHANGES)

- [x] ✅ **Create backup of current system** (Claude Code, 2025-12-09 15:55 - DONE)
  - Git tag: `pre-mcp-v1.1-baseline`
  - Command: `git tag -a pre-mcp-v1.1-baseline -m "Baseline before MCP v1.1 implementation"`
  - Verified: Tag exists, can rollback with `git checkout pre-mcp-v1.1-baseline`
  - **Why:** ONE-COMMAND ROLLBACK if MCP breaks everything

- [x] ✅ Create feature flag system (Gemini, 2025-12-09 14:55 - DONE)
  - File: `.ai-agents/config/feature_flags.json`
  - Format:

    ```json
    {
      "MCP_ENABLED": false,
      "MCP_SESSION_SUMMARIES": false,
      "MCP_RETRIEVAL_TRIGGERS": false,
      "MCP_STRUCTURED_LOGS": false
    }
    ```

  - Integration: `scripts/start_session.sh` checks flags before loading summaries
  - Owner: _____ (who does this?)
  - **Why:** Can disable without code changes

- [x] ✅ **Create rollback script** (Claude Code, 2025-12-09 16:05 - DONE)
  - File: `scripts/rollback_mcp.sh`
  - Actions:
    1. Set all MCP flags to false
    2. Restore `scripts/start_session.sh` from backups
    3. Remove `.ai-agents/session_context/` if exists (optional)
    4. Verify session start works
  - Script created and tested (chmod +x applied)
  - **Why:** Panic button when things go wrong

- [x] ✅ **Create file protection system** (Claude Code, 2025-12-09 16:10 - DONE)
  - Critical files documented in `.ai-agents/CRITICAL_FILES_DO_NOT_DELETE.md`
  - Lists: Mission-critical files, protected directories, modification rules
  - Includes: Emergency recovery procedures, pre-commit hook example
  - **Why:** Prevent accidental deletion of critical docs

### 0.4 Test Framework Setup

- [ ] **Create test harness for session start**
  - File: `tests/test_mcp_session_start.py`
  - Tests:
    - Session start completes without errors
    - Context size is measured and logged
    - All governance constraints still accessible
    - No information loss vs. baseline
  - Owner: _____ (who does this?)
  - **Why:** Automated validation of changes

- [ ] **Create test harness for trigger detection**
  - File: `tests/test_mcp_triggers.py`
  - Tests:
    - Golden dataset scenarios pass
    - False positive rate < 10%
    - All 5 trigger types detected correctly
    - Performance < 100ms per detection
  - Owner: _____ (who does this?)
  - **Why:** Validate trigger detector works before integration

- [ ] **Create test harness for summarization quality**
  - File: `tests/test_mcp_summaries.py`
  - Tests:
    - All 7 required fields present (causal steps, constraints, etc.)
    - Provenance metadata valid (file, hash, lines exist)
    - No critical constraints dropped
    - Summaries are <= 20% of original size
  - Owner: _____ (who does this?)
  - **Why:** Ensure summaries don't lose critical info

---

## Phase 1: Minimal Viable Context Engineering

### 1.1 Session Macro Reduction (Claude Code)

#### 1.1.1 Create Directory Structure

- [ ] **Create `.ai-agents/session_context/` directory**
  - Command: `mkdir -p .ai-agents/session_context`
  - Verify: `ls -la .ai-agents/session_context`
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Directory creation only, no deletions

- [ ] **Create backups directory**
  - Command: `mkdir -p .ai-agents/backups`
  - Purpose: Store original files before modification
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Backup location for rollback

#### 1.1.2 Generate Governance Summary

- [ ] **Backup original governance docs**
  - Copy CLAUDE.md → `.ai-agents/backups/CLAUDE.md.$(date +%Y%m%d)`
  - Copy TROUBLESHOOTING_CHECKLIST.md → backups
  - Copy SELF_DIAGNOSTIC_FRAMEWORK.md → backups
  - Verify backups exist and are readable
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Originals preserved, can restore if summary is bad

- [ ] **Create governance summary with provenance**
  - File: `.ai-agents/session_context/GOVERNANCE_SUMMARY.md`
  - Target size: ~2KB (vs. 60KB full docs)
  - Required sections:
    - Current deployment status (from CLAUDE.md)
    - Critical constraints (from all docs)
    - Recent changes (last 3 git commits)
    - Emergency procedures (from TROUBLESHOOTING_CHECKLIST.md)
  - Provenance format:

    ```markdown
    ---
    source: CLAUDE.md
    commit: 31d099c
    lines: 1-50
    generated: 2025-12-09T15:30:00Z
    schema_version: v1.0
    ---
    ```

  - Owner: _____ (who does this?)
  - **FAILSAFE:** Original files untouched, summary is additive

- [ ] **Validate governance summary completeness**
  - Test: Load summary, attempt common tasks
  - Check: Can answer "What's the deployment command?" without full doc
  - Check: All critical constraints mentioned
  - Owner: _____ (who does this?)
  - **Why:** Ensure no information loss

#### 1.1.3 Define Retrieval Triggers

- [ ] **Create retrieval triggers document**
  - File: `.ai-agents/session_context/RETRIEVAL_TRIGGERS.md`
  - Target size: ~1KB
  - Define 5 triggers with mappings:
    1. Error keywords → TROUBLESHOOTING_CHECKLIST.md
    2. Deployment keywords → DEPLOYMENT_TRUTH.md, scripts/deploy.sh
    3. Database keywords → SELF_DIAGNOSTIC_FRAMEWORK.md (storage section)
    4. Test keywords → tests/*, golden dataset docs
    5. Context overflow → CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Document only, no code changes yet

- [ ] **Test trigger mappings manually**
  - For each trigger, verify target docs exist
  - For each trigger, verify docs contain relevant info
  - Document any gaps: `.ai-agents/validation/TRIGGER_GAPS.md`
  - Owner: _____ (who does this?)
  - **Why:** Validate trigger → doc mappings before automation

#### 1.1.4 Refactor Session Start Script

- [ ] **Backup original start_session.sh**
  - Copy: `scripts/start_session.sh` → `.ai-agents/backups/start_session.sh.$(date +%Y%m%d)`
  - Verify backup is executable: `bash .ai-agents/backups/start_session.sh.*`
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Can restore original script instantly

- [ ] **Create new session start script with feature flag**
  - File: `scripts/start_session_mcp.sh` (NEW FILE, don't modify original yet)
  - Logic:

    ```bash
    if [ "$MCP_ENABLED" = "true" ]; then
      cat .ai-agents/session_context/GOVERNANCE_SUMMARY.md
      cat .ai-agents/session_context/RETRIEVAL_TRIGGERS.md
    else
      # Original behavior
      cat CLAUDE.md
      cat TROUBLESHOOTING_CHECKLIST.md
      # ... etc
    fi
    ```

  - Owner: _____ (who does this?)
  - **FAILSAFE:** Original script untouched, new script side-by-side

- [ ] **Test new session start script**
  - Test with MCP_ENABLED=false → Should behave exactly like original
  - Test with MCP_ENABLED=true → Should load summaries only
  - Measure context size both ways
  - Document results: `.ai-agents/validation/SESSION_START_TEST_RESULTS.md`
  - Owner: _____ (who does this?)
  - **Why:** Validate before switching default

- [ ] **Validate context size reduction**
  - Measure: New session start context size
  - Expected: <10KB (vs. 60KB baseline)
  - If not achieved, investigate: What's still large?
  - Owner: _____ (who does this?)
  - **Why:** Core success metric for Phase 1

- [ ] **Test critical workflows still work**
  - Try deployment command
  - Try error handling
  - Try database operation
  - Verify: Can still access info needed for tasks
  - Owner: _____ (who does this?)
  - **Why:** Ensure no regressions

- [ ] **Replace original script (DESTRUCTIVE - FINAL STEP)**
  - **ONLY after all above tests pass**
  - Action: `mv scripts/start_session.sh scripts/start_session.sh.old`
  - Action: `mv scripts/start_session_mcp.sh scripts/start_session.sh`
  - Commit both files (old as .old, new as main)
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Old script committed as .old, can revert commit

### 1.2 Structured Session Log (Codex)

#### 1.2.1 Define Event Schema

- [ ] **Create session log schema document**
  - File: `.ai-agents/session_context/SESSION_LOG_SCHEMA.json`
  - Required fields (from Codex's analysis):
    1. causal_steps: Array of decision points with reasoning
    2. active_constraints: Currently applicable governance rules
    3. failure_ledger: What was tried and failed
    4. open_commitments: Promises/deliverables still pending
    5. key_entities: Map of shorthand → full references
    6. dependencies: What depends on what
    7. provenance: Source of each piece of information
  - Event types:
    - user_message
    - tool_call
    - state_change
    - commitment
    - error
    - constraint_applied
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Schema definition only, no data yet

- [ ] **Create schema validation function**
  - File: `.ai-agents/session_context/validate_session_log.py`
  - Function: `validate_event(event: dict) -> bool`
  - Checks: All required fields present, types correct, provenance valid
  - Owner: _____ (who does this?)
  - **Why:** Prevent bad data from entering logs

- [ ] **Test schema with sample events**
  - Create: `.ai-agents/test_data/sample_events.json`
  - Include: Valid events, invalid events (missing fields), edge cases
  - Verify: Validator catches all invalid cases
  - Owner: _____ (who does this?)
  - **Why:** Validate schema before production use

#### 1.2.2 Implement Log Writer

- [ ] **Create append-only log writer**
  - File: `.ai-agents/session_context/session_logger.py`
  - Function: `append_event(session_id: str, event: dict) -> bool`
  - Behavior:
    - Validate event with schema
    - Append to `.ai-agents/sessions/{session_id}.jsonl`
    - Never modify existing entries (append-only)
    - Return False if validation fails
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Append-only, never deletes or modifies past entries

- [ ] **Create log directory structure**
  - Command: `mkdir -p .ai-agents/sessions`
  - Purpose: Store session logs, one file per session
  - Naming: `{session_id}.jsonl` (JSON Lines format)
  - Owner: _____ (who does this?)
  - **FAILSAFE:** New directory, doesn't touch existing files

- [ ] **Test log writer**
  - Test: Append valid event → succeeds
  - Test: Append invalid event → fails, logs error
  - Test: Append to nonexistent session → creates file
  - Test: Concurrent appends → both succeed (file locking)
  - Owner: _____ (who does this?)
  - **Why:** Validate before integration

#### 1.2.3 Implement Summarizer

- [ ] **Create schema-driven summarizer**
  - File: `.ai-agents/session_context/summarize_session.py`
  - Function: `summarize_session(session_id: str) -> dict`
  - Algorithm:
    1. Read all events from session log
    2. Extract 7 required fields
    3. Generate summary with provenance
    4. Return structured summary (not free-form prose)
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Read-only operation, doesn't modify logs

- [ ] **Test summarizer with sample session**
  - Create: `.ai-agents/test_data/sample_session.jsonl` (synthetic session)
  - Run: Summarizer on sample session
  - Validate: All 7 fields present, no information loss
  - Owner: _____ (who does this?)
  - **Why:** Validate summarization quality

- [ ] **Validate summarization compression ratio**
  - Measure: Summary size vs. full log size
  - Target: Summary is 10-20% of full log size
  - If too large: Identify what's not compressing well
  - Owner: _____ (who does this?)
  - **Why:** Ensure summaries actually reduce context

### 1.3 Retrieval Trigger Detection (Gemini)

- [x] ✅ Create golden dataset for trigger detection (Gemini, 2025-12-09 14:54 - DONE)
  - File: `.ai-agents/test_data/TRIGGER_TEST_DATASET.json`
  - Include 20+ scenarios:
    - Error messages (should trigger "error" + specific domain)
    - Deployment commands (should trigger "deployment")
    - Database queries (should trigger "database")
    - Test failures (should trigger "test")
    - Long responses (should trigger "context_overflow")
    - Edge cases (ambiguous, multiple triggers, no triggers)
  - Owner: Gemini
  - **Why:** Can't validate without test data

- [x] ✅ **Document expected behavior for each test case** (Gemini, 2025-12-10 10:10 - DONE)
  - Format:

    ```json
    {
      "id": "test_001",
      "user_message": "Deploy to production failed",
      "agent_response": "Checking logs...",
      "expected_triggers": ["error", "deployment"],
      "should_not_trigger": ["database", "test"],
      "rationale": "Contains both 'failed' (error) and 'deploy' (deployment)"
    }
    ```

  - Owner: Gemini
  - **Why:** Clear acceptance criteria

#### 1.3.2 Implement Trigger Detector

- [x] ✅ **Create trigger detection module** (Gemini, 2025-12-10 10:10 - DONE)
  - File: `.ai-agents/session_context/trigger_detector.py`
  - Function: `detect_triggers(user_message: str, agent_response: str) -> List[str]`
  - Algorithm: Pattern matching on keywords (can be simple initially)
  - Owner: Gemini
  - **FAILSAFE:** Read-only, no side effects

- [x] ✅ **Test trigger detector with golden dataset** (Gemini, 2025-12-10 10:10 - DONE)
  - Run: Detector on all test cases
  - Measure: Precision (% of triggers correct), Recall (% of expected triggers found)
  - Target: >90% precision, >90% recall
  - Document results: `.ai-agents/validation/TRIGGER_DETECTION_RESULTS.md`
  - Owner: Gemini
  - **Why:** Validate before integration

- [x] ✅ **Measure false positive rate** (Gemini, 2025-12-10 10:10 - DONE)
  - Create negative test cases (no trigger should fire)
  - Run detector on negative cases
  - Target: <10% false positive rate
  - If too high: Refine patterns
  - Owner: Gemini
  - **Why:** Don't want unnecessary doc fetching

- [x] ✅ **Optimize trigger detection performance** (Gemini, 2025-12-10 10:10 - DONE)
  - Measure: Time to detect triggers (avg, p95, p99)
  - Target: <100ms average
  - If too slow: Optimize patterns (compile regex, etc.)
  - Owner: Gemini
  - **Why:** Can't add latency to every message

#### 1.3.3 Integration Testing

- [ ] **Test trigger detector with real messages**
  - Source: Recent session transcripts (if available)
  - Run: Detector on real messages
  - Validate: Triggers make sense in context
  - Owner: _____ (who does this?)
  - **Why:** Golden dataset may not cover all real patterns

- [ ] **Create integration stub for broker script**
  - File: `.ai-agents/session_context/broker_integration.py`
  - Function: `fetch_documents_for_triggers(triggers: List[str]) -> Dict[str, str]`
  - Behavior: Map trigger → file contents (from RETRIEVAL_TRIGGERS.md)
  - Owner: _____ (who does this?)
  - **FAILSAFE:** Read-only file access, no modifications

---

## Phase 1 Validation (CRITICAL - GATE TO PHASE 2)

### 1.4 Integration Testing

- [ ] **Test complete Phase 1 workflow**
  - Start session with MCP enabled
  - Verify context size <10KB
  - Trigger each of 5 trigger types manually
  - Verify correct documents fetched
  - Verify session log captures events correctly
  - Owner: _____ (who does this?)
  - **Why:** End-to-end validation before Phase 2

- [ ] **Compare to baseline measurements**
  - Metric: Context size (should be <10KB vs. 60KB baseline)
  - Metric: Session duration before degradation (should be >20 min vs. 10-20 baseline)
  - Metric: Information accessibility (should be same, not worse)
  - Document: `.ai-agents/validation/PHASE_1_RESULTS.md`
  - Owner: _____ (who does this?)
  - **Why:** Prove Phase 1 achieved goals

- [ ] **Test failure modes**
  - Test: MCP files missing → fallback to original behavior
  - Test: Invalid trigger → logs error, continues
  - Test: Corrupt session log → can still start new session
  - Owner: _____ (who does this?)
  - **Why:** Ensure graceful degradation

- [ ] **Run regression tests**
  - Run: All tests in `tests/` directory
  - Verify: Golden dataset still passes
  - Verify: No new failures introduced
  - Owner: _____ (who does this?)
  - **Why:** Ensure no regressions

### 1.5 Go/No-Go Decision for Phase 2

- [ ] **Review Phase 1 results with team**
  - Document: `.ai-agents/validation/PHASE_1_GO_NO_GO.md`
  - Decision criteria:
    - ✅ Context size reduced by >80%
    - ✅ Trigger detection >90% accurate
    - ✅ Session logs capturing events correctly
    - ✅ No critical regressions
    - ✅ Fallback mechanisms work
  - Decision: GO / NO-GO / ITERATE
  - Owner: _____ (who decides?)
  - **Why:** Don't proceed to Phase 2 unless Phase 1 proves value

---

## Phase 2: Multi-Agent Coordination

**STATUS:** Blocked until Phase 1 complete and validated

### 2.1 Broker Integration (Gemini)

- [ ] **Design broker MCP client**
  - File: `scripts/broker_mcp_client.sh` or `.py`
  - Behavior: Query MCP for context before sending to Gemini
  - Owner: _____ (who does this?)
  - **FAILSAFE:** New script, doesn't modify existing broker

- [ ] **Implement context logging**
  - Directory: `.gemini_logs/`
  - Format: `turn_{timestamp}_context.txt` (full prompt sent to Gemini)
  - Owner: _____ (who does this?)
  - **Why:** Observability - can reproduce Gemini's view

- [ ] **Test broker integration**
  - Test: Broker fetches context via triggers
  - Test: Full context logged every turn
  - Test: Gemini responses still correct
  - Owner: _____ (who does this?)
  - **Why:** Validate before production use

### 2.2 Mirror Exports (Codex)

- [ ] **Design export directory structure**
  - Directory: `docs/mcp_exports/`
  - Structure:

    ```
    docs/mcp_exports/
      GOVERNANCE_SUMMARY.md
      TROUBLESHOOTING_SUMMARY.md
      SESSION_{id}_SUMMARY.md
      metadata/
        provenance.json
    ```

  - Owner: _____ (who does this?)
  - **FAILSAFE:** New directory, doesn't touch existing docs

- [ ] **Implement export daemon**
  - File: `scripts/mcp_export_daemon.py`
  - Behavior: Watch for MCP state changes, export to files
  - Owner: _____ (who does this?)
  - **Why:** ChatGPT (Codex) can't query HTTP, needs files

- [ ] **Test export staleness detection**
  - Test: Exports >24h old → detected
  - Test: Stale exports → revert to full doc loads
  - Owner: _____ (who does this?)
  - **Why:** Prevent Codex from using outdated info

### 2.3 Handoff Standardization (ALL)

- [ ] **Create handoff template**
  - File: `.ai-agents/templates/HANDOFF_TEMPLATE.md`
  - Structure: Use Codex's 7-field schema
  - Owner: _____ (who does this?)
  - **Why:** Stop using free-form prose for handoffs

- [ ] **Test structured handoff**
  - Create: Sample handoff using template
  - Validate: All 7 fields present
  - Test: Agent can resume work from handoff alone
  - Owner: _____ (who does this?)
  - **Why:** Validate template is sufficient

---

## Phase 3: Production Hardening

**STATUS:** Blocked until Phase 2 complete

### 3.1 Observability

- [ ] **Create `/debug dump-context` command**
  - Owner: _____ (who does this?)

- [ ] **Implement retrieval logging**
  - Owner: _____ (who does this?)

- [ ] **Create context size tracking dashboard**
  - Owner: _____ (who does this?)

### 3.2 Failure Recovery

- [ ] **Test all failure modes**
  - MCP server down
  - Corrupt session logs
  - Missing export files
  - Invalid summaries
  - Owner: _____ (who does this?)

- [ ] **Implement auto-recovery**
  - Detect failures
  - Fallback to baseline behavior
  - Log incidents
  - Alert team
  - Owner: _____ (who does this?)

### 3.3 Success Metrics

- [ ] **Measure agent session duration improvement**
  - Baseline: 10-20 minutes before degradation
  - Target: 30+ minutes without degradation
  - Owner: _____ (who does this?)

- [ ] **Validate no information loss**
  - Compare: Tasks completable before vs. after MCP
  - Owner: _____ (who does this?)

---

## Failsafe Summary (Quick Reference)

### ONE-COMMAND ROLLBACK

```bash
git checkout pre-mcp-v1.1-baseline
# OR
./scripts/rollback_mcp.sh
```

### CRITICAL FILES (NEVER DELETE)

- CLAUDE.md
- TROUBLESHOOTING_CHECKLIST.md
- SELF_DIAGNOSTIC_FRAMEWORK.md
- scripts/start_session.sh (backup before modifying)
- All files in `docs/` (additive only)

### FEATURE FLAGS (DISABLE ANYTIME)

```json
{
  "MCP_ENABLED": false  // Instant disable
}
```

### BACKUPS LOCATION

- `.ai-agents/backups/` (all original files timestamped)

---

## Team Coordination

### Status Update Protocol

1. Mark checkbox when starting work: 🔄
2. Mark checkbox when complete: ✅
3. Add timestamp and your name
4. If blocked, add: ⛔ and reason

### Example

- [x] 🔄 Create governance summary (Claude Code, 2025-12-09 16:00 - IN PROGRESS)
- [x] ✅ Create governance summary (Claude Code, 2025-12-09 17:30 - DONE)

---

## Open Questions

1. **Who owns baseline measurements?** (Phase 0.2)
   - Need: Someone to run current system and measure
   - Urgency: High (need before implementation)

2. **Who creates golden dataset?** (Phase 0.4)
   - Need: Sample messages with expected triggers
   - Urgency: High (Gemini needs this to test)

3. **Who makes Go/No-Go decision?** (Phase 1.5)
   - Damian? All agents consensus? Claude Code?
   - Urgency: Medium (need before Phase 2)

---

## Next Actions (Immediate)

1. **ALL AGENTS:** Read this checklist
2. **ALL AGENTS:** Verify items marked complete are actually complete
3. **ALL AGENTS:** Identify which Phase 0 tasks you can do
4. **START:** Phase 0 baseline measurements (blocking everything else)
5. **THEN:** Phase 0 failsafe setup (before any code changes)
6. **THEN:** Phase 1 implementation (only after Phase 0 complete)

---

**END OF MASTER CHECKLIST**

**Status:** READY FOR TEAM REVIEW
**Next Update:** When any agent completes a task
