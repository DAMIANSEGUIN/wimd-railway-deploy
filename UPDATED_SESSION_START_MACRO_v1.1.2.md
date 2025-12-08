# SESSION START MACRO — v1.1.2
**Document Metadata:**
- Created: 2025-12-06
- Last Updated: 2025-12-06 by Gemini
- Status: ACTIVE

NOTE: This macro fully replaces the legacy `SESSION_START_v2.md`, which is now
DEPRECATED. Agents must NOT load or execute `SESSION_START_v2.md` for any
active Mosaic workflow.

## Sequence
1. Load this macro.
2. Load META_GOVERNANCE_CANON_MVP_v1.0.md.
3. Load GLOBAL_META_INSTRUCTION_v2.0.md.
4. Load MOSAIC_CODESTYLE_CODEX_MVP_v1.0.md.
5. Load MOSAIC_CODEX_ELITE_BENCHMARK_ADDENDUM_v1.1.2.md.
6. Confirm MODE: OPTION A is active.

## Session Initialization

### Repo Context Memory Initialization

- This agent acknowledges the three-layer Mosaic architecture:
  LOCAL AUTHORITATIVE → GDRIVE MASTER → GDRIVE CONSULTING MIRROR.
- All reads occur from the Mirror (ChatGPT) or Local (others).
- All writes occur locally only.
- Sync is performed exclusively by the google-drive-sync.sh service.
- Drift is not permitted; Mirror is always subordinate to Local/Master.

If repo context is missing, request the “MOSAIC_GOVERNANCE_ARCHITECTURE_ADDENDUM_v1.0.md” recovery file.

---
Beginning Mosaic session.  
Active Mode: OPTION A  
Benchmark Addendum: v1.1.2