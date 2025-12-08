# GOVERNANCE_UPDATE_INDEX.md

Mosaic Governance – Update Index
================================

This package contains the following files:

1. `INSERTIONS_FOR_GEMINI.md`
   - Cut-and-paste insertion blocks for:
     - META_GOVERNANCE_CANON_MVP_v1.0.md
     - MOSAIC_GOVERNANCE_STATE_MVP_v1.0.md
     - README.md
     - UPDATED_SESSION_START_MACRO_v1.1.2.md
     - MOSAIC_META_PROMPT_TEMPLATE_MVP_v1.0.md
     - TEAM_HANDOFF_BRIEF_v1.0.md
   - Includes a Gemini recovery prompt snippet.

2. `MOSAIC_GOVERNANCE_ARCHITECTURE_ADDENDUM_v1.0.md`
   - Canonical description of:
     - Local / Master / Mirror architecture
     - Sync script and scheduling
     - Drift rules
     - AI access model
     - Recovery protocol
     - Operator responsibilities

Update order during a governance refresh or recovery:

1. Edit LOCAL copies of the target files.
2. Apply the insertion blocks from `INSERTIONS_FOR_GEMINI.md`.
3. Ensure the addendum file is stored in the same governance family.
4. Run the sync script locally:

   `/Users/damianseguin/.local/bin/google-drive-sync.sh`

5. Confirm that GDrive Master and GDrive Consulting Mirror are up to date.
