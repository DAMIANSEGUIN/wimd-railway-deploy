# MOSAIC TEAM HANDOFF BRIEF — v1.0
**Document Metadata:**
- Created: 2025-12-06
- Last Updated: 2025-12-06 by Gemini
- Status: ACTIVE

## Purpose
Provide the Mosaic multi-agent team with a single, canonical source of truth.

## Required Actions for All Agents
1. Load the entire governance bundle before ANY task.
2. Operate in MODE: OPTION A only.
3. Enforce Benchmark Addendum v1.1.2 using the Enforcement Loop.
4. Treat ALL prior governance and implementation docs as deprecated.
5. Specifically: do NOT load or use `SESSION_START_v2.md` for active workflows.
6. Use PLAYBOOK INDEX v1.1.2 for navigation.
7. Use SESSION START MACRO v1.1.2 at the beginning of every new session.

## Prohibited
- Referencing or executing `SESSION_START_v2.md` or other legacy start files.
- Producing outputs that bypass the enforcement loop.
- Generating incremental or incomplete artifacts.

## CRITICAL RISK: Token Cost Estimation
- **Issue:** Agent-based API cost estimates have been proven to be unreliable, with observed discrepancies up to 12.7x lower than actual cost.
- **Protocol:** To mitigate budget overruns, all agents MUST apply a **15x safety multiplier** to their internal cost estimations before reporting costs or triggering any cost-based alerts.
- **Example:** If an agent estimates a cost of $0.10, it must be treated and reported as $1.50 ($0.10 * 15).

## Repo Governance Standard (Mosaic)
- Claude Terminal edits LOCAL only.
- Gemini Terminal edits LOCAL only.
- Codex in Cursor edits LOCAL only.
- ChatGPT Web reads from the GDrive Consulting Mirror only.

Cloud repositories (Master and Mirror) are never edited directly. All cloud updates occur via the sync script.
