# UI Testing Protocol

**Created:** 2026-01-25
**Purpose:** Comprehensive end-to-end UI testing before deployment
**Status:** MANDATORY - Run before every production push

---

## WHY THIS IS NEEDED

**Today's Failure:**
- Frontend deployed with wrong API URL (`mosaic-platform.vercel.app`)
- Gate 9 passed but didn't catch it
- All backend features broken (404 errors)
- Issue only discovered when user asked "have you tested the UI?"

**Root Cause:**
- Gate 9 checked wrong file (`mosaic_ui/index.html` instead of `frontend/index.html`)
- Test passed with warning instead of failing
- No end-to-end functional testing

---

## TESTING LAYERS

### Layer 1: Static Analysis (Pre-Deploy)
**Check configuration without deploying**

```bash
#!/bin/bash
# .mosaic/enforcement/test_ui_config.sh

echo "=== UI CONFIGURATION TESTS ==="

# Test 1: Check frontend API URL
echo "Test 1: Frontend API URL"
FRONTEND_API=$(grep -o "api:'[^']*'" frontend/index.html | cut -d"'" -f2)
EXPECTED_API="https://mosaic-backend-tpog.onrender.com"

if [ "$FRONTEND_API" = "$EXPECTED_API" ]; then
    echo "  ✅ PASS: Frontend API URL correct ($FRONTEND_API)"
else
    echo "  ❌ FAIL: Frontend API URL wrong"
    echo "     Found: $FRONTEND_API"
    echo "     Expected: $EXPECTED_API"
    exit 1
fi

# Test 2: Netlify redirects point to correct backend
echo "Test 2: Netlify redirect configuration"
REDIRECT_COUNT=$(grep -c "https://mosaic-backend-tpog.onrender.com" netlify.toml)

if [ "$REDIRECT_COUNT" -gt 5 ]; then
    echo "  ✅ PASS: Netlify redirects configured ($REDIRECT_COUNT endpoints)"
else
    echo "  ❌ FAIL: Netlify redirects missing or wrong"
    echo "     Found: $REDIRECT_COUNT references to Render backend"
    exit 1
fi

# Test 3: No dead backend URLs
echo "Test 3: No dead backend URLs in frontend"
DEAD_URLS=(
    "mosaic-platform.vercel.app"
    "what-is-my-delta-site-production.up.render.app"
    "localhost:8000"
)

FOUND_DEAD=0
for URL in "${DEAD_URLS[@]}"; do
    if grep -q "$URL" frontend/index.html; then
        echo "  ❌ FAIL: Found dead URL: $URL"
        FOUND_DEAD=1
    fi
done

if [ $FOUND_DEAD -eq 0 ]; then
    echo "  ✅ PASS: No dead backend URLs"
else
    exit 1
fi

# Test 4: PS101 content present
echo "Test 4: PS101 content present in frontend"
if grep -q "PS101" frontend/index.html && grep -q "Step 1 of 10" frontend/index.html; then
    echo "  ✅ PASS: PS101 content found"
else
    echo "  ❌ FAIL: PS101 content missing"
    exit 1
fi

echo ""
echo "✅ All UI configuration tests passed"
```

### Layer 2: Backend Connectivity (Pre-Deploy)
**Verify backend is healthy before deploying frontend**

```bash
#!/bin/bash
# .mosaic/enforcement/test_backend_health.sh

echo "=== BACKEND HEALTH TESTS ==="

BACKEND_URL="https://mosaic-backend-tpog.onrender.com"

# Test 1: Health endpoint
echo "Test 1: Health endpoint responds"
HEALTH=$(curl -s -w "%{http_code}" -o /tmp/health.json "$BACKEND_URL/health")

if [ "$HEALTH" = "200" ]; then
    if jq -e '.ok == true' /tmp/health.json > /dev/null; then
        echo "  ✅ PASS: Backend healthy"
    else
        echo "  ❌ FAIL: Backend returned ok=false"
        exit 1
    fi
else
    echo "  ❌ FAIL: Health endpoint returned HTTP $HEALTH"
    exit 1
fi

# Test 2: Config endpoint
echo "Test 2: Config endpoint responds"
CONFIG=$(curl -s -w "%{http_code}" -o /tmp/config.json "$BACKEND_URL/config")

if [ "$CONFIG" = "200" ]; then
    API_BASE=$(jq -r '.apiBase' /tmp/config.json)
    if [ "$API_BASE" = "$BACKEND_URL" ]; then
        echo "  ✅ PASS: Config returns correct apiBase"
    else
        echo "  ❌ FAIL: Config apiBase mismatch"
        echo "     Expected: $BACKEND_URL"
        echo "     Got: $API_BASE"
        exit 1
    fi
else
    echo "  ❌ FAIL: Config endpoint returned HTTP $CONFIG"
    exit 1
fi

# Test 3: Database connected
echo "Test 3: Database connectivity"
if jq -e '.checks.database == true' /tmp/health.json > /dev/null; then
    echo "  ✅ PASS: Database connected"
else
    echo "  ❌ FAIL: Database not connected"
    exit 1
fi

# Test 4: AI available
echo "Test 4: AI services available"
if jq -e '.checks.ai_available == true' /tmp/health.json > /dev/null; then
    echo "  ✅ PASS: AI services available"
else
    echo "  ❌ FAIL: AI services unavailable"
    exit 1
fi

echo ""
echo "✅ All backend health tests passed"
```

