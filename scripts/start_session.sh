#!/bin/bash
# WIMD Railway Deploy - Session Start (Web Interface Default)
# Simplified initialization - no mode detection required

PROJECT_ROOT="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
cd "$PROJECT_ROOT" || exit 1

echo "################################################################"
echo "## LOADING CORE GOVERNANCE - NON-NEGOTIABLE FOR ALL AGENTS    ##"
echo "################################################################"
echo ""
echo "# Mosaic Governance Core v1"
cat Mosaic_Governance_Core_v1.md
echo ""
echo "---"
echo ""
echo "# TEAM_PLAYBOOK_v2.md"
cat TEAM_PLAYBOOK_v2.md
echo ""
echo "---"
echo ""

# Determine which agent is running this (optional parameter)
AGENT_NAME="${1:-claude_web}"  # Default to claude_web (web interface)

# Check for messages in inbox
INBOX_FILE=".ai-agents/queue/${AGENT_NAME}_inbox.txt"
if [ -f "$INBOX_FILE" ]; then
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  📬 YOU HAVE A MESSAGE                                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    cat "$INBOX_FILE"
    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    # Delete the message after reading
    rm "$INBOX_FILE"
fi

echo "# WIMD Railway Deploy - Session Context"
echo ""
echo "**Environment:** claude.ai web interface (default)"
echo ""

# Load project documentation
cat CLAUDE.md
echo ""
echo "---"
echo ""
cat TROUBLESHOOTING_CHECKLIST.md
echo ""

echo "## Session Ready"
echo "- Loaded core governance + project documentation"
echo "- Working directory: $PROJECT_ROOT"
echo ""
