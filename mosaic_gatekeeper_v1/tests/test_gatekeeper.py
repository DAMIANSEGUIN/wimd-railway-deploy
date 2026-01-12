"""
Test suite for Mosaic Gatekeeper v1.

Proves fail-closed behavior: if anything is missing or invalid, HALT.

Run with: pytest test_gatekeeper.py -v
"""

import json
import os
import sys
from pathlib import Path
import pytest

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / "gatekeeper"))

from gatekeeper import run_gatekeeper


@pytest.fixture
def temp_intent_file(tmp_path):
    """Create temporary intent file for testing."""
    def _create_intent(data):
        intent_file = tmp_path / "intent.json"
        with open(intent_file, 'w') as f:
            json.dump(data, f)
        return str(intent_file)
    return _create_intent


@pytest.fixture
def valid_intent_draft():
    """Valid intent draft that passes all gates (with proof)."""
    return {
        "task_type": "mosaic_governance",
        "intent_statement": "Implement deterministic gates for intent validation",
        "scope_in": [
            "Schema validation",
            "Jurisdiction checking",
            "Scope verification"
        ],
        "scope_out": [
            "LLM-based validation",
            "Self-certification"
        ],
        "assumptions": [],
        "constraints": [
            "Must be deterministic",
            "Must fail closed"
        ],
        "success_criteria": [
            "All gates pass",
            "External proof verified"
        ]
    }


def test_halt_when_schema_invalid(temp_intent_file):
    """HALT when IntentDraft doesn't match schema."""
    invalid_intent = {
        "task_type": "mosaic_governance",
        # Missing required fields
    }

    intent_file = temp_intent_file(invalid_intent)
    result = run_gatekeeper(intent_file)

    assert result["status"] == "HALT"
    assert "SchemaGate" in result["failed_gates"]
    assert "schema_errors" in result


def test_halt_when_no_jurisdiction_proof_for_mosaic_governance(temp_intent_file, valid_intent_draft):
    """HALT when external enforcement required but no proof provided."""
    # Ensure environment variable is NOT set
    env_var = "GATEKEEPER_JURISDICTION_PROOF"
    if env_var in os.environ:
        del os.environ[env_var]

    intent_file = temp_intent_file(valid_intent_draft)
    result = run_gatekeeper(intent_file)

    assert result["status"] == "HALT"
    assert "JurisdictionGate" in result["failed_gates"]
    assert result["mode"] == "DESIGN_ONLY_NO_ENFORCEMENT"
    assert result["jurisdiction_proof"] == "NO_EXTERNAL_ENFORCEMENT"


def test_proceed_when_jurisdiction_proof_valid_and_no_assumptions_and_scope_ok(
    temp_intent_file,
    valid_intent_draft
):
    """PROCEED when all gates pass with valid external proof."""
    # Set valid jurisdiction proof
    os.environ["GATEKEEPER_JURISDICTION_PROOF"] = "CREWAI_RUN:test_run_12345"

    intent_file = temp_intent_file(valid_intent_draft)
    result = run_gatekeeper(intent_file)

    assert result["status"] == "PROCEED"
    assert result["mode"] == "REAL_CREWAI_ENFORCED"
    assert len(result["gates_passed"]) == 5
    assert "SchemaGate" in result["gates_passed"]
    assert "JurisdictionGate" in result["gates_passed"]
    assert "ScopeGate" in result["gates_passed"]
    assert "NoAssumptionGate" in result["gates_passed"]
    assert "PromptRetrievalGate" in result["gates_passed"]
    assert result["selected_prompt_id"] == "INTENT_MATCH_V1"
    assert result["jurisdiction_proof"] == "CREWAI_RUN:test_run_12345"

    # Cleanup
    del os.environ["GATEKEEPER_JURISDICTION_PROOF"]


def test_halt_when_assumptions_present(temp_intent_file, valid_intent_draft):
    """HALT when assumptions list is non-empty."""
    # Set valid proof so we get past JurisdictionGate
    os.environ["GATEKEEPER_JURISDICTION_PROOF"] = "CREWAI_RUN:test_run_12345"

    # Add assumptions
    intent_with_assumptions = valid_intent_draft.copy()
    intent_with_assumptions["assumptions"] = [
        "User has API access",
        "Database is populated"
    ]

    intent_file = temp_intent_file(intent_with_assumptions)
    result = run_gatekeeper(intent_file)

    assert result["status"] == "HALT"
    assert "NoAssumptionGate" in result["failed_gates"]
    assert "assumption_details" in result
    assert result["assumption_details"]["assumptions_count"] == 2

    # Cleanup
    del os.environ["GATEKEEPER_JURISDICTION_PROOF"]


