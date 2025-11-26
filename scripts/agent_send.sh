#!/bin/bash
# Send message to another agent via broker

BROKER_URL="${AGENT_BROKER_URL:-http://localhost:8765}"
FROM_AGENT="${AI_AGENT_NAME:-Claude-Code}"
TO_AGENT="$1"
MESSAGE_TYPE="$2"
MESSAGE_BODY="$3"

if [ -z "$TO_AGENT" ] || [ -z "$MESSAGE_TYPE" ] || [ -z "$MESSAGE_BODY" ]; then
    echo "Usage: $0 <to_agent> <message_type> <message_body>"
    echo "Example: $0 Gemini SQL_QUERY 'Run query from DIAGNOSTIC file'"
    exit 1
fi

# Check if broker is running
if ! curl -s -f "$BROKER_URL/health" > /dev/null 2>&1; then
    echo "❌ Broker not running. Start it with: python3 scripts/agent_broker.py"
    exit 1
fi

# Send message
RESPONSE=$(curl -s -X POST "$BROKER_URL/messages" \
    -H "Content-Type: application/json" \
    -d @- <<EOF
{
  "from_agent": "$FROM_AGENT",
  "to_agent": "$TO_AGENT",
  "message_type": "$MESSAGE_TYPE",
  "body": "$MESSAGE_BODY"
}
EOF
)

if [ $? -eq 0 ]; then
    MSG_ID=$(echo "$RESPONSE" | jq -r '.id')
    echo "✅ Message sent to $TO_AGENT (ID: $MSG_ID)"
else
    echo "❌ Failed to send message"
    exit 1
fi
