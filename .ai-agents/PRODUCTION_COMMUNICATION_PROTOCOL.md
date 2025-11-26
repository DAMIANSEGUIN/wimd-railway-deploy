# Production Communication Protocol
**SSEW Framework for AI Team Updates**

---

## Purpose

In a production environment with multiple AI agents and a human coordinator, **every communication must be structured for clarity and action.** This protocol ensures all team updates contain the essential context needed for decision-making.

---

## SSEW Framework

**Every update MUST follow this structure:**

### **S - Situation**
What happened? What changed? State current reality in 1-2 sentences.

### **S - Solution**
What did you do about it? What's the fix/decision/action taken?

### **E - Evidence**
How do you know it worked? What proves the solution is valid?

### **W - Way Forward**
What happens next? Who does what?

---

## Template for Team Updates

```markdown
# [Topic] - [Date]

## Situation
[1-2 sentences: what changed, what problem existed]

## Solution
[What was done to address it]
- File(s) changed: [list with paths]
- Commit(s): [hash(es)]

## Evidence
[How you verified it works]
- Test results
- Commands run
- Output observed

## Way Forward
**[AGENT NAME]: [ACTION or PAUSE]**
- [Specific instruction or pointer to documentation]

**[OTHER AGENTS]: PAUSE**
- [When they'll be needed next]
```

---

## Examples

### Example 1: Bug Fix

```markdown
# session_end.sh Exit Bug - 2025-11-24

## Situation
session_end.sh was exiting with status 1 before writing CURRENT_WORK.json.
Codex tested with piped input and file was not created.

## Solution
Added `set +e` / `set -e` around health check (line 93-99)
- File changed: scripts/session_end.sh
- Commit: d3e131f

## Evidence
Codex re-tested with piped input:
- CURRENT_WORK.json now updates correctly
- All fields populated (last_updated, agent, task, production, git, warnings)
- Exit code 0

## Way Forward
**GEMINI: START P0.2**
- Run: ./scripts/status.sh
- Read: CURRENT_WORK.json → next_action field
- Task details: AI_TEAM_METHODOLOGY.md P0.2 section

**CODEX, CLAUDE CODE, CHATGPT: PAUSE**
- Resume when Gemini completes P0.2
```

### Example 2: Documentation Update

```markdown
# AI_START_HERE.txt Simplified - 2025-11-24

## Situation
Multiple entry-point docs (START_HERE.md, AI_START_HERE.txt, SESSION_START_PROTOCOL.md)
were causing confusion about which to read first.

## Solution
Updated AI_START_HERE.txt to single instruction: "run ./scripts/status.sh"
- Files changed: AI_START_HERE.txt, .ai-agents/SESSION_START_PROTOCOL.md
- Commit: c5fcb47

## Evidence
New AI_START_HERE.txt content:
- 3 lines total
- Points to status.sh only
- No conflicting instructions

## Way Forward
**ALL AGENTS: NOTE CHANGE**
- New sessions: run ./scripts/status.sh (not other docs)
- Old START_HERE.md is outdated (marked in file)

**NEXT TASK: P0.2** (Gemini leads)
- Consolidate remaining handoff docs
```

### Example 3: Deployment

```markdown
# Backend Deployed - Phase 4 Sources - 2025-10-07

## Situation
All 12 job sources implemented but not deployed. Phase 4 stuck in local testing.

## Solution
Deployed to Railway production
- Branch: main (f439633 → a7b2c1d)
- Files: api/job_sources/*.py, requirements.txt
- Feature flags: RAG_BASELINE=true, JOB_SOURCES_STUBBED_ENABLED=true

## Evidence
Health check confirms deployment:
- curl https://what-is-my-delta-site-production.up.railway.app/health
- Response: {"ok": true, "job_sources": 12}
- No errors in Railway logs (5 min monitor)

## Way Forward
**USER: MANUAL TEST REQUIRED**
- Test job search in production UI
- Verify real job data returns

**ALL AGENTS: PAUSE**
- Do NOT deploy until user confirms working
- If issues found, see TROUBLESHOOTING_CHECKLIST.md
```

### Example 4: Blocked/Need Decision

