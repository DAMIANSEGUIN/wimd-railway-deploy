#!/bin/bash
# scripts/update_project_state.sh - Auto-update project state at session end

set -euo pipefail

REPO_ROOT="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
STATE_FILE="$REPO_ROOT/.mosaic/project_state.json"

cd "$REPO_ROOT"

echo "========================================"
echo "SESSION END - Updating Project State"
echo "========================================"
echo ""

# Get current git commit
CURRENT_COMMIT=$(git rev-parse --short HEAD)
CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Interactive prompts
echo "Please answer the following questions to update project state:"
echo ""

read -p "Agent name (e.g., Claude Code, Gemini, ChatGPT): " AGENT_NAME
echo ""

read -p "What was accomplished this session? " SESSION_SUMMARY
echo ""

read -p "Is current phase complete? (yes/no): " PHASE_COMPLETE
echo ""

read -p "Which implementation steps are now COMPLETE? (comma-separated step IDs, or 'none'): " COMPLETED_STEPS
echo ""

read -p "Any new blocking issues? (describe or press enter for none): " BLOCKING_ISSUES
echo ""

# Update project_state.json using Python for JSON manipulation
python3 <<EOF
import json
import sys
from datetime import datetime

STATE_FILE = "$STATE_FILE"
AGENT_NAME = "$AGENT_NAME"
SESSION_SUMMARY = "$SESSION_SUMMARY"
PHASE_COMPLETE = "$PHASE_COMPLETE"
COMPLETED_STEPS = "${COMPLETED_STEPS}"
BLOCKING_ISSUES = "$BLOCKING_ISSUES"
CURRENT_COMMIT = "$CURRENT_COMMIT"
CURRENT_TIMESTAMP = "$CURRENT_TIMESTAMP"

# Load current state
with open(STATE_FILE, 'r') as f:
    state = json.load(f)

# Update metadata
state['last_updated'] = CURRENT_TIMESTAMP
state['updated_by'] = AGENT_NAME
state['git_commit'] = CURRENT_COMMIT

# Update phase completion
if PHASE_COMPLETE.lower() == 'yes':
    state['current_phase']['status'] = 'COMPLETE'
    state['current_phase']['completion_date'] = datetime.now().strftime('%Y-%m-%d')
    state['current_phase']['completion_commit'] = CURRENT_COMMIT

# Update implementation steps
if COMPLETED_STEPS.lower() != 'none':
    step_ids = [s.strip() for s in COMPLETED_STEPS.split(',')]
    for step in state.get('next_phase', {}).get('implementation_steps', []):
        if step['step_id'] in step_ids:
            step['status'] = 'COMPLETE'

# Add blocking issues
if BLOCKING_ISSUES.strip():
    if 'blocking_issues' not in state:
        state['blocking_issues'] = []
    state['blocking_issues'].append({
        "description": BLOCKING_ISSUES,
        "date_reported": datetime.now().strftime('%Y-%m-%d'),
        "reported_by": AGENT_NAME,
        "status": "OPEN"
    })

# Add session history entry
session_entry = {
    "date": datetime.now().strftime('%Y-%m-%d'),
    "agent": AGENT_NAME,
    "action": SESSION_SUMMARY,
    "commit": CURRENT_COMMIT
}
state['session_history'].append(session_entry)

# Write updated state
with open(STATE_FILE, 'w') as f:
    json.dump(state, f, indent=2)

print("✅ project_state.json updated successfully")
EOF

echo ""
echo "========================================"
echo "Updated State:"
echo "========================================"
cat "$STATE_FILE" | python3 -m json.tool
echo ""

# Commit the updated state
echo "Committing updated project state..."
git add "$STATE_FILE"
git commit -m "Session end: Update project state

Agent: $AGENT_NAME
Summary: $SESSION_SUMMARY
Commit: $CURRENT_COMMIT
Phase complete: $PHASE_COMPLETE
"

echo ""
echo "✅ Session end complete!"
echo "   Updated: .mosaic/project_state.json"
echo "   Committed: $(git rev-parse --short HEAD)"
echo ""
echo "Next session will read updated state automatically."
