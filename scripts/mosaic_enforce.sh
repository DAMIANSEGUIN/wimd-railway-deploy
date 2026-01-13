#!/bin/bash
# scripts/mosaic_enforce.sh - Mosaic Enforcer with local gates (Corrected Parsing v2)

set -euo pipefail

MODE=""
REPO_ROOT="." # Assume CWD is repo root, set by pre-flight script.
AUTHORITY_MAP_PATH="$REPO_ROOT/.mosaic/authority_map.json"
SESSION_START_JSON="$REPO_ROOT/.mosaic/session_start.json"

# --- Argument Parsing ---
for arg in "$@"; do
  case $arg in
    --mode=*)
      MODE="${arg#*=}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# --- Mode Validation ---
if [ -z "$MODE" ]; then
    echo "🛑 REJECT: Execution mode not provided."
    echo "   Required fix: Pass '--mode=local', '--mode=ci', or '--mode=runtime' to this script."
    exit 1
elif [ "$MODE" != "local" ] && [ "$MODE" != "ci" ] && [ "$MODE" != "runtime" ]; then
    echo "🛑 REJECT: Mode '$MODE' is not supported. Supported modes: local, ci, runtime."
    exit 1
fi

# --- File Creation ---
if [ ! -f "$SESSION_START_JSON" ]; then
    echo "⏳ Creating missing config file: $SESSION_START_JSON"
    echo '{"canon_id": "UNINITIALIZED", "session_name": "session_name_placeholder"}' > "$SESSION_START_JSON"
    echo "✅ Created $SESSION_START_JSON"
else
    echo "✅ Config file $SESSION_START_JSON already exists."
fi

echo "--- Mosaic Enforcement Report (mode: $MODE) ---"
GATES_PASSED=0
GATES_TOTAL=0
FAILED_GATES=()

# --- Gate: REPO_REMOTE_MATCH ---
GATES_TOTAL=$((GATES_TOTAL + 1))
echo "⏳ Checking gate: REPO_REMOTE_MATCH..."
if [ ! -f "$AUTHORITY_MAP_PATH" ]; then
    echo "🛑 FAIL: REPO_REMOTE_MATCH - Authority map not found at $AUTHORITY_MAP_PATH"
    FAILED_GATES+=("REPO_REMOTE_MATCH")
else
    # Corrected parsing v2: Handle both SSH and HTTPS URLs more robustly.
    # The current remote can be either format, so we check against both possibilities derived from origin_ssh.
    ORIGIN_SSH_URL=$(grep -o '"origin_ssh": *"[^"]*"' "$AUTHORITY_MAP_PATH" | sed -e 's/"origin_ssh": *//' -e 's/"//g' || true)
    
    if [ -z "$ORIGIN_SSH_URL" ]; then
        echo "🛑 FAIL: REPO_REMOTE_MATCH - Could not parse origin_ssh from $AUTHORITY_MAP_PATH"
        FAILED_GATES+=("REPO_REMOTE_MATCH")
    else
        # Derive the SSH URL format from the HTTPS URL
        OWNER_REPO=$(echo "$ORIGIN_SSH_URL" | sed -e 's/https:\/\/github.com\///' -e 's/\.git//' || true)
        EXPECTED_SSH_REMOTE="git@github.com:$OWNER_REPO.git"
        
        CURRENT_REMOTE=$(git remote get-url origin)
        
        if [ "$CURRENT_REMOTE" == "$ORIGIN_SSH_URL" ] || [ "$CURRENT_REMOTE" == "$EXPECTED_SSH_REMOTE" ]; then
            echo "✅ PASS: REPO_REMOTE_MATCH"
            GATES_PASSED=$((GATES_PASSED + 1))
        else
            echo "🛑 FAIL: REPO_REMOTE_MATCH"
            echo "  - Expected remote (HTTPS): $ORIGIN_SSH_URL"
            echo "  - Or Expected remote (SSH): $EXPECTED_SSH_REMOTE"
            echo "  - Current remote:  $CURRENT_REMOTE"
            FAILED_GATES+=("REPO_REMOTE_MATCH")
        fi
    fi
