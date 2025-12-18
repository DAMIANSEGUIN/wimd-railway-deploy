#!/bin/bash
# validate_curl_command.sh

# This script validates if a given command string is a valid curl command.
# For now, it's a simple check to see if the command starts with "curl".

COMMAND_STRING="$1"

if [[ -z "$COMMAND_STRING" ]]; then
    echo "Error: No command string provided."
    exit 1
fi

if [[ "$COMMAND_STRING" == curl* ]]; then
    echo "Validation successful: Command is a curl command."
    exit 0
else
    echo "Validation failed: Command is not a curl command."
    exit 1
fi
