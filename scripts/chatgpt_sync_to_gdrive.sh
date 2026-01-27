#!/bin/bash
set -euo pipefail

export ZSH_DISABLE_COMPFIX=true

LOCAL_ROOT="$HOME/AI_Workspace/WIMD-Deploy-Project"
REMOTE_ROOT="gdrive:WIMD-Deploy-Project"

if ! command -v rclone >/dev/null 2>&1; then
  echo "ERROR: rclone is not installed or not on PATH."
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

rclone sync "$LOCAL_ROOT" "$REMOTE_ROOT" \
  --verbose \
  --copy-links \
  --checksum \
  --exclude "node_modules/**" \
  --exclude ".git/**"

echo
echo "Sync complete. All Mosaic files should now be present in:"
echo "  $REMOTE_ROOT"
