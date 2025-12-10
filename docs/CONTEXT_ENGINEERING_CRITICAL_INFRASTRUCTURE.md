# Context Engineering: Critical Infrastructure for Agent Reliability

**Document Metadata:**
- Created: 2025-12-09 by Claude Code
- Status: REQUIRED READING - All AI Agents
- Source: Synthesis of Ethan Mollick's "Clearing the Desk" + Google ADK + Manus + ACE papers
- Purpose: Fix systemic 10-20 minute agent failure

---

## 🚨 The Critical Problem We Must Solve

**Symptom:** Every AI agent session fails predictably after 10-20 minutes of work.

**What Happens:**
- Minutes 1-10: Agent is sharp, clear reasoning, appropriate tool use, steady progress
- Minutes 10-20: Agent starts repeating itself, forgets constraints it acknowledged earlier, tries approaches already tried
- Minutes 20+: Reasoning becomes muddy and circular, agent effectively unusable

**This is NOT:**
- ❌ A model intelligence problem (smarter models hit same wall)
- ❌ A context window size problem (longer windows make it WORSE)
- ❌ Fixed by better prompts or fine-tuning

**This IS:**
- ✅ An **architectural problem** with how we manage in-session memory
- ✅ The reason agents "demo well, fail in production"
- ✅ **Why we can't give agents real work that takes longer than 20 minutes**

---

## Why This Matters (Non-Technical)

AI agents have **two memory problems:**

### Problem 1: Cross-Session Amnesia
Agents forget everything between conversations. You work Monday, come back Tuesday, agent has no idea what happened.

**Solution:** Domain memory (external records - task lists, progress logs). We have some of this already.

### Problem 2: Within-Session Degradation (THIS DOCUMENT)
Agents get worse the longer they run **within a single session**. Sharp at minute 5, confused at minute 25.

**Why it happens:** Everything the agent does—every tool call, every result—piles up in what it's paying attention to. Eventually important stuff gets buried under accumulated noise.

**Why bigger context windows don't help:** Every token you add competes for the model's attention. Stuff 100,000 tokens of history into the window and the model's ability to reason about what actually matters **degrades**. The critical constraint from step 3 gets buried under noise from steps 4-40.

**The solution:** Smarter memory architecture—being deliberate about what the agent sees at each step rather than just accumulating everything.

---

## The Research: Why Accumulation Fails

### The Default Broken Pattern

Most agent systems (including ours) use **simple accumulation**:
1. Start with system prompt
2. Append every message
3. Append every tool call
4. Append every tool result
5. Send growing transcript to model on each turn

**For chatbots:** This works fine (conversations are short)

**For agents:** This breaks predictably:
- Manus (production agent): averages **50 tool calls per task**
- Each call produces output that gets appended
- Input-to-output ratio: **100:1**
- Most tokens sent to model are accumulated history, not current decision

### The Research Evidence

**"Lost in the Middle" paper:**
- Models struggle with information in the middle of long inputs
- Beginning and end get attention, middle gets ignored
- Not a bug getting patched—it's **architectural**

**Chroma research (18 models tested):**
- Consistent performance degradation as input length increases
- Especially for tasks requiring reasoning across full context

**Transformer architecture limitation:**
- Creates n² pairwise relationships between tokens
- Every token attends to every other token
- As context grows, ability to capture relationships gets stretched thin
- Training data skews toward shorter sequences

**Anthropic's "attention budget" framing:**
- Every token you include is a token of attention spent
- Include 100K tokens of history → model's capacity to weigh what matters degrades
- Critical constraint from step 3 gets buried under noise from steps 4-40

### The Uncomfortable Truth

**Naively stuffing more into context leads to worse reasoning, not better.**

The model that fumbles at minute 30 would perform perfectly if you started fresh with just the relevant information.

This is why:
- ✅ Demo tasks work (5 minutes, small context)
- ❌ Production tasks fail (hours, hundreds of files, accumulated noise)

---

## The Architectural Solution: Four-Layer Memory Model

