#!/usr/bin/env python3
"""
Test SESSION_INIT.md protocol enforcement

This test verifies that the SESSION_INIT.md file exists, is properly referenced,
and contains all required elements to prevent the "what would you like to work on?"
protocol failure.

Usage:
    python3 .mosaic/enforcement/test_session_init.py

Exit codes:
    0 = All tests passed
    1 = One or more tests failed
"""

import json
import os
import sys
from pathlib import Path


class SessionInitTester:
    def __init__(self):
        self.repo_root = Path(__file__).parent.parent.parent
        self.failures = []
        self.warnings = []
        self.passed = 0

    def test_session_init_exists(self) -> bool:
        """Test: SESSION_INIT.md file exists"""
        print("\n🧪 Test: SESSION_INIT.md exists")

        session_init = self.repo_root / '.mosaic/SESSION_INIT.md'

        if not session_init.exists():
            self.failures.append("SESSION_INIT.md does not exist")
            print("  ❌ FAIL: File not found")
            return False

        if not session_init.is_file():
            self.failures.append("SESSION_INIT.md is not a file")
            print("  ❌ FAIL: Not a file")
            return False

        print("  ✅ PASS: File exists")
        return True

    def test_session_init_content(self) -> bool:
        """Test: SESSION_INIT.md contains required elements"""
        print("\n🧪 Test: SESSION_INIT.md has required content")

        session_init = self.repo_root / '.mosaic/SESSION_INIT.md'

        if not session_init.exists():
            self.failures.append("Cannot test content - file doesn't exist")
            print("  ❌ FAIL: File doesn't exist")
            return False

        with open(session_init) as f:
            content = f.read()

        required_elements = [
            ("NEVER ASK", "Prohibition against asking 'what to work on?'"),
            ("what to work on", "Explicit mention of the anti-pattern"),
            ("protocol failure", "Recognition that this is a failure"),
            ("Read state files", "Instruction to read state files"),
            ("agent_state.json", "Reference to state file"),
            ("current_task", "Reference to current task field"),
            ("handoff_message", "Reference to handoff message field"),
            ("Should I proceed?", "Correct question to ask instead"),
            ("CHECKLIST", "Checklist of required actions"),
            ("ANTI-PATTERNS", "Section on what NOT to do"),
            ("CORRECT PATTERN", "Section on what TO do"),
        ]

        missing = []
        for keyword, description in required_elements:
            if keyword not in content:
                missing.append(f"{description} (keyword: '{keyword}')")

        if missing:
            for item in missing:
                self.failures.append(f"SESSION_INIT.md missing: {item}")
            print(f"  ❌ FAIL: Missing {len(missing)} required elements")
            for item in missing[:3]:  # Show first 3
                print(f"     - {item}")
            return False

        print(f"  ✅ PASS: All {len(required_elements)} required elements present")
        return True

    def test_ai_agent_prompt_references_session_init(self) -> bool:
        """Test: AI_AGENT_PROMPT.md references SESSION_INIT.md as Step 0"""
        print("\n🧪 Test: AI_AGENT_PROMPT.md references SESSION_INIT")

        ai_prompt = self.repo_root / '.ai-agents/AI_AGENT_PROMPT.md'

        if not ai_prompt.exists():
            self.failures.append("AI_AGENT_PROMPT.md does not exist")
            print("  ❌ FAIL: AI_AGENT_PROMPT.md not found")
            return False

        with open(ai_prompt) as f:
            content = f.read()

        checks = [
            ("Step 0", "Step 0 section exists"),
            ("SESSION_INIT.md", "References SESSION_INIT.md"),
            ("cat .mosaic/SESSION_INIT.md", "Shows command to read file"),
            ("FIRST", "Emphasizes reading first"),
            ("protocol failure", "Mentions protocol failure"),
        ]

        missing = []
        for keyword, description in checks:
            if keyword not in content:
                missing.append(f"{description} (keyword: '{keyword}')")

        if missing:
            for item in missing:
                self.failures.append(f"AI_AGENT_PROMPT.md missing: {item}")
            print(f"  ❌ FAIL: Missing {len(missing)} required references")
            return False

        print(f"  ✅ PASS: All {len(checks)} required references present")
        return True

    def test_state_files_exist(self) -> bool:
        """Test: State files that SESSION_INIT references exist"""
        print("\n🧪 Test: Referenced state files exist")

        state_files = [
            '.mosaic/agent_state.json',
            '.mosaic/current_task.json',
            '.mosaic/blockers.json',
        ]

        missing = []
        for file_path in state_files:
            full_path = self.repo_root / file_path
            if not full_path.exists():
                missing.append(file_path)

        if missing:
            for file_path in missing:
                self.failures.append(f"State file missing: {file_path}")
            print(f"  ❌ FAIL: {len(missing)} state files missing")
            return False

        print(f"  ✅ PASS: All {len(state_files)} state files exist")
        return True

    def test_state_files_valid_json(self) -> bool:
        """Test: State files are valid JSON"""
        print("\n🧪 Test: State files are valid JSON")

        state_files = [
            '.mosaic/agent_state.json',
            '.mosaic/current_task.json',
            '.mosaic/blockers.json',
        ]

        invalid = []
        for file_path in state_files:
            full_path = self.repo_root / file_path
            if full_path.exists():
                try:
                    with open(full_path) as f:
                        json.load(f)
                except json.JSONDecodeError as e:
                    invalid.append(f"{file_path}: {str(e)}")

        if invalid:
            for item in invalid:
                self.failures.append(f"Invalid JSON: {item}")
            print(f"  ❌ FAIL: {len(invalid)} files have invalid JSON")
            return False

        print(f"  ✅ PASS: All {len(state_files)} state files are valid JSON")
        return True

    def test_agent_state_has_current_task(self) -> bool:
        """Test: agent_state.json has current_task and handoff_message"""
        print("\n🧪 Test: agent_state.json has required fields")

        agent_state_path = self.repo_root / '.mosaic/agent_state.json'

        if not agent_state_path.exists():
            self.failures.append("agent_state.json doesn't exist")
            print("  ❌ FAIL: File doesn't exist")
            return False

        try:
            with open(agent_state_path) as f:
                state = json.load(f)
        except json.JSONDecodeError:
            self.failures.append("agent_state.json is not valid JSON")
            print("  ❌ FAIL: Invalid JSON")
            return False

        required_fields = ['current_task', 'handoff_message', 'last_agent']
        missing = [field for field in required_fields if field not in state]

        if missing:
            for field in missing:
                self.failures.append(f"agent_state.json missing field: {field}")
            print(f"  ❌ FAIL: Missing {len(missing)} required fields")
            return False

        # Check if current_task is not empty
        if not state['current_task'] or state['current_task'].strip() == '':
            self.warnings.append("current_task is empty (new session won't know what to work on)")
            print("  ⚠️  WARN: current_task is empty")

        # Check if handoff_message is not empty
        if not state['handoff_message'] or len(state['handoff_message']) < 50:
            self.warnings.append("handoff_message is too short or empty")
            print("  ⚠️  WARN: handoff_message is too short")

        print(f"  ✅ PASS: All {len(required_fields)} required fields present")
        return True

    def test_mandatory_briefing_exists(self) -> bool:
        """Test: MANDATORY_AGENT_BRIEFING.md exists (referenced by SESSION_INIT)"""
        print("\n🧪 Test: MANDATORY_AGENT_BRIEFING.md exists")

        briefing = self.repo_root / '.mosaic/MANDATORY_AGENT_BRIEFING.md'

        if not briefing.exists():
            self.failures.append("MANDATORY_AGENT_BRIEFING.md doesn't exist")
            print("  ❌ FAIL: File not found")
            return False

        print("  ✅ PASS: File exists")
        return True

    def test_session_init_file_size(self) -> bool:
        """Test: SESSION_INIT.md is substantial (not a stub)"""
        print("\n🧪 Test: SESSION_INIT.md is substantial")

        session_init = self.repo_root / '.mosaic/SESSION_INIT.md'

        if not session_init.exists():
            self.failures.append("SESSION_INIT.md doesn't exist")
            print("  ❌ FAIL: File doesn't exist")
            return False

        size = session_init.stat().st_size
        min_size = 5000  # At least 5KB (comprehensive guide)

        if size < min_size:
            self.failures.append(f"SESSION_INIT.md too small ({size} bytes, expected >{min_size})")
            print(f"  ❌ FAIL: File too small ({size} bytes)")
            return False

        print(f"  ✅ PASS: File is substantial ({size} bytes)")
        return True

    def run_all_tests(self) -> bool:
        """Run all tests and return overall result"""
        print("🧪 SESSION_INIT PROTOCOL TEST SUITE")
        print("=" * 60)

        tests = [
            self.test_session_init_exists,
            self.test_session_init_file_size,
            self.test_session_init_content,
            self.test_ai_agent_prompt_references_session_init,
            self.test_state_files_exist,
            self.test_state_files_valid_json,
            self.test_agent_state_has_current_task,
            self.test_mandatory_briefing_exists,
        ]

        passed = 0
        failed = 0

        for test in tests:
            try:
                if test():
                    passed += 1
                else:
                    failed += 1
            except Exception as e:
                print(f"  ❌ FAIL: Exception: {str(e)}")
                self.failures.append(f"Test exception: {str(e)}")
                failed += 1

        # Summary
        print("\n" + "=" * 60)
        print("📊 TEST RESULTS")
        print("=" * 60)
        print(f"\n✅ Tests passed: {passed}")
        print(f"❌ Tests failed: {failed}")

        if self.warnings:
            print(f"⚠️  Warnings: {len(self.warnings)}")
            print("\nWarnings (non-blocking):")
            for warning in self.warnings:
                print(f"  - {warning}")

        if self.failures:
            print("\n❌ FAILURES:")
            for failure in self.failures:
                print(f"  - {failure}")
            print("\nNext steps:")
            print("1. Review failures above")
            print("2. Fix SESSION_INIT.md or state files")
            print("3. Re-run this test")
            return False
        else:
            print("\n✅ All SESSION_INIT protocol tests passed!")
            print("\nThis means:")
            print("- SESSION_INIT.md exists and is comprehensive")
            print("- AI_AGENT_PROMPT.md references it as Step 0")
            print("- State files exist and have current task info")
            print("- New Claude sessions should NOT ask 'what to work on?'")
            print("- New Claude sessions should read state and continue task")
            return True


def main():
    """Main entry point"""
    tester = SessionInitTester()
    success = tester.run_all_tests()
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
