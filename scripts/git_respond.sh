#!/bin/bash
# Respond to an agent request using git-based protocol

FROM_AGENT="${AI_AGENT_NAME:-Gemini}"
REQUEST_FILE="$1"
RESPONSE_DATA="$2"

if [ -z "$REQUEST_FILE" ] || [ -z "$RESPONSE_DATA" ]; then
    echo "Usage: $0 <request_file> <response_data>"
    echo "Example: $0 .ai-agents/request_for_Gemini_12345.json '{\"hash_length\": 97}'"
    exit 1
fi

if [ ! -f "$REQUEST_FILE" ]; then
    echo "❌ Request file not found: $REQUEST_FILE"
    exit 1
fi

# Extract request details
REQUEST_ID=$(jq -r '.request_id' "$REQUEST_FILE")
TO_AGENT=$(jq -r '.from_agent' "$REQUEST_FILE")
RESPONSE_FILE=$(jq -r '.response_file' "$REQUEST_FILE")

# Create response file
cat > "$RESPONSE_FILE" <<EOF
{
  "request_id": "$REQUEST_ID",
  "from_agent": "$FROM_AGENT",
  "to_agent": "$TO_AGENT",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "COMPLETED",
  "payload": $RESPONSE_DATA
}
EOF

# Validate JSON
if ! python3 -m json.tool "$RESPONSE_FILE" > /dev/null 2>&1; then
    echo "❌ Invalid JSON generated!"
    cat "$RESPONSE_FILE"
    rm "$RESPONSE_FILE"
    exit 1
fi

echo "✅ Response created: $RESPONSE_FILE"
echo ""
echo "Next step: Commit this response"
echo "  git add $RESPONSE_FILE"
echo "  git commit -m \"Response: $REQUEST_ID completed\""
echo ""
echo "Git hook will automatically notify $TO_AGENT when you commit"
