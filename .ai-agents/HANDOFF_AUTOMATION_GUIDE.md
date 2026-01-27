# AI Agent Handoff Automation Guide

**Last Updated:** 2025-11-25
**Purpose:** Streamline context transfer between AI coding sessions

---

## Quick Start (For AI Agents)

### Starting a New Session

```bash
./scripts/start_session.sh
```

This automatically:

- Shows handoff from previous agent
- Lists critical files to read
- Displays git status
- Provides next steps

### Ending Your Session

```bash
./scripts/end_session.sh "Brief description of what you accomplished"
```

This automatically:

- Creates valid handoff JSON
- Archives old handoffs
- Validates JSON format
- Shows summary for next agent

---

## Manual Workflows (For Humans)

### When Starting Work with a New AI Agent

```bash
# Show the AI agent where to start
./scripts/show_latest_context.sh
```

Then copy this prompt to your AI:

```
I'm starting work on this project. Run: ./scripts/start_session.sh
```

### When Switching Between AI Agents Mid-Task

```bash
# Current agent ends session
./scripts/end_session.sh "Waiting for Gemini to analyze password hash"

# Tell next agent:
# "Run ./scripts/start_session.sh and read the handoff"
```

---

## Advanced Automation Options

### Option A: Git Hooks (Automatic on Commit)

Create `.git/hooks/post-commit`:

```bash
#!/bin/bash
# Auto-create handoff after every commit

LAST_MSG=$(git log -1 --pretty=%B)
./scripts/end_session.sh "Committed: $LAST_MSG"
```

**Pros:** Zero-effort handoffs
**Cons:** Creates many handoff files

### Option B: Claude Code Custom Slash Command

Create `.claude/commands/handoff.md`:

```markdown
When I say "/handoff", run:
1. ./scripts/end_session.sh with a summary of your work
2. Show me the handoff summary
3. Suggest files the next agent should read
```

**Pros:** Natural language trigger
**Cons:** Requires Claude Code CLI

### Option C: Scheduled Auto-Archive (Daily Cleanup)

Add to crontab:

```bash
# Archive handoffs older than 7 days (daily at 2am)
0 2 * * * cd /Users/damianseguin/WIMD-Deploy-Project && \
  find .ai-agents -name "handoff_*.json" -mtime +7 -exec mv {} .ai-agents/archive/ \;
```

**Pros:** Keeps workspace clean
**Cons:** May lose historical context

---

## Handoff JSON Schema

```json
{
  "timestamp": "ISO-8601 UTC timestamp",
  "agent_name": "Name of AI agent (Claude-Code, Gemini, etc)",
  "status": "Brief summary of current state",
  "git_state": {
    "commit": "Full git commit hash",
    "branch": "Current branch name",
    "uncommitted_changes": 0
  },
  "critical_features": {
    "auth_ui_present": ["file1", "file2"],
    "ps101_state_count": ["file1"],
    "api_base_configured": ["file1"]
  },
  "deployment_status": {
    "render_health": "true|false|unknown",
    "production_auth_present": 0
  },
  "last_commit": {
    "message": "Commit message",
    "author": "Author name",
    "timestamp": "ISO-8601 timestamp"
  },
  "tasks_in_progress": [
    "Task description 1",
    "Task description 2"
  ],
  "notes": "Any important context for next agent"
}
```

---

## Best Practices

### For Outgoing Agent (You're Ending Your Session)

1. ✅ **DO:** Include specific blockers in status
   - Good: "Waiting for SQL query results from production DB"
   - Bad: "Some things done, some pending"

2. ✅ **DO:** List concrete next steps
   - Good: "Next agent: Read DIAGNOSTIC_LOGIN_ISSUE, run diagnose endpoint"
   - Bad: "Continue where I left off"

3. ✅ **DO:** Commit your changes first

   ```bash
   git add .
   git commit -m "Your changes"
   ./scripts/end_session.sh "Changes committed, ready for review"
   ```

4. ❌ **DON'T:** Leave uncommitted changes without explanation
   - If you must, explain why in status message

### For Incoming Agent (You're Starting a Session)

1. ✅ **DO:** Run start_session.sh first
2. ✅ **DO:** Read handoff notes completely before asking questions
3. ✅ **DO:** Verify critical features if handoff warns about issues
4. ❌ **DON'T:** Ignore "uncommitted changes" warnings
5. ❌ **DON'T:** Skip reading referenced files

