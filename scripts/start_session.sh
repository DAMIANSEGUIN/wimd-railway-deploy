#!/bin/bash
# Auto-load context for new AI agent session

set -e

echo "🚀 Starting new AI agent session..."
echo ""

# 1. Show latest handoff
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 HANDOFF FROM PREVIOUS AGENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
LATEST_HANDOFF=$(ls -t .ai-agents/handoff_*.json 2>/dev/null | head -1)
if [ -n "$LATEST_HANDOFF" ]; then
    jq -r '
    "From Agent: \(.agent_name // .outgoing_agent // "unknown")
Status: \(.status // "none")
Timestamp: \(.timestamp)
Git: \(.git_state.branch) @ \(.git_state.commit[0:8])
Uncommitted: \(.git_state.uncommitted_changes) files
Notes: \(.notes)"
    ' "$LATEST_HANDOFF"

    # Check for urgent issues
    UNCOMMITTED=$(jq -r '.git_state.uncommitted_changes' "$LATEST_HANDOFF")
    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo ""
        echo "⚠️  WARNING: Previous session left $UNCOMMITTED uncommitted files"
    fi
else
    echo "❌ No handoff found - this may be the first session"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 CRITICAL FILES TO READ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. .ai-agents/START_HERE.md"
echo "2. Recent status files:"
find .ai-agents -name "*.md" -mtime -7 -type f | grep -E "STATUS|SUMMARY|ISSUE" | head -3 | sed 's/^/   - /'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 QUICK HEALTH CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Quick health checks
git status --short | head -5
echo ""

# Check if verification script exists
if [ -x "./scripts/verify_critical_features.sh" ]; then
    echo "✅ Verification script available"
    echo "   Run: ./scripts/verify_critical_features.sh"
else
    echo "⚠️  Verification script not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💬 AGENT-TO-AGENT MESSAGES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check broker first (real-time)
if curl -s -f http://localhost:8765/health > /dev/null 2>&1; then
    echo "🔗 Message broker online - checking for messages..."
    ./scripts/agent_receive.sh
else
    echo "⚠️  Message broker offline - checking file-based messages..."
    ./scripts/check_agent_messages.sh
    echo ""
    echo "💡 For real-time messaging, run: ./scripts/start_broker.sh"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ SESSION READY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Read the files listed above"
echo "2. Run: ./scripts/verify_critical_features.sh"
echo "3. When done, run: ./scripts/end_session.sh 'Your status message here'"
echo ""
