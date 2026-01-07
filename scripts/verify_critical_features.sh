#!/bin/bash
# verify_critical_features.sh
# Verifies critical features exist in codebase before deployment
# Created: 2026-01-07
# Usage: ./scripts/verify_critical_features.sh

set -e

echo "🔍 Verifying Critical Features..."
echo ""

ERRORS=0

# Check 1: Authentication UI components
echo "📋 Checking Authentication UI..."
AUTH_MODAL=$(grep -r "authModal\|loginForm\|registerForm" mosaic_ui/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$AUTH_MODAL" -gt 0 ]; then
    echo "   ✅ Authentication UI: $AUTH_MODAL references found"
else
    echo "   ❌ Authentication UI: NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

# Check 2: PS101 v2 flow
echo "📋 Checking PS101 v2 flow..."
PS101_STATE=$(grep -r "PS101State\|ps101_steps" api/ mosaic_ui/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$PS101_STATE" -gt 0 ]; then
    echo "   ✅ PS101 v2 flow: $PS101_STATE references found"
else
    echo "   ❌ PS101 v2 flow: NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

# Check 3: API_BASE configuration (relative paths)
echo "📋 Checking API_BASE configuration..."
if grep -q "API_BASE.*=.*['\"]\\s*['\"]" mosaic_ui/index.html 2>/dev/null || \
   grep -q "apiBase.*:.*['\"]\\s*['\"]" mosaic_ui/index.html 2>/dev/null; then
    echo "   ✅ API_BASE: Relative paths configured"
else
    echo "   ⚠️  API_BASE: Configuration not found (may use absolute URL)"
fi

# Check 4: Chat interface
echo "📋 Checking Chat interface..."
CHAT_UI=$(grep -r "chatContainer\|sendMessage\|coach" mosaic_ui/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$CHAT_UI" -gt 0 ]; then
    echo "   ✅ Chat interface: $CHAT_UI references found"
else
    echo "   ❌ Chat interface: NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

# Check 5: File upload functionality
echo "📋 Checking File upload functionality..."
FILE_UPLOAD=$(grep -r "file.*upload\|multipart\|FileReader" mosaic_ui/ api/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$FILE_UPLOAD" -gt 0 ]; then
    echo "   ✅ File upload: $FILE_UPLOAD references found"
else
    echo "   ❌ File upload: NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

# Check 6: Backend health endpoint
echo "📋 Checking Backend health endpoint..."
if [ -f "api/index.py" ]; then
    if grep -q "@app.get.*['\"/]health['\"]" api/index.py 2>/dev/null; then
        echo "   ✅ Health endpoint: Found in api/index.py"
    else
        echo "   ❌ Health endpoint: NOT FOUND"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "   ❌ api/index.py: NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All critical features verified successfully"
    exit 0
else
    echo "❌ Verification failed: $ERRORS critical feature(s) missing"
    exit 1
fi
