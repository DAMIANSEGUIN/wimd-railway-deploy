# Git-Based Agent Communication (The Practical Solution)

**Status:** ✅ Fully implemented and tested
**Why it works:** Uses git (tool you already use) + desktop notifications
**Your involvement:** Just pull/push - git does the rest

---

## Why This Actually Works

### The Problem with Other Solutions

- **Message broker:** Requires agents to poll/check manually
- **Orchestrator:** Needs persistent daemon processes
- **Direct API:** Agents aren't running continuously

### Why Git-Based Solves It

```
✅ You're already using git for every session
✅ Agents already commit their work
✅ Git hooks trigger automatically on commit
✅ Desktop notifications alert you instantly
✅ No new infrastructure needed
✅ Works offline (async by design)
```

---

## How It Works

### Architecture

```
Claude Code Session                Git Repository               Gemini Session
─────────────────                 ───────────────              ──────────────

1. Needs SQL data
   │
   ├──> Create request file
   │    .ai-agents/request_for_Gemini_12345.json
   │
   ├──> git add + git commit
   │                              │
   │                              ├──> Post-commit hook runs
   │                              │    • Detects request file
   │                              │    • Sends desktop notification
   │                              │
   │                              ├──> 🔔 "Claude → Gemini: SQL_QUERY"
   │                                   (macOS notification appears)
   │
   │                                                            You see notification
   │                                                            │
   │                                                            ├──> git pull
   │                                                            │
   │                                                            ├──> Read request file
   │                                                            │
   │                                                            ├──> Run SQL query
   │                                                            │
   │                                                            ├──> Create response file
   │                                                            │    .ai-agents/response_req_12345.json
   │                                                            │
   │                                                            ├──> git add + git commit
   │                              │
   │                              ├──> Post-commit hook runs
   │                              │    • Detects response file
   │                              │    • Sends desktop notification
   │                              │
   │                              ├──> 🔔 "Gemini → Claude: Response ready"
   │
   ├──> git pull
   │
   ├──> Read response file
   │
   └──> Continue work with SQL results
```

---

## Setup (One-Time, 30 Seconds)

### 1. Git Hook is Already Installed ✅

```bash
# Already done:
.git/hooks/post-commit
```

### 2. Test Desktop Notifications

```bash
# macOS
osascript -e 'display notification "Test message" with title "AI Agent"'

# Linux (Ubuntu)
notify-send "AI Agent" "Test message"

# Windows
# Use Windows Toast notifications or Powershell
```

---

## Usage

### For Claude Code (Requesting Agent)

**When you need something from Gemini:**

```bash
# 1. Create request
export AI_AGENT_NAME="Claude-Code"
./scripts/git_request.sh Gemini SQL_QUERY "Run query from DIAGNOSTIC_LOGIN_ISSUE"

# Output:
# ✅ Request created: .ai-agents/request_for_Gemini_12345.json
# Next step: Commit this request

# 2. Commit (triggers automatic notification)
git add .ai-agents/request_for_Gemini_12345.json
git commit -m "Request: Gemini to run SQL query"

# 3. Post-commit hook automatically:
#    • Detects request file
#    • Sends notification: "Claude → Gemini: SQL_QUERY"

# 4. Push (so Gemini can pull)
git push

# DONE - You'll get notified when response is ready
```

### For Gemini (Responding Agent)

**When you get notification:**

```bash
# 1. Pull to get request
git pull

# 2. Check what's being requested
ls .ai-agents/request_for_Gemini_*.json
cat .ai-agents/request_for_Gemini_12345.json

# 3. Execute the request (example: SQL query)
export DATABASE_URL="your-postgres-url"
psql $DATABASE_URL -c "SELECT ..." > /tmp/sql_result.txt

# 4. Create response
export AI_AGENT_NAME="Gemini"
./scripts/git_respond.sh \
    .ai-agents/request_for_Gemini_12345.json \
    '{"hash_length": 97, "format": "valid"}'

# 5. Commit (triggers automatic notification to Claude)
git add .ai-agents/response_req_12345.json
git commit -m "Response: SQL query results"

# 6. Push
git push

# DONE - Claude will be notified automatically
```

---

## Your Involvement: Minimal

### Before (Manual Copy/Paste)

```
1. Claude: "I need SQL results for user X"
2. You: Copy entire message
3. You: Paste to Gemini
4. Gemini: Executes query
5. Gemini: "Here are the results: ..."
6. You: Copy entire response
7. You: Paste to Claude
8. Claude: Continues work
```

