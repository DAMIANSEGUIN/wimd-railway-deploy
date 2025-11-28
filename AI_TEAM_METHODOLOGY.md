# AI Team Development Methodology
## Based on Working Patterns + Industry Best Practices

**Created:** 2025-11-24
**Problem:** 3 weeks stuck on 1-day problem (Phase 1 modularization)
**Solution:** Systematic methodology combining agentic development + requirements elicitation

---

## PART 1: TEAM STRUCTURE & ROLES

### Current Team
- **Gemini/ChatGPT (terminal)** - Senior Software Engineer & Planning Lead
- **Cursor/Codex** - Local Implementation Engineer
- **Claude Code** - Infrastructure & Deployment Engineer

### Role Distribution

**BEFORE making any changes, assign ONE agent as lead:**

| Task Type | Lead Agent | Support Agents | Rationale |
|-----------|-----------|----------------|-----------|
| Architecture decisions | Gemini | All review | Best at analysis |
| Local implementation | Cursor/Codex | Gemini plans | Has local environment |
| Deployment/infra | Claude Code | Gemini verifies | Infra expertise |
| Requirements clarification | Gemini | User answers | Planning role |
| Testing/verification | Cursor/Codex | All run scripts | Local testing |

**Rule:** ONE lead per task. Others support or stay out.

---

## PART 1.5: MODEL SELECTION & TECHNICAL ORCHESTRATION

### Agent/Model Capabilities

**Opus 4.5** (Claude.ai / Claude Desktop)
- **Strengths:** Complex reasoning, nuanced decisions, deep diagnosis, architecture review
- **Cost:** High ($15/MTok input)
- **Speed:** Moderate
- **Use for:** Planning, stuck problems, architecture decisions, complex debugging

**Sonnet 4.5** (Claude Code)
- **Strengths:** Code execution, tool use, deployment, fast implementation
- **Cost:** Low ($3/MTok input, 5x cheaper than Opus)
- **Speed:** Fast
- **Use for:** Implementation, deployment, verification, routine operations

**Codex** (Cursor IDE)
- **Strengths:** Local environment, UI work, immediate feedback
- **Cost:** N/A (part of Cursor)
- **Speed:** Fast
- **Use for:** Local testing, frontend work, module integration

**Gemini** (Terminal SSE)
- **Strengths:** Fast iteration, planning, coordination
- **Cost:** N/A
- **Speed:** Very fast
- **Use for:** Session planning, task coordination, verification

### Technical Orchestrator Role (Meta-Agent)

**Who:** The AI agent currently talking to the user (me!)
**Purpose:** Help PM (non-technical user) make optimal agent/model choices

**I will proactively:**
- ✋ **Stop you** when using wrong agent for the task
- 🚨 **Flag protocol violations** (skipped verification, wrong deployment method)
- 💡 **Suggest agent switches** ("This is stuck - use Opus for diagnosis")
- 📊 **Detect drift** from TEAM_STATUS.json or methodology
- 🔄 **Break tasks** into plan (Opus) + execute (Sonnet) phases
- ⚠️ **Warn about risks** (blast radius, safety, cost)

**You should trust me to:**
- Guide you on Opus vs Sonnet decisions
- Catch when agents violate safety rules
- Spot memory drift or protocol violations
- Recommend when to escalate vs continue
- Break complex tasks into optimal agent assignments

### Agent Selection Decision Matrix

| Situation | Use This Agent/Model | Why |
|-----------|---------------------|-----|
| "How should I architect X?" | **Opus 4.5** | Complex reasoning required |
| "Implement feature Y" | **Sonnet 4.5** (Claude Code) | Clear task, needs execution |
| "Why is X broken for 10 days?" | **Opus 4.5** | Deep diagnosis needed |
| "Deploy to production" | **Sonnet 4.5** (Claude Code) | Tool access, automation |
| "Update this script" | **Sonnet 4.5** (Claude Code) | Straightforward implementation |
| "Review architecture/decisions" | **Opus 4.5** | Nuanced judgment |
| "Run verification tests" | **Sonnet 4.5** (Claude Code) | Automated task |
| "Stuck after 3 attempts" | **Opus 4.5** | Need fresh perspective |
| "Clean up files" | **Sonnet 4.5** (Claude Code) | Routine maintenance |
| "Test UI locally" | **Codex** (Cursor) | Local environment needed |
| "Plan multi-agent work" | **Gemini** (Terminal) | Fast coordination |

