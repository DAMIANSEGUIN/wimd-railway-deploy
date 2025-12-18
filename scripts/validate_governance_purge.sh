#!/bin/bash
# validate_governance_purge.sh
# Validates that the core governance documents have been purged of "RECOMMENDED" and user enforcement language.

set -e

# List of files to check
FILES_TO_CHECK=(
    "TEAM_PLAYBOOK_v2.md"
    "Mosaic_Governance_Core_v1.md"
)

# List of forbidden words and phrases
FORBIDDEN_PATTERNS=(
    "RECOMMENDED"
    "user must"
    "user should"
    "user's protocol is to"
    "user should query"
    "user must intervene"
    "user must challenge"
    "user should enforce"
    "User enforcement is critical"
)

# Flag to track overall success
OVERALL_SUCCESS=true

# --- Main ---
echo "================================================="
echo "Running Governance Purge Validation..."
echo "================================================="
echo

for file in "${FILES_TO_CHECK[@]}"; do
    echo "--- Checking file: $file ---"

    if [ ! -f "$file" ]; then
        echo "❌ FAIL: File not found: $file"
        OVERALL_SUCCESS=false
        continue
    fi

    FILE_HAS_FORBIDDEN_PATTERN=false
    for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
        # Use grep -i for case-insensitive search and -q for quiet mode
        if grep -iq "$pattern" "$file"; then
            echo "❌ FAIL: Found forbidden pattern '$pattern' in $file"
            grep -in "$pattern" "$file" # Show the line number and the line
            FILE_HAS_FORBIDDEN_PATTERN=true
            OVERALL_SUCCESS=false
        fi
    done

    if [ "$FILE_HAS_FORBIDDEN_PATTERN" = false ]; then
        echo "✅ PASS: No forbidden patterns found in $file"
    fi
    echo
done

echo "================================================="
if [ "$OVERALL_SUCCESS" = true ]; then
    echo "✅ VALIDATION PASSED: All governance files are clean."
    exit 0
else
    echo "❌ VALIDATION FAILED: Forbidden patterns found in governance files."
    exit 1
fi
