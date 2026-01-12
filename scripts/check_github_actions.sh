#!/bin/bash
# scripts/check_github_actions.sh - Monitor GitHub Actions without gh CLI
# Uses GitHub API with existing token from keychain

set -euo pipefail

REPO="DAMIANSEGUIN/wimd-railway-deploy"

# Get GitHub token from keychain via git credential helper
GITHUB_TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill | grep "^password=" | cut -d= -f2)

echo "🔍 Checking GitHub Actions workflow status..."
echo ""

# Get latest workflow runs
RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/actions/runs?per_page=3")

# Parse and display results
echo "$RESPONSE" | jq -r '.workflow_runs[] | "[\(.conclusion // .status)] \(.name) - \(.created_at) - \(.html_url)"' 2>/dev/null || {
  echo "❌ Failed to parse GitHub API response"
  echo "Response: $RESPONSE"
  exit 1
}

echo ""
echo "📊 Latest workflow status:"

# Get the most recent workflow conclusion
LATEST_STATUS=$(echo "$RESPONSE" | jq -r '.workflow_runs[0].conclusion // .workflow_runs[0].status' 2>/dev/null)
LATEST_NAME=$(echo "$RESPONSE" | jq -r '.workflow_runs[0].name' 2>/dev/null)

if [ "$LATEST_STATUS" = "failure" ]; then
    echo "❌ FAILED: $LATEST_NAME"
    echo ""
    echo "View logs: $(echo "$RESPONSE" | jq -r '.workflow_runs[0].html_url')"
    exit 1
elif [ "$LATEST_STATUS" = "success" ]; then
    echo "✅ PASSED: $LATEST_NAME"
    exit 0
elif [ "$LATEST_STATUS" = "in_progress" ] || [ "$LATEST_STATUS" = "queued" ]; then
    echo "⏳ IN PROGRESS: $LATEST_NAME"
    exit 0
else
    echo "⚠️  UNKNOWN: $LATEST_STATUS"
    exit 1
fi
