#!/bin/bash
# MCP v1.1 Rollback Script - PANIC BUTTON
# Reverts all MCP changes and restores baseline behavior

set -e  # Exit on error

echo "🚨 MCP v1.1 ROLLBACK INITIATED"
echo "This will revert to pre-MCP baseline state"
echo ""

# Confirm with user
read -p "Are you sure you want to rollback? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Rollback cancelled"
    exit 0
fi

echo ""
echo "Step 1: Disabling all MCP feature flags..."
if [ -f ".ai-agents/config/feature_flags.json" ]; then
    cat > .ai-agents/config/feature_flags.json <<'EOF'
{
  "schema_version": "v1.0",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "flags": {
    "MCP_ENABLED": false,
    "MCP_SESSION_SUMMARIES": false,
    "MCP_RETRIEVAL_TRIGGERS": false,
    "MCP_STRUCTURED_LOGS": false,
    "MCP_BROKER_INTEGRATION": false,
    "MCP_MIRROR_EXPORTS": false
  },
  "notes": {
    "rollback": "All flags disabled by rollback script at $(date)"
  }
}
EOF
    echo "✅ Feature flags disabled"
else
    echo "⚠️  Feature flags file not found (may not be implemented yet)"
fi

echo ""
echo "Step 2: Restoring original start_session.sh..."
if [ -f "scripts/start_session.sh.old" ]; then
    cp scripts/start_session.sh.old scripts/start_session.sh
    echo "✅ Original start_session.sh restored"
elif [ -f ".ai-agents/backups/start_session.sh."* ]; then
    # Find most recent backup
    latest_backup=$(ls -t .ai-agents/backups/start_session.sh.* | head -1)
    cp "$latest_backup" scripts/start_session.sh
    echo "✅ start_session.sh restored from backup: $latest_backup"
else
    echo "⚠️  No backup found for start_session.sh"
    echo "   Original script may not have been modified yet"
fi

echo ""
echo "Step 3: Checking git rollback option..."
if git tag | grep -q "pre-mcp-v1.1-baseline"; then
    echo "Git tag 'pre-mcp-v1.1-baseline' exists"
    echo ""
    echo "To perform full git rollback, run:"
    echo "  git checkout pre-mcp-v1.1-baseline"
    echo ""
    echo "WARNING: This will discard ALL changes since tag was created"
else
    echo "⚠️  Git tag 'pre-mcp-v1.1-baseline' not found"
fi

echo ""
echo "Step 4: Removing MCP-generated files (optional)..."
echo "The following directories contain MCP-generated files:"
echo "  - .ai-agents/session_context/"
echo "  - .ai-agents/sessions/"
echo "  - docs/mcp_exports/"
echo ""
read -p "Remove MCP-generated files? (yes/no): " remove_files

if [ "$remove_files" = "yes" ]; then
    [ -d ".ai-agents/session_context" ] && rm -rf .ai-agents/session_context && echo "  ✅ Removed session_context/"
    [ -d ".ai-agents/sessions" ] && rm -rf .ai-agents/sessions && echo "  ✅ Removed sessions/"
    [ -d "docs/mcp_exports" ] && rm -rf docs/mcp_exports && echo "  ✅ Removed mcp_exports/"
    echo "MCP-generated files removed"
else
    echo "MCP-generated files preserved"
fi

echo ""
echo "Step 5: Verifying session start works..."
if [ -f "scripts/start_session.sh" ]; then
    # Test that script is executable and has basic structure
    if bash -n scripts/start_session.sh 2>/dev/null; then
        echo "✅ start_session.sh syntax valid"
    else
        echo "❌ start_session.sh has syntax errors"
        exit 1
    fi
else
    echo "❌ scripts/start_session.sh not found"
    exit 1
fi

echo ""
echo "✅ ROLLBACK COMPLETE"
echo ""
echo "Summary:"
echo "  - All MCP feature flags disabled"
echo "  - Original scripts restored (if backups existed)"
echo "  - MCP files removed: $remove_files"
echo ""
echo "Next steps:"
echo "  1. Start a new session to verify baseline behavior"
echo "  2. Check logs for any errors"
echo "  3. If issues persist, run: git checkout pre-mcp-v1.1-baseline"
echo ""
echo "Rollback logged to: .ai-agents/rollback_log.txt"

# Log the rollback
mkdir -p .ai-agents
echo "[$(date)] MCP v1.1 rollback executed - flags disabled, scripts restored" >> .ai-agents/rollback_log.txt
