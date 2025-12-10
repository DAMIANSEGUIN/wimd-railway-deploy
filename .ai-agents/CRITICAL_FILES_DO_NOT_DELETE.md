# Critical Files Protection List
**DO NOT DELETE OR OVERWRITE WITHOUT BACKUP**

**Last Updated:** 2025-12-09 by Claude Code

---

## Mission-Critical Files (NEVER DELETE)

These files contain essential governance, architecture, and deployment knowledge. Loss would break agent functionality.

### Primary Governance
- `CLAUDE.md` - **CRITICAL** - Primary architecture, deployment commands, current status
- `TROUBLESHOOTING_CHECKLIST.md` - **CRITICAL** - Error prevention, debugging workflows
- `SELF_DIAGNOSTIC_FRAMEWORK.md` - **CRITICAL** - Architecture-specific error handling

### Deployment & Operations
- `DEPLOYMENT_TRUTH.md` - **CRITICAL** - Authoritative deployment procedures
- `scripts/start_session.sh` - **CRITICAL** - Session initialization (backup before modifying)
- `scripts/deploy.sh` - **CRITICAL** - Deployment wrapper with verification
- `scripts/push.sh` - **CRITICAL** - Push wrapper with verification
- `scripts/verify_critical_features.sh` - **CRITICAL** - Post-deployment validation

### Documentation
- `docs/README.md` - Project documentation and restart protocol
- `docs/mosaic_mcp_v1_1/` - **ENTIRE DIRECTORY** - MCP architecture specs
- `docs/MCP_V1_1_MASTER_CHECKLIST.md` - Implementation plan and progress

---

## Protected Directories (ADDITIVE ONLY - NO DELETIONS)

### Documentation Directory
- `docs/` - **Additive only** - Can add files, never delete existing

### Agent State
- `.ai-agents/baseline/` - **Preserve** - Baseline measurements for comparison
- `.ai-agents/backups/` - **Preserve** - Critical file backups

### Configuration
- `.ai-agents/config/` - **Preserve** - Feature flags and configuration

---

## Modification Rules

### Rule 1: Backup Before Modify
If modifying any critical file:
1. Create timestamped backup in `.ai-agents/backups/`
2. Verify backup is readable
3. Then make changes
4. Commit both old and new versions to git

**Example:**
```bash
# Before modifying scripts/start_session.sh
cp scripts/start_session.sh .ai-agents/backups/start_session.sh.$(date +%Y%m%d_%H%M%S)
# Then make changes
```

### Rule 2: Test Before Replace
If creating new version of critical script:
1. Create as NEW file (e.g., `start_session_mcp.sh`)
2. Test thoroughly with feature flag
3. Only after validation, replace original
4. Keep `.old` version in git

### Rule 3: Never Delete Docs
- Documentation is always additive
- Outdated docs should be marked as `[SUPERSEDED]` not deleted
- Keep history for reference

### Rule 4: Preserve Provenance
- When summarizing/compressing docs, include provenance metadata
- Always link back to original source (file, commit, lines)
- Never orphan information (always traceable to source)

---

## MCP-Specific Protection Rules

### Files MCP May Create (Safe to Modify)
- `.ai-agents/session_context/` - Generated summaries and context
- `.ai-agents/sessions/` - Session logs (append-only)
- `docs/mcp_exports/` - Exported summaries for mirror agent

### Files MCP Must NOT Touch
- Original governance docs (CLAUDE.md, TROUBLESHOOTING_CHECKLIST.md, etc.)
- Deployment scripts (unless explicitly backing up first)
- Any file in `docs/` that existed before MCP

### Rollback Protection
- Git tag `pre-mcp-v1.1-baseline` created for instant rollback
- Rollback script: `scripts/rollback_mcp.sh`
- Feature flags can disable MCP without code changes

---

## Emergency Recovery

### If Critical File Accidentally Deleted:

**Option 1: Git History**
```bash
# Find when file was deleted
git log --all --full-history -- path/to/file

# Restore from commit before deletion
git checkout <commit-hash>^ -- path/to/file
```

**Option 2: Backup Directory**
```bash
# Check backups
ls -lt .ai-agents/backups/

# Restore latest backup
cp .ai-agents/backups/FILENAME.TIMESTAMP path/to/original
```

**Option 3: Git Tag Rollback**
```bash
# Nuclear option - revert entire repo to baseline
git checkout pre-mcp-v1.1-baseline
```

---

## Pre-Commit Hook (Recommended)

Add to `.git/hooks/pre-commit` to prevent accidental deletion:

```bash
#!/bin/bash

# Check for deletion of critical files
CRITICAL_FILES=(
  "CLAUDE.md"
  "TROUBLESHOOTING_CHECKLIST.md"
  "SELF_DIAGNOSTIC_FRAMEWORK.md"
  "DEPLOYMENT_TRUTH.md"
  "scripts/start_session.sh"
  "scripts/deploy.sh"
)

for file in "${CRITICAL_FILES[@]}"; do
  if git diff --cached --name-status | grep -q "^D.*$file"; then
    echo "ERROR: Attempting to delete critical file: $file"
    echo "This file is protected. See .ai-agents/CRITICAL_FILES_DO_NOT_DELETE.md"
    exit 1
  fi
done
```

---

## Validation Checklist

Before any deployment, verify:
- [ ] All critical files still exist
- [ ] No critical files in `git status -s` as deleted
- [ ] Backups created for any modified critical files
- [ ] Feature flags allow rollback
- [ ] Git tag `pre-mcp-v1.1-baseline` still exists

---

**Remember: Information is easier to create than to recreate from memory.**
**When in doubt, back it up first.**
