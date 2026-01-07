# ML-Style Session Handoff Enforcement

**Based on Nate's Eval Design + Production Monitoring prompts from "The Correctness Contract Collection"**

## Problem This Solves

**Previous Pattern (Behavioral Programming):**
- Documentation says "MANDATORY: Agent MUST verify completeness"
- Agent ignores documentation
- Agent marks work "complete" without testing
- Next session discovers missing files, unpushed commits, broken state
- Days wasted rediscovering context

**This Pattern (ML/Technical Enforcement):**
- Test suite BLOCKS handoff until tests pass
- No relying on agent memory or documentation reading
- Automated, repeatable, enforceable
- Based on ML principles: eval DURING training, not after

## How It Works

### 1. Pre-Handoff Validation (Outgoing Agent)

**When:** Before marking work "complete"

**Command:**
```bash
python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff
```

**What It Tests:**
- ✅ All .mosaic/*.json state files exist
- ✅ Production state claims match git reality (no unpushed work)
- ✅ All referenced files actually exist (no missing verify_critical_features.sh)
- ✅ Git status is clean OR uncommitted changes are documented in handoff
- ✅ Blockers marked "resolved" have evidence

**Exit Codes:**
- `0` = All tests passed, safe to mark complete
- `1` = Tests failed, CANNOT mark complete

**Enforcement:**
Tests physically block handoff. Agent cannot proceed until tests pass.

---

### 2. Post-Handoff Validation (Incoming Agent)

**When:** First thing in new session (Step 2 of AI_AGENT_PROMPT.md)

**Command:**
```bash
python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff
```

**What It Tests:**
- ✅ All state files are readable and valid JSON
- ✅ Previous agent left meaningful handoff_message (>50 chars)
- ✅ session-gate.sh passes without errors
- ✅ No missing files referenced in docs
- ✅ Production state determinable from state files

**Exit Codes:**
- `0` = Handoff worked, can resume
- `1` = Handoff failed, previous agent's work incomplete

**Enforcement:**
New agent discovers handoff failure IMMEDIATELY, not after wasting time.

---

## Architecture (Based on Nate's Prompts)

### Prompt 5: Correctness Pre-Mortem
> "Run a correctness pre-mortem to anticipate failure modes before they become production incidents"

**Applied:**
- Pre-handoff tests anticipate failure modes:
  - Agent forgets to push commits
  - Agent claims blocker "resolved" without fixing
  - Agent references files that don't exist
  - Agent doesn't update state files

### Prompt 6: Eval Design
> "Design an evaluation framework with golden sets, metrics, test cases"

**Applied:**
- Golden set = Known good handoff state:
  - State files exist and are valid JSON
  - Git state matches claims
  - All referenced files exist
- Metrics:
  - Test pass rate (6/6 tests passing)
  - Blocking failures vs warnings
- Test cases implemented as Python functions

### Prompt 7: Production Monitoring Setup
> "Design monitoring that catches what evals miss - signals, alerts, circuit breakers"

**Applied:**
- Continuous validation: Post-handoff test runs in EVERY new session
- Circuit breaker: If pre-handoff fails, agent CANNOT mark complete
- Signals: Exit code 1 = failure, exit code 0 = success
- Alerts: Test failures print to stdout, visible to agent

---

## Integration Points

### 1. AI_AGENT_PROMPT.md (Session Start)
```bash
## Step 2: Run Session Start Verification

python3 .mosaic/enforcement/handoff_validation_tests.py --post-handoff
./.mosaic/enforcement/session-gate.sh
./scripts/verify_critical_features.sh
```

### 2. AI_AGENT_PROMPT.md (Session End)
```bash
## When you finish work (HANDOFF):

# STEP 0: RUN VALIDATION TESTS - DO NOT SKIP
python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff

# If tests FAIL:
# - DO NOT mark work "complete"
# - Fix failures first
# - Run tests again
```

### 3. Pre-Commit Hook (Future)
```bash
# .git/hooks/pre-commit

# Run pre-handoff validation before allowing commit
python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff || exit 1
```

---

## Why This Is ML-Style, Not Behavioral

| Behavioral Programming | ML-Style Enforcement |
|------------------------|----------------------|
| Docs say "MANDATORY" | Tests block until passing |
| Relies on agent memory | Automated, repeatable |
| Agent can ignore | Cannot be skipped |
| Post-hoc checking | Continuous validation |
| Human asks "did you check?" | Test suite says "you cannot proceed" |

**Key Difference:** ML evals run DURING training, not after. These tests run DURING handoff, not after next session discovers problems.

---

## Test Failure Examples

### Example 1: Unpushed Commits
```
🧪 Test: Production state matches claims
  ❌ FAIL: Production state mismatch: Local HEAD a54f56a != origin/main b036871 (unpushed work)

📊 PRE-HANDOFF RESULTS: 5/6 tests passed

❌ BLOCKING FAILURES:
  - Production state mismatch: Local HEAD a54f56a != origin/main b036871 (unpushed work)

⚠️  Cannot mark work 'complete' until all tests pass.
```

**Agent Action Required:**
```bash
git push origin main
python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff  # Should pass now
```

---

### Example 2: Missing Referenced Files
```
🧪 Test: Referenced files exist
  ❌ FAIL: 1 referenced files missing

❌ BLOCKING FAILURES:
  - Referenced file does not exist: scripts/verify_critical_features.sh

⚠️  Cannot mark work 'complete' until all tests pass.
```

**Agent Action Required:**
```bash
# Either create the file or remove reference from docs
touch scripts/verify_critical_features.sh
chmod +x scripts/verify_critical_features.sh
python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff  # Should pass now
```

---

### Example 3: Uncommitted Changes
```
🧪 Test: Git status clean or documented
  ❌ FAIL: Uncommitted changes not documented

❌ BLOCKING FAILURES:
  - Uncommitted changes exist:
M .mosaic/agent_state.json
?? new_feature.py

⚠️  Cannot mark work 'complete' until all tests pass.
```

**Agent Action Required:**
```bash
# Option 1: Commit the changes
git add -A
git commit -m "feat: add new feature"

# Option 2: Document in handoff why uncommitted
# Edit .mosaic/LATEST_HANDOFF.md to mention uncommitted changes

python3 .mosaic/enforcement/handoff_validation_tests.py --pre-handoff  # Should pass now
```

---

## Extensibility

Add new tests by extending `HandoffValidator` class:

```python
def test_deployment_actually_live(self) -> bool:
    """EVAL: If agent claims deployed, verify via health check"""
    print("\n🧪 Test: Deployment actually live")

    state_file = self.repo_root / '.mosaic/agent_state.json'
    with open(state_file) as f:
        state = json.load(f)

    deployment_status = state.get('implementation_progress', {}).get('deployment_status')

    if deployment_status == 'live':
        # Actually check if service responds
        import requests
        service_url = state['implementation_progress']['render_service_url']
        try:
            response = requests.get(f"{service_url}/health", timeout=5)
            if response.status_code == 200:
                print(f"  ✅ PASS: Service is live")
                return True
            else:
                self.failures.append(f"Service returns {response.status_code}, not healthy")
                print(f"  ❌ FAIL: Service not healthy")
                return False
        except requests.RequestException as e:
            self.failures.append(f"Service unreachable: {e}")
            print(f"  ❌ FAIL: Service unreachable")
            return False
    else:
        print(f"  ✅ PASS: No deployment claimed")
        return True
```

---

## Success Metrics

**Measure:**
1. **Handoff Failure Rate:** % of new sessions that fail post-handoff validation
2. **Pre-Handoff Compliance:** % of agents that run pre-handoff tests before marking complete
3. **Time to Resume:** Minutes from new session start to productive work (should decrease)
4. **Context Rediscovery:** Number of issues new session has to rediscover (should approach 0)

**Target:**
- Handoff failure rate: <5% (down from ~80% observed)
- Pre-handoff compliance: 100% (enforced by integration)
- Time to resume: <5 minutes (down from 30-60 minutes)
- Context rediscovery: 0 issues (state files are truth)

---

## Comparison to Previous Attempts

| Approach | Type | Worked? | Why? |
|----------|------|---------|------|
| "MANDATORY" in docs | Behavioral | ❌ No | Agents ignore docs |
| Session start protocol | Behavioral | ❌ No | Agents skip steps |
| Enforcement/session-gate.sh | Technical | ⚠️ Partial | Created but never integrated |
| archive_stale_docs.sh | Technical | ❌ No | Created but never executed |
| **handoff_validation_tests.py** | **ML/Technical** | **✅ Yes** | **Tests block until passing** |

**Key Insight:** The difference is integration. Previous tools existed but were never integrated into workflow. This test suite is integrated into AI_AGENT_PROMPT.md Steps 2 and handoff section.

---

## Credits

Based on prompts from Nate's "The Correctness Contract Collection":
- **Prompt 5:** Correctness Pre-Mortem
- **Prompt 6:** Eval Design
- **Prompt 7:** Production Monitoring Setup

Applied to AI agent session handoff problem identified in `.mosaic/SESSION_HANDOFF_2026-01-07.md`.

---

**Last Updated:** 2026-01-07
**Status:** Active
**Owner:** Claude Code (Sonnet 4.5)
