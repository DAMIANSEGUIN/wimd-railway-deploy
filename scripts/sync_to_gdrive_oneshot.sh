#!/usr/bin/env zsh
# One-shot sync: Local Mosaic → GDrive canonical folder
# Purpose: Create single source of truth in GDrive for ChatGPT access
# Author: Claude Code
# Date: 2025-12-05

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

LOCAL_ROOT="/Users/damianseguin/WIMD-Deploy-Project"
GDRIVE_REMOTE="gdrive:WIMD-Deploy-Project"
RCLONE_BIN="/Users/damianseguin/coachvox_tools/bin/rclone"

# ============================================================================
# PREFLIGHT CHECKS
# ============================================================================

echo "=== Mosaic → GDrive One-Shot Sync ==="
echo ""

# Check 1: rclone exists
if [[ ! -f "$RCLONE_BIN" ]]; then
    echo "❌ ERROR: rclone not found at $RCLONE_BIN"
    exit 1
fi
echo "✅ rclone found"

# Check 2: Local directory exists
if [[ ! -d "$LOCAL_ROOT" ]]; then
    echo "❌ ERROR: Local directory not found: $LOCAL_ROOT"
    exit 1
fi
echo "✅ Local directory exists"

# Check 3: gdrive remote configured
if ! "$RCLONE_BIN" listremotes | grep -q "^gdrive:$"; then
    echo "❌ ERROR: rclone remote 'gdrive:' not configured"
    echo "Run: rclone config"
    exit 1
fi
echo "✅ gdrive remote configured"

# Check 4: Can reach GDrive
if ! "$RCLONE_BIN" lsd gdrive: --max-depth 1 >/dev/null 2>&1; then
    echo "❌ ERROR: Cannot connect to Google Drive"
    echo "Check authentication: rclone config reconnect gdrive:"
    exit 1
fi
echo "✅ Can connect to GDrive"

echo ""
echo "=== Preflight checks passed ==="
echo ""

# ============================================================================
# SYNC EXECUTION
# ============================================================================

echo "Source:      $LOCAL_ROOT"
echo "Destination: $GDRIVE_REMOTE"
echo ""
echo "This will:"
echo "  - Copy all files from local to GDrive"
echo "  - Preserve directory structure"
echo "  - Skip unchanged files (fast)"
echo "  - NOT delete files in GDrive (safe)"
echo ""

# Dry run first
echo "=== DRY RUN (showing what will be synced) ==="
"$RCLONE_BIN" sync "$LOCAL_ROOT" "$GDRIVE_REMOTE" \
    --exclude .git/** \
    --exclude .pytest_cache/** \
    --exclude __pycache__/** \
    --exclude node_modules/** \
    --exclude .venv/** \
    --exclude .test-venv/** \
    --exclude "*.pyc" \
    --exclude .DS_Store \
    --dry-run \
    --progress

echo ""
echo "=== DRY RUN COMPLETE ==="
echo ""
echo "Ready to execute actual sync?"
echo "Press ENTER to continue, or Ctrl+C to cancel..."
read

# Actual sync
echo ""
echo "=== EXECUTING SYNC ==="
"$RCLONE_BIN" sync "$LOCAL_ROOT" "$GDRIVE_REMOTE" \
    --exclude .git/** \
    --exclude .pytest_cache/** \
    --exclude __pycache__/** \
    --exclude node_modules/** \
    --exclude .venv/** \
    --exclude .test-venv/** \
    --exclude "*.pyc" \
    --exclude .DS_Store \
    --progress \
    --verbose

echo ""
echo "=== SYNC COMPLETE ==="
echo ""

# ============================================================================
# VERIFICATION
# ============================================================================

echo "=== VERIFICATION ==="
echo ""

# Count files in GDrive
GDRIVE_FILE_COUNT=$("$RCLONE_BIN" size "$GDRIVE_REMOTE" --json | grep -o '"count":[0-9]*' | cut -d: -f2)
echo "Files in GDrive: $GDRIVE_FILE_COUNT"

# Check key Tier 1 files
echo ""
echo "Checking Tier 1 files:"
TIER1_FILES=(
    "TEAM_PLAYBOOK.md"
    "SESSION_START.md"
    "TROUBLESHOOTING_CHECKLIST.md"
    "SELF_DIAGNOSTIC_FRAMEWORK.md"
    "RECURRING_BLOCKERS.md"
    "CLAUDE.md"
    "DEPLOYMENT_TRUTH.md"
    "TECH_DEBT_TRACKING.md"
)

MISSING_COUNT=0
for file in "${TIER1_FILES[@]}"; do
    if "$RCLONE_BIN" ls "$GDRIVE_REMOTE" --max-depth 1 | grep -q "$file"; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (MISSING)"
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

echo ""
if [[ $MISSING_COUNT -eq 0 ]]; then
    echo "✅ All Tier 1 files verified in GDrive"
else
    echo "⚠️  WARNING: $MISSING_COUNT Tier 1 files missing"
fi

# ============================================================================
# SHAREABLE LINKS
# ============================================================================

echo ""
echo "=== GENERATING SHAREABLE LINKS ==="
echo ""
echo "Key files for ChatGPT:"
echo ""

for file in "${TIER1_FILES[@]}"; do
    LINK=$("$RCLONE_BIN" link "$GDRIVE_REMOTE/$file" 2>/dev/null || echo "ERROR")
    echo "- $file"
    echo "  $LINK"
    echo ""
done

echo "=== SYNC SUMMARY ==="
echo ""
echo "✅ Local → GDrive sync complete"
echo "✅ GDrive folder: WIMD-Deploy-Project"
echo "✅ Total files synced: $GDRIVE_FILE_COUNT"
echo "✅ Tier 1 files: $((8 - MISSING_COUNT))/8 verified"
echo ""
echo "Next steps:"
echo "1. Share GDrive folder 'WIMD-Deploy-Project' with ChatGPT"
echo "2. Tell ChatGPT to read: MOSAIC_GDRIVE_AUDIT_FOR_CHATGPT_2025-12-05.md"
echo "3. ChatGPT can now access all project files"
echo ""
echo "=== END OF SYNC ==="
