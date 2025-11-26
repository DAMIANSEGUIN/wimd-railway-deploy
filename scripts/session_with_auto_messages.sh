#!/bin/bash
# Start an AI agent session with automatic message checking in background

AGENT_NAME="${AI_AGENT_NAME:-Claude-Code}"
POLL_INTERVAL="${POLL_INTERVAL:-5}"  # Check every 5 seconds
BROKER_URL="${AGENT_BROKER_URL:-http://localhost:8765}"

# Ensure broker is running
if ! curl -s -f "$BROKER_URL/health" > /dev/null 2>&1; then
    echo "🚀 Starting message broker..."
    ./scripts/start_broker.sh
    sleep 2
fi

# Start background message watcher
echo "🤖 Starting $AGENT_NAME session with auto-messaging..."
echo "   Messages will be checked automatically every ${POLL_INTERVAL}s"
echo ""

# Create a flag file to control the background process
SESSION_FLAG="/tmp/ai_agent_session_${AGENT_NAME}_$$"
touch "$SESSION_FLAG"

# Get the current TTY for output
TTY_DEVICE=$(tty)

# Background process that watches for messages
(
    while [ -f "$SESSION_FLAG" ]; do
        MESSAGES=$(curl -s "$BROKER_URL/messages/$AGENT_NAME" 2>/dev/null)

        if [ $? -eq 0 ] && [ "$MESSAGES" != "[]" ]; then
            MSG_COUNT=$(echo "$MESSAGES" | jq 'length' 2>/dev/null || echo 0)

            if [ "$MSG_COUNT" -gt 0 ]; then
                # Write directly to the TTY to ensure visibility
                {
                    # Sound alert
                    echo -e "\a"  # Terminal bell

                    echo ""
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "📨 [$(date +%H:%M:%S)] NEW MESSAGE(S) RECEIVED"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

                    # Display each message
                    echo "$MESSAGES" | jq -r '.[] |
                        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" +
                        "From: \(.from_agent)\n" +
                        "Type: \(.message_type)\n" +
                        "Time: \(.timestamp)\n" +
                        "Message:\n\(.body)\n" +
                        "ID: \(.id)"
                    '

                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo ""
                } > "$TTY_DEVICE"

                # Auto-acknowledge messages
                echo "$MESSAGES" | jq -r '.[].id' | while read msg_id; do
                    curl -s -X POST "$BROKER_URL/messages/$msg_id/ack" > /dev/null
                done

                # Desktop notification (optional, can be noisy)
                if command -v osascript &> /dev/null; then
                    FROM=$(echo "$MESSAGES" | jq -r '.[0].from_agent')
                    osascript -e "display notification \"Check your terminal\" with title \"Message from $FROM\""
                fi
            fi
        fi

        sleep "$POLL_INTERVAL"
    done
) &

WATCHER_PID=$!

echo "✅ Message watcher running (PID: $WATCHER_PID)"
echo "   To send message: ./scripts/agent_send.sh <agent> <type> <message>"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 SESSION READY - Work normally, messages will appear automatically"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Ending session..."
    rm -f "$SESSION_FLAG"
    kill $WATCHER_PID 2>/dev/null
    echo "✅ Message watcher stopped"
}

trap cleanup EXIT INT TERM

# Keep script running (in foreground or launch shell)
if [ "$1" = "--interactive" ]; then
    # Launch a new shell with the watcher running
    export AI_AGENT_NAME="$AGENT_NAME"
    export AGENT_BROKER_URL="$BROKER_URL"

    # Custom PS1 to show agent name
    export PS1="[$AGENT_NAME] \w $ "

    exec bash --noprofile --norc
else
    # Just keep running and show messages
    echo "Press Ctrl+C to end session"
    echo ""

    # Keep alive
    while [ -f "$SESSION_FLAG" ]; do
        sleep 1
    done
fi
