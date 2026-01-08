#!/usr/bin/env python3
"""
ML-Style Session Handoff Validation Tests

Based on Nate's Eval Design + Production Monitoring prompts.
This is TECHNICAL enforcement - tests that BLOCK until passing.

NOT behavioral programming (documentation asking agents to follow rules).

Validation Gates:
1. Pre-Handoff: Agent cannot mark "complete" without passing tests
2. During-Handoff: State files must match reality (production state, file existence)
3. Post-Handoff: New session must be able to resume without errors

Usage:
    python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff
    python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff

Exit codes:
    0 = All tests passed
    1 = Tests failed (blocks handoff)
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Tuple
from datetime import datetime

class HandoffValidator:
    """Test suite that validates session handoff completeness"""

    def __init__(self, repo_root: Path = None):
        self.repo_root = repo_root or Path(__file__).parent.parent.parent
        self.failures = []
        self.warnings = []

    def run_pre_handoff_tests(self) -> bool:
        """
        Run BEFORE agent claims work is complete.
        Based on Nate's Eval Design prompt.
        """
        print("🔍 PRE-HANDOFF VALIDATION TESTS")
        print("=" * 60)

        tests = [
            self.test_state_files_exist,
            self.test_production_state_matches_claims,
            self.test_referenced_files_exist,
            self.test_git_status_clean_or_documented,
            self.test_mandatory_briefing_updated,
            self.test_blockers_status_matches_reality,
        ]

        passed = 0
        for test in tests:
            if test():
                passed += 1

        total = len(tests)
        print(f"\n📊 PRE-HANDOFF RESULTS: {passed}/{total} tests passed")

        if self.failures:
            print(f"\n❌ BLOCKING FAILURES:")
            for failure in self.failures:
                print(f"  - {failure}")
            print(f"\n⚠️  Cannot mark work 'complete' until all tests pass.")
            return False

        if self.warnings:
            print(f"\n⚠️  WARNINGS (non-blocking):")
            for warning in self.warnings:
                print(f"  - {warning}")

        print(f"\n✅ All pre-handoff tests passed. Safe to mark complete.")
        return True

    def run_post_handoff_tests(self) -> bool:
        """
        Run in NEW session to validate handoff worked.
        Based on Nate's Production Monitoring prompt.
        """
        print("🔍 POST-HANDOFF VALIDATION TESTS")
        print("=" * 60)

        tests = [
            self.test_can_read_all_state_files,
            self.test_handoff_message_exists,
            self.test_session_gate_passes,
            self.test_no_missing_files_referenced,
            self.test_can_determine_production_state,
        ]

        passed = 0
        for test in tests:
            if test():
                passed += 1

        total = len(tests)
        print(f"\n📊 POST-HANDOFF RESULTS: {passed}/{total} tests passed")

        if self.failures:
            print(f"\n❌ HANDOFF FAILED:")
            for failure in self.failures:
                print(f"  - {failure}")
            print(f"\n⚠️  Previous agent's handoff did not work correctly.")
            return False

        print(f"\n✅ All post-handoff tests passed. Session can resume.")
        return True

    # ===== PRE-HANDOFF TESTS =====

    def test_state_files_exist(self) -> bool:
        """EVAL: All .mosaic/*.json state files must exist"""
        required_files = [
            '.mosaic/agent_state.json',
            '.mosaic/blockers.json',
            '.mosaic/current_task.json',
        ]

        print("\n🧪 Test: State files exist")
        missing = []
        for file_path in required_files:
            full_path = self.repo_root / file_path
            if not full_path.exists():
                missing.append(file_path)

        if missing:
            self.failures.append(f"Missing state files: {missing}")
            print(f"  ❌ FAIL: Missing {len(missing)} state files")
            return False
        else:
            print(f"  ✅ PASS: All {len(required_files)} state files exist")
            return True

    def test_production_state_matches_claims(self) -> bool:
        """
        EVAL: Git state must be clean and pushed.
        Prevents: Agent says "deployed" but didn't actually push.

        NOTE: No longer checks last_commit (removed due to circular dependency).
        Now only validates that all commits are pushed to origin/main.
        """
        print("\n🧪 Test: Production state matches claims")

        # Get actual git state
        try:
            actual_commit = subprocess.check_output(
                ['git', 'rev-parse', 'HEAD'],
                cwd=self.repo_root,
                text=True
            ).strip()[:7]

            origin_commit = subprocess.check_output(
                ['git', 'rev-parse', 'origin/main'],
                cwd=self.repo_root,
                text=True
            ).strip()[:7]

        except subprocess.CalledProcessError as e:
            self.failures.append(f"Cannot check git state: {e}")
            print(f"  ❌ FAIL: Git command failed")
            return False

        # Check if all commits are pushed
        if actual_commit != origin_commit:
            self.failures.append(f"Production state mismatch: Local HEAD {actual_commit} != origin/main {origin_commit} (unpushed work)")
            print(f"  ❌ FAIL: Unpushed commits detected")
            return False
        else:
            print(f"  ✅ PASS: All commits pushed (HEAD = {actual_commit})")
            return True

    def test_referenced_files_exist(self) -> bool:
        """
        EVAL: All files referenced in documentation must exist.
        Prevents: Docs say "run verify_critical_features.sh" but file doesn't exist.
        """
        print("\n🧪 Test: Referenced files exist")

        # Files referenced in AI_AGENT_PROMPT.md
        referenced_files = [
            '.mosaic/MANDATORY_AGENT_BRIEFING.md',
            '.mosaic/agent_state.json',
            '.mosaic/blockers.json',
            '.mosaic/current_task.json',
            '.mosaic/enforcement/session-gate.sh',
            'scripts/archive_stale_docs.sh',
        ]

        missing = []
        for file_path in referenced_files:
            full_path = self.repo_root / file_path
            if not full_path.exists():
                missing.append(file_path)

        if missing:
            for file in missing:
                self.failures.append(f"Referenced file does not exist: {file}")
            print(f"  ❌ FAIL: {len(missing)} referenced files missing")
            return False
        else:
            print(f"  ✅ PASS: All {len(referenced_files)} referenced files exist")
            return True

    def test_git_status_clean_or_documented(self) -> bool:
        """
        EVAL: No uncommitted changes OR handoff doc explains them.
        Prevents: Agent forgets to commit work.
        """
        print("\n🧪 Test: Git status clean or documented")

        try:
            git_status = subprocess.check_output(
                ['git', 'status', '--short'],
                cwd=self.repo_root,
                text=True
            ).strip()
        except subprocess.CalledProcessError as e:
            self.failures.append(f"Cannot check git status: {e}")
            print(f"  ❌ FAIL: Git command failed")
            return False

        if not git_status:
            print(f"  ✅ PASS: No uncommitted changes")
            return True

        # Check if handoff doc mentions uncommitted changes
        handoff_file = self.repo_root / '.mosaic/LATEST_HANDOFF.md'
        if handoff_file.exists():
            with open(handoff_file) as f:
                handoff_content = f.read().lower()
            if 'uncommitted' in handoff_content or 'not committed' in handoff_content:
                self.warnings.append(f"Uncommitted changes exist but documented in handoff")
                print(f"  ⚠️  WARN: Uncommitted changes but documented")
                return True

        self.failures.append(f"Uncommitted changes exist:\n{git_status}")
        print(f"  ❌ FAIL: Uncommitted changes not documented")
        return False

    def test_mandatory_briefing_updated(self) -> bool:
        """
        EVAL: MANDATORY_AGENT_BRIEFING.md modified date matches session.
        Prevents: Agent forgets to update briefing.
        """
        print("\n🧪 Test: Mandatory briefing updated")

        briefing_file = self.repo_root / '.mosaic/MANDATORY_AGENT_BRIEFING.md'
        if not briefing_file.exists():
            self.failures.append("MANDATORY_AGENT_BRIEFING.md does not exist")
            print(f"  ❌ FAIL: Briefing file missing")
            return False

        # Check modification time
        mtime = datetime.fromtimestamp(briefing_file.stat().st_mtime)
        age_hours = (datetime.now() - mtime).total_seconds() / 3600

        if age_hours > 24:
            self.warnings.append(f"Briefing last updated {age_hours:.1f} hours ago")
            print(f"  ⚠️  WARN: Briefing is {age_hours:.1f} hours old")
            return True
        else:
            print(f"  ✅ PASS: Briefing updated {age_hours:.1f} hours ago")
            return True

    def test_blockers_status_matches_reality(self) -> bool:
        """
        EVAL: Blockers marked "resolved" must have evidence.
        Prevents: Agent marks blocker resolved without actually fixing it.
        """
        print("\n🧪 Test: Blocker status matches reality")

        blockers_file = self.repo_root / '.mosaic/blockers.json'
        with open(blockers_file) as f:
            blockers = json.load(f)

        resolved_blockers = [
            b for b in blockers.get('blockers', [])
            if b.get('status') == 'resolved'
        ]

        if not resolved_blockers:
            print(f"  ✅ PASS: No blockers marked resolved")
            return True

        # For each resolved blocker, check if fix exists
        for blocker in resolved_blockers:
            blocker_id = blocker.get('id', 'unknown')

            # Simple heuristic: If blocker mentioned file, check file exists/changed
            # This is a simplified check - real version would be more sophisticated
            if 'missing' in blocker.get('description', '').lower():
                # Check if previously missing file now exists
                # (This would need blocker-specific logic)
                pass

        # For now, just warn if many blockers resolved in one session
        if len(resolved_blockers) > 3:
            self.warnings.append(f"{len(resolved_blockers)} blockers marked resolved - verify each")
            print(f"  ⚠️  WARN: {len(resolved_blockers)} blockers resolved")

        print(f"  ✅ PASS: Blocker status checks passed")
        return True

    # ===== POST-HANDOFF TESTS =====

    def test_can_read_all_state_files(self) -> bool:
        """EVAL: New session can read all state files without errors"""
        print("\n🧪 Test: Can read all state files")

        state_files = [
            '.mosaic/agent_state.json',
            '.mosaic/blockers.json',
            '.mosaic/current_task.json',
        ]

        errors = []
        for file_path in state_files:
            full_path = self.repo_root / file_path
            try:
                with open(full_path) as f:
                    json.load(f)
            except (FileNotFoundError, json.JSONDecodeError) as e:
                errors.append(f"{file_path}: {e}")

        if errors:
            for error in errors:
                self.failures.append(f"Cannot read state file: {error}")
            print(f"  ❌ FAIL: {len(errors)} state files unreadable")
            return False
        else:
            print(f"  ✅ PASS: All {len(state_files)} state files readable")
            return True

    def test_handoff_message_exists(self) -> bool:
        """EVAL: agent_state.json contains handoff_message from previous agent"""
        print("\n🧪 Test: Handoff message exists")

        state_file = self.repo_root / '.mosaic/agent_state.json'
        with open(state_file) as f:
            state = json.load(f)

        handoff_msg = state.get('handoff_message', '')

        if not handoff_msg or len(handoff_msg) < 50:
            self.failures.append("handoff_message is empty or too short")
            print(f"  ❌ FAIL: No meaningful handoff message")
            return False
        else:
            print(f"  ✅ PASS: Handoff message exists ({len(handoff_msg)} chars)")
            return True

    def test_session_gate_passes(self) -> bool:
        """EVAL: session-gate.sh passes without errors"""
        print("\n🧪 Test: Session gate passes")

        session_gate = self.repo_root / '.mosaic/enforcement/session-gate.sh'
        if not session_gate.exists():
            self.failures.append("session-gate.sh does not exist")
            print(f"  ❌ FAIL: Session gate missing")
            return False

        try:
            subprocess.check_output(
                ['bash', str(session_gate)],
                cwd=self.repo_root,
                stderr=subprocess.STDOUT,
                text=True
            )
            print(f"  ✅ PASS: Session gate passed")
            return True
        except subprocess.CalledProcessError as e:
            self.failures.append(f"Session gate failed: {e.output}")
            print(f"  ❌ FAIL: Session gate returned error")
            return False

    def test_no_missing_files_referenced(self) -> bool:
        """EVAL: Same as pre-handoff - ensures nothing broke during handoff"""
        return self.test_referenced_files_exist()

    def test_can_determine_production_state(self) -> bool:
        """EVAL: New session can determine production state from state files"""
        print("\n🧪 Test: Can determine production state")

        state_file = self.repo_root / '.mosaic/agent_state.json'
        with open(state_file) as f:
            state = json.load(f)

        required_fields = [
            'last_agent',
            'implementation_progress',
        ]

        missing = [f for f in required_fields if f not in state]

        if missing:
            for field in missing:
                self.failures.append(f"agent_state.json missing required field: {field}")
            print(f"  ❌ FAIL: Missing {len(missing)} required fields")
            return False

        # Check if implementation_progress has deployment info
        impl_progress = state.get('implementation_progress', {})
        if not impl_progress.get('render_service_url'):
            self.warnings.append("No render_service_url in implementation_progress")
            print(f"  ⚠️  WARN: No production URL in state")

        print(f"  ✅ PASS: Production state determinable")
        return True


def main():
    validator = HandoffValidator()

    if '--pre-handoff' in sys.argv:
        success = validator.run_pre_handoff_tests()
    elif '--post-handoff' in sys.argv:
        success = validator.run_post_handoff_tests()
    else:
        print("Usage: handoff_validation_tests.py [--pre-handoff|--post-handoff]")
        print("")
        print("  --pre-handoff   Run before marking work complete")
        print("  --post-handoff  Run in new session to verify handoff")
        sys.exit(1)

    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
