#!/bin/bash
# Pre-Push Verification Script
# COMPREHENSIVE testing: Backend + Frontend with equal rigor
# Created: 2026-01-07
# Updated: 2026-02-06 - Added mandatory frontend E2E testing

set -euo pipefail

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          PRE-DEPLOYMENT VERIFICATION (Backend + Frontend)      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0
WARNINGS=0

# ============================================================================
# SECTION 1: BACKEND VERIFICATION
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SECTION 1: BACKEND VERIFICATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1.1: Backend sanity checks
echo "Step 1.1: Backend sanity checks..."
if [ -f "./scripts/predeploy_sanity.sh" ]; then
  if ./scripts/predeploy_sanity.sh; then
    echo "  ✅ Backend sanity checks passed"
  else
    echo "  ❌ Backend sanity checks FAILED"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ⚠️  predeploy_sanity.sh not found"
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Step 1.2: Backend health (if local server running)
echo "Step 1.2: Backend health check..."
if curl -s http://localhost:8000/health &> /dev/null; then
  HEALTH=$(curl -s http://localhost:8000/health)
  if echo "$HEALTH" | grep -q '"ok":true'; then
    echo "  ✅ Local backend healthy"
  else
    echo "  ⚠️  Local backend unhealthy: $HEALTH"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "  ℹ️  Local backend not running (OK for remote-only deploys)"
fi
echo ""

# ============================================================================
# SECTION 2: FRONTEND VERIFICATION (MANDATORY)
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SECTION 2: FRONTEND VERIFICATION (MANDATORY)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 2.1: Check for frontend files
echo "Step 2.1: Frontend file structure..."
FRONTEND_DIR="frontend"
if [ -d "$FRONTEND_DIR" ]; then
  echo "  ✅ Frontend directory exists: $FRONTEND_DIR/"

  if [ -f "$FRONTEND_DIR/index.html" ]; then
    FILE_SIZE=$(wc -c < "$FRONTEND_DIR/index.html" | tr -d ' ')
    echo "  ✅ index.html exists ($FILE_SIZE bytes)"
  else
    echo "  ❌ index.html missing from $FRONTEND_DIR/"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ❌ Frontend directory not found: $FRONTEND_DIR/"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# Step 2.2: Content verification (critical features)
echo "Step 2.2: Critical feature detection..."
if [ -f "$FRONTEND_DIR/index.html" ]; then
  # Check for authentication
  if grep -q "authModal" "$FRONTEND_DIR/index.html"; then
    echo "  ✅ Authentication UI detected"
  else
    echo "  ❌ Authentication UI missing (authModal not found)"
    ERRORS=$((ERRORS + 1))
  fi

  # Check for PS101
  if grep -q "PS101State" "$FRONTEND_DIR/index.html"; then
    echo "  ✅ PS101 flow detected"
  else
    echo "  ❌ PS101 flow missing (PS101State not found)"
    ERRORS=$((ERRORS + 1))
  fi

  # Check for navigation functions
  if grep -q "nextPrompt()" "$FRONTEND_DIR/index.html"; then
    echo "  ✅ PS101 navigation functions detected"
  else
    echo "  ❌ PS101 navigation broken (nextPrompt() not found)"
    ERRORS=$((ERRORS + 1))
  fi

  # Check for console logging (debugging)
  if grep -q "console.log.*PS101.*nextPrompt" "$FRONTEND_DIR/index.html"; then
    echo "  ✅ PS101 debug logging enabled"
  else
    echo "  ⚠️  PS101 debug logging not detected (recommended for debugging)"
    WARNINGS=$((WARNINGS + 1))
  fi
fi
echo ""

# Step 2.3: Playwright setup verification (CRITICAL)
echo "Step 2.3: Playwright testing framework..."

# Check for Node.js/npm
if ! command -v npx &> /dev/null; then
  echo "  ❌ npm/npx not found - Node.js required for frontend testing"
  echo "  💡 Install: brew install node"
  ERRORS=$((ERRORS + 1))
  echo ""
  echo "🚨 CRITICAL: Frontend testing infrastructure missing!"
  echo "Cannot proceed without Node.js/Playwright"
  echo ""
  exit 1
fi

echo "  ✅ npm/npx found: $(npx --version)"

# Check for Playwright installation
if npx playwright --version &> /dev/null 2>&1; then
  PW_VERSION=$(npx playwright --version 2>&1 | head -1)
  echo "  ✅ Playwright installed: $PW_VERSION"
else
  echo "  ⚠️  Playwright not installed - installing now..."
  if npm install -D @playwright/test && npx playwright install --with-deps chromium; then
    echo "  ✅ Playwright installed successfully"
  else
    echo "  ❌ Failed to install Playwright"
    ERRORS=$((ERRORS + 1))
    echo ""
    echo "🚨 CRITICAL: Cannot run frontend tests without Playwright"
    exit 1
  fi
fi
echo ""

# Step 2.4: Run Playwright E2E Tests (MANDATORY)
echo "Step 2.4: Frontend E2E Tests (BLOCKING)..."
echo ""

PLAYWRIGHT_ERRORS=0

# Test 1: PS101 Complete Flow
if [ -f "test-ps101-complete-flow.js" ]; then
  echo "  🧪 Test 1: PS101 Complete Flow (Steps 1-10)"
  echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Run test with detailed output
  if npx playwright test test-ps101-complete-flow.js --reporter=list --workers=1 2>&1 | tee /tmp/ps101-flow-test.log; then
    echo ""
    echo "  ✅ PS101 Complete Flow: PASSED"
  else
    echo ""
    echo "  ❌ PS101 Complete Flow: FAILED"
    echo "  📋 Details in: /tmp/ps101-flow-test.log"
    PLAYWRIGHT_ERRORS=$((PLAYWRIGHT_ERRORS + 1))
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ❌ test-ps101-complete-flow.js not found"
  echo "  🚨 CRITICAL: Core E2E test missing!"
  ERRORS=$((ERRORS + 1))
fi

echo ""

# Test 2: PS101 Step 6 Validation
if [ -f "test-ps101-step6-validation.js" ]; then
  echo "  🧪 Test 2: PS101 Step 6 Validation (Experiment Design)"
  echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if npx playwright test test-ps101-step6-validation.js --reporter=list --workers=1 2>&1 | tee /tmp/ps101-step6-test.log; then
    echo ""
    echo "  ✅ Step 6 Validation: PASSED"
  else
    echo ""
    echo "  ❌ Step 6 Validation: FAILED"
    echo "  📋 Details in: /tmp/ps101-step6-test.log"
    PLAYWRIGHT_ERRORS=$((PLAYWRIGHT_ERRORS + 1))
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ⚠️  test-ps101-step6-validation.js not found (optional test)"
  WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Frontend test summary
if [ $PLAYWRIGHT_ERRORS -eq 0 ]; then
  echo "  ✅ All frontend E2E tests passed!"
else
  echo "  ❌ $PLAYWRIGHT_ERRORS frontend test(s) failed"
  echo "  🔧 Fix tests before deploying to production"
fi
echo ""

# ============================================================================
# SECTION 3: GIT STATUS
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SECTION 3: GIT STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Step 3.1: Working tree status..."
if [ -n "$(git status --porcelain)" ]; then
  echo "  ⚠️  Uncommitted changes detected:"
  git status --short
  WARNINGS=$((WARNINGS + 1))
else
  echo "  ✅ Git working tree clean"
fi
echo ""

# ============================================================================
# FINAL SUMMARY
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      VERIFICATION SUMMARY                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

if [ $ERRORS -eq 0 ]; then
  echo "✅ ALL CHECKS PASSED"
  echo ""
  echo "  Backend:  ✅ Verified"
  echo "  Frontend: ✅ Verified (E2E tests passed)"
  echo "  Git:      ✅ Ready"
  echo ""

  if [ $WARNINGS -gt 0 ]; then
    echo "⚠️  $WARNINGS warning(s) detected (non-blocking)"
    echo ""
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚀 SAFE TO DEPLOY"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo "❌ VERIFICATION FAILED"
  echo ""
  echo "  Errors:   $ERRORS"
  echo "  Warnings: $WARNINGS"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚫 DEPLOYMENT BLOCKED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Fix the errors above before deploying to production."
  echo ""
  echo "Test logs saved to:"
  echo "  - /tmp/ps101-flow-test.log"
  echo "  - /tmp/ps101-step6-test.log"
  echo ""
  echo "Emergency bypass (NOT RECOMMENDED):"
  echo "  SKIP_VERIFICATION=true ./scripts/deploy.sh ..."
  echo "  (Will be logged to .verification_audit.log)"
  echo ""
  exit 1
fi