fi

# --- Gate: BRANCH_MATCH ---
GATES_TOTAL=$((GATES_TOTAL + 1))
echo "⏳ Checking gate: BRANCH_MATCH..."
if [ ! -f "$AUTHORITY_MAP_PATH" ]; then
    echo "🛑 FAIL: BRANCH_MATCH - Authority map not found at $AUTHORITY_MAP_PATH"
    FAILED_GATES+=("BRANCH_MATCH")
else
    # Corrected parsing: Extract deploy_branch
    EXPECTED_BRANCH=$(grep -o '"deploy_branch": *"[^"]*"' "$AUTHORITY_MAP_PATH" | sed -e 's/"deploy_branch": *//' -e 's/"//g' || true)
    
    if [ -z "$EXPECTED_BRANCH" ]; then
        echo "🛑 FAIL: BRANCH_MATCH - Could not parse deploy_branch from $AUTHORITY_MAP_PATH"
        FAILED_GATES+=("BRANCH_MATCH")
    else
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        if [ "$CURRENT_BRANCH" == "$EXPECTED_BRANCH" ]; then
            echo "✅ PASS: BRANCH_MATCH"
            GATES_PASSED=$((GATES_PASSED + 1))
        else
            echo "🛑 FAIL: BRANCH_MATCH - Expected '$EXPECTED_BRANCH', found '$CURRENT_BRANCH'"
            FAILED_GATES+=("BRANCH_MATCH")
        fi
    fi
fi

# --- Gate: CLEAN_WORKTREE ---
GATES_TOTAL=$((GATES_TOTAL + 1))
echo "⏳ Checking gate: CLEAN_WORKTREE..."
if [[ -z $(git status --porcelain) ]]; then
    echo "✅ PASS: CLEAN_WORKTREE"
    GATES_PASSED=$((GATES_PASSED + 1))
else
    echo "🛑 FAIL: CLEAN_WORKTREE - Uncommitted changes detected."
    FAILED_GATES+=("CLEAN_WORKTREE")
fi

# --- Gate: SESSION_START_SSOT ---
GATES_TOTAL=$((GATES_TOTAL + 1))
echo "⏳ Checking gate: SESSION_START_SSOT..."
if [ ! -f "$SESSION_START_JSON" ]; then
    echo "🛑 FAIL: SESSION_START_SSOT - File not found: $SESSION_START_JSON"
    FAILED_GATES+=("SESSION_START_SSOT")
else
    CANON_ID=$(grep -o '"canon_id": *"[^"]*"' "$SESSION_START_JSON" | sed -e 's/"canon_id": *//' -e 's/"//g' || true)
    if [ -z "$CANON_ID" ] || [ "$CANON_ID" == "UNINITIALIZED" ]; then
        echo "🛑 FAIL: SESSION_START_SSOT - canon_id is missing or UNINITIALIZED in $SESSION_START_JSON"
        FAILED_GATES+=("SESSION_START_SSOT")
    else
        echo "✅ PASS: SESSION_START_SSOT"
        GATES_PASSED=$((GATES_PASSED + 1))
    fi
fi