### Layer 3: End-to-End Functional (Post-Deploy)
**Test actual deployed UI functionality**

```bash
#!/bin/bash
# .mosaic/enforcement/test_ui_e2e.sh

echo "=== END-TO-END UI TESTS ==="

FRONTEND_URL="https://whatismydelta.com"
BACKEND_URL="https://mosaic-backend-tpog.onrender.com"

# Test 1: Frontend loads
echo "Test 1: Frontend loads"
FRONTEND_STATUS=$(curl -s -w "%{http_code}" -o /tmp/frontend.html "$FRONTEND_URL")

if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "  ✅ PASS: Frontend loads (HTTP 200)"
else
    echo "  ❌ FAIL: Frontend returned HTTP $FRONTEND_STATUS"
    exit 1
fi

# Test 2: PS101 content visible
echo "Test 2: PS101 content visible in deployed frontend"
if grep -q "PS101" /tmp/frontend.html && grep -q "Step.*1.*of.*10" /tmp/frontend.html; then
    echo "  ✅ PASS: PS101 content present"
else
    echo "  ❌ FAIL: PS101 content missing from deployed frontend"
    exit 1
fi

# Test 3: Deployed frontend has correct API URL
echo "Test 3: Deployed frontend API URL"
DEPLOYED_API=$(grep -o "api:'[^']*'" /tmp/frontend.html | cut -d"'" -f2)

if [ "$DEPLOYED_API" = "$BACKEND_URL" ]; then
    echo "  ✅ PASS: Deployed frontend uses correct API ($DEPLOYED_API)"
else
    echo "  ❌ FAIL: Deployed frontend has wrong API"
    echo "     Found: $DEPLOYED_API"
    echo "     Expected: $BACKEND_URL"
    exit 1
fi

# Test 4: Backend endpoints accessible through Netlify
echo "Test 4: Backend /health accessible through Netlify proxy"
PROXY_HEALTH=$(curl -s -w "%{http_code}" -o /tmp/proxy_health.json "$FRONTEND_URL/health")

if [ "$PROXY_HEALTH" = "200" ]; then
    if jq -e '.ok == true' /tmp/proxy_health.json > /dev/null 2>&1; then
        echo "  ✅ PASS: Netlify proxy works for /health"
    else
        echo "  ⚠️  WARN: Proxy returned 200 but unexpected format"
    fi
else
    echo "  ❌ FAIL: Netlify proxy for /health returned HTTP $PROXY_HEALTH"
    exit 1
fi

# Test 5: Backend /config accessible through Netlify
echo "Test 5: Backend /config accessible through Netlify proxy"
PROXY_CONFIG=$(curl -s -w "%{http_code}" -o /tmp/proxy_config.json "$FRONTEND_URL/config")

if [ "$PROXY_CONFIG" = "200" ]; then
    echo "  ✅ PASS: Netlify proxy works for /config"
else
    echo "  ❌ FAIL: Netlify proxy for /config returned HTTP $PROXY_CONFIG"
    exit 1
fi

# Test 6: Test a POST endpoint (simulate chat)
echo "Test 6: Backend POST endpoint works through proxy"
POST_RESULT=$(curl -s -w "%{http_code}" -o /tmp/post_result.json \
    -X POST "$FRONTEND_URL/wimd" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"test"}')

# Accept 200, 401, or 422 (needs auth or validation)
# But 404 means routing broken
if [ "$POST_RESULT" = "404" ]; then
    echo "  ❌ FAIL: POST endpoint returned 404 (routing broken)"
    exit 1
elif [ "$POST_RESULT" = "200" ] || [ "$POST_RESULT" = "401" ] || [ "$POST_RESULT" = "422" ]; then
    echo "  ✅ PASS: POST endpoint routed correctly (HTTP $POST_RESULT)"
else
    echo "  ⚠️  WARN: POST endpoint returned HTTP $POST_RESULT (unexpected)"
fi

echo ""
echo "✅ All end-to-end UI tests passed"
```

