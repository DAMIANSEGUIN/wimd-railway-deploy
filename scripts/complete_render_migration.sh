#!/bin/bash
# Complete Render Migration - Get Service URL and Test
# Run this script after checking Render dashboard

set -e

echo "=== Render Migration Completion Script ==="
echo ""

# Step 1: Get service URL from user
echo "Step 1: Get your Render service URL"
echo "---------------------------------------"
echo "Go to: https://dashboard.render.com"
echo "Click on: mosaic-backend service"
echo "Copy the URL shown at the top (should be https://mosaic-backend-XXXXX.onrender.com)"
echo ""
read -p "Paste the Render service URL here: " RENDER_URL

# Validate URL
if [[ ! "$RENDER_URL" =~ ^https://.*onrender\.com ]]; then
    echo "Error: URL should be https://something.onrender.com"
    exit 1
fi

echo ""
echo "Step 2: Testing Render deployment..."
echo "-------------------------------------"

# Test health endpoint
echo "Testing /health endpoint..."
HTTP_CODE=$(curl -s -o /tmp/render_health.json -w "%{http_code}" "$RENDER_URL/health" --max-time 30)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Health check passed!"
    cat /tmp/render_health.json | python3 -m json.tool 2>/dev/null || cat /tmp/render_health.json
else
    echo "❌ Health check failed with HTTP $HTTP_CODE"
    cat /tmp/render_health.json
    exit 1
fi

echo ""
echo "Step 3: Testing /config endpoint..."
curl -s "$RENDER_URL/config" | python3 -m json.tool

echo ""
echo "Step 4: Update state files..."
echo "-----------------------------"

# Update agent state
cat > .mosaic/agent_state.json <<EOF
{
  "version": 1,
  "last_agent": "claude_code_terminal",
  "last_mode": "DEPLOY",
  "last_session_start": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_session_end": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_commit": "$(git rev-parse --short HEAD)",
  "current_agent": "COMPLETED",
  "current_task": "Render migration complete",
  "handoff_message": "Render migration COMPLETE. Service live at $RENDER_URL. Health check passing. Ready for frontend update.",
  "briefing_acknowledgment": {
    "agent": "claude_code_terminal",
    "briefing_version": "1.0",
    "acknowledged_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "last_commit_known": "$(git rev-parse --short HEAD)"
  },
  "user_decisions": {
    "D1_relative_paths_only": "YES",
    "D2_archive_old_docs": "YES",
    "D3_mosaic_json_canonical": "YES",
    "D4_deployment_strategy": "Render"
  },
  "implementation_progress": {
    "render_migration": "complete",
    "render_url": "$RENDER_URL"
  },
  "next_agent": "TBD",
  "open_questions": []
}
EOF

# Log to session log
echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"agent\":\"claude_code_terminal\",\"mode\":\"DEPLOY\",\"action\":\"render_migration_complete\",\"outcome\":\"service_live_at_${RENDER_URL}\"}" >> .mosaic/session_log.jsonl

echo "✅ State files updated"

echo ""
echo "Step 5: Next steps"
echo "------------------"
echo "1. Update frontend API_BASE to: $RENDER_URL"
echo "2. Test full user flow from https://whatismydelta.com"
echo "3. Decommission Railway once verified"
echo ""
echo "Render service URL: $RENDER_URL"
echo ""
echo "Migration complete!"
