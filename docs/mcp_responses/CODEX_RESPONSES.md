# Codex MCP Questionnaire Responses

**Document Metadata:**

- Agent: Codex (ChatGPT Mirror)
- Date: 2025-12-09
- Status: ✅ COMPLETE – Codex input captured

---

## Section 2: View Compilation Design

**Purpose:** Define what must/should/should-not enter the context view for each step type. Codex operates from the GDrive mirror with a relatively small working window, so every view has to be purpose-built.

| Step Type | MUST Include | SHOULD Include | Reference Only | Exclude Rationale | Notes |
|-----------|--------------|----------------|----------------|-------------------|-------|
| Session Initialization | Session start macro digest (mode, guardrails, required files), most recent handoff highlights, outstanding risks/approvals | Latest feature-flag snapshot, prior deployment status snippet | Full governance library, troubleshooting appendix | Raw tool logs or file diffs create noise before user task arrives | Keep under ~2 KB so downstream steps have headroom; fetch detailed docs on demand |
| Discovery / Planning | User goal + acceptance criteria verbatim, canonical constraints tied to task, known dependencies/blockers | High-level architecture diagram excerpt, summary of adjacent initiatives, last 2 related commits | Entire architecture handbook, backlog inventory | Historical context beyond current goal slows planning | When requests span multiple domains, break planning into subviews per domain |
| Implementation / Coding | Active file snippet (≤80 lines) with focus markers, task-specific acceptance checks, relevant code-style or API contract bullets | Neighboring module summary, branch status, pending TODO items | Complete repository history, whole governance stack | Including entire files wastes tokens and hides errors | Replace snippet whenever cursor moves to new region to avoid stale context |
| Verification / Testing | Test plan reference, expected outputs, environment/config toggles, current test command | Previous failure summary, mitigation notes, coverage deltas | Full historical test logs, bug archives | Large logs swamp the reasoning window | Keep last failure inline until resolved, then archive to external note |
| Deployment / Handoff | Release checklist items with completion marks, approval state, change summary bullets, rollback pointer | Monitoring hooks, stakeholder notification template | Full DEPLOYMENT_TRUTH.md, exhaustive incident history | Raw coding transcripts don’t help reviewers, push to artifact store instead | Handoff view doubles as audit trail; include links to artifacts rather than embedding |

**Your Analysis:**
The mirror agent should treat the session state as authoritative and build tiny, phase-specific views instead of accreting everything the user ever said. Each row above keeps “must include” minimal (goal, constraints, immediate inputs) and demotes everything else to reference pointers or retrievable artifacts. This keeps the prompt <10 KB even in complex deployments and aligns with MCP’s principle that the view is computed from state. Whenever a user request spans multiple phases (e.g., plan + implement + test), Codex should render separate subviews sequentially rather than combining them.

**Open Questions:**

- Can MCP expose curated “view bundles” so Codex requests `GET /view/implementation?task_id=123` instead of stitching snippets manually?
- Should session initialization automatically prefetch feature-flag and deployment snippets, or stay on-demand to reduce cold-start latency?

---

## Section 5: Summarization Schema Design

| Schema Field | Capture Rules | Failure if Missing | Notes |
|--------------|---------------|-------------------|-------|
| Causal Steps | Chronological list of pivotal decisions with “because” clauses; limit to 8 bullets per summary | Reviewers cannot reconstruct why the plan shifted, leading to repeated debates or regressions | Cite source message IDs or file paths alongside each step |
| Active Constraints | Enumerate all guardrails still in force (modes, budgets, SLAs, governance clauses) with identifiers | Agent may unknowingly violate constraints after long sessions | Mark each constraint as “satisfied / pending / at risk” to drive escalations |
| Failure Ledger | Record each failed attempt with timestamp, tool/result, and root cause in ≤2 sentences | Without a failure ledger the agent loops on the same idea and burns tokens | Archive ledger entries only after a verified fix lands |
| Open Commitments | Track promises, deliverables, or approvals owed to stakeholders with due time | Unfulfilled commitments slip through handoffs | Include owner + next checkpoint so supervisor can follow up |
| Key Entities & References | List canonical names/IDs for services, tables, feature flags, tickets, and link to source doc/line | Follow-on agents cannot map shorthand to real objects, causing misapplied fixes | Use stable handles (e.g., `api.booking.create`), not local nicknames |
| Pending Data / Dependencies | Describe inputs still needed (credentials, logs, sign-offs) and who owns them | Work stalls silently when dependencies are forgotten | Pair each dependency with escalation path |
| Provenance & Source Hash | For every summary block, capture the originating file + commit hash or doc path + line | Auditors cannot verify accuracy; stale data might masquerade as current | Store as metadata (YAML front-matter) so it survives copy/paste |

