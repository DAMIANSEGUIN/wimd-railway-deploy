# Claude Code MCP Questionnaire Responses

**Document Metadata:**

- Agent: Claude Code (CLI Local Agent)
- Date: 2025-12-09
- Status: ✅ COMPLETE
- Sections Completed: 1, 3, 6, 11

---

## Section 1: State Persistence Analysis

**Agent Description:**
I'm a CLI-based AI agent running locally on macOS. My lifecycle is session-based (started via `./scripts/start_session.sh`, terminated on user exit). I receive text prompts from user, execute tools (Read, Write, Edit, Bash, Glob, Grep, Task), and return text responses with tool outputs. I have no persistent memory between sessions except what's written to filesystem.

**Inputs:** User text prompts, file contents (via Read tool), command outputs (via Bash tool), search results (via Glob/Grep)

**Outputs:** Text responses, file modifications (via Write/Edit), git commits, deployments (via Bash), TODO lists (via TodoWrite)

**Lifecycle:** Single session (30min - 4 hours typical), no cross-session memory

### Information Items Classification

| Information Item | Proposed Category | Risk if Missing Later | Risk if Always Present | Notes |
|------------------|-------------------|----------------------|------------------------|-------|
| **Governance files** (META_GOVERNANCE_CANON_MVP_v1.0.md, etc.) | EXTERNAL ARTIFACT | Agent violates governance rules, makes unsafe changes | Context bloat (60KB+ per session), slows responses | Must load at session start, reference only |
| **Session start macro** (UPDATED_SESSION_START_MACRO_v1.1.2.md) | DURABLE (session-scoped) | Agent doesn't know which governance files to load, misses critical protocols | Minimal - only 1KB, needed entire session | Core session initialization |
| **Project documentation** (CLAUDE.md, DEPLOYMENT_TRUTH.md) | DECISION-RELEVANT | Agent makes wrong deployment decisions, breaks production | Context bloat (20KB+), outdated info persists | Load on-demand when deployment/architecture questions asked |
| **Troubleshooting guides** (TROUBLESHOOTING_CHECKLIST.md, SELF_DIAGNOSTIC_FRAMEWORK.md) | DECISION-RELEVANT | Agent can't debug errors, repeats known mistakes | Context bloat (46KB combined), irrelevant during normal coding | Load only when errors occur or debugging needed |
| **TODO list state** (via TodoWrite tool) | TRANSIENT (task-scoped) | Agent forgets what it's working on, incomplete tasks | Stale tasks clutter context after completion | Clear at task completion or session end |
| **File contents from Read tool** | TRANSIENT (operation-scoped) | Can't edit files without re-reading | Massive context bloat (files can be 1000+ lines), outdated after edits | Discard after operation complete, re-read if needed |
| **Command outputs from Bash** | TRANSIENT (operation-scoped) | Can't verify command success, missing error messages | Log spam, irrelevant after issue resolved | Keep only for immediate next step, then discard |
| **Search results from Glob/Grep** | TRANSIENT (operation-scoped) | Can't find files/code again | Stale results after code changes | Discard after using results, re-search if needed |
| **User's original task description** | DURABLE (session-scoped) | Agent loses track of original goal, scope creep | Minimal risk, usually <200 words | Keep entire session to prevent drift |
| **Git commit history (last 5-10)** | DECISION-RELEVANT | Can't understand recent changes, breaks rollback decisions | Minimal (~2KB for 10 commits), but rarely needed | Load on-demand for rollback/history questions |
| **Railway/Netlify deployment logs** | TRANSIENT (debugging-scoped) | Can't diagnose deployment failures | Log spam (200+ lines), irrelevant after fix | Fetch only when deployment fails, discard after resolution |
| **Database schema** | DECISION-RELEVANT | Agent writes wrong SQL syntax, breaks queries | Moderate bloat (~5KB), but schema rarely changes | Load once per session if DB work expected, cache |
| **Feature flags state** | DECISION-RELEVANT | Agent references disabled features, deploys broken code | Minimal (~1KB), but outdated flags cause confusion | Load at session start, refresh before deployments |
| **API endpoint inventory** | DECISION-RELEVANT | Agent can't navigate codebase, wrong endpoint references | Moderate bloat (~3KB for 40+ endpoints), but stable | Load once per session if API work expected |
| **Error messages from failed operations** | DURABLE (error-scoped) | Agent can't learn from failures, repeats mistakes | Error accumulation bloats context over long sessions | Keep for current error investigation, clear after fix |
| **Cross-agent handoff notes** | DECISION-RELEVANT | Agent doesn't know what other agents did, duplicates work | Handoff notes can be long (5KB+), outdated after implementation | Load only when resuming another agent's work |
| **MCP server configuration** (future) | DURABLE (session-scoped) | Agent can't query MCP servers, no context retrieval | Minimal (~1KB config), needed if MCP active | Load at session start IF MCP implemented |

