#!/bin/bash
# Auto-generate handoff when ending AI session

set -e

TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)
HANDOFF_FILE=".ai-agents/handoff_${TIMESTAMP}_inprogress.json"

# Get optional status message
STATUS_MSG="${1:-Session ended - verify features before proceeding}"
AGENT_NAME="${AI_AGENT_NAME:-Claude-Code}"

echo "🤖 Creating handoff for next agent..."

# Generate valid JSON using jq
cat > "$HANDOFF_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent_name": "$AGENT_NAME",
  "outgoing_agent": "$AGENT_NAME",
  "status": "$STATUS_MSG",
  "git_state": {
    "commit": "$(git rev-parse HEAD)",
    "branch": "$(git rev-parse --abbrev-ref HEAD)",
    "uncommitted_changes": $(git status --porcelain | wc -l | tr -d ' ')
  },
  "critical_features": {
    "auth_ui_present": [
      $(grep -l "authModal\|loginForm" frontend/index.html mosaic_ui/index.html 2>/dev/null | awk '{printf "\"%s\"", $0}' | paste -sd ',' -)
    ],
    "ps101_state_count": [
      $(grep -l "PS101State" frontend/index.html mosaic_ui/index.html 2>/dev/null | awk '{printf "\"%s\"", $0}' | paste -sd ',' -)
    ],
    "api_base_configured": [
      $(grep -l "API_BASE" frontend/index.html mosaic_ui/index.html 2>/dev/null | awk '{printf "\"%s\"", $0}' | paste -sd ',' -)
    ]
  },
  "deployment_status": {
    "railway_health": "$(curl -s -m 5 https://what-is-my-delta-site-production.up.railway.app/health 2>/dev/null | jq -r '.ok' 2>/dev/null || echo 'unknown')",
    "production_auth_present": $(curl -s -m 5 https://whatismydelta.com/ 2>/dev/null | grep -c "authModal\|loginForm" || echo 0)
  },
  "last_commit": {
    "message": $(git log -1 --pretty=format:'"%s"'),
    "author": $(git log -1 --pretty=format:'"%an"'),
    "timestamp": "$(git log -1 --pretty=format:'%aI')"
  },
  "tasks_in_progress": [],
  "notes": "$STATUS_MSG"
}
EOF

# Validate JSON
if python3 -m json.tool "$HANDOFF_FILE" > /dev/null 2>&1; then
    echo "✅ Valid handoff created: $HANDOFF_FILE"
else
    echo "❌ Invalid JSON generated!"
    cat "$HANDOFF_FILE"
    exit 1
fi

# Archive old handoffs (keep last 10)
OLD_HANDOFFS=$(ls -t .ai-agents/handoff_*.json 2>/dev/null | tail -n +11)
if [ -n "$OLD_HANDOFFS" ]; then
    mkdir -p .ai-agents/archive
    echo "$OLD_HANDOFFS" | xargs -I {} mv {} .ai-agents/archive/
    echo "📦 Archived old handoffs"
fi

echo ""
echo "📋 Handoff Summary:"
jq -r '"Agent: \(.agent_name)\nStatus: \(.status)\nCommit: \(.git_state.commit[0:8])\nUncommitted: \(.git_state.uncommitted_changes) files"' "$HANDOFF_FILE"
