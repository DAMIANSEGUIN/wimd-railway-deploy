# INSERTIONS_FOR_GEMINI.md

Mosaic Governance – Gemini Insertion Package (Deliverable A)
===========================================================

Purpose
-------

This file provides insertion-ready blocks to repair or update Mosaic governance documents
when an AI agent (Gemini, Claude, Codex, ChatGPT) has lost architectural or governance context.

Each block includes:

- Target filename
- Target section anchor
- Markdown content to insert
- Brief team note

Use: copy individual blocks into the appropriate files in the LOCAL workspace, then run the sync script.

---

## A1. Insert into `META_GOVERNANCE_CANON_MVP_v1.0.md`

**Target section:** `## SYSTEM GOVERNANCE ROOT`

```markdown
### 1.3 Multi-Repo Architecture (Authoritative Definition)

The Mosaic system operates on a three-layer repository model:

1. LOCAL AUTHORITATIVE WORKSPACE
   - Location: /Users/damianseguin/AI_Workspace/WIMD-Render_Deploy_Project
   - Contains the real, editable files.
   - Edited by Gemini (Terminal), Claude (Terminal), Codex (Cursor), and human.

2. GDRIVE MASTER REPOSITORY (Authoritative Cloud Copy)
   - The single cloud source of truth for governance and documentation.
   - Mirrors the local workspace using the scheduled google-drive-sync.sh service.
   - Used by ChatGPT (web) to access and maintain continuity across sessions.

3. GDRIVE CONSULTING MIRROR (LLM Consumption Layer)
   - Contains a clean, structured mirror of all documents needed by LLMs.
   - Purpose: prevent ChatGPT/Gemini/Claude from accidentally modifying the Master.
   - Always overwritten by the sync process; cannot diverge.

Governance Principle:
Local ➜ Master ➜ Mirror is a one-directional, controlled flow.
Mirror ➜ Master or Mirror ➜ Local flows are explicitly forbidden.

This section defines the canonical architecture for all future Mosaic, WIMD, PS101, and OpportunityBridge operations.
```

**Team Note:** Establishes the single, authoritative architecture across all agents.

---

## A2. Insert into `MOSAIC_GOVERNANCE_STATE_MVP_v1.0.md`

**Target section:** `## ACTIVE STATE RULES`

```markdown
### 2.4 Repo Synchronization & Drift Governance

A. Scheduled Sync
- Sync script path: /Users/damianseguin/.local/bin/google-drive-sync.sh
- Trigger: LaunchAgents at 12:00, 18:00, 21:00 daily.
- Function:
  1. Push LOCAL → GDrive Master
  2. Push LOCAL → GDrive Consulting Mirror

B. Manual Sync Protocol (Session Mode)
When updating governance files or any architectural documentation, human operator runs:
    /Users/damianseguin/.local/bin/google-drive-sync.sh
This ensures all LLMs receive the updated state immediately.

C. Drift Detection Rule
If Mirror differs from Master, Mirror is always assumed stale.
Mirror must be overwritten from LOCAL during the next sync cycle.

D. AI Access Rule
- ChatGPT Web: Reads from Consulting Mirror only.
- Gemini Terminal: Reads/writes LOCAL only.
- Claude Terminal: Reads/writes LOCAL only.
- Codex (Cursor): Reads/writes LOCAL only.

Agents MUST NOT directly write to GDrive. Only the sync service performs cloud writes.
```

**Team Note:** Encodes the sync and drift rules so they are enforceable.

---

## A3. Insert into `README.md`

**Placement:** New section titled “FAST GUIDE: Which Repo Do I Use?”

```markdown
## FAST GUIDE: Which Repo Do I Use?

LOCAL (edit here):
  /Users/damianseguin/AI_Workspace/WIMD-Render_Deploy_Project

GDRIVE MASTER (authoritative cloud):
  Located in Google Drive under Mosaic/Master

GDRIVE CONSULTING MIRROR (LLM-only):
  Located in Google Drive under Mosaic/Consulting_Mirror

Manual Sync (run anytime):
  /Users/damianseguin/.local/bin/google-drive-sync.sh

Core Rule: Only LOCAL is editable.
All other copies are generated via sync.
```

**Team Note:** Gives humans and agents a 10-second orientation.

---

## A4. Insert into `UPDATED_SESSION_START_MACRO_v1.1.2.md`

**Target section:** Under “Session Initialization”.

```markdown
### Repo Context Memory Initialization

- This agent acknowledges the three-layer Mosaic architecture:
  LOCAL AUTHORITATIVE → GDRIVE MASTER → GDRIVE CONSULTING MIRROR.
- All reads occur from the Mirror (ChatGPT) or Local (others).
- All writes occur locally only.
- Sync is performed exclusively by the google-drive-sync.sh service.
- Drift is not permitted; Mirror is always subordinate to Local/Master.

If repo context is missing, request the “MOSAIC_GOVERNANCE_ARCHITECTURE_ADDENDUM_v1.0.md” recovery file.
```

**Team Note:** Forces agents to reload architecture at session start.

---

## A5. Insert into `MOSAIC_META_PROMPT_TEMPLATE_MVP_v1.0.md`

**Target section:** Under “Constraints”.

```markdown
- You must adhere to Mosaic’s three-layer repository governance model.
- If attempting to access or modify files, determine whether you are operating:
  (1) locally, (2) cloud-master, or (3) consulting-mirror.
- Never write to cloud repositories; request manual sync instead.
```

---

## A6. Cross-Agent Team Note

Add this short note to `TEAM_HANDOFF_BRIEF_v1.0.md`:

```markdown
### Repo Governance Standard (Mosaic)

- Claude Terminal edits LOCAL only.
- Gemini Terminal edits LOCAL only.
- Codex in Cursor edits LOCAL only.
- ChatGPT Web reads from the GDrive Consulting Mirror only.

Cloud repositories (Master and Mirror) are never edited directly. All cloud updates occur via the sync script.
```

---

## A7. Gemini Recovery Prompt Snippet

Use this when Gemini (or any other agent) has lost all awareness of repo layout or governance:

```text
LOAD MOSAIC GOVERNANCE ARCHITECTURE.

Apply the insertion blocks from INSERTIONS_FOR_GEMINI.md into:
- META_GOVERNANCE_CANON_MVP_v1.0.md
- MOSAIC_GOVERNANCE_STATE_MVP_v1.0.md
- README.md
- UPDATED_SESSION_START_MACRO_v1.1.2.md
- MOSAIC_META_PROMPT_TEMPLATE_MVP_v1.0.md
- TEAM_HANDOFF_BRIEF_v1.0.md

Then regenerate the governance view using the three-layer repo model:
LOCAL AUTHORITATIVE → GDRIVE MASTER → GDRIVE CONSULTING MIRROR.

Do not invent alternative architectures. Do not shift responsibility back to the operator.
```