def test_halt_when_scope_too_large(temp_intent_file, valid_intent_draft):
    """HALT when scope_in exceeds max_scope_items."""
    # Set valid proof
    os.environ["GATEKEEPER_JURISDICTION_PROOF"] = "CREWAI_RUN:test_run_12345"

    # Create scope with > 12 items
    large_scope = valid_intent_draft.copy()
    large_scope["scope_in"] = [f"Item {i}" for i in range(15)]

    intent_file = temp_intent_file(large_scope)
    result = run_gatekeeper(intent_file)

    assert result["status"] == "HALT"
    assert "ScopeGate" in result["failed_gates"]
    assert result["scope_details"]["scope_in_length"] == 15

    # Cleanup
    del os.environ["GATEKEEPER_JURISDICTION_PROOF"]


def test_halt_when_scope_empty(temp_intent_file, valid_intent_draft):
    """HALT when scope_in is empty."""
    # Set valid proof
    os.environ["GATEKEEPER_JURISDICTION_PROOF"] = "CREWAI_RUN:test_run_12345"

    # Empty scope
    empty_scope = valid_intent_draft.copy()
    empty_scope["scope_in"] = []

    intent_file = temp_intent_file(empty_scope)
    result = run_gatekeeper(intent_file)

    assert result["status"] == "HALT"
    assert "ScopeGate" in result["failed_gates"]

    # Cleanup
    del os.environ["GATEKEEPER_JURISDICTION_PROOF"]


def test_halt_when_prompt_retrieval_fails(temp_intent_file, valid_intent_draft):
    """HALT when no matching prompt found."""
    # Set valid proof
    os.environ["GATEKEEPER_JURISDICTION_PROOF"] = "CREWAI_RUN:test_run_12345"

    # Use task_type that doesn't exist in prompt_index
    unknown_task = valid_intent_draft.copy()
    unknown_task["task_type"] = "unknown_task_type_xyz"

    intent_file = temp_intent_file(unknown_task)
    result = run_gatekeeper(intent_file)

    assert result["status"] == "HALT"
    assert "PromptRetrievalGate" in result["failed_gates"]
    assert "prompt_retrieval_details" in result

    # Cleanup
    del os.environ["GATEKEEPER_JURISDICTION_PROOF"]


def test_halt_when_jurisdiction_proof_invalid_prefix(temp_intent_file, valid_intent_draft):
    """HALT when proof token doesn't start with required prefix."""
    # Set proof with wrong prefix
    os.environ["GATEKEEPER_JURISDICTION_PROOF"] = "WRONG_PREFIX:test_run_12345"

    intent_file = temp_intent_file(valid_intent_draft)
    result = run_gatekeeper(intent_file)

    assert result["status"] == "HALT"
    assert "JurisdictionGate" in result["failed_gates"]
    assert result["mode"] == "DESIGN_ONLY_NO_ENFORCEMENT"

    # Cleanup
    del os.environ["GATEKEEPER_JURISDICTION_PROOF"]


def test_proceed_for_non_enforcement_task_type(temp_intent_file):
    """PROCEED for task types that don't require external enforcement."""
    # Task type not in require_external_enforcement_for list
    non_enforcement_intent = {
        "task_type": "data_analysis",  # Not in enforcement list
        "intent_statement": "Analyze user data for insights",
        "scope_in": ["User activity logs", "Session data"],
        "scope_out": ["PII", "Financial data"],
        "assumptions": [],
        "constraints": ["GDPR compliant", "Read-only access"],
        "success_criteria": ["Report generated", "No errors"]
    }

    # No proof needed
    if "GATEKEEPER_JURISDICTION_PROOF" in os.environ:
        del os.environ["GATEKEEPER_JURISDICTION_PROOF"]

    intent_file = temp_intent_file(non_enforcement_intent)
    result = run_gatekeeper(intent_file)

    # Should fail at PromptRetrievalGate since no prompt for data_analysis
    assert result["status"] == "HALT"
    assert "PromptRetrievalGate" in result["failed_gates"]
    # But JurisdictionGate should have passed
    assert "JurisdictionGate" not in result["failed_gates"]


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
