#!/bin/bash
# WIMD-Railway-Deploy-Project Deprecation Deletion Verifier
# Exit 0 = all deprecated artifacts removed
# Exit 1 = deprecated artifacts still present

DEPRECATED_PATHS=(
  "/Users/damianseguin/Downloads/AI_Workspace/WIMD-Railway-Deploy-Project"
  "/Users/damianseguin/Backups/WIMD-Railway-Deploy-Project_2025-11-11"
  "/Users/damianseguin/Backups/WIMD-Railway-Deploy-Project_2025-11-12_ps101_nav"
  "/Users/damianseguin/Backups/WIMD-Railway-Deploy-Project_2025-11-12_113700"
  "/Users/damianseguin/Backups/WIMD-Railway-Deploy-Project_2025-11-12_chat_session"
  "/Users/damianseguin/.cursor/projects/Users-damianseguin-AI-Workspace-WIMD-Railway-Deploy-Project"
  "/Users/damianseguin/.claude/projects/-Users-damianseguin-AI-Workspace-WIMD-Railway-Deploy-Project"
  "/Users/damianseguin/.claude_backup_20260127/projects/-Users-damianseguin-AI-Workspace-WIMD-Railway-Deploy-Project"
)

FOUND_COUNT=0

echo "🔍 VERIFYING WIMD-Railway-Deploy-Project DELETION"
echo "=================================================="

for path in "${DEPRECATED_PATHS[@]}"; do
  if [ -e "$path" ]; then
    echo "❌ STILL EXISTS: $path"
    FOUND_COUNT=$((FOUND_COUNT + 1))
  else
    echo "✅ DELETED: $path"
  fi
done

echo ""
echo "=================================================="

if [ $FOUND_COUNT -eq 0 ]; then
  echo "✅ VERIFICATION PASSED"
  echo "All deprecated WIMD-Railway-Deploy-Project artifacts removed"
  exit 0
else
  echo "❌ VERIFICATION FAILED"
  echo "Found $FOUND_COUNT deprecated artifacts still present"
  exit 1
fi
