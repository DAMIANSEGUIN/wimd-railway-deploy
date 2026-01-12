"""
Deterministic gate rules.
Each gate is a pure function that returns (passed: bool, details: dict).

Governor is not the governed.
These rules cannot be overridden by LLM output.
"""

import os
from typing import Dict, List, Tuple, Any
import jsonschema


def schema_gate(intent_draft: Dict[str, Any], schema: Dict[str, Any]) -> Tuple[bool, Dict[str, Any]]:
    """
    Validate IntentDraft against JSON schema.

    Returns:
        (passed, details) where details contains validation errors if failed
    """
    try:
        jsonschema.validate(instance=intent_draft, schema=schema)
        return True, {"message": "Schema validation passed"}
    except jsonschema.ValidationError as e:
        return False, {
            "message": "Schema validation failed",
            "error": str(e.message),
            "path": list(e.absolute_path) if e.absolute_path else [],
            "schema_path": list(e.absolute_schema_path) if e.absolute_schema_path else []
        }
    except jsonschema.SchemaError as e:
        return False, {
            "message": "Invalid schema definition",
            "error": str(e)
        }


def jurisdiction_gate(
    intent_draft: Dict[str, Any],
    config: Dict[str, Any]
) -> Tuple[bool, Dict[str, Any]]:
    """
    Check external jurisdiction proof from environment variable ONLY.

    Never accept proof from IntentDraft JSON itself.
    Governor is not the governed.

    Returns:
        (passed, details) with mode set based on proof validity
    """
    task_type = intent_draft.get("task_type", "")
    requires_enforcement = task_type in config["require_external_enforcement_for"]

    # Get proof from environment ONLY
    env_var_name = config["environment_variables"]["jurisdiction_proof"]
    proof_token = os.environ.get(env_var_name, "")

    expected_prefix = config["jurisdiction_proof_prefix"]

    details = {
        "task_type": task_type,
        "requires_enforcement": requires_enforcement,
        "proof_source": "environment_variable",
        "proof_present": bool(proof_token)
    }

    if not requires_enforcement:
        # Task doesn't require external enforcement
        return True, {
            **details,
            "message": "Task type does not require external enforcement",
            "mode": "REAL_CREWAI_ENFORCED"
        }

    if not proof_token:
        # Required enforcement but no proof
        return False, {
            **details,
            "message": f"External enforcement required but {env_var_name} not set",
            "mode": config["mode_when_no_proof"]
        }

    if not proof_token.startswith(expected_prefix):
        # Proof present but invalid format
        return False, {
            **details,
            "message": f"Proof token must start with {expected_prefix}",
            "mode": config["mode_when_no_proof"],
            "proof_preview": proof_token[:20] + "..." if len(proof_token) > 20 else proof_token
        }

    # Valid external proof
    return True, {
        **details,
        "message": "Valid external jurisdiction proof",
        "mode": "REAL_CREWAI_ENFORCED",
        "jurisdiction_proof": proof_token
    }


def scope_gate(
    intent_draft: Dict[str, Any],
    config: Dict[str, Any]
) -> Tuple[bool, Dict[str, Any]]:
    """
    Validate scope_in is not empty and doesn't exceed max items.

    Returns:
        (passed, details)
    """
    scope_in = intent_draft.get("scope_in", [])
    max_items = config["max_scope_items"]

    if not scope_in:
        return False, {
            "message": "scope_in cannot be empty",
            "scope_in_length": 0
        }

    if len(scope_in) > max_items:
        return False, {
            "message": f"scope_in exceeds maximum of {max_items} items",
            "scope_in_length": len(scope_in),
            "max_scope_items": max_items
        }

    return True, {
        "message": "Scope validation passed",
        "scope_in_length": len(scope_in),
        "max_scope_items": max_items
    }


def no_assumption_gate(intent_draft: Dict[str, Any]) -> Tuple[bool, Dict[str, Any]]:
    """
    Fail if assumptions list is non-empty.

    Deterministic execution requires zero assumptions.

    Returns:
        (passed, details)
    """
    assumptions = intent_draft.get("assumptions", [])

    if assumptions:
        return False, {
            "message": "Deterministic execution requires zero assumptions",
            "assumptions_count": len(assumptions),
            "assumptions": assumptions
        }

    return True, {
        "message": "No assumptions present",
        "assumptions_count": 0
    }


def prompt_retrieval_gate(
    intent_draft: Dict[str, Any],
    prompt_index: Dict[str, Any]
) -> Tuple[bool, Dict[str, Any]]:
    """
    Deterministically select prompt based on task_type and tag overlap.

    Scoring:
    - Exact task_type match: required
    - Tag overlap: simple count of matching keywords in intent_statement + scope_in + constraints

    Returns:
        (passed, details) with selected_prompt_id if passed
    """
    task_type = intent_draft.get("task_type", "")
    intent_statement = intent_draft.get("intent_statement", "").lower()
    scope_in = " ".join(intent_draft.get("scope_in", [])).lower()
    constraints = " ".join(intent_draft.get("constraints", [])).lower()

    search_text = f"{intent_statement} {scope_in} {constraints}"

    # Filter prompts by exact task_type match
    eligible_prompts = [
        p for p in prompt_index["prompts"]
        if p["task_type"] == task_type
    ]

    if not eligible_prompts:
        return False, {
            "message": f"No prompts found for task_type: {task_type}",
            "task_type": task_type,
            "top3_prompts": []
        }

    # Score by tag overlap
    scored_prompts = []
    for prompt in eligible_prompts:
        tags = prompt.get("tags", [])
        score = sum(1 for tag in tags if tag.lower() in search_text)
        scored_prompts.append((score, prompt))

    # Sort by score descending
    scored_prompts.sort(key=lambda x: x[0], reverse=True)

    best_score, best_prompt = scored_prompts[0]

    if best_score == 0:
        # No tag overlap at all
        top3 = [
            {"prompt_id": p["prompt_id"], "score": s, "tags": p.get("tags", [])}
            for s, p in scored_prompts[:3]
        ]
        return False, {
            "message": "No prompt has score > 0",
            "task_type": task_type,
            "top3_prompts": top3
        }

    # Success - return selected prompt
    return True, {
        "message": "Prompt selected deterministically",
        "selected_prompt_id": best_prompt["prompt_id"],
        "score": best_score,
        "tags_matched": [
            tag for tag in best_prompt.get("tags", [])
            if tag.lower() in search_text
        ]
    }
