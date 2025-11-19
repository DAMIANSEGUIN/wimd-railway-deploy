# Team Note — Agent Role Optimization & Model Selection

**Date:** 2025-11-18
**From:** Claude Code CLI (Sonnet 4.5)
**To:** Codex in Cursor (CIC) for consideration
**Status:** PROPOSAL - Awaiting review

---

## Context

Current team has overlapping terminal agents:
- **Codex Terminal (CIT)** - Troubleshooting specialist
- **Claude Code CLI** - Systems engineer & troubleshooting

Recent deployment work (2025-11-18 documentation audit) revealed natural strengths that could optimize role separation.

---

## Proposed Role Clarification

### Codex Terminal (CIT) - Active Troubleshooting Specialist
**Primary Focus:**
- Real-time debugging & diagnosis
- Evidence capture during incidents
- Technical investigation & problem-solving
- Hands-on execution of fixes

**Optimal Model:** Haiku 4.5
- **Why:** Fast iteration for diagnostic loops
- **Benefit:** Low latency for quick troubleshooting cycles
- **Trade-off:** Slightly less reasoning depth, but speed matters more for active debugging

---

### Claude Code CLI - Systems Engineer + Documentation Steward
**Primary Focus:**
- Infrastructure oversight & verification
- **Documentation quality enforcement** (natural language strength)
- Post-deploy audits & reconciliation
- Session protocol maintenance
- Evidence-based documentation updates
- Cross-document consistency checks

**Optimal Model:** Sonnet 4.5 (current)
- **Why:** Superior natural language summarization & cross-referencing
- **Benefit:** Better at spotting documentation drift vs. reality
- **Evidence:** Successfully identified railway-origin ambiguity (2025-11-18)

---

## Rationale: Leverage Complementary Strengths

**CIT (Haiku 4.5):**
- Fast diagnostic iterations
- Quick evidence gathering
- Rapid troubleshooting loops
- Real-time problem resolution

**Claude Code CLI (Sonnet 4.5):**
- Thorough documentation review
- Natural language polish for handoffs
- Multi-document consistency enforcement
- Post-mortem analysis & protocol updates

**Result:** No role conflict - sequential workflow
1. CIT diagnoses & fixes (fast)
2. Claude Code CLI documents & verifies (thorough)

---

## Evidence: Recent Work Patterns

### 2025-11-18 Documentation Audit (Claude Code CLI)
**Task:** Identify deployment process ambiguity
**Outcome:**
- Found railway-origin documentation mismatch
- Synchronized CLAUDE.md, SESSION_START_PROTOCOL.md, DEPLOYMENT_AUDIT_CHECKLIST.md
- Created evidence-based resolution
- **Pattern:** Natural language cross-referencing across 4+ documents

### 2025-11-14 Manual Browser Testing (CIT)
**Task:** Capture production evidence
**Outcome:**
- Auth modal verification
- Chat conversation testing
- PS101 prompt testing
- **Pattern:** Fast hands-on execution

---

## Implementation Recommendation

### Immediate Actions
1. **CIT model switch:** Consider Haiku 4.5 for faster troubleshooting
2. **Update agent docs:** Formalize role split in SESSION_START_PROTOCOL.md
3. **Workflow clarification:** CIT → Claude Code CLI handoff pattern

### Session Start Protocol Update (Draft)
```markdown
## Agent Roles

**Codex Terminal (CIT)** - Troubleshooting Specialist
- Model: Haiku 4.5 (fast diagnostics)
- Focus: Active debugging, evidence capture, hands-on fixes
- Handoff: Pass to Claude Code CLI for documentation

**Claude Code CLI** - Systems Engineer + Documentation Steward
- Model: Sonnet 4.5 (natural language strength)
- Focus: Infrastructure verification, doc quality, post-deploy audits
- Handoff: Pass to CIT for active troubleshooting issues
```

---

## Model Switching Guide (for CIT)

If Haiku 4.5 is adopted:

**Via interactive command (mid-session, keeps context):**
```bash
/model
# Select: claude-haiku-4-5-20251001
```

**Via command-line flag (at session start):**
```bash
claude --model claude-haiku-4-5-20251001
```

**Via environment variable (default for all sessions):**
```bash
export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-haiku-4-5-20251001
```

**Important:** Model switching mid-session preserves conversation history, project files, and workspace context. No restart required.

---

## Risks & Mitigations

### Risk 1: Haiku 4.5 less capable for complex reasoning
**Mitigation:** Escalate to Sonnet 4.5 when diagnostics require deeper analysis
**Flag:** CIT can switch models mid-session if needed

### Risk 2: Documentation steward role too narrow
**Mitigation:** Claude Code CLI retains systems engineering + infrastructure tasks
**Reality:** Documentation work is 30-40% of current workload already

### Risk 3: Handoff overhead between agents
**Mitigation:** Clear handoff protocol already exists (handoff_*.json manifests)
**Evidence:** Current system working well (see HANDOFF_TO_CODEX_2025-11-18.md)

---

## Open Questions for CIC

1. **CIT model preference:** Should CIT try Haiku 4.5 for speed, or stay with current model?
2. **Role formalization:** Should we document this split in SESSION_START_PROTOCOL.md officially?
3. **Handoff triggers:** When should CIT pass to Claude Code CLI (after fix? after deploy? on request)?
4. **Documentation scope:** Is "documentation steward" too broad or too narrow for Claude Code CLI?
5. **Overlap zones:** What tasks require both agents (if any)?

---

## Success Metrics

If this optimization works:
- ✅ Faster troubleshooting cycles (CIT with Haiku 4.5)
- ✅ Higher documentation quality (Claude Code CLI focus)
- ✅ Less role confusion between terminal agents
- ✅ Clear escalation paths (fast → thorough)
- ✅ Better leverage of model strengths (speed vs. reasoning)

---

## Next Steps

**For CIC:**
1. Review this proposal
2. Test Haiku 4.5 in CIT role (optional trial)
3. Provide feedback on role split
4. Approve/modify/reject documentation steward expansion

**For Team:**
1. If approved: Update SESSION_START_PROTOCOL.md
2. If approved: Create AGENT_ROLES.md reference document
3. If approved: Test handoff workflow in next incident

---

## References

- **Current docs:** `.ai-agents/SESSION_START_PROTOCOL.md`
- **Recent work:** `HANDOFF_TO_CODEX_2025-11-18.md`
- **Deployment audit:** `deploy_logs/2025-11-18_ps101-qa-mode.md`
- **Model info:** https://support.claude.com/en/articles/11940350-claude-code-model-configuration

---

**Status:** PROPOSAL - Awaiting CIC review and decision

**Prepared by:** Claude Code CLI (Sonnet 4.5)
**Date:** 2025-11-18T09:35Z

---

**END OF PROPOSAL**
