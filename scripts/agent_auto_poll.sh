#!/bin/bash
# Auto-poll for messages and execute responses autonomously
# Run this when starting an agent session - it runs in background

AGENT_NAME="${AI_AGENT_NAME:-Claude-Code}"
POLL_INTERVAL="${POLL_INTERVAL:-10}"  # seconds
BROKER_URL="${AGENT_BROKER_URL:-http://localhost:8765}"

echo "🤖 Starting auto-poll for $AGENT_NAME (checking every ${POLL_INTERVAL}s)"
echo "   Press Ctrl+C to stop"

while true; do
    # Check for new messages
    MESSAGES=$(curl -s "$BROKER_URL/messages/$AGENT_NAME" 2>/dev/null)

    if [ $? -eq 0 ] && [ "$MESSAGES" != "[]" ]; then
        MSG_COUNT=$(echo "$MESSAGES" | jq 'length' 2>/dev/null || echo 0)

        if [ "$MSG_COUNT" -gt 0 ]; then
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📨 [$(date +%H:%M:%S)] New message(s) detected!"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

            # Display messages
            echo "$MESSAGES" | jq -r '.[] | "From: \(.from_agent)\nType: \(.message_type)\nBody: \(.body)\nID: \(.id)\n"'

            # Auto-acknowledge (mark as read)
            echo "$MESSAGES" | jq -r '.[].id' | while read msg_id; do
                curl -s -X POST "$BROKER_URL/messages/$msg_id/ack" > /dev/null
            done

            echo "✅ Messages retrieved and acknowledged"
            echo ""

            # IMPORTANT: This is where you'd trigger the agent to process
            # For now, just notify - agent needs to manually handle
            # In future: could write to a file that agent reads, or use IPC
        fi
    fi

    sleep "$POLL_INTERVAL"
done