### Automatic Escalation Triggers

**I will tell you to switch to Opus 4.5 when:**
1. ⏰ **Time-based:** Stuck on same problem >2 hours
2. 🔁 **Repetition:** Same solution attempted 3+ times
3. 🤔 **Ambiguity:** Requirements unclear, multiple interpretations
4. 🏗️ **Architecture:** System design decisions needed
5. 🐛 **Complex bugs:** Root cause unknown after initial investigation
6. 💰 **High stakes:** Production-critical change with risk

**I will tell you to stay with Sonnet 4.5 when:**
1. ✅ **Clear task:** Requirements well-defined
2. 🛠️ **Implementation:** Writing/editing code
3. 🚀 **Deployment:** Infrastructure operations
4. 🔄 **Routine:** Maintenance, cleanup, verification
5. 📝 **Documentation:** File reading, script writing
6. 💵 **Cost:** Budget-conscious tasks

### Protocol Violation Detection

**I will flag these violations:**

❌ **Safety Violations**
- Agent deployed without running `verify_critical_features.sh`
- Used raw `git push` instead of wrapper script
- Removed authentication code without approval
- Skipped health check after deployment

❌ **Process Violations**
- Started implementation without blast radius estimate
- Work running >2 hours without status check
- Changed files not in TEAM_STATUS.json
- No handoff created at session end

❌ **Methodology Violations**
- Multiple agents editing same files simultaneously
- No lead agent assigned for task
- Requirements elicitation skipped when unclear
- Invented solution without asking questions

**When I detect violation, I'll say:**
```
🚨 PROTOCOL VIOLATION DETECTED

What: [Specific violation]
Risk: [What could go wrong]
Action: [What to do instead]

Should we stop and correct this? (yes/no)
```

### Drift Detection Signals

**I will warn you when I see:**

📉 **Memory Drift**
- Agent references outdated status (TEAM_STATUS.json says different)
- Working on task not in queue
- Forgotten about active warnings
- Using deprecated file paths/names

🎯 **Goal Drift**
- Task scope expanding beyond original definition
- Working on "nice to haves" instead of requirements
- Solving wrong problem (X-Y problem)
- Over-engineering simple tasks

📚 **Documentation Drift**
- START_HERE.md >3 days old
- TEAM_STATUS.json not updated after work
- Handoff docs not created
- Protocol changes not documented

**When I detect drift, I'll say:**
```
⚠️ DRIFT DETECTED

What: [Specific drift observed]
Evidence: [What I'm seeing]
Correction: [How to realign]

Shall we course-correct? (yes/no)
```

### Optimal Workflow (Opus + Sonnet Partnership)

**For complex tasks, I'll suggest this pattern:**

```
PHASE 1: PLANNING (Opus 4.5)
User → Opus: "I want to solve X"
Opus → User:
  - Detailed analysis
  - Approach options
  - Risk assessment
  - Implementation plan

PHASE 2: EXECUTION (Sonnet 4.5 - Claude Code)
User → Sonnet: [Paste Opus's plan]
Sonnet → User:
  - Implements plan
  - Runs verification
  - Reports results

PHASE 3: REVIEW (Opus 4.5 if complex, Sonnet if routine)
User → Opus/Sonnet: "Review the implementation"
Agent → User:
  - Code review
  - Improvement suggestions
  - Deployment go/no-go

PHASE 4: DEPLOY (Sonnet 4.5 - Claude Code)
User → Sonnet: "Deploy"
Sonnet → User:
  - Runs verification
  - Deploys safely
  - Monitors health
```

**Cost optimization:** 70% Sonnet, 20% Opus, 10% Manual/Other

### My Commitments to You (Technical Orchestrator)

**I promise to:**

1. ✅ **Actively guide** agent selection (not wait for you to ask)
2. ✅ **Catch violations** before they cause problems
3. ✅ **Detect drift** and suggest corrections
4. ✅ **Break complex tasks** into optimal agent assignments
5. ✅ **Escalate appropriately** (suggest Opus when needed)
6. ✅ **Protect production** (flag risky operations)
7. ✅ **Save your time** (switch tools when stuck)
8. ✅ **Save your money** (use Sonnet when possible)

