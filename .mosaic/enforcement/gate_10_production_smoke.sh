#!/bin/bash
# GATE 10: Production Smoke Tests
# Authority: Google SRE Handbook, DORA Metrics, Test Pyramid (Martin Fowler)
# Purpose: Validate deployed code actually works in production
# Enforcement: BLOCKS marking work "complete"

set -e

BACKEND_URL="${BACKEND_URL:-https://mosaic-backend-tpog.onrender.com}"
FRONTEND_URL="${FRONTEND_URL:-https://whatismydelta.com}"

echo "🔍 GATE 10: PRODUCTION SMOKE TESTS"
echo "Authority: Google SRE, DORA Metrics, Test Pyramid"
echo "============================================================"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Basic health check
echo "🧪 Test 1: Backend health responds..."
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/health" || echo "000")
if [ "$HEALTH_STATUS" = "200" ]; then
    echo "  ✅ PASS: Health endpoint responds (200)"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Health endpoint returned $HEALTH_STATUS (expected 200)"
    ((TESTS_FAILED++))
fi
echo ""

# Test 2: Health endpoint returns valid JSON
echo "🧪 Test 2: Health endpoint returns valid JSON..."
HEALTH_JSON=$(curl -s "$BACKEND_URL/health" | jq -e '.ok' 2>/dev/null || echo "invalid")
if [ "$HEALTH_JSON" = "true" ]; then
    echo "  ✅ PASS: Health JSON valid and ok=true"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Health JSON invalid or ok!=true"
    ((TESTS_FAILED++))
fi
echo ""

# Test 3: Check if deployment includes new endpoints
echo "🧪 Test 3: New endpoints from recent commit..."
COMMIT_MESSAGE=$(git log -1 --pretty=%B 2>/dev/null || echo "")

if echo "$COMMIT_MESSAGE" | grep -qi "semantic-match\|reranker\|analytics"; then
    echo "  📋 Detected semantic match deployment in commit message"
    echo "  Testing new endpoints: /reranker/health, /analytics/health"
    echo ""

    # Test reranker health endpoint
    echo "  🧪 Test 3a: /reranker/health endpoint..."
    RERANKER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/reranker/health" || echo "000")
    if [ "$RERANKER_STATUS" = "200" ]; then
        echo "    ✅ PASS: /reranker/health responds (200)"
        ((TESTS_PASSED++))
    elif [ "$RERANKER_STATUS" = "404" ]; then
        echo "    ❌ FAIL: /reranker/health returns 404 (endpoint not deployed)"
        echo "    💡 Likely cause: Render deployment not complete or code not deployed"
        ((TESTS_FAILED++))
    else
        echo "    ⚠️  WARN: /reranker/health returns $RERANKER_STATUS (not 200)"
        ((TESTS_FAILED++))
    fi
    echo ""

    # Test analytics health endpoint
    echo "  🧪 Test 3b: /analytics/health endpoint..."
    ANALYTICS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/analytics/health" || echo "000")
    if [ "$ANALYTICS_STATUS" = "200" ]; then
        echo "    ✅ PASS: /analytics/health responds (200)"
        ((TESTS_PASSED++))
    elif [ "$ANALYTICS_STATUS" = "404" ]; then
        echo "    ❌ FAIL: /analytics/health returns 404 (endpoint not deployed)"
        echo "    💡 Likely cause: Render deployment not complete or code not deployed"
        ((TESTS_FAILED++))
    else
        echo "    ⚠️  WARN: /analytics/health returns $ANALYTICS_STATUS (not 200)"
        ((TESTS_FAILED++))
    fi
    echo ""

    # Test RAG health endpoint
    echo "  🧪 Test 3c: /health/rag endpoint..."
    RAG_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/health/rag" || echo "000")
    if [ "$RAG_STATUS" = "200" ]; then
        echo "    ✅ PASS: /health/rag responds (200)"
        ((TESTS_PASSED++))
    elif [ "$RAG_STATUS" = "404" ]; then
        echo "    ❌ FAIL: /health/rag returns 404 (endpoint not deployed)"
        echo "    💡 Likely cause: Render deployment not complete or code not deployed"
        ((TESTS_FAILED++))
    else
        echo "    ⚠️  WARN: /health/rag returns $RAG_STATUS (not 200)"
        ((TESTS_FAILED++))
    fi
    echo ""
else
    echo "  ℹ️  No new endpoints detected in commit message"
    echo "  Skipping endpoint-specific tests"
    echo ""
fi

# Test 4: Frontend accessibility
echo "🧪 Test 4: Frontend loads..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" || echo "000")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "  ✅ PASS: Frontend loads (200)"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Frontend returned $FRONTEND_STATUS (expected 200)"
    ((TESTS_FAILED++))
fi
echo ""

# Test 5: Response time check (SRE P95 latency requirement)
echo "🧪 Test 5: Health endpoint latency (SRE P95 target: <500ms)..."
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$BACKEND_URL/health" || echo "999")
RESPONSE_MS=$(echo "$RESPONSE_TIME * 1000" | bc 2>/dev/null || echo "999")
RESPONSE_MS_INT=$(printf "%.0f" "$RESPONSE_MS" 2>/dev/null || echo "999")

if [ "$RESPONSE_MS_INT" -lt 500 ]; then
    echo "  ✅ PASS: Response time ${RESPONSE_MS_INT}ms (< 500ms SRE target)"
    ((TESTS_PASSED++))
elif [ "$RESPONSE_MS_INT" -lt 1000 ]; then
    echo "  ⚠️  WARN: Response time ${RESPONSE_MS_INT}ms (exceeds 500ms SRE target)"
    # Don't fail, just warn
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Response time ${RESPONSE_MS_INT}ms (far exceeds SRE target)"
    ((TESTS_FAILED++))
fi
echo ""

# Results summary
echo "============================================================"
echo "📊 PRODUCTION SMOKE TEST RESULTS"
echo "============================================================"
echo ""
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo ""

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo "✅ Gate 10 PASSED - Production endpoints validated"
    echo ""
    echo "DORA Metrics:"
    echo "  ✅ Change Failure Rate: 0% (this deployment)"
    echo "  ✅ Deployment validated per SRE standards"
    echo ""
    exit 0
else
    echo "❌ Gate 10 FAILED - Production validation incomplete"
    echo ""
    echo "DORA Metrics:"
    echo "  ❌ Change Failure Rate: 100% (this deployment FAILED)"
    echo "  ❌ Work is NOT complete until all tests pass"
    echo ""
    echo "Next steps:"
    echo "  1. Check Render deployment status (may still be deploying)"
    echo "  2. Check Render logs for errors"
    echo "  3. Verify requirements.txt dependencies installed"
    echo "  4. Re-run this test after fixes"
    echo ""
    exit 1
fi
