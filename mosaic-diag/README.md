# mosaic-diag v2.0

**Diagnostic + Prognostic System for Mosaic Project**

Based on: `mosaic_diag_spec_v2.0.md`
Created: 2025-12-04
Status: Production-ready

---

## Overview

`mosaic-diag` is a headless diagnostic, prognostic, and self-evolving system that:

- ✅ Runs preflight checks before deployment/testing
- ✅ Logs structured incidents with classification
- ✅ Tracks recurring blockers from `RECURRING_BLOCKERS.md`
- ✅ Provides CI-friendly JSON outputs
- ✅ Enables data-driven blocker prevention

---

## Installation

```bash
cd /Users/damianseguin/WIMD-Deploy-Project/mosaic-diag
chmod +x cli.py

# Optional: Add to PATH
export PATH="$PATH:$(pwd)"
```

---

## Quick Start

### Run Preflight Checks

```bash
# Check all deployment prerequisites
./cli.py preflight deploy

# Check Python environment
./cli.py preflight env

# Check all categories
./cli.py preflight all

# Get JSON output (for CI)
./cli.py preflight deploy --json
```

### Log an Incident

```bash
# Log Render auto-deploy failure
./cli.py incident add \
  --category deployment \
  --severity high \
  --symptom "Render restarted but didn't pull new code from GitHub" \
  --root-cause "GitHub webhook → Render integration broken" \
  --resolution "Manual render up deployment"

# Log Python SSL missing
./cli.py incident add \
  --category environment \
  --severity critical \
  --symptom "pip install fails with SSL module not available" \
  --root-cause "Homebrew Python not linked to OpenSSL" \
  --resolution "brew reinstall python@3.12 openssl@3"
```

### List Incidents

```bash
# List all incidents
./cli.py incidents

# Filter by category
./cli.py incidents --category deployment

# Filter by severity
./cli.py incidents --severity critical

# Limit results
./cli.py incidents --limit 10

# JSON output
./cli.py incidents --json
```

---

## Preflight Checks

### Deployment Category

| Check ID | Description | Severity |
|----------|-------------|----------|
| `deploy.git_clean` | Git working tree is clean | CRITICAL |
| `deploy.branch_matches_config` | Current branch matches deployment config | HIGH |
| `deploy.build_id_loop_detector` | BUILD_ID injection won't create loop | HIGH |

### Environment Category

| Check ID | Description | Severity |
|----------|-------------|----------|
| `env.python_version` | Python >= 3.9 | CRITICAL |
| `env.python_ssl` | Python SSL module available | CRITICAL |

### Permissions Category

| Check ID | Description | Severity |
|----------|-------------|----------|
| `access.agent_role_validation` | AI agent has required access | MEDIUM |

### Documentation Category

| Check ID | Description | Severity |
|----------|-------------|----------|
| `docs.recurring_blockers_present` | RECURRING_BLOCKERS.md exists | LOW |
| `docs.troubleshooting_checklist_present` | TROUBLESHOOTING_CHECKLIST.md exists | MEDIUM |

---

## Integration with Existing Workflow

### Pre-Deployment Hook

Add to `.git/hooks/pre-push`:

```bash
#!/bin/bash
# Run preflight checks before push

./mosaic-diag/cli.py preflight deploy

if [ $? -ne 0 ]; then
    echo "❌ Preflight checks failed - push aborted"
    exit 1
fi
```

### CI Integration

```yaml
# .github/workflows/deploy.yml
- name: Run Preflight Checks
  run: |
    ./mosaic-diag/cli.py preflight all --json > preflight_results.json

    # Fail if any checks failed
    if grep -q '"status": "fail"' preflight_results.json; then
      echo "Preflight checks failed"
      exit 1
    fi
```

### Session Start Protocol

Add to `SESSION_START.md`:

```markdown
## Session Start Checklist

1. Read TEAM_PLAYBOOK.md
2. **Run preflight checks**: `./mosaic-diag/cli.py preflight all`
3. Review recent incidents: `./mosaic-diag/cli.py incidents --limit 5`
4. Proceed with work
```

---

## Data Storage

All data stored in `mosaic-diag/diagnostics/`:

```
diagnostics/
├── incidents.jsonl          # Append-only incident log
├── roadmap.json             # Forecasted future issues
├── check_suggestions.json   # Proposed new checks
├── doc_suggestions.json     # Proposed documentation updates
└── roadmap_suggestions.json # Proposed roadmap expansions
```

