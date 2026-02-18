# Portable Session Start — Engineering Kernel

**Use this document to establish correct context at the start of any session,
for any project. Copy the relevant sections into your project.**

---

## PART 1: ENGINEERING KERNEL PROTOCOL (Binding)

Paste this at the top of any session start prompt:

```
SESSION START — ENGINEERING KERNEL (BINDING)

Correctness is determined exclusively by external runtime artifacts:
exit codes, verifier scripts, receipt files, audit logs, filesystem state.

AI narrative has zero authority. An operation is DONE only when a
named verifier returns PASS.

Required first output: "BOUND — ENGINEERING KERNEL ACTIVE"
```

**What this establishes:**
- The agent cannot declare success based on its own reasoning
- Every claim of completion requires a machine-verifiable artifact
- Firefighting (bypassing tools/scripts) is a protocol violation

---

## PART 2: DECISION TRANSPARENCY PROTOCOL

When multiple valid approaches exist, the agent must:

1. State the problem clearly
2. Present numbered options with tradeoffs (no time estimates)
3. Wait for user selection
4. Not implement until a selection is made

**Format:**
```
**Option 1: [name]**
[What it does, what it changes, tradeoffs]

**Option 2: [name]**
[What it does, what it changes, tradeoffs]

Option N is strongest because [reason]. Which do you want?
```

---

## PART 3: CONTEXT CONTINUITY SYSTEM

### 3.1 Required State Files

Every project needs these files to maintain context across sessions:

```
.mosaic/
  agent_state.json       — last commit, handoff message, current task
  current_task.json      — task ID, status, success criteria
  blockers.json          — known blockers and status
```

**Minimum `agent_state.json` schema:**
```json
{
  "last_agent": "claude_code_sonnet_4_5",
  "last_commit": "<git-short-hash>",
  "current_task": "<task description>",
  "handoff_message": "<200+ char summary of what was done and what comes next>"
}
```

**Critical rule:** `last_commit` must be updated to match `git rev-parse --short HEAD`
before ending every session. Stale state = wrong context for next session.

### 3.2 Session End Checklist

Before ending any session:

```
□ Update agent_state.json last_commit to current HEAD
□ Write substantive handoff_message (200+ chars, describes what was done and what comes next)
□ All tests passing
□ All changes committed
□ Verifier returns PASS
```

### 3.3 Session Start Checklist

At the start of any session:

```
□ Read state files (agent_state.json, current_task.json)
□ Confirm last_commit matches git HEAD (stale = wrong context)
□ Read handoff_message to understand prior work
□ Run enforcement gates before touching any code
□ Run E2E tests if functional work is planned
```

---

## PART 4: GATE SYSTEM

Gates are machine-executable scripts that block deployment if invariants
are violated. They encode what is non-negotiable.

### 4.1 Gate Categories

| Gate | When | Blocks |
|------|------|--------|
| Pre-commit | Every commit | Code pattern violations |
| Pre-push | Before push | Architectural violations, failed tests |
| Pre-deploy | Before deploy | Contract violations, missing receipts |
| Post-deploy | After deploy | Production smoke test failures |

### 4.2 Gate Anatomy (Template)

```python
#!/usr/bin/env python3
"""
Gate N: [Name]
Blocks [what it prevents]
Exit 0 = PASS, Exit 1 = FAIL
"""
import sys

def check_[invariant]() -> tuple[bool, str]:
    # Check the invariant
    # Return (passed, detail)
    pass

def main():
    checks = [check_[invariant]]
    violations = []

    for check in checks:
        passed, detail = check()
        if not passed:
            violations.append(detail)

    if violations:
        print(f"❌ Gate FAILED: {len(violations)} violations")
        for v in violations: print(f"  {v}")
        sys.exit(1)

    print("✅ Gate PASSED")
    sys.exit(0)

if __name__ == '__main__':
    main()
```

### 4.3 Receipt Pattern

**Principle:** A gate that produces a receipt cannot be bypassed upstream.

```python
# Producer (test/gate writes receipt on PASS)
import json, time
receipt = {
    "timestamp_utc": int(time.time()),
    "test_name": "my-test",
    "tests_passed": N,
    "tests_failed": 0,
    "exit_code": 0
}
open("/tmp/my_receipt.json", "w").write(json.dumps(receipt))

# Consumer (verifier reads receipt before proceeding)
import time, sys
try:
    receipt = json.load(open("/tmp/my_receipt.json"))
    age = int(time.time()) - receipt["timestamp_utc"]
    if age > 1800:  # 30 min max
        print("FAIL: receipt stale"); sys.exit(1)
    if receipt["exit_code"] != 0:
        print("FAIL: receipt shows failure"); sys.exit(1)
except FileNotFoundError:
    print("FAIL: no receipt — run the test first"); sys.exit(1)
```

**Effect:** Verifier cannot PASS without the test having run successfully
within the time window. Bypassing the test leaves no receipt → verifier fails.

---

## PART 5: GOOD CODING PRACTICES (Enforced)

### 5.1 Check Before Act

```
# WRONG: creating without checking
create_file("output.txt")

# CORRECT: check if it exists or if similar solution already exists
if not Path("output.txt").exists():
    create_file("output.txt")
```

Applies to: installing tools, creating files, writing functions, adding tests.
Always verify current state before acting on assumed state.

### 5.2 Prefer Extend Over Create

```
Decision tree for any new addition:
  Does exact solution exist?     → Use it (no changes)
  Does similar solution exist?   → Extend it
  No existing solution?          → Create new (document why)
```

### 5.3 No Firefighting