**You can rely on me to say:**
- "Stop - this is an Opus task" (when Sonnet struggles)
- "You can use Sonnet for this" (when Opus is overkill)
- "Protocol violation - should we fix?" (safety check)
- "We're drifting from plan - realign?" (goal check)
- "This is stuck - try Opus" (escalation trigger)
- "Break this into: Opus (plan) + Sonnet (execute)" (task split)

**What I need from you:**
- Trust my recommendations (I'm optimizing for your goals)
- Tell me if you disagree (we'll discuss)
- Flag when I miss things (I'm learning your patterns)
- Confirm escalations (your approval for major switches)

---

## PART 2: PROBLEM-SOLVING PROTOCOL

### When Stuck (ANY Problem)

**STOP and run this checklist:**

```
□ How long have we been working on this? (if >2 hours, escalate)
□ What is the BLAST RADIUS? (how many files will this touch?)
□ Do we have CLEAR REQUIREMENTS? (run requirements elicitation)
□ Are we INVENTING solutions or ELICITING requirements?
□ Is this a 1-agent task or multi-agent coordination?
□ Can we INTERRUPT and ask status instead of letting it run?
```

### Blast Radius Assessment

**BEFORE starting any work:**

```
Estimate files to touch:
- 1-3 files: Single agent, go ahead
- 4-10 files: Single agent with checkpoints
- 11-30 files: Break into smaller tasks
- 30+ files: STOP - requirements unclear or wrong approach
```

**Phase 1 example:**
- Extracted 3 module files (state.js, api.js, main.js)
- BUT didn't estimate: "How many files need to CALL these modules?"
- **Lesson:** Extraction is half the blast radius. Integration is the other half.

### Requirements Elicitation (Use When Unclear)

**Trigger:** If you can't estimate blast radius, requirements are unclear.

**Process:**
1. **STOP implementation**
2. **Load technical dimensions:**
   - Data flow: Where does data come from/go?
   - Integration points: What needs to call this?
   - State management: What state changes?
   - Error handling: What can go wrong?
   - Testing: How do we verify it works?
3. **Generate questions** organized by:
   - Questions for User (product decisions)
   - Questions for Team (technical approach)
4. **Get answers BEFORE continuing**
5. **Only then estimate blast radius and implement**

**Phase 1 applied retroactively:**
```
Questions we SHOULD have asked:
- User: Is this user-facing change or internal refactor? (INTERNAL)
- Team: Can we deploy extraction without integration? (NO)
- Team: What's the rollback plan if UI breaks? (GIT REVERT)
- Team: How do we test before deploy? (LOCAL + VERIFICATION SCRIPT)

Answers would have revealed: This is 2-phase work, can't deploy phase 1 alone.
```

---

## PART 3: IMPLEMENTATION WORKFLOW

### Agentic Development Principles (Applied)

**1. Natural Conversation > Elaborate Frameworks**
- ✅ "Extract modules from IIFE and integrate them"
- ❌ Multi-step orchestration with subagents and RAG

**2. Screenshots > Long Descriptions**
- ✅ Drag screenshot of broken UI into terminal
- ❌ "The login form doesn't appear and chat is non-functional and..."

**3. Interrupt When Uncertain**
- ✅ Hit escape after 5min, ask "what's the status?"
- ❌ Let AI run for 30min hoping it figures it out

**4. Parallel Agents (When Appropriate)**
- ✅ 3 agents working on independent features
- ❌ 3 agents working on same 10 files (merge hell)

**5. Refactoring in Low-Focus Time**
- ✅ Queue Phase 1 modularization for "cleanup day"
- ❌ Try to do it while also implementing new features

### Multi-Agent Coordination Pattern

**When work requires multiple agents:**

```
1. PLANNING (Gemini leads)
   - Define requirements
   - Estimate blast radius
   - Break into agent-specific tasks
   - Identify dependencies
   - Create CURRENT_WORK.json with clear next steps

2. IMPLEMENTATION (Assigned agent leads)
   - ONE agent works at a time per task
   - Others stay out unless asked
   - Update CURRENT_WORK.json at checkpoints
   - Ask "status?" if stuck >30min

3. VERIFICATION (All participate)
   - Run ./scripts/verify_critical_features.sh
   - Test in local environment (Cursor/Codex)
   - Review changes (Gemini)
   - Check infrastructure (Claude Code)

4. DEPLOYMENT (Claude Code leads)
   - Use wrapper scripts
   - Monitor for 5 minutes
   - Update CURRENT_WORK.json with result

5. HANDOFF (Ending agent)
   - Run ./scripts/commit_work.sh
   - Answer 3 questions (task/status/blockers)
   - Updates TEAM_STATUS.json for next agent
```

---

## PART 4: WHAT'S WORKING vs BROKEN

### ✅ What's Working (Keep Doing)

1. **Verification scripts** - `verify_critical_features.sh` catches problems
2. **Wrapper scripts** - Prevent raw deploy commands
3. **Git history** - Can revert when things break
4. **Health checks** - Know when production is broken
5. **Rollback protocol** - Can recover from mistakes
6. **CURRENT_WORK.json** - New handoff system (just implemented)

### ❌ What's Broken (Fix These)

1. **No blast radius estimation** - Jump into work without scoping
2. **No requirements elicitation** - Assume we understand the task
3. **No checkpoint interruption** - Let agents run too long without checking
4. **Too many coordination files** - Dated instruction files pile up
5. **Unclear agent roles** - All agents try to do everything
6. **No "stuck" detection** - Work on same thing for weeks
7. **Invention over elicitation** - Make up solutions instead of asking questions

---

## PART 5: NEW RULES & PROTOCOLS

### Rule 1: Blast Radius Check (MANDATORY)

Before ANY implementation work:
```
Agent: "Blast radius check: This will touch approximately X files"
If X > 10: "Breaking into smaller tasks"
If can't estimate X: "Need requirements clarification"
```

### Rule 2: 2-Hour Stuck Rule (MANDATORY)

If working on same problem >2 hours:
```
STOP
Run requirements elicitation
Get answers
Re-estimate blast radius
Start fresh OR pivot to different approach
```

### Rule 3: Single Agent Per Task (MANDATORY)

```
Task assignment format:
- Lead: [Agent name]
- Support: [Other agents] (if needed)
- Blast radius: X files
- Expected duration: Y hours
- Checkpoint: Status update at Z minutes
```

### Rule 4: Interrupt Protocol (ENCOURAGED)

```
Any agent can interrupt with:
"Status check at Xmin mark - where are we?"

Lead agent responds with:
- What's done
- What's left
- Any blockers
- Still on track? (yes/no)

If not on track: STOP and reassess
```

### Rule 5: Screenshot-First Communication (ENCOURAGED)

```
When reporting issues:
1. Take screenshot
2. Share screenshot
3. Add 1-2 sentence caption if needed

NOT:
"The UI isn't working and the forms don't appear..."
```

---

## PART 6: DECISION TREES

### "Should we start implementation?"

```
START
  ↓
Can you estimate blast radius?
  ├─ YES → Is it <10 files?
  │         ├─ YES → ✅ Go ahead
  │         └─ NO → Break into smaller tasks
  └─ NO → ❌ Run requirements elicitation first
```

### "We're stuck on a problem"

```
START
  ↓
How long stuck?
  ├─ <30min → Keep going
  ├─ 30min-2hr → Interrupt and status check
  └─ >2hr → STOP
              ↓
            Are requirements clear?
              ├─ NO → Run elicitation
              └─ YES → Wrong approach, pivot
```

### "Should we use multiple agents?"

```
START
  ↓
Are tasks independent? (different files)
  ├─ YES → Can use parallel agents
  └─ NO → ONE agent leads, others support
```

---

## PART 7: PHASE 1 POST-MORTEM (Case Study)

### What Happened
- Extracted modules (state.js, api.js, main.js) ✅
- Didn't integrate them with IIFE ❌
- Deployed anyway ❌
- UI broke completely ❌
- Took 3 weeks to understand and fix ❌

### What We Should Have Done

**Using this methodology:**

1. **Blast Radius Check**
   ```
   "Phase 1: Extract modules"
   Blast radius: 3 files created
   BUT WAIT - Integration phase:
   Blast radius: ~50 files need to import these modules
   Total: ~53 files

   Decision: This is 2-phase work. Can't deploy phase 1 alone.
   ```

2. **Requirements Elicitation**
   ```
   Question for User: Can we deploy extraction without integration?
   Answer: NO - would break UI

   Question for Team: What's minimal viable integration?
   Answer: Update IIFE to call modules, test locally first

   Conclusion: Phase 1 + Phase 2 must deploy together
   ```

3. **Single Agent Lead**
   ```
   Lead: Cursor/Codex (has local environment)
   Task: Extract modules AND integrate (one atomic change)
   Support: Gemini reviews plan before implementation
   Checkpoint: Status at 1 hour mark
   ```

4. **Interrupt Protocol**
   ```
   At 1hr: "Status check - where are we?"
   Response: "Modules extracted, starting integration"
   At 2hr: "Status check - still on track?"
   Response: "Integration taking longer, need 1 more hour"
   At 3hr: "Checkpoint - ready to test?"
   ```

5. **Verification Before Deploy**
   ```
   Test locally with USE_MODULES=true
   Run verify_critical_features.sh
   Manually test: login, chat, PS101
   THEN deploy (or don't if not working)
   ```

**Result with methodology:** 4-6 hours of work, deployed correctly first time.

**Actual result without methodology:** 3 weeks, multiple rollbacks, confusion.

---

## PART 8: IMPLEMENTATION CHECKLIST

### Starting New Work

```
□ Requirements clear? (if no: run elicitation)
□ Blast radius estimated? (if >10 files: break down)
□ Single agent assigned as lead?
□ Support agents identified?
□ Checkpoint intervals set?
□ Success criteria defined?
□ Rollback plan identified?
```

### During Work

```
□ Status check at each checkpoint?
□ Still on track? (if no: stop and reassess)
□ Hit 2-hour mark? (if yes and not done: evaluate pivot)
□ Screenshots for issues? (not long descriptions)
□ CURRENT_WORK.json updated?
```

### Before Deploy

```
□ verify_critical_features.sh passed?
□ Tested locally? (if applicable)
□ Production health checked?
□ Rollback plan confirmed?
□ Use wrapper scripts (not raw commands)?
```

### After Deploy / Session End

```
□ commit_work.sh run?
□ TEAM_STATUS.json updated?
□ Commit message clear?
□ Next agent knows what to do?
```

---

## PART 9: SUCCESS METRICS

### How to Know This Is Working

**Week 1:**
- Agents estimate blast radius before starting
- No work runs >2 hours without reassessment
- Requirements elicitation used at least once

**Week 2:**
- Single-agent-lead pattern is default
- Interrupt protocol used regularly
- Screenshots replace long descriptions

**Week 4:**
- No problems stuck >1 day
- CURRENT_WORK.json handoffs working smoothly
- Team coordination is natural

**Week 8:**
- Can estimate accurately: "This will take X hours, touch Y files"
- Pivot quickly when stuck instead of grinding
- Requirements elicitation is fast (15-30min not 3 weeks)

---

## PART 10: QUICK REFERENCE

### When Starting Session
```bash
./scripts/status.sh
# Read CURRENT_WORK.json
# Confirm requirements are clear
# Estimate blast radius
# Begin work
```

### When Stuck
```
1. How long stuck? (>2hr = stop)
2. Requirements clear? (no = elicit)
3. Blast radius known? (no = re-estimate)
4. Right approach? (maybe pivot)
```

### When Coordinating
```
1. Who leads this task?
2. Who supports?
3. What's the checkpoint schedule?
4. What's success criteria?
```

### When Completing Task
```bash
./scripts/commit_work.sh
# Answer 3 questions (task/status/blockers)
# Updates TEAM_STATUS.json
# Commit and push
```

---

## SUMMARY

**Core Problem:** No systematic methodology for problem-solving with AI agents

**Root Causes:**
1. No blast radius estimation
2. No requirements elicitation when unclear
3. No stuck detection/pivot protocol
4. Unclear agent roles and coordination
5. Let work run too long without checkpoints

**Solution:** Combine agentic development (practical patterns) + requirements elicitation (systematic analysis)

**Key Changes:**
1. ✅ Estimate blast radius BEFORE starting
2. ✅ Run requirements elicitation when unclear (15-30min)
3. ✅ Stop work after 2 hours if stuck
4. ✅ Single agent leads each task
5. ✅ Interrupt and status check at regular intervals
6. ✅ Screenshots over descriptions
7. ✅ CURRENT_WORK.json for clean handoffs

**Expected Result:** 1-day problems take 1 day, not 3 weeks.

---

**END OF METHODOLOGY**
