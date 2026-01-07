#!/usr/bin/env python3
"""
GATE 1: Session Start Validator

Validates that new AI agent session completed mandatory startup protocol.
If validation fails, auto-generates redirect message with exact commands.

Usage:
    python3 gate_1_session_start.py "agent's first response text here"

    OR from file:
    cat agent_response.txt | python3 gate_1_session_start.py

Exit codes:
    0 = Gate passed (agent followed protocol)
    1 = Gate failed (agent violated protocol, see redirect message)
"""

import sys
from typing import Dict, List
from pathlib import Path

class Gate1SessionStart:
    """Validates session start protocol compliance"""

    REQUIRED_EVIDENCE = [
        {
            "name": "State Files Read",
            "evidence": ["Last agent:", "Last commit:", "Handoff message:"],
            "redirect_commands": [
                "cat .mosaic/agent_state.json",
                "cat .mosaic/blockers.json",
                "cat .mosaic/current_task.json"
            ],
            "reference_docs": [".mosaic/agent_state.json"]
        },
        {
            "name": "Latest Handoff Read",
            "evidence": ["SESSION HANDOFF", "Session Time:", "WHAT WAS BUILT"],
            "redirect_commands": [
                "cat .mosaic/LATEST_HANDOFF.md"
            ],
            "reference_docs": [".mosaic/LATEST_HANDOFF.md"]
        },
        {
            "name": "Post-Handoff Validation Run",
            "evidence": ["POST-HANDOFF VALIDATION", "tests passed", "Handoff validation:"],
            "redirect_commands": [
                "python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff"
            ],
            "reference_docs": [".mosaic/enforcement/README.md"]
        },
        {
            "name": "Git State Checked",
            "evidence": ["git log", "git status", "Recent commits:", "Working tree:"],
            "redirect_commands": [
                "git log --oneline -3",
                "git status"
            ],
            "reference_docs": []
        },
        {
            "name": "Critical Features Verified",
            "evidence": ["Authentication UI:", "PS101 v2 flow:", "API configuration:"],
            "redirect_commands": [
                "./scripts/verify_critical_features.sh"
            ],
            "reference_docs": [".ai-agents/AI_AGENT_PROMPT.md"]
        }
    ]

    def __init__(self, agent_response: str):
        self.agent_response = agent_response
        self.violations = []

    def validate(self) -> Dict:
        """Run all validation checks"""

        for requirement in self.REQUIRED_EVIDENCE:
            # Check if ANY evidence of this requirement exists
            has_evidence = any(
                evidence.lower() in self.agent_response.lower()
                for evidence in requirement["evidence"]
            )

            if not has_evidence:
                self.violations.append(requirement)

        if self.violations:
            return {
                "passed": False,
                "gate": "GATE_1_SESSION_START",
                "violations": self.violations,
                "redirect_message": self.generate_redirect()
            }

        return {
            "passed": True,
            "gate": "GATE_1_SESSION_START",
            "message": "Agent completed session start protocol"
        }

    def generate_redirect(self) -> str:
        """Generate auto-response to redirect agent to correct behavior"""

        msg = "⛔ GATE 1 FAILURE: Session Start Protocol Violated\n"
        msg += "=" * 70 + "\n\n"

        msg += "You did NOT execute mandatory startup commands from AI_AGENT_PROMPT.md.\n\n"

        msg += "MISSING EVIDENCE:\n"
        for v in self.violations:
            msg += f"  ❌ {v['name']}\n"

        msg += "\n" + "─" * 70 + "\n\n"
        msg += "🔧 CORRECTIVE ACTION REQUIRED:\n\n"
        msg += "Execute these commands NOW and show their output:\n\n"

        for v in self.violations:
            msg += f"# {v['name']}\n"
            for cmd in v['redirect_commands']:
                msg += f"{cmd}\n"
            msg += "\n"

        msg += "─" * 70 + "\n\n"
        msg += "📖 REFERENCE DOCUMENTS:\n\n"

        # Collect all unique reference docs
        all_docs = set()
        for v in self.violations:
            all_docs.update(v['reference_docs'])

        # Add mandatory docs
        all_docs.add(".ai-agents/AI_AGENT_PROMPT.md (Steps 1-3 MANDATORY)")
        all_docs.add(".mosaic/LATEST_HANDOFF.md (Previous session context)")

        for doc in sorted(all_docs):
            msg += f"  • {doc}\n"

        msg += "\n" + "─" * 70 + "\n\n"
        msg += "⚠️  DO NOT ask 'what would you like me to work on' until you:\n"
        msg += "  1. Execute all commands above\n"
        msg += "  2. Show their output in your response\n"
        msg += "  3. Declare what you learned from reading state files\n\n"

        msg += "=" * 70 + "\n"

        return msg


def main():
    """Main entry point"""

    # Read agent response from stdin or command line argument
    if len(sys.argv) > 1:
        agent_response = " ".join(sys.argv[1:])
    else:
        agent_response = sys.stdin.read()

    if not agent_response.strip():
        print("ERROR: No agent response provided", file=sys.stderr)
        print("Usage: gate_1_session_start.py 'agent response text'", file=sys.stderr)
        print("   OR: cat response.txt | gate_1_session_start.py", file=sys.stderr)
        return 1

    # Run validation
    gate = Gate1SessionStart(agent_response)
    result = gate.validate()

    if result["passed"]:
        print("✅ GATE 1 PASSED: Session Start Protocol Followed")
        print(f"\n{result['message']}")
        return 0
    else:
        print(result["redirect_message"])
        return 1


if __name__ == '__main__':
    sys.exit(main())
