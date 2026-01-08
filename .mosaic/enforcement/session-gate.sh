#!/bin/bash
# .mosaic/enforcement/session-gate.sh
# Machine-enforceable session validation - must pass before any work
# Usage: ./mosaic/enforcement/session-gate.sh

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$REPO_ROOT"

echo "🚨 MOSAIC SESSION GATE - Validation Required"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This script validates that you have:"
echo "1. Read the mandatory briefing"
echo "2. Understand current state"
echo "3. Acknowledged user decisions"
echo "4. Know what was just completed"
echo ""

FAILURES=0

# ============================================================================
# CHECK 1: Verify .mosaic state files exist and are valid
# ============================================================================
echo "📋 Check 1: State files exist and are valid JSON..."

REQUIRED_FILES=(
  ".mosaic/agent_state.json"
  ".mosaic/blockers.json"
  ".mosaic/current_task.json"
  ".mosaic/session_log.jsonl"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "❌ FAIL: Missing required file: $file"
    FAILURES=$((FAILURES + 1))
  else
    if [[ "$file" == *.json ]]; then
      if ! jq empty "$file" 2>/dev/null; then
        echo "❌ FAIL: Invalid JSON in $file"
        FAILURES=$((FAILURES + 1))
      fi
    fi
  fi
done

if [ $FAILURES -eq 0 ]; then
  echo "✅ PASS: All state files exist and valid"
fi

# ============================================================================
# CHECK 2: Extract current state information
# ============================================================================
echo ""
echo "📋 Check 2: Reading current state..."

if command -v jq &> /dev/null && [ $FAILURES -eq 0 ]; then
  CURRENT_AGENT=$(jq -r '.current_agent' .mosaic/agent_state.json)
  CURRENT_TASK=$(jq -r '.current_task' .mosaic/agent_state.json)
  HANDOFF_MESSAGE=$(jq -r '.handoff_message' .mosaic/agent_state.json)

  echo "   Current Agent: $CURRENT_AGENT"
  echo "   Current Task: $CURRENT_TASK"
  echo "   Handoff: $HANDOFF_MESSAGE"
  echo ""

  # Check if briefing was acknowledged
  BRIEFING_ACK=$(jq -r '.briefing_acknowledgment // "null"' .mosaic/agent_state.json)

  if [ "$BRIEFING_ACK" = "null" ]; then
    echo "⚠️  WARNING: No briefing acknowledgment found"
    echo "   Required: Add 'briefing_acknowledgment' field to .mosaic/agent_state.json"
    echo "   This proves you read .mosaic/MANDATORY_AGENT_BRIEFING.md"
    FAILURES=$((FAILURES + 1))
  else
    echo "✅ PASS: Briefing acknowledgment found"
  fi
else
  echo "⚠️  WARNING: jq not installed, cannot extract state"
fi

# ============================================================================
# CHECK 3: Verify git state
# ============================================================================
echo ""
echo "📋 Check 3: Verifying git state..."

CURRENT_BRANCH=$(git branch --show-current)
GIT_STATUS=$(git status --porcelain)

echo "   Current branch: $CURRENT_BRANCH"

if [ -n "$GIT_STATUS" ]; then
  echo "   Working tree: DIRTY (uncommitted changes)"
  echo ""
  echo "   Uncommitted files:"
  git status --short | head -10
else
  echo "   Working tree: CLEAN"
fi

ACTUAL_LAST_COMMIT=$(git rev-parse --short HEAD)
echo "   Git HEAD: $ACTUAL_LAST_COMMIT"
echo ""
echo "✅ PASS: Git state validated"

# ============================================================================
# CHECK 4: User decisions verification
# ============================================================================
echo ""
echo "📋 Check 4: User decisions..."

if command -v jq &> /dev/null; then
  USER_DECISIONS=$(jq -r '.user_decisions // {}' .mosaic/agent_state.json)

  if [ "$USER_DECISIONS" = "{}" ]; then
    echo "   No user decisions recorded"
  else
    echo "   User decisions on record:"
    echo "$USER_DECISIONS" | jq -r 'to_entries[] | "   - \(.key): \(.value)"'
  fi

  echo ""
  echo "✅ PASS: User decisions loaded"
fi

# ============================================================================
# CHECK 5: Required documentation exists
# ============================================================================
echo ""
echo "📋 Check 5: Required documentation exists..."

REQUIRED_DOCS=(
  ".mosaic/MANDATORY_AGENT_BRIEFING.md"
  ".ai-agents/CROSS_AGENT_PROTOCOL.md"
  ".ai-agents/INTENT_FRAMEWORK.md"
  "CLAUDE.md"
  "DOCUMENTATION_MAP.md"
)

for doc in "${REQUIRED_DOCS[@]}"; do
  if [ ! -f "$doc" ]; then
    echo "❌ FAIL: Missing required doc: $doc"
    FAILURES=$((FAILURES + 1))
  fi
done

if [ $FAILURES -eq 0 ]; then
  echo "✅ PASS: All required docs present"
fi

# ============================================================================
# INTERACTIVE VERIFICATION (Optional)
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAILURES -gt 0 ]; then
  echo "❌ SESSION GATE: $FAILURES checks FAILED"
  echo ""
  echo "You must fix the failures above before proceeding."
  echo ""
  echo "Required actions:"
  echo "1. Read .mosaic/MANDATORY_AGENT_BRIEFING.md"
  echo "2. Read .mosaic/agent_state.json (current state)"
  echo "3. Read .mosaic/blockers.json (known issues)"
  echo "4. Update .mosaic/agent_state.json with briefing_acknowledgment"
  echo ""
  echo "Example acknowledgment:"
  echo '  "briefing_acknowledgment": {'
  echo '    "agent": "claude_code_terminal",'
  echo '    "briefing_version": "1.0",'
  echo '    "acknowledged_at": "2026-01-05T17:30:00Z"'
  echo '  }'
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi

echo "✅ SESSION GATE: ALL CHECKS PASSED"
echo ""
echo "You may proceed with work."
echo ""
echo "Next steps:"
echo "1. Review handoff message: $HANDOFF_MESSAGE"
echo "2. Check current task: $CURRENT_TASK"
echo "3. Read relevant docs per DOCUMENTATION_MAP.md"
echo "4. Follow INTENT framework (Intent → Check → Receipt)"
echo "5. Update .mosaic/agent_state.json when work complete"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 0
