# Mosaic Gatekeeper v1 - Deterministic External Enforcement

**Governor is not the governed.**

LLM output is never authoritative about compliance. Only deterministic code decides.

## Purpose

Prevent "governance theater" by implementing fail-closed enforcement gates that cannot be overridden by LLM self-certification.

## Key Principles

1. **External Proof Required**: Jurisdiction proof must come from environment variable, never from LLM output
2. **Fail-Closed**: If anything is missing or invalid, HALT
3. **Deterministic**: No LLM calls at runtime, pure logic only
4. **Non-Bypassable**: Governor is not the governed - enforcement is external

## Setup

### 1. Create Virtual Environment

```bash
cd mosaic_gatekeeper_v1
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install jsonschema pytest
```

### 3. Verify Installation

```bash
python gatekeeper/gatekeeper.py --help
```

## Usage

### Basic Command

```bash
python gatekeeper/gatekeeper.py path/to/intent.json
```

### With External Enforcement Proof

For tasks requiring external enforcement (mosaic_governance, resume_rewrite, job_search):

```bash
export GATEKEEPER_JURISDICTION_PROOF="CREWAI_RUN:unique_run_id_12345"
python gatekeeper/gatekeeper.py examples/intent.json
```

### Output

Gatekeeper prints single JSON object to stdout:

**PROCEED** (all gates passed):
```json
{
  "status": "PROCEED",
  "mode": "REAL_CREWAI_ENFORCED",
  "gates_passed": [
    "SchemaGate",
    "JurisdictionGate",
    "ScopeGate",
    "NoAssumptionGate",
    "PromptRetrievalGate"
  ],
  "selected_prompt_id": "INTENT_MATCH_V1",
  "jurisdiction_proof": "CREWAI_RUN:unique_run_id_12345"
}
```

**HALT** (gate failed):
```json
{
  "status": "HALT",
  "mode": "DESIGN_ONLY_NO_ENFORCEMENT",
  "failed_gates": ["JurisdictionGate"],
  "jurisdiction_details": {
    "message": "External enforcement required but GATEKEEPER_JURISDICTION_PROOF not set",
    "task_type": "mosaic_governance",
    "requires_enforcement": true
  },
  "jurisdiction_proof": "NO_EXTERNAL_ENFORCEMENT"
}
```

## Gates

### 1. SchemaGate
- Validates IntentDraft against `intent_schema.json`
- Uses JSON Schema draft 2020-12
- HALT on validation errors

### 2. JurisdictionGate
- Checks for external enforcement proof from `GATEKEEPER_JURISDICTION_PROOF` environment variable
- **Never accepts proof from IntentDraft JSON**
- Required for: mosaic_governance, resume_rewrite, job_search
- Proof must start with: `CREWAI_RUN:`
- HALT if required but missing or invalid

### 3. ScopeGate
- Validates scope_in is not empty
- Validates scope_in doesn't exceed 12 items
- HALT on violation

### 4. NoAssumptionGate
- Fails if assumptions list is non-empty
- Deterministic execution requires zero assumptions
- HALT if assumptions present

### 5. PromptRetrievalGate
- Deterministically selects prompt from `prompt_index.json`
- Requires exact task_type match
- Scores by tag overlap with intent text
- HALT if no prompt with score > 0

## Testing

### Run All Tests

```bash
pytest tests/test_gatekeeper.py -v
```

### Run Specific Test

```bash
pytest tests/test_gatekeeper.py::test_halt_when_no_jurisdiction_proof_for_mosaic_governance -v
```

### Test Coverage

Tests prove fail-closed behavior:
- ✅ `test_halt_when_schema_invalid`
- ✅ `test_halt_when_no_jurisdiction_proof_for_mosaic_governance`
- ✅ `test_proceed_when_jurisdiction_proof_valid_and_no_assumptions_and_scope_ok`
- ✅ `test_halt_when_assumptions_present`
- ✅ `test_halt_when_scope_too_large`
- ✅ `test_halt_when_scope_empty`
- ✅ `test_halt_when_prompt_retrieval_fails`
- ✅ `test_halt_when_jurisdiction_proof_invalid_prefix`

