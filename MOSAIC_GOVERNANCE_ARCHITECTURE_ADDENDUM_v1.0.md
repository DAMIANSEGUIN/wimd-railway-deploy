# MOSAIC_GOVERNANCE_ARCHITECTURE_ADDENDUM_v1.0

Mosaic Governance – Architecture & Repo Model Addendum
======================================================

## 1. Purpose

This addendum defines the canonical repository architecture, sync model, AI access rules,
and drift-governance for all Mosaic-related work (Mosaic, WIMD, PS101, OpportunityBridge).

Any AI agent or human collaborator that interacts with Mosaic MUST treat this document
as authoritative for:

- Where files live
- Who can edit them
- How changes propagate
- How to recover if context is lost

---

## 2. Repository Architecture

### 2.1 Local Authoritative Workspace (Primary Source of Truth)

**Path (on Damian's Mac):**
`/Users/damianseguin/AI_Workspace/WIMD-Railway_Deploy_Project`

Contains:

- All editable governance documents
- All architectural specs
- All state and playbooks

Writable by:

- Gemini (Terminal)
- Claude (Terminal)
- Codex in Cursor
- Human operator

ChatGPT Web does **not** write directly to this workspace.

---

### 2.2 GDrive Master Repository (Authoritative Cloud Copy)

Purpose:

- Cloud-based continuity and backup
- Team access
- Long-term storage

Properties:

- Mirrors the Local Authoritative Workspace
- Never edited directly by AI agents or humans
- Updated exclusively by the sync script

When in doubt, Local is treated as more up-to-date than Master.

---

### 2.3 GDrive Consulting Mirror (LLM Consumption Layer)

Purpose:

- Provide a clean, read-only representation of the system to ChatGPT Web
- Decouple analysis and drafting from the authoritative repositories
- Reduce risk of accidental corruption or drift

Properties:

- Overwritten during each sync cycle
- Never edited directly
- Used only for reading by ChatGPT (and other web-only LLM interfaces, if needed)

If Master and Mirror differ, Mirror is assumed stale.

---

## 3. Synchronization Governance

### 3.1 Sync Script

**Script path:**
`/Users/damianseguin/.local/bin/google-drive-sync.sh`

Core responsibilities:

1. Push changes from LOCAL → GDrive Master
2. Push changes from LOCAL → GDrive Consulting Mirror

The script is triggered by LaunchAgents at:

- 12:00
- 18:00
- 21:00

Manual invocation (during active editing sessions):

```bash
/Users/damianseguin/.local/bin/google-drive-sync.sh
```

Only this script is allowed to update GDrive copies.

---

### 3.2 Drift Rules

- If LOCAL ≠ Master → LOCAL is authoritative.
- If Master ≠ Mirror → Master is authoritative, Mirror must be overwritten.
- Mirror is never considered a source of truth; it is a derived view.

All drift resolution flows in one direction:
LOCAL → Master → Mirror.

---

## 4. AI Access Model

| Agent              | Reads From               | Writes To      | Notes                                      |
|--------------------|--------------------------|----------------|--------------------------------------------|
| Gemini (Terminal)  | Local workspace          | Local workspace| No direct GDrive access                    |
| Claude (Terminal)  | Local workspace          | Local workspace| No direct GDrive access                    |
| Codex (Cursor)     | Local workspace          | Local workspace| Used primarily for code-related edits      |
| ChatGPT (Web)      | GDrive Consulting Mirror | *None*         | Analysis, planning, governance integration |

No AI writes directly to GDrive. All GDrive updates flow through the sync script.

---

## 5. Enforcement Rules

### 5.1 Self-Enforcement by AI Agents

Each agent must:

- Identify whether it is operating on Local, Master, or Mirror.
- Refuse to propose or describe a workflow where Mirror becomes a write target.
- Recommend running the sync script whenever documents are meaningfully updated.

When generating instructions for humans, agents MUST:

- Point to Local as the only editable copy.
- Remind the operator to run the sync script if work affects governance, architecture, or other critical documents.

---

### 5.2 Refusal Conditions

Agents should explicitly refuse to:

- Edit files in the GDrive Master repository directly.
- Use the GDrive Consulting Mirror as if it were editable.
- Propose bidirectional sync between Mirror and Local.

The correct response is to:

- Update Local
- Instruct the operator to run the sync script
- Confirm that Master and Mirror will update via that channel

---

## 6. Recovery Protocol

When any AI agent loses Mosaic architectural or governance context:

1. Load this addendum: `MOSAIC_GOVERNANCE_ARCHITECTURE_ADDENDUM_v1.0.md`
2. Reconstruct an internal model of:
   - Local / Master / Mirror roles
   - Sync script responsibilities
   - Drift resolution rules
3. If the canonical governance docs are out of date, apply the blocks from `INSERTIONS_FOR_GEMINI.md` to:
   - META_GOVERNANCE_CANON_MVP_v1.0.md
   - MOSAIC_GOVERNANCE_STATE_MVP_v1.0.md
   - README.md
   - UPDATED_SESSION_START_MACRO_v1.1.2.md
   - MOSAIC_META_PROMPT_TEMPLATE_MVP_v1.0.md
   - TEAM_HANDOFF_BRIEF_v1.0.md
4. Instruct the operator (once) to run:

```bash
/Users/damianseguin/.local/bin/google-drive-sync.sh
```

After that, do not ask again unless architecture changes.

---

## 7. Operator Responsibilities (Minimal)

To keep the system healthy, the operator is only required to:

- Run the manual sync script when:
  - Governance or architecture documents are edited
  - Major structural changes are made

Everything else (documentation layout, drift rules, sync governance) is defined and enforced here.

---

## 8. Summary for Future Agents

If you are an AI agent reading this:

- Never invent a new repo layout for Mosaic.
- Never make Mirror or Master editable in your mental model.
- Always treat Local as the source of truth.
- Use this file plus INSERTIONS_FOR_GEMINI.md to repair or re-align governance.

This is the canonical architectural governance for Mosaic.