Firefighting = bypassing the established tool/script/process to get a faster result.

Examples:
- `netlify deploy --prod` instead of `./scripts/deploy.sh netlify`
- `git push --force` instead of understanding why push was rejected
- Declaring PASS based on reasoning instead of running the verifier

Firefighting produces the right short-term result with the wrong long-term pattern.

### 5.4 Wrapper Scripts Are the Interface

Wrap all deployment operations in scripts that enforce verification:
```bash
# scripts/deploy.sh
#!/bin/bash
./scripts/pre_deploy_check.sh || exit 1
netlify deploy --prod --dir frontend
./scripts/post_deploy_verify.sh || { echo "DEPLOY FAILED POST-CHECK"; exit 1; }
```

The wrapper is the contract. Direct CLI is the bypass.

---

## PART 6: SESSION START READINESS TEST (Template)

For any project, adapt this test to verify readiness before starting a new session:

```python
#!/usr/bin/env python3
"""
Session Start Readiness Test
Machine-verifiable: are the conditions right for a new session to start correctly?
Exit 0 = PASS, Exit 1 = FAIL (with specific reason)
"""
import json, subprocess, sys, time
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent

def check_state_currency():
    """State files must match git HEAD"""
    head = subprocess.check_output(
        ["git", "rev-parse", "--short", "HEAD"], cwd=REPO_ROOT
    ).decode().strip()
    state = json.loads((REPO_ROOT / ".mosaic/agent_state.json").read_text())
    last = state.get("last_commit", "")
    if last != head:
        return False, f"STALE: state={last} HEAD={head} — update before ending session"
    return True, f"current at {head}"

def check_handoff_quality():
    """Handoff must be substantive"""
    state = json.loads((REPO_ROOT / ".mosaic/agent_state.json").read_text())
    msg = state.get("handoff_message", "")
    if len(msg) < 100:
        return False, f"handoff too short ({len(msg)} chars, min 100)"
    return True, f"{len(msg)} chars"

def check_e2e_receipt(receipt_path="/tmp/e2e_receipt.json", max_age=1800):
    """E2E test must have been run recently"""
    try:
        r = json.loads(open(receipt_path).read())
        age = int(time.time()) - r["timestamp_utc"]
        if age > max_age:
            return False, f"stale ({age}s > {max_age}s)"
        if r.get("exit_code") != 0:
            return False, "receipt shows failure"
        return True, f"age={age}s passed={r.get('tests_passed')}"
    except FileNotFoundError:
        return False, f"no receipt at {receipt_path}"

def main():
    checks = [
        ("State file currency", check_state_currency),
        ("Handoff quality", check_handoff_quality),
        ("E2E receipt", check_e2e_receipt),
        # Add project-specific checks here
    ]

    failed = []
    for name, fn in checks:
        ok, detail = fn()
        status = "✅" if ok else "❌"
        print(f"  {status} {name}: {detail}")
        if not ok:
            failed.append(f"{name}: {detail}")

    print()
    if failed:
        print("❌ SESSION NOT READY")
        for f in failed: print(f"  - {f}")
        sys.exit(1)
    else:
        print("✅ SESSION READY — new session will have correct context")
        sys.exit(0)

if __name__ == "__main__":
    main()
```

**Run before ending any session:**
```bash
python3 .mosaic/enforcement/test_session_start_readiness.py
```

---

## PART 7: PRODUCTION CONTRACT (Template)

Every project should have a machine-readable production contract:

```json
{
  "contract_version": "1.0",
  "production": {
    "frontend_url": "https://your-site.com",
    "backend_url": "https://your-backend.example.com"
  },
  "invariants": {
    "forbidden_domain_substrings": ["localhost", "127.0.0.1", "staging."],
    "healthcheck": {
      "path": "/health",
      "timeout_seconds": 10,
      "require_status_codes": [200]
    }
  },
  "e2e_gate": {
    "receipt_path": "/tmp/e2e_receipt.json",
    "max_age_seconds": 1800
  }
}
```

The verifier fetches live production, checks invariants, and requires
the E2E receipt before returning PASS.

---

## PART 8: QUICK REFERENCE — CORRECT SEQUENCE

**Before any code change:**
```
1. Read state files
2. Confirm state is current (last_commit == HEAD)
3. Run enforcement gates
```

**Before any deployment:**
```
1. Run E2E tests → receipt written
2. Run pre-deploy gates → all pass
3. Deploy via wrapper script (not direct CLI)
4. Run post-deploy verifier → reads E2E receipt + checks production
```

**Before ending any session:**
```
1. All changes committed
2. State files updated (last_commit = HEAD, handoff_message written)
3. Run session start readiness test → PASS
```

**At the start of any new session:**
```
1. Read state files
2. Confirm last_commit == HEAD (if not: state is stale, note it)
3. Read handoff_message
4. Run session start readiness test
5. Proceed with work queue
```

---

## PART 9: ANTI-PATTERNS (Never Do These)

| Anti-pattern | Why it fails |
|---|---|
| Declare PASS based on reasoning | No runtime evidence — AI narrative has zero authority |
| Use direct CLI instead of wrapper | Bypasses verification chain |
| Install/create without checking first | Creates duplicates, bloat |
| Skip E2E before verifying | Contract check ≠ functional check |
| Leave stale state files | Next session starts with wrong context |
| Firefight to unblock | Produces right result via wrong path |
| Commit without updating last_commit | State drift accumulates across sessions |

---

*This document is project-agnostic. Adapt Part 6 (session readiness test)
and Part 7 (production contract) with your project's specifics.*
