#!/bin/bash
# Script to show latest context for AI agents
# Run this at session start to see what to read first

set -e

PROJECT_ROOT="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
cd "$PROJECT_ROOT"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 LATEST CONTEXT FOR AI AGENTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Always start here
echo "📍 STEP 1: Read the Start Here file"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f ".ai-agents/START_HERE.md" ]; then
    LAST_UPDATED=$(grep "Last Updated:" .ai-agents/START_HERE.md | head -1)
    echo "✅ .ai-agents/START_HERE.md"
    echo "   $LAST_UPDATED"

    # Check if it's stale (older than 3 days)
    if [ -f ".ai-agents/START_HERE.md" ]; then
        AGE_DAYS=$(( ( $(date +%s) - $(stat -f %m .ai-agents/START_HERE.md) ) / 86400 ))
        if [ $AGE_DAYS -gt 3 ]; then
            echo "   ⚠️  WARNING: File is $AGE_DAYS days old - may need update"
        fi
    fi
else
    echo "❌ START_HERE.md not found - create it first!"
fi
echo ""

# 2. Latest incident/status files
echo "📋 STEP 2: Read latest status files (last 7 days)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
LATEST_FILES=$(find .ai-agents -name "FINAL_STATUS_*.md" -o -name "CRITICAL_ISSUE_*.md" -o -name "SESSION_SUMMARY_*.md" | \
    xargs ls -t 2>/dev/null | head -5)

if [ -n "$LATEST_FILES" ]; then
    echo "$LATEST_FILES" | while read file; do
        BASENAME=$(basename "$file")
        FILEDATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file")
        echo "   📄 $BASENAME"
        echo "      Modified: $FILEDATE"
    done
else
    echo "   ℹ️  No recent status files found"
fi
echo ""

# 3. Latest handoff
echo "🤝 STEP 3: Check for handoff from previous agent"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
LATEST_HANDOFF=$(ls -t .ai-agents/handoff_*.json 2>/dev/null | head -1)
if [ -n "$LATEST_HANDOFF" ]; then
    HANDOFF_DATE=$(echo "$LATEST_HANDOFF" | grep -o '[0-9]\{8\}_[0-9]\{6\}' | sed 's/_/ /')
    echo "✅ $LATEST_HANDOFF"
    echo "   Created: $HANDOFF_DATE"

    # Show key info from handoff
    if command -v jq &> /dev/null; then
        echo "   Agent: $(jq -r '.agent_name // "unknown"' "$LATEST_HANDOFF")"
        echo "   Status: $(jq -r '.status // "unknown"' "$LATEST_HANDOFF")"
    fi
else
    echo "ℹ️  No handoff files found - fresh session"
fi
echo ""

# 4. Recent git activity
echo "📝 STEP 4: Recent git commits (last 5)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git log -5 --pretty=format:"   %h - %an, %ar: %s" 2>/dev/null || echo "   ⚠️  Not a git repository"
echo ""
echo ""

# 5. Urgent files
echo "🚨 STEP 5: Check for urgent files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
URGENT_FILES=$(ls -1 URGENT_* FOR_*_AGENT*.md 2>/dev/null)
if [ -n "$URGENT_FILES" ]; then
    echo "$URGENT_FILES" | while read file; do
        echo "   ⚠️  $file"
    done
else
    echo "✅ No urgent files found"
fi
echo ""

# 6. System health
echo "🏥 STEP 6: Quick health check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if verify script exists
if [ -f "scripts/verify_critical_features.sh" ]; then
    echo "✅ Verification script available"
    echo "   Run: ./scripts/verify_critical_features.sh"
else
    echo "⚠️  Verification script not found"
fi

# Check Railway health
echo -n "   Railway API: "
if curl -s -f -m 5 https://what-is-my-delta-site-production.up.railway.app/health > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Not responding"
fi

# Check domain
echo -n "   Domain API: "
if curl -s -f -m 5 https://whatismydelta.com/health > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Not responding"
fi

echo ""

# 7. Recommended reading order
echo "📚 RECOMMENDED READING ORDER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. .ai-agents/START_HERE.md (overview + latest status)"
echo "2. .ai-agents/SESSION_START_PROTOCOL.md (mandatory checklist)"

if [ -n "$LATEST_FILES" ]; then
    FIRST_FILE=$(echo "$LATEST_FILES" | head -1)
    echo "3. $FIRST_FILE (latest incident/status)"
fi

if [ -n "$LATEST_HANDOFF" ]; then
    echo "4. $LATEST_HANDOFF (previous agent handoff)"
fi

echo "5. ../CLAUDE.md (architecture overview)"
echo "6. ../TROUBLESHOOTING_CHECKLIST.md (if debugging)"
echo ""

# 8. Quick action commands
echo "⚡ QUICK ACTIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "# Read START_HERE"
echo "cat .ai-agents/START_HERE.md"
echo ""
echo "# Run verification"
echo "./scripts/verify_critical_features.sh"
echo ""
echo "# Check recent activity"
echo "git log -10 --oneline"
echo ""
echo "# View latest status file"
if [ -n "$LATEST_FILES" ]; then
    FIRST_FILE=$(echo "$LATEST_FILES" | head -1)
    echo "cat $FIRST_FILE"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Context summary complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
