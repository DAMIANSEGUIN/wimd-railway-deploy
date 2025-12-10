#!/bin/bash
# Agent Task Completion Script
# Agents call this when they finish a task to trigger next agent

AGENT_NAME="$1"
TASK_ID="$2"
DELIVERABLES="$3"  # JSON array as string

if [ -z "$AGENT_NAME" ] || [ -z "$TASK_ID" ]; then
    echo "Usage: ./complete_task.sh <agent_name> <task_id> '<deliverables_json>'"
    exit 1
fi

# Create completion gate file
GATE_FILE=".ai-agents/status/${TASK_ID}_${AGENT_NAME}.complete"

cat > "$GATE_FILE" << EOF
{
  "task": "$TASK_ID",
  "agent": "$AGENT_NAME",
  "completed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "deliverables": $DELIVERABLES,
  "validation_status": "passed"
}
EOF

echo "✅ Task complete: $TASK_ID"
echo "📝 Gate file created: $GATE_FILE"
echo ""

# Check who's ready to work next
echo "🔍 Checking for next ready agent..."
echo ""

for agent in claude_code gemini codex; do
    echo "Checking $agent..."
    result=$(python3 .ai-agents/scripts/check_gates.py "$agent" 2>&1)

    # Check if agent is ready (exit code 0)
    if echo "$result" | grep -q "🚀 READY TO START"; then
        task_name=$(echo "$result" | grep "Task:" | sed 's/.*Task: //')

        echo ""
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║  🚀 NEXT AGENT READY                                       ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Agent: $agent"
        echo "Task: $task_name"
        echo ""

        # Write message directly to next agent's inbox
        mkdir -p .ai-agents/queue
        cat > ".ai-agents/queue/${agent}_inbox.txt" << INBOX_MSG
From: $AGENT_NAME
Task: $task_name
Previous: $TASK_ID completed
Dependencies: All satisfied

Your task is ready. Check gate status with:
./scripts/start_session.sh $agent
INBOX_MSG

        echo "✉️  Message queued for $agent"
        echo "📬 Location: .ai-agents/queue/${agent}_inbox.txt"
        echo ""
        echo "When Damian starts $agent, they will see this message automatically."
        echo ""

        # Only show first ready agent
        break
    fi
done

echo "✅ Task completion processing complete"
