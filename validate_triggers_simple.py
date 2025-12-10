#!/usr/bin/env python3
"""
Simple trigger validation - bypasses import issues
"""
import json
import sys
sys.path.insert(0, '.ai-agents/session_context')
from trigger_detector import TriggerDetector

# Load golden dataset
with open('.ai-agents/test_data/TRIGGER_TEST_DATASET.json') as f:
    dataset = json.load(f)

detector = TriggerDetector()
total = len(dataset)
correct = 0
fp_cases = 0
fn_cases = 0

print(f"Testing {total} cases...")
print("=" * 80)

for case in dataset:
    expected = set(case["expected_triggers"])
    detected = set(detector.detect_triggers(case["user_message"], case.get("agent_response", "")))

    fp = detected - expected
    fn = expected - detected

    is_correct = (not fp and not fn)

    if is_correct:
        correct += 1
        print(f"✅ {case['id']}")
    else:
        print(f"❌ {case['id']}")
        if fp:
            fp_cases += 1
            print(f"   FP: {sorted(fp)}")
        if fn:
            fn_cases += 1
            print(f"   FN: {sorted(fn)}")

print("\n" + "=" * 80)
precision = correct / total
fp_rate = fp_cases / total

print(f"Results: {correct}/{total} correct ({precision*100:.1f}%)")
print(f"FP cases: {fp_cases} ({fp_rate*100:.1f}%)")
print(f"FN cases: {fn_cases}")
print(f"\n✅ PASS" if (precision >= 0.90 and fp_rate < 0.10) else "\n❌ FAIL")
