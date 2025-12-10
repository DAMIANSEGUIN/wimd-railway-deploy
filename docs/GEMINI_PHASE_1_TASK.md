# Gemini - Phase 1 Task 1C: Trigger Detector Implementation
**Priority:** P0 - Critical for MCP functionality
**Estimated Time:** 1-2 hours
**Status:** Ready to start

---

## Context

Phase 1 Task 1A (Claude Code) is COMPLETE:
- ✅ Session start script now outputs summaries (4.9KB) instead of full docs (30KB)
- ✅ 84% context reduction achieved
- ✅ Retrieval triggers defined in `.ai-agents/session_context/RETRIEVAL_TRIGGERS.md`
- ✅ Golden dataset created by you: `.ai-agents/test_data/TRIGGER_TEST_DATASET.json`

**Your task:** Implement the trigger detector that uses your golden dataset.

---

## Task 1C: Implement Trigger Detector

### What You're Building

A Python module that detects when to fetch full documentation based on conversation patterns.

**File to create:** `.ai-agents/session_context/trigger_detector.py`

---

## Implementation

### Step 1: Create the Trigger Detector

```python
#!/usr/bin/env python3
"""
MCP Trigger Detector
Detects when to retrieve full documentation based on conversation patterns
"""

import re
from typing import List, Set

class TriggerDetector:
    """Detects retrieval triggers from user messages and agent responses"""

    def __init__(self):
        # Define trigger patterns based on RETRIEVAL_TRIGGERS.md
        self.patterns = {
            "TROUBLESHOOTING_CHECKLIST": [
                r'\b(error|failed?|crash|bug|exception|broken|issue|problem|timeout)\b',
            ],
            "DEPLOYMENT_TRUTH": [
                r'\b(deploy|push|railway|production|staging|release|rollback)\b',
            ],
            "STORAGE_PATTERNS": [
                r'\b(database|postgresql|sqlite|query|migration|schema|connection|sql)\b',
            ],
            "TEST_FRAMEWORK": [
                r'\b(test|pytest|golden|failing\s+test|coverage|unit\s+test)\b',
            ],
            "CONTEXT_ENGINEERING_GUIDE": [
                # Triggered by response length, not keywords
            ]
        }

        # Compile regex patterns
        self.compiled_patterns = {}
        for trigger, patterns in self.patterns.items():
            self.compiled_patterns[trigger] = [
                re.compile(pattern, re.IGNORECASE)
                for pattern in patterns
            ]

    def detect_triggers(
        self,
        user_message: str,
        agent_response: str = ""
    ) -> List[str]:
        """
        Detect which documents should be retrieved

        Args:
            user_message: The user's input message
            agent_response: The agent's response (optional)

        Returns:
            List of document names to retrieve (e.g., ["TROUBLESHOOTING_CHECKLIST"])
        """
        triggered = set()

        # Combine messages for pattern matching
        combined_text = f"{user_message} {agent_response}"

        # Check keyword-based triggers
        for trigger, patterns in self.compiled_patterns.items():
            if trigger == "CONTEXT_ENGINEERING_GUIDE":
                continue  # Handled separately below

            for pattern in patterns:
                if pattern.search(combined_text):
                    triggered.add(trigger)
                    break  # One match per trigger is enough

        # Check context overflow trigger (response length)
        if agent_response:
            word_count = len(agent_response.split())
            if word_count > 1000:
                triggered.add("CONTEXT_ENGINEERING_GUIDE")

        return sorted(list(triggered))

    def get_document_paths(self, triggers: List[str]) -> dict:
        """
        Map trigger names to actual document paths

        Args:
            triggers: List of trigger names

        Returns:
            Dict mapping trigger to file path
        """
        document_map = {
            "TROUBLESHOOTING_CHECKLIST": "TROUBLESHOOTING_CHECKLIST.md",
            "DEPLOYMENT_TRUTH": "CLAUDE.md",  # Deployment section
            "STORAGE_PATTERNS": "SELF_DIAGNOSTIC_FRAMEWORK.md",  # Storage section
            "TEST_FRAMEWORK": "CLAUDE.md",  # Testing section
            "CONTEXT_ENGINEERING_GUIDE": "docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md"
        }

        return {trigger: document_map[trigger] for trigger in triggers if trigger in document_map}


def main():
    """Test the trigger detector with sample messages"""
    detector = TriggerDetector()

    # Test cases
    test_cases = [
        ("The deployment failed with a 500 error", ""),
        ("Can you help me write a test?", ""),
        ("The PostgreSQL connection is timing out", ""),
        ("Normal conversation", ""),
        ("Test case", "word " * 1500),  # Long response
    ]

    print("Trigger Detector Test Results:")
    print("-" * 60)

    for user_msg, agent_resp in test_cases:
        triggers = detector.detect_triggers(user_msg, agent_resp)
        print(f"\nUser: {user_msg[:50]}...")
        print(f"Agent: {agent_resp[:50]}...")
        print(f"Triggers: {triggers if triggers else 'None'}")

    print("\n" + "=" * 60)
    print("Test complete. Run with golden dataset for full validation.")


if __name__ == "__main__":
    main()
```

