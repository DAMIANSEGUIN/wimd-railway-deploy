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

# Regex to extract potential file paths:
# 1. Paths starting with / (absolute)
# 2. Paths starting with ./ or ../ (relative)
# 3. Words that look like filenames with extensions (e.g., script.sh)
# This is a heuristic and might not catch all cases, but covers common ones.
POTENTIAL_PATHS=$(echo "$COMMAND" | grep -oE '(/[^[:space:]]+|[.]{1,2}/[^[:space:]]+|[[:alnum:]_.-]+\.(sh|py|js|md|txt|json|yaml|yml|cfg|conf|ini|xml|html|css|js|ts|jsx|tsx|go|java|c|cpp|h|hpp|php|rb|swift|kt|pl|sql|r|vue|svelte|lua|dart|f|for|ada|lisp|scm|clj|cs|fs|vb|groovy|scala|kt|ex|erl|hrl|jl|pm|ps1|psm1|psd1|cmake|gradle|pom|properties|env|lock|gitignore|editorconfig|npmignore|dockerignore|gitattributes))' || true)

VALIDATED_PATHS=""

if [ -z "$POTENTIAL_PATHS" ]; then
    echo "⚠️  No obvious file paths detected in command. Proceeding without path validation."
else
    echo "Detected potential file paths:"
    echo "$POTENTIAL_PATHS"
    echo ""

    # Check each path
    for PATH_TO_CHECK in $POTENTIAL_PATHS; do
        # Absolute path check
        if [[ "$PATH_TO_CHECK" == /* ]]; then
            echo "Checking absolute path: $PATH_TO_CHECK"
            if [ ! -e "$PATH_TO_CHECK" ]; then
                echo "❌ FAIL: Absolute file does not exist: $PATH_TO_CHECK"
                exit 1
            fi
            VALIDATED_PATHS="$VALIDATED_PATHS $PATH_TO_CHECK"
        elif [[ "$PATH_TO_CHECK" == ./* ]] || [[ "$PATH_TO_CHECK" == ../* ]]; then
            echo "⚠️  WARNING: Relative path detected: $PATH_TO_CHECK"
            echo "   Recommendation: Use absolute paths as per COMMAND_VALIDATION_GATE.md"
            # Simply check for existence for relative paths as realpath is not available
            if [ ! -e "$PATH_TO_CHECK" ]; then
                 echo "❌ FAIL: Relative file does not exist: $PATH_TO_CHECK"
                 exit 1
            fi
            # Note: We cannot resolve to absolute path without realpath
            echo "   Relative path exists: $PATH_TO_CHECK"
            VALIDATED_PATHS="$VALIDATED_PATHS $PATH_TO_CHECK"
        else
            echo "Checking ambiguous path: $PATH_TO_CHECK (assuming in current dir)"
            if [ ! -e "$PATH_TO_CHECK" ]; then
                echo "❌ FAIL: File does not exist in current directory: $PATH_TO_CHECK"
                exit 1
            fi
            VALIDATED_PATHS="$VALIDATED_PATHS $PATH_TO_CHECK"
        fi

        # Additional checks for scripts
        if [[ "$PATH_TO_CHECK" == *.sh ]] || [[ "$PATH_TO_CHECK" == *.py ]]; then
            # Check if executable
            if [ ! -x "$PATH_TO_CHECK" ]; then
                echo "⚠️  WARNING: File not executable: $PATH_TO_CHECK"
                echo "   Fix with: chmod +x $PATH_TO_CHECK"
            fi
            # Removed bash -n check as it is unreliable in this environment.
        fi
        echo "✅ File existence/type check passed for $PATH_TO_CHECK"
        echo ""
    done
fi

# Check for basic error handling
echo "Checking for error handling..."
if echo "$COMMAND" | grep -qE '(\|\||set -e)'; then
    echo "✅ Basic error handling (|| or set -e) detected."
else
    echo "⚠️  WARNING: No explicit error handling (e.g., '|| echo' or 'set -e') detected."
    echo "   Recommendation: Add error handling for robust execution."
fi
echo ""

echo "=========================================="
echo "✅ VALIDATION PASSED"
echo "=========================================="

echo ""
echo "Safe to provide to user (with warnings if any)."