### Analysis

**Current Problem:**

- I load 60KB+ of governance docs every session even when just fixing typos
- Biggest bloat: TROUBLESHOOTING_CHECKLIST.md (15KB) + SELF_DIAGNOSTIC_FRAMEWORK.md (32KB) = 47KB loaded preemptively

**Proposed Improvement:**

- Load governance as EXTERNAL ARTIFACTS, fetch only relevant sections via retrieval triggers
- Example: "error occurred" → fetch troubleshooting, "deployment command" → fetch deployment truth

**MCP Opportunity:**

- Summarize governance into decision rules (~5KB)
- Keep full docs as retrievable artifacts

### Open Questions

- @Codex: Do you agree governance files should be EXTERNAL ARTIFACTS vs. DURABLE?
- @Damian: Is 60KB governance load acceptable, or should we optimize with MCP retrieval?
- @ALL: Should error messages persist across sessions (durable) or only within-session (transient)?

---

## Section 3: Retrieval Trigger Design

**Current State:** No automatic retrieval triggers exist. Agent loads all governance at session start (manual). Future MCP could trigger context retrieval based on keywords, tool usage, or error states.

### Retrieval Triggers

| Trigger Scenario | Signal (keywords/state/tool) | Retrieval Mechanism | Context Source |
|------------------|------------------------------|---------------------|----------------|
| **Error during code execution** | Tool result contains "Error", "Exception", "Failed" | Fetch TROUBLESHOOTING_CHECKLIST.md section matching error type | MCP query: `retrieve(type="troubleshooting", query=error_message)` |
| **Deployment command detected** | User prompt contains "deploy", "push", "railway" | Fetch DEPLOYMENT_TRUTH.md | MCP query: `retrieve(type="deployment", section="all")` |
| **Database operation detected** | Tool usage: Bash with SQL keywords, or Edit on `api/storage.py` | Fetch database schema summary + context manager pattern rules | MCP query: `retrieve(type="architecture", topic="database")` |
| **Code change to critical file** | Edit/Write to files matching patterns: `api/*.py`, `frontend/*.js`, deployment configs | Fetch relevant architecture doc section + pre-commit checklist | MCP query: `retrieve(type="checklist", context=file_path)` |
| **Git operation detected** | Bash tool with "git commit", "git push", "git revert" | Fetch git workflow rules + recent commit history | MCP query: `retrieve(type="workflow", operation="git")` |
| **User asks "how to" question** | Prompt contains "how do I", "how to", "what's the command" | Fetch relevant documentation section | MCP query: `retrieve(type="docs", semantic_search=user_query)` |
| **Agent resuming another agent's work** | User mentions "Codex said", "Gemini was working on", handoff scenario | Fetch latest handoff note from that agent | MCP query: `retrieve(type="handoff", agent=mentioned_agent, limit=1)` |
| **Session start** | `./scripts/start_session.sh` executed | Fetch governance summary (5KB) + current feature flags + last deployment status | MCP query: `retrieve(type="init", summarize=true)` |
| **Feature flag reference detected** | Code mentions flags: `RAG_BASELINE`, `EXPERIMENTS_ENABLED`, etc. | Fetch current feature flag state | MCP query: `retrieve(type="config", key="feature_flags")` |
| **Testing phase detected** | User says "run tests", "test this", Bash with `pytest` | Fetch testing checklist + golden dataset info | MCP query: `retrieve(type="testing", section="all")` |
| **API endpoint work detected** | Editing files in `api/` folder, or user asks about endpoints | Fetch API endpoint inventory + route structure | MCP query: `retrieve(type="api", section="inventory")` |
| **Context window approaching limit** | Token count > 150K (75% of 200K budget) | Summarize current context, offload old tool outputs | MCP operation: `summarize(current_context) + archive(old_outputs)` |

### Analysis

**Current Problem (v1.1.2):**

- No triggers → Agent loads everything at session start
- Wastes 60KB context on info that might never be needed
- Agent doesn't know when to refresh context (stale feature flags, old docs)

