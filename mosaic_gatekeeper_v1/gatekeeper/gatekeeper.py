#!/usr/bin/env python3
"""
Mosaic Gatekeeper v1 - Deterministic External Enforcement

Usage:
    python gatekeeper.py path/to/intent.json

Returns single JSON object to stdout with status: HALT or PROCEED.

Governor is not the governed.
LLM output is never authoritative about compliance.
Only deterministic code decides.
"""

import sys
import json
import os
from pathlib import Path
from typing import Dict, Any

from rules import (
    schema_gate,
    jurisdiction_gate,
    scope_gate,
    no_assumption_gate,
    prompt_retrieval_gate
)


def load_json(file_path: str) -> Dict[str, Any]:
    """Load and parse JSON file."""
    with open(file_path, 'r') as f:
        return json.load(f)


def run_gatekeeper(intent_draft_path: str) -> Dict[str, Any]:
    """
    Run all gates and return deterministic result.

    Fail-closed: If anything is missing or invalid, HALT.

    Returns:
        JSON object with status: HALT or PROCEED
    """
    # Get gatekeeper directory
    gatekeeper_dir = Path(__file__).parent

    # Load configuration
    config = load_json(gatekeeper_dir / "config.json")
    intent_schema = load_json(gatekeeper_dir / "intent_schema.json")
    prompt_index = load_json(gatekeeper_dir / "prompt_index.json")

    # Load intent draft
    try:
        intent_draft = load_json(intent_draft_path)
    except Exception as e:
        return {
            "status": "HALT",
            "mode": "DESIGN_ONLY_NO_ENFORCEMENT",
            "failed_gates": ["InputValidation"],
            "error": f"Failed to load intent draft: {str(e)}",
            "jurisdiction_proof": "NO_EXTERNAL_ENFORCEMENT"
        }

    # Initialize result
    result = {
        "status": "PROCEED",
        "mode": "REAL_CREWAI_ENFORCED",
        "failed_gates": [],
        "gates_passed": [],
        "jurisdiction_proof": os.environ.get(
            config["environment_variables"]["jurisdiction_proof"],
            "NO_EXTERNAL_ENFORCEMENT"
        )
    }

    # Gate 1: SchemaGate
    passed, details = schema_gate(intent_draft, intent_schema)
    if not passed:
        return {
            "status": "HALT",
            "mode": "DESIGN_ONLY_NO_ENFORCEMENT",
            "failed_gates": ["SchemaGate"],
            "schema_errors": details,
            "jurisdiction_proof": result["jurisdiction_proof"]
        }
    result["gates_passed"].append("SchemaGate")

    # Gate 2: JurisdictionGate
    passed, details = jurisdiction_gate(intent_draft, config)
    if not passed:
        return {
            "status": "HALT",
            "mode": details["mode"],
            "failed_gates": ["JurisdictionGate"],
            "jurisdiction_details": details,
            "jurisdiction_proof": result["jurisdiction_proof"]
        }
    result["gates_passed"].append("JurisdictionGate")
    result["mode"] = details["mode"]
    if "jurisdiction_proof" in details:
        result["jurisdiction_proof"] = details["jurisdiction_proof"]

    # Gate 3: ScopeGate
    passed, details = scope_gate(intent_draft, config)
    if not passed:
        return {
            "status": "HALT",
            "mode": result["mode"],
            "failed_gates": ["ScopeGate"],
            "scope_details": details,
            "jurisdiction_proof": result["jurisdiction_proof"]
        }
    result["gates_passed"].append("ScopeGate")

    # Gate 4: NoAssumptionGate
    passed, details = no_assumption_gate(intent_draft)
    if not passed:
        return {
            "status": "HALT",
            "mode": result["mode"],
            "failed_gates": ["NoAssumptionGate"],
            "assumption_details": details,
            "jurisdiction_proof": result["jurisdiction_proof"]
        }
    result["gates_passed"].append("NoAssumptionGate")

    # Gate 5: PromptRetrievalGate
    passed, details = prompt_retrieval_gate(intent_draft, prompt_index)
    if not passed:
        return {
            "status": "HALT",
            "mode": result["mode"],
            "failed_gates": ["PromptRetrievalGate"],
            "prompt_retrieval_details": details,
            "jurisdiction_proof": result["jurisdiction_proof"]
        }
    result["gates_passed"].append("PromptRetrievalGate")
    result["selected_prompt_id"] = details["selected_prompt_id"]

    # All gates passed
    return result


def main():
    """CLI entry point."""
    if len(sys.argv) != 2:
        print(json.dumps({
            "status": "HALT",
            "mode": "DESIGN_ONLY_NO_ENFORCEMENT",
            "failed_gates": ["Usage"],
            "error": "Usage: python gatekeeper.py path/to/intent.json",
            "jurisdiction_proof": "NO_EXTERNAL_ENFORCEMENT"
        }, indent=2))
        sys.exit(1)

    intent_draft_path = sys.argv[1]

    if not os.path.exists(intent_draft_path):
        print(json.dumps({
            "status": "HALT",
            "mode": "DESIGN_ONLY_NO_ENFORCEMENT",
            "failed_gates": ["FileNotFound"],
            "error": f"Intent draft file not found: {intent_draft_path}",
            "jurisdiction_proof": "NO_EXTERNAL_ENFORCEMENT"
        }, indent=2))
        sys.exit(1)

    result = run_gatekeeper(intent_draft_path)
    print(json.dumps(result, indent=2))

    # Exit with code 1 if HALT, 0 if PROCEED
    sys.exit(0 if result["status"] == "PROCEED" else 1)


if __name__ == "__main__":
    main()
