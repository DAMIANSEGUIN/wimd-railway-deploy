#!/bin/bash
# Mosaic MVP Quick Test Script
# Usage: ./scripts/test_mosaic.sh

set -e

echo "=========================================="
echo "Mosaic MVP Quick Test Suite"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Backend Health
echo "Test 1: Backend Health Check"
echo "----------------------------"
HEALTH_RESPONSE=$(curl -s https://mosaic-backend-tpog.onrender.com/health)
HEALTH_OK=$(echo "$HEALTH_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('ok', False))")
DB_OK=$(echo "$HEALTH_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('checks', {}).get('database', False))")

if [ "$HEALTH_OK" = "True" ] && [ "$DB_OK" = "True" ]; then
    echo -e "${GREEN}✅ Backend healthy, PostgreSQL connected${NC}"
else
    echo -e "${RED}❌ Backend health check failed${NC}"
    echo "$HEALTH_RESPONSE" | python3 -m json.tool
fi
echo ""

# Test 2: Context Extraction Endpoint
echo "Test 2: Context Extraction Endpoint"
echo "-----------------------------------"
HTTP_STATUS=$(curl -X POST https://mosaic-backend-tpog.onrender.com/api/ps101/extract-context \
  -H "Content-Type: application/json" \
  -w "%{http_code}" -o /dev/null -s)

if [ "$HTTP_STATUS" = "422" ]; then
    echo -e "${GREEN}✅ Endpoint exists (422 = needs auth, expected)${NC}"
elif [ "$HTTP_STATUS" = "404" ]; then
    echo -e "${RED}❌ Endpoint not found (404)${NC}"
    echo "Router prefix issue - check api/index.py"
else
    echo -e "${YELLOW}⚠️  Unexpected status: $HTTP_STATUS${NC}"
fi
echo ""

# Test 3: Frontend Reachability
echo "Test 3: Frontend Reachability"
echo "-----------------------------"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://whatismydelta.com)

if [ "$FRONTEND_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Frontend accessible${NC}"
else
    echo -e "${RED}❌ Frontend returned: $FRONTEND_STATUS${NC}"
fi
echo ""

# Test 4: Recent Errors in Logs
echo "Test 4: Recent Error Check"
echo "--------------------------"
ERROR_COUNT=$(railway logs 2>/dev/null | grep -iE "error|exception" | wc -l | tr -d ' ')

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ No recent errors in logs${NC}"
else
    echo -e "${YELLOW}⚠️  Found $ERROR_COUNT error(s) in recent logs${NC}"
    echo "Run: railway logs | grep -iE 'error|exception' --color=always"
fi
echo ""

# Test 5: Database Context Table
echo "Test 5: Database Context Table"
echo "------------------------------"
CONTEXT_COUNT=$(railway run psql $DATABASE_URL -c "SELECT COUNT(*) FROM user_contexts;" 2>/dev/null | grep -oE '[0-9]+' | head -1)

if [ -n "$CONTEXT_COUNT" ]; then
    echo -e "${GREEN}✅ user_contexts table exists ($CONTEXT_COUNT rows)${NC}"
else
    echo -e "${YELLOW}⚠️  Could not query user_contexts table${NC}"
fi
echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Open browser: open -a 'Google Chrome' https://whatismydelta.com"
echo "2. Create test account: test+mosaic_$(date +%s)@example.com"
echo "3. Complete PS101 flow (use sample answers in .ai-agents/quick_start/BROWSER_TESTING_PROMPT.md)"
echo "4. Check console for 'Context extraction successful'"
echo "5. Test personalized chat with: 'What should I do next?'"
echo ""
echo "Full testing guide: .ai-agents/validation/MOSAIC_MVP_TESTING_GUIDE.md"
echo ""