## Example IntentDraft

Create `example_intent.json`:

```json
{
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
```

Test it:

```bash
# Without proof - should HALT
python gatekeeper/gatekeeper.py example_intent.json

# With proof - should PROCEED
export GATEKEEPER_JURISDICTION_PROOF="CREWAI_RUN:test_12345"
python gatekeeper/gatekeeper.py example_intent.json
```

## Configuration

Edit `gatekeeper/config.json`:

```json
{
  "confidence_min_to_proceed": 0.85,
  "max_scope_items": 12,
  "require_external_enforcement_for": [
    "mosaic_governance",
    "resume_rewrite",
    "job_search"
  ],
  "jurisdiction_proof_prefix": "CREWAI_RUN:",
  "mode_when_no_proof": "DESIGN_ONLY_NO_ENFORCEMENT"
}
```

## Exit Codes

- `0`: PROCEED (all gates passed)
- `1`: HALT (one or more gates failed)

## Integration Example

```bash
#!/bin/bash
# run_governed_workflow.sh

export GATEKEEPER_JURISDICTION_PROOF="CREWAI_RUN:$(uuidgen)"

if python gatekeeper/gatekeeper.py intent.json > gate_result.json; then
    echo "✅ Gates passed - proceeding with execution"
    PROMPT_ID=$(jq -r '.selected_prompt_id' gate_result.json)
    # Execute workflow with selected prompt
else
    echo "❌ Gates failed - cannot proceed"
    jq '.' gate_result.json
    exit 1
fi
```

## Architecture

```
mosaic_gatekeeper_v1/
├── gatekeeper/
│   ├── __init__.py              # Package init
│   ├── config.json              # Gate configuration
│   ├── intent_schema.json       # IntentDraft schema (JSON Schema 2020-12)
│   ├── artifact_schema.json     # Artifact schema
│   ├── prompt_index.json        # Prompt library
│   ├── gatekeeper.py            # Main orchestrator (CLI)
│   └── rules.py                 # Pure gate functions
├── prompts/
│   └── PROMPT_INTENT_MATCH_V1.txt  # Example prompt
├── tests/
│   └── test_gatekeeper.py       # Pytest test suite
└── README.md                    # This file
```

## Design Decisions

### Why External Proof from Environment?

- **Governor is not governed**: LLM cannot self-certify compliance
- **Tamper-proof**: Environment variable set by external orchestrator (CrewAI)
- **Auditable**: Proof token appears in logs and output

### Why Fail-Closed?

- **Safe default**: If uncertain, don't proceed
- **Explicit success**: All gates must pass explicitly
- **No silent failures**: Every HALT includes reason

### Why Deterministic Prompt Selection?

- **Reproducible**: Same intent always selects same prompt
- **No LLM involved**: Pure scoring logic
- **Transparent**: Scoring algorithm is visible and testable

## Troubleshooting

### "JurisdictionGate failed"

```bash
# Check environment variable is set
echo $GATEKEEPER_JURISDICTION_PROOF

# Should output: CREWAI_RUN:xxx
# If empty, set it:
export GATEKEEPER_JURISDICTION_PROOF="CREWAI_RUN:$(uuidgen)"
```

### "SchemaGate failed"

Validate your intent.json matches the schema. Common issues:
- Missing required fields
- Empty arrays for scope_in or constraints
- Wrong data types

### "PromptRetrievalGate failed"

- Check task_type matches a prompt in `prompt_index.json`
- Ensure intent text contains relevant tags

## Version History

- **v1.0.0** (2026-01-12): Initial release with 5 deterministic gates

## License

Proprietary - Mosaic Platform

---

**Remember: Governor is not the governed.**
