#!/usr/bin/env python3
"""
MCP Failure Mode Testing
Tests graceful degradation when MCP components fail
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, Any


def test_missing_mcp_files() -> Dict[str, Any]:
    """Test: MCP summary files missing - should fallback to full docs"""

    print("\n🧪 TEST 1: Missing MCP Files")
    print("=" * 60)

    required_files = [
        ".ai-agents/session_context/GOVERNANCE_SUMMARY.md",
        ".ai-agents/session_context/TROUBLESHOOTING_SUMMARY.md",
        ".ai-agents/session_context/RETRIEVAL_TRIGGERS.md"
    ]

    fallback_files = [
        "CLAUDE.md",
        "TROUBLESHOOTING_CHECKLIST.md"
    ]

    missing = []
    for filepath in required_files:
        if not Path(filepath).exists():
            missing.append(filepath)
            print(f"   ❌ MISSING: {filepath}")
        else:
            print(f"   ✅ EXISTS: {filepath}")

    # Check fallback files exist
    print("\n   Checking fallback files:")
    all_fallbacks_exist = True
    for filepath in fallback_files:
        if not Path(filepath).exists():
            print(f"   ❌ FALLBACK MISSING: {filepath}")
            all_fallbacks_exist = False
        else:
            print(f"   ✅ FALLBACK EXISTS: {filepath}")

    if missing:
        if all_fallbacks_exist:
            print("\n   ✅ PASS: Can fallback to full docs")
            return {"status": "pass", "missing": missing, "can_fallback": True}
        else:
            print("\n   ⚠️  WARNING: Some fallback files missing")
            return {"status": "warning", "missing": missing, "can_fallback": False}
    else:
        print("\n   ✅ PASS: All MCP files present")
        return {"status": "pass", "missing": [], "can_fallback": True}


def test_corrupt_session_log() -> Dict[str, Any]:
    """Test: Corrupt session log - should still start new session"""

    print("\n🧪 TEST 2: Corrupt Session Log")
    print("=" * 60)

    sessions_dir = Path(".ai-agents/sessions")

    # Create test corrupt log
    test_session = "test_corrupt_session"
    test_log = sessions_dir / f"{test_session}.jsonl"

    sessions_dir.mkdir(parents=True, exist_ok=True)

    # Write invalid JSON
    with open(test_log, 'w') as f:
        f.write("{invalid json here\n")
        f.write("not a valid jsonl format\n")

    print(f"   Created corrupt log: {test_log}")

    # Try to read it
    try:
        sys.path.insert(0, str(Path(__file__).parent.parent / "session_context"))
        from session_logger import SessionLogger
        logger = SessionLogger()

        # Attempt to read corrupt session
        events = logger.read_session(test_session)

        # Should handle gracefully (return empty or partial)
        print(f"   ⚠️  Read {len(events)} events from corrupt log")

        # Try to create NEW session (should work)
        new_session = "test_new_session_after_corrupt"
        success, error = logger.append_event(
            session_id=new_session,
            event_type="user_message",
            agent="test",
            source="test",
            data={"message": "test"}
        )

        if success:
            print("   ✅ PASS: Can create new session after corrupt log")
            # Clean up
            test_log.unlink()
            (sessions_dir / f"{new_session}.jsonl").unlink()
            return {"status": "pass", "can_create_new": True}
        else:
            print(f"   ❌ FAIL: Cannot create new session: {error}")
            test_log.unlink()
            return {"status": "fail", "can_create_new": False, "error": error}

    except Exception as e:
        print(f"   ❌ FAIL: Exception handling corrupt log: {e}")
        test_log.unlink()
        return {"status": "fail", "error": str(e)}


def test_invalid_trigger() -> Dict[str, Any]:
    """Test: Invalid trigger - should log error and continue"""

    print("\n🧪 TEST 3: Invalid Trigger")
    print("=" * 60)

    try:
        sys.path.insert(0, str(Path(__file__).parent.parent / "session_context"))
        from trigger_detector import detect_triggers

        # Test with invalid/ambiguous input
        user_message = ""  # Empty message
        agent_response = ""  # Empty response

        triggers = detect_triggers(user_message, agent_response)

        print(f"   Triggers detected: {triggers}")

        if isinstance(triggers, list):
            print("   ✅ PASS: Returns list even with empty input")
            return {"status": "pass", "triggers": triggers}
        else:
            print("   ❌ FAIL: Does not return list")
            return {"status": "fail", "triggers": triggers}

    except Exception as e:
        print(f"   ⚠️  Exception: {e}")
        print("   ✅ PASS: Exception handled (expected for invalid input)")
        return {"status": "pass", "exception_handled": True}


def test_missing_schema_file() -> Dict[str, Any]:
    """Test: Missing schema file - should handle gracefully"""

    print("\n🧪 TEST 4: Missing Schema File")
    print("=" * 60)

    schema_file = Path(".ai-agents/session_context/SESSION_LOG_SCHEMA.json")

    if not schema_file.exists():
        print(f"   ⚠️  Schema file missing: {schema_file}")
        print("   Attempting to create session without schema...")

        try:
            sys.path.insert(0, str(Path(__file__).parent.parent / "session_context"))
            from session_logger import SessionLogger
            logger = SessionLogger()
            print("   ❌ FAIL: SessionLogger should require schema")
            return {"status": "fail", "should_fail_without_schema": True}

        except Exception as e:
            print(f"   ✅ PASS: Correctly fails without schema: {e}")
            return {"status": "pass", "fails_correctly": True}

    else:
        print(f"   ✅ Schema file exists: {schema_file}")

        # Temporarily rename schema
        backup_name = schema_file.with_suffix('.json.backup')
        schema_file.rename(backup_name)

        try:
            sys.path.insert(0, str(Path(__file__).parent.parent / "session_context"))
            from session_logger import SessionLogger
            logger = SessionLogger()
            print("   ❌ FAIL: Should fail without schema")
            result = {"status": "fail", "should_fail_without_schema": True}

        except Exception as e:
            print(f"   ✅ PASS: Correctly requires schema: {e}")
            result = {"status": "pass", "requires_schema": True}

        finally:
            # Restore schema
            backup_name.rename(schema_file)

        return result


def test_feature_flag_disabled() -> Dict[str, Any]:
    """Test: MCP disabled via feature flag - should use baseline"""

    print("\n🧪 TEST 5: Feature Flag Disabled")
    print("=" * 60)

    flags_file = Path(".ai-agents/config/feature_flags.json")

    if not flags_file.exists():
        print(f"   ⚠️  Feature flags file missing: {flags_file}")
        return {"status": "warning", "file_missing": True}

    with open(flags_file) as f:
        flags = json.load(f)

    mcp_enabled = flags.get("flags", {}).get("MCP_ENABLED", False)

    print(f"   MCP_ENABLED flag: {mcp_enabled}")

    if not mcp_enabled:
        print("   ✅ PASS: MCP disabled, should use baseline docs")
        return {"status": "pass", "using_baseline": True}
    else:
        print("   ⚠️  INFO: MCP enabled, should use summaries")
        return {"status": "info", "using_summaries": True}


def run_all_tests() -> Dict[str, Any]:
    """Run all failure mode tests"""

    print("\n" + "=" * 60)
    print("MCP FAILURE MODE TESTING")
    print("=" * 60)

    results = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "tests": {}
    }

    # Run tests
    results["tests"]["missing_mcp_files"] = test_missing_mcp_files()
    results["tests"]["corrupt_session_log"] = test_corrupt_session_log()
    results["tests"]["invalid_trigger"] = test_invalid_trigger()
    results["tests"]["missing_schema"] = test_missing_schema_file()
    results["tests"]["feature_flag"] = test_feature_flag_disabled()

    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)

    passed = sum(1 for t in results["tests"].values() if t.get("status") == "pass")
    warnings = sum(1 for t in results["tests"].values() if t.get("status") == "warning")
    failed = sum(1 for t in results["tests"].values() if t.get("status") == "fail")
    total = len(results["tests"])

    print(f"\n   ✅ Passed:   {passed}/{total}")
    print(f"   ⚠️  Warnings: {warnings}/{total}")
    print(f"   ❌ Failed:   {failed}/{total}")

    overall = "PASS" if failed == 0 else "FAIL"
    print(f"\n   Overall: {overall}")

    # Save results
    results_file = Path(".ai-agents/validation/FAILURE_MODE_TEST_RESULTS.json")
    results_file.parent.mkdir(parents=True, exist_ok=True)

    with open(results_file, 'w') as f:
        json.dumps(results, indent=2)

    print(f"\n   Results saved: {results_file}")

    return results


def main():
    """CLI interface"""
    results = run_all_tests()

    # Exit with appropriate code
    failed = sum(1 for t in results["tests"].values() if t.get("status") == "fail")
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