```markdown
# Phase 1 Integration - Blast Radius Unknown - 2025-11-24

## Situation
Phase 1 modularization extracted files (state.js, api.js, main.js) but integration
scope unclear. Can't estimate blast radius.

## Solution
**STOPPED - Running requirements elicitation**
- No code changes made
- Questions document created: .ai-agents/PHASE1_QUESTIONS.md

## Evidence
Blast radius check failed:
- Extracted: 3 files
- Integration targets: Unknown (could be 10 or 50 files)
- Decision tree says: STOP if can't estimate

## Way Forward
**USER: ANSWER QUESTIONS**
- Read: .ai-agents/PHASE1_QUESTIONS.md
- Provide answers to questions 1-5

**ALL AGENTS: PAUSE**
- Resume Phase 1 work after user clarifies requirements
- Do NOT attempt integration without blast radius estimate
```

---

## Rules for SSEW Communication

### 1. **Situation = Facts Only**
- No opinions, speculation, or assumptions
- State what IS, not what you think it means
- Include relevant timestamps, commit hashes, file paths

### 2. **Solution = Actions Taken**
- List concrete changes made
- Always include file paths and commit hashes
- If no solution yet, say "BLOCKED" or "PAUSED"

### 3. **Evidence = Proof**
- Commands you ran + output
- Test results (pass/fail)
- Health check responses
- Screenshots if applicable
- Never say "it should work" - show that it DOES work

### 4. **Way Forward = Clear Assignments**
- Name specific agent(s)
- Use verbs: START, PAUSE, RESUME, TEST, REVIEW
- Point to exact documentation or file
- If agent should PAUSE, say when they resume

---

## Anti-Patterns (DO NOT DO THIS)

### ❌ Vague Update
```
"Fixed the bug. Should be good now. Let me know if issues."
```
**Problem:** No situation context, no evidence, no file changes, no next action.

### ❌ Wall of Text
```
"So I was looking at the session_end script and noticed it was using
set -e which is a bash feature that makes scripts exit on any error
and I thought that might be causing problems because when I tested
it the health check was failing and then the whole script would exit
before it could write the JSON file so I added set +e around that
part to disable the exit-on-error behavior temporarily and then
re-enabled it after and now it seems to work better..."
```
**Problem:** Buried the lead. Hard to extract action items. Use SSEW structure.

### ❌ Missing Way Forward
```
# Bug Fixed - 2025-11-24

## Situation
session_end.sh was broken

## Solution
Fixed it (commit d3e131f)

## Evidence
Tested, works now
```
**Problem:** WHO does WHAT next? User has to ask.

### ❌ No Evidence
```
## Solution
Updated the deployment script

## Way Forward
Should be safe to deploy now
```
**Problem:** "Should be" is not evidence. Show test results.

---

## When to Use SSEW

**ALWAYS use SSEW for:**
- Bug fixes
- Feature completions
- Deployments
- Blockers/questions for user
- Handoffs between agents
- Status updates user requested

**Can skip SSEW for:**
- Quick clarification questions mid-session
- Acknowledging instructions ("got it, starting now")
- Internal agent coordination (if agents can communicate directly)

---

## Integration with CURRENT_WORK.json

**SSEW updates supplement CURRENT_WORK.json, not replace it.**

```
CURRENT_WORK.json = persistent state (what/who/when)
SSEW update = event notification (what changed and what to do about it)
```

**When to update both:**
1. Make code changes
2. Update CURRENT_WORK.json via session_end.sh
3. Send SSEW update to team (user shares it)

**User's role:**
- Receives SSEW updates from agents
- Shares with other agents who need to know
- Decides if action is needed or agents should continue

---

## Checklist: Before Sending Update

```
□ Situation: Stated current reality (1-2 sentences)?
□ Solution: Listed files changed + commit hashes?
□ Evidence: Showed test results or verification?
□ Way Forward: Named specific agent(s) + clear action?
□ Way Forward: Other agents told to PAUSE or given task?
□ Brevity: Could I remove any fluff without losing meaning?
□ Actionable: Can recipient act on this immediately without asking questions?
```

---

## Summary

**Every update needs 4 things:**
1. **What happened** (Situation)
2. **What you did** (Solution) + file paths + commits
3. **Proof it worked** (Evidence)
4. **Who does what next** (Way Forward)

**If you can't fill in all 4, your update is incomplete.**

---

**END OF PROTOCOL**