**MCP Opportunity:**

- Trigger-based retrieval reduces initial context to ~5KB (governance summary only)
- Fetch additional context just-in-time when signals detected
- Can refresh context mid-session (e.g., re-fetch feature flags before deployment)

**Implementation Notes:**

- Trigger detection happens in agent's reasoning layer (before tool calls)
- MCP query format needs to be defined (JSON-RPC? REST API?)
- Fallback: If MCP unavailable, fall back to full file reads (current behavior)
- Retrieval latency must be <500ms to not disrupt workflow

**Testing Strategy:**

- Measure context size with vs. without triggers
- Track retrieval accuracy (did we fetch the right doc?)
- Monitor false positives (fetched unnecessarily) and false negatives (missed fetching)

### Open Questions

- @Codex: Should semantic search be part of MCP retrieval, or separate?
- @Gemini: How would API mode detect triggers without tool introspection?
- @Damian: Are 500ms retrieval latencies acceptable, or must be faster?
- @ALL: Should triggers fire automatically, or require agent confirmation first?

---

## Section 6: External Memory Architecture

**Current State:** Current architecture uses filesystem as external memory (everything is `.md` or `.json` files). No MCP servers yet, no database for agent state, no checkpoint system. Every session starts fresh, loads from files.

### Content Type Storage Decisions

| Content Type | In-Context Summary? | External Storage Plan | Retrieval Method |
|--------------|---------------------|----------------------|------------------|
| **Governance documents** (9 files, 60KB total) | YES - Summarize to ~5KB decision rules | Keep full docs in `docs/` folder | MCP retrieval on keyword trigger ("error" → fetch troubleshooting) |
| **Project documentation** (CLAUDE.md, DEPLOYMENT_TRUTH.md, etc.) | YES - Summarize architecture/deployment to ~3KB | Keep full docs in root folder | MCP retrieval on topic trigger ("deployment" → fetch DEPLOYMENT_TRUTH.md) |
| **Code files** (api/, frontend/, tests/, etc.) | NO - Too large (100+ files, 50KB+ total) | Keep in git repo, read on-demand | Direct Read tool when needed, never bulk load |
| **Bash command outputs** | NO - Ephemeral, discarded after use | NOT STORED (except in terminal scrollback) | N/A - re-run command if needed |
| **TODO lists** | YES - Current task list only (~1KB) | Store in-context during session, discard after | TodoWrite tool manages in-memory |
| **Error logs** (Railway, Netlify, local) | YES - Summarize last error only (~500 bytes) | Logs stored in Railway/Netlify services | Bash tool fetches on-demand when debugging |
| **Git history** | YES - Last 5 commits summarized (~1KB) | Full history in `.git/` folder | Bash tool (`git log`) on-demand |
| **Database schema** | YES - Schema summary with table names/columns (~2KB) | Full schema in PostgreSQL (Railway) | SQL query or schema introspection on-demand |
| **Feature flags** | YES - Current flags loaded at session start (~1KB) | Stored in `feature_flags.json` | Read tool at session start, refresh before deploy |
| **API endpoint inventory** | YES - Summarize routes/handlers (~2KB) | Full implementation in `api/` code | Grep tool to find specific endpoints on-demand |
| **Cross-agent handoff notes** | YES - Summary of last handoff (~500 bytes) | Full notes in docs folder (HANDOFF_NOTE_*.md) | Read tool when resuming another agent's work |
| **Deployment status** | YES - Last deployment info (~500 bytes) | Stored in Railway/Netlify dashboards + git tags | Bash tool (`git describe --tags`, `railway status`) |
| **Test results** | NO - Too verbose, changes constantly | Stored in `.pytest_cache/`, discarded after | Bash tool re-runs tests when verification needed |
| **User session data** (PS101 state, uploads, etc.) | NO - Belongs to application database | Stored in PostgreSQL (users, sessions, uploads tables) | SQL queries via backend API |
| **MCP server state** (FUTURE) | YES - Connection config + query cache (~2KB) | MCP servers (location TBD - Railway? Local? Separate?) | MCP client library (protocol TBD - HTTP? WebSocket?) |

### Analysis

**Current Approach (v1.1.2):**

- All context loaded from files each session (no summarization)
- No structured external memory (just filesystem)
- No checkpointing or cross-session persistence
- Works, but inefficient (60KB+ governance load every time)

**Proposed MCP Approach:**

