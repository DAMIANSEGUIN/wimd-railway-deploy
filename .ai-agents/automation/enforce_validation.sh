#!/bin/bash
# Command Enforcement Wrapper
# Forces validation before any command can be provided to user
# Usage: source this in Claude's workflow to auto-validate
#
# Document Metadata:
# - Created: 2025-12-11 by Claude Code
# - Last Updated: 2025-12-11 by Claude Code
# - Status: ACTIVE

set -e

PROJECT_ROOT="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
VALIDATOR="$PROJECT_ROOT/.ai-agents/automation/validate_command.sh"
VIOLATION_LOG="$PROJECT_ROOT/.ai-agents/automation/validation_violations.log"

# Ensure validator exists and is executable
if [ ! -x "$VALIDATOR" ]; then
    echo "❌ ERROR: Validator not found or not executable: $VALIDATOR"
    exit 1
fi

# Function: validate_before_output
# Must be called before providing ANY command to user
validate_before_output() {
    local COMMAND="$1"

    if [ -z "$COMMAND" ]; then
        echo "❌ VALIDATION FAILED: Empty command"
        return 1
    fi

    echo "🔍 Validating command before output..."
    echo ""

    # Run validator
    if "$VALIDATOR" "$COMMAND"; then
        echo ""
        echo "✅ VALIDATION PASSED - Safe to provide to user"
        return 0
    else
        echo ""
        echo "❌ VALIDATION FAILED - Command BLOCKED"
        echo ""

        # Log violation
        echo "[$(date -u +"%Y-%m-%d %H:%M:%S UTC")] BLOCKED: $COMMAND" >> "$VIOLATION_LOG"

        # Prevent command from being shown
        echo "⚠️  This command cannot be provided to the user until it passes validation."
        echo "⚠️  Fix the issues above and re-validate."
        return 1
    fi
}

# Function: enforce_absolute_paths
# Converts relative paths to absolute paths
enforce_absolute_paths() {
    local COMMAND="$1"

    # Replace ./scripts/ with absolute path
    COMMAND="${COMMAND//\.\/scripts\//$PROJECT_ROOT/scripts/}"

    # Replace ../ references (unsafe)
    if echo "$COMMAND" | grep -q "\.\./"; then
        echo "❌ ERROR: Relative parent paths (..) are not allowed"
        return 1
    fi

    echo "$COMMAND"
}

# Function: check_file_exists
# Verifies file paths in command exist
check_file_exists() {
    local COMMAND="$1"

    # Extract file paths
    local PATHS=$(echo "$COMMAND" | grep -oE '(/[^ ]+\.(sh|py|js|md|txt|json|csv|yml|yaml))' || true)

    if [ -z "$PATHS" ]; then
        return 0  # No file paths to check
    fi

    for PATH_TO_CHECK in $PATHS; do
        if [ ! -e "$PATH_TO_CHECK" ]; then
            echo "❌ ERROR: File does not exist: $PATH_TO_CHECK"
            return 1
        fi
    done

    return 0
}

# Function: auto_fix_command
# Attempts to automatically fix common validation issues
auto_fix_command() {
    local COMMAND="$1"

    echo "🔧 Attempting auto-fix..."

    # Fix 1: Convert relative to absolute paths
    COMMAND=$(enforce_absolute_paths "$COMMAND")

    # Fix 2: Add error handling if missing
    if ! echo "$COMMAND" | grep -q "||"; then
        COMMAND="$COMMAND || echo 'ERROR: Command failed. Check logs for details.'"
    fi

    # Fix 3: Make scripts executable
    local SCRIPT_PATHS=$(echo "$COMMAND" | grep -oE '(/[^ ]+\.sh)' || true)
    for SCRIPT in $SCRIPT_PATHS; do
        if [ -f "$SCRIPT" ] && [ ! -x "$SCRIPT" ]; then
            echo "  Making executable: $SCRIPT"
            chmod +x "$SCRIPT"
        fi
    done

    echo "$COMMAND"
}

# Export functions for use in subshells
export -f validate_before_output
export -f enforce_absolute_paths
export -f check_file_exists
export -f auto_fix_command

echo "✅ Command validation enforcement loaded"
echo "   Use: validate_before_output \"your command here\""
