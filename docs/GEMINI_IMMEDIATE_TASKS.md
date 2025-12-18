# Gemini - Immediate Tasks (Phase 0)

**Priority: URGENT - Start These Now**
**Date: 2025-12-09**
**From: Claude Code**

---

## Situation

Codex has hit limit and cannot continue. You (Gemini) are now the primary implementation agent along with Claude Code.

**Master Plan:** `docs/MCP_V1_1_MASTER_CHECKLIST.md` - Read this first

---

## Your Immediate Tasks (Phase 0 - Next 2 Hours)

### Task 0.4.1: Create Golden Dataset for Trigger Detection

**File:** `.ai-agents/test_data/TRIGGER_TEST_DATASET.json`
**Priority:** P0 - Blocking your Phase 1 work
**Time Estimate:** 1 hour

**What to Create:**
A JSON file with 20-30 test cases for trigger detection. Each case includes:

- User message
- Agent response (optional)
- Expected triggers that should fire
- Triggers that should NOT fire
- Rationale for the classification

**Format:**

```json
[
  {
    "id": "test_001",
    "user_message": "The deployment to Railway failed with a 500 error",
    "agent_response": "Let me check the deployment logs...",
    "expected_triggers": ["error", "deployment"],
    "should_not_trigger": ["database", "test"],
    "rationale": "Contains 'failed' (error keyword) and 'deployment' (deployment keyword)"
  },
  {
    "id": "test_002",
    "user_message": "Can you help me write a test for the auth system?",
    "agent_response": "Sure, let's create a test...",
    "expected_triggers": ["test"],
    "should_not_trigger": ["error", "deployment", "database"],
    "rationale": "Contains 'test' keyword, no error or failure"
  },
  {
    "id": "test_003",
    "user_message": "The PostgreSQL connection is timing out",
    "agent_response": "This could be a database configuration issue...",
    "expected_triggers": ["error", "database"],
    "should_not_trigger": ["deployment", "test"],
    "rationale": "Contains 'timing out' (error) and 'PostgreSQL' (database)"
  }
  // Add 17-27 more cases covering:
  // - Error scenarios (bugs, failures, crashes)
  // - Deployment scenarios (deploy, push, railway, production)
  // - Database scenarios (PostgreSQL, SQLite, queries, migrations)
  // - Test scenarios (pytest, golden dataset, test failures)
  // - Context overflow (very long responses)
  // - Edge cases (ambiguous, multiple triggers, no triggers)
]
```

**5 Trigger Types to Cover:**

1. **error** - Keywords: error, failed, crash, bug, exception, broken, issue, problem, timeout
2. **deployment** - Keywords: deploy, push, railway, production, staging, release, rollback
3. **database** - Keywords: database, postgresql, sqlite, query, migration, schema, connection, SQL
4. **test** - Keywords: test, pytest, golden, failing test, test coverage, unit test
5. **context_overflow** - Triggered when agent response >1000 words (not keyword-based)

**Include Edge Cases:**

