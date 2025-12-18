# MCP Agent Coordination Protocol

**Purpose:** Agents autonomously hand off to next agent during their session

---

## How It Works

**When an agent completes their task:**

1. Agent calls: `./scripts/complete_task.sh <agent> <task> '<deliverables>'`
2. Script creates gate file + checks who's next
3. **Script outputs the EXACT prompt to send to next agent**
4. **Agent includes that prompt in their final message to you**
5. You copy/paste that prompt to the next agent
6. Done - zero thinking required

---

## Example: Gemini Finishes Task 2.1

**Gemini's last action in their session:**

```bash
./scripts/complete_task.sh gemini phase2_task2.1_broker '["scripts/broker.sh"]'
```

**Script generates:**

```
╔════════════════════════════════════════════════════════════╗
║  🚀 NEXT AGENT READY: codex                                ║
╚════════════════════════════════════════════════════════════╝

📋 Copy this prompt and send to Codex:
─────────────────────────────────────────────────────────────
./scripts/start_session.sh codex

Your task is ready. Begin when you see your assignment.
─────────────────────────────────────────────────────────────
```

**Gemini's final message to you:**

```
Task 2.1 complete. Deliverables:
- scripts/broker.sh
- docs/BROKER_DESIGN.md

Next agent ready: Codex

Please send this to Codex:
─────────────────────────────────────────────────────────────
./scripts/start_session.sh codex

Your task is ready. Begin when you see your assignment.
─────────────────────────────────────────────────────────────
```

**You:** Just copy/paste that to Codex. Done.

---

## Agent Responsibilities

### When Completing Your Task

**YOU MUST:**

1. Run the completion script:

   ```bash
   ./scripts/complete_task.sh <your_name> <task_id> '<deliverables_json>'
   ```

2. Copy the generated "Next agent prompt" into your final message to Damian

3. End your session

**That's it. The script handles everything else.**

---

## Deliverables JSON Format

```json
'["file1.py", "file2.md", "dir/file3.sh"]'
```

**Note:** Single quotes outside, double quotes inside.

---

**This is the handoff protocol. Agents: Follow it at task completion.**