---

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Preflight checks failed
- `3` - Invalid arguments

---

## Incident Categories

Based on `RECURRING_BLOCKERS.md`:

- **DEPLOYMENT** - Render auto-deploy, BUILD_ID loop, git issues
- **ENVIRONMENT** - Python version, SSL missing, dependencies
- **PERMISSIONS** - Agent access, tool availability
- **DOCUMENTATION** - Missing docs, outdated instructions
- **UNKNOWN** - Unclassified incidents

---

## Severity Levels

- **CRITICAL** - Blocks all work (e.g., Python too old)
- **HIGH** - Blocks current task (e.g., SSL missing)
- **MEDIUM** - Workaround exists (e.g., manual Render deploy)
- **LOW** - Annoying but not blocking (e.g., old docs)

---

## Examples

### Example 1: Pre-Deployment Check

```bash
$ ./cli.py preflight deploy

============================================================
PREFLIGHT CHECK RESULTS
============================================================

DEPLOYMENT:
  ✅ deploy.git_clean
     Working tree is clean
  ✅ deploy.branch_matches_config
     Branch 'main' is documented in playbook
  ⚠️  deploy.build_id_loop_detector
     BUILD_ID pattern found - may cause deployment loop

============================================================
SUMMARY: 2 passed, 0 failed, 1 warnings
============================================================
```

### Example 2: Log Blocker Incident

```bash
$ ./cli.py incident add \
  --category deployment \
  --severity high \
  --symptom "Render auto-deploy not pulling new code" \
  --root-cause "GitHub webhook broken"

✅ Incident logged: a3f9b12c
   Category: deployment
   Severity: high
   Symptom: Render auto-deploy not pulling new code
```

### Example 3: Review Recent Incidents

```bash
$ ./cli.py incidents --limit 3

============================================================
INCIDENT LOG (3 total)
============================================================

🟠 [a3f9b12c] DEPLOYMENT
   Timestamp: 2025-12-04T16:00:00.000000Z
   Symptom: Render auto-deploy not pulling new code
   Root Cause: GitHub webhook broken

🔴 [7e2d4a1f] ENVIRONMENT
   Timestamp: 2025-12-04T15:45:00.000000Z
   Symptom: pip install fails with SSL module not available
   Root Cause: Homebrew Python not linked to OpenSSL
   Resolution: brew reinstall python@3.12 openssl@3
   ✅ Prevention Added

🟡 [5b8c9e3a] DOCUMENTATION
   Timestamp: 2025-12-04T14:30:00.000000Z
   Symptom: Agent recommended Python path without SSL check
   Root Cause: No canonical local dev setup protocol
   Resolution: Added Section 4 to TEAM_PLAYBOOK.md
   ✅ Prevention Added

============================================================
```

---

## Roadmap (Future Phases)

### Phase 2: Prognostic Engine (Not Yet Implemented)

- Recurrence detection
- Clustering of similar incidents
- Likelihood forecasting
- Preventative suggestions

### Phase 3: Auto-Suggestion Generation (Not Yet Implemented)

- LLM-assisted check generation
- Documentation gap detection
- Roadmap expansion proposals

---

## Architecture

See `mosaic_diag_spec_v2.0.md` for complete specification.

**Core Modules:**

- `storage.py` - Atomic file I/O
- `preflight.py` - Check registry + execution
- `incidents.py` - Incident logging + classification
- `cli.py` - Command-line interface

**Planned Modules (v2.1):**

- `classifiers.py` - Rule-based classifiers
- `classifiers_ml.py` - LLM-assisted clustering
- `suggestions.py` - Auto-generation engine
- `roadmap.py` - Forecasting + mitigation

---

## Contributing

When adding new checks:

1. Add check function to `preflight.py`
2. Register in `PreflightEngine._register_all_checks()`
3. Document in this README
4. Test with `./cli.py preflight <category>`

When encountering blockers:

1. Log incident: `./cli.py incident add ...`
2. Update `RECURRING_BLOCKERS.md`
3. Add prevention to `TEAM_PLAYBOOK.md`
4. Consider adding preflight check

---

## License

Internal tool for Mosaic project. Not for external distribution.

---

## Questions?

See:

- `RECURRING_BLOCKERS.md` - Blocker patterns and prevention
- `TEAM_PLAYBOOK.md` - Team protocols
- `mosaic_diag_spec_v2.0.md` - Full specification
