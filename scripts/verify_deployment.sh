#!/bin/bash
# Consolidated Deployment Verification Script
#
# This script provides a single source of truth for verifying both local file
# integrity and live deployment status. It combines and improves checks from
# verify_critical_features.sh and verify_live_deployment.sh,
# superseding those legacy scripts with a single authority.

set -euo pipefail

echo "🔍 Consolidated Deployment Verification"
echo "======================================"
echo ""

ERRORS=0
CRITICAL_ERRORS=0
BASE_URL="${DEPLOY_URL:-https://whatismydelta.com}"

# --- Local File Integrity Checks ---

echo "--- Verifying Local Files ---"

# 1. Authentication UI Check (Local)
echo "Checking for Authentication UI in local files..."
AUTH_COUNT=0
for file in frontend/index.html mosaic_ui/index.html; do
  if [[ -f "$file" ]]; then
    # Check for the presence of the auth modal structure
    COUNT=$(grep -c "authModal\|LOGIN/REGISTER MODAL\|loginForm" "$file" 2>/dev/null || echo 0)
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
  if [[ -f "$file" ]]; then
    COUNT=$(grep -c "PS101State\|ps101-" "$file" 2>/dev/null || echo 0)
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
  if [[ -f "$file" ]]; then
    # Correctly check for the relative path assignment
    if grep -q "API_BASE = '/wimd'" "$file" 2>/dev/null; then
      API_BASE_CORRECT=1
      break # Found it, no need to check other files
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


# --- Live Deployment Checks ---

echo "--- Verifying Live Deployment ($BASE_URL) ---"

# 4. Site Reachability
echo "Checking site reachability..."
if ! curl -s -f -m 10 "$BASE_URL" > /dev/null; then
  echo "❌ CRITICAL: Live site is unreachable or returned an error."
  CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
else
  echo "✅ Live site is reachable."
fi
echo ""

# 5. Live Authentication UI Check
echo "Checking for Authentication UI on live site..."
# NOTE: This check is fragile as curl does not execute JavaScript.
# It only verifies if the auth modal is present in the initial HTML payload.
LIVE_AUTH_COUNT=$(curl -s -m 10 "$BASE_URL" | grep -c "authModal" || echo "0")
LIVE_AUTH_COUNT=$(echo "$LIVE_AUTH_COUNT" | tr -d '\r\n')
if [[ ! "$LIVE_AUTH_COUNT" =~ ^[0-9]+$ ]]; then
  LIVE_AUTH_COUNT=0
fi

if [ "$LIVE_AUTH_COUNT" -eq 0 ]; then
  echo "⚠️  WARNING: Authentication UI (authModal) not found on live site. This may be a false negative if the UI is rendered by JavaScript."
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Authentication UI present on live site ($LIVE_AUTH_COUNT references)."
fi
echo ""

# 6. Live PS101 Flow Check
echo "Checking for PS101 flow on live site..."
LIVE_PS101_COUNT=$(curl -s -m 10 "$BASE_URL" | grep -c "PS101State" || echo "0")
LIVE_PS101_COUNT=$(echo "$LIVE_PS101_COUNT" | tr -d '\r\n')
if [[ ! "$LIVE_PS101_COUNT" =~ ^[0-9]+$ ]]; then
  LIVE_PS101_COUNT=0
fi

if [ "$LIVE_PS101_COUNT" -eq 0 ]; then
  echo "❌ CRITICAL: PS101 flow (PS101State) not found on live site."
  CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
else
  echo "✅ PS101 flow present on live site ($LIVE_PS101_COUNT references)."
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
