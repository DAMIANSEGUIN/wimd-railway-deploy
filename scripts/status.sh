#!/bin/bash
# status.sh - SINGLE SOURCE OF TRUTH FOR PROJECT STATUS
# All AI agents MUST run this script at session start
# This is the ONLY authoritative source for current project state

set -e

# Colors for output (optional, works in most terminals)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   WIMD PROJECT STATUS                          ║"
echo "║                  $(date '+%Y-%m-%d %H:%M:%S %Z')                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# 1. PRODUCTION HEALTH (LIVE CHECK)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 PRODUCTION STATUS (Live Check)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check frontend
echo -n "   Frontend (whatismydelta.com): "
FRONTEND_HEALTH=$(curl -s -m 5 https://whatismydelta.com/health 2>/dev/null || echo '{"ok":false}')
if echo "$FRONTEND_HEALTH" | grep -q '"ok":true'; then
    echo -e "${GREEN}✅ HEALTHY${NC}"
    PROD_STATUS="healthy"
else
    echo -e "${RED}🔴 DOWN OR UNHEALTHY${NC}"
    PROD_STATUS="unhealthy"
fi

# Check backend
echo -n "   Backend (Railway API): "
BACKEND_HEALTH=$(curl -s -m 5 https://what-is-my-delta-site-production.up.railway.app/health 2>/dev/null || echo '{"ok":false}')
if echo "$BACKEND_HEALTH" | grep -q '"ok":true'; then
    echo -e "${GREEN}✅ HEALTHY${NC}"
else
    echo -e "${RED}🔴 DOWN OR UNHEALTHY${NC}"
    PROD_STATUS="unhealthy"
fi

# Check critical features
echo -n "   Critical Features: "
FEATURES_OK=0
if ./scripts/verify_critical_features.sh > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ALL PRESENT${NC}"
    FEATURES_OK=1
else
    echo -e "${RED}❌ VERIFICATION FAILED${NC}"
    PROD_STATUS="unhealthy"
fi

echo ""

# ============================================================================
# 2. GIT STATUS
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 GIT STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CURRENT_BRANCH=$(git branch --show-current)
echo "   Current Branch: $CURRENT_BRANCH"

# Last commit (what's deployed)
echo "   Last Commit (Deployed):"
git log -1 --pretty=format:"      %h - %ar - %s" --color=always
echo ""
echo ""

# Working directory status
UNCOMMITTED=$(git status --porcelain | wc -l | tr -d ' ')
if [ "$UNCOMMITTED" -gt 0 ]; then
    echo -e "   ${YELLOW}⚠️  Uncommitted Changes: $UNCOMMITTED files${NC}"
    git status --short | head -10 | sed 's/^/      /'
    if [ "$UNCOMMITTED" -gt 10 ]; then
        echo "      ... and $((UNCOMMITTED - 10)) more"
    fi
else
    echo -e "   ${GREEN}✅ Clean Working Directory${NC}"
fi

echo ""

# ============================================================================
# 3. CURRENT WORK STATUS (MANDATORY HANDOFF)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 CURRENT WORK (From Previous Agent)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "CURRENT_WORK.json" ]; then
    echo "   📄 File: CURRENT_WORK.json"

    # Extract key info
    LAST_AGENT=$(jq -r '.agent // "Unknown"' CURRENT_WORK.json)
    LAST_UPDATED=$(jq -r '.last_updated // "Unknown"' CURRENT_WORK.json)
    TASK_TITLE=$(jq -r '.task.title // "No task specified"' CURRENT_WORK.json)
    NEXT_ACTION=$(jq -r '.task.next_action // "Ask user what to work on"' CURRENT_WORK.json)

    echo "   🤖 Last Agent: $LAST_AGENT"
    echo "   🕒 Updated: $LAST_UPDATED"
    echo ""
    echo "   🎯 Task: $TASK_TITLE"
    echo ""

    # Show completed items
    COMPLETED_COUNT=$(jq '.task.completed | length' CURRENT_WORK.json)
    if [ "$COMPLETED_COUNT" -gt 0 ]; then
        echo "   ✅ Completed:"
        jq -r '.task.completed[] | "      - " + .' CURRENT_WORK.json
    fi

    # Show todo items
    TODO_COUNT=$(jq '.task.todo | length' CURRENT_WORK.json)
    if [ "$TODO_COUNT" -gt 0 ]; then
        echo "   ⏳ Still TODO:"
        jq -r '.task.todo[] | "      - " + .' CURRENT_WORK.json
    fi

    echo ""
    echo "   ➡️  NEXT ACTION: $NEXT_ACTION"
    echo ""

    # Show warnings from CURRENT_WORK.json
    WORK_WARNINGS_COUNT=$(jq '.warnings | length' CURRENT_WORK.json)
    if [ "$WORK_WARNINGS_COUNT" -gt 0 ]; then
        echo "   ⚠️  Warnings from previous agent:"
        jq -r '.warnings[] | "      - " + .' CURRENT_WORK.json
        echo ""
    fi

    HAS_CURRENT_WORK=1
else
    echo -e "   ${YELLOW}⚠️  No CURRENT_WORK.json found${NC}"
    echo "   This means either:"
    echo "   - This is a fresh start (no previous work)"
    echo "   - Previous agent didn't run session_end.sh properly"
    echo ""
    echo "   Default action: Ask user what to work on"
    HAS_CURRENT_WORK=0
fi

echo ""

# ============================================================================
# 4. ADDITIONAL CONTEXT (Optional Reference Files)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 ADDITIONAL CONTEXT (Optional - if you need more info)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find most recent instruction file (last 7 days)
LATEST_INSTRUCTION=""
LATEST_TIME=0

# Check multiple locations for instruction files
for file in \
    .ai-agents/NOTE_FOR_*_$(date +%Y-%m-%d).md \
    .ai-agents/NOTE_FOR_*_$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d yesterday +%Y-%m-%d 2>/dev/null).md \
    .ai-agents/FOR_*_$(date +%Y-%m-%d).txt \
    .ai-agents/INFRASTRUCTURE_STATUS_$(date +%Y-%m-%d).md \
    .ai-agents/NOTE_FOR_*.md \
    .ai-agents/FOR_*.txt \
    .ai-agents/INFRASTRUCTURE_STATUS_*.md \
    .ai-agents/*_$(date +%Y-%m-%d).md; do

    if [ -f "$file" ]; then
        FILE_TIME=$(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file" 2>/dev/null)
        if [ "$FILE_TIME" -gt "$LATEST_TIME" ]; then
            LATEST_TIME=$FILE_TIME
            LATEST_INSTRUCTION=$file
        fi
    fi
done

if [ -n "$LATEST_INSTRUCTION" ]; then
    FILE_AGE_SECONDS=$(($(date +%s) - LATEST_TIME))
    FILE_AGE_HOURS=$((FILE_AGE_SECONDS / 3600))

    echo "   📄 File: $LATEST_INSTRUCTION"
    echo "   🕒 Modified: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$LATEST_INSTRUCTION" 2>/dev/null || stat -c "%y" "$LATEST_INSTRUCTION" 2>/dev/null | cut -d' ' -f1-2) ($FILE_AGE_HOURS hours ago)"
    echo ""
    echo "   📖 Preview (first 10 lines):"
    echo "   ┌─────────────────────────────────────────────────────────┐"
    head -10 "$LATEST_INSTRUCTION" | sed 's/^/   │ /'
    echo "   └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "   ℹ️  This is OPTIONAL context. Your primary instructions are"
    echo "   in CURRENT_WORK.json above."

    INSTRUCTION_FILE="$LATEST_INSTRUCTION"
else
    echo "   ℹ️  No additional instruction files found (this is normal)"
    echo "   Your task is defined in CURRENT_WORK.json above."
    INSTRUCTION_FILE=""
fi

echo ""

# ============================================================================
# 4. ACTIVE WARNINGS & BLOCKERS
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  ACTIVE WARNINGS & BLOCKERS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

WARNINGS_FOUND=0

# Check for recent rollback/revert
if git log -5 --oneline | grep -qi "revert\|rollback"; then
    echo -e "   ${RED}🚨 CRITICAL: Recent rollback detected${NC}"
    echo "      Check .ai-agents/*ROLLBACK*.md or *INCIDENT*.md files"
    WARNINGS_FOUND=1
fi

# Check for incomplete Phase 1
if git branch -a | grep -q "phase1-incomplete"; then
    echo -e "   ${YELLOW}⚠️  WARNING: Phase 1 branch exists but is INCOMPLETE${NC}"
    echo "      Branch: phase1-incomplete"
    echo "      DO NOT DEPLOY this branch without integration"
    WARNINGS_FOUND=1
fi

# Check for uncommitted local changes that might be deployment hooks
if [ "$UNCOMMITTED" -gt 0 ] && git status --porcelain | grep -q "mosaic_ui/index.html"; then
    echo -e "   ${YELLOW}⚠️  NOTICE: Local changes to mosaic_ui/index.html${NC}"
    echo "      These may be safe hooks not yet deployed"
    echo "      Verify with user before deploying"
    WARNINGS_FOUND=1
fi

# Check if production is unhealthy
if [ "$PROD_STATUS" = "unhealthy" ]; then
    echo -e "   ${RED}🚨 CRITICAL: Production health check FAILED${NC}"
    echo "      STOP all work and diagnose production issue first"
    WARNINGS_FOUND=1
fi

if [ $WARNINGS_FOUND -eq 0 ]; then
    echo -e "   ${GREEN}✅ No active warnings${NC}"
fi

echo ""

# ============================================================================
# 5. WHAT TO DO NEXT (DECISION TREE)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 WHAT TO DO NEXT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Decision tree based on current state
if [ "$PROD_STATUS" = "unhealthy" ]; then
    echo "   1. 🚨 PRODUCTION IS UNHEALTHY - This is the top priority"
    echo "   2. STOP all other work - diagnose production issue"
    echo "   3. Check Railway dashboard for errors"
    echo "   4. Check Netlify dashboard for deployment failures"
    echo "   5. Review recent commits that may have broken prod"
    echo "   6. Consider rollback if issue is from recent deploy"

elif [ "$HAS_CURRENT_WORK" -eq 1 ]; then
    echo "   ✅ You have a clear task from the previous agent"
    echo ""
    echo "   📋 Read CURRENT_WORK.json above (already displayed)"
    echo ""
    echo "   ➡️  NEXT ACTION: $NEXT_ACTION"
    echo ""
    echo "   Before making changes:"
    echo "   - Run: ./scripts/verify_critical_features.sh"
    echo ""
    echo "   When you're done:"
    echo "   - Run: ./scripts/session_end.sh (updates CURRENT_WORK.json)"

else
    echo "   ⚠️  No CURRENT_WORK.json found"
    echo ""
    echo "   This means either:"
    echo "   - Fresh start (no previous work to continue)"
    echo "   - Previous agent didn't end session properly"
    echo ""
    echo "   Your options:"
    echo "   1. Ask user: \"What should I work on?\""
    echo "   2. Check architecture docs: CLAUDE.md"
    echo "   3. Check for urgent files in .ai-agents/ directory"
fi

echo ""

# ============================================================================
# 6. QUICK REFERENCE
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 QUICK REFERENCE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Production URLs:"
echo "      Frontend: https://whatismydelta.com"
echo "      Backend:  https://what-is-my-delta-site-production.up.railway.app"
echo ""
echo "   Essential Commands:"
echo "      Check features: ./scripts/verify_critical_features.sh"
echo "      Check health:   curl https://whatismydelta.com/health"
echo "      Recent commits: git log -10 --oneline"
echo "      Recent files:   ls -lht .ai-agents/*.md | head -5"
echo ""
echo "   Deployment (ALWAYS use wrapper scripts):"
echo "      Frontend: ./scripts/deploy.sh netlify"
echo "      Backend:  ./scripts/deploy.sh railway"
echo "      Both:     ./scripts/deploy.sh all"
echo ""
echo "   Documentation:"
echo "      Architecture:    CLAUDE.md"
echo "      Troubleshooting: TROUBLESHOOTING_CHECKLIST.md"
echo "      Session Start:   .ai-agents/SESSION_START_PROTOCOL.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# 7. SUMMARY STATUS (for quick scanning)
# ============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                        SUMMARY                                 ║"
echo "╠════════════════════════════════════════════════════════════════╣"

if [ "$PROD_STATUS" = "healthy" ] && [ $FEATURES_OK -eq 1 ] && [ $WARNINGS_FOUND -eq 0 ]; then
    echo -e "║  Status: ${GREEN}✅ ALL SYSTEMS GO${NC}                                       ║"
elif [ "$PROD_STATUS" = "unhealthy" ] || [ $FEATURES_OK -eq 0 ]; then
    echo -e "║  Status: ${RED}🔴 PRODUCTION ISSUE - INVESTIGATE IMMEDIATELY${NC}        ║"
elif [ $WARNINGS_FOUND -gt 0 ]; then
    echo -e "║  Status: ${YELLOW}⚠️  WARNINGS ACTIVE - PROCEED WITH CAUTION${NC}           ║"
else
    echo -e "║  Status: ${GREEN}✅ OPERATIONAL${NC}                                        ║"
fi

if [ -n "$INSTRUCTION_FILE" ]; then
    echo "║  Next Step: Read instruction file above                       ║"
else
    echo "║  Next Step: Ask user for direction                            ║"
fi

echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Exit with status code
if [ "$PROD_STATUS" = "unhealthy" ]; then
    exit 1
else
    exit 0
fi
