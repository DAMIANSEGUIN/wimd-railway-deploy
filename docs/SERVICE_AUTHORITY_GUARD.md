# SERVICE AUTHORITY GUARD

## Purpose

This document outlines the purpose and function of the Service Authority Guard.
Its primary responsibilities are to:
- Assert the correct mapping between `repo -> service -> environment -> deploy branch`.
- Fail loudly when a user or agent targets the wrong service.
- Expose authority in Git, not in UI.

## Inputs

- `.mosaic/authority_map.json`
- Environment variables (e.g., expected service ID/URL, Render project/service names).
- Git metadata (origin URL, branch, HEAD SHA).
- Optional: Render status/metadata (if CLI available).

## Outputs

- `ALLOW` (exit 0) with a short machine summary.
- `REJECT` (exit 2) with reason codes + required correction.
- `CLARIFY_REQUIRED` (exit 3) if missing required authority fields.