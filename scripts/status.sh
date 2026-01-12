#!/bin/bash
# status.sh - Run this at the start of every session
# Shows current team status, production health, and what to work on

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   WIMD PROJECT STATUS                          ║"
echo "║                  $(date '+%Y-%m-%d %H:%M:%S %Z')                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# 1. PRODUCTION HEALTH
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 PRODUCTION STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -n "   Frontend: "
if curl -s -m 5 https://whatismydelta.com/health 2>/dev/null | grep -q '"ok":true'; then
    echo -e "${GREEN}✅ HEALTHY${NC}"
else
    echo -e "${YELLOW}⚠️  CHECK FAILED (may be network)${NC}"
fi

echo -n "   Backend:  "
if curl -s -m 5 https://mosaic-backend-tpog.onrender.com/health 2>/dev/null | grep -q '"ok":true'; then
    echo -e "${GREEN}✅ HEALTHY${NC}"
else
    echo -e "${YELLOW}⚠️  CHECK FAILED (may be network)${NC}"
fi

echo ""

# ============================================================================
# 2. GIT STATUS
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 GIT STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "   Branch: $(git branch --show-current)"
echo "   Last Commit:"
git log -1 --pretty=format:"      %h - %ar - %s" --color=always
echo ""
echo ""

UNCOMMITTED=$(git status --porcelain | wc -l | tr -d ' ')
if [ "$UNCOMMITTED" -gt 0 ]; then
    echo -e "   ${YELLOW}⚠️  Uncommitted: $UNCOMMITTED files${NC}"
else
    echo -e "   ${GREEN}✅ Clean${NC}"
fi

echo ""

# ============================================================================
# 3. TEAM STATUS (who's doing what)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👥 TEAM STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "TEAM_STATUS.json" ]; then
    echo -e "   ${RED}❌ TEAM_STATUS.json not found${NC}"
    echo "   Run: ./scripts/commit_work.sh to create it"
    echo ""
else
    # Active work
    ACTIVE_COUNT=$(jq '.active | length' TEAM_STATUS.json)
    if [ "$ACTIVE_COUNT" -gt 0 ]; then
        echo -e "   ${BLUE}Active Work:${NC}"
        jq -r '.active[] | "      • \(.task): \(.title) (\(.agent))\n        \(.description)"' TEAM_STATUS.json
    else
        echo "   No active work"
    fi
    echo ""

    # Completed today
    DONE_COUNT=$(jq '.done_today | length' TEAM_STATUS.json)
    if [ "$DONE_COUNT" -gt 0 ]; then
        echo -e "   ${GREEN}Done Today:${NC}"
        jq -r '.done_today[] | "      ✅ \(.task) (\(.agent)) - \(.commit)"' TEAM_STATUS.json
    fi
    echo ""

    # Blocked
    BLOCKED_COUNT=$(jq '.blocked | length' TEAM_STATUS.json)
    if [ "$BLOCKED_COUNT" -gt 0 ]; then
        echo -e "   ${RED}Blocked:${NC}"
        jq -r '.blocked[] | "      🚫 \(.task) (\(.agent)) - \(.blocker)"' TEAM_STATUS.json
        echo ""
    fi

    # Queue
    QUEUE_COUNT=$(jq '.queue | length' TEAM_STATUS.json)
    if [ "$QUEUE_COUNT" -gt 0 ]; then
        echo -e "   ${YELLOW}Queue (Next Up):${NC}"
        jq -r '.queue[] | "      → \(.task): \(.title) (\(.assigned))"' TEAM_STATUS.json
    else
        echo "   Queue empty"
    fi
    echo ""

    # Warnings
    WARNING_COUNT=$(jq '.warnings | length' TEAM_STATUS.json)
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo -e "   ${YELLOW}⚠️  Warnings:${NC}"
        jq -r '.warnings[] | "      ⚠️  \(.)"' TEAM_STATUS.json
        echo ""
    fi

    # Last updated
    LAST_UPDATED=$(jq -r '.last_updated' TEAM_STATUS.json)
    echo "   Last updated: $LAST_UPDATED"
fi

echo ""

# ============================================================================
# 4. WHAT TO DO NEXT
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 WHAT TO DO NEXT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "TEAM_STATUS.json" ]; then
    echo "   1. Create TEAM_STATUS.json (run commit_work.sh)"
    echo "   2. Read: AI_TEAM_METHODOLOGY.md"
else
    # Check if anything is blocked (needs user)
    BLOCKED_COUNT=$(jq '.blocked | length' TEAM_STATUS.json)
    if [ "$BLOCKED_COUNT" -gt 0 ]; then
        echo -e "   ${RED}⚠️  BLOCKERS NEED ATTENTION${NC}"
        echo "   Review blocked items above and unblock them"
        echo ""
    fi

    # Check if there's active work
    ACTIVE_COUNT=$(jq '.active | length' TEAM_STATUS.json)
    if [ "$ACTIVE_COUNT" -gt 0 ]; then
        echo "   Someone is actively working (see above)"
        echo "   Wait for them to finish or pick another task from queue"
        echo ""
    fi

    # Show next available task
    QUEUE_COUNT=$(jq '.queue | length' TEAM_STATUS.json)
    if [ "$QUEUE_COUNT" -gt 0 ]; then
        echo "   Next available task:"
        NEXT_TASK=$(jq -r '.queue[0] | "      → \(.task): \(.title) (\(.assigned))"' TEAM_STATUS.json)
        echo "$NEXT_TASK"
        echo ""
        echo "   To start work:"
        echo "      1. Work on your assigned task"
        echo "      2. When done: ./scripts/commit_work.sh"
    else
        echo "   ✅ All tasks complete or in progress"
        echo "   Check with user for next priority"
    fi
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      STATUS CHECK COMPLETE                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
