import json
import sys
from pathlib import Path

import pytest

# Add the directory containing trigger_detector.py to the Python path
sys.path.insert(0, str(Path(__file__).parent.parent / ".ai-agents" / "session_context"))

try:
    from trigger_detector import detect_retrieval_triggers
except ImportError:
    # Placeholder for testing framework if detect_retrieval_triggers is not yet implemented
    # or if path resolution fails in some environments.
    # This should not be hit in a correctly set up environment after Phase 1.3.2.
    def detect_retrieval_triggers(user_message: str, agent_response: str = "") -> list:
        """Placeholder - actual implementation is in .ai-agents/session_context/trigger_detector.py"""
        print("WARNING: Using placeholder detect_retrieval_triggers. Ensure module is importable.")
        return []


def load_golden_dataset():
    """Load the golden dataset for trigger detection"""
    dataset_path = Path(".ai-agents/test_data/TRIGGER_TEST_DATASET.json")

    if not dataset_path.exists():
        # Using pytest.skip for test cases that require the dataset.
        # The test_golden_dataset_format will also check for existence.
        pytest.skip(f"Golden dataset not found at {dataset_path} - run Phase 0.4.1 first")

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
        assert "rationale" in case, f"Case missing 'rationale': {case}"  # Added rationale check


def test_trigger_detection_precision(golden_dataset):
    """Test that trigger detector has high precision (>90%)"""
    correct_detections = 0
    total_cases_with_expected = 0
    errors = []

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")
        expected_triggers = set(case["expected_triggers"])
        should_not_trigger = set(case["should_not_trigger"])

        detected_triggers = set(detect_retrieval_triggers(user_msg, agent_resp))

        # Check for false positives against should_not_trigger
        false_positives_against_should_not = detected_triggers.intersection(should_not_trigger)
        if false_positives_against_should_not:
            errors.append(
                f"Case {case['id']}: False positives against should_not_trigger: {false_positives_against_should_not} (Detected: {detected_triggers}, Should not trigger: {should_not_trigger})"
            )

        # Check if all detected triggers are either expected or not explicitly forbidden
        # This focuses on precision by checking if detected triggers are "correct"
        # A trigger is "correct" if it's in expected_triggers AND NOT in should_not_trigger.
        # Or, more simply, if it's in expected_triggers.
        # This metric needs to be carefully defined for "precision".
        # For simplicity, let's count how many detected are *actually* in expected.
        correctly_detected_for_this_case = len(detected_triggers.intersection(expected_triggers))
        total_detected_for_this_case = len(detected_triggers)

        if total_detected_for_this_case > 0:
            if correctly_detected_for_this_case == len(detected_triggers):
                # All detected are correct and no forbidden ones were detected.
                correct_detections += 1
            else:
                # Some detected triggers were not in expected, or were in should_not_trigger.
                errors.append(
                    f"Case {case['id']}: Incorrect detections. Detected: {detected_triggers}, Expected: {expected_triggers}, Should not: {should_not_trigger}"
                )
        elif len(expected_triggers) == 0 and total_detected_for_this_case == 0:
            correct_detections += 1  # No expected and no detected, counts as correct.
        elif len(expected_triggers) > 0 and total_detected_for_this_case == 0:
            # Missed all expected triggers, not precise for what it did detect (nothing).
            errors.append(
                f"Case {case['id']}: No triggers detected but expected some. Expected: {expected_triggers}"
            )

        total_cases_with_expected += 1  # Count each case for overall precision.

    # Precision calculation needs refinement depending on exact definition.
    # If precision is "out of what it detected, how many were correct?", then:
    # Sum of (correctly_detected_in_case / total_detected_in_case) / total_cases

    # Let's adjust to a more common definition of precision:
    # (True Positives) / (True Positives + False Positives)
    # Where False Positives are triggers that were detected but were not in 'expected_triggers'
    # Or, were in 'should_not_trigger'. The latter is a stronger check.

    true_positives_total = 0
    false_positives_total = 0

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")
        expected = set(case["expected_triggers"])
        should_not = set(case["should_not_trigger"])

        detected = set(detect_retrieval_triggers(user_msg, agent_resp))

        true_positives_total += len(detected.intersection(expected))

        # False positives are triggers detected that are NOT in expected,
        # OR triggers detected that are in should_not_trigger.
        false_positives_total += len(detected - expected)  # Detected but not expected
        false_positives_total += len(
            detected.intersection(should_not)
        )  # Detected and should not trigger

    # Prevent division by zero if no triggers are detected at all
    precision = (
        true_positives_total / (true_positives_total + false_positives_total)
        if (true_positives_total + false_positives_total) > 0
        else 1.0
    )

    if precision < 0.90:
        print("\n".join(errors))
        pytest.fail(f"Precision {precision:.2%} < 90% target")


def test_trigger_detection_recall(golden_dataset):
    """Test that trigger detector has high recall (>90%)"""
    total_expected_triggers = 0
    total_found_expected_triggers = 0
    errors = []

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")
        expected = set(case["expected_triggers"])

        detected = set(detect_retrieval_triggers(user_msg, agent_resp))

        total_expected_triggers += len(expected)
        total_found_expected_triggers += len(detected.intersection(expected))

        if not expected.issubset(detected) and len(expected) > 0:
            missed = expected - detected
            errors.append(
                f"Case {case['id']}: Missed expected triggers: {missed} (Detected: {detected}, Expected: {expected})"
            )

    recall = (
        total_found_expected_triggers / total_expected_triggers
        if total_expected_triggers > 0
        else 1.0
    )

    if recall < 0.90:
        print("\n".join(errors))
        pytest.fail(f"Recall {recall:.2%} < 90% target")


def test_false_positive_rate(golden_dataset):
    """Test that false positive rate is <10%"""
    total_should_not_possible = 0  # Total count of triggers that should NOT fire across all cases
    actual_false_positives = (
        0  # Count of triggers that erroneously fired from should_not_trigger list
    )

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")
        should_not = set(case["should_not_trigger"])

        detected = set(detect_retrieval_triggers(user_msg, agent_resp))

        total_should_not_possible += len(should_not)
        actual_false_positives += len(detected.intersection(should_not))

    fp_rate = (
        actual_false_positives / total_should_not_possible if total_should_not_possible > 0 else 0.0
    )

    assert fp_rate < 0.10, f"False positive rate {fp_rate:.2%} >= 10% target"


def test_trigger_detection_performance(golden_dataset):
    """Test that trigger detection is fast (<100ms average)"""
    import time

    times = []

    for case in golden_dataset:
        user_msg = case["user_message"]
        agent_resp = case.get("agent_response", "")

        start = time.perf_counter()
        detect_retrieval_triggers(user_msg, agent_resp)
        elapsed = (time.perf_counter() - start) * 1000  # Convert to ms

        times.append(elapsed)

    avg_time = sum(times) / len(times) if times else 0

    assert avg_time < 100, f"Average detection time {avg_time:.2f}ms >= 100ms target"
