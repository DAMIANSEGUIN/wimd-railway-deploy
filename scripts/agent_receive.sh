#!/bin/bash
# Check for messages from other agents via broker

BROKER_URL="${AGENT_BROKER_URL:-http://localhost:8765}"
AGENT_NAME="${AI_AGENT_NAME:-Claude-Code}"

# Check if broker is running
if ! curl -s -f "$BROKER_URL/health" > /dev/null 2>&1; then
    echo "⚠️  Broker not running (messages will use file-based fallback)"
    return 0 2>/dev/null || exit 0
fi

# Get messages
MESSAGES=$(curl -s "$BROKER_URL/messages/$AGENT_NAME")

if [ -z "$MESSAGES" ] || [ "$MESSAGES" = "[]" ]; then
    echo "✅ No pending messages"
    exit 0
fi

echo "📨 You have messages:"
echo ""
echo "$MESSAGES" | jq -r '.[] | "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nFrom: \(.from_agent)\nType: \(.message_type)\nTime: \(.timestamp)\nMessage: \(.body)\nID: \(.id)\n"'

# Ask to acknowledge
echo "To mark as read, run:"
echo "$MESSAGES" | jq -r '.[] | "  curl -X POST '$BROKER_URL'/messages/\(.id)/ack"'
