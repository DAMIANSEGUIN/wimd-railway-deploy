#!/usr/bin/env python3
"""
Session Start Readiness Test

Machine-executable verification that the system is ready for a new session
to start with correct context. Replaces the behavioral CONTEXT_PROVISIONING_TEST.md
(which required manual observation of a new session).

This test verifies INFRASTRUCTURE, not agent behavior:
  - State files are current (not stale)
  - Handoff is substantive
  - Architecture documentation matches live system
  - Enforcement gates pass
  - E2E receipt is present

On PASS: writes /tmp/session_start_receipt.json
On FAIL: exits 1 with specific failure reason

Usage:
    python3 .mosaic/enforcement/test_session_start_readiness.py

Exit codes:
    0 = PASS — system ready for new session
    1 = FAIL — fix issues before starting new session
"""

import json
import os
import subprocess
import sys
import time
from pathlib import Path


REPO_ROOT = Path(__file__).parent.parent.parent
RECEIPT_PATH = Path("/tmp/session_start_receipt.json")
E2E_RECEIPT_PATH = Path("/tmp/e2e_receipt.json")
E2E_MAX_AGE_SECONDS = 1800


class Check:
    def __init__(self, name: str):
        self.name = name
        self.passed = False
        self.detail = ""

    def ok(self, detail: str):
        self.passed = True
        self.detail = detail
        print(f"  ✅ {self.name}: {detail}")

    def fail(self, detail: str):
        self.passed = False
        self.detail = detail
        print(f"  ❌ {self.name}: {detail}")


