#!/bin/bash
# session_end.sh - Run this at the end of every AI agent session
# Creates a status commit message for the next agent

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

# Detect agent type from environment or ask
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

# Ask structured questions for handoff
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 HANDOFF QUESTIONS (for next agent)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "1. What were you working on? (one line)"
read -r TASK_TITLE

echo ""
echo "2. What did you complete? (comma separated, or 'nothing yet')"
read -r COMPLETED

echo ""
echo "3. What's still left to do? (comma separated, or 'all done')"
read -r TODO

echo ""
echo "4. What should the next agent do FIRST? (one concrete action)"
read -r NEXT_ACTION

echo ""
echo "5. Any blockers or warnings? (comma separated, or 'none')"
read -r WARNINGS_INPUT

SESSION_SUMMARY="$TASK_TITLE"

# Check production health
echo ""
echo "Checking production health..."
PROD_STATUS="unknown"
if curl -s -m 5 https://whatismydelta.com/health 2>/dev/null | grep -q '"ok":true'; then
    PROD_STATUS="healthy"
else
    PROD_STATUS="unhealthy"
fi

# Build warnings array
WARNINGS_ARRAY="[]"
if git log -5 --oneline | grep -qi "revert\|rollback"; then
    WARNINGS_ARRAY=$(echo "$WARNINGS_ARRAY" | jq '. += ["Recent rollback in git history"]')
fi
if git branch -a | grep -q "phase1-incomplete"; then
    WARNINGS_ARRAY=$(echo "$WARNINGS_ARRAY" | jq '. += ["Phase 1 branch incomplete - do not deploy"]')
fi
if [ "$PROD_STATUS" = "unhealthy" ]; then
    WARNINGS_ARRAY=$(echo "$WARNINGS_ARRAY" | jq '. += ["Production health check FAILED"]')
fi
if [ "$WARNINGS_INPUT" != "none" ] && [ -n "$WARNINGS_INPUT" ]; then
    # Add user-provided warnings
    IFS=',' read -ra USER_WARNS <<< "$WARNINGS_INPUT"
    for warn in "${USER_WARNS[@]}"; do
        WARNINGS_ARRAY=$(echo "$WARNINGS_ARRAY" | jq --arg w "$(echo "$warn" | xargs)" '. += [$w]')
    done
fi

# Build completed/todo arrays
COMPLETED_ARRAY="[]"
if [ "$COMPLETED" != "nothing yet" ] && [ -n "$COMPLETED" ]; then
    IFS=',' read -ra ITEMS <<< "$COMPLETED"
    for item in "${ITEMS[@]}"; do
        COMPLETED_ARRAY=$(echo "$COMPLETED_ARRAY" | jq --arg i "$(echo "$item" | xargs)" '. += [$i]')
    done
fi

TODO_ARRAY="[]"
if [ "$TODO" != "all done" ] && [ -n "$TODO" ]; then
    IFS=',' read -ra ITEMS <<< "$TODO"
    for item in "${ITEMS[@]}"; do
        TODO_ARRAY=$(echo "$TODO_ARRAY" | jq --arg i "$(echo "$item" | xargs)" '. += [$i]')
    done
fi

# Create CURRENT_WORK.json
cat > CURRENT_WORK.json <<EOF
{
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent": "$AGENT_NAME",
  "task": {
    "title": "$TASK_TITLE",
    "completed": $COMPLETED_ARRAY,
    "todo": $TODO_ARRAY,
    "next_action": "$NEXT_ACTION"
  },
  "production": {
    "status": "$PROD_STATUS",
    "frontend": "https://whatismydelta.com",
    "backend": "https://what-is-my-delta-site-production.up.railway.app"
  },
  "git": {
    "branch": "$(git branch --show-current)",
    "last_commit": "$(git log -1 --pretty=format:'%h - %ar - %s')"
  },
  "warnings": $WARNINGS_ARRAY
}
EOF

echo "✅ Created CURRENT_WORK.json"
echo ""

# Build commit warnings for message
WARNINGS=""
if echo "$WARNINGS_ARRAY" | jq -e '. | length > 0' > /dev/null; then
    WARNINGS="Warnings:\n$(echo "$WARNINGS_ARRAY" | jq -r '.[] | "- " + .')\n"
fi

# Create commit message
COMMIT_MSG="Session: $SESSION_SUMMARY

Agent: $AGENT_NAME
Date: $(date '+%Y-%m-%d %H:%M %Z')
Production: $PROD_STATUS

Changes:
$(git status --short | head -10 | sed 's/^/  /')
$([ "$UNCOMMITTED" -gt 10 ] && echo "  ... and $((UNCOMMITTED - 10)) more files")

Status for next agent:
- Production: https://whatismydelta.com ($PROD_STATUS)
- Backend: https://what-is-my-delta-site-production.up.railway.app
- Branch: $(git branch --show-current)
- Last deploy: $(git log -1 --pretty=format:'%h - %ar - %s')

$([ -n "$WARNINGS" ] && echo "Warnings:" && echo -e "$WARNINGS")
Next agent: Run ./scripts/status.sh to get current state"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Commit message preview:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$COMMIT_MSG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ask if user wants to commit
echo "Commit these changes? (y/n)"
read -r CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    # Stage all changes
    git add -A

    # Create commit with the message
    git commit -m "$COMMIT_MSG"

    echo ""
    echo "✅ Session committed successfully"
    echo ""
    echo "📋 For next agent:"
    echo "   Run: ./scripts/status.sh"
    echo ""

    # Ask if they want to push
    echo "Push to remote? (y/n)"
    read -r PUSH_CONFIRM

    if [ "$PUSH_CONFIRM" = "y" ] || [ "$PUSH_CONFIRM" = "Y" ]; then
        CURRENT_BRANCH=$(git branch --show-current)
        git push origin "$CURRENT_BRANCH"
        echo "✅ Pushed to origin/$CURRENT_BRANCH"
    else
        echo "ℹ️  Changes committed locally but not pushed"
        echo "   Next agent can push with: git push origin $(git branch --show-current)"
    fi
else
    echo ""
    echo "❌ Commit cancelled"
    echo ""
    echo "Your changes are still uncommitted. Options:"
    echo "  1. Run this script again: ./scripts/session_end.sh"
    echo "  2. Commit manually: git add -A && git commit -m 'your message'"
    echo "  3. Stash changes: git stash save 'WIP: description'"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              SESSION END COMPLETE                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
