# MCP Session Logging - Usage Guide

**Purpose:** Structured, append-only event logging for agent sessions with causal tracking

---

## Quick Start

```python
from session_logger import SessionLogger

logger = SessionLogger()

# Log an event
success, error = logger.append_event(
    session_id="my_session_20251210",
    event_type="tool_call",
    agent="claude_code",
    source="./scripts/deploy.sh",
    data={"command": "deploy render"}
)

if not success:
    print(f"Error: {error}")
```

---

## Event Types

| Type | Description | When to Use |
|------|-------------|-------------|
| `user_message` | User input received | Every user message |
| `tool_call` | Agent invokes a tool | Every Bash, Read, Write, etc. |
| `state_change` | System state changes | File created, config updated |
| `commitment` | Promise/deliverable made | Agent commits to delivering something |
| `error` | Error occurred | Any failure or exception |
| `constraint_applied` | Governance rule enforced | Using mandatory pattern |
| `decision` | Key decision point | Choosing between alternatives |

---

## Required Fields

Every event MUST have:

- `event_id`: Auto-generated unique ID
- `timestamp`: Auto-generated ISO 8601 timestamp
- `event_type`: One of the types above
- `provenance`: Source and agent information

---

## Optional Fields (Highly Recommended)

### Causal Steps

**Track reasoning and decision-making:**

```python
causal_steps=[
    {
        "step": "Analyzed deployment options",
        "reasoning": "Need zero-downtime deployment",
        "alternatives_considered": ["direct push", "blue-green", "rolling"]
    },
    {
        "step": "Chose rolling deployment",
        "reasoning": "Minimizes risk, allows rollback"
    }
]
```

### Active Constraints

**Document governance rules in effect:**

```python
active_constraints=[
    {
        "constraint": "Use wrapper scripts for deployment",
        "source": "CLAUDE.md",
        "priority": "mandatory"
    }
]
```

### Failure Ledger

**Track what didn't work:**

```python
failure_ledger=[
    {
        "attempt": "Direct git push to render",
        "failure_reason": "Permission denied",
        "timestamp": "2025-12-10T12:00:00Z",
        "error_code": "403"
    }
]
```

### Open Commitments

**Track pending promises:**

```python
open_commitments=[
    {
        "commitment": "Deploy Phase 2 to production",
        "status": "in_progress",
        "dependencies": ["Gemini completes Task 2.1"]
    }
]
```

### Key Entities

**Map shorthand to full references:**

```python
key_entities={
    "broker": {
        "full_name": "MCP Document Retrieval Broker",
        "type": "module",
        "location": ".ai-agents/designs/BROKER_ARCHITECTURE.md"
    }
}
```

### Dependencies

**Track event relationships:**

```python
dependencies={
    "depends_on": ["evt_abc12345"],
    "blocks": ["evt_def67890"]
}
```

---

## Examples

### Example 1: Log User Message

```python
logger.append_event(
    session_id="session_20251210_1400",
    event_type="user_message",
    agent="user",
    source="terminal",
    data={"message": "Fix the deployment script"},
    causal_steps=[
        {
            "step": "User requests bug fix",
            "reasoning": "Deployment failing in production"
        }
    ]
)
```

### Example 2: Log Tool Call with Constraints

```python
logger.append_event(
    session_id="session_20251210_1400",
    event_type="tool_call",
    agent="claude_code",
    source="TROUBLESHOOTING_CHECKLIST.md",
    data={
        "tool": "Edit",
        "file": "scripts/deploy.sh",
        "change": "Added error handling"
    },
    active_constraints=[
        {
            "constraint": "Context manager pattern for DB operations",
            "source": "TROUBLESHOOTING_CHECKLIST.md",
            "priority": "mandatory"
        }
    ],
    causal_steps=[
        {
            "step": "Identified missing error handling",
            "reasoning": "Script fails silently on network errors"
        }
    ]
)
```

### Example 3: Log Error with Failure History

```python
logger.append_event(
    session_id="session_20251210_1400",
    event_type="error",
    agent="claude_code",
    source="render_api",
    data={
        "error_code": "500",
        "message": "Internal server error",
        "traceback": "..."
    },
    failure_ledger=[
        {
            "attempt": "Deploy via git push",
            "failure_reason": "500 error from Render",
            "timestamp": "2025-12-10T12:00:00Z",
            "error_code": "500"
        },
        {
            "attempt": "Deploy via render up",
            "failure_reason": "Same 500 error",
            "timestamp": "2025-12-10T12:05:00Z",
            "error_code": "500"
        }
    ],
    open_commitments=[
        {
            "commitment": "Deploy to production",
            "status": "blocked",
            "dependencies": ["Render service operational"]
        }
    ]
)
```

