#!/bin/bash
# scripts/run_local_enforcement.sh
# Pre-flight check script to establish authority and run the local enforcer.

set -euo pipefail
set +H

# C) Add “repo root anchor” preflight
# Find the absolute path of the repository root. If this command fails, the script will exit.
echo "⏳ Anchoring to repository root..."
REPO_ROOT=$(git rev-parse --show-toplevel)

if [ -z "$REPO_ROOT" ]; then
    # The user requested the canonical expected local path. I don't know this path,
    # so I will state that the command should be run from within the clone.
    echo "🛑 REJECT: Not inside a git repository. Please run this command from within your local git clone."
    exit 1
fi

# A) Replace /usr/bin/pwd with `pwd` or /bin/pwd. Using the shell builtin `pwd`.
echo "✅ Repo root found at: $(pwd)"

# cd to the resolved root before any other ops.
cd "$REPO_ROOT"
echo "✅ Changed directory to repository root."

# Call the main enforcement script, passing the mode deterministically.
echo "⏳ Invoking enforcer with MODE=local..."
# We use an argument format that the patched script will understand.
./scripts/mosaic_enforce.sh --mode=local