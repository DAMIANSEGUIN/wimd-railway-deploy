#!/bin/bash
# One-shot script to configure Gemini to always start in WIMD project directory

set -e

PROJECT_DIR="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
SHELL_CONFIG="$HOME/.zshrc"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         CONFIGURE GEMINI STARTUP DIRECTORY                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Project directory not found: $PROJECT_DIR"
    exit 1
fi

echo "📁 Project directory: $PROJECT_DIR"
echo "⚙️  Shell config: $SHELL_CONFIG"
echo ""

# Check if already configured
if grep -q "cd $PROJECT_DIR" "$SHELL_CONFIG" 2>/dev/null; then
    echo "✅ Already configured - found in $SHELL_CONFIG"
    echo ""
    echo "Current line:"
    grep "cd $PROJECT_DIR" "$SHELL_CONFIG"
    echo ""
    echo "No changes needed."
else
    echo "📝 Adding startup directory to $SHELL_CONFIG..."
    echo "" >> "$SHELL_CONFIG"
    echo "# Auto-navigate to WIMD project for Gemini (added $(date +%Y-%m-%d))" >> "$SHELL_CONFIG"
    echo "cd $PROJECT_DIR" >> "$SHELL_CONFIG"
    echo "" >> "$SHELL_CONFIG"
    echo "✅ Configuration added!"
    echo ""
    echo "Added lines:"
    tail -3 "$SHELL_CONFIG"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next time you open a terminal (or Gemini session), you'll start in:"
echo "$PROJECT_DIR"
echo ""
echo "To test now, run: source $SHELL_CONFIG"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      SETUP COMPLETE                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
