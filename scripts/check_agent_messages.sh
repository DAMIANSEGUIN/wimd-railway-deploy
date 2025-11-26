#!/bin/bash
# Check for agent-to-agent messages (requests and responses)

AGENT_NAME="${AI_AGENT_NAME:-Claude-Code}"

echo "🔍 Checking messages for $AGENT_NAME..."
echo ""

# Check for requests TO this agent
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📨 PENDING REQUESTS FOR YOU"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REQUESTS=$(find .ai-agents -name "request_for_${AGENT_NAME}_*.json" -type f 2>/dev/null)
if [ -z "$REQUESTS" ]; then
    echo "✅ No pending requests"
else
    echo "$REQUESTS" | while read req; do
        echo ""
        echo "📄 $(basename $req)"
        if command -v jq &> /dev/null; then
            jq -r '"  From: \(.from_agent)\n  Type: \(.request_type)\n  Time: \(.timestamp)\n  Description: \(.payload.description)"' "$req"
        else
            echo "  File: $req"
        fi
    done
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📬 RESPONSES TO YOUR REQUESTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

RESPONSES=$(find .ai-agents -name "response_req_*.json" -type f 2>/dev/null)
if [ -z "$RESPONSES" ]; then
    echo "✅ No responses yet"
else
    echo "$RESPONSES" | while read resp; do
        if command -v jq &> /dev/null; then
            TO_AGENT=$(jq -r '.to_agent' "$resp")
            if [ "$TO_AGENT" = "$AGENT_NAME" ]; then
                echo ""
                echo "📄 $(basename $resp)"
                jq -r '"  From: \(.from_agent)\n  Status: \(.status)\n  Time: \(.timestamp)"' "$resp"
            fi
        fi
    done
fi

echo ""