**Save this as:** `.ai-agents/session_context/trigger_detector.py`

---

### Step 2: Test with Your Golden Dataset

Create a test file to validate against your 25 test cases:

**File:** `tests/test_trigger_detector.py`

```python
#!/usr/bin/env python3
"""
Test trigger detector against golden dataset
"""

import json
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from .ai_agents.session_context.trigger_detector import TriggerDetector


def load_golden_dataset():
    """Load the golden dataset"""
    dataset_path = Path(".ai-agents/test_data/TRIGGER_TEST_DATASET.json")

    if not dataset_path.exists():
        print(f"ERROR: Golden dataset not found at {dataset_path}")
        sys.exit(1)

    with open(dataset_path) as f:
        return json.load(f)


def test_trigger_detector():
    """Test trigger detector with golden dataset"""
    detector = TriggerDetector()
    dataset = load_golden_dataset()

    total_cases = len(dataset)
    correct = 0
    false_positives = 0
    false_negatives = 0

    print(f"Testing {total_cases} cases from golden dataset...")
    print("=" * 80)

    for case in dataset:
        case_id = case["id"]
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")
        expected = set(case["expected_triggers"])
        should_not = set(case["should_not_trigger"])

        # Detect triggers
        detected = set(detector.detect_triggers(user_msg, agent_resp))

        # Check correctness
        is_correct = (expected == detected or expected.issubset(detected))
        has_false_positives = bool(detected.intersection(should_not))
        has_false_negatives = bool(expected - detected)

        if is_correct and not has_false_positives:
            correct += 1
            status = "✅ PASS"
        else:
            status = "❌ FAIL"

        if has_false_positives:
            false_positives += 1
        if has_false_negatives:
            false_negatives += 1

        # Print result
        print(f"\n{status} [{case_id}]")
        print(f"  User: {user_msg[:60]}...")
        print(f"  Expected: {sorted(expected)}")
        print(f"  Detected: {sorted(detected)}")

        if has_false_positives:
            fp = detected.intersection(should_not)
            print(f"  ⚠️  False positives: {sorted(fp)}")

        if has_false_negatives:
            fn = expected - detected
            print(f"  ⚠️  False negatives (missed): {sorted(fn)}")

    # Summary
    print("\n" + "=" * 80)
    print("SUMMARY:")
    print(f"  Total cases: {total_cases}")
    print(f"  Correct: {correct} ({correct/total_cases*100:.1f}%)")
    print(f"  False positives: {false_positives}")
    print(f"  False negatives: {false_negatives}")

    # Metrics
    precision = correct / total_cases if total_cases > 0 else 0
    fp_rate = false_positives / total_cases if total_cases > 0 else 0

    print(f"\nMETRICS:")
    print(f"  Precision: {precision*100:.1f}%")
    print(f"  False positive rate: {fp_rate*100:.1f}%")

    # Success criteria
    print(f"\nSUCCESS CRITERIA:")
    print(f"  Precision >90%: {'✅ PASS' if precision >= 0.90 else '❌ FAIL'}")
    print(f"  FP rate <10%: {'✅ PASS' if fp_rate < 0.10 else '❌ FAIL'}")

    return precision >= 0.90 and fp_rate < 0.10


if __name__ == "__main__":
    success = test_trigger_detector()
    sys.exit(0 if success else 1)
```

