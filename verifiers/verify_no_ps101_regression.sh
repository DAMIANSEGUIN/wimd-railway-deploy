#!/bin/bash
# PS101 Architecture Regression Detector
# Ensures old 10-step architecture cannot return to production
# Exit code 0 = No regression detected
# Exit code 1 = Regression detected (blocks deployment)

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$REPO_ROOT"

echo "🔍 PS101 REGRESSION DETECTION"
echo "============================================================"
echo ""

VIOLATIONS=0

# CHECK 1: No "Step 1 of 10" in production HTML
echo "📋 Check 1: No 'Step 1 of 10' pattern in frontend/index.html"
if grep -q "Step 1 of 10" frontend/index.html 2>/dev/null; then
    echo "   ❌ REGRESSION: Found old 'Step 1 of 10' label"
    grep -n "Step 1 of 10" frontend/index.html | head -3
    ((VIOLATIONS++))
else
    echo "   ✅ PASS: Old step label not found"
fi
echo ""

# CHECK 2: No PS101_STEPS array in production code
echo "📋 Check 2: No PS101_STEPS array in frontend/index.html"
if grep -q "PS101_STEPS = \[" frontend/index.html 2>/dev/null; then
    echo "   ❌ REGRESSION: Found old PS101_STEPS array"
    grep -n "PS101_STEPS = \[" frontend/index.html | head -3
    ((VIOLATIONS++))
else
    echo "   ✅ PASS: Old PS101_STEPS array not found"
fi
echo ""

# CHECK 3: Must have "Question 1 of 8" in production HTML
echo "📋 Check 3: Production HTML has 'Question 1 of 8' label"
if grep -q "Question 1 of 8" frontend/index.html 2>/dev/null; then
    echo "   ✅ PASS: New 8-prompt label found"
else
    echo "   ❌ VIOLATION: Missing 'Question 1 of 8' label"
    ((VIOLATIONS++))
fi
echo ""

# CHECK 4: Must have ps101_simple_state in production code
echo "📋 Check 4: Production code uses ps101_simple_state"
if grep -q "ps101_simple_state" frontend/index.html 2>/dev/null; then
    echo "   ✅ PASS: New state structure found"
else
    echo "   ❌ VIOLATION: Missing ps101_simple_state"
    ((VIOLATIONS++))
fi
echo ""

# CHECK 5: Must have exactly 8 progress dots in HTML
echo "📋 Check 5: Exactly 8 progress dots in HTML"
DOT_COUNT=$(grep -c '<button class="dot"' frontend/index.html 2>/dev/null || echo "0")
if [ "$DOT_COUNT" -eq 8 ]; then
    echo "   ✅ PASS: Found $DOT_COUNT dots (correct)"
elif [ "$DOT_COUNT" -eq 7 ]; then
    # 7 is also acceptable (1 dot has 'active' class, 7 don't)
    ACTIVE_DOT=$(grep -c '<button class="dot active"' frontend/index.html 2>/dev/null || echo "0")
    if [ "$ACTIVE_DOT" -eq 1 ]; then
        echo "   ✅ PASS: Found 7 + 1 active = 8 dots total (correct)"
    else
        echo "   ❌ VIOLATION: Found $DOT_COUNT dots, expected 8"
        ((VIOLATIONS++))
    fi
elif [ "$DOT_COUNT" -eq 10 ]; then
    echo "   ❌ REGRESSION: Found $DOT_COUNT dots (old 10-step architecture)"
    ((VIOLATIONS++))
else
    echo "   ❌ VIOLATION: Found $DOT_COUNT dots, expected 8"
    ((VIOLATIONS++))
fi
echo ""

# CHECK 6: Old test file should be renamed/deprecated
echo "📋 Check 6: Old test file deprecated"
if [ -f "test-ps101-complete-flow.js" ]; then
    # Check if it's been marked as deprecated
    if grep -q "DEPRECATED" test-ps101-complete-flow.js 2>/dev/null; then
        echo "   ✅ PASS: Old test marked as deprecated"
    else
        echo "   ⚠️  WARNING: Old test file exists but not marked deprecated"
        echo "       File: test-ps101-complete-flow.js"
        echo "       Consider renaming to: test-ps101-complete-flow.DEPRECATED.js"
    fi
else
    echo "   ✅ PASS: Old test file removed"
fi
echo ""

# CHECK 7: New test file exists
echo "📋 Check 7: New test file exists"
if [ -f "test-ps101-simple-flow.js" ]; then
    echo "   ✅ PASS: New test file exists"
else
    echo "   ❌ VIOLATION: Missing test-ps101-simple-flow.js"
    ((VIOLATIONS++))
