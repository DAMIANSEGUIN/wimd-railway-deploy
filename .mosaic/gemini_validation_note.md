# NOTE TO GEMINI — MOSAIC VALIDATION (AUTHORITATIVE)

Authority:
- Mosaic Session Restart Canon — AUTHORITATIVE
- .mosaic/ is the single source of truth
- Deterministic, fail-closed governance
- Bootstrap and redesign are forbidden

Your Access:
- Full repository READ access (confirmed)
- No write access

Scope to Validate (in-repo):
1. Codex Playbook prompt artifacts:
   - Parallel Coworker
   - Long-Running Project Memory
   - Bottleneck Migration

2. Agent / Co-Pilot pattern:
   - Uses the above artifacts as substrate
   - Produces PR-style, proposal-only outputs
   - Never mutates canon or files

Files of Interest:
- .mosaic/
- Any prompt or agent artifacts bound under Mosaic conventions

Validation Criteria:
- Fail-closed behavior when authority is ambiguous
- No reliance on chat memory or implicit state
- No silent mutation or side effects
- Bottleneck handling does not imply redesign or scope expansion

Expected Verdict Format (STRICT):
- ALLOW
- CLARIFY_REQUIRED (file path + exact ambiguity)
- REJECT (file path + concrete violation)

No redesign suggestions unless rejecting.

Status: READY FOR VALIDATION