**Your Analysis:**
Mirror summaries have to be loss-aware: once context is compressed there is no second chance to rehydrate unless MCP explicitly stores the dropped details. The schema above enforces that we keep decision causality, constraints, and obligations in structured slots while pushing everything else into retrievable artifacts. Provenance is non-negotiable—without it, the mirror agent can’t prove that a summarized constraint is still real or see when the source changed upstream. Summaries should be generated via a template so the MCP server (or Codex manually) can validate fields before accepting them.

**Open Questions:**

- Where should this schema live—in MCP JSON (so every summary is machine-validated) or as Markdown front-matter for compatibility with existing docs?
- Do we need different schemas per phase (e.g., deployments vs. research), or can one general schema suffice with optional fields?

---

## Section 7: Multi-Agent Scope Design (Collaborative)

| Candidate Split | Benefit (Clarity/Correctness) | Risks of Split | Decision | Notes |
|-----------------|-------------------------------|----------------|----------|-------|
| Mirror (Codex) vs. Local CLI (Claude Code) | Keeps read-only mirror work isolated from write-capable CLI operations; resilience if one agent is down | Duplication of context ingestion, drift between mirror and local truth if synchronization lags | ✅ Keep split, but require MCP-backed shared state for handoffs | Mirror excels at narrative synthesis; CLI handles execution |
| API Mode (Gemini) vs. interactive agents | Allows parallel automated runs without tying up human-interactive sessions; suits high-throughput API tasks | Broker scripts must stay in sync with governance; risk of “shadow decisions” unseen by other agents | ✅ Keep but wrap broker state in MCP so transcripts and state diffs are visible | Gemini should publish checkpoints into MCP before/after jobs |
| Supervisor Agent vs. embedded coordination | Dedicated supervisor could manage retrieval, approvals, and scheduling so workers focus on tasks | New single point of failure; extra latency round-trips; unclear host environment | ⚠️ Defer until MCP MVP proves reliable | Start with lightweight coordination scripts; revisit once observability exists |
| Planner vs. Executor within a single agent | Allows clean prompt windows (planner free of execution noise, executor guided by concise plan) | Increased token overhead and synchronization complexity | ⚠️ Case-by-case – use only for mega-tasks >1K steps | For routine work, Codex can plan + execute sequentially without separate personas |

**Your Analysis:**
Multi-agent design is justified when separate context windows genuinely reduce cognitive load or when isolation is required for safety. The current trio (Codex, Claude Code, Gemini) meets that bar because each agent has different IO constraints. However, introducing additional supervisory personas without strong observability would simply add failure modes. MCP should first act as the shared memory bus—once that is trustworthy we can revisit whether a formal supervisor adds value.

**Open Questions:**

- Can the MCP store make handoffs feel instantaneous (shared plan objects) so the existing triad behaves like facets of one agent?
- Who operates the supervisor if/when we add it—human-triggered or always-on service?

---

## Section 10: Architecture Ceiling Test (Collaborative)

| Potential Ceiling | Why It Exists | Impact on Stronger Models | Mitigation Idea | Notes |
|-------------------|---------------|---------------------------|-----------------|-------|
| Monolithic session macro that front-loads 60 KB of governance | Built for safety when MCP didn’t exist; assumes agent can’t retrieve later | Even GPT-5 wastes context budget parsing static text each session | Replace with MCP-backed view compiler + retrieval triggers; keep macro as fallback | Needs contract guaranteeing fallback when MCP unreachable |
| File-only authoritative source | Governance lives solely in Markdown; no API for structured queries | More capable models still have to grep files manually | Introduce MCP schemas (JSON) while retaining local mirror for audit | Maintain write-protected mirror to uphold “local authoritative” principle |
| Manual handoff notes | Each agent writes free-form summaries; next agent must re-interpret | Smarter models still burn time parsing prose; risk of ambiguity | Standardize handoffs using the summarization schema and store in MCP | Provide tooling to generate/export handoff packets automatically |
| Stateless sessions for mirror agent | ChatGPT forgets prior steps once run ends; no persistent store besides docs | Better models can reason deeper per session but still cold-start each day | Use MCP to persist structured memories (commitments, failures) so new sessions load them quickly | Needs clear retention/expiration policy to avoid stale guidance |

**Your Analysis:**
Most ceilings stem from architectural guardrails added when tooling was weaker. Even if we swapped in a more capable model, we would still be limited by the macro that dumps every governance doc and by the lack of structured handoffs. MCP should therefore be treated as an enabling refactor: codify constraints into schemas, expose APIs for retrieval, and keep file-based fallbacks. Only after those ceilings are removed will model upgrades yield proportional benefits.

**Open Questions:**

- How strict should we be about MCP availability SLAs before we allow the macro to shrink?
- Do we need automated diff alerts when Markdown governance changes without the MCP schema updating?

---

## Section 12: Demystifying Agentic Memory (Non-Technical)

