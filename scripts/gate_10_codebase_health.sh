#!/bin/bash
# GATE 10: Codebase Health Audit
# Verifies no duplicate implementations exist
# Created: 2026-01-27 (CODEBASE_HEALTH_AUDIT implementation)

set -e

VIOLATIONS=0

echo "🔍 GATE 10: CODEBASE HEALTH AUDIT"
echo "============================================================"
echo ""

# Check 1: Single API directory
echo "📋 Check 1: Single Source of Truth (API)"
if [ -d "api" ] && [ -d "backend/api" ]; then
  echo "  ❌ VIOLATION: Dual API directories exist (api/ and backend/api/)"
  echo "     Risk: Python import confusion, deployment ambiguity"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  if [ -d "backend/api" ]; then
    echo "  ✅ PASS: Single API directory (backend/api/)"
  elif [ -d "api" ]; then
    echo "  ✅ PASS: Single API directory (api/)"
  else
    echo "  ❌ VIOLATION: No API directory found"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
fi
echo ""

# Check 2: No duplicate storage implementations
echo "📋 Check 2: Storage Layer Consistency"
STORAGE_COUNT=$(find . -name "storage.py" -not -path "*/archive/*" -not -path "*/.venv/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l | tr -d ' ')
if [ "$STORAGE_COUNT" -gt 1 ]; then
  echo "  ❌ VIOLATION: Multiple storage.py files found ($STORAGE_COUNT)"
  find . -name "storage.py" -not -path "*/archive/*" -not -path "*/.venv/*" -not -path "*/node_modules/*" 2>/dev/null | sed 's/^/     /'
  echo "     Risk: Wrong import = SQLite fallback = data loss"
  VIOLATIONS=$((VIOLATIONS + 1))
elif [ "$STORAGE_COUNT" -eq 1 ]; then
  STORAGE_PATH=$(find . -name "storage.py" -not -path "*/archive/*" -not -path "*/.venv/*" -not -path "*/node_modules/*" 2>/dev/null)
  echo "  ✅ PASS: Single storage.py implementation ($STORAGE_PATH)"
else
  echo "  ❌ VIOLATION: No storage.py found"
  VIOLATIONS=$((VIOLATIONS + 1))
fi
echo ""

# Check 3: Entry point matches authority map
echo "📋 Check 3: Entry Point Authority"
if [ -f ".mosaic/authority_map.json" ]; then
  BACKEND_ROOT=$(jq -r '.services[] | select(.name=="mosaic-backend") | .root_dir' .mosaic/authority_map.json 2>/dev/null || echo "")

  if [ -n "$BACKEND_ROOT" ]; then
    ENTRY_POINT="$BACKEND_ROOT/api/index.py"
    if [ -f "$ENTRY_POINT" ]; then
      echo "  ✅ PASS: Entry point exists at $ENTRY_POINT"
    else
      echo "  ❌ VIOLATION: Entry point missing at $ENTRY_POINT"
      echo "     Authority map specifies root_dir: $BACKEND_ROOT"
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  else
    echo "  ⚠️  WARNING: Could not read backend root_dir from authority_map.json"
  fi
else
  echo "  ⚠️  WARNING: authority_map.json not found"
fi
echo ""

# Check 4: No dev server files in root
echo "📋 Check 4: No Development Servers in Root"
DEV_SERVERS=("minimal_server.py" "local_dev_server.py" "minimal_app.py")
DEV_FOUND=0
for server in "${DEV_SERVERS[@]}"; do
  if [ -f "$server" ] || [ -f "backend/$server" ]; then
    echo "  ❌ VIOLATION: Development server found: $server"
    echo "     Risk: Could be accidentally deployed instead of production app"
    VIOLATIONS=$((VIOLATIONS + 1))
    DEV_FOUND=1
  fi
done
if [ "$DEV_FOUND" -eq 0 ]; then
  echo "  ✅ PASS: No development servers in root or backend/"
fi
echo ""

# Summary
echo "============================================================"
echo "📊 GATE 10 RESULTS"
echo "============================================================"
echo ""

# Exit with violation count
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "❌ Gate 10 FAILED: $VIOLATIONS violation(s) detected"
  echo ""
  echo "These violations create deployment ambiguity and risk:"
  echo "  - Wrong code version deployed"
  echo "  - Data loss from SQLite fallback"
  echo "  - Import resolution errors"
  echo ""
  echo "Fix violations before committing. See: archive/ for cleanup guidance"
  echo ""
  exit 1
else
  echo "✅ Gate 10 PASSED: Codebase health verified"
  echo ""
  echo "All checks passed:"
  echo "  - Single API directory"
  echo "  - Single storage implementation"
  echo "  - Entry point matches authority map"
  echo "  - No dev servers in production paths"
  echo ""
fi