---

## Troubleshooting

### "No handoff found"

**Cause:** First session or handoff files deleted
**Fix:** Run `./scripts/show_latest_context.sh` to find context in other files

### "Invalid JSON in handoff"

**Cause:** Manual editing broke JSON format
**Fix:** Run `python3 -m json.tool handoff_file.json` to see error, then fix

### "Uncommitted changes warning"

**Cause:** Previous agent left work in progress
**Fix:**

```bash
git status  # See what's uncommitted
git diff    # Review changes
# Then either commit or stash
```

### "Can't find scripts/end_session.sh"

**Cause:** You're in wrong directory
**Fix:** `cd /Users/damianseguin/WIMD-Deploy-Project`

---

## Integration with Existing Tools

### With show_latest_context.sh

- `start_session.sh` uses same logic but more concise
- `show_latest_context.sh` provides deeper analysis
- Use `start_session.sh` for quick starts, `show_latest_context.sh` for investigation

### With verify_critical_features.sh

- `start_session.sh` reminds you to run verification
- Run verification after reading handoff, before making changes

### With Session Start Protocol

- These scripts **complement** SESSION_START_PROTOCOL.md
- Protocol = what to do; Scripts = automation of those steps

---

## Future Enhancements (Ideas)

### 1. Handoff Web UI

- Browser extension to view/create handoffs
- Visual timeline of agent sessions
- Click to load context from any point

### 2. AI-to-AI Direct Handoff

- Integration with Claude Code agent orchestration
- Auto-pass handoff when switching agents mid-conversation
- No manual script running needed

### 3. Handoff Analytics

- Track: average time between handoffs, uncommitted change frequency
- Identify: bottlenecks, communication gaps
- Suggest: better handoff practices

### 4. Handoff Templates

- Pre-defined templates for common scenarios:
  - "Emergency rollback" template
  - "Waiting for external input" template
  - "Feature complete, needs review" template

---

## Quick Reference Card

**Print this and keep next to your desk:**

```
╔══════════════════════════════════════════════════════╗
║  AI AGENT HANDOFF QUICK REFERENCE                    ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  STARTING A SESSION:                                 ║
║  → ./scripts/start_session.sh                        ║
║                                                      ║
║  ENDING A SESSION:                                   ║
║  → ./scripts/end_session.sh "Your status message"    ║
║                                                      ║
║  INVESTIGATING ISSUES:                               ║
║  → ./scripts/show_latest_context.sh                  ║
║                                                      ║
║  VERIFY BEFORE DEPLOY:                               ║
║  → ./scripts/verify_critical_features.sh             ║
║                                                      ║
║  HANDOFF LOCATION:                                   ║
║  → .ai-agents/handoff_YYYYMMDD_HHMMSS_*.json         ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```

---

## Examples

### Example 1: Clean Handoff

```bash
$ git add .
$ git commit -m "Fix login issue - update password hash"
$ ./scripts/end_session.sh "Login fix deployed, waiting for user testing"

✅ Valid handoff created: .ai-agents/handoff_20251125_143022_inprogress.json
📋 Handoff Summary:
Agent: Claude-Code
Status: Login fix deployed, waiting for user testing
Commit: 2d1496a
Uncommitted: 0 files
```

### Example 2: Blocked Handoff

```bash
$ ./scripts/end_session.sh "Waiting for Gemini to provide SQL query results"

✅ Valid handoff created: .ai-agents/handoff_20251125_143500_inprogress.json
📋 Handoff Summary:
Agent: Claude-Code
Status: Waiting for Gemini to provide SQL query results
Commit: 2d1496a
Uncommitted: 0 files
```

### Example 3: Next Agent Starts

```bash
$ ./scripts/start_session.sh

🚀 Starting new AI agent session...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📥 HANDOFF FROM PREVIOUS AGENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
From Agent: Claude-Code
Status: Waiting for Gemini to provide SQL query results
Timestamp: 2025-11-25T14:35:00Z
Git: main @ 2d1496a
Uncommitted: 0 files
Notes: Waiting for Gemini to provide SQL query results
```

---

**END OF GUIDE**