| Scenario / Anecdote | Explanation Given | Analogy Used | Follow-up Questions | Notes |
|---------------------|-------------------|--------------|---------------------|-------|
| User asked AI to remember a feature flag but it “forgot” during deployment | The agent only keeps a short “chalkboard” of info; once it gets crowded, older notes are erased unless saved elsewhere | Whiteboard in a meeting room—if you never photograph it, the info is gone when someone wipes it | “Can we auto-save the whiteboard between meetings?” | Good story for why MCP needs durable storage |
| AI kept retrying the same broken command during troubleshooting | Nothing signaled that the prior attempt failed, so the agent assumed it was a fresh idea each time | Assembly line without defect tags—bad parts keep circulating because nobody labels them | “How do we tag a failed attempt so the next shift avoids it?” | Motivates the failure ledger in the schema |
| AI felt smart when it recalled a user’s preferred deployment checklist | That info lived in an external “filing cabinet” (doc) and the agent pulled it just-in-time | Desk vs. filing cabinet—the desk (context window) stays tidy if you only bring out what you need | “What if the cabinet is locked?” | Highlights need for MCP availability + fallback |

**Your Non-Technical Explanation:**
Think of an AI session as working at a small desk. The desk only fits a few papers—the immediate instructions, the file you’re editing, maybe one checklist. Everything else lives in filing cabinets around the room. When people say “the AI remembered,” what usually happened is that the agent wrote something down in a cabinet (a document, a database, a note) and then fetched it later. Without that, the desk gets wiped clean whenever the conversation runs long or the meeting ends.

MCP is essentially a smart filing clerk. Instead of the agent rummaging through every cabinet each time, it can ask the clerk, “Bring me the deployment checklist for project Mosaic” or “Remind me what went wrong last time we ran tests.” This keeps the desk tidy (smaller prompts, fewer mistakes) while ensuring nothing critical is lost. The trade-off is that if the clerk is unavailable—or brings the wrong folder—the agent needs a fallback plan (reading the documents itself). That’s why we’re designing schemas, triggers, and observability: so we always know what’s on the desk, what’s in the cabinets, and why.

**Open Questions:**

- Should user-facing documentation include this analogy so non-technical stakeholders understand why MCP work matters?
- Do we need a lightweight UI for browsing the “filing cabinet” outside of chat-based agents?

---

## ChatGPT Mirror Integration Questions

1. **Can ChatGPT query HTTP MCP servers?**
   Not directly—mirror sessions are file-only. I can read anything mirrored into the repo (or GDrive mirror) but cannot initiate arbitrary HTTP calls. MCP data must therefore be materialized as files/snapshots that stay within the mirror sandbox.

2. **How does MCP affect your GDrive Mirror reads?**
   If MCP becomes the orchestration layer, it must export curated artifacts (summaries, view bundles) into the mirror so I can keep functioning. Otherwise, my onboarding macro loses its source material. Ideally the MCP server writes to `docs/mcp_exports/` whenever state changes.

3. **What happens to your governance document summaries if MCP holds context?**
   Summaries remain my responsibility, but they should be generated via the schema above and checked into the mirror. MCP could host the structured version, yet the mirror still needs a rendered copy so I can cite chapters and line numbers.

4. **How do you handle MCP server unavailability?**
   I fall back to the current file-based workflow: load governance Markdown directly, rely on manual handoffs, and document that MCP was unreachable. We must script automatic exports so the mirror never depends on a live query.

5. **Should ChatGPT sessions have persistent memory across conversations?**
   Only via external artifacts. Raw cross-session memory inside ChatGPT is unavailable, but MCP can provide that persistence by writing structured notes I can re-read at the next login. This keeps human auditability and avoids phantom memories the team cannot inspect.

---

## Overall Recommendation

- **Go/No-Go Opinion:** ⚠️ Conditional Go
- **Rationale:** MCP can cut mirror context usage by >70 % and provide auditable handoffs, but only if it exports artifacts into the mirror and maintains a reliable fallback path. Without that, Codex loses access to governance truth.
- **Critical Requirements for ChatGPT Mirror:**
  1. MCP must publish schema-validated summaries and handoff packets into the repo/mirror on every update.
  2. View compiler outputs need stable filenames so Codex can “include by reference” without ad-hoc scraping.
  3. Every MCP dependency (retrieval, supervisor decisions) requires provenance metadata embedded in the exported files.
  4. Fallback remains first-class: if exports are stale >24 h, session macros revert to direct Markdown loads automatically.

Once those artifacts exist and we prove the export cycle is reliable, I’m comfortable shrinking the startup macro and leaning on MCP-managed context. Until then, the mirror agent must assume MCP is advisory rather than authoritative.

---

## MCP Task Status (2025-12-09)

- [x] **Task 1B – Structured Session Log Schema:** Implemented `.ai-agents/session_context/SESSION_LOG_SCHEMA.json` with the seven-field summary (causal steps, constraints, failures, commitments, entities, dependencies, provenance) plus event-level traceability hooks.
- [ ] **Task 2B – Mirror Export Design:** Blocked until Phase 2; will start once Phase 1 verification completes.