def _run_shell(cmd: str, cwd=None) -> tuple:
    result = subprocess.run(
        cmd, shell=True, capture_output=True, text=True,
        cwd=cwd or REPO_ROOT
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def check_git_head_matches_state() -> Check:
    """State files must be current — allow 1 commit lag for state-update commit itself"""
    c = Check("State file currency")

    code, head, _ = _run_shell("git rev-parse --short HEAD")
    if code != 0:
        c.fail("Could not read git HEAD")
        return c

    state_path = REPO_ROOT / ".mosaic/agent_state.json"
    if not state_path.exists():
        c.fail("agent_state.json does not exist")
        return c

    try:
        state = json.loads(state_path.read_text())
    except json.JSONDecodeError as e:
        c.fail(f"agent_state.json is invalid JSON: {e}")
        return c

    last_commit = state.get("last_commit", "")

    if not last_commit:
        c.fail("agent_state.json has no last_commit field")
        return c

    # Allow 1 commit lag: state-update commit always creates a new HEAD.
    # Check that last_commit appears in recent history (last 3 commits).
    code2, log, _ = _run_shell("git log --oneline -3 --format=%h")
    recent = [h.strip() for h in log.splitlines() if h.strip()]

    if last_commit not in recent:
        c.fail(
            f"STALE: state has {last_commit}, not in recent commits {recent} "
            f"— update agent_state.json before ending session"
        )
        return c

    lag = recent.index(last_commit)
    c.ok(f"state at {last_commit} ({lag} commit(s) behind HEAD {head})")
    return c


def check_handoff_quality() -> Check:
    """Handoff message must be substantive — it's what a new session reads first"""
    c = Check("Handoff quality")

    state_path = REPO_ROOT / ".mosaic/agent_state.json"
    if not state_path.exists():
        c.fail("agent_state.json does not exist")
        return c

    state = json.loads(state_path.read_text())
    handoff = state.get("handoff_message", "")

    if not handoff:
        c.fail("handoff_message is empty — new session will have no context")
        return c

    if len(handoff) < 100:
        c.fail(
            f"handoff_message too short ({len(handoff)} chars) — "
            f"minimum 100 required for meaningful context"
        )
        return c

    c.ok(f"{len(handoff)} chars — substantive")
    return c


def check_current_task_defined() -> Check:
    """current_task must be defined so new session knows what to work on"""
    c = Check("Current task defined")

    state_path = REPO_ROOT / ".mosaic/agent_state.json"
    if not state_path.exists():
        c.fail("agent_state.json does not exist")
        return c

    state = json.loads(state_path.read_text())
    task = state.get("current_task", "")

    if not task or task.strip() == "":
        c.fail(
            "current_task is empty — new session won't know what to work on "
            "(acceptable only if project is fully idle)"
        )
        return c

    c.ok(f"task: {task[:60]}")
    return c


def check_ps101_architecture_current() -> Check:
    """SESSION_START_PS101.md must reflect 8-prompt architecture, not 10-step"""
    c = Check("PS101 architecture documentation")

    ps101_doc = REPO_ROOT / ".mosaic/SESSION_START_PS101.md"
    if not ps101_doc.exists():
        c.fail("SESSION_START_PS101.md not found")
        return c

    content = ps101_doc.read_text()

    required = [
        ("8 prompts", "v3 architecture spec"),
        ("Question 1 of 8", "correct UI label pattern"),
        ("ps101_simple_state", "correct state key"),
    ]

    # Note: deprecated patterns like "Step 1 of 10" appear in this doc as
    # negative examples (❌). Live site and Gate 13 enforce codebase cleanliness.
    # This check only verifies the v3 spec is documented.

    missing = [(kw, desc) for kw, desc in required if kw not in content]

    if missing:
        c.fail(
            f"Missing v3 markers: {[kw for kw, _ in missing]} "
            f"— documentation is stale"
        )
        return c

    c.ok("v3 (8-prompt) architecture confirmed in documentation")
    return c


def check_live_frontend_architecture() -> Check:
    """Live site must show 8-prompt architecture — confirms what new session inherits"""
    c = Check("Live frontend architecture")

    code, html, err = _run_shell(
        "curl -s --max-time 15 https://whatismydelta.com"
    )
    if code != 0 or not html:
        c.fail(f"Could not fetch live site (exit={code}): {err[:80]}")
        return c

    if "Question 1 of 8" not in html:
        c.fail("Live site missing 'Question 1 of 8' — v3 architecture not deployed")
        return c

    if "Step 1 of 10" in html:
        c.fail("Live site contains 'Step 1 of 10' — old architecture present (regression)")
        return c

    c.ok("live site shows 'Question 1 of 8' — v3 architecture confirmed")
    return c


def check_gate_13() -> Check:
    """Gate 13 must pass — it blocks old PS101 ghost code from entering"""
    c = Check("Gate 13 (no PS101 ghosts)")

    gate = REPO_ROOT / ".mosaic/enforcement/gate_13_no_ps101_ghosts.sh"
    if not gate.exists():
        c.fail("gate_13_no_ps101_ghosts.sh not found")
        return c

    code, stdout, stderr = _run_shell(str(gate))
    if code != 0:
        c.fail(f"Gate 13 FAIL (exit {code}) — ghost code detected")
        return c

    c.ok("no PS101 ghost code detected")
    return c


def check_e2e_receipt() -> Check:
    """E2E receipt must exist and be recent — proves functional tests were run"""
    c = Check("E2E receipt")

    if not E2E_RECEIPT_PATH.exists():
        c.fail(
            f"No E2E receipt at {E2E_RECEIPT_PATH} "
            f"— run test-ps101-simple-flow.js before starting new session"
        )
        return c

    try:
        receipt = json.loads(E2E_RECEIPT_PATH.read_text())
    except json.JSONDecodeError:
        c.fail("E2E receipt is not valid JSON")
        return c

    age = int(time.time()) - int(receipt.get("timestamp_utc", 0))

    if age > E2E_MAX_AGE_SECONDS:
        c.fail(
            f"E2E receipt is stale (age={age}s, max={E2E_MAX_AGE_SECONDS}s) "
            f"— re-run test-ps101-simple-flow.js"
        )
        return c

    if receipt.get("exit_code") != 0 or int(receipt.get("tests_failed", 1)) > 0:
        c.fail(
            f"E2E receipt shows failure: tests_failed={receipt.get('tests_failed')} "
            f"— fix E2E tests first"
        )
        return c

    c.ok(
        f"receipt age={age}s tests_passed={receipt.get('tests_passed')} "
        f"test={receipt.get('test_name')}"
    )
    return c


def write_session_start_receipt(checks: list) -> None:
    passed = sum(1 for c in checks if c.passed)
    receipt = {
        "timestamp_utc": int(time.time()),
        "test_name": "session-start-readiness",
        "checks_passed": passed,
        "checks_total": len(checks),
        "checks_failed": len(checks) - passed,
        "exit_code": 0,
        "detail": {c.name: {"ok": c.passed, "detail": c.detail} for c in checks}
    }
    RECEIPT_PATH.write_text(json.dumps(receipt, indent=2))
    print(f"\n📋 Session start receipt written: {RECEIPT_PATH}")


def main():
    print("🔍 SESSION START READINESS TEST")
    print("=" * 60)
    print()
    print("Checks that session context infrastructure is ready.")
    print("Replaces manual behavioral observation with machine verification.")
    print()

    checks = [
        check_git_head_matches_state,
        check_handoff_quality,
        check_current_task_defined,
        check_ps101_architecture_current,
        check_live_frontend_architecture,
        check_gate_13,
        check_e2e_receipt,
    ]

    results = []
    for check_fn in checks:
        results.append(check_fn())
        print()

    passed = [c for c in results if c.passed]
    failed = [c for c in results if not c.passed]

    print("=" * 60)
    print("📊 RESULTS")
    print("=" * 60)
    print(f"  Passed: {len(passed)} / {len(results)}")
    print(f"  Failed: {len(failed)} / {len(results)}")
    print()

    if failed:
        print("❌ SESSION START READINESS: FAIL")
        print()
        print("Failures (fix before ending session):")
        for c in failed:
            print(f"  - {c.name}: {c.detail}")
        print()
        print("A new session started now will lack correct context.")
        sys.exit(1)
    else:
        write_session_start_receipt(results)
        print("✅ SESSION START READINESS: PASS")
        print()
        print("A new session started now will have:")
        print("  - Current state files (not stale)")
        print("  - Substantive handoff message")
        print("  - Clear current task")
        print("  - Correct PS101 architecture documented")
        print("  - Live site confirmed on v3 architecture")
        print("  - Enforcement gates passing")
        print("  - Recent E2E test confirmation")
        sys.exit(0)


if __name__ == "__main__":
    main()
