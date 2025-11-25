#!/bin/bash
# Start the AI agent message broker in background

BROKER_PID_FILE=".ai-agents/broker.pid"

# Check if already running
if [ -f "$BROKER_PID_FILE" ]; then
    PID=$(cat "$BROKER_PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "✅ Broker already running (PID: $PID)"
        echo "   Check messages: ./scripts/agent_receive.sh"
        exit 0
    else
        rm "$BROKER_PID_FILE"
    fi
fi

echo "🚀 Starting AI agent message broker..."

# Start broker in background
nohup python3 scripts/agent_broker.py > .ai-agents/broker.log 2>&1 &
BROKER_PID=$!

# Save PID
echo "$BROKER_PID" > "$BROKER_PID_FILE"

# Wait a moment for startup
sleep 2

# Verify it's running
if ps -p "$BROKER_PID" > /dev/null 2>&1; then
    echo "✅ Broker started (PID: $BROKER_PID)"
    echo "   Logs: .ai-agents/broker.log"
    echo "   URL: http://localhost:8765"
    echo ""
    echo "To stop: kill $BROKER_PID"
else
    echo "❌ Failed to start broker"
    cat .ai-agents/broker.log
    rm "$BROKER_PID_FILE"
    exit 1
fi
