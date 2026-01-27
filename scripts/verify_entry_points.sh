#!/bin/bash
# verify_entry_points.sh
# Validates deployment entry points match authority map
# Created: 2026-01-27 (GATE_10 implementation)

set -e

echo "🔍 Verifying Entry Points..."
echo ""

# Check authority_map
BACKEND_ROOT=$(jq -r '.services[] | select(.name=="mosaic-backend") | .root_dir' .mosaic/authority_map.json)
echo "Authority Map backend root: $BACKEND_ROOT"

# Check render.yaml
if [ -f "render.yaml" ]; then
  RENDER_ROOT=$(grep "rootDir:" render.yaml | awk '{print $2}')
  echo "Render rootDir: $RENDER_ROOT"

  if [ "$BACKEND_ROOT" != "$RENDER_ROOT" ]; then
    echo "❌ MISMATCH: Authority map says '$BACKEND_ROOT' but render.yaml says '$RENDER_ROOT'"
    exit 1
  fi
fi

# Verify entry point exists
ENTRY_POINT="$BACKEND_ROOT/api/index.py"
if [ -f "$ENTRY_POINT" ]; then
  echo "✅ Entry point exists: $ENTRY_POINT"
else
  echo "❌ Entry point missing: $ENTRY_POINT"
  exit 1
fi

# Verify start command in render.yaml
if [ -f "render.yaml" ]; then
  START_CMD=$(grep "startCommand:" render.yaml | cut -d: -f2-)
  echo "Start command: $START_CMD"

  if echo "$START_CMD" | grep -q "api.index:app"; then
    echo "✅ Start command references api.index:app"
  else
    echo "⚠️  Start command doesn't reference api.index:app"
  fi
fi

echo ""
echo "✅ Entry point validation passed"
