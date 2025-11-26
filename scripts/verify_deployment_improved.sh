#!/bin/bash
# Improved Deployment Verification Script
# Addresses weaknesses in original Gemini plan:
# - Uses Playwright for JS-rendered content verification
# - Single source of truth for all verification
# - Clear error categorization (CRITICAL vs WARNING)
# - Fast fail-fast approach

set -euo pipefail

echo "🔍 Improved Deployment Verification"
echo "======================================"
echo ""

ERRORS=0
CRITICAL_ERRORS=0
BASE_URL="${DEPLOY_URL:-https://whatismydelta.com}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# --- Local File Integrity Checks ---

echo "--- Verifying Local Files ---"

# 1. Authentication UI Check (Local)
echo "Checking for Authentication UI in local files..."
AUTH_COUNT=0
for file in frontend/index.html mosaic_ui/index.html; do
  if [[ -f "$PROJECT_ROOT/$file" ]]; then
    COUNT=$(grep -c "authModal\|LOGIN/REGISTER MODAL\|loginForm" "$PROJECT_ROOT/$file" 2>/dev/null || echo 0)
    AUTH_COUNT=$((AUTH_COUNT + COUNT))
  fi
done

if [[ $AUTH_COUNT -eq 0 ]]; then
  echo "❌ CRITICAL: Authentication UI missing from local files."
  CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
else
  echo "✅ Authentication UI present in local files ($AUTH_COUNT occurrences)."
fi
echo ""

# 2. PS101 Flow Check (Local)
echo "Checking for PS101 flow in local files..."
PS101_COUNT=0
for file in frontend/index.html mosaic_ui/index.html; do
  if [[ -f "$PROJECT_ROOT/$file" ]]; then
    COUNT=$(grep -c "PS101State\|ps101-" "$PROJECT_ROOT/$file" 2>/dev/null || echo 0)
    PS101_COUNT=$((PS101_COUNT + COUNT))
  fi
done

if [[ $PS101_COUNT -eq 0 ]]; then
  echo "❌ CRITICAL: PS101 flow missing from local files."
  CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
else
  echo "✅ PS101 flow present in local files ($PS101_COUNT references)."
fi
echo ""

# 3. API Configuration Check (Local)
echo "Checking API_BASE configuration in local files..."
API_BASE_CORRECT=0
for file in frontend/index.html mosaic_ui/index.html; do
  if [[ -f "$PROJECT_ROOT/$file" ]]; then
    if grep -q "API_BASE = '/wimd'" "$PROJECT_ROOT/$file" 2>/dev/null; then
      API_BASE_CORRECT=1
      break
    fi
  fi
done

if [[ $API_BASE_CORRECT -eq 0 ]]; then
  echo "⚠️  WARNING: API_BASE is not set to the expected relative path '/wimd' in local files."
  ERRORS=$((ERRORS + 1))
else
  echo "✅ API_BASE is correctly configured to a relative path in local files."
fi
echo ""

# 4. Check for JavaScript function ordering issues
echo "Checking for common JavaScript ordering issues..."
JS_ORDER_ISSUES=0
for file in frontend/index.html mosaic_ui/index.html; do
  if [[ -f "$PROJECT_ROOT/$file" ]]; then
    # Check if bindPS101TextareaInput is called before definition
    if grep -n "bindPS101TextareaInput()" "$PROJECT_ROOT/$file" | head -1 | cut -d: -f1 | \
       xargs -I {} bash -c "LINE={}; grep -n 'function bindPS101TextareaInput' '$PROJECT_ROOT/$file' | head -1 | cut -d: -f1 | xargs -I @ bash -c 'test \$LINE -lt @ && exit 1 || exit 0'" 2>/dev/null; then
      JS_ORDER_ISSUES=$((JS_ORDER_ISSUES + 1))
    fi
  fi
done

if [[ $JS_ORDER_ISSUES -gt 0 ]]; then
  echo "⚠️  WARNING: Potential JavaScript function ordering issues detected."
  ERRORS=$((ERRORS + 1))
else
  echo "✅ No obvious JavaScript ordering issues detected."
fi
echo ""

# --- Live Deployment Checks ---

echo "--- Verifying Live Deployment ($BASE_URL) ---"

# 5. Site Reachability
echo "Checking site reachability..."
if ! curl -s -f -m 10 "$BASE_URL" > /dev/null; then
  echo "❌ CRITICAL: Live site is unreachable or returned an error."
  CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
  SITE_REACHABLE=0
else
  echo "✅ Live site is reachable."
  SITE_REACHABLE=1
fi
echo ""

