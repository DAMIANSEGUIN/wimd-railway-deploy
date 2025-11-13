# Baseline Snapshot - Thu 13 Nov 2025 18:50:33 EST

## Git State
```
On branch restore-prod-2025-11-13
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	BASELINE_SNAPSHOT_20251113-185033.md

nothing added to commit but untracked files present (use "git add" to track)
```

## Current Branch & Commit
- Branch: restore-prod-2025-11-13
- Commit: d7afcf48495a4c580c173f72e8140489dd9e5a0b
- Message: Fix deploy gate logging default

## Modified Files
```

```

## Staged Files
```

```

## Untracked Files
```
BASELINE_SNAPSHOT_20251113-185033.md
```

## Critical File Checksums
- index.html: 8936ec0e2e6d98f9f743dddb4439738c0645b9426bc3dab5efe5232911727879  frontend/index.html
- netlify.toml: c7abafd547aadb24d547a51fb8ed7ac3d2c543e43319c1fa28b5a543143a3872  frontend/netlify.toml
- package.json: 0cdba7ff9c08eeacf513a7bf556d14d665a6cd869e7bc2eb25b0e89f77385b91  package.json

## Deployment Status
- Last Railway deploy: [Check Railway dashboard]
- Last Netlify deploy: [Check Netlify dashboard]
- Health check: Failed

## What's Being Attempted
- Restore Mosaic UI/backend to the certified `prod-2025-11-13` baseline (commit d72b609) for rollback readiness.
- Validate deployment guardrails (gate script, baseline capture) prior to handoff to Codex in Cursor.

## Expected Changes
- `frontend/` and `mosaic_ui/` match the Nov 13 production artefact (line count 4327 ± tolerance).
- Guardrail documentation/scripts (deployment baseline, deploy gate) present alongside the restored build.

## Rollback Plan
```bash
git reset --hard d7afcf48495a4c580c173f72e8140489dd9e5a0b
# Or: git checkout restore-prod-2025-11-13
```
