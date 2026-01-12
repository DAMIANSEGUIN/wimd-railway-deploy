#!/bin/bash
# AI Context Loader - One-shot full context output

PROJECT_ROOT="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
cd "$PROJECT_ROOT"

echo "═══════════════════════════════════════════════════════════════════"
echo "🤖 AI SESSION CONTEXT"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# 1. Resume State
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 LAST SESSION STATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "AI_RESUME_STATE.md" ]; then
    cat AI_RESUME_STATE.md
else
    echo "⚠️  No resume state found - starting fresh"
    echo ""
    echo "Check latest handoff below for context."
fi
echo ""
echo ""

# 2. Latest Handoffs
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 LATEST HANDOFF DOCUMENTS (Last 3)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

HANDOFF_FILES=$(ls -t .ai-agents/*.md 2>/dev/null | head -3)

if [ -z "$HANDOFF_FILES" ]; then
    echo "⚠️  No handoff documents found"
else
    for file in $HANDOFF_FILES; do
        filename=$(basename "$file")
        echo ""
        echo "▼ $filename"
        echo "───────────────────────────────────────────────────────────────────"
        cat "$file"
        echo ""
    done
fi
echo ""

# 3. Git Status
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 CURRENT GIT STATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Branch: $(git branch --show-current)"
echo ""
echo "Modified files:"
git status --short | head -10
UNCOMMITTED=$(git status --porcelain | wc -l | tr -d ' ')
if [ "$UNCOMMITTED" -gt 10 ]; then
    echo "... and $((UNCOMMITTED - 10)) more files"
fi
echo ""
echo "Recent commits:"
git log --oneline -5
echo ""

# 4. Backend Health
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💚 BACKEND HEALTH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

HEALTH_RESPONSE=$(curl -s -m 5 https://mosaic-backend-tpog.onrender.com/health 2>/dev/null)

if echo "$HEALTH_RESPONSE" | grep -q '"ok":true'; then
    echo "✅ Backend: HEALTHY"
    echo "$HEALTH_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$HEALTH_RESPONSE"
else
    echo "❌ Backend: UNHEALTHY or UNREACHABLE"
    echo "$HEALTH_RESPONSE"
fi
echo ""

echo "═══════════════════════════════════════════════════════════════════"
echo "✅ CONTEXT LOADED - Review above then ask user what to work on"
echo "═══════════════════════════════════════════════════════════════════"