Three organizations (Google ADK, Manus, Stanford/SambaNova ACE) independently converged on the same architecture.

### The Core Insight

**Old way (broken):** Context is a mutable string buffer. Append to it. Eventually truncate.

**New way (works):** Context is a **compiled view** over a richer stateful system.

**The shift:**
- Sessions, memory, and artifacts = **sources** (full, structured state)
- Flows and processors = **compiler pipeline** (transformations)
- Working context = **compiled output** (sent to LLM for this one call)

Once you internalize this, context engineering stops being prompt manipulation and starts looking like systems engineering.

### The Four Layers (Critical to Understand)

```
┌─────────────────────────────────────────┐
│ WORKING CONTEXT (What model sees)      │  ← Small, computed fresh each call
│ - System prompt                         │     (~5-10KB target)
│ - Current task                          │
│ - Relevant history (retrieved)          │
│ - Relevant artifacts (pointers)         │
└─────────────────────────────────────────┘
            ↑ COMPUTED FROM ↓
┌─────────────────────────────────────────┐
│ SESSION (Structured event log)          │  ← Full trajectory, can grow large
│ - User messages                         │     (model doesn't see this directly)
│ - Agent replies                         │
│ - Tool calls + results                  │
│ - State changes                         │
│ - Errors                                │
└─────────────────────────────────────────┘
            ↑ QUERIES ↓
┌─────────────────────────────────────────┐
│ MEMORY (Searchable knowledge)           │  ← Retrieved on demand
│ - Domain records (task lists, logs)    │     (not permanently present)
│ - Insights from earlier in session     │
│ - Learned strategies                    │
└─────────────────────────────────────────┘
            ↑ REFERENCES ↓
┌─────────────────────────────────────────┐
│ ARTIFACTS (Large objects by reference)  │  ← Stored externally, accessed by pointer
│ - Codebase                              │     (not tokenized into window)
│ - Files                                 │
│ - Database results                      │
│ - Web pages                             │
└─────────────────────────────────────────┘
```

**The parallel to computer architecture is intentional:**
- Working context = **cache** (expensive, limited)
- Sessions = **RAM** (larger but still bounded)
- Memory & artifacts = **disk** (can grow arbitrarily)

**This tiered model lets state expand without proportionally increasing per-call cost.**

---

## The Nine Principles (How to Build This)

### Principle 1: Context Is Computed, Not Accumulated

**Every LLM call = freshly computed projection against durable state.**

Ask at runtime:
- What's relevant **now**?
- What instructions apply **now**?
- Which artifacts matter **now**?

**Don't:** Append everything into one giant prompt (collapses under "three-way pressure")
- Cost and latency scale with context length
- Signal degrades ("lost in the middle")
- Eventually hit hard limits

**Do:** Grow underlying state arbitrarily while keeping each working context small

**Tradeoff:** Need infrastructure (session store, view-compilation pipeline)
- For demos: overhead
- For production: prerequisite

---

### Principle 2: Separate Storage from Presentation

**Durable state and per-call views serve different purposes.**

**Session stores:** Everything that happened (every event, tool result, state change)

**Working context:** Computed subset, optimized for current decision

**Why this matters:**
- Compilation logic can change without touching storage
- Experiment with summarization strategies without rewriting history
- Cost savings: If input-to-output ratio is 100:1, most cost is context
- Debugging: Inspect full session (what happened) vs working context (what model saw)

**Manus implementation:**
- Tool results stored in full in filesystem
- Context window carries compact references (file paths, not payloads)
- Agent fetches full results if needed, doesn't pay token cost unless relevant

---

### Principle 3: Scope by Default

**Default context should contain nearly nothing.**

Additional information enters through **explicit decisions**:
- Loading memory
- Requesting artifacts
- Querying past results

**Rationale:** Attention budget
- Every token competes for limited attention
- Old "nice to have" info dilutes signal from new relevant info

