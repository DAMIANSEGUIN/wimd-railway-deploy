#!/bin/bash
# Start Gemini Session - Ensures correct working directory

# Project directory
PROJECT_DIR="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "═══════════════════════════════════════════════════════════════════"
echo "           GEMINI SESSION STARTER"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Change to project directory
cd "$PROJECT_DIR" || {
    echo "❌ Error: Could not change to project directory"
    echo "   Expected: $PROJECT_DIR"
    exit 1
}

echo -e "${GREEN}✓${NC} Working directory set to:"
echo "   $PWD"
echo ""

# Verify we're in the right place
if [ ! -f "scripts/status.sh" ]; then
    echo -e "${YELLOW}⚠${NC}  Warning: scripts/status.sh not found"
    echo "   Are you sure this is the right directory?"
    exit 1
fi

echo -e "${GREEN}✓${NC} Project directory verified"
echo ""

# Show what to tell Gemini
echo "═══════════════════════════════════════════════════════════════════"
echo "COPY THIS TO GEMINI (PASTE AS FIRST MESSAGE):"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
cat << 'EOF'
Set working directory to:
/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

Then run this command:
./scripts/status.sh

Do NOT search files outside this directory.
EOF
echo ""
echo "═══════════════════════════════════════════════════════════════════"