# 6. Enhanced Live Auth/PS101 Check using Playwright
if [[ $SITE_REACHABLE -eq 1 ]]; then
  echo "Checking live site with Playwright (renders JavaScript)..."

  # Create temporary Playwright verification script
  cat > /tmp/verify_live_site.js << 'EOF'
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  try {
    await page.goto(process.env.BASE_URL || 'https://whatismydelta.com', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    // Wait for page to fully render
    await page.waitForTimeout(2000);

    // Check for authentication UI
    const authModal = await page.$('#authModal, .auth-modal, [id*="auth"]');
    const loginForm = await page.$('#loginForm, .login-form, [id*="login"]');

    // Check for PS101 flow
    const ps101Elements = await page.$$('[class*="ps101"], [id*="ps101"]');

    const results = {
      authPresent: !!(authModal || loginForm),
      ps101Present: ps101Elements.length > 0,
      ps101Count: ps101Elements.length
    };

    console.log(JSON.stringify(results));
    await browser.close();
    process.exit(0);

  } catch (error) {
    console.error(JSON.stringify({ error: error.message }));
    await browser.close();
    process.exit(1);
  }
})();
EOF

  # Run Playwright check (only if Node.js and Playwright are available)
  if command -v node &> /dev/null; then
    if node -e "require('playwright');" >/dev/null 2>&1; then
      PLAYWRIGHT_RESULT=$(cd "$PROJECT_ROOT" && BASE_URL="$BASE_URL" node /tmp/verify_live_site.js 2>&1 || echo '{"error":"Playwright check failed"}')

      # Parse results (only trust structured success output)
      if echo "$PLAYWRIGHT_RESULT" | grep -q '"authPresent":true'; then
        echo "✅ Authentication UI present on live site (verified with JavaScript rendering)."
      else
        echo "⚠️  WARNING: Authentication UI not detected on live site."
        ERRORS=$((ERRORS + 1))
      fi

      if echo "$PLAYWRIGHT_RESULT" | grep -q '"ps101Present":true'; then
        PS101_LIVE_COUNT=$(echo "$PLAYWRIGHT_RESULT" | grep -o '"ps101Count":[0-9]*' | cut -d: -f2)
        echo "✅ PS101 flow present on live site ($PS101_LIVE_COUNT elements)."
      else
        echo "❌ CRITICAL: PS101 flow not found on live site."
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
      fi
    else
      echo "⚠️  WARNING: Playwright not available, skipping Playwright verification."
      echo "   Falling back to basic curl check..."

      # Fallback to curl
      LIVE_AUTH_COUNT=$(curl -s -m 10 "$BASE_URL" | grep -c "authModal\|loginForm" || echo "0")
      LIVE_PS101_COUNT=$(curl -s -m 10 "$BASE_URL" | grep -c "PS101State\|ps101-" || echo "0")

      if [ "$LIVE_AUTH_COUNT" -gt 0 ]; then
        echo "✅ Authentication UI present (curl fallback: $LIVE_AUTH_COUNT references)."
      else
        echo "⚠️  WARNING: Auth UI not found (curl limitation - may be false negative)."
        ERRORS=$((ERRORS + 1))
      fi

      if [ "$LIVE_PS101_COUNT" -gt 0 ]; then
        echo "✅ PS101 flow present (curl fallback: $LIVE_PS101_COUNT references)."
      else
        echo "❌ CRITICAL: PS101 flow not found on live site."
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
      fi
    fi
  else
    echo "⚠️  WARNING: Node.js not available, skipping Playwright verification."
    echo "   Falling back to basic curl check..."

    # Fallback to curl
    LIVE_AUTH_COUNT=$(curl -s -m 10 "$BASE_URL" | grep -c "authModal\|loginForm" || echo "0")
    LIVE_PS101_COUNT=$(curl -s -m 10 "$BASE_URL" | grep -c "PS101State\|ps101-" || echo "0")

    if [ "$LIVE_AUTH_COUNT" -gt 0 ]; then
      echo "✅ Authentication UI present (curl fallback: $LIVE_AUTH_COUNT references)."
    else
      echo "⚠️  WARNING: Auth UI not found (curl limitation - may be false negative)."
      ERRORS=$((ERRORS + 1))
    fi

    if [ "$LIVE_PS101_COUNT" -gt 0 ]; then
      echo "✅ PS101 flow present (curl fallback: $LIVE_PS101_COUNT references)."
    else
      echo "❌ CRITICAL: PS101 flow not found on live site."
      CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi
  fi

  # Cleanup
  rm -f /tmp/verify_live_site.js
else
  echo "⚠️  Skipping live content checks (site unreachable)."
fi
echo ""

# --- Summary ---
echo "======================================"
if [ $CRITICAL_ERRORS -gt 0 ]; then
  echo "❌ VERIFICATION FAILED: $CRITICAL_ERRORS critical error(s) found."
  exit 1
elif [ $ERRORS -gt 0 ]; then
  echo "⚠️  VERIFICATION PASSED WITH WARNINGS: $ERRORS warning(s) found."
  exit 0
else
  echo "✅ All checks passed successfully."
  exit 0
fi