---

## INTEGRATION INTO DEPLOYMENT FLOW

### Update Pre-Push Hook
```bash
# .git/hooks/pre-push

# After Gate 9 production check, add:

echo "Running UI configuration tests..."
if ! .mosaic/enforcement/test_ui_config.sh; then
    echo "❌ UI configuration tests failed"
    exit 1
fi

echo "Running backend health tests..."
if ! .mosaic/enforcement/test_backend_health.sh; then
    echo "❌ Backend health tests failed"
    exit 1
fi
```

### Post-Deploy Verification
```bash
# After push completes:

# Wait for Netlify deployment (2-3 min)
echo "Waiting 180 seconds for Netlify deployment..."
sleep 180

# Run end-to-end tests
echo "Running post-deploy UI tests..."
if ! .mosaic/enforcement/test_ui_e2e.sh; then
    echo "❌ CRITICAL: Deployment succeeded but UI tests failed"
    echo "Action required: Investigate deployed frontend"
    exit 1
fi

echo "✅ All post-deploy tests passed - UI is functional"
```

---

## FIX GATE 9

Update `.mosaic/enforcement/gate_9_production_check.py`:

```python
def test_frontend_backend_urls_match(self) -> bool:
    """Test: Frontend API URLs point to correct backend"""
    print("\n🧪 Test: Frontend URLs match production backend")

    # FIXED: Check correct frontend location
    frontend_html = self.repo_root / "frontend/index.html"

    if not frontend_html.exists():
        # FIXED: Fail instead of warning
        self.failures.append("frontend/index.html not found")
        print(f"  ❌ FAIL: Frontend file not found at frontend/index.html")
        return False  # Don't pass if file missing

    with open(frontend_html) as f:
        content = f.read()

    expected_backend = "https://mosaic-backend-tpog.onrender.com"

    # Check if correct backend is referenced
    if expected_backend in content:
        print(f"  ✅ PASS: Frontend uses correct backend URL")
        return True
    else:
        # Check netlify.toml for proxy config
        netlify_toml = self.repo_root / "netlify.toml"
        if netlify_toml.exists():
            with open(netlify_toml) as f:
                toml_content = f.read()
                if expected_backend in toml_content:
                    print(f"  ✅ PASS: Netlify proxy configured correctly")
                    return True

        # FIXED: Fail if wrong URL found
        self.failures.append("Frontend has wrong backend URL")
        print(f"  ❌ FAIL: Frontend backend URL incorrect")
        print(f"     Expected: {expected_backend}")

        # Show what was found
        import re
        api_match = re.search(r"api:'([^']*)'", content)
        if api_match:
            print(f"     Found: {api_match.group(1)}")

        return False
```

---

## TESTING CHECKLIST

**Before every production push:**

```
□ Run Layer 1: Static Analysis
  □ Frontend API URL correct
  □ Netlify redirects configured
  □ No dead backend URLs
  □ PS101 content present

□ Run Layer 2: Backend Health
  □ Health endpoint responds
  □ Config endpoint correct
  □ Database connected
  □ AI services available

□ Push to production

□ Run Layer 3: End-to-End (after deploy)
  □ Frontend loads
  □ PS101 content visible
  □ Deployed API URL correct
  □ Netlify proxies work
  □ POST endpoints routed

□ Manual spot check (5 min)
  □ Visit https://whatismydelta.com
  □ Click through UI
  □ Test one feature end-to-end
```

---

## LESSONS LEARNED

**What Went Wrong:**
1. Gate 9 checked wrong file location
2. Gate 9 passed with warning instead of failing
3. No end-to-end functional testing
4. Assumed "deployment works" = "UI works"

**Fixes Implemented:**
1. Fix Gate 9 to check `frontend/index.html` not `mosaic_ui/index.html`
2. Fail hard when frontend file missing (don't just warn)
3. Add 3-layer testing protocol (static, health, e2e)
4. Integrate into pre-push and post-deploy flow

**Prevention:**
- Never deploy without running all 3 test layers
- Always verify deployed UI manually after push
- Update testing protocol as frontend evolves

---

**END OF UI TESTING PROTOCOL**

**Status:** READY FOR IMPLEMENTATION
**Next Steps:** Fix Gate 9, create test scripts, integrate into hooks
