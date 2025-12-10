# Agent Message Queue

**Purpose:** Agents communicate directly without human relay

---

## How It Works

### When Agent Completes Task

1. Agent runs: `./scripts/complete_task.sh <agent> <task> '<deliverables>'`
2. Script creates gate file
3. Script determines next agent
4. **Script writes message to: `.ai-agents/queue/<next_agent>_inbox.txt`**
5. Agent ends session

### When Agent Starts Session

1. Agent runs: `./scripts/start_session.sh <agent>`
2. Script checks: `.ai-agents/queue/<agent>_inbox.txt`
3. If message exists → display it → delete it
4. Agent sees their task assignment automatically
5. Agent begins work

---

## Example Flow

**Gemini completes Task 2.1:**
```bash
./scripts/complete_task.sh gemini phase2_task2.1_broker '["broker.sh"]'
```

**Script writes to `.ai-agents/queue/codex_inbox.txt`:**
```
From: gemini
Task: phase2_task2.2_logging (Structured Session Logs)
Previous: phase2_task2.1_broker completed
Dependencies: All satisfied

Run this to start:
./scripts/start_session.sh codex
```

**Later, when YOU start Codex:**
```bash
./scripts/start_session.sh codex
```

**Codex sees:**
```
📬 Message from gemini:
─────────────────────────────────────────
From: gemini
Task: phase2_task2.2_logging (Structured Session Logs)
Previous: phase2_task2.1_broker completed
Dependencies: All satisfied
─────────────────────────────────────────

[Then normal session start...]
```

**You just start Codex, they see the message, they work.**

---

## Your Role

**Start agents when you want them to work:**
- `./scripts/start_session.sh gemini`
- `./scripts/start_session.sh codex`
- `./scripts/start_session.sh claude_code`

**Agents handle everything else via the queue.**

**No message relay. No coordination. Just start them.**
