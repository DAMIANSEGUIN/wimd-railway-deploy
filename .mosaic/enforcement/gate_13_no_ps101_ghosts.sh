#!/bin/bash
# Gate 13: PS101 Ghost Code Detection
# Blocks deployment if old 10-step architecture code is present
# Exit 0 = pass, Exit 1 = fail (blocks deployment)

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$REPO_ROOT"

echo "🔍 GATE 13: PS101 GHOST CODE DETECTION"
echo "============================================================"
echo ""

VIOLATIONS=0

# CRITICAL: Must NOT have old PS101State methods
DANGEROUS_METHODS=(
    "getActiveExperiment"
    "getCurrentStep"
    "goToStep"
    "prevPrompt.*currentStep"
    "nextPrompt.*currentStep"
    "step\.prompts\.length"
)

for method in "${DANGEROUS_METHODS[@]}"; do
    if grep -q "$method" frontend/index.html 2>/dev/null; then
        echo "❌ GHOST CODE: Found old method pattern '$method'"
        grep -n "$method" frontend/index.html | head -3
        ((VIOLATIONS++))
    fi
done

# Check for duplicate PS101State definitions
PS101_STATE_COUNT=$(grep -c "const PS101State = {" frontend/index.html 2>/dev/null || echo "0")
if [ "$PS101_STATE_COUNT" -gt 1 ]; then
    echo "❌ CRITICAL: Multiple PS101State definitions found ($PS101_STATE_COUNT)"
    echo "   This will cause unpredictable behavior"
    grep -n "const PS101State = {" frontend/index.html
    ((VIOLATIONS++))
fi

# Check for references to step.prompts (old nested structure)
STEP_PROMPTS_COUNT=$(grep -c "step\.prompts" frontend/index.html 2>/dev/null || echo "0")
if [ "$STEP_PROMPTS_COUNT" -gt 0 ]; then
    echo "❌ OLD ARCHITECTURE: Found $STEP_PROMPTS_COUNT references to 'step.prompts'"
    echo "   New architecture has flat prompt array, not nested structure"
    ((VIOLATIONS++))
fi

# Check for experiment-related code (steps 6-9 in old architecture)
if grep -q "experiment.*obstacles\|experiment.*actions" frontend/index.html 2>/dev/null; then
    echo "❌ OLD FEATURES: Found experiment components (Step 6-9 from old architecture)"
    ((VIOLATIONS++))
fi

echo ""
echo "============================================================"
if [ $VIOLATIONS -eq 0 ]; then
    echo "✅ Gate 13 PASSED: No ghost code detected"
    echo ""
    exit 0
else
    echo "❌ Gate 13 FAILED: $VIOLATIONS ghost code violations"
    echo ""
    echo "REQUIRED ACTION:"
    echo "  1. Remove all old PS101 code from frontend/index.html"
    echo "  2. Keep only PS101 simple code (starts at line ~3495)"
    echo "  3. Old code includes:"
    echo "     - getActiveExperiment()"
    echo "     - getCurrentStep()"
    echo "     - step.prompts.length"
    echo "     - experiment components"
    echo ""
    echo "DANGER: Ghost code can cause regression if triggered"
    echo ""
    exit 1
fi
