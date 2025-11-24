#!/bin/bash
# One-shot script to install jq and test the handoff system

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           INSTALL JQ & TEST HANDOFF SYSTEM                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if jq is already installed
if command -v jq &> /dev/null; then
    echo "✅ jq is already installed: $(jq --version)"
else
    echo "📦 Installing jq..."
    brew install jq
    echo "✅ jq installed: $(jq --version)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing CURRENT_WORK.json parsing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "CURRENT_WORK.json" ]; then
    echo "📄 Found CURRENT_WORK.json"
    echo ""
    echo "Task: $(jq -r '.task.title' CURRENT_WORK.json)"
    echo "Next Action: $(jq -r '.task.next_action' CURRENT_WORK.json)"
    echo "Last Agent: $(jq -r '.agent' CURRENT_WORK.json)"
    echo ""
else
    echo "⚠️  No CURRENT_WORK.json found (this is expected on first run)"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Running status.sh to test full system"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./scripts/status.sh

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      TEST COMPLETE                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ If you saw the CURRENT WORK section above, the system works!"
echo ""
echo "Next steps:"
echo "  1. Review AI_TEAM_METHODOLOGY.md to understand the approach"
echo "  2. Decide if you want to commit these changes"
echo "  3. Test session_end.sh when ready (requires interactive input)"
echo ""
