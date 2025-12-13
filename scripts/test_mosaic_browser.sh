#!/bin/bash
# Mosaic Browser Testing Script
# Opens Chrome with CodexCapture extension for user testing

set -e

CODEX_PATH="/Users/damianseguin/CodexTools/CodexCapture"
MOSAIC_URL="https://whatismydelta.com"

echo "=========================================="
echo "Mosaic Browser Testing"
echo "=========================================="
echo ""
echo "Opening Chrome with CodexCapture extension..."
echo "URL: $MOSAIC_URL"
echo ""
echo "Testing Instructions:"
echo "1. Register new account: test+mosaic_$(date +%s)@example.com"
echo "2. Password: TestPass123!"
echo "3. Complete PS101 flow (10 questions)"
echo "4. Test chat: 'What should I do next?'"
echo ""
echo "CodexCapture will record all interactions."
echo ""

# Launch Chrome with CodexCapture
open -a "Google Chrome" --args \
  --load-extension="$CODEX_PATH" \
  --new-window \
  "$MOSAIC_URL"

echo "✅ Chrome launched with CodexCapture"
echo ""
echo "Full testing guide: .ai-agents/validation/MOSAIC_MVP_TESTING_GUIDE.md"
