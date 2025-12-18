#!/bin/bash
# Validate metadata headers exist in all governance files
# Usage: ./scripts/validate_metadata.sh
#
# AUTO-DISCOVERY MODE: Scans for governance files by pattern rather than hardcoded names
# This prevents breakage when files are renamed or versioned

set -e

# Governance file patterns (auto-discover by pattern matching)
TIER1_PATTERNS=(
    "Mosaic_Governance_Core*.md"
    "TEAM_PLAYBOOK*.md"
    "*SESSION*START*.md"  # Matches any session start file regardless of version
    "SESSION_END*.md"
    "API_MODE_GOVERNANCE*.md"
)

TIER2_PATTERNS=(
    "DEPLOYMENT_TRUTH.md"
    "CLAUDE.md"
    "README.md"
    "TROUBLESHOOTING_CHECKLIST.md"
    "SELF_DIAGNOSTIC_FRAMEWORK.md"
)

ALL_PATTERNS=("${TIER1_PATTERNS[@]}" "${TIER2_PATTERNS[@]}")

FAILED=0
FILES_CHECKED=0

echo "🔍 Auto-discovering governance files..."
echo ""

# Find all matching files
FOUND_FILES=()
for pattern in "${ALL_PATTERNS[@]}"; do
    # Use find to locate files matching pattern
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            FOUND_FILES+=("$file")
        fi
    done < <(find . -maxdepth 1 -name "$pattern" -type f 2>/dev/null)
done

# Remove duplicates and sort
UNIQUE_FILES=($(printf '%s\n' "${FOUND_FILES[@]}" | sort -u))

echo "Found ${#UNIQUE_FILES[@]} governance files"
echo ""

if [ ${#UNIQUE_FILES[@]} -eq 0 ]; then
    echo "❌ No governance files found - check patterns"
    exit 1
fi

# Validate each discovered file
for file in "${UNIQUE_FILES[@]}"; do
    FILES_CHECKED=$((FILES_CHECKED + 1))

    # Remove ./ prefix for display
    display_name="${file#./}"

    # Check for metadata header
    if ! grep -F "Document Metadata:" "$file" >/dev/null 2>&1; then
        echo "❌ $display_name - MISSING METADATA HEADER"
        FAILED=1
        continue
    fi

    # Check for required fields
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
        echo "❌ $display_name - MISSING FIELDS: $MISSING_FIELDS"
        FAILED=1
    else
        echo "✅ $display_name"
    fi
done

echo ""
echo "Validated $FILES_CHECKED files"
echo ""

if [ $FAILED -eq 1 ]; then
    echo "❌ Validation FAILED - Fix metadata issues above"
    exit 1
else
    echo "✅ All governance files have valid metadata headers"
    exit 0
fi