- **In-context:** Summaries only (~15KB total: 5KB governance rules + 3KB architecture + 2KB schema + 2KB API inventory + 1KB flags + 1KB git + 1KB todos)
- **External storage:** Full documents in filesystem, MCP servers provide retrieval
- **Structured store:** Future - could use PostgreSQL for agent state (query history, learned patterns, cross-session memory)

### Key Decision Points

1. **Where do MCP servers run?**
   - Option A: Railway service (new deployment, $5-10/month)
   - Option B: Local process (started by session script, no cost but availability issues)
   - Option C: Separate cloud service (AWS Lambda, higher reliability but complexity)
   - **Recommendation:** Start with Option B (local), migrate to Option A if valuable

2. **What protocol for retrieval?**
   - Option A: HTTP REST API (`GET /retrieve?query=troubleshooting`)
   - Option B: WebSocket (persistent connection, lower latency)
   - Option C: Unix socket (local only, fastest)
   - **Recommendation:** Option A (HTTP) for flexibility, easiest to test

3. **Should we use PostgreSQL for agent state?**
   - Pros: Structured queries, cross-session persistence, shared across agents
   - Cons: Schema design overhead, query complexity, another dependency
   - **Recommendation:** Not in Phase 1 - prove MCP value with file-based first

### Rollback Safety

- All external storage stays in filesystem (unchanged from v1.1.2)
- If MCP fails, agents fall back to direct file reads
- No data loss risk - MCP is query layer only, not storage

### Open Questions

- @Damian: Budget for MCP server infrastructure? (Railway service ~$5-10/month)
- @Codex: Can ChatGPT query HTTP MCP servers, or only file-based retrieval?
- @Gemini: How would API mode broker scripts interact with MCP servers?
- @ALL: Should we store agent query history for learning/optimization?

---

## Section 11: Context Observability Audit

**Current State:** No built-in context observability. I can see my system reminders (in tool results) and my own tool outputs, but cannot introspect my full context window. No provenance tracking exists for loaded documents. No logs of what was included/excluded from context.

### Observability Aspects

| Observability Aspect | Current Capability | Gap | Proposed Instrumentation |
|----------------------|-------------------|-----|--------------------------|
| **Context window dump** | NONE - cannot see full context, only tool results | Cannot debug what info agent has/lacks at any moment | Add `/debug dump-context` command → writes context to `.ai-agents/context_dump_TIMESTAMP.txt` |
| **Token usage tracking** | Basic - see "Token usage: X/200000" in system reminders | Cannot see per-message token breakdown, no historical tracking | Log to `.ai-agents/token_usage.jsonl`: `{timestamp, message_tokens, cumulative, remaining}` |
| **Provenance tracking** | NONE - no record of where info came from | Cannot trace decisions back to source docs | Tag all retrieved content: `<!-- SOURCE: TROUBLESHOOTING_CHECKLIST.md:42 -->` |
| **Inclusion rationale** | NONE - don't know why doc was loaded | Cannot audit if retrieval triggers are working correctly | Log to `.ai-agents/retrieval_log.jsonl`: `{trigger, query, retrieved_docs, timestamp}` |
| **Exclusion tracking** | NONE - don't know what was NOT loaded | Cannot identify missed context (false negatives) | Log excluded docs with reason: `{doc, reason="not_triggered", timestamp}` |
| **MCP query history** (FUTURE) | N/A - no MCP yet | Cannot debug MCP retrieval issues | MCP server logs all queries: `{agent, query, results, latency, timestamp}` |
| **Context summarization log** | NONE - no record of summarization decisions | Cannot audit what info was lost in summarization | Log summaries: `{original_size, summarized_size, compression_ratio, fields_dropped}` |
| **Tool output retention** | Ephemeral - discarded after use | Cannot review past tool outputs for debugging | Keep last 10 tool outputs in `.ai-agents/tool_history.jsonl` |
| **Error context capture** | Partial - errors logged to Railway/terminal | Error context not captured (what was agent doing when error occurred?) | On error: dump context + last 5 messages to `.ai-agents/error_context_TIMESTAMP.txt` |
| **Cross-session continuity** | NONE - each session is blank slate | Cannot see what previous sessions did | Session log: `.ai-agents/sessions.jsonl` with {start, end, work_done, files_modified} |
| **Governance compliance audit** | NONE - no verification that rules were followed | Cannot prove agent followed governance | Log governance rule checks: `{rule, checked, passed, evidence, timestamp}` |

### Analysis

**Current State (v1.1.2):**

