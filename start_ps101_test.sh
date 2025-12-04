#!/bin/bash
# Start PS101 Testing Environment
# Launches local server + Chromium with CodexCapture

echo "🚀 Starting PS101 Testing Environment"
echo "======================================"

# 1. Start local server
echo ""
echo "1. Starting local development server..."
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
python3 local_dev_server.py &
SERVER_PID=$!
echo "   ✅ Server started (PID: $SERVER_PID) on http://localhost:3000"
sleep 2

# 2. Launch Chromium with CodexCapture
echo ""
echo "2. Launching Chromium with CodexCapture..."
/Applications/Chromium.app/Contents/MacOS/Chromium \
  --user-data-dir=/Users/damianseguin/CodexChromiumProfile \
  --load-extension=/Users/damianseguin/CodexTools/CodexCapture \
  http://localhost:3000 &

echo "   ✅ Chromium launched"

# 3. Instructions
echo ""
echo "======================================"
echo "✅ Testing environment ready!"
echo ""
echo "CodexCapture Instructions:"
echo "  • Keyboard shortcut: Command+Shift+Y"
echo "  • Captures save to: ~/Downloads/CodexAgentCaptures/"
echo ""
echo "Test PS101 flow:"
echo "  1. Type in textarea - test character counter"
echo "  2. Click 'Next Prompt' - test advancement"
echo "  3. Check prompt counter values"
echo "  4. Complete all 10 steps"
echo ""
echo "Press Command+Shift+Y to capture diagnostics at each step"
echo ""
echo "To stop server: kill $SERVER_PID"
echo "======================================"
