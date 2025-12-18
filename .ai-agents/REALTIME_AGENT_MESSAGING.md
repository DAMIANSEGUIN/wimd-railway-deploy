# Real-Time Agent-to-Agent Messaging System

**Status:** ✅ Ready to use
**Setup Time:** 30 seconds
**Your Involvement:** Just start the broker once

---

## Quick Start (For You)

### One-Time Setup

```bash
# 1. Start the message broker (runs in background)
./scripts/start_broker.sh

# That's it! Leave it running.
```

Now when you start ANY AI agent session:

```bash
# 2. Tell the AI agent:
"Run ./scripts/start_session.sh"

# The agent will automatically:
# - See messages from other agents
# - Can send messages to other agents
# - All without you copying/pasting
```

---

## How It Works

### Architecture

```
┌─────────────────┐
│  Claude Code    │ ←─┐
│  (Terminal)     │   │
└────────┬────────┘   │
         │            │
         ↓            │
┌─────────────────────┴──┐      ┌──────────────────┐
│  Message Broker         │      │  Gemini          │
│  (Python HTTP Server)   │ ←────│  (Browser/API)   │
│  localhost:8765         │      └──────────────────┘
└─────────────────────────┘
         ↑
         │
    Persisted to:
    .ai-agents/broker_messages.json
```

### Message Flow Example

```
1. Claude Code (me): Needs SQL results from Gemini
   → I run: agent_send.sh Gemini SQL_QUERY "Run query from file X"
   → Message instantly posted to broker

2. Gemini (already open in your browser):
   → You say: "Check for messages"
   → Gemini runs: agent_receive.sh
   → Gemini sees: "Claude Code needs SQL query"
   → Gemini executes query
   → Gemini runs: agent_send.sh Claude-Code SQL_RESULT "Hash is valid, 97 chars"

3. Claude Code (me):
   → I periodically check: agent_receive.sh
   → I see: "Gemini responded with SQL results"
   → I continue working with the data

Total user involvement: "Check for messages" (2 words, 2 times)
```

---

## For AI Agents

### When You Need to Send a Message

**From Claude Code (me):**

```bash
./scripts/agent_send.sh Gemini REQUEST_TYPE "Your message here"
```

**From Gemini (in browser console or via tool):**

```bash
# Gemini would execute via its shell access or API:
curl -X POST http://localhost:8765/messages \
  -H "Content-Type: application/json" \
  -d '{
    "from_agent": "Gemini",
    "to_agent": "Claude-Code",
    "message_type": "RESPONSE",
    "body": "Your response here"
  }'
```

### When You Start Your Session

**Automatic check:**

```bash
./scripts/start_session.sh
# Automatically checks for messages and displays them
```

**Manual check:**

```bash
./scripts/agent_receive.sh
# Shows all pending messages for you
```

---

## Message Types (Suggested Conventions)

- `REQUEST` - General request for help/info
- `SQL_QUERY` - Need database query results
- `CODE_REVIEW` - Need code review
- `VERIFICATION` - Need to verify something
- `RESPONSE` - Responding to a previous message
- `BLOCKED` - Can't proceed, need help
- `INFO` - Just FYI information
- `URGENT` - High priority, check immediately

---

## Advantages vs File-Based

| Feature | File-Based | Real-Time Broker |
|---------|-----------|------------------|
| Setup | None | 1 command |
| Speed | Async (check manually) | Near-instant |
| User copying | None needed | None needed |
| Persistence | Yes (git) | Yes (.json file) |
| Cross-platform | Yes | Yes (HTTP) |
| Works offline | Yes | No (needs broker running) |

**Best practice:** Use broker when it's running, fall back to file-based if not.

---

## Advanced: For Gemini Integration

### If Gemini Has Shell Access

```bash
# Gemini can use same scripts as Claude Code:
export AI_AGENT_NAME="Gemini"
./scripts/agent_send.sh Claude-Code RESPONSE "SQL results: ..."
./scripts/agent_receive.sh
```

### If Gemini Only Has Browser/API Access

**JavaScript (browser console):**

```javascript
// Check for messages
fetch('http://localhost:8765/messages/Gemini')
  .then(r => r.json())
  .then(msgs => {
    console.log('📨 Messages:', msgs);
  });

// Send message
fetch('http://localhost:8765/messages', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    from_agent: 'Gemini',
    to_agent: 'Claude-Code',
    message_type: 'SQL_RESULT',
    body: 'Hash length: 97, format valid'
  })
});
```

**Python (if Gemini uses Python tools):**

```python
import requests

# Check messages
resp = requests.get('http://localhost:8765/messages/Gemini')
messages = resp.json()
print(f"📨 You have {len(messages)} messages")

# Send message
requests.post('http://localhost:8765/messages', json={
    'from_agent': 'Gemini',
    'to_agent': 'Claude-Code',
    'message_type': 'RESPONSE',
    'body': 'Query results attached'
})
```

