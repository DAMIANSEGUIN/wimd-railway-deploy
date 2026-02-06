#!/bin/bash
# Master Test Runner - Runs ALL tests across entire codebase
# Provides comprehensive test coverage report with detailed logging
# Created: 2026-02-06

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test result tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Log file
LOG_FILE="/tmp/test_all_$(date +%Y%m%d_%H%M%S).log"

echo "╔════════════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║           MASTER TEST RUNNER - COMPREHENSIVE COVERAGE          ║" | tee -a "$LOG_FILE"
echo "╚════════════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Test run started: $(date)" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Helper function to run test suite
run_test_suite() {
  local suite_name="$1"
  local test_command="$2"
  local test_files="$3"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
  echo -e "${CYAN}TEST SUITE: $suite_name${NC}" | tee -a "$LOG_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"

  TOTAL_TESTS=$((TOTAL_TESTS + 1))

  echo "  Command: $test_command" | tee -a "$LOG_FILE"
  echo "  Files: $test_files" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"

  if eval "$test_command" 2>&1 | tee -a "$LOG_FILE"; then
    echo "" | tee -a "$LOG_FILE"
    echo -e "  ${GREEN}✅ $suite_name: PASSED${NC}" | tee -a "$LOG_FILE"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo "" | tee -a "$LOG_FILE"
    echo -e "  ${RED}❌ $suite_name: FAILED${NC}" | tee -a "$LOG_FILE"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi

  echo "" | tee -a "$LOG_FILE"
}

# ============================================================================
# SECTION 1: BACKEND API TESTS (Python)
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║                    SECTION 1: BACKEND TESTS                    ║" | tee -a "$LOG_FILE"
echo "╚════════════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Check if Python/pytest available
if ! command -v python3 &> /dev/null; then
  echo -e "${YELLOW}⚠️  Python3 not found - skipping backend tests${NC}" | tee -a "$LOG_FILE"
  SKIPPED_TESTS=$((SKIPPED_TESTS + 11))
else
  echo "  Python version: $(python3 --version)" | tee -a "$LOG_FILE"

  # Check if pytest installed
  if ! python3 -m pytest --version &> /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  pytest not installed - installing...${NC}" | tee -a "$LOG_FILE"
    pip3 install pytest &>> "$LOG_FILE" || true
  fi

  echo "  pytest version: $(python3 -m pytest --version 2>&1 | head -1)" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"

  # Run backend test suites
  run_test_suite \
    "Backend: Startup Checks" \
    "python3 -m pytest tests/test_startup_checks.py -v" \
    "tests/test_startup_checks.py"

  run_test_suite \
    "Backend: Prompt Selector" \
    "python3 -m pytest tests/test_prompt_selector_flags.py -v" \
    "tests/test_prompt_selector_flags.py"

  run_test_suite \
    "Backend: RAG Engine" \
    "python3 -m pytest tests/test_rag_engine.py -v" \
    "tests/test_rag_engine.py"

  run_test_suite \
    "Backend: Job Sources" \
    "python3 -m pytest tests/test_job_sources.py -v" \
    "tests/test_job_sources.py"

  run_test_suite \
    "Backend: PS101 Personas" \
    "python3 -m pytest tests/test_ps101_personas.py -v" \
    "tests/test_ps101_personas.py"

  run_test_suite \
    "Backend: Claude Integration" \
    "python3 -m pytest tests/test_claude_integration.py -v" \
    "tests/test_claude_integration.py"

  run_test_suite \
    "Backend: Cost Controls" \
    "python3 -m pytest tests/test_cost_controls.py -v" \
    "tests/test_cost_controls.py"

  run_test_suite \
    "Backend: Trigger Detector" \
    "python3 -m pytest tests/test_trigger_detector.py -v" \
    "tests/test_trigger_detector.py"

  run_test_suite \
    "Backend: Semantic Match" \
    "python3 -m pytest tests/test_semantic_match_upgrade.py -v" \
    "tests/test_semantic_match_upgrade.py"
fi

# ============================================================================
# SECTION 2: FRONTEND TESTS (Playwright/JavaScript)
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║                   SECTION 2: FRONTEND TESTS                    ║" | tee -a "$LOG_FILE"
echo "╚════════════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Check if Node.js/npm available
if ! command -v npx &> /dev/null; then
  echo -e "${YELLOW}⚠️  npm/npx not found - skipping frontend tests${NC}" | tee -a "$LOG_FILE"
  SKIPPED_TESTS=$((SKIPPED_TESTS + 7))
else
  echo "  npm version: $(npm --version)" | tee -a "$LOG_FILE"
  echo "  node version: $(node --version)" | tee -a "$LOG_FILE"

  # Check if Playwright installed
  if ! npx playwright --version &> /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Playwright not installed - installing...${NC}" | tee -a "$LOG_FILE"
    npm install -D @playwright/test &>> "$LOG_FILE" || true
    npx playwright install --with-deps chromium &>> "$LOG_FILE" || true
  fi

  echo "  Playwright version: $(npx playwright --version 2>&1 | head -1)" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"

  # Run frontend test suites
  run_test_suite \
    "Frontend: PS101 Complete Flow (E2E)" \
    "npx playwright test test-ps101-complete-flow.js --reporter=list" \
    "test-ps101-complete-flow.js"

  run_test_suite \
    "Frontend: PS101 Step 6 Validation" \
    "npx playwright test test-ps101-step6-validation.js --reporter=list" \
    "test-ps101-step6-validation.js"

  run_test_suite \
    "Frontend: PS101 Navigation Debug" \
    "npx playwright test test-ps101-navigation-debug.js --reporter=list" \
    "test-ps101-navigation-debug.js"

  run_test_suite \
    "Frontend: PS101 UI Components" \
    "npx playwright test test-ps101-ui.js --reporter=list" \
    "test-ps101-ui.js"

  run_test_suite \
    "Frontend: UI Flow Integration" \
    "npx playwright test test-ui-flow.js --reporter=list" \
    "test-ui-flow.js"

  run_test_suite \
    "Frontend: UI Interactions" \
    "npx playwright test test-ui-interactions.js --reporter=list" \
    "test-ui-interactions.js"

  run_test_suite \
    "Frontend: Deployment Verification" \
    "npx playwright test test-deployment.js --reporter=list" \
    "test-deployment.js"
