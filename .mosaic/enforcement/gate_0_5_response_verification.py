#!/usr/bin/env python3
"""
GATE 0.5: Response Claim Verification

Validates agent responses for false existence claims BEFORE user sees them.
Enforces "check before act" protocol at response generation time.

Exit codes:
    0 = Response verified (all claims match filesystem reality)
    1 = Response blocked (false claim detected - agent must check filesystem first)
    2 = Verification cannot run (missing dependencies - NO_RUNTIME_AUTHORITY)
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Tuple, Dict

class Gate05ResponseVerification:
    """Verifies existence claims in agent responses against filesystem reality"""

    # Patterns that indicate agent is claiming something doesn't exist
    EXISTENCE_CLAIM_PATTERNS = [
        r'([\w\s-]+)\s+(?:is missing|doesn\'t exist|not found|missing|absent|gap)',
        r'(?:Missing|Gap|Absent):?\s*([^\n\.]+)',
        r'❌\s+(?:Missing|Not found|Doesn\'t exist):?\s*([^\n]+)',
        r'(?:need to create|should create|must create)\s+([\w\s-]+)',
        r'([\w\s-]+)\s+(?:does not exist|has not been|haven\'t been)\s+(?:created|implemented|built)',
    ]

    # Map natural language entity names to filesystem paths to check
    ENTITY_FILESYSTEM_MAP = {
        "master verifier": [
            "./verify_all.sh",
            "./verify.sh",
            "scripts/verify_all.sh",
            "verifiers/verify_all.sh"
        ],
        "audit log": [
            ".mosaic/session_log.jsonl",
            ".mosaic/audit.log",
            ".mosaic/audit.jsonl",
            ".mosaic/audit_log.json"
        ],
        "project identity": [
            ".mosaic/project_state.json",
            ".mosaic/project_identity.json",
            ".mosaic/project_metadata.json"
        ],
        "comprehension gate": [
            ".mosaic/enforcement/gate_1_session_start.py",
            ".mosaic/enforcement/gate_0_comprehension.sh"
        ],
        "verification manifest": [
            ".mosaic/verification_manifest.json",
            ".mosaic/verifiers.json"
        ],
        "receipt schema": [
            ".receipts/schema.json",
            ".mosaic/receipt_schema.json"
        ],
        "completion protocol": [
            ".mosaic/COMPLETION_PROTOCOL.md",
            ".mosaic/completion_checklist.md"
        ]
    }

    def __init__(self, repo_root: str = "."):
        self.repo_root = Path(repo_root)

    def extract_existence_claims(self, response_text: str) -> List[str]:
        """Extract all claims about missing/non-existent entities"""
        claims = []

        for pattern in self.EXISTENCE_CLAIM_PATTERNS:
            matches = re.finditer(pattern, response_text, re.IGNORECASE | re.MULTILINE)
            for match in matches:
                entity = match.group(1).strip().lower()
                # Clean up entity name
                entity = re.sub(r'\s+', ' ', entity)
                entity = entity.rstrip('.:,')
                claims.append(entity)

        return list(set(claims))  # Deduplicate

    def check_entity_exists(self, entity: str) -> Tuple[bool, List[str]]:
        """Check if entity exists in filesystem

        Returns:
            (exists, paths_found)
        """
        # Direct match in map
        if entity in self.ENTITY_FILESYSTEM_MAP:
            paths = self.ENTITY_FILESYSTEM_MAP[entity]
            found = [str(p) for p in paths if (self.repo_root / p).exists()]
            return (len(found) > 0, found)

        # Fuzzy match - check if any mapped entity contains the claim
        for mapped_entity, paths in self.ENTITY_FILESYSTEM_MAP.items():
            if entity in mapped_entity or mapped_entity in entity:
                found = [str(p) for p in paths if (self.repo_root / p).exists()]
                if found:
                    return (True, found)

        # No mapping - cannot verify (not a false claim if we don't know how to check)
        return (True, [])  # Pass by default if unmapped

    def verify_response(self, response_text: str) -> Tuple[bool, str]:
        """Verify all existence claims in response

        Returns:
            (passed, error_message)
        """
        claims = self.extract_existence_claims(response_text)

        if not claims:
            return (True, "")  # No existence claims to verify

        violations = []

        for claim in claims:
            exists, found_paths = self.check_entity_exists(claim)

            if exists and found_paths:
                violations.append({
                    "claim": claim,
                    "reality": f"EXISTS at: {', '.join(found_paths)}"
                })

        if violations:
            error_msg = self._generate_error_message(violations)
            return (False, error_msg)

        return (True, "")

    def _generate_error_message(self, violations: List[Dict]) -> str:
        """Generate detailed error message for blocked response"""
        msg = [
            "❌ GATE 0.5 FAILED: False existence claim detected",
            "=" * 70,
            "",
            "Your response contains claims that contradict filesystem reality:",
            ""
        ]

        for v in violations:
            msg.append(f"❌ You claimed: \"{v['claim']}\" is missing")
            msg.append(f"   Reality: {v['reality']}")
            msg.append("")

        msg.extend([
            "=" * 70,
            "REQUIRED ACTION (Check Before Act Protocol):",
            "",
            "1. Check filesystem state:",
            f"   ls -la {violations[0]['reality'].split(': ')[1].split(',')[0]}",
            "",
            "2. Read the file to understand what exists:",
            f"   cat {violations[0]['reality'].split(': ')[1].split(',')[0]}",
            "",
            "3. Regenerate response with accurate assessment",
            "",
            "Your response has been BLOCKED until you verify filesystem state.",
            "",
            "This enforces: CLAUDE.md CHECK BEFORE ACT protocol",
            "Pattern: Same as Gate 13 (ghost code) - detect → block → force check",
            ""
        ])

        return "\n".join(msg)

def main():
    """Run Gate 0.5 verification"""

    # Get response text from stdin or file
    if len(sys.argv) > 1:
        response_text = sys.argv[1]
    else:
        response_text = sys.stdin.read()

    if not response_text.strip():
        print("ERROR: No response text provided")
        sys.exit(2)  # NO_RUNTIME_AUTHORITY

    gate = Gate05ResponseVerification()
    passed, error_message = gate.verify_response(response_text)

    if passed:
        print("✅ Gate 0.5 PASSED: No false existence claims detected")
        print("")
        sys.exit(0)
    else:
        print(error_message)
        sys.exit(1)

if __name__ == "__main__":
    main()
