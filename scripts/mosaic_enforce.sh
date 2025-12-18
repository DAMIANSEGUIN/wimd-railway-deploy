#!/bin/bash
# scripts/mosaic_enforce.sh - Mosaic Enforcer with REPO_REMOTE_MATCH gate

set -euo pipefail

MODE=""
TARGET_SERVICE=""
REPO_ROOT="$(git rev-parse --show-toplevel)"
AUTHORITY_MAP_PATH="$REPO_ROOT/.mosaic/authority_map.json"

for arg in "$@"; do
  case $arg in
    --mode=*)
      MODE="${arg#*=}"
      shift
      ;;
    --target=*)
      TARGET_SERVICE="${arg#*=}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

echo "--- Mosaic Enforcement Report ---"
echo "Mode: ${MODE:-N/A}"
echo "Target Service: ${TARGET_SERVICE:-N/A}"

if [ "$MODE" == "local" ]; then
    echo "Running local enforcement gates..."

    # Gate: REPO_REMOTE_MATCH
    echo "Checking gate: REPO_REMOTE_MATCH..."
    if [ ! -f "$AUTHORITY_MAP_PATH" ]; then
        echo "REJECT: Authority map not found at $AUTHORITY_MAP_PATH"
        exit 1
    fi

    # Using grep and sed for simple, dependency-free JSON parsing
    EXPECTED_REMOTE=$(grep -o '"origin_ssh": *"[^"]*"' "$AUTHORITY_MAP_PATH" | sed -e 's/"origin_ssh": *//' -e 's/"//g')
    CURRENT_REMOTE=$(git remote get-url origin)

    if [ "$EXPECTED_REMOTE" == "$CURRENT_REMOTE" ]; then
        echo "PASS: REPO_REMOTE_MATCH"
        # In a real script, other checks would follow
    else
        echo "REJECT: REPO_REMOTE_MATCH"
        echo "  Expected remote: $EXPECTED_REMOTE"
        echo "  Current remote:  $CURRENT_REMOTE"
        exit 1
    fi

    echo "Status: DONE"
    echo "Gates checked: 1"
    echo "Passed: 1"
    exit 0

else
    echo "Status: NO-OP (Enforcer logic for mode '$MODE' not yet implemented)"
    echo "Gates checked: (none)"
    echo "Passed: (none)"
    exit 0
fi