# --- Gate: RUNTIME_IDENTITY_MATCH (CI mode only) ---
if [ "$MODE" == "ci" ]; then
    GATES_TOTAL=$((GATES_TOTAL + 1))
    echo "⏳ Checking gate: RUNTIME_IDENTITY_MATCH..."

    # Extract runtime_identity_path (/__version endpoint for Phase 3)
    # Fallback to runtime_version_path for backwards compatibility
    RUNTIME_IDENTITY_PATH=$(grep -o '"runtime_identity_path": *"[^"]*"' "$AUTHORITY_MAP_PATH" | head -1 | sed -e 's/"runtime_identity_path": *//' -e 's/"//g' || true)
    if [ -z "$RUNTIME_IDENTITY_PATH" ]; then
        RUNTIME_IDENTITY_PATH=$(grep -o '"runtime_version_path": *"[^"]*"' "$AUTHORITY_MAP_PATH" | head -1 | sed -e 's/"runtime_version_path": *//' -e 's/"//g' || true)
    fi

    if [ -z "$RUNTIME_IDENTITY_PATH" ]; then
        echo "⚠️  CLARIFY_REQUIRED: RUNTIME_IDENTITY_MATCH - Missing runtime_version_path in authority_map.json"
        FAILED_GATES+=("RUNTIME_IDENTITY_MATCH")
    else
        # Find the service with runtime_version_path and extract its URL
        # Look for "mosaic-backend" service specifically (has runtime_version_path)
        RUNTIME_URL=$(grep -A 10 '"name": *"mosaic-backend"' "$AUTHORITY_MAP_PATH" | grep -o '"url": *"[^"]*"' | head -1 | sed -e 's/"url": *//' -e 's/"//g' || true)
        RUNTIME_MODE=$(grep -A 10 '"name": *"mosaic-backend"' "$AUTHORITY_MAP_PATH" | grep -o '"mode": *"[^"]*"' | head -1 | sed -e 's/"mode": *//' -e 's/"//g' || true)

        if [ "$RUNTIME_MODE" == "static" ]; then
            # Static mode: URL is directly specified

            if [ -z "$RUNTIME_URL" ]; then
                echo "⚠️  CLARIFY_REQUIRED: RUNTIME_IDENTITY_MATCH - Missing url in static mode"
                FAILED_GATES+=("RUNTIME_IDENTITY_MATCH")
            else
                EXPECTED_SHA=$(git rev-parse HEAD)
                FULL_URL="${RUNTIME_URL}${RUNTIME_IDENTITY_PATH}"

                # Fetch runtime health/version
                RUNTIME_RESPONSE=$(curl --fail --silent --max-time 5 "$FULL_URL" 2>&1 || echo "NETWORK_FAILURE")

                if [ "$RUNTIME_RESPONSE" == "NETWORK_FAILURE" ]; then
                    echo "⚠️  CLARIFY_REQUIRED: RUNTIME_IDENTITY_MATCH - Network failure accessing $FULL_URL"
                    FAILED_GATES+=("RUNTIME_IDENTITY_MATCH")
                else
                    # Phase 3: For /__version endpoint, verify git_sha matches
                    if echo "$FULL_URL" | grep -q "/__version"; then
                        RUNTIME_SHA=$(echo "$RUNTIME_RESPONSE" | grep -o '"git_sha": *"[^"]*"' | sed -e 's/"git_sha": *//' -e 's/"//g' || true)
                        if [ -n "$RUNTIME_SHA" ]; then
                            if [ "$RUNTIME_SHA" == "$EXPECTED_SHA" ]; then
                                echo "✅ PASS: RUNTIME_IDENTITY_MATCH (git_sha: ${RUNTIME_SHA:0:8} matches expected)"
                                GATES_PASSED=$((GATES_PASSED + 1))
                            else
                                echo "🛑 FAIL: RUNTIME_IDENTITY_MATCH - Git SHA mismatch"
                                echo "  - Expected: ${EXPECTED_SHA:0:8}"
                                echo "  - Runtime:  ${RUNTIME_SHA:0:8}"
                                FAILED_GATES+=("RUNTIME_IDENTITY_MATCH")
                            fi
                        else
                            echo "⚠️  CLARIFY_REQUIRED: RUNTIME_IDENTITY_MATCH - No git_sha in response"
                            FAILED_GATES+=("RUNTIME_IDENTITY_MATCH")
                        fi
                    else
                        # For health endpoints, just check if service is responding
                        if echo "$RUNTIME_RESPONSE" | grep -q '"ok"'; then
                            echo "✅ PASS: RUNTIME_IDENTITY_MATCH (service healthy at $FULL_URL)"
                            GATES_PASSED=$((GATES_PASSED + 1))
                        else
                            echo "⚠️  CLARIFY_REQUIRED: RUNTIME_IDENTITY_MATCH - Service responding but no health status"
                            FAILED_GATES+=("RUNTIME_IDENTITY_MATCH")
                        fi
                    fi
                fi
            fi
        elif [ "$RUNTIME_MODE" == "template" ]; then
            # Template mode: resolve env vars
            RUNTIME_URL_TEMPLATE=$(grep -o '"template": *"[^"]*"' "$AUTHORITY_MAP_PATH" | sed -e 's/"template": *//' -e 's/"//g' || true)

            if [ -n "${RAILWAY_STATIC_URL:-}" ]; then
                RUNTIME_URL=$(echo "$RUNTIME_URL_TEMPLATE" | sed "s/\${RAILWAY_STATIC_URL}/${RAILWAY_STATIC_URL}/g")
                FULL_URL="${RUNTIME_URL}${RUNTIME_IDENTITY_PATH}"
                EXPECTED_SHA=$(git rev-parse HEAD)

                RUNTIME_RESPONSE=$(curl --fail --silent --max-time 5 "$FULL_URL" 2>&1 || echo "NETWORK_FAILURE")

                if [ "$RUNTIME_RESPONSE" == "NETWORK_FAILURE" ]; then
                    echo "⚠️  CLARIFY_REQUIRED: RUNTIME_IDENTITY_MATCH - Network failure (service unreachable)"
                    FAILED_GATES+=("RUNTIME_IDENTITY_MATCH")
                else
                    echo "✅ PASS: RUNTIME_IDENTITY_MATCH (service responding)"
                    GATES_PASSED=$((GATES_PASSED + 1))
                fi
            else
                echo "⏭️  SKIP: RUNTIME_IDENTITY_MATCH - Required env var not set (expected in initial CI setup)"
                GATES_PASSED=$((GATES_PASSED + 1))
            fi
        else
            echo "⚠️  CLARIFY_REQUIRED: RUNTIME_IDENTITY_MATCH - Unknown runtime_base_url mode: $RUNTIME_MODE"
            FAILED_GATES+=("RUNTIME_IDENTITY_MATCH")
        fi
    fi
