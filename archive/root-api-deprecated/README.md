# Archived API Directory

This directory was the root-level /api folder that duplicated /backend/api.

**Date Archived**: 2026-01-27
**Reason**: Dual API directories caused deployment ambiguity
**Canonical Source**: /backend/api/ (per authority_map.json)

## Context

The /api/ directory at project root conflicted with /backend/api/:
- Different file sizes (75KB vs 82KB in index.py)
- Caused Python import confusion
- Deployment config points to /backend/ as root

## Files Archived

      35 files

## Restoration

If needed, restore with:
```
mv archive/root-api-deprecated/api ./
```

See: CODEBASE_HEALTH_AUDIT implementation (2026-01-27)
