#!/bin/bash
# Command Validator - Tests commands before showing to user
# Usage: ./validate_command.sh "command to test"

set -e

COMMAND="$1"

if [ -z "$COMMAND" ]; then
    echo "Usage: ./validate_command.sh \"command to test\""
    exit 1
fi

echo "=========================================="
echo "COMMAND VALIDATION"
echo "=========================================="
echo ""
echo "Testing: $COMMAND"
echo ""

# Extract file paths from command
PATHS=$(echo "$COMMAND" | grep -oE '(/[^ ]+\.(sh|py|js|md))' || true)

if [ -z "$PATHS" ]; then
    echo "⚠️  No file paths detected in command"
else
    echo "Detected file paths:"
    echo "$PATHS"
    echo ""

    # Check each path
    for PATH_TO_CHECK in $PATHS; do
        echo "Checking: $PATH_TO_CHECK"

        # Check if file exists
        if [ ! -e "$PATH_TO_CHECK" ]; then
            echo "❌ FAIL: File does not exist"
            exit 1
        fi

        # Check if it's a script
        if [[ "$PATH_TO_CHECK" == *.sh ]] || [[ "$PATH_TO_CHECK" == *.py ]]; then
            # Check if executable
            if [ ! -x "$PATH_TO_CHECK" ]; then
                echo "⚠️  WARNING: File not executable"
                echo "   Fix with: chmod +x $PATH_TO_CHECK"
            fi

            # Check bash syntax if .sh file
            if [[ "$PATH_TO_CHECK" == *.sh ]]; then
                if bash -n "$PATH_TO_CHECK" 2>/dev/null; then
                    echo "✅ Bash syntax valid"
                else
                    echo "❌ FAIL: Bash syntax error"
                    bash -n "$PATH_TO_CHECK"
                    exit 1
                fi
            fi
        fi

        echo "✅ File exists"
        echo ""
    done
fi

# Try to execute the command in dry-run mode if possible
echo "Attempting dry-run test..."
echo ""

# For safety, don't actually execute - just validate syntax
if bash -n <(echo "$COMMAND") 2>/dev/null; then
    echo "✅ Command syntax valid"
else
    echo "❌ FAIL: Command syntax error"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ VALIDATION PASSED"
echo "=========================================="
echo ""
echo "Safe to provide to user."