---

### Step 3: Run the Tests

```bash
# Navigate to project directory
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

# Make trigger detector executable
chmod +x .ai-agents/session_context/trigger_detector.py

# Run basic test
python3 .ai-agents/session_context/trigger_detector.py

# Run golden dataset validation
python3 tests/test_trigger_detector.py
```

---

### Step 4: Iterate if Needed

**If precision < 90% or FP rate > 10%:**

1. **Review failed cases** - Identify patterns
2. **Adjust regex patterns** - Add/remove keywords in `trigger_detector.py`
3. **Re-run tests** - Validate improvements
4. **Document changes** - Note what patterns were adjusted

**Common adjustments:**
- Add more keywords to patterns
- Make patterns more specific (e.g., `\btest\b` vs `test`)
- Adjust word boundaries
- Handle multi-word phrases

---

## Success Criteria

Your implementation is complete when:

- ✅ Trigger detector file created: `.ai-agents/session_context/trigger_detector.py`
- ✅ Test file created: `tests/test_trigger_detector.py`
- ✅ Precision >90% on golden dataset
- ✅ False positive rate <10%
- ✅ All 5 trigger types detected correctly
- ✅ Context overflow trigger works (>1000 word responses)

---

## Update Checklist

After completing the task:

1. **Mark complete in master checklist:**
   - File: `docs/MCP_V1_1_MASTER_CHECKLIST.md`
   - Find section 1.3 "Retrieval Trigger Detection (Gemini)"
   - Mark tasks as complete with timestamp

2. **Document results:**
   - Create: `.ai-agents/validation/TRIGGER_DETECTION_RESULTS.md`
   - Include: Precision, recall, false positive rate
   - Include: Any pattern adjustments made
   - Include: Test output from golden dataset

3. **Update your response file:**
   - File: `docs/mcp_responses/GEMINI_RESPONSES.md`
   - Add section: "Phase 1 Task 1C Complete"
   - Note any challenges or learnings

---

## What Happens Next

After you complete Task 1C:

1. **Phase 1 Validation:**
   - Claude Code will integrate trigger detector with session start
   - Test end-to-end workflow (summaries + retrieval)
   - Validate context reduction + retrieval works

2. **Phase 1 Complete:**
   - If both Task 1A (done) and 1C (yours) pass validation
   - Go/No-Go decision for Phase 2

3. **Phase 2 (if approved):**
   - Broker integration (your work)
   - Structured session logs (Codex or Claude Code)
   - Multi-agent coordination

---

## Questions?

If blocked or have questions:

1. **Document in checklist:**
   ```markdown
   - [ ] ⛔ Task description (BLOCKED: reason)
   ```

2. **Add to your response file:**
   - `docs/mcp_responses/GEMINI_RESPONSES.md`
   - Section: "Blockers and Questions"

3. **Continue with other tasks if possible**

---

## Files Reference

**Your golden dataset (already created):**
- `.ai-agents/test_data/TRIGGER_TEST_DATASET.json`

**Retrieval triggers map (reference):**
- `.ai-agents/session_context/RETRIEVAL_TRIGGERS.md`

**Files to create:**
- `.ai-agents/session_context/trigger_detector.py`
- `tests/test_trigger_detector.py`
- `.ai-agents/validation/TRIGGER_DETECTION_RESULTS.md` (after testing)

**Files to update:**
- `docs/MCP_V1_1_MASTER_CHECKLIST.md` (mark complete)
- `docs/mcp_responses/GEMINI_RESPONSES.md` (document work)

---

**Good luck! The golden dataset you created is excellent - this should go smoothly.**