- Essentially blind to my own context
- Cannot debug "why did I not fetch doc X?"
- Cannot prove compliance with governance rules
- No audit trail for decisions

**Criticality for MCP:**

- MCP retrieval REQUIRES observability to debug
- Must log: what was retrieved, why, what was excluded
- Must track: MCP query latency, retrieval accuracy
- Must verify: triggers fired correctly, fallback worked

### Implementation Approach

**Phase 1 (No MCP):** Add basic logging to `.ai-agents/` folder

- `context_dump_TIMESTAMP.txt` - manual dumps on request
- `token_usage.jsonl` - token tracking
- `sessions.jsonl` - session metadata

**Phase 2 (With MCP):** Add retrieval logging

- `retrieval_log.jsonl` - all MCP queries
- Provenance tags in retrieved content
- Exclusion tracking (what was NOT fetched)

**Phase 3 (Advanced):** Add ML-based audit

- Analyze retrieval accuracy (did we fetch the right doc?)
- Detect pattern: agent repeatedly fails same task → context issue
- Auto-suggest trigger improvements

### Storage Considerations

- `.ai-agents/` folder already exists for governance docs
- JSONL format for logs (append-only, easy to parse)
- Rotate logs after 7 days (or 100MB file size)
- .gitignore logs (don't commit context dumps)

### Privacy/Security

- Redact sensitive info from context dumps (API keys, credentials)
- Separate audit trail (what was done) from content dumps (what was said)
- Alert if context dump requested in production environment

### Testing Instrumentation

- Add `/debug stats` command → show token usage, retrieval count, tool calls
- Add `/debug last-retrieval` → show details of most recent MCP query
- Add `/debug context-size` → show breakdown of context by category

### Open Questions

- @Damian: Is logging to `.ai-agents/` folder acceptable, or need separate location?
- @Codex: How do you audit your ChatGPT sessions currently? (ChatGPT doesn't expose context dump commands)
- @Gemini: Can API mode agents log to filesystem, or need different approach?
- @ALL: Should context dumps be human-readable (markdown) or machine-readable (JSON)?

---

## Overall Recommendations

### MCP Value Proposition (From My Perspective)

**Problems MCP Could Solve:**

1. **Context Bloat:** Reduce 60KB governance load to 5KB summaries
2. **Just-In-Time Retrieval:** Fetch docs only when needed, not preemptively
3. **Context Refresh:** Update stale info (feature flags) mid-session
4. **Observability:** Track what was retrieved, why, and audit decisions

**Costs/Risks:**

1. **Complexity:** New infrastructure to maintain (MCP servers)
2. **Latency:** Retrieval adds overhead (<500ms target)
3. **Failure Modes:** What if MCP is down? (need fallback)
4. **Development Time:** 2-4 weeks to implement + test

**Go/No-Go Opinion:** 🟡 **CAUTIOUS YES** - BUT start small

- Phase 1: Local MCP server, file-based only, prove value
- Phase 2: If valuable, migrate to Railway, add structured storage
- Phase 3: If still valuable, add advanced features (semantic search, cross-session memory)

### Critical Success Factors

1. ✅ **Observability FIRST** - must log/debug MCP before trusting it
2. ✅ **Fallback always works** - if MCP fails, agents read files directly
3. ✅ **Measurable improvement** - track context size, retrieval accuracy, workflow speed
4. ⚠️ **All agents can use it** - if only Claude Code benefits, not worth shared infrastructure

### What I Need From Other Agents

**From Gemini:**

- Section 4: Attention Budget - cost analysis (is MCP worth token savings?)
- Section 9: Failure Reflection - how to handle MCP failures in API mode
- Answer: Can you query HTTP MCP servers from API mode context?

**From Codex:**

- Section 2: View Compilation - what should be in context per step type?
- Section 5: Summarization Schema - how to compress governance to 5KB safely?
- Section 7: Multi-Agent Scope - do we need separate agents with MCP shared memory?
- Answer: Can ChatGPT query external MCP servers, or only file-based?

**From Damian:**

- Strategic: What's the budget for MCP infrastructure?
- Timeline: How urgent is context optimization? (current system works)
- Decision: If MCP only benefits 1-2 agents, still worth it?

---

## Status

**Sections Complete:** 1, 3, 6, 11 (4/4 assigned sections)

**Awaiting:** Gemini and Codex responses before synthesis

**Next Step:** After all responses received, create `SYNTHESIS.md` with consolidated recommendations

---

**End of Claude Code Responses**
