#!/usr/bin/env python3
"""
Test trigger detector against golden dataset
"""

import json
import sys
from pathlib import Path

# Add parent directory to path to allow import from .ai-agents
sys.path.insert(0, './.ai-agents')
from session_context.trigger_detector import TriggerDetector


def load_golden_dataset():
    """Load the golden dataset"""
    # Correct path assuming script is run from project root
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
    
    # Store detailed results for summary
    results_log = []

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

        # Evaluate correctness
        # Correct if all expected triggers are present AND no disallowed triggers are present.
        is_correct = expected.issubset(detected) and not detected.intersection(should_not)
        
        # A more precise correctness check: detected set must exactly match the expected set.
        # This aligns better with precision/recall metrics.
        is_exact_match = (expected == detected)

        has_false_positives = bool(detected - expected)
        has_false_negatives = bool(expected - detected)
        
        # Let's stick to the definition from the instructions: "Correct if all expected triggers are present AND no disallowed triggers are present"
        # The prompt defines `should_not_trigger` which is key.
        # A detection is a PASS if:
        # 1. It finds all `expected_triggers`.
        # 2. It does NOT find any `should_not_trigger`.
        # Detections that are not in `expected_triggers` but also not in `should_not_trigger` are tolerated.
        
        # Let's refine the logic based on standard metrics.
        # True Positives (TP): correctly identified triggers (detected intersect expected)
        # False Positives (FP): incorrectly identified triggers (detected - expected)
        # False Negatives (FN): missed triggers (expected - detected)
        
        tp = detected.intersection(expected)
        fp = detected - expected
        fn = expected - detected

        # A case is a "pass" if it has no FPs and no FNs.
        if not fp and not fn:
            correct += 1
            status = "✅ PASS"
        else:
            status = "❌ FAIL"
        
        if fp:
            false_positives += len(fp)
        if fn:
            false_negatives += len(fn)

        result_details = {
            "status": status,
            "case_id": case_id,
            "user_msg": user_msg,
            "expected": sorted(list(expected)),
            "detected": sorted(list(detected)),
            "fp": sorted(list(fp)),
            "fn": sorted(list(fn))
        }
        results_log.append(result_details)

        # Print result
        print(f"\n{status} [{case_id}]")
        print(f"  User: {user_msg[:60]}...")
        print(f"  Expected: {result_details['expected']}")
        print(f"  Detected: {result_details['detected']}")

        if fp:
            print(f"  ⚠️  False positives: {result_details['fp']}")

        if fn:
            print(f"  ⚠️  False negatives (missed): {result_details['fn']}")


    # Summary
    # Total number of potential triggers across all test cases
    total_possible_positives = sum(len(case["expected_triggers"]) for case in dataset)
    total_true_positives = total_possible_positives - false_negatives

    # Precision = TP / (TP + FP)
    precision = total_true_positives / (total_true_positives + false_positives) if (total_true_positives + false_positives) > 0 else 0.0
    
    # False Positive Rate not well-defined here without True Negatives. Let's use the definition from the instructions:
    # "FP rate < 10%" implies `false_positives / total_cases < 0.1`
    fp_rate = sum(1 for r in results_log if r['fp']) / total_cases if total_cases > 0 else 0.0
    
    # Let's recalculate precision based on the number of correct *cases*, as in the instructions
    case_precision = correct / total_cases if total_cases > 0 else 0

    print("\n" + "=" * 80)
    print("SUMMARY:")
    print(f"  Total cases: {total_cases}")
    print(f"  Correct cases (exact match): {correct} ({case_precision*100:.1f}%)")
    
    # Count cases with at least one false positive
    fp_case_count = sum(1 for r in results_log if r['fp'])
    print(f"  Cases with False Positives: {fp_case_count}")
    # Count cases with at least one false negative
    fn_case_count = sum(1 for r in results_log if r['fn'])
    print(f"  Cases with False Negatives: {fn_case_count}")

    # METRICS as defined in instructions
    # Precision is based on cases
    precision_metric = case_precision
    # FP rate is based on cases
    fp_rate_metric = fp_case_count / total_cases if total_cases > 0 else 0


    print(f"\nMETRICS (as per instruction interpretation):")
    print(f"  Case Precision: {precision_metric*100:.1f}%")
    print(f"  False Positive Rate (by case): {fp_rate_metric*100:.1f}%")

    # Success criteria
    print(f"\nSUCCESS CRITERIA:")
    print(f"  Precision >90%: {'✅ PASS' if precision_metric >= 0.90 else '❌ FAIL'}")
    print(f"  FP rate <10%: {'✅ PASS' if fp_rate_metric < 0.10 else '❌ FAIL'}")

    return precision_metric >= 0.90 and fp_rate_metric < 0.10


if __name__ == "__main__":


    success = test_trigger_detector()


    sys.exit(0 if success else 1)