**Manus: "Reduce, Offload, Isolate"**
- **Reduce:** Compact stale results (swap full outputs for references)
- **Offload:** Write to filesystem, refer by path
- **Isolate:** Give sub-agents their own windows (don't share giant context)

**Tradeoff:** Retrieval adds latency and decision overhead
- Works better for agents with clear domain boundaries
- Harder for exploratory tasks with unpredictable context needs

**Claude Code hybrid:**
- Small, almost-always-relevant files (CLAUDE.md) loaded upfront
- Everything else retrieved just-in-time (glob/grep)
- Agent navigates and fetches what it needs

---

### Principle 4: Retrieval Over Pinning

**Don't keep everything permanently in context (fails even with million-token windows).**

**Treat memory as something the agent queries on demand, with relevance-ranked results.**

**Why this matters:**
- Differentiates critical constraint from 30 steps ago vs. noise from 3 steps ago
- Without explicit retrieval: agents become recency-biased (whatever appeared most recently dominates)

**Domain memory integration:**
- External records (task lists, progress logs, validation criteria) aren't dumped wholesale
- They're **queried**
- Agent retrieves specific task it's working on, relevant progress, applicable criteria
- Not everything. The slice that matters.

**Implementation quality matters:**
- Random text blobs + embedding similarity = poor results
- Structured events + queries by type/timestamp/tags = precise retrieval
- More structure in storage → more precise retrieval

---

### Principle 5: Summarization Must Be Schema-Driven

**If you don't aggressively maintain context, it decays through:**
1. Bloat (until you hit limits and truncate randomly)
2. Lossy summarization (compress away critical info)

**Common failure:** Summarize "to save space" without specifying what must be preserved
- Agent fails at step 47 because constraint was compressed away
- No one can explain what happened (raw data gone)

**ACE paper failure modes:**
- **Brevity bias:** Summarization drops domain-specific insights for generic compression
- **Context collapse:** Iterative rewriting erodes detail over time
- Summarize once → lose a little
- Summarize again → lose more
- After a few rounds → vague mush that doesn't support decisions

**The fix: Schema-driven summarization**

Before you compress anything, define what must survive:

| Schema Field | What It Captures | Failure if Missing |
|--------------|------------------|-------------------|
| **Causal Steps** | Chain of decisions with "because" clauses (limit 8 bullets) | Can't reconstruct why plan shifted → repeated debates |
| **Active Constraints** | All guardrails still in force (modes, budgets, SLAs, governance) | Agent unknowingly violates constraints |
| **Failure Ledger** | Each failed attempt: timestamp, tool/result, root cause (≤2 sentences) | Agent loops on same idea, burns tokens |
| **Open Commitments** | Promises, deliverables, approvals owed with due time + owner | Unfulfilled commitments slip through handoffs |
| **Key Entities** | Canonical names/IDs for services, tables, flags, tickets + source link | Follow-on agents can't map shorthand to real objects |
| **Pending Dependencies** | Inputs still needed (credentials, logs, sign-offs) + who owns + escalation path | Work stalls silently |
| **Provenance** | Originating file + commit hash OR doc path + line (YAML front-matter) | Can't verify accuracy, stale data masquerades as current |

**Practical test:** Can summarized context make same decisions as full context on known examples?
- If not → schema is wrong or compression too aggressive

**Manus staged compression:**
1. First: Swap full tool results for compact references (lightweight, reversible)
2. When that reaches diminishing returns: Escalate to schema-based summarization
3. Schema guarantees required fields survive
4. Lose surface detail but preserve structure

---

### Principle 6: Offload Heavy State to Tools and Sandboxes

**Don't feed the model raw tool results at scale. Write them to disk and pass pointers.**

**Why modern context windows (128K+) aren't enough:**
- Tool results can be huge (web pages, PDFs, database queries)
- Single observation can blow past what's reasonable
- Even when results fit, including them raw degrades performance (dilutes attention)

**Manus solution: Filesystem as ultimate context**
- Unlimited size, persistent by nature, directly operable by agent
- Model writes to and reads from files on demand
- Filesystem = externalized memory

**Compression becomes reversible:**
- Web page content dropped from context as long as URL preserved
- Document contents omitted if path remains available
- Shrink context without permanently losing information (agent can fetch back if needed)

**Tool design philosophy:**
- Manus: Fewer than 20 atomic tools (bash, filesystem ops, code execution)
- Push complexity into sandbox, not function-calling layer
- MCP tools exposed through CLI commands agent runs via bash

**Claude Skills:**
- Skills live in filesystem, not as bound tools
- Agent uses basic file operations to progressively discover and use them
- Don't need entire skill library in context—just enough to know what's available

**Key point:** Tool schemas consume attention too
- They sit near front of serialized context
- Expose 50 overlapping tools → spent significant attention budget before agent sees task content

---

### Principle 7: Isolate Context with Sub-Agents

**Multi-agent systems should manage context, not mimic org charts.**

**Sub-agents exist to give different work its own window—not to roleplay human teams.**

**Common mistake (avoid this):**
- Create Designer Agent, PM Agent, Engineer Agent, QA Agent
- They chat in shared context like simulated standup
- Result: context explosion with no capability gain
- Cross-agent chatter becomes drift and hallucination

**Manus approach:**
- Sub-agents exist to **isolate context**
- Planner assigns tasks
- Knowledge manager curates what should be saved
- Executor performs work
- Each has **own window**, communicates through **structured artifacts** (not transcripts)

**Communication protocol matters:**

**Simple tasks (planner only needs output):**
- Pass instructions via function call
- Sub-agent works in own context
- Returns structured result

**Complex tasks (shared state needed):**
- Planner shares full context
- Sub-agent still has own action space and instructions

**In both cases:**
- Output follows schema
- Sub-agent has "submit results" tool with defined fields
- Constrained decoding ensures adherence
- No free-form "here's what I did" that planner must parse

**The test:** "What gets clearer or more correct with separate windows?"
- If you can't answer → split is probably wrong

---

### Principle 8: Design for Cache Stability

**KV-cache hit rate may be the single most important metric for production agents.**

**Why it matters:**
- With Claude Sonnet: cached tokens cost **$0.30 per million** vs **$3.00 uncached** (10x difference)
- Agents making dozens of calls per task see this compound dramatically

**The mechanism:**
- Contexts with identical prefixes can reuse cached key-value computations
- Due to autoregressive processing, even **single-token difference** invalidates cache from that point forward

**Requirements for cache benefits:**

**1. Keep prompt prefix stable**
- Common mistake: Including timestamp at beginning of system prompt
- Lets model tell time, but **destroys cache hit rate**
- Timestamp changes every call → invalidates everything after it

**2. Make context append-only**
- Don't modify previous actions or observations
- Ensure serialization is deterministic
- Many JSON libraries don't guarantee key ordering
- Non-deterministic serialization silently breaks cache even when logical content identical

**3. Mark cache breakpoints explicitly**
- Some providers require manual breakpoint insertion
- At minimum: ensure breakpoints cover system prompt (caches across turns)

**ADK implementation:**
- Separates session and working context naturally
- Architecture divides context into:
  - **Stable prefix:** System instructions, agent identity, long-lived summaries
  - **Variable suffix:** Latest input, new tool outputs
- Changes to suffix don't invalidate prefix cache

**Manus:** Most-tracked metric
- Cache efficiency determines whether multi-hour agent sessions are economically viable

---

### Principle 9: Let Context Evolve Through Execution

**Static prompts freeze agents at version one. Agent never learns from experience.**

Every failure is re-discovered rather than remembered.

**ACE paper framework:**

**Instead of monolithic prompt rewrites:**
- Represent context as structured "bullets"
- Discrete items with metadata (unique ID, helpful/harmful counts)
- Content: strategy, concept, failure mode
- Updates add new bullets or modify existing ones
- Localized changes that preserve past knowledge

**Three components collaborate:**

1. **Generator:** Produces reasoning trajectories, surfaces strategies and pitfalls
2. **Reflector:** Critiques those traces to extract lessons
3. **Curator:** Synthesizes lessons into delta entries, merged by lightweight non-LLM logic

**Because updates are itemized:**
- Multiple deltas merge in parallel
- System supports multi-epoch adaptation
- Revisit queries to progressively strengthen context

**Results:**
- +10.6% on agent benchmarks
- +8.6% on finance tasks
- 86.9% lower adaptation latency than existing methods
- ACE with smaller open-source model matched top-ranked GPT-4.1 agents

**Critically: Uses execution feedback, not labeled data**
- Reflector analyzes what actually happened (successes and failures)
- Extracts insights
- No human annotation required

**Implication:** Design systems to capture outcomes and feed them back
- Agent that ran this morning should inform context for agent running this afternoon

---

## The Nine Failure Modes (What We're Currently Doing Wrong)

### 1. The Append-Everything Trap (OUR CURRENT PROBLEM)

**What we do:**
- Keep single growing transcript
- Hand it to model every turn

**Result:**
- Cost and latency scale linearly
- Attention dilutes as stale events accumulate
- Performance degrades predictably around 20-30 minute mark

**Teams debug for weeks trying prompt tweaks when problem is architectural.**

---

### 2. Blind Summarization

**What happens:**
- Compress "to save space" without defining what must survive
- ACE calls this "brevity bias" and "context collapse"

**Result:**
- Agents forget edge cases, constraints, what was already tried
- Behavior degrades as you "optimize"

**Fix isn't better summarization prompts—it's explicit schemas (Principle 5).**

---

### 3. The Long-Context Delusion

**What happens:**
- Upgrade to million-token model
- Assume problem solved

**Result:**
- Performance gets **worse**
- Pay more for more distracted model
- Structural issues (no filtering, no compaction, no scoping) don't disappear
- They just manifest at higher token counts

---

### 4. Observability as Context

**What happens:**
- Stick debug logs, raw tool outputs, stack traces into same buffer as task instructions
- Conflate what you need for debugging with what model needs for decisions

**Result:**
- Model drowns in log noise

**Fix:**
- Sessions should capture everything (for observability)
- Working context should be curated (for decision-making)
- **These are different**

---

### 5. Tool Schema Bloat

**What happens:**
- Bind dozens of tools with detailed descriptions
- Each description consumes attention budget

**Result:**
- Overlapping tools create ambiguity
- Model oscillates between similar options or calls wrong one

**Manus:** Uses fewer than 20 atomic tools, pushes complexity into sandbox

---

### 6. Anthropomorphic Multi-Agent

**What happens:**
- Create Designer Agent, PM Agent, Engineer Agent
- Feels like good division of labor
- They share giant context and "communicate" by appending messages

**Result:**
- Context explodes
- Cross-agent chatter becomes hallucination

**Manus warning:** Sub-agents exist to isolate context, not to cosplay teams

---

### 7. Static Configurations

**What happens:**
- No accumulation of knowledge
- No sharpening of heuristics
- Rebuild from scratch every session

**Result:**
- Agents never improve
- Discard all signal from trajectories

**ACE's point:** Contexts must evolve through execution feedback

---

### 8. Over-Structured Harness

**What happens:**
- Build elaborate multi-step planners, strict tool hierarchies, complex routing logic
- Swap in better model → performance barely changes

**Result:**
- Harness is bottleneck
- Structure prevents model from using its capabilities

**Manus:** Refactored five times because they know this trap

---

### 9. Cache Destruction

**What happens:**
- Rebuild prompts every turn with unstable prefixes
- Timestamps, non-deterministic serialization, reorganized content

**Result:**
- Pay full cost for identical logical content (bytes differ)
- Forced into premature summarization

**Fix:** Separate stable from volatile sections (Principle 8)

---

## What Becomes Possible (Why This Matters)

### Multi-Hour Autonomy
- Research tasks, code migrations, audit workflows
- Work that runs for hours and touches hundreds of files
- Agent stays coherent (receives relevant slices, doesn't drown in history)
- Manus: sustains 50+ tool calls per task
- ADK: maintains full event history while feeding model curated views

### Self-Improving Agents
- Log strategies, update heuristics, learn from mistakes
- Without retraining
- ACE: evolving contexts enable smaller models to match/exceed larger-model agents with static prompts
- Improvement happens in memory and instruction layers, not weights

### Scalable Personalization
- Persistent preferences, learned constraints, prior outcomes
- Without ballooning context
- Long-term memory retrieved on demand, not pinned
- Inject what matters, leave rest searchable

### Multi-Agent Coordination That Works
- Planner, executor, validator collaborate through structured artifacts
- Not shared context that degrades everything
- Each agent sees what it needs
- Coordination is debuggable (trace exactly what each saw and why)

### Reasoning Over Large Corpora
- Codebases, document collections, datasets
- Treated as artifacts (not tokenized wholesale)
- Structured retrieval decouples reasoning from raw size
- Agent works with bodies of information vastly exceeding window limits

### Auditable Systems
- Full reconstructability of what model saw and why
- Session logs, compaction events, memory updates—all traceable
- When something goes wrong at step 47, inspect exactly what context produced that decision

### Viable Economics
- Sub-linear cost growth (cache reuse, intelligent compaction)
- Agents you can afford to run in production
- Not just demo at hackathon
- Manus: significantly lower per-task costs than integrated alternatives (largely from context engineering)

### Domain-Specific Workspaces
- Finance agents with durable risk context
- Code agents with project history
- Research agents with evidence logs
- Become persistent environments (not one-shot sessions)
- Agent understands long-term arc (architecture supports it)

---

## Implementation Plan (Hours, Not Weeks)

### Phase 1: Core Infrastructure (4-6 hours)

**Goal:** Fix the 20-minute failure

**Tasks:**
1. **Implement session store** (structured events, not string concatenation)
   - Store: user messages, agent replies, tool calls, results, errors
   - Format: JSON with type/timestamp/metadata
   - Location: `.ai-agents/sessions/SESSION_ID.jsonl`

2. **Implement view compiler** (compute working context from session)
   - Read session events
   - Apply relevance filtering
   - Assemble working context (system prompt + relevant history + current task)
   - Target: <10KB working context even with large session

3. **Implement basic retrieval triggers**
   - Error detected → fetch troubleshooting docs
   - Deployment keyword → fetch deployment procedures
   - Session start → fetch governance summary

4. **Test:** Does agent stay coherent past 20 minutes?
   - Run multi-hour task
   - Measure: Does agent repeat itself? Forget constraints?
   - Compare: Before vs after (should see dramatic improvement)

**Deliverables:**
- `api/context_engine.py` - Session store + view compiler
- `api/retrieval_triggers.py` - Trigger detection + context fetching
- Updated session start script to use context engine

---

### Phase 2: Summarization & Provenance (2-4 hours)

**Goal:** Safe compression without losing critical information

**Tasks:**
1. **Implement summarization schema** (Codex already defined this)
   - 7 required fields: causal steps, constraints, failures, commitments, entities, dependencies, provenance
   - YAML front-matter format
   - Validation: schema checker

2. **Add provenance metadata**
   - Every retrieved content tagged with source file + commit + lines
   - Format: `<!-- SOURCE: file.md:42-58, commit: 31d099c -->`

3. **File exports for Codex** (Mirror agent compatibility)
   - Context engine writes to `docs/mcp_exports/` automatically
   - Stable filenames
   - Codex can read even if engine down

**Deliverables:**
- `api/summarization.py` - Schema-driven compression
- `docs/mcp_exports/` - Auto-exported artifacts
- Provenance tags on all generated content

---

### Phase 3: Observability & Optimization (2-4 hours)

**Goal:** Debug context issues, optimize performance

**Tasks:**
1. **Observability logging**
   - Full context dump command: `/debug dump-context`
   - Retrieval log: what was fetched, why, when
   - Exclusion log: what was left out and why
   - Location: `.ai-agents/context_logs/`

2. **Cache stability optimization**
   - Ensure stable prefix (no timestamps in system prompt)
   - Deterministic JSON serialization
   - Measure cache hit rate

3. **Failure reflection system**
   - Capture failed commands with context
   - Store in session: what was tried, why it failed
   - Prevent retry loops

**Deliverables:**
- `.ai-agents/context_logs/` - Full observability
- Cache optimization in context engine
- Failure ledger in session store

---

### Total Implementation Time: 8-14 hours

**Not weeks. Hours.**

The research is done. The architecture is defined. We just need to implement it.

---

## What Each Agent Needs to Do

### Claude Code (Me)
**Role:** Implement the context engine (I have filesystem access)

**Tasks:**
1. Build session store (`.ai-agents/sessions/`)
2. Build view compiler (compute working context)
3. Implement retrieval triggers
4. Add observability logging
5. Test with multi-hour tasks

**Skills needed:** Python, file I/O, JSON manipulation (I have these)

---

### Gemini (API Mode)
**Role:** Integrate broker scripts with context engine

**Tasks:**
1. Update `agent_send.sh` to log full context sent to Gemini
2. Structure context with source metadata
3. Log exclusions (what was omitted)
4. Query context engine for retrieval
5. Test with API mode workflows

**Skills needed:** Shell scripting, JSON formatting (you have these)

---

### Codex (ChatGPT Mirror)
**Role:** Define schemas, consume file exports

**Tasks:**
1. Validate summarization schema (you already defined it)
2. Read from `docs/mcp_exports/` (file-based, you can access)
3. Test fallback when context engine down
4. Provide feedback on export format
5. Document non-technical explanation for stakeholders

**Skills needed:** Schema design, file reading (you have these)

---

### Damian (Human)
**Role:** Approve implementation, test results

**Tasks:**
1. ✅ Approve this plan (go/no-go)
2. ⏳ Test: Give agents multi-hour tasks, observe if 20-minute failure fixed
3. ⏳ Measure: Context size reduction, session length improvement
4. ⏳ Decide: After Phase 1 works, proceed to Phase 2-3?

**Time commitment:** 30 minutes approval + periodic testing

---

## Success Criteria

### Phase 1 Success
- ✅ Agent works coherently for >1 hour (vs current 20 min failure)
- ✅ Context stays <10KB even in long sessions (vs current 60KB+ bloat)
- ✅ Agent doesn't repeat itself or forget constraints
- ✅ Can complete real multi-hour tasks

### Phase 2 Success
- ✅ Summarization preserves critical info (test: same decisions as full context)
- ✅ Provenance traceable (can find source of any info in context)
- ✅ Codex can work even if engine down (file exports functional)

### Phase 3 Success
- ✅ Can debug context issues (full observability logs)
- ✅ Cache hit rate >50% (cost savings)
- ✅ Failure reflection prevents retry loops

---

## The Bottom Line

**Current state:** Agents fail after 20 minutes. Unusable for real work.

**Root cause:** Context accumulation (architectural problem, not model problem)

**Solution:** Four-layer memory model (working context, sessions, memory, artifacts)

**Implementation:** 8-14 hours of work across 3 phases

**Result:** Agents work for hours instead of minutes. Unlocks all real value.

**This is not optional. This is critical infrastructure.**

Without this, we have agents that demo well but can't do real work. With this, we have agents that can work autonomously for hours on complex tasks.

**Question for Damian: Should we proceed with Phase 1 implementation?**

---

## References

**Papers:**
1. [Architecting efficient context-aware multi-agent framework for production](https://developers.googleblog.com/en/introducing-the-agent-development-kit-adk/) - Google Developers Blog
2. [Context Engineering in Manus](https://blog.langchain.dev/manus/) - Lance Martin
3. [Agentic Context Engineering: Evolving Contexts for Self-Improving Language Models](https://arxiv.org/abs/2412.02609) - arXiv
4. [Effective context engineering for AI agents](https://www.anthropic.com/research/building-effective-agents) - Anthropic Engineering

**Original Article:** Ethan Mollick - "Clearing the Desk: Context Engineering for AI Agents"

---

**END OF DOCUMENT**

**Status:** ✅ READY FOR TEAM REVIEW & IMPLEMENTATION DECISION