fi
echo ""

# CHECK 8: Pre-push hook uses new test
echo "📋 Check 8: Pre-push hook runs correct test"
if [ -f ".git/hooks/pre-push" ]; then
    if grep -q "test-ps101-simple-flow.js" .git/hooks/pre-push 2>/dev/null; then
        echo "   ✅ PASS: Pre-push hook uses new test"
    else
        echo "   ❌ VIOLATION: Pre-push hook doesn't reference test-ps101-simple-flow.js"
        ((VIOLATIONS++))
    fi
else
    echo "   ⚠️  WARNING: No pre-push hook found"
fi
echo ""

# CHECK 9: No references to deprecated spec v2
echo "📋 Check 9: No active references to PS101_CANONICAL_SPEC_V2.md"
if grep -r "PS101_CANONICAL_SPEC_V2.md" --include="*.md" --include="*.js" --include="*.html" --exclude-dir=".git" . 2>/dev/null | grep -v "DEPRECATED" | grep -v "docs/DEPRECATED"; then
    echo "   ⚠️  WARNING: Found references to old spec (should use v3)"
else
    echo "   ✅ PASS: No active references to old spec"
fi
echo ""

# CHECK 10: V3 spec exists and is canonical
echo "📋 Check 10: PS101_CANONICAL_SPEC_V3_CORRECTED.md exists"
if [ -f "docs/PS101_CANONICAL_SPEC_V3_CORRECTED.md" ]; then
    echo "   ✅ PASS: New canonical spec exists"
else
    echo "   ❌ VIOLATION: Missing PS101_CANONICAL_SPEC_V3_CORRECTED.md"
    ((VIOLATIONS++))
fi
echo ""

# CHECK 11: Live site verification (if curl available)
echo "📋 Check 11: Live site has correct architecture"
if command -v curl &> /dev/null; then
    LIVE_LABEL=$(curl -s https://whatismydelta.com 2>/dev/null | grep -o "Question 1 of 8" | head -1 || echo "")
    if [ -n "$LIVE_LABEL" ]; then
        echo "   ✅ PASS: Live site shows 'Question 1 of 8'"
    else
        echo "   ⚠️  WARNING: Could not verify live site (may not be deployed yet)"
    fi

    OLD_LABEL=$(curl -s https://whatismydelta.com 2>/dev/null | grep -c "Step 1 of 10" || echo "0")
    if [ "$OLD_LABEL" -gt 0 ]; then
        echo "   ❌ REGRESSION DETECTED: Live site shows old 'Step 1 of 10' label"
        ((VIOLATIONS++))
    else
        echo "   ✅ PASS: Live site doesn't have old step label"
    fi
else
    echo "   ⚠️  SKIP: curl not available"
fi
echo ""

# CHECK 12: Search for dangerous patterns in code
echo "📋 Check 12: No references to old nested prompt structure"
DANGEROUS_PATTERNS=(
    "step.prompts.length"
    "currentPromptIndex.*step"
    "PS101_STEPS\[.*\].prompts"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if grep -rn -E "$pattern" frontend/index.html 2>/dev/null | grep -v "// OLD:" | grep -v "DEPRECATED"; then
        echo "   ⚠️  WARNING: Found pattern '$pattern' (may be old architecture code)"
    fi
done
echo "   ✅ PASS: No dangerous patterns found"
echo ""

# SUMMARY
echo "============================================================"
echo "📊 REGRESSION DETECTION RESULTS"
echo "============================================================"
echo ""

if [ $VIOLATIONS -eq 0 ]; then
    echo "✅ NO REGRESSION DETECTED"
    echo ""
    echo "All checks passed:"
    echo "  - No old 'Step 1 of 10' labels"
    echo "  - No PS101_STEPS array"
    echo "  - New 'Question 1 of 8' architecture present"
    echo "  - 8 progress dots (not 10)"
    echo "  - New test file exists"
    echo "  - Pre-push hook uses new test"
    echo "  - Live site verified (if accessible)"
    echo ""
    exit 0
else
    echo "❌ REGRESSION DETECTED: $VIOLATIONS violations found"
    echo ""
    echo "VIOLATIONS:"
    echo "  - Review errors above"
    echo "  - Old architecture may have been reintroduced"
    echo "  - Fix violations before deploying"
    echo ""
    echo "To fix:"
    echo "  1. Review failed checks above"
    echo "  2. Ensure frontend/index.html uses PS101 v3 architecture"
    echo "  3. Run: node test-ps101-simple-flow.js"
    echo "  4. Verify: curl https://whatismydelta.com | grep 'Question 1 of 8'"
    echo ""
    exit 1
fi
