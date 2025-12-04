#!/bin/bash
# Session End Script - Updates TEAM_PLAYBOOK.md and creates backup
# Author: Claude Code
# Created: 2025-12-03
# Purpose: Triggered when user says "ending session" - backs up state and updates playbook
# Status: Active

set -euo pipefail

PLAYBOOK="TEAM_PLAYBOOK.md"
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
BACKUP_DIR="session_backups/${TIMESTAMP}"

echo "========================================"
echo "SESSION END - Backup & Update"
echo "========================================"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup critical files
echo "📦 Backing up critical files..."
cp feature_flags.json "$BACKUP_DIR/" 2>/dev/null || echo "  ⚠️  feature_flags.json not found"
cp railway.json "$BACKUP_DIR/" 2>/dev/null || echo "  ⚠️  railway.json not found"
cp api/index.py "$BACKUP_DIR/index.py" 2>/dev/null || echo "  ⚠️  api/index.py not found"
cp api/storage.py "$BACKUP_DIR/storage.py" 2>/dev/null || echo "  ⚠️  api/storage.py not found"
cp api/ps101.py "$BACKUP_DIR/ps101.py" 2>/dev/null || echo "  ⚠️  api/ps101.py not found"
cp api/settings.py "$BACKUP_DIR/settings.py" 2>/dev/null || echo "  ⚠️  api/settings.py not found"

echo "  ✅ Backup created: $BACKUP_DIR"
echo ""

# Get session summary from user
echo "📝 Session Summary (required for playbook update)"
echo ""
echo "What was accomplished this session?"
read -r ACCOMPLISHED

echo ""
echo "What should the next session do?"
read -r NEXT_TASK

echo ""
echo "Any NEW blocking issues discovered? (type 'None' if none)"
read -r NEW_BLOCKERS

echo ""
echo "Your AI name (e.g., Claude Code, Gemini, GPT-4):"
read -r AI_NAME

echo ""
echo "📝 Updating $PLAYBOOK Section 2..."

# Update TEAM_PLAYBOOK.md using Python
python3 << PYTHON_SCRIPT
import re
from datetime import datetime

playbook_path = "$PLAYBOOK"

# Read file
with open(playbook_path, 'r') as f:
    content = f.read()

# Extract current blocking issues count
blocking_match = re.search(r'\*\*BLOCKING ISSUES.*?\n(.*?)\n\n', content, re.DOTALL)
current_blockers = blocking_match.group(1) if blocking_match else ""

# Prepare new blockers section
if "$NEW_BLOCKERS" != "None" and "$NEW_BLOCKERS".strip():
    new_blocker_line = "\n5. **[NEW]** $NEW_BLOCKERS (Discovered: $TIMESTAMP)"
else:
    new_blocker_line = ""

# Create updated section content (without header)
new_content = f"""**Last Updated**: $TIMESTAMP
**Updated By**: $AI_NAME
**Current Code Version**: See \`api/index.py\` lines 1-18 for authoritative version info

**CODE STATE (Source of Truth)**:
- **Check**: \`api/index.py\` header (lines 1-18)
  - Git commit: $GIT_COMMIT
  - Branch: $GIT_BRANCH
  - Backup: session_backups/$TIMESTAMP/

**BLOCKING ISSUES (CRITICAL - Address First)**:
{current_blockers}{new_blocker_line}

**LAST SESSION ACCOMPLISHED**:
- $ACCOMPLISHED

**NEXT TASK (After Blockers Resolved)**:
- $NEXT_TASK

"""

# Replace content between "### What's Happening Right Now" and next "###"
pattern = r"(### What's Happening Right Now\n\n).*?(\n### )"
replacement = r"\1" + new_content + r"\2"
updated = re.sub(pattern, replacement, content, flags=re.DOTALL)

# Write back
with open(playbook_path, 'w') as f:
    f.write(updated)

print("  ✅ TEAM_PLAYBOOK.md Section 2 updated")
PYTHON_SCRIPT

echo ""
echo "========================================"
echo "✅ SESSION END COMPLETE"
echo "========================================"
echo ""
echo "Backup Location: $BACKUP_DIR"
echo "Playbook Updated: $PLAYBOOK Section 2"
echo "Git State: $GIT_COMMIT on $GIT_BRANCH"
echo ""
echo "Next session start command:"
echo "  Read SESSION_START.md"
echo ""
