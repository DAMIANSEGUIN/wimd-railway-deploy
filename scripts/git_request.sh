#!/bin/bash
# Create a request for another agent using git-based protocol

FROM_AGENT="${AI_AGENT_NAME:-Claude-Code}"
TO_AGENT="$1"
REQUEST_TYPE="$2"
DESCRIPTION="$3"

if [ -z "$TO_AGENT" ] || [ -z "$REQUEST_TYPE" ] || [ -z "$DESCRIPTION" ]; then
    echo "Usage: $0 <to_agent> <request_type> <description>"
    echo "Example: $0 Gemini SQL_QUERY 'Need password hash from production'"
    exit 1
fi

TIMESTAMP=$(date +%s)
REQUEST_FILE=".ai-agents/request_for_${TO_AGENT}_${TIMESTAMP}.json"

# Create request file
cat > "$REQUEST_FILE" <<EOF
{
  "request_id": "req_${TIMESTAMP}",
  "from_agent": "$FROM_AGENT",
  "to_agent": "$TO_AGENT",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "PENDING",
  "request_type": "$REQUEST_TYPE",
  "payload": {
    "description": "$DESCRIPTION"
  },
  "response_file": ".ai-agents/response_req_${TIMESTAMP}.json"
}
EOF

# Validate JSON
if ! python3 -m json.tool "$REQUEST_FILE" > /dev/null 2>&1; then
    echo "❌ Invalid JSON generated!"
    cat "$REQUEST_FILE"
    rm "$REQUEST_FILE"
    exit 1
fi

echo "✅ Request created: $REQUEST_FILE"
echo ""
echo "Next step: Commit this request"
echo "  git add $REQUEST_FILE"
echo "  git commit -m \"Request: $TO_AGENT to $REQUEST_TYPE\""
echo ""
echo "Git hook will automatically notify $TO_AGENT when you commit"
