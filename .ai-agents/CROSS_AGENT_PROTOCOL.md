# Cross-Agent Coordination Protocol

**Version:** 1.0
**Created:** 2026-01-05
**Applies to:** All AI agents (Claude Code, Gemini, ChatGPT, etc.)
**Status:** ACTIVE - Mandatory for all sessions

---

## PURPOSE

This protocol ensures multiple AI agents can work on the same git repository without coordination failures. It solves the "absolute path divergence" problem where paths like `/Users/damianseguin/...` only work in one environment.

---

## THE 6 MANDATORY RULES

### Rule 1: All File Paths Must Be Relative

**DO:**
```markdown
Read .ai-agents/PROTOCOL.md
cat .mosaic/current_task.json
./scripts/deploy.sh
```

**DON'T:**
```markdown
Read /Users/damianseguin/WIMD-Deploy-Project/.ai-agents/PROTOCOL.md
Read /home/user/wimd-render-deploy/.mosaic/current_task.json
/absolute/path/to/scripts/deploy.sh
```

**Why:** Absolute paths only work in one environment. Relative paths work everywhere.

---

### Rule 2: State Lives in .mosaic/ JSON Files

**Before any work, read these 3 files:**
```bash
cat .mosaic/current_task.json    # What am I doing?
cat .mosaic/blockers.json         # What's blocking progress?
cat .mosaic/agent_state.json      # What did the last agent do?
```

**Why:** JSON files are path-agnostic, machine-readable, and version-controlled. They work in any environment.

---

### Rule 3: Update State on HANDOFF Mode

**When ending your session (HANDOFF mode):**

```bash
# 1. Update agent state
cat > .mosaic/agent_state.json <<EOF
{
  "version": 1,
  "last_agent": "YOUR_AGENT_NAME",
  "last_mode": "HANDOFF",
  "last_session_end": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_commit": "$(git rev-parse --short HEAD)",
  "next_agent": "TBD",
  "handoff_message": "Brief summary of what you accomplished",
  "open_questions": []
}
EOF

# 2. Append to session log
echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"agent\":\"YOUR_AGENT\",\"mode\":\"HANDOFF\",\"action\":\"session_end\",\"outcome\":\"summary_here\"}" >> .mosaic/session_log.jsonl
```

**Why:** The next agent needs to know where you left off.

---

### Rule 4: Commit State Changes

**After updating .mosaic/ files:**
```bash
git add .mosaic/
git commit -m "chore(state): Update agent state [AGENT_NAME]"
git push origin HEAD
```

**Why:** State changes must be synced via git so other agents can see them.

---

### Rule 5: Verify Sync Before Starting Work

**At session start (INIT mode):**
```bash
# Pull latest state
git pull origin $(git branch --show-current)

# Read state
cat .mosaic/current_task.json
cat .mosaic/blockers.json
cat .mosaic/agent_state.json

# Verify you understand the task
echo "Current task: [state your understanding]"
```

**Why:** Prevents working on stale state or duplicating work.

---

### Rule 6: No New Session Handoff Docs

**DON'T create:**
- `SESSION_HANDOFF_2026-01-05.md`
- `SESSION_SUMMARY_*.md`
- `NEXT_SESSION_PROMPT_*.md`
- Any other session-specific markdown files

**DO update:**
- `.mosaic/agent_state.json`
- `.mosaic/session_log.jsonl`

**Why:** 131 session docs already exist and cause confusion. State belongs in JSON, not markdown.

---

### Rule 7: Use INTENT Framework for All Deliverables

**MANDATORY: Before creating any deliverable, follow Intent → Check → Receipt pattern**

See `.ai-agents/INTENT_FRAMEWORK.md` for complete details.

**Quick version:**

**STEP 1: Show Intent Doc**
```markdown
# INTENT DOC
**TASK:** [One sentence - what deliverable am I creating?]
**SCOPE:** Included: [...] / Excluded: [...]
**SOURCES:** [Exact files I'll use]
**CONSTRAINTS:** No fabrication, no embellishment, no guessing
**UNCERTAIN:** [Questions needing answers, or "None"]
```

**STEP 2: Wait for Confirmation**
- User responds: "Proceed" / "Adjust [X]" / "Stop"
- Do NOT create deliverable without approval

**STEP 3: Provide Receipt**
```markdown
# RECEIPT
**SOURCES USED:** [What I actually referenced]
**INCLUDED:** [What I delivered]
**EXCLUDED:** [What I left out and why]
**JUDGMENT CALLS:** [Interpretive decisions made]
**NEEDS VERIFICATION:** [What user should double-check]
```

**Why:** Prevents fabrication, ensures alignment, creates accountability trail.

**Applies to:** Code, documentation, analysis, architecture decisions, implementation plans.

---

## GOVERNANCE STATE MACHINE

All agents must operate in exactly one mode at a time (see `Mosaic_Governance_Core_v1.md`):

```
INIT → BUILD → DIAGNOSE → REPAIR → VERIFY → HANDOFF
```

**Mode Transitions:**
- **INIT:** Read state, verify task, enter next mode
- **BUILD:** Create/modify code
- **DIAGNOSE:** Analyze errors
- **REPAIR:** Fix defects
- **VERIFY:** Validate changes
- **HANDOFF:** Update state, commit, end session

---

## SESSION START PROTOCOL

**Every session MUST start with:**

1. **Pull latest commits**
   ```bash
   git pull origin $(git branch --show-current)
   ```

