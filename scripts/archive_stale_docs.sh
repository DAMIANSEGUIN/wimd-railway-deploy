#!/bin/bash
# Archive all session docs older than 2025-12-01
# Part of Phase 4: Documentation Consolidation

ARCHIVE_DIR="docs_archive/sessions_2025"
CUTOFF_DATE="2025-12-01"

echo "Creating archive directory..."
mkdir -p "$ARCHIVE_DIR"

echo "Finding session docs to archive..."
ARCHIVED_COUNT=0

# Archive SESSION*.md files older than cutoff
for file in SESSION*.md; do
  if [ -f "$file" ]; then
    # Get file modification date (macOS compatible)
    FILE_DATE=$(stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1)

    if [[ "$FILE_DATE" < "$CUTOFF_DATE" ]]; then
      echo "Archiving: $file (modified $FILE_DATE)"
      mv "$file" "$ARCHIVE_DIR/"
      ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
    fi
  fi
done

echo ""
echo "✅ Archive complete!"
echo "   Archived: $ARCHIVED_COUNT files"
echo "   Location: $ARCHIVE_DIR"
echo ""
echo "Active session docs remaining:"
ls -1 SESSION*.md 2>/dev/null | wc -l

# Create archive README
cat > "$ARCHIVE_DIR/README.md" <<EOF
# Archived Session Documents

**Archived:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Reason:** Documentation consolidation (moved to .mosaic/*.json state system)
**Cutoff Date:** Files older than $CUTOFF_DATE

## New System

Session state now lives in:
- \`.mosaic/current_task.json\` - Current objective
- \`.mosaic/blockers.json\` - Known blockers
- \`.mosaic/agent_state.json\` - Agent handoff state
- \`.mosaic/session_log.jsonl\` - Session history

These files use relative paths and work across all environments.

## Archive Contents

This directory contains $ARCHIVED_COUNT historical session documents from 2025.
They are preserved for reference but superseded by the new state system.
EOF

echo "Created archive README"
