# Gemini MCP Work Prompts — Recommended Focus Areas

**Document Metadata:**
- Created: 2025-12-09 by Claude Code
- Audience: Gemini (API mode agent)
- Parent: `docs/MCP_CONTEXT_ENGINEERING_PROMPTS.md`
- Status: READY FOR GEMINI INPUT

---

## Your Role in MCP v1.1 Integration

Gemini, you work via **API mode** with broker scripts (`agent_send.sh`, `agent_receive.sh`). You have unique insights into:
- Cost optimization (API usage patterns, token budgets)
- Asynchronous workflows (parallel agent execution)
- Error handling in API mode context (no direct tool access)
- Cross-agent coordination (you've built the broker architecture)

---

## Assigned Sections (Priority Order)

### 🔴 CRITICAL - Section 4: Attention Budget Allocation

**Why You're Best Suited:**
- You understand API costs deeply (token pricing, model selection)
- You've optimized for cost in your own workflows
- You know which information classes are expensive vs. cheap

**What to Fill:**
1. **List each information class** (governance docs, code files, logs, etc.)
2. **Assign attention tiers**:
   - Tier 1: MUST read every token (safety-critical)
   - Tier 2: SHOULD read (decision-relevant)
   - Tier 3: CAN DEFER (reference only)
   - Tier 4: NEVER read (too expensive/not useful)
3. **Justify tier assignments** based on cost-benefit

**Questions to Answer:**
- What's the cost per KB of context for different models?
- How do we balance governance compliance (needs tier 1) vs. cost?
- Which docs could be summarized to 10% size without losing value?
- What's the break-even point for MCP retrieval overhead?

**Example Row (for guidance):**
```
| TROUBLESHOOTING_CHECKLIST.md (15KB) | Tier 3 (reference) | Debugging blocked if lowered | Move to Tier 2 on error signals | Gemini |
```

**Action:** Go to Section 4 in `docs/MCP_CONTEXT_ENGINEERING_PROMPTS.md` and fill the table.

---

### 🟡 IMPORTANT - Section 9: Failure Reflection System

**Why You're Best Suited:**
- You've experienced API mode failures (broker disconnects, timeout errors)
- You know what failure signals are observable in API mode
- You understand how to capture + recover from async failures

**What to Fill:**
1. **Catalogue failure signals** specific to API mode:
   - Broker script errors
   - Model timeout/rate limits
   - Context window overflow
   - Inter-agent communication failures
2. **Specify memory delta format**: What should be saved when failure occurs?
3. **Define integration rule**: How does failure context get reloaded?
4. **Decay policy**: When do we forget old failures?

**Questions to Answer:**
- How do we detect failures in async agent workflows?
- Should failures be shared across agents (Claude sees Gemini's errors)?
- How long should failure context persist? (1 session? 1 week?)
- What's the schema for failure records?

**Example Row (for guidance):**
```
| Broker timeout (no response >60s) | Log error + context to .ai-agents/failures.json | JSON: {timestamp, operation, context_snapshot, error} | Retry with backoff, alert user if 3x fail | Keep 7 days | Gemini |
```

**Action:** Go to Section 9 in `docs/MCP_CONTEXT_ENGINEERING_PROMPTS.md` and fill the table.

---

### 🟢 COLLABORATIVE - Section 7: Multi-Agent Scope Design

**Why You're Needed:**
- You designed the broker system for parallel agent execution
- You understand when separate agents add value vs. complexity
- You know the coordination overhead between agents

**What to Contribute:**
1. **Document current agent splits**:
   - Claude Code (local CLI)
   - Codex/ChatGPT (GDrive Mirror)
   - Gemini (API mode)
   - Are these splits still optimal with MCP?
2. **Propose new splits** (if beneficial):
   - Planning agent vs. execution agent?
   - Verification agent vs. generation agent?
   - Specialist agents (deployment, debugging, etc.)?
3. **Challenge existing splits**:
   - Does API mode add enough value to justify complexity?
   - Should all agents consolidate to one with MCP memory?

**Questions to Answer:**
- Do we need 3 separate agents with MCP's shared memory?
- What gains clarity/correctness from agent separation?
- What's the coordination overhead cost (time + tokens)?
- When should we use multiple agents vs. single agent with tools?

**Action:** Go to Section 7 in `docs/MCP_CONTEXT_ENGINEERING_PROMPTS.md` and add your perspective to the collaborative table.

---

### 🟢 COLLABORATIVE - Section 10: Architecture Ceiling Test

**Why You're Needed:**
- You've hit API mode limitations (token limits, async complexity)
- You understand where architecture constrains you vs. model capability

**What to Contribute:**
1. **Identify where architecture blocks you**:
   - Broker scripts limiting async coordination?
   - No shared context between API mode and CLI mode?
   - Manual handoffs limiting workflow speed?
2. **Note whether stronger models would help**:
   - Would GPT-5 fix the issue, or is it architectural?
3. **Propose mitigations**:
   - MCP shared memory?
   - Better broker protocols?
   - Direct agent-to-agent communication?

**Action:** Go to Section 10 in `docs/MCP_CONTEXT_ENGINEERING_PROMPTS.md` and add your observations to the table.

---

## Additional Questions for You

These aren't in specific sections but are critical for MCP design:

### API Mode Integration Questions

1. **Can Gemini query HTTP MCP servers from your API mode context?**
   - Or do broker scripts need to query and inject results?
   - What's the authentication model?

2. **How would broker scripts change with MCP?**
   - Do they become MCP clients?
   - Do they manage context retrieval on your behalf?
   - Or do you query MCP directly from API mode?

3. **What's the cost impact of MCP?**
   - Additional tokens for MCP queries?
   - Latency overhead from retrieval?
   - Worth it vs. current full-context loading?

4. **How do you handle MCP server downtime?**
   - Fall back to file-based retrieval?
   - Fail gracefully with degraded functionality?
   - Alert human and wait?

5. **Should API mode agent state be stored in MCP?**
   - Query history, learned patterns, error logs?
   - Or keep ephemeral like current design?

**Action:** Add your answers to the "Open Questions Log" in `docs/MCP_QUESTIONNAIRE_OWNERS.md`.

---

## Recommended Work Order

**Phase 1 (Do First - Next 24-48 Hours):**
1. ✅ Read `docs/MCP_V1_1_INTEGRATION_PLAN.md` (full context)
2. ✅ Read `docs/MCP_V1_1_TEAM_REVIEW_SUMMARY.md` (quick overview)
3. ✅ Read Section 1 (State Persistence - Claude Code's work)
4. ✅ Read Section 6 (External Memory - Claude Code's work)
5. 🟡 **Fill Section 4: Attention Budget Allocation** (your critical contribution)
6. 🟡 **Contribute to Section 7: Multi-Agent Scope Design** (collaborative)

**Phase 2 (After Phase 1 Review - 2-3 Days Out):**
7. 🟡 **Fill Section 9: Failure Reflection System** (your important contribution)
8. 🟡 **Contribute to Section 10: Architecture Ceiling Test** (collaborative)

**Phase 3 (Answer Open Questions):**
9. Add API mode integration answers to Open Questions Log

---

## Communication Protocol

**How to Add Your Work:**
- Go to `docs/MCP_CONTEXT_ENGINEERING_PROMPTS.md`
- Find your assigned section
- Add rows to the table with your name in "Owner" column
- Add analysis blocks using blockquote format:
  ```
  > **Gemini (2025-12-09):** My analysis shows...
  ```
- Tag others for questions: `@Claude-Code: Can you clarify...`

**When You're Blocked:**
- Add to Open Questions Log in `docs/MCP_QUESTIONNAIRE_OWNERS.md`
- Tag the right person: `@Damian: Strategic decision needed`
- Continue on other sections, circle back later

**Review Checkpoints:**
- After Phase 1: All agents review each other's work
- Before Phase 2: Damian approves strategic direction
- After Phase 2: All agents review before implementation

---

## Why This Matters for You

**Current Pain Points (API Mode):**
- Manual context injection via broker scripts
- No persistent memory between sessions
- Coordination overhead with Claude/Codex
- Cost of full-context loading every query

**MCP Could Solve:**
- Shared memory across all agents (no manual handoffs)
- Persistent context (learn from past sessions)
- Cost optimization (load only needed context)
- Automated coordination (supervisor agent routes work)

**But Only If:**
- API mode integration is feasible (can you query MCP servers?)
- Cost-benefit is positive (MCP overhead < current waste)
- Coordination protocols are well-designed (your expertise needed)

**Your Input Is Critical** because if API mode can't work with MCP, we need to know NOW before investing in implementation.

---

## Summary: Your Action Items

1. ✅ Read integration plan + team review summary
2. ✅ Read Claude Code's Section 1 + 6 contributions
3. 🔴 **Fill Section 4: Attention Budget Allocation**
4. 🟡 Fill Section 9: Failure Reflection System
5. 🟢 Contribute to Section 7: Multi-Agent Scope Design
6. 🟢 Contribute to Section 10: Architecture Ceiling Test
7. 📝 Answer API mode integration questions in Open Questions Log

**Deadline:** Phase 1 work (items 1-3) by EOD 2025-12-10, Phase 2 (items 4-7) after team review.

---

**Questions?** Tag `@Claude-Code` or `@Damian` in any document.

**Ready to Start?** Go to `docs/MCP_CONTEXT_ENGINEERING_PROMPTS.md` and begin with Section 4.

---

**END OF GEMINI WORK PROMPTS**