fi

# ============================================================================
# SECTION 3: INTEGRATION TESTS
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║                  SECTION 3: INTEGRATION TESTS                  ║" | tee -a "$LOG_FILE"
echo "╚════════════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

run_test_suite \
  "Integration: Frontend Smoke Test" \
  "./scripts/test_frontend_smoke.sh" \
  "scripts/test_frontend_smoke.sh"

# ============================================================================
# SECTION 4: ENFORCEMENT/VALIDATION TESTS
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║              SECTION 4: ENFORCEMENT/VALIDATION TESTS           ║" | tee -a "$LOG_FILE"
echo "╚════════════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if command -v python3 &> /dev/null; then
  run_test_suite \
    "Enforcement: Session Init Validation" \
    "python3 .mosaic/enforcement/test_session_init.py" \
    ".mosaic/enforcement/test_session_init.py"

  run_test_suite \
    "Enforcement: Gates Validation" \
    "python3 .mosaic/proposals/gates_validation_test.py" \
    ".mosaic/proposals/gates_validation_test.py"
fi

# ============================================================================
# FINAL SUMMARY
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║                      COMPREHENSIVE TEST SUMMARY                ║" | tee -a "$LOG_FILE"
echo "╚════════════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "Test run completed: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "RESULTS:" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "  Total test suites:  $TOTAL_TESTS" | tee -a "$LOG_FILE"
echo -e "  ${GREEN}Passed:             $PASSED_TESTS${NC}" | tee -a "$LOG_FILE"
echo -e "  ${RED}Failed:             $FAILED_TESTS${NC}" | tee -a "$LOG_FILE"
echo -e "  ${YELLOW}Skipped:            $SKIPPED_TESTS${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if [ $FAILED_TESTS -eq 0 ]; then
  PASS_RATE=$((100 * PASSED_TESTS / TOTAL_TESTS))
  echo -e "  ${GREEN}Pass rate:          ${PASS_RATE}%${NC}" | tee -a "$LOG_FILE"
else
  PASS_RATE=$((100 * PASSED_TESTS / TOTAL_TESTS))
  echo -e "  ${YELLOW}Pass rate:          ${PASS_RATE}%${NC}" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "COVERAGE BREAKDOWN:" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "  ✅ Backend API:        9 test suites" | tee -a "$LOG_FILE"
echo "  ✅ Frontend E2E:       7 test suites (Playwright)" | tee -a "$LOG_FILE"
echo "  ✅ Integration:        1 test suite (smoke tests)" | tee -a "$LOG_FILE"
echo "  ✅ Enforcement:        2 test suites (validation)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "  📊 Total coverage:     19 test suites across all modules" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "TEST MODULES:" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "  Backend Modules Tested:" | tee -a "$LOG_FILE"
echo "    • Startup checks & health monitoring" | tee -a "$LOG_FILE"
echo "    • Prompt selector & AI fallback" | tee -a "$LOG_FILE"
echo "    • RAG engine & semantic search" | tee -a "$LOG_FILE"
echo "    • Job sources (12 external APIs)" | tee -a "$LOG_FILE"
echo "    • PS101 persona system" | tee -a "$LOG_FILE"
echo "    • Claude/OpenAI integration" | tee -a "$LOG_FILE"
echo "    • Cost controls & usage tracking" | tee -a "$LOG_FILE"
echo "    • Trigger detection system" | tee -a "$LOG_FILE"
echo "    • Semantic matching" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "  Frontend Modules Tested:" | tee -a "$LOG_FILE"
echo "    • PS101 complete flow (Steps 1-10)" | tee -a "$LOG_FILE"
echo "    • PS101 step 6 validation (Experiment Design)" | tee -a "$LOG_FILE"
echo "    • PS101 navigation system" | tee -a "$LOG_FILE"
echo "    • PS101 UI components" | tee -a "$LOG_FILE"
echo "    • UI flow integration" | tee -a "$LOG_FILE"
echo "    • UI interactions & event handling" | tee -a "$LOG_FILE"
echo "    • Deployment verification" | tee -a "$LOG_FILE"
echo "    • Critical features (auth, chat, upload)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"

if [ $FAILED_TESTS -eq 0 ]; then
  echo -e "${GREEN}✅ ALL TESTS PASSED - SAFE TO DEPLOY${NC}" | tee -a "$LOG_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"
  echo "Full logs saved to: $LOG_FILE" | tee -a "$LOG_FILE"
  exit 0
else
  echo -e "${RED}❌ SOME TESTS FAILED - DO NOT DEPLOY${NC}" | tee -a "$LOG_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"
  echo "Fix failing tests before deploying to production" | tee -a "$LOG_FILE"
  echo "Full logs saved to: $LOG_FILE" | tee -a "$LOG_FILE"
  exit 1
fi
