#!/usr/bin/env python3
"""
MCP Trigger Detector
Detects when to retrieve full documentation based on conversation patterns
"""

import re
from typing import List, Set

class TriggerDetector:
    """Detects retrieval triggers from user messages and agent responses"""

    def __init__(self):
        # Define trigger patterns based on RETRIEVAL_TRIGGERS.md
        self.patterns = {
            "TROUBLESHOOTING_CHECKLIST": [
                # Match error/problem keywords in technical contexts
                r'\b(error|errors|failed|fails|failing|crash|crashed|exception|broken)\b',
                # Match timeout variations
                r'\b(timeout|timeouts|timing\s+out|timed\s+out)\b',
                # Match bug in technical context (not "bug flying")
                r'\bbug\s+(in|with|report|fix|fixes)',
                r'\bbugs\b',
                # Match issue/problem in technical context
                r'\bissues?\s+(with|in|report|detected)',
                r'\b(performance|security|critical)\s+issues?\b',
                r'\bproblems?\s+(with|in|detected)',
            ],
            "DEPLOYMENT_TRUTH": [
                r'\b(deploy|deployment|deploying|deployed|push|pushing|railway|production|prod|staging|release|released|rollback)\b',
            ],
            "STORAGE_PATTERNS": [
                r'\b(database|postgresql|postgres|sqlite|query|queries|migration|migrations|schema|connection|connections|sql)\b',
            ],
            "TEST_FRAMEWORK": [
                # Match test-related phrases
                r'\b(pytest|golden\s+dataset|coverage)\b',
                r'\bunit\s+tests?\b',
                r'\btests?\s+(are\s+)?(failing|failed|passed?|pass|running)\b',
            ],
            "CONTEXT_ENGINEERING_GUIDE": [
                # Triggered by response length, not keywords
            ]
        }

        # Compile regex patterns
        self.compiled_patterns = {}
        for trigger, patterns in self.patterns.items():
            self.compiled_patterns[trigger] = [
                re.compile(pattern, re.IGNORECASE)
                for pattern in patterns
            ]

    def detect_triggers(
        self,
        user_message: str,
        agent_response: str = ""
    ) -> List[str]:
        """
        Detect which documents should be retrieved

        Args:
            user_message: The user's input message
            agent_response: The agent's response (optional)

        Returns:
            List of document names to retrieve (e.g., ["TROUBLESHOOTING_CHECKLIST"])
        """
        triggered = set()

        # Combine messages for pattern matching
        combined_text = f"{user_message} {agent_response}"

        # Check keyword-based triggers
        for trigger, patterns in self.compiled_patterns.items():
            if trigger == "CONTEXT_ENGINEERING_GUIDE":
                continue  # Handled separately below

            for pattern in patterns:
                if pattern.search(combined_text):
                    triggered.add(trigger)
                    break  # One match per trigger is enough

        # Check context overflow trigger (response length)
        if agent_response:
            word_count = len(agent_response.split())
            if word_count > 1000:
                triggered.add("CONTEXT_ENGINEERING_GUIDE")

        return sorted(list(triggered))

    def get_document_paths(self, triggers: List[str]) -> dict:
        """
        Map trigger names to actual document paths

        Args:
            triggers: List of trigger names

        Returns:
            Dict mapping trigger to file path
        """
        document_map = {
            "TROUBLESHOOTING_CHECKLIST": "TROUBLESHOOTING_CHECKLIST.md",
            "DEPLOYMENT_TRUTH": "CLAUDE.md",  # Deployment section
            "STORAGE_PATTERNS": "SELF_DIAGNOSTIC_FRAMEWORK.md",  # Storage section
            "TEST_FRAMEWORK": "CLAUDE.md",  # Testing section
            "CONTEXT_ENGINEERING_GUIDE": "docs/CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md"
        }

        return {trigger: document_map[trigger] for trigger in triggers if trigger in document_map}


def main():
    """Test the trigger detector with sample messages"""
    detector = TriggerDetector()

    # Test cases
    test_cases = [
        ("The deployment failed with a 500 error", ""),
        ("Can you help me write a test?", ""),
        ("The PostgreSQL connection is timing out", ""),
        ("Normal conversation", ""),
        ("Test case", "word " * 1500),  # Long response
    ]

    print("Trigger Detector Test Results:")
    print("-" * 60)

    for user_msg, agent_resp in test_cases:
        triggers = detector.detect_triggers(user_msg, agent_resp)
        print(f"\nUser: {user_msg[:50]}...")
        print(f"Agent: {agent_resp[:50]}...")
        print(f"Triggers: {triggers if triggers else 'None'}")

    print("\n" + "=" * 60)
    print("Test complete. Run with golden dataset for full validation.")


if __name__ == "__main__":
    main()