# SESSION START CANONICAL DOCUMENT

This document defines the deterministic session start protocol for Mosaic.

## Current State

- State: This is a BOOTSTRAP of a Mosaic session.
- Authority Services:
  - `mosaic-frontend`: configured in `.mosaic/authority_map.json`
  - `mosaic-backend`: configured in `.mosaic/authority_map.json`

## Mandatory First Command

`scripts/mosaic_enforce.sh --mode=local --target=<service_name>`

## Prohibitions

- Re-bootstrap phrases or actions.
- Re-litigation of established rules.
- Reliance on unverified assumptions or chat memory.

## Error Codes

- E001: Missing authority map
- E002: Origin mismatch
- E003: Branch mismatch
- E004: Target service unspecified/invalid
- E005: Runtime commit mismatch
- E006: Cannot reach runtime endpoint