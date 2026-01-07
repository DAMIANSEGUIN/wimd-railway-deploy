#!/usr/bin/env python3
"""
GATE 2: Behavior Lint Validator

Detects forbidden behavioral patterns in agent responses.
If forbidden phrase appears without required context, auto-generates
redirect with relevant docs and deployment logs.

Usage:
    python3 gate_2_behavior_lint.py "agent response text here"

    OR from file:
    cat agent_response.txt | python3 gate_2_behavior_lint.py

Exit codes:
    0 = Gate passed (no violations)
    1 = Gate failed (violations detected, see redirect message)
"""

import sys
import subprocess
from typing import Dict, List
from pathlib import Path

class Gate2BehaviorLint:
    """Validates agent behavior patterns"""

    FORBIDDEN_PATTERNS = [
        {
            "trigger": "what would you like me to work on",
            "also_matches": ["what should i do", "what would you like me to do", "awaiting your direction"],
            "requires_context": [
                "Last agent:",
                "Last commit:",
                "Handoff message:",
                "✅ State files read"
            ],
            "redirect_to_docs": [
                ".mosaic/agent_state.json",
                ".mosaic/LATEST_HANDOFF.md",
                ".ai-agents/AI_AGENT_PROMPT.md (Steps 1-3)"
            ],
            "deployment_logs": [
                "git log --oneline -5",
                "git status",
                "python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff"
            ],
            "violation_type": "ASKED_FOR_DIRECTION_WITHOUT_READING_STATE",
            "severity": "CRITICAL"
        },
        {
            "trigger": "work complete",
            "also_matches": ["i'm done", "implementation complete", "ready for handoff"],
            "requires_context": [
                "6/6 tests passed",
                "✅ All pre-handoff tests passed",
                "PRE-HANDOFF RESULTS:",
                "Validation tests passed"
            ],
            "redirect_to_docs": [
                ".mosaic/enforcement/README.md",
                ".mosaic/ML_ENFORCEMENT_SUMMARY.md",
                ".ai-agents/AI_AGENT_PROMPT.md (Handoff section)"
            ],
            "deployment_logs": [
                "python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff",
                "git log --oneline -3",
                "git diff HEAD~1 HEAD --stat"
            ],
            "violation_type": "CLAIMED_COMPLETE_WITHOUT_VALIDATION",
            "severity": "CRITICAL"
        },
        {
            "trigger": "should i deploy",
            "also_matches": ["ready to deploy", "deploy this", "push to production"],
            "requires_context": [
                "Health check:",
                "Production state:",
                "deployment_status",
                "render_service_url"
            ],
            "redirect_to_docs": [
                "RENDER_DEPLOYMENT_GUIDE.md",
                ".mosaic/agent_state.json (implementation_progress)",
                "TROUBLESHOOTING_CHECKLIST.md"
            ],
            "deployment_logs": [
                "curl https://mosaic-backend-tpog.onrender.com/health",
                "cat .mosaic/agent_state.json | jq .implementation_progress",
                "git log --oneline origin/main..HEAD"
            ],
            "violation_type": "ASKED_ABOUT_DEPLOY_WITHOUT_CHECKING_STATE",
            "severity": "HIGH"
        },
        {
            "trigger": "i'll update the",
            "also_matches": ["let me update", "updating the", "i'll modify"],
            "requires_context": [
                "INTENT:",
                "Intent:",
                "Planning to",
                "Going to"
            ],
            "redirect_to_docs": [
                ".ai-agents/INTENT_FRAMEWORK.md",
                ".ai-agents/CROSS_AGENT_PROTOCOL.md (Rule 7)"
            ],
            "deployment_logs": [],
            "violation_type": "ACTION_WITHOUT_INTENT_DECLARATION",
            "severity": "MEDIUM"
        }
    ]

    def __init__(self, agent_response: str):
        self.agent_response = agent_response
        self.violations = []

    def validate(self) -> Dict:
        """Run all behavior lint checks"""

        for pattern in self.FORBIDDEN_PATTERNS:
            # Check if trigger phrase OR any alternate matches appear
            triggers = [pattern["trigger"]] + pattern.get("also_matches", [])

            trigger_found = any(
                trigger.lower() in self.agent_response.lower()
                for trigger in triggers
            )

            if trigger_found:
                # Check if required context is present
                has_context = any(
                    ctx in self.agent_response
                    for ctx in pattern["requires_context"]
                )

                if not has_context:
                    self.violations.append({
                        "pattern": pattern,
                        "matched_trigger": next(
                            t for t in triggers
                            if t.lower() in self.agent_response.lower()
                        )
                    })

        if self.violations:
            return {
                "passed": False,
                "gate": "GATE_2_BEHAVIOR_LINT",
                "violations": self.violations,
                "redirect_message": self.generate_redirect()
            }

        return {
            "passed": True,
            "gate": "GATE_2_BEHAVIOR_LINT",
            "message": "No behavioral violations detected"
        }

    def generate_redirect(self) -> str:
        """Generate auto-response with docs and deployment logs"""

        msg = "⛔ GATE 2 FAILURE: Behavioral Protocol Violation\n"
        msg += "=" * 70 + "\n\n"

        critical_count = sum(1 for v in self.violations if v["pattern"]["severity"] == "CRITICAL")

        if critical_count > 0:
            msg += f"🚨 {critical_count} CRITICAL violation(s) detected\n\n"

        for idx, v in enumerate(self.violations, 1):
            pattern = v["pattern"]

            msg += f"VIOLATION {idx}: {pattern['violation_type']}\n"
            msg += f"Severity: {pattern['severity']}\n"
            msg += "─" * 70 + "\n"
            msg += f"❌ You said: \"{v['matched_trigger']}\"\n"
            msg += f"   But you did NOT show:\n"
            for ctx in pattern["requires_context"]:
                msg += f"     • {ctx}\n"
            msg += "\n"

            msg += "📖 READ THESE DOCUMENTS FIRST:\n"
            for doc in pattern["redirect_to_docs"]:
                msg += f"   cat {doc}\n"
            msg += "\n"

            if pattern["deployment_logs"]:
                msg += "📊 CHECK DEPLOYMENT STATE:\n"
                for log_cmd in pattern["deployment_logs"]:
                    msg += f"   {log_cmd}\n"
                msg += "\n"

            msg += "Then respond with EVIDENCE you read them and checked state.\n"
            msg += "=" * 70 + "\n\n"

        msg += "⚠️  PROTOCOL REQUIREMENT:\n"
        msg += "  You cannot use forbidden phrases without showing required context.\n"
        msg += "  Read the docs, check deployment state, THEN respond with evidence.\n\n"

        return msg

    def get_deployment_state(self) -> str:
        """Get current deployment state for context"""
        try:
            # Get git state
            git_head = subprocess.check_output(
                ['git', 'rev-parse', '--short', 'HEAD'],
                cwd=Path(__file__).parent.parent.parent
            ).decode().strip()

            return f"Current HEAD: {git_head}"
        except:
            return "Could not retrieve deployment state"


def main():
    """Main entry point"""

    # Read agent response from stdin or command line argument
    if len(sys.argv) > 1:
        agent_response = " ".join(sys.argv[1:])
    else:
        agent_response = sys.stdin.read()

    if not agent_response.strip():
        print("ERROR: No agent response provided", file=sys.stderr)
        print("Usage: gate_2_behavior_lint.py 'agent response text'", file=sys.stderr)
        print("   OR: cat response.txt | gate_2_behavior_lint.py", file=sys.stderr)
        return 1

    # Run validation
    gate = Gate2BehaviorLint(agent_response)
    result = gate.validate()

    if result["passed"]:
        print("✅ GATE 2 PASSED: No Behavioral Violations")
        print(f"\n{result['message']}")
        return 0
    else:
        print(result["redirect_message"])
        return 1


if __name__ == '__main__':
    sys.exit(main())
