#!/bin/bash
set -euo pipefail

export ZSH_DISABLE_COMPFIX=true

LOCAL_ROOT="$HOME/WIMD-Deploy-Project"
REMOTE_ROOT="gdrive:WIMD-Deploy-Project"

RCLONE_BIN="/Users/damianseguin/coachvox_tools/bin/rclone"

if [ ! -f "$RCLONE_BIN" ]; then
  echo "ERROR: rclone not found at $RCLONE_BIN"
  exit 1
fi

if [ ! -d "$LOCAL_ROOT" ]; then
  echo "ERROR: Local Mosaic root not found at: $LOCAL_ROOT"
  exit 1
fi

echo "Syncing local Mosaic tree to Google Drive..."
echo "  From: $LOCAL_ROOT"
echo "  To:   $REMOTE_ROOT"
echo

"$RCLONE_BIN" sync "$LOCAL_ROOT" "$REMOTE_ROOT" \
  --verbose \
  --copy-links \
  --checksum \
  --exclude "node_modules/**" \
  --exclude ".git/**" \
  --exclude ".venv/**" \
  --exclude "__pycache__/**" \
  --exclude "*.pyc"

echo
echo "Sync complete. All Mosaic files should now be present in:"
echo "  $REMOTE_ROOT"
