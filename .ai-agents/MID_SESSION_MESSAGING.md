# Mid-Session Agent Messaging (Zero User Involvement)

**Problem Solved:** Agents communicate while BOTH are actively working, no user intervention needed

---

## How It Works

### Architecture

```
Terminal 1 (Claude Code)               Message Broker               Terminal 2 (Gemini)
─────────────────────────             (localhost:8765)             ──────────────────────

┌─────────────────────┐                                           ┌─────────────────────┐
│ Main Session        │                                           │ Main Session        │
│ • Writing code      │                                           │ • Available         │
│ • Running commands  │                                           │ • Waiting for tasks │
└─────────────────────┘                                           └─────────────────────┘
         │                                                                  │
         │                                                                  │
┌─────────────────────┐               ┌──────────┐               ┌─────────────────────┐
│ Background Watcher  │──── Poll ────→│  Broker  │←──── Poll ────│ Background Watcher  │
│ (checks every 5s)   │               │ Messages │               │ (checks every 5s)   │
│                     │               └──────────┘               │                     │
│ • Sees new messages │                    ↑│                    │ • Sees new messages │
│ • Displays in term  │                    ││                    │ • Displays in term  │
│ • Auto-acknowledges │                    ││                    │ • Auto-acknowledges │
└─────────────────────┘                    ││                    └─────────────────────┘
         │                                 ││                             │
         │                                 ││                             │
         └────── Send Message ─────────────┘└───────── Send Message ─────┘
```

### Key Insight

**Background process polls for messages while you work**

- Runs in parallel with your session
- Doesn't interfere with your typing/commands
- Messages appear automatically between your commands

---

## Setup (Do This ONCE)

### Terminal 1 - Claude Code

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

export AI_AGENT_NAME="Claude-Code"
./scripts/session_with_auto_messages.sh --interactive
```

**What happens:**

1. Broker starts (if not running)
2. Background watcher starts (polls every 5s)
3. New shell prompt appears: `[Claude-Code] ~/path $`
4. You can work normally - messages will interrupt automatically

### Terminal 2 - Gemini

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

export AI_AGENT_NAME="Gemini"
./scripts/session_with_auto_messages.sh --interactive
```

**What happens:**

1. Connects to existing broker
2. Background watcher starts (polls every 5s)
3. New shell prompt appears: `[Gemini] ~/path $`
4. You can work normally - messages will interrupt automatically

---

## Usage: Live Demo

### Scenario: Claude needs SQL from Gemini

```bash
# ═══════════════════════════════════════════════════════════════
# TERMINAL 1 - CLAUDE CODE SESSION (already running with watcher)
# ═══════════════════════════════════════════════════════════════

[Claude-Code] ~/project $ # I'm working on code...

[Claude-Code] ~/project $ # I realize I need SQL data

[Claude-Code] ~/project $ ./scripts/agent_send.sh Gemini SQL_QUERY "SELECT id, email, LENGTH(password_hash) as hash_length, password_hash FROM users WHERE LOWER(email) = 'damian.seguin@gmail.com'"

✅ Message sent to Gemini (ID: msg_1764085900_0)

[Claude-Code] ~/project $ # I continue working while waiting...

[Claude-Code] ~/project $ # Writing more code...




# ═══════════════════════════════════════════════════════════════
# TERMINAL 2 - GEMINI SESSION (already running with watcher)
# ═══════════════════════════════════════════════════════════════

[Gemini] ~/project $ # Working on other tasks...

[Gemini] ~/project $ # Typing a command...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📨 [10:15:23] NEW MESSAGE(S) RECEIVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
From: Claude-Code
Type: SQL_QUERY
Time: 2025-11-25T15:15:20Z
Message:
SELECT id, email, LENGTH(password_hash) as hash_length, password_hash FROM users WHERE LOWER(email) = 'damian.seguin@gmail.com'
ID: msg_1764085900_0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Gemini] ~/project $ # Message appeared automatically!

[Gemini] ~/project $ # Now I run the query...

[Gemini] ~/project $ render run bash -c 'psql $DATABASE_URL -c "SELECT id, email, LENGTH(password_hash) as len, password_hash FROM users WHERE LOWER(email) = '\''damian.seguin@gmail.com'\''"'

 id   | email                    | len | password_hash
------+--------------------------+-----+-------------------
 abc  | damian.seguin@gmail.com  | 97  | a1b2c3...:salt123

[Gemini] ~/project $ # Send response back

[Gemini] ~/project $ ./scripts/agent_send.sh Claude-Code SQL_RESULT '{"id":"abc","hash_length":97,"format":"valid","hash":"a1b2c3...:salt123"}'

✅ Message sent to Claude-Code (ID: msg_1764085920_1)




# ═══════════════════════════════════════════════════════════════
# TERMINAL 1 - CLAUDE CODE SESSION (automatically receives)
# ═══════════════════════════════════════════════════════════════

[Claude-Code] ~/project $ # Still working...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📨 [10:15:45] NEW MESSAGE(S) RECEIVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
From: Gemini
Type: SQL_RESULT
Time: 2025-11-25T15:15:43Z
Message:
{"id":"abc","hash_length":97,"format":"valid","hash":"a1b2c3...:salt123"}
ID: msg_1764085920_1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Claude-Code] ~/project $ # Response appeared automatically!

[Claude-Code] ~/project $ # Now I can use this data...

[Claude-Code] ~/project $ echo "Great! Hash is valid format (97 chars). Now I'll implement the fix..."
```

