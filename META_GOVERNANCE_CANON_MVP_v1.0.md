# META GOVERNANCE CANON — MOSAIC MVP v1.0

**Document Metadata:**

- Created: 2025-12-06 by ChatGPT
- Last Updated: 2025-12-06 by Gemini
- Status: ACTIVE

## SUPERCEDENCE NOTICE

This governance bundle replaces all earlier Mosaic governance and implementation documents.
No prior versions may be referenced for active guidance.

The legacy file `SESSION_START_v2.md` is explicitly DEPRECATED and must not be
loaded, executed, or followed by any agent. It may be retained only in an
`archive/` directory for historical context.

## Purpose

Defines the minimum rules for Mosaic MVP governance and agent behavior.

## SYSTEM GOVERNANCE ROOT

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
