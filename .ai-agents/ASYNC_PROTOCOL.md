# Async Agent-to-Agent Communication Protocol

**Purpose:** Allow AI agents to communicate without human intermediary

---

## Request Format

**File naming:** `.ai-agents/request_for_{TARGET_AGENT}_{TIMESTAMP}.json`

```json
{
  "request_id": "req_20251125_143000",
  "from_agent": "Claude-Code",
  "to_agent": "Gemini",
  "timestamp": "2025-11-25T14:30:00Z",
  "status": "PENDING",
  "request_type": "SQL_QUERY",
  "payload": {
    "description": "Need password hash from production database",
    "query": "SELECT id, email, LENGTH(password_hash), password_hash FROM users WHERE LOWER(email) = 'damian.seguin@gmail.com'",
    "context_files": [
      ".ai-agents/DIAGNOSTIC_LOGIN_ISSUE_2025-11-24.md"
    ]
  },
  "response_file": ".ai-agents/response_req_20251125_143000.json"
}
```

## Response Format

**File naming:** `.ai-agents/response_{REQUEST_ID}.json`

```json
{
  "request_id": "req_20251125_143000",
  "from_agent": "Gemini",
  "to_agent": "Claude-Code",
  "timestamp": "2025-11-25T14:35:00Z",
  "status": "COMPLETED",
  "payload": {
    "query_results": {
      "id": "abc-123",
      "email": "damian.seguin@gmail.com",
      "hash_length": 97,
      "hash_preview": "a1b2c3...d4e5f6:1234567890abcdef"
    },
    "diagnosis": "Hash format is valid (97 chars, has separator)"
  }
}
```

## Agent Instructions

### For Requesting Agent (e.g., Claude Code):
```bash
# 1. Create request file
cat > .ai-agents/request_for_Gemini_$(date +%s).json << EOF
{
  "from_agent": "Claude-Code",
  "to_agent": "Gemini",
  "request_type": "SQL_QUERY",
  ...
}
EOF

# 2. Commit and note for human
git add .ai-agents/request_for_Gemini_*.json
git commit -m "Request: Gemini to run SQL query"

# 3. Tell user: "Created request for Gemini. When you start Gemini next, it will see this automatically."
```

### For Responding Agent (e.g., Gemini):
```bash
# 1. On session start, check for requests
ls .ai-agents/request_for_Gemini_*.json | while read req; do
  echo "Found request: $req"
  # Read and process
done

# 2. Execute request and create response
cat > .ai-agents/response_req_xxx.json << EOF
{
  "request_id": "req_xxx",
  "status": "COMPLETED",
  ...
}
EOF

# 3. Commit response
git add .ai-agents/response_*.json
git commit -m "Response: SQL query results for Claude-Code"
```

### For User (Minimal Involvement):
```bash
# When switching between agents, just tell them:
# "Check for pending requests"

# That's it! No copying/pasting messages.
```

---

## Workflow Example

```
SCENARIO: Claude Code needs SQL results from Gemini

[Claude Code session]
Claude: I need SQL data. Creating request file...
Claude: *writes .ai-agents/request_for_Gemini_12345.json*
Claude: *commits file*
Claude: User, when you start Gemini next, tell it to check for requests.

[User ends Claude session, starts Gemini session]
User: "Check for pending requests"

[Gemini session]
Gemini: Found request_for_Gemini_12345.json
Gemini: It's asking for SQL query results...
Gemini: *runs SQL query*
Gemini: *writes .ai-agents/response_req_12345.json*
Gemini: *commits file*
Gemini: Response ready for Claude Code.

[User ends Gemini session, starts Claude Code session]
User: "Check for responses to your requests"

[Claude Code session]
Claude: Found response_req_12345.json
Claude: *reads SQL results*
Claude: Got the data! Continuing with fix...

[Done - user only said "check for requests/responses", didn't copy any content]
```

---

## Automation Scripts

### For start_session.sh (auto-check requests)
```bash
# Add to scripts/start_session.sh
echo "🔍 Checking for pending requests..."
AGENT_NAME="${AI_AGENT_NAME:-Claude-Code}"
REQUESTS=$(ls .ai-agents/request_for_${AGENT_NAME}_*.json 2>/dev/null)
if [ -n "$REQUESTS" ]; then
    echo "📨 You have pending requests!"
    echo "$REQUESTS" | while read req; do
        echo "  - $req"
    done
fi

echo "🔍 Checking for responses to your requests..."
RESPONSES=$(ls .ai-agents/response_req_*.json 2>/dev/null | while read resp; do
    REQ_AGENT=$(jq -r '.to_agent' "$resp")
    if [ "$REQ_AGENT" = "$AGENT_NAME" ]; then
        echo "$resp"
    fi
done)
if [ -n "$RESPONSES" ]; then
    echo "📬 You have responses!"
    echo "$RESPONSES"
fi
```

---

## Reducing User Involvement Further

### Option A: Git Hooks
```bash
# .git/hooks/post-checkout
# Auto-notify about requests when switching branches/sessions
./scripts/check_requests.sh
```

### Option B: Slack/Discord Bot
- Bot monitors .ai-agents/ folder
- When request file appears, bot pings target agent
- Agent processes and commits response
- Bot notifies requester
- User sees it happen but doesn't touch it

### Option C: Cron Job (Long-running)
```bash
# Run every 5 minutes
*/5 * * * * cd /path/to/project && ./scripts/process_requests.sh
```

---

## Benefits

✅ User involvement: "Check for requests" (not copying full messages)
✅ Async: Agents don't need to be online at same time
✅ Auditable: All requests/responses in git history
✅ Cross-platform: Works between Claude, Gemini, Codex, etc.
✅ Resumable: If agent crashes, request file persists

## Limitations

❌ Not real-time (requires user to start sessions)
❌ Still requires user to tell agents to check
❌ No automatic agent spawning

---

For TRUE zero-involvement automation, you'd need:
1. Long-running agent processes (not sessions)
2. Message broker (RabbitMQ, Redis, etc.)
3. Agent orchestrator (like LangChain, AutoGPT)

But file-based async is the simplest that works TODAY with your existing setup.