2. **Read state files**
   ```bash
   cat .mosaic/current_task.json
   cat .mosaic/blockers.json
   cat .mosaic/agent_state.json
   ```

3. **Read assessment docs**
   ```bash
   cat CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md
   cat TERMINAL_AGENT_BRIEFING.md
   ```

4. **Confirm understanding**
   - State the current task in your own words
   - Identify any blockers
   - Enter appropriate mode (usually INIT → BUILD or INIT → DIAGNOSE)

---

## SESSION END PROTOCOL

**Every session MUST end with:**

1. **Update agent state**
   ```bash
   # Edit .mosaic/agent_state.json with your summary
   ```

2. **Append to session log**
   ```bash
   echo "{...}" >> .mosaic/session_log.jsonl
   ```

3. **Commit state**
   ```bash
   git add .mosaic/
   git commit -m "chore(state): Session end [AGENT_NAME]"
   git push origin HEAD
   ```

4. **Enter HANDOFF mode**
   - Declare mode: "Entering HANDOFF mode"
   - Summarize work completed
   - List any open questions or blockers

---

## BLOCKER MANAGEMENT

**When you encounter a blocker:**

1. **Add to blockers.json**
   ```json
   {
     "id": "B005",
     "title": "Brief description",
     "severity": "critical|high|medium|low",
     "status": "active",
     "description": "Detailed description",
     "solution": "Proposed solution or 'unknown'",
     "owner": "agent_name or 'user_decision_required'"
   }
   ```

2. **Update current_task.json**
   ```json
   {
     "status": "blocked",
     ...
   }
   ```

3. **Stop work** if blocker is critical

4. **Enter HANDOFF mode** and explain blocker

---

## VALIDATION COMMANDS

**Test cross-agent compatibility:**

```bash
# Test 1: Can you read state files?
cat .mosaic/current_task.json
# Should return valid JSON

# Test 2: No absolute paths in docs?
grep -r "/Users/" *.md .ai-agents/*.md || echo "PASS: No absolute paths"
grep -r "/home/" *.md .ai-agents/*.md || echo "PASS: No absolute paths"

# Test 3: Git sync working?
git pull origin $(git branch --show-current)
git log --oneline -3
# Should show recent commits from other agents

# Test 4: Can you update state?
echo '{"test":true}' > .mosaic/test_state.json
git add .mosaic/test_state.json
git commit -m "test(state): Verify write access"
rm .mosaic/test_state.json
git add .mosaic/test_state.json
git commit -m "test(state): Clean up test file"
```

---

## EXAMPLE: SUCCESSFUL HANDOFF

**Agent A (ending session):**
```bash
# 1. Update state
cat > .mosaic/agent_state.json <<EOF
{
  "version": 1,
  "last_agent": "claude_code_terminal",
  "last_mode": "HANDOFF",
  "last_session_end": "2026-01-05T16:30:00Z",
  "last_commit": "abc1234",
  "next_agent": "TBD",
  "handoff_message": "Completed Phase 1-3 of cross-agent coordination. Created .mosaic/*.json files, updated CLAUDE.md, created this protocol. Ready for Phase 4 (archive docs).",
  "open_questions": []
}
EOF

# 2. Log session
echo '{"timestamp":"2026-01-05T16:30:00Z","agent":"claude_code_terminal","mode":"HANDOFF","action":"completed_phases_1_to_3","outcome":"success"}' >> .mosaic/session_log.jsonl

# 3. Commit
git add .mosaic/
git commit -m "chore(state): Session end - completed phases 1-3 [claude_code_terminal]"
git push origin HEAD
```

**Agent B (starting session):**
```bash
# 1. Sync
git pull origin main

# 2. Read state
cat .mosaic/agent_state.json
# Sees: "Agent A completed phases 1-3, ready for phase 4"

# 3. Continue work
# Proceeds with Phase 4 (archive docs)
```

---

## ANTI-PATTERNS (DON'T DO THIS)

❌ **Using absolute paths**
```markdown
Read /Users/damianseguin/...
```

❌ **Creating new session docs**
```bash
cat > SESSION_HANDOFF_2026-01-05.md
```

❌ **Not updating state**
```bash
# Agent ends session without updating .mosaic/agent_state.json
```

❌ **Not committing state**
```bash
# Agent updates .mosaic/ but doesn't git commit + push
```

❌ **Skipping INIT mode**
```bash
# Agent starts coding without reading .mosaic/*.json first
```

---

## SUCCESS CRITERIA

Cross-agent coordination is working when:

1. ✅ Both agents can read the same state files
2. ✅ Session handoffs happen via git commits (not manual copy-paste)
3. ✅ No documentation contains absolute paths
4. ✅ Both agents can update state and see each other's changes
5. ✅ Session history is captured in `.mosaic/session_log.jsonl`
6. ✅ No duplicate work happens (agents read state before starting)

---

## REFERENCES

- **Full Assessment:** `CROSS_AGENT_STATE_ASSESSMENT_2026-01-05.md`
- **Implementation Guide:** `CROSS_AGENT_SOLUTION_IMPLEMENTATION.md`
- **Terminal Briefing:** `TERMINAL_AGENT_BRIEFING.md`
- **Governance:** `Mosaic_Governance_Core_v1.md`
- **Decision Hierarchy:** `TEAM_PLAYBOOK_v2.md` Section 5

---

**END OF CROSS-AGENT PROTOCOL**

**Version:** 1.0
**Status:** ACTIVE - All agents MUST follow this protocol
**Last Updated:** 2026-01-05
