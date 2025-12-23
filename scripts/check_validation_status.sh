#!/bin/bash
# scripts/check_validation_status.sh - Deterministic gate: Block push without Gemini ALLOW

set -euo pipefail

REPO_ROOT="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
cd "$REPO_ROOT"

echo "🔒 Validation Gate: Checking for Gemini ALLOW verdict..."

# Find most recent HANDOFF_TO_GEMINI file
HANDOFF_FILE=$(ls -t HANDOFF_TO_GEMINI_*.md 2>/dev/null | head -1 || echo "")

if [ -z "$HANDOFF_FILE" ]; then
    echo "✅ SKIP: No handoff file found (no validation required)"
    exit 0
fi

echo "📄 Found handoff: $HANDOFF_FILE"

# Check for Gemini's verdict in the file or a companion validation file
VALIDATION_FILE="${HANDOFF_FILE%.md}_VALIDATION.md"

if [ -f "$VALIDATION_FILE" ]; then
    # Check if verdict is ALLOW
    if grep -q "Verdict: ALLOW" "$VALIDATION_FILE" 2>/dev/null; then
        echo "✅ ALLOW: Gemini has approved (found in $VALIDATION_FILE)"
        exit 0
    elif grep -q "Verdict: CLARIFY_REQUIRED" "$VALIDATION_FILE" 2>/dev/null; then
        echo "🛑 REJECT: Gemini requires clarification"
        echo "   Fix issues in handoff and request re-review"
        exit 1
    elif grep -q "Verdict: REJECT" "$VALIDATION_FILE" 2>/dev/null; then
        echo "🛑 REJECT: Gemini has rejected implementation"
        echo "   Address violations before pushing"
        exit 1
    else
        echo "⚠️  CLARIFY_REQUIRED: Validation file exists but no clear verdict"
        echo "   File: $VALIDATION_FILE"
        exit 1
    fi
fi

# If no validation file, check handoff file itself for verdict
if grep -q "^Verdict: ALLOW" "$HANDOFF_FILE" 2>/dev/null; then
    echo "✅ ALLOW: Gemini has approved (found in $HANDOFF_FILE)"
    exit 0
fi

# No validation found
echo "🛑 REJECT: No Gemini validation found for $HANDOFF_FILE"
echo ""
echo "Required action:"
echo "1. Share $HANDOFF_FILE with Gemini"
echo "2. Wait for Gemini's validation"
echo "3. Gemini creates ${VALIDATION_FILE}"
echo "4. Gemini adds 'Verdict: ALLOW' to validation file"
echo "5. Then you can push"
echo ""
echo "This is a HARD GATE. Cannot proceed without validation."
exit 1
