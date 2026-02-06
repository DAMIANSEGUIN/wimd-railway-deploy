#!/bin/bash
# Frontend Smoke Test Script
# Quick validation of critical frontend functionality
# Run before every deployment for fast feedback
# Created: 2026-02-06

set -euo pipefail

echo "🔥 Frontend Smoke Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0
FRONTEND_DIR="frontend"
FRONTEND_URL="${1:-https://whatismydelta.com}"

# Test 1: File Structure
echo "Test 1: File structure..."
if [ -f "$FRONTEND_DIR/index.html" ]; then
  FILE_SIZE=$(wc -c < "$FRONTEND_DIR/index.html" | tr -d ' ')
  echo "  ✅ index.html exists ($FILE_SIZE bytes)"
else
  echo "  ❌ index.html missing"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 2: Critical JavaScript Functions
echo "Test 2: Critical JavaScript functions..."

check_function() {
  local func_name="$1"
  local search_pattern="$2"

  if grep -q "$search_pattern" "$FRONTEND_DIR/index.html"; then
    echo "  ✅ $func_name present"
  else
    echo "  ❌ $func_name missing"
    ERRORS=$((ERRORS + 1))
  fi
}

check_function "PS101State" "const PS101State ="
check_function "PS101_STEPS array" "const PS101_STEPS = \["
check_function "nextPrompt()" "nextPrompt()"
check_function "nextStep()" "nextStep()"
check_function "renderCurrentStep()" "renderCurrentStep()"
check_function "updateProgressIndicator()" "updateProgressIndicator("
echo ""

# Test 3: Critical UI Elements
echo "Test 3: Critical UI elements..."

check_element() {
  local element_name="$1"
  local search_id="$2"

  if grep -q "id=\"$search_id\"" "$FRONTEND_DIR/index.html"; then
    echo "  ✅ $element_name present"
  else
    echo "  ❌ $element_name missing"
    ERRORS=$((ERRORS + 1))
  fi
}

check_element "PS101 welcome screen" "ps101-welcome"
check_element "PS101 flow container" "ps101-flow"
check_element "PS101 completion screen" "ps101-completion"
check_element "Step answer textarea" "step-answer"
check_element "Navigation buttons (next)" "ps101-next"
check_element "Navigation buttons (back)" "ps101-back"
check_element "Auth modal" "authModal"
echo ""

# Test 4: PS101 Step Count Validation
echo "Test 4: PS101 step count validation..."
STEP_COUNT=$(grep -o "step: [0-9]\+," "$FRONTEND_DIR/index.html" | wc -l | tr -d ' ')
if [ "$STEP_COUNT" -eq 10 ]; then
  echo "  ✅ Correct step count: 10 steps"
else
  echo "  ❌ Incorrect step count: found $STEP_COUNT (expected 10)"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 5: Debug Logging (Recommended)
echo "Test 5: Debug logging..."
if grep -q "console.log.*\[PS101\].*nextPrompt" "$FRONTEND_DIR/index.html"; then
  echo "  ✅ PS101 debug logging enabled"
else
  echo "  ⚠️  Debug logging not detected (recommended for troubleshooting)"
fi
echo ""

# Test 6: Live Site Check (if URL provided)
if command -v curl &> /dev/null; then
  echo "Test 6: Live site check ($FRONTEND_URL)..."

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>&1 || echo "000")

  if [ "$HTTP_CODE" = "200" ]; then
    echo "  ✅ Site accessible (HTTP 200)"

    # Check for critical content in live site
    LIVE_CONTENT=$(curl -s "$FRONTEND_URL" 2>&1)

    if echo "$LIVE_CONTENT" | grep -q "PS101State"; then
      echo "  ✅ PS101 code deployed"
    else
      echo "  ⚠️  PS101 code not detected in live site"
    fi

    if echo "$LIVE_CONTENT" | grep -q "What Is My Delta"; then
      echo "  ✅ Site content present"
    else
      echo "  ⚠️  Site content missing or changed"
    fi
  else
    echo "  ⚠️  Site returned HTTP $HTTP_CODE"
  fi
  echo ""
fi

# Test 7: Frontend Health Endpoint
if command -v curl &> /dev/null; then
  echo "Test 7: Frontend health endpoint..."

  HEALTH_URL="${FRONTEND_URL}/health.html"
  HEALTH_RESPONSE=$(curl -s "$HEALTH_URL" 2>&1)

  if echo "$HEALTH_RESPONSE" | grep -q '"ok": true'; then
    echo "  ✅ Frontend health endpoint responding"
    echo "  ✅ Health status: OK"
  elif echo "$HEALTH_RESPONSE" | grep -q '"ok":'; then
    echo "  ⚠️  Frontend health endpoint responding but not healthy"
  else
    echo "  ⚠️  Frontend health endpoint not accessible"
  fi
  echo ""
fi

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
  echo "✅ SMOKE TEST PASSED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Frontend is ready for deployment"
  exit 0
else
  echo "❌ SMOKE TEST FAILED ($ERRORS error(s))"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Fix errors before deploying"
  exit 1
fi
