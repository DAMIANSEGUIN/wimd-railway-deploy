#!/bin/bash
# PRE-RESPONSE CHECK: Force agent to verify filesystem before claiming gaps
# Usage: ./pre_response_check.sh "entity_name" [alternative_names...]
# Exit 0 if entity doesn't exist (claim is valid)
# Exit 1 if entity exists (claim is FALSE - agent must check)

set -e

ENTITY="$1"
shift
ALTERNATIVES=("$@")

echo "🔍 PRE-RESPONSE CHECK: Verifying claim about '$ENTITY'"
echo "========================================"

# Get search patterns based on entity name
PATTERNS=""
case "${ENTITY// /_}" in
    master_verifier)
        PATTERNS="verify_all.sh verify.sh"
        ;;
    audit_log)
        PATTERNS="session_log.jsonl audit.log audit.jsonl"
        ;;
    project_identity)
        PATTERNS="project_state.json project_identity.json"
        ;;
    comprehension_gate)
        PATTERNS="gate_1_session_start.py gate_0_comprehension.sh"
        ;;
    completion_protocol)
        PATTERNS="COMPLETION_PROTOCOL.md completion_checklist.md"
        ;;
    receipt_schema)
        PATTERNS="receipt_schema.json"
        ;;
    *)
        # No predefined patterns, use entity name and alternatives
        PATTERNS="$ENTITY ${ALTERNATIVES[*]}"
        ;;
esac

echo "Search patterns: $PATTERNS"
echo ""

FOUND_FILES=()

# Search for each pattern
for pattern in $PATTERNS; do
    echo "Checking for: $pattern"

    # Search in common locations
    while IFS= read -r -d '' file; do
        FOUND_FILES+=("$file")
        echo "  ✓ Found: $file"
    done < <(find . -maxdepth 3 -name "*${pattern}*" -type f -print0 2>/dev/null)
done

echo ""
echo "========================================"

if [ ${#FOUND_FILES[@]} -eq 0 ]; then
    echo "✅ CLAIM VALID: '$ENTITY' not found in filesystem"
    echo "Agent may proceed to claim this is missing/needs creation"
    echo ""
    exit 0
else
    echo "❌ CLAIM BLOCKED: '$ENTITY' EXISTS in filesystem"
    echo ""
    echo "Found ${#FOUND_FILES[@]} file(s):"
    for file in "${FOUND_FILES[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "REQUIRED ACTION:"
    echo "  1. Read the file: cat ${FOUND_FILES[0]}"
    echo "  2. Understand what exists"
    echo "  3. Update response to acknowledge existing implementation"
    echo ""
    echo "DO NOT claim this is missing without checking filesystem first."
    echo ""
    exit 1
fi