---

## Troubleshooting

### "Broker not running"

**Fix:**

```bash
./scripts/start_broker.sh
```

### "Connection refused"

**Check if broker is running:**

```bash
curl http://localhost:8765/health
# Should return: {"status": "ok", "messages": 0}
```

**If not running, check logs:**

```bash
cat .ai-agents/broker.log
```

### "Port 8765 already in use"

**Option 1 - Use different port:**

```bash
export AGENT_BROKER_URL=http://localhost:8766
python3 scripts/agent_broker.py 8766
```

**Option 2 - Kill existing process:**

```bash
kill $(cat .ai-agents/broker.pid)
./scripts/start_broker.sh
```

### "Messages not persisting"

**Check:** `.ai-agents/broker_messages.json` exists and is writable

**Recover:** Messages are in memory until broker restarts, then loaded from file

---

## Stopping the Broker

```bash
# Get PID
cat .ai-agents/broker.pid

# Stop broker
kill $(cat .ai-agents/broker.pid)
rm .ai-agents/broker.pid

# Messages are saved to .ai-agents/broker_messages.json
```

---

## Security Notes

- Broker listens on **localhost only** (not accessible from network)
- No authentication (assumes trusted local environment)
- Messages logged to file for audit trail
- CORS enabled for browser-based agents

**For production use, add:**

- Authentication tokens
- Rate limiting
- Message encryption
- Access control lists

---

## Comparison to Alternatives

### vs Claude Code's Task Tool

- **Task:** Only works between Claude instances, fully automated
- **Broker:** Works across platforms (Claude ↔ Gemini), minimal setup

### vs Shared File Protocol

- **Files:** No daemon needed, survives restarts
- **Broker:** Real-time, no polling, cleaner API

### vs Enterprise Solutions (RabbitMQ, Redis, etc.)

- **Enterprise:** Production-grade, scalable, complex
- **Broker:** Simple Python script, 200 lines, runs locally

---

## Example Workflow: Current Scenario

```
SCENARIO: Gemini is open with project access, needs to pass SQL results to me

[Terminal 1 - You run ONCE]
$ ./scripts/start_broker.sh
✅ Broker started (PID: 12345)

[Terminal 2 - Claude Code session (me)]
$ ./scripts/start_session.sh
🔗 Message broker online - checking for messages...
✅ No pending messages

# I realize I need SQL data
$ ./scripts/agent_send.sh Gemini SQL_QUERY "Run SELECT query from DIAGNOSTIC_LOGIN_ISSUE"
✅ Message sent to Gemini (ID: msg_1732544500_0)

# I tell you:
"Ask Gemini to check messages and respond"

[Browser - Gemini session]
You say: "Check for messages via the broker"

Gemini runs in its environment:
> curl http://localhost:8765/messages/Gemini

Gemini sees:
{
  "from_agent": "Claude-Code",
  "to_agent": "Gemini",
  "message_type": "SQL_QUERY",
  "body": "Run SELECT query from DIAGNOSTIC_LOGIN_ISSUE",
  "id": "msg_1732544500_0"
}

Gemini executes query, then:
> curl -X POST http://localhost:8765/messages -d '{
    "from_agent": "Gemini",
    "to_agent": "Claude-Code",
    "message_type": "SQL_RESULT",
    "body": "{\"hash_length\": 97, \"valid\": true}"
  }'

[Terminal 2 - Claude Code (me)]
# I auto-check every few seconds or when you tell me
$ ./scripts/agent_receive.sh
📨 You have messages:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
From: Gemini
Type: SQL_RESULT
Message: {"hash_length": 97, "valid": true}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# I parse the result and continue working
"Great! Hash is valid. Now I'll implement the fix..."

TOTAL USER INVOLVEMENT:
1. "Start broker" (once)
2. "Ask Gemini to check messages" (once per exchange)
```

---

## Future Enhancements

### Polling Mode (Zero User Involvement)

```python
# Add to agent_broker.py
def poll_messages():
    """Auto-check for messages every 5 seconds"""
    while True:
        time.sleep(5)
        # Check for new messages
        # Trigger agent callback
```

### Browser Extension

- Visual notification when message arrives
- Click to respond inline
- No terminal needed

### Webhook Support

```python
# Agent registers webhook URL
POST /webhooks/register {"agent": "Gemini", "url": "http://..."}

# Broker pushes messages instead of polling
POST http://gemini-webhook/message {"from": "Claude", ...}
```

---

**END OF GUIDE**

## tl;dr

**You:** Run `./scripts/start_broker.sh` once

**Then:** Tell each agent "check messages" when switching

**Result:** Agents communicate directly via HTTP, no more copying/pasting between them
