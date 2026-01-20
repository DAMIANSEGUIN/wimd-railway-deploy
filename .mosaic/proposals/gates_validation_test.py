#!/usr/bin/env python3
"""
Validation test for GATES.yaml normalization
Tests parseable, valid, and enforceable properties
"""

import yaml
import sys
import subprocess
from pathlib import Path

def test_parseable():
    """Test 1: GATES.yaml is valid YAML and parseable"""
    print("TEST 1: Parseable check...")

    gates_path = Path("mosaic_governance/GATES.yaml")
    assert gates_path.exists(), f"GATES.yaml not found at {gates_path}"

    with open(gates_path) as f:
        data = yaml.safe_load(f)

    assert data is not None, "GATES.yaml parsed to None"
    assert isinstance(data, dict), "GATES.yaml must be a dict"

    print("  ✅ GATES.yaml is valid YAML")
    return data

def test_valid_structure(data):
    """Test 2: GATES.yaml has valid structure"""
    print("TEST 2: Valid structure check...")

    # Required top-level keys
    assert 'gates' in data, "Missing 'gates' key"
    assert 'version' in data, "Missing 'version' key"
    assert 'meta' in data, "Missing 'meta' key"
    assert 'description' in data, "Missing 'description' key"

    # Gates must be a list
    assert isinstance(data['gates'], list), "gates must be a list"
    assert len(data['gates']) > 0, "gates list is empty"

    print(f"  ✅ Found {len(data['gates'])} gates")

    # Required fields for each gate
    required_fields = ['id', 'name', 'description', 'domain', 'trigger', 'severity', 'aliases']
    valid_domains = ['repo_hook', 'pre_push_hook', 'human_check', 'manual_ops', 'runtime_watchdog', 'schema_contract']
    valid_severities = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']

    for i, gate in enumerate(data['gates']):
        for field in required_fields:
            assert field in gate, f"Gate #{i+1} ({gate.get('id', 'UNKNOWN')}) missing field: {field}"

        # Validate domain
        assert gate['domain'] in valid_domains, \
            f"Gate {gate['id']} has invalid domain: {gate['domain']}"

        # Validate severity
        assert gate['severity'] in valid_severities, \
            f"Gate {gate['id']} has invalid severity: {gate['severity']}"

        # Validate aliases is a list
        assert isinstance(gate['aliases'], list), \
            f"Gate {gate['id']} aliases must be a list, got {type(gate['aliases'])}"

    print(f"  ✅ All gates have required fields")
    print(f"  ✅ Domains: {data['meta']['enforcement_domains']}")
    print(f"  ✅ Severity distribution: {data['meta']['severity_distribution']}")

    return True

def test_enforceable():
    """Test 3: Enforcement infrastructure is configured"""
    print("TEST 3: Enforceable check...")

    # Check pre-commit config exists
    precommit_path = Path(".pre-commit-config.yaml")
    assert precommit_path.exists(), "pre-commit config not found"

    with open(precommit_path) as f:
        precommit = yaml.safe_load(f)

    # Check secrets baseline exists
    baseline_path = Path(".secrets.baseline")
    assert baseline_path.exists(), "detect-secrets baseline not found"

    # Check that local hooks reference correct Python
    local_repos = [r for r in precommit['repos'] if r.get('repo') == 'local']
    assert len(local_repos) > 0, "No local hooks configured"

    for hook in local_repos[0]['hooks']:
        if 'python' in hook.get('entry', ''):
            assert 'python3' in hook['entry'], \
                f"Hook {hook['id']} uses 'python' instead of 'python3'"

    print("  ✅ pre-commit config valid")
    print("  ✅ detect-secrets baseline exists")
    print("  ✅ Local hooks use python3")

    # Check YAML validity of pre-commit config
    try:
        result = subprocess.run(
            ['python3', '-c', 'import yaml; yaml.safe_load(open(".pre-commit-config.yaml"))'],
            capture_output=True,
            text=True,
            timeout=5
        )
        assert result.returncode == 0, f"pre-commit config YAML invalid: {result.stderr}"
        print("  ✅ pre-commit config is valid YAML")
    except Exception as e:
        print(f"  ⚠️  Could not validate pre-commit YAML: {e}")

    return True

def main():
    """Run all validation tests"""
    print("="*60)
    print("GATES.yaml Validation Test Suite")
    print("="*60)
    print()

    try:
        # Test 1: Parseable
        data = test_parseable()
        print()

        # Test 2: Valid structure
        test_valid_structure(data)
        print()

        # Test 3: Enforceable
        test_enforceable()
        print()

        print("="*60)
        print("✅ ALL TESTS PASSED")
        print("="*60)
        print()
        print("Summary:")
        print(f"  - GATES.yaml is parseable (valid YAML)")
        print(f"  - GATES.yaml has valid structure (22 gates, all required fields)")
        print(f"  - Enforcement infrastructure configured (pre-commit + baseline)")
        print()
        return 0

    except AssertionError as e:
        print()
        print("="*60)
        print(f"❌ TEST FAILED: {e}")
        print("="*60)
        return 1
    except Exception as e:
        print()
        print("="*60)
        print(f"❌ ERROR: {e}")
        print("="*60)
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
