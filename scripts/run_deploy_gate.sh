#!/bin/zsh
# Enforce Mosaic deployment protocol before pushing or deploying
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

LOG_FILE=".verification_audit.log"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
USER_ID="${DEPLOY_ACTOR:-$(whoami)}"

echo "🛡️  Mosaic Deployment Gate"
echo "==============================="
echo ""
echo "Timestamp : $TIMESTAMP (UTC)"
echo "Actor     : $USER_ID"
echo ""
echo "Step 1: Running automated verification pipeline..."
echo ""

if ! ./scripts/pre_push_verification.sh; then
  {
    echo "[$TIMESTAMP] deploy_gate FAIL (pre_push_verification) actor=$USER_ID"
  } >> "$LOG_FILE"
  echo ""
  echo "❌ Deployment gate aborted - automated verification failed."
  exit 1
fi

echo ""
echo "✅ Automated verification passed"
echo ""

# Manual confirmation checklist
PROMPTS=(
  "Baseline snapshot or diff review completed (PS101 + docs up to date)"
  "Auth + coach smoke test executed on local/staging build"
  "PS101 10-step flow walked end-to-end against this build"
  "Release notes & DEPLOYMENT_CHECKLIST updated for this deploy"
  "Human reviewer notified (or queued) for user-facing changes"
)

typeset -A RESPONSES
echo "Step 2: Confirm manual gate checklist (answer yes / no / n/a)."
echo ""

for prompt in "${PROMPTS[@]}"; do
  while true; do
    printf "%s? [yes/no/n/a]: " "$prompt"
    read -r reply
    reply="${reply:l}"
    if [[ "$reply" == "yes" || "$reply" == "y" ]]; then
      RESPONSES["$prompt"]="yes"
      break
    elif [[ "$reply" == "no" || "$reply" == "n" ]]; then
      RESPONSES["$prompt"]="no"
      {
        echo "[$TIMESTAMP] deploy_gate FAIL (manual:$prompt) actor=$USER_ID"
      } >> "$LOG_FILE"
      echo ""
      echo "❌ Deployment gate aborted - '$prompt' not confirmed."
      exit 1
    elif [[ "$reply" == "n/a" || "$reply" == "na" ]]; then
      RESPONSES["$prompt"]="n/a"
      break
    else
      echo "Please respond with yes, no, or n/a."
    fi
  done
done

echo ""
echo "✅ Manual checklist confirmed"
echo ""

{
  echo "[$TIMESTAMP] deploy_gate PASS actor=$USER_ID"
  echo "  automated=pass"
for prompt in "${PROMPTS[@]}"; do
    response="${RESPONSES[$prompt]-n/a}"
    echo "  ${prompt} => ${response}"
  done
} >> "$LOG_FILE"

echo "Gate log appended to $LOG_FILE"
echo ""
echo "🟢 Deployment gate cleared. Safe to push and deploy."