### After (Git-Based)

```
1. Claude: Creates request, commits, pushes
2. 🔔 Notification: "Claude → Gemini: SQL_QUERY"
3. You: See notification → Tell Gemini: "git pull and check requests"
4. Gemini: Pulls, executes, responds, commits, pushes
5. 🔔 Notification: "Gemini → Claude: Response ready"
6. You: Tell Claude: "git pull and check responses"
7. Claude: Pulls, reads response, continues
```

**Your involvement:**

- See 2 notifications
- Say 2 sentences total
- No copying/pasting content

---

## Advantages

### ✅ Async by Design

- Agents don't need to be online at same time
- Request sits in git until Gemini is ready
- Response sits in git until Claude pulls

### ✅ Auditable

- All requests/responses in git history
- Can see when request was made, when answered
- Can trace communication flow

### ✅ No New Infrastructure

- Uses git (already using)
- Uses desktop notifications (built-in OS)
- No broker daemon to manage
- No port conflicts

### ✅ Works Offline

- Commit locally even without internet
- Push when connection available
- Other agent pulls when ready

### ✅ Persistent

- Survives agent crashes
- Survives computer restarts
- Nothing lost if process dies

### ✅ Cross-Platform

- Works with any agent that uses git
- Claude Code, Gemini, Codex, human devs
- Same protocol for everyone

---

## Notifications

### macOS (Built-in)

```bash
osascript -e 'display notification "Message" with title "Title"'
```

**Appears:** Top-right corner
**Sound:** System notification sound
**Action:** Click to see details

### Linux (notify-send)

```bash
notify-send "Title" "Message"
```

**Appears:** Top-right corner (Ubuntu/GNOME)
**Duration:** 5 seconds default

### Windows (Powershell)

```powershell
Add-Type -AssemblyName System.Windows.Forms
$notification = New-Object System.Windows.Forms.NotifyIcon
$notification.Icon = [System.Drawing.SystemIcons]::Information
$notification.BalloonTipText = "Message"
$notification.BalloonTipTitle = "Title"
$notification.Visible = $true
$notification.ShowBalloonTip(5000)
```

---

## Advanced: Auto-Pull on Notification

### Make It Even More Automatic

**Create notification action script:**

```bash
# ~/.ai-agent-notification-handler.sh
#!/bin/bash

# When notification clicked, auto-pull
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
git pull

# Check for messages
if [ -n "$AI_AGENT_NAME" ]; then
    ./scripts/check_agent_messages.sh
fi
```

**Update git hook to trigger script:**

```bash
# In .git/hooks/post-commit, add:
osascript -e 'tell application "Terminal" to do script "~/.ai-agent-notification-handler.sh"'
```

**Result:** Notification appears → Click it → Terminal opens → Auto-pulls → Shows messages

---

## Example: Real Workflow

### Scenario: Claude needs SQL from Gemini

