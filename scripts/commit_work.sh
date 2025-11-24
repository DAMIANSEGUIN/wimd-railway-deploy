#!/bin/bash
# session_end.sh - Run this at the end of every AI agent session
# Updates TEAM_STATUS.json and creates commit

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              SESSION END PROTOCOL                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if there are uncommitted changes
UNCOMMITTED=$(git status --porcelain | wc -l | tr -d ' ')

if [ "$UNCOMMITTED" -eq 0 ]; then
    echo "✅ No uncommitted changes - working directory is clean"
    echo ""
    echo "Session ended successfully. No commit needed."
    exit 0
fi

echo "📊 Session Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Detect agent type
AGENT_NAME="${AI_AGENT_NAME:-Unknown}"
if [ "$AGENT_NAME" = "Unknown" ]; then
    echo "Which AI agent are you? (claude-code/gemini/cursor/chatgpt)"
    read -r AGENT_INPUT
    case "$AGENT_INPUT" in
        claude*|Claude*)
            AGENT_NAME="Claude Code"
            ;;
        gemini|Gemini)
            AGENT_NAME="Gemini"
            ;;
        cursor|Cursor|codex|Codex)
            AGENT_NAME="Cursor/Codex"
            ;;
        chat*|ChatGPT*)
            AGENT_NAME="ChatGPT"
            ;;
        *)
            AGENT_NAME="$AGENT_INPUT"
            ;;
    esac
fi

echo "Agent: $AGENT_NAME"
echo "Uncommitted changes: $UNCOMMITTED files"
echo ""

# Show what changed
echo "Files modified:"
git status --short | head -20 | sed 's/^/  /'
if [ "$UNCOMMITTED" -gt 20 ]; then
    echo "  ... and $((UNCOMMITTED - 20)) more files"
fi
echo ""

# Ask questions
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 HANDOFF QUESTIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "1. What task were you working on? (e.g., P0.2, bug-fix-auth, feature-search)"
read -r TASK_ID

echo ""
echo "2. Status: (done/blocked/in-progress)"
read -r STATUS

echo ""
BLOCKERS=""
if [ "$STATUS" = "blocked" ]; then
    echo "3. What's blocking you? (one line)"
    read -r BLOCKERS
fi

# Check production health
echo ""
echo "Checking production health..."
PROD_STATUS="healthy"
set +e
if ! curl -s -m 5 https://whatismydelta.com/health 2>/dev/null | grep -q '"ok":true'; then
    PROD_STATUS="unhealthy"
fi
set -e

# Update TEAM_STATUS.json
echo ""
echo "Updating TEAM_STATUS.json..."

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
COMMIT_HASH=$(git log -1 --pretty=format:'%h' 2>/dev/null || echo "none")
CURRENT_BRANCH=$(git branch --show-current)

# Read current TEAM_STATUS.json
if [ ! -f "TEAM_STATUS.json" ]; then
    echo "⚠️  TEAM_STATUS.json not found, creating new one"
    cat > TEAM_STATUS.json <<EOF
{
  "active": [],
  "done_today": [],
  "blocked": [],
  "queue": [],
  "production": {
    "status": "$PROD_STATUS",
    "frontend": "https://whatismydelta.com",
    "backend": "https://what-is-my-delta-site-production.up.railway.app",
    "last_deploy": "$COMMIT_HASH",
    "last_check": "$TIMESTAMP"
  },
  "warnings": [],
  "last_updated": "$TIMESTAMP"
}
EOF
fi

# Update based on status
if [ "$STATUS" = "done" ]; then
    # Remove from active, add to done_today
    jq --arg task "$TASK_ID" \
       --arg agent "$AGENT_NAME" \
       --arg commit "$COMMIT_HASH" \
       --arg time "$TIMESTAMP" \
       '.active = [.active[] | select(.task != $task)] |
        .done_today += [{task: $task, agent: $agent, commit: $commit, completed: $time}] |
        .last_updated = $time |
        .production.last_deploy = $commit |
        .production.last_check = $time |
        .production.status = "'"$PROD_STATUS"'"' \
       TEAM_STATUS.json > TEAM_STATUS.tmp && mv TEAM_STATUS.tmp TEAM_STATUS.json

elif [ "$STATUS" = "blocked" ]; then
    # Add to blocked array
    jq --arg task "$TASK_ID" \
       --arg agent "$AGENT_NAME" \
       --arg blocker "$BLOCKERS" \
       --arg time "$TIMESTAMP" \
       '.blocked += [{task: $task, agent: $agent, blocker: $blocker, since: $time}] |
        .last_updated = $time' \
       TEAM_STATUS.json > TEAM_STATUS.tmp && mv TEAM_STATUS.tmp TEAM_STATUS.json

else
    # Still in progress, update timestamp
    jq --arg task "$TASK_ID" \
       --arg time "$TIMESTAMP" \
       '.active = [.active[] | if .task == $task then .last_update = $time else . end] |
        .last_updated = $time' \
       TEAM_STATUS.json > TEAM_STATUS.tmp && mv TEAM_STATUS.tmp TEAM_STATUS.json
fi

echo "✅ Updated TEAM_STATUS.json"
echo ""

# Create commit message
COMMIT_MSG="$STATUS: $TASK_ID

Agent: $AGENT_NAME
Branch: $CURRENT_BRANCH
Production: $PROD_STATUS

$([ "$STATUS" = "blocked" ] && echo "Blocker: $BLOCKERS" && echo "")
Files changed: $UNCOMMITTED
$(git status --short | head -5 | sed 's/^/  /')
$([ "$UNCOMMITTED" -gt 5 ] && echo "  ... and $((UNCOMMITTED - 5)) more")

Next: Run ./scripts/status.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Commit message:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$COMMIT_MSG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Commit
echo "Commit these changes? (y/n)"
read -r CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    git add -A
    git commit -m "$COMMIT_MSG"

    echo ""
    echo "✅ Session committed"
    echo ""

    # Push
    echo "Push to remote? (y/n)"
    read -r PUSH_CONFIRM

    if [ "$PUSH_CONFIRM" = "y" ] || [ "$PUSH_CONFIRM" = "Y" ]; then
        git push origin "$CURRENT_BRANCH"
        echo "✅ Pushed to origin/$CURRENT_BRANCH"
    fi
else
    echo "❌ Commit cancelled - changes still uncommitted"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              SESSION END COMPLETE                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Next agent: Run ./scripts/status.sh"
echo ""