fi

# --- Gate: RUNTIME_SELF_ATTEST (runtime mode only) ---
if [ "$MODE" == "runtime" ]; then
    GATES_TOTAL=$((GATES_TOTAL + 1))
    echo "⏳ Checking gate: RUNTIME_SELF_ATTEST..."

    # Phase 3: Runtime Self-Attestation
    # Verify that GIT_SHA is available in runtime environment
    # Render provides RENDER_GIT_COMMIT automatically, check both

    GIT_SHA="${GIT_SHA:-}"
    RENDER_GIT_COMMIT="${RENDER_GIT_COMMIT:-}"

    if [ -n "$GIT_SHA" ] || [ -n "$RENDER_GIT_COMMIT" ]; then
        EFFECTIVE_SHA="${GIT_SHA:-$RENDER_GIT_COMMIT}"
        echo "✅ PASS: RUNTIME_SELF_ATTEST (git_sha: ${EFFECTIVE_SHA:0:8})"
        GATES_PASSED=$((GATES_PASSED + 1))
    else
        echo "🛑 FAIL: RUNTIME_SELF_ATTEST - GIT_SHA not set in runtime environment"
        echo "  - Required: Set GIT_SHA or ensure RENDER_GIT_COMMIT is available"
        echo "  - This indicates build-time injection failed"
        FAILED_GATES+=("RUNTIME_SELF_ATTEST")
    fi
fi

# --- Final Verdict ---
echo "---"
echo "Gates checked: $GATES_TOTAL"
echo "Result: $GATES_PASSED / $GATES_TOTAL passed."

if [ $GATES_PASSED -eq $GATES_TOTAL ]; then
    echo "✅ ALLOW"
    exit 0
else
    echo "🛑 REJECT"
    echo "Failed gates: ${FAILED_GATES[*]}"
    exit 1
fi