---

## Key Features

### ✅ Zero User Involvement

- User doesn't copy/paste
- User doesn't say "check messages"
- Messages just appear in the terminal

### ✅ Works During Active Sessions

- Both agents working simultaneously
- Background watcher doesn't interfere
- Messages appear between commands

### ✅ Visual Alert

- Sound (terminal bell)
- Clear message box
- Desktop notification (optional)

### ✅ Auto-Acknowledge

- Messages marked as read automatically
- Won't see same message twice

### ✅ Session-Scoped

- Watcher stops when you exit session (Ctrl+C)
- Clean cleanup
- No orphan processes

---

## Configuration

### Adjust Poll Interval

```bash
# Check more frequently (every 2 seconds)
export POLL_INTERVAL=2
./scripts/session_with_auto_messages.sh --interactive

# Check less frequently (every 10 seconds)
export POLL_INTERVAL=10
./scripts/session_with_auto_messages.sh --interactive
```

**Trade-off:**

- Lower interval = faster message delivery, more CPU
- Higher interval = slower delivery, less CPU

**Recommended:** 5 seconds (default)

### Disable Desktop Notifications

Edit `scripts/session_with_auto_messages.sh`, comment out:

```bash
# if command -v osascript &> /dev/null; then
#     ...
# fi
```

### Change Broker URL

```bash
export AGENT_BROKER_URL="http://localhost:9000"
./scripts/session_with_auto_messages.sh --interactive
```

---

## Comparison: This vs Other Solutions

| Feature | Manual Copy/Paste | Git-Based | Mid-Session (This) |
|---------|-------------------|-----------|-------------------|
| **User says something** | 4 times | 2 times | **0 times** |
| **Works during session** | ❌ No | ❌ No | **✅ Yes** |
| **Real-time** | ✅ Yes | ❌ No | **✅ Yes** |
| **Automatic delivery** | ❌ No | ❌ No | **✅ Yes** |
| **Setup complexity** | None | Low | Medium |

---

## Troubleshooting

### "Messages not appearing"

**Check:** Is watcher running?

```bash
ps aux | grep session_with_auto_messages
# Should show background process
```

**Check:** Is broker running?

```bash
curl http://localhost:8765/health
# Should return: {"status": "ok"}
```

### "Watcher stops randomly"

**Cause:** Session flag file deleted
**Fix:** Ensure `/tmp/ai_agent_session_*` files exist while session active

### "Too many notifications"

**Reduce frequency:**

```bash
export POLL_INTERVAL=10  # Check every 10 seconds instead of 5
```

### "Can't send messages"

**Check:** Agent name set?

```bash
echo $AI_AGENT_NAME
# Should show: Claude-Code or Gemini
```

---

## Advanced: Multiple Agents

```bash
# Terminal 1 - Claude Code
export AI_AGENT_NAME="Claude-Code"
./scripts/session_with_auto_messages.sh --interactive

# Terminal 2 - Gemini
export AI_AGENT_NAME="Gemini"
./scripts/session_with_auto_messages.sh --interactive

# Terminal 3 - Codex
export AI_AGENT_NAME="Codex"
./scripts/session_with_auto_messages.sh --interactive

# All three can now message each other mid-session!
```

---

## How Background Watcher Works

### Technical Details

```bash
# Creates flag file: /tmp/ai_agent_session_Claude-Code_12345
# Starts background process that:
while [ -f flag_file ]; do
    # 1. Check broker for messages
    messages=$(curl http://localhost:8765/messages/Claude-Code)

    # 2. If messages found, display them
    if [ messages != "[]" ]; then
        echo "NEW MESSAGE!"
        display_message
        acknowledge_message
    fi

    # 3. Wait 5 seconds
    sleep 5
done
```

**Process Tree:**

```
bash (your session)
  └─ session_with_auto_messages.sh
       ├─ bash (interactive shell) ← You type here
       └─ bash (background watcher) ← Polls for messages
```

**Cleanup:**

- When you Ctrl+C or exit
- Trap signal kills background process
- Removes flag file
- No orphan processes left

---

## THIS is the solution you wanted

**Before:** You are the messenger between active agents

**After:** Agents see messages automatically while both working

**Your involvement during session:** **ZERO**