### Example 4: Log Decision Point

```python
logger.append_event(
    session_id="session_20251210_1400",
    event_type="decision",
    agent="claude_code",
    source="task_analysis",
    data={
        "decision": "Take over Task 2.2 from Codex",
        "rationale": "Codex unavailable, task blocks Phase 2 progress"
    },
    causal_steps=[
        {
            "step": "Identified Codex unavailable",
            "reasoning": "User confirmed Codex out of picture"
        },
        {
            "step": "Evaluated options",
            "reasoning": "Can defer or take task myself",
            "alternatives_considered": ["defer to later", "bring in another agent", "do it myself"]
        },
        {
            "step": "Chose to implement Task 2.2",
            "reasoning": "Straightforward work, unblocks my Task 2.3"
        }
    ]
)
```

---

## Querying Logs

### Read All Events

```python
events = logger.read_session("session_20251210_1400")
print(f"Total events: {len(events)}")
```

### Filter by Event Type

```python
errors = logger.query_events(
    session_id="session_20251210_1400",
    event_type="error"
)
```

### Filter by Agent

```python
my_events = logger.query_events(
    session_id="session_20251210_1400",
    agent="claude_code"
)
```

### Filter by Time

```python
recent = logger.query_events(
    session_id="session_20251210_1400",
    after_timestamp="2025-12-10T12:00:00Z"
)
```

### Get Open Commitments

```python
commitments = logger.get_open_commitments("session_20251210_1400")
for c in commitments:
    print(f"- {c['commitment']}: {c['status']}")
```

### Get Failure History

```python
failures = logger.get_failure_history("session_20251210_1400")
for f in failures:
    print(f"- {f['attempt']}: {f['failure_reason']}")
```

---

## Log Management

### Archive Old Sessions

```python
from log_management import LogManager

manager = LogManager()

# Archive sessions older than 30 days
cleaned = manager.cleanup_old_sessions(older_than_days=30, archive_first=True)
print(f"Archived {cleaned} sessions")
```

### Get Storage Stats

```python
stats = manager.get_storage_stats()
print(f"Active: {stats['active_size_mb']} MB")
print(f"Archived: {stats['archived_size_mb']} MB")
```

### Restore from Archive

```python
success = manager.restore_session("old_session_id")
```

---

## Best Practices

### 1. Log Liberally

- Log every significant event
- Better too much data than too little
- Logs are append-only, cheap to store

### 2. Always Include Causal Steps

- Helps understand why decisions were made
- Critical for debugging
- Future agents benefit from reasoning

### 3. Track Failures Explicitly

- Don't hide what didn't work
- Failure ledger prevents repeated mistakes
- Other agents learn from failures

### 4. Document Constraints

- Make governance explicit
- Show which rules applied
- Helps validate compliance

### 5. Track Commitments

- Make promises explicit
- Track status clearly
- Prevents dropped deliverables

---

## Schema Validation

All events are validated against `SESSION_LOG_SCHEMA.json` before writing.

**If validation fails:**

- Event is rejected
- Error message returned
- No partial writes (atomic)

**Common validation errors:**

- Missing required fields
- Invalid event_type
- Malformed timestamp
- Invalid provenance

---

## File Format

Logs are stored as **JSONL** (JSON Lines):

- One event per line
- Newline-delimited JSON
- Append-only (never modified)
- Easy to stream/parse

**Location:** `.ai-agents/sessions/<session_id>.jsonl`

**Example:**

```
{"event_id":"evt_abc123","timestamp":"2025-12-10T12:00:00Z","event_type":"user_message",...}
{"event_id":"evt_def456","timestamp":"2025-12-10T12:01:00Z","event_type":"tool_call",...}
{"event_id":"evt_ghi789","timestamp":"2025-12-10T12:02:00Z","event_type":"error",...}
```

---

## Integration with MCP

Session logging is used by:

- **Broker** - Logs retrieval requests
- **Trigger Detector** - Logs trigger events
- **Agents** - Log their actions and decisions
- **Handoff Protocol** - Logs agent transitions

**Session IDs:** Use format `<agent>_<date>_<time>` (e.g., `claude_20251210_1400`)

---

## Files Reference

- **Schema:** `.ai-agents/session_context/SESSION_LOG_SCHEMA.json`
- **Logger:** `.ai-agents/session_context/session_logger.py`
- **Management:** `.ai-agents/session_context/log_management.py`
- **Logs:** `.ai-agents/sessions/*.jsonl`
- **Archive:** `.ai-agents/sessions/archive/*.jsonl.gz`

---

**Session logging is now active and ready for use.**
