#!/bin/bash
# Validate metadata headers exist in all governance files
# Usage: ./scripts/validate_metadata.sh

set -e

# Tier-1 Governance Files (MANDATORY)
TIER1_FILES=(
    "Mosaic_Governance_Core_v1.md"
    "TEAM_PLAYBOOK_v2.md"
    "UPDATED_SESSION_START_MACRO_v1.1.2.md"
    "SESSION_END_OPTIONS.md"
    "API_MODE_GOVERNANCE_PROTOCOL.md"
)

# Tier-2 Deployment Files (MANDATORY)
TIER2_FILES=(
    "DEPLOYMENT_TRUTH.md"
    "CLAUDE.md"
    "README.md"
    "TROUBLESHOOTING_CHECKLIST.md"
    "SELF_DIAGNOSTIC_FRAMEWORK.md"
)

ALL_FILES=("${TIER1_FILES[@]}" "${TIER2_FILES[@]}")

FAILED=0

echo "🔍 Validating metadata headers in ${#ALL_FILES[@]} files..."
echo ""

for file in "${ALL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ $file - FILE NOT FOUND"
        FAILED=1
        continue
    fi

    # Check for metadata header (simple string match)
    if ! grep -F "Document Metadata:" "$file" >/dev/null 2>&1; then
        echo "❌ $file - MISSING METADATA HEADER"
        FAILED=1
        continue
    fi

    # Check for required fields (simple substring check)
    MISSING_FIELDS=""
    if ! grep -F "Created:" "$file" >/dev/null 2>&1; then
        MISSING_FIELDS="${MISSING_FIELDS}Created,"
    fi
    if ! grep -F "Last Updated:" "$file" >/dev/null 2>&1; then
        MISSING_FIELDS="${MISSING_FIELDS}Last-Updated,"
    fi
    if ! grep -F "Last Deployment Tag:" "$file" >/dev/null 2>&1; then
        MISSING_FIELDS="${MISSING_FIELDS}Last-Deployment-Tag,"
    fi
    if ! grep -F "Status:" "$file" >/dev/null 2>&1; then
        MISSING_FIELDS="${MISSING_FIELDS}Status"
    fi

    if [ -n "$MISSING_FIELDS" ]; then
        echo "❌ $file - MISSING FIELDS: $MISSING_FIELDS"
        FAILED=1
    else
        echo "✅ $file"
    fi
done

echo ""
if [ $FAILED -eq 1 ]; then
    echo "❌ Validation FAILED - Fix metadata issues above"
    exit 1
else
    echo "✅ All files have valid metadata headers"
    exit 0
fi
