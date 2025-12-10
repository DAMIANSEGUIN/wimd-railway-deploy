#!/bin/bash
# WIMD Railway Deploy - MCP-Enabled Session Start
# Feature-flagged: Uses summaries if MCP enabled, full docs otherwise

# Determine which agent is running this (optional parameter)
AGENT_NAME="${1:-claude_code}"  # Default to claude_code if not specified

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

# Check gate status for this agent
echo "# Checking MCP Gate Status..."
python3 .ai-agents/scripts/check_gates.py "$AGENT_NAME" 2>&1
GATE_STATUS=$?
echo ""

# Load feature flags
MCP_ENABLED=$(python3 -c "import json; print(json.load(open('.ai-agents/config/feature_flags.json'))['flags'].get('MCP_ENABLED', False))" 2>/dev/null || echo "False")

echo "# WIMD Railway Deploy - Session Context"
echo ""

if [ "$MCP_ENABLED" = "True" ]; then
    echo "**Mode:** MCP Enabled (Summaries + On-Demand Retrieval)"
    echo ""

    # Load summaries (4.9KB total)
    cat .ai-agents/session_context/GOVERNANCE_SUMMARY.md
    echo ""
    echo "---"
    echo ""
    cat .ai-agents/session_context/TROUBLESHOOTING_SUMMARY.md
    echo ""
    echo "---"
    echo ""
    cat .ai-agents/session_context/RETRIEVAL_TRIGGERS.md
    echo ""
    echo "## Session Ready (MCP Mode)"
    echo "- Loaded summaries (4.9KB vs 30KB full docs)"
    echo "- Full docs will be retrieved automatically when triggered"
    echo "- To disable MCP: Set MCP_ENABLED=false in .ai-agents/config/feature_flags.json"

else
    echo "**Mode:** Standard (Full Documents)"
    echo ""

    # Load full docs (30.9KB total)
    cat CLAUDE.md
    echo ""
    echo "---"
    echo ""
    cat TROUBLESHOOTING_CHECKLIST.md
    echo ""
    echo "## Session Ready (Standard Mode)"
    echo "- Loaded full documentation (30KB)"
    echo "- To enable MCP: Set MCP_ENABLED=true in .ai-agents/config/feature_flags.json"
fi

echo ""