- Message with NO triggers (normal conversation)
- Message with MULTIPLE triggers (deployment failed = error + deployment)
- Ambiguous messages (could be interpreted multiple ways)
- False positives to avoid (words that sound like triggers but aren't)

**Deliverable:**

- File created: `.ai-agents/test_data/TRIGGER_TEST_DATASET.json`
- Contains 20-30 test cases
- Covers all 5 trigger types
- Includes edge cases

**Mark in Checklist:**

```markdown
- [x] ✅ Create golden dataset for trigger detection (Gemini, 2025-12-09 HH:MM - DONE)
```

---

### Task 0.2.3: Test Current Agent Performance at 20-Minute Mark

**File:** `.ai-agents/baseline/20MIN_BASELINE_SESSION.md`
**Priority:** P0 - Proves the problem exists
**Time Estimate:** 30 minutes (20 min session + 10 min documentation)

**What to Do:**

1. Start a fresh session (clear context)
2. Work on a complex task for 20 minutes
3. Document any degradation you observe:
   - Forgetting original task
   - Repeated questions/debates
   - Quality decline in responses
   - Context confusion
   - Lost track of commitments

**Format:**

```markdown
# 20-Minute Baseline Session - Gemini
**Date:** 2025-12-09
**Agent:** Gemini
**Task:** [Describe the task you worked on]

## Timeline

### 0-5 Minutes
- Task understanding: [Good/Fair/Poor]
- Response quality: [Good/Fair/Poor]
- Context awareness: [Good/Fair/Poor]
- Notes: [Any observations]

### 5-10 Minutes
- [Same metrics]

### 10-15 Minutes
- [Same metrics]

### 15-20 Minutes
- [Same metrics]

## Degradation Observed

### Symptoms:
- [ ] Forgot original task
- [ ] Repeated same question
- [ ] Lost track of previous decision
- [ ] Confused about context
- [ ] Quality decline in responses
- [ ] Other: [describe]

### Specific Examples:
1. [Example of degradation]
2. [Example of degradation]

## Conclusion

**Did degradation occur?** Yes/No
**At what point?** [Minute mark]
**Severity:** Minor/Moderate/Severe

This baseline will be compared to post-MCP sessions to measure improvement.
```

**Deliverable:**

- File created: `.ai-agents/baseline/20MIN_BASELINE_SESSION.md`
- Documents actual degradation (if any)
- Provides baseline for comparison

**Mark in Checklist:**

```markdown
- [x] ✅ Test current agent performance at 20-minute mark (Gemini, 2025-12-09 HH:MM - DONE)
```

---

### Task 0.3.2: Create Feature Flag System

**File:** `.ai-agents/config/feature_flags.json`
**Priority:** P0 - Required before any code changes
**Time Estimate:** 15 minutes

**What to Create:**
A simple JSON file that controls MCP features. This allows disabling MCP without code changes.

**Format:**

```json
{
  "schema_version": "v1.0",
  "last_updated": "2025-12-09T16:00:00Z",
  "flags": {
    "MCP_ENABLED": false,
    "MCP_SESSION_SUMMARIES": false,
    "MCP_RETRIEVAL_TRIGGERS": false,
    "MCP_STRUCTURED_LOGS": false,
    "MCP_BROKER_INTEGRATION": false,
    "MCP_MIRROR_EXPORTS": false
  },
  "notes": {
    "MCP_ENABLED": "Master switch - disables all MCP features",
    "MCP_SESSION_SUMMARIES": "Load summaries instead of full docs at session start",
    "MCP_RETRIEVAL_TRIGGERS": "Automatic document retrieval based on triggers",
    "MCP_STRUCTURED_LOGS": "Log events in structured format",
    "MCP_BROKER_INTEGRATION": "Broker script uses MCP for context",
    "MCP_MIRROR_EXPORTS": "Export MCP state to files for mirror agent"
  }
}
```

**Also Create Reader Function:**
**File:** `.ai-agents/config/read_flags.py`

```python
import json
from pathlib import Path

def read_feature_flags() -> dict:
    """Read feature flags from JSON file"""
    flag_file = Path(".ai-agents/config/feature_flags.json")

    if not flag_file.exists():
        # Default: all disabled
        return {
            "MCP_ENABLED": False,
            "MCP_SESSION_SUMMARIES": False,
            "MCP_RETRIEVAL_TRIGGERS": False,
            "MCP_STRUCTURED_LOGS": False,
            "MCP_BROKER_INTEGRATION": False,
            "MCP_MIRROR_EXPORTS": False
        }

    with open(flag_file) as f:
        data = json.load(f)
        return data.get("flags", {})

def is_feature_enabled(feature_name: str) -> bool:
    """Check if a specific feature is enabled"""
    flags = read_feature_flags()

    # If master switch is off, all features disabled
    if not flags.get("MCP_ENABLED", False):
        return False

    return flags.get(feature_name, False)

# Usage example:
# if is_feature_enabled("MCP_SESSION_SUMMARIES"):
#     load_summaries()
# else:
#     load_full_docs()
```

**Deliverable:**

- File created: `.ai-agents/config/feature_flags.json`
- File created: `.ai-agents/config/read_flags.py`
- All flags default to `false` (safe)

**Mark in Checklist:**

```markdown
- [x] ✅ Create feature flag system (Gemini, 2025-12-09 HH:MM - DONE)
```

---

### Task 0.4.2: Create Test Harness for Trigger Detection

**File:** `tests/test_mcp_triggers.py`
**Priority:** P0 - Validates your Phase 1 work
**Time Estimate:** 30 minutes

**What to Create:**
A pytest test file that validates trigger detection using the golden dataset you created.

**Format:**

```python
import pytest
import json
from pathlib import Path

# Import the trigger detector (will be created in Phase 1)
# For now, create placeholder import
try:
    from .ai_agents.session_context.trigger_detector import detect_triggers
except ImportError:
    # Placeholder for testing framework
    def detect_triggers(user_message: str, agent_response: str = "") -> list:
        """Placeholder - will be implemented in Phase 1"""
        return []

def load_golden_dataset():
    """Load the golden dataset for trigger detection"""
    dataset_path = Path(".ai-agents/test_data/TRIGGER_TEST_DATASET.json")

    if not dataset_path.exists():
        pytest.skip("Golden dataset not found - run Phase 0.4.1 first")

    with open(dataset_path) as f:
        return json.load(f)

@pytest.fixture
def golden_dataset():
    """Pytest fixture to load golden dataset"""
    return load_golden_dataset()

def test_golden_dataset_format(golden_dataset):
    """Validate the golden dataset format is correct"""
    assert isinstance(golden_dataset, list), "Dataset should be a list"
    assert len(golden_dataset) >= 20, "Dataset should have at least 20 test cases"

    for case in golden_dataset:
        assert "id" in case, f"Case missing 'id': {case}"
        assert "user_message" in case, f"Case missing 'user_message': {case}"
        assert "expected_triggers" in case, f"Case missing 'expected_triggers': {case}"
        assert "should_not_trigger" in case, f"Case missing 'should_not_trigger': {case}"

def test_trigger_detection_precision(golden_dataset):
    """Test that trigger detector has high precision (>90%)"""
    correct = 0
    total = 0
    errors = []

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")
        expected = set(case["expected_triggers"])
        should_not = set(case["should_not_trigger"])

        detected = set(detect_triggers(user_msg, agent_resp))

        # Check if all expected triggers were detected
        if expected.issubset(detected):
            correct += 1
        else:
            missed = expected - detected
            errors.append(f"Case {case['id']}: Missed triggers {missed}")

        # Check for false positives
        false_positives = detected.intersection(should_not)
        if false_positives:
            errors.append(f"Case {case['id']}: False positives {false_positives}")

        total += 1

    precision = correct / total if total > 0 else 0

    if precision < 0.90:
        print("\n".join(errors))
        pytest.fail(f"Precision {precision:.2%} < 90% target")

def test_trigger_detection_recall(golden_dataset):
    """Test that trigger detector has high recall (>90%)"""
    total_expected = 0
    total_detected = 0

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")
        expected = set(case["expected_triggers"])

        detected = set(detect_triggers(user_msg, agent_resp))

        total_expected += len(expected)
        total_detected += len(expected.intersection(detected))

    recall = total_detected / total_expected if total_expected > 0 else 0

    assert recall >= 0.90, f"Recall {recall:.2%} < 90% target"

def test_false_positive_rate(golden_dataset):
    """Test that false positive rate is <10%"""
    total_should_not = 0
    false_positives = 0

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")
        should_not = set(case["should_not_trigger"])

        detected = set(detect_triggers(user_msg, agent_resp))

        total_should_not += len(should_not)
        false_positives += len(detected.intersection(should_not))

    fp_rate = false_positives / total_should_not if total_should_not > 0 else 0

    assert fp_rate < 0.10, f"False positive rate {fp_rate:.2%} >= 10%"

def test_trigger_detection_performance(golden_dataset):
    """Test that trigger detection is fast (<100ms average)"""
    import time

    times = []

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")

        start = time.perf_counter()
        detect_triggers(user_msg, agent_resp)
        elapsed = (time.perf_counter() - start) * 1000  # Convert to ms

        times.append(elapsed)

    avg_time = sum(times) / len(times) if times else 0

    assert avg_time < 100, f"Average detection time {avg_time:.2f}ms >= 100ms target"
```

**Deliverable:**

- File created: `tests/test_mcp_triggers.py`
- Tests validate: format, precision, recall, false positives, performance
- Can run (will skip if trigger_detector.py not implemented yet)

**Mark in Checklist:**

```markdown
- [x] ✅ Create test harness for trigger detection (Gemini, 2025-12-09 HH:MM - DONE)
```

---

## After Completing These Tasks

1. **Update the master checklist:**
   - File: `docs/MCP_V1_1_MASTER_CHECKLIST.md`
   - Mark your completed tasks with ✅

2. **Document your status:**
   - File: `docs/mcp_responses/GEMINI_RESPONSES.md`
   - Add section: "Phase 0 Work Completed"
   - List what you did and any findings

3. **Coordinate with Claude Code:**
   - Claude Code is working on Phase 0 failsafes (git tag, rollback script)
   - Once both Phase 0 efforts complete, can start Phase 1

4. **Wait for Phase 1 green light:**
   - Don't start Phase 1 implementation until Phase 0 validated
   - Phase 1 is your trigger detector implementation (using the golden dataset you created)

---

## Questions / Blockers?

If you have questions or get blocked:

1. **Document in checklist:**

   ```markdown
   - [ ] ⛔ Task description (BLOCKED: reason)
   ```

2. **Update your response file:**
   - Add to `docs/mcp_responses/GEMINI_RESPONSES.md`

3. **Continue with other Phase 0 tasks:**
   - Don't block on one task, do others in parallel

---

## Summary

**Your Phase 0 Tasks (Next 2 Hours):**

1. ✅ Create golden dataset (20-30 test cases) - 1 hour
2. ✅ Test 20-minute baseline session - 30 min
3. ✅ Create feature flag system - 15 min
4. ✅ Create test harness for triggers - 30 min

**Total Time:** ~2 hours 15 minutes
**After Complete:** Update checklist, coordinate with Claude Code for Phase 1

**Priority:** These are BLOCKING tasks - Phase 1 cannot start without them

---

**Good luck! These Phase 0 tasks set up the foundation for safe implementation.**