```bash
# ═══════════════════════════════════════════════════════
# CLAUDE CODE SESSION
# ═══════════════════════════════════════════════════════

$ export AI_AGENT_NAME="Claude-Code"

# I realize I need database info
$ ./scripts/git_request.sh Gemini SQL_QUERY \
    "SELECT id, email, LENGTH(password_hash), password_hash FROM users WHERE email = 'damian.seguin@gmail.com'"

✅ Request created: .ai-agents/request_for_Gemini_1732544500.json

$ git add .ai-agents/request_for_Gemini_1732544500.json
$ git commit -m "Request: Gemini run password hash query"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📨 AGENT MESSAGE DETECTED IN COMMIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📬 NEW REQUEST
   From: Claude-Code
   To: Gemini
   Type: SQL_QUERY
   File: .ai-agents/request_for_Gemini_1732544500.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$ git push

# ═══════════════════════════════════════════════════════
# USER'S MAC - DESKTOP NOTIFICATION APPEARS
# ═══════════════════════════════════════════════════════

🔔 AI Agent Request
   Claude-Code → Gemini: SQL_QUERY

# User sees notification, switches to Gemini session

# ═══════════════════════════════════════════════════════
# GEMINI SESSION
# ═══════════════════════════════════════════════════════

$ export AI_AGENT_NAME="Gemini"
$ git pull

From github.com:user/WIMD-Railway-Deploy-Project
   1 file changed, 10 insertions(+)
   create mode 100644 .ai-agents/request_for_Gemini_1732544500.json

$ cat .ai-agents/request_for_Gemini_1732544500.json

{
  "request_id": "req_1732544500",
  "from_agent": "Claude-Code",
  "to_agent": "Gemini",
  "request_type": "SQL_QUERY",
  "payload": {
    "description": "SELECT id, email, LENGTH(password_hash), password_hash FROM users WHERE email = 'damian.seguin@gmail.com'"
  }
}

# Gemini executes query
$ railway run bash -c 'psql $DATABASE_URL -c "SELECT id, email, LENGTH(password_hash) as len, password_hash FROM users WHERE LOWER(email) = '\''damian.seguin@gmail.com'\''"'

 id   | email                    | len | password_hash
------+--------------------------+-----+-------------------
 abc  | damian.seguin@gmail.com  | 97  | a1b2c3...:d4e5f6...

# Gemini creates response
$ ./scripts/git_respond.sh \
    .ai-agents/request_for_Gemini_1732544500.json \
    '{"id":"abc","email":"damian.seguin@gmail.com","hash_length":97,"hash_valid":true,"format":"SHA256:salt"}'

✅ Response created: .ai-agents/response_req_1732544500.json

$ git add .ai-agents/response_req_1732544500.json
$ git commit -m "Response: Password hash query results"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📨 AGENT MESSAGE DETECTED IN COMMIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📭 NEW RESPONSE
   From: Gemini
   To: Claude-Code
   File: .ai-agents/response_req_1732544500.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$ git push

# ═══════════════════════════════════════════════════════
# USER'S MAC - DESKTOP NOTIFICATION APPEARS
# ═══════════════════════════════════════════════════════

🔔 AI Agent Response
   Gemini → Claude-Code: Response ready

# User sees notification, switches back to Claude

# ═══════════════════════════════════════════════════════
# CLAUDE CODE SESSION
# ═══════════════════════════════════════════════════════

$ git pull

From github.com:user/WIMD-Railway-Deploy-Project
   1 file changed, 9 insertions(+)
   create mode 100644 .ai-agents/response_req_1732544500.json

$ cat .ai-agents/response_req_1732544500.json

{
  "request_id": "req_1732544500",
  "from_agent": "Gemini",
  "to_agent": "Claude-Code",
  "status": "COMPLETED",
  "payload": {
    "id": "abc",
    "email": "damian.seguin@gmail.com",
    "hash_length": 97,
    "hash_valid": true,
    "format": "SHA256:salt"
  }
}

# Claude continues with the fix
"Great! The hash is valid format (97 chars, SHA256:salt). The issue must be elsewhere. Let me check the salt extraction logic..."
```

---

## Comparison: Your Involvement

| Method | Human Actions | Time Spent |
|--------|---------------|------------|
| **Manual Copy/Paste** | 4 (copy request, paste, copy response, paste) | ~60 seconds |
| **Message Broker** | 2 (tell to check messages twice) | ~30 seconds |
| **Git-Based** | 2 (see notifications, say "check git" twice) | ~20 seconds |
| **Orchestrator** | 0 (fully automatic) | 0 seconds |

**Git-based is practical middle ground:**

- Not fully automatic (that requires orchestrator)
- But close enough (2 simple actions vs manual copying)
- Uses tools you already have (git + notifications)

---

## Troubleshooting

### "No notification appeared"

**Check:** Notifications enabled for Terminal/iTerm
**macOS:** System Preferences → Notifications → Terminal → Allow notifications

### "Git hook didn't run"

**Check:** Hook is executable

```bash
chmod +x .git/hooks/post-commit
```

### "Can't find request file"

**Check:** Did you pull first?

```bash
git pull
ls .ai-agents/request_*.json
```

---

## Benefits Summary

✅ **Async:** Agents don't wait for each other
✅ **Persistent:** Survives crashes, restarts
✅ **Auditable:** Full history in git
✅ **Simple:** Just commit files
✅ **Automatic:** Hooks + notifications = minimal effort
✅ **Cross-platform:** Works anywhere git works
✅ **No infrastructure:** No servers, brokers, daemons

---

## This is the REAL automation

**Not perfect (orchestrator would be better) but:**

- Works TODAY with tools you have
- Requires no new infrastructure
- Reduces your work by 70%
- Agents can work async
- Nothing gets lost

**For your current project, this is the sweet spot.**
