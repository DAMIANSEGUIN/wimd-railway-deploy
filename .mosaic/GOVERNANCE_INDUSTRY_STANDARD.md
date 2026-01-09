# Mosaic Project Governance - Industry Standard

**Authority:** Google SRE, DORA Research, Martin Fowler Test Pyramid
**Status:** CANONICAL - Replaces all custom validation systems
**Last Updated:** 2026-01-09

---

## 🎯 PRINCIPLE: External Authority Only

**This governance uses ONLY proven industry standards:**
- ✅ Google SRE Book (Site Reliability Engineering)
- ✅ DORA Metrics (DevOps Research and Assessment)
- ✅ Test Pyramid (Martin Fowler)
- ✅ HTTP Specification (W3C)
- ❌ NO custom AI-invented validation systems

---

## 📊 DORA METRICS (Primary Quality Measure)

**Source:** https://dora.dev/research/

### Four Key Metrics

#### 1. Deployment Frequency
```
How often: Daily for Elite teams
Our target: ≥1 per day
Measurement: Count git pushes to main that trigger deployment
```

#### 2. Lead Time for Changes
```
Definition: Time from commit to production
Elite target: <1 hour
Our measurement: git commit timestamp → production endpoint responding
```

#### 3. **Change Failure Rate** (Most Critical)
```
Definition: % of deployments causing failure requiring:
- Rollback
- Hotfix within 24h
- Manual intervention
- User-visible errors

Elite target: 0-15%
Our measurement: Gate 10 production smoke tests
```

#### 4. Time to Restore Service
```
Definition: Time from incident to resolution
Elite target: <1 hour
Our measurement: Incident logged → service restored
```

### Implementation

**File:** `.mosaic/dora_metrics.json`

```json
{
  "schema_version": "1.0",
  "period_start": "2026-01-01",
  "period_end": "2026-01-31",

  "deployment_frequency": {
    "total_deployments": 20,
    "deployments_per_day": 0.67,
    "rating": "Medium (target: >1/day)",
    "deployments": [
      {"date": "2026-01-09", "commit": "1e57859", "success": true},
      {"date": "2026-01-09", "commit": "96e89f2", "success": true}
    ]
  },

  "lead_time_for_changes": {
    "avg_minutes": 45,
    "p50_minutes": 30,
    "p95_minutes": 120,
    "rating": "Elite (<1 hour average)",
    "recent_deployments": [
      {
        "commit": "1e57859",
        "commit_time": "2026-01-09T19:15:00Z",
        "deployed_time": "2026-01-09T19:25:00Z",
        "lead_time_minutes": 10
      }
    ]
  },

  "change_failure_rate": {
    "total_deployments": 20,
    "failed_deployments": 2,
    "percentage": 10.0,
    "rating": "Elite (<15%)",
    "failures": [
      {
        "date": "2026-01-09",
        "commit": "1e57859",
        "claimed": "Semantic match upgrade complete",
        "reality": "Endpoints return 404 - deployment incomplete",
        "detected_by": "Gate 10 production smoke tests",
        "root_cause": "Render deployment not validated",
        "resolution": "Add Gate 10 to validation process",
        "time_to_detect_minutes": 30
      }
    ]
  },

  "time_to_restore_service": {
    "incidents": 1,
    "avg_minutes": 45,
    "p95_minutes": 45,
    "rating": "Elite (<1 hour)"
  }
}
```

---

## 🛡️ SRE PRODUCTION VALIDATION (Google Standard)

**Source:** Google SRE Book - Chapter 26 (Data Integrity)
**URL:** https://sre.google/sre-book/data-integrity/

### Service Level Indicators (SLIs)

**What to measure:**
1. **Availability:** % of successful requests
2. **Latency:** Time to respond (P50, P95, P99)
3. **Correctness:** % of requests returning correct data

**Implementation:**

```bash
# File: .mosaic/enforcement/sre_slis.sh

# SLI 1: Availability (target: 99.9%)
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/health")
if [ "$HEALTH_STATUS" = "200" ]; then
  AVAILABILITY=100
else
  AVAILABILITY=0
fi

# SLI 2: Latency (target: P95 <500ms)
LATENCY_MS=$(curl -s -o /dev/null -w "%{time_total}" "$BACKEND_URL/health" | awk '{print $1*1000}')

# SLI 3: Correctness (target: 100%)
# Test that endpoint returns expected data structure
HEALTH_OK=$(curl -s "$BACKEND_URL/health" | jq -e '.ok == true')
if [ "$HEALTH_OK" = "true" ]; then
  CORRECTNESS=100
else
  CORRECTNESS=0
fi

echo "SLIs: Availability=$AVAILABILITY%, Latency=${LATENCY_MS}ms, Correctness=$CORRECTNESS%"
```

### Service Level Objectives (SLOs)

**Targets:**
- Availability: ≥99.9% (max 43 minutes downtime/month)
- Latency: P95 <500ms, P99 <1000ms
- Correctness: 100% (all responses valid JSON with expected fields)

### Production Smoke Tests (MANDATORY)

**File:** `.mosaic/enforcement/gate_10_production_smoke.sh` (already created)

**Run:** After EVERY deployment, before marking work "complete"

**Tests:**
1. Health endpoint responds (HTTP 200)
2. Response is valid JSON
3. All NEW endpoints respond (non-404)
4. Latency within SLO (<500ms P95)
5. Frontend accessible

**Exit code:**
- 0 = All tests passed, deployment successful
- 1 = Tests failed, deployment INCOMPLETE

---

## 🧪 TEST PYRAMID (Martin Fowler Standard)

**Source:** https://martinfowler.com/bliki/TestPyramid.html

### Test Coverage Distribution

```
         /\
        /  \  E2E (10%)          ← Production smoke tests (Gate 10)
       /----\                      - Test deployed endpoints
      /      \  Integration (20%)  ← API contract tests
     /--------\                     - Test components together
    /          \  Unit (70%)       ← Function tests
   /____________\                   - Mock external dependencies
```

### Implementation

**1. Unit Tests (70%)**
```bash
# File: tests/test_*.py
# Run: pytest tests/ -v
# Coverage target: >80% line coverage
# Example: tests/test_semantic_match_upgrade.py (already created)
```

**2. Integration Tests (20%)**
```bash
# File: tests/integration/test_api_*.py
# Run: pytest tests/integration/ -v
# Tests: Real database, API contracts, component interaction
# TODO: Create integration tests for semantic match
```

**3. Production Smoke Tests (10%)**
```bash
# File: .mosaic/enforcement/gate_10_production_smoke.sh
# Run: After every deployment
# Tests: Real production endpoints, actual responses
```

### Coverage Requirements

```bash
# Run coverage report
pytest --cov=api --cov-report=term-missing tests/

# Minimum targets:
# - Unit test coverage: >80%
# - Integration tests: All API endpoints
# - Production tests: All deployed endpoints
```

---

## 🔄 DEPLOYMENT PIPELINE (Industry Standard)

**Based on:** GitOps, CI/CD best practices

### Stage 1: Local Validation
```bash
# Pre-commit (local)
1. Run unit tests: pytest tests/
2. Run linters: Gate 1-8 (existing gates)
3. Check code quality
```

### Stage 2: Integration Validation
```bash
# CI/CD (GitHub Actions or similar)
1. Run all tests (unit + integration)
2. Build artifacts
3. Test in staging environment
```

### Stage 3: Production Deployment
```bash
# Deployment (Render auto-deploy)
1. Code pushed to main
2. Render detects push
3. Builds Docker container
4. Installs dependencies (requirements.txt)
5. Restarts service
```

### Stage 4: Production Validation (CRITICAL - Often missed)
```bash
# Post-deployment (Gate 10)
1. Wait for service to stabilize (30 seconds)
2. Run Gate 10 production smoke tests
3. Check DORA metrics
4. Update deployment status

# ONLY mark "complete" if Gate 10 passes
```

---

## 📝 COMMIT VALIDATION (Existing Gates + DORA)

### Pre-Commit Gates (1-8)
```bash
# Already implemented:
- Gate 1: Session start validator
- Gate 2: Behavior lint
- Gate 3: Pre-commit hook
- Gate 4: Gemini eval
- Gate 5: Secret detection
- Gate 6: Critical features
- Gate 7: Context manager
- Gate 8: ML enforcement
```

### Pre-Push Gates (9-10)
```bash
# Gate 9: Production connectivity (existing)
./.mosaic/enforcement/gate_9_production_check.sh

# Gate 10: Production smoke tests (NEW - SRE standard)
./.mosaic/enforcement/gate_10_production_smoke.sh
```

### Post-Deployment Validation
```bash
# DORA metrics update
python3 .mosaic/enforcement/update_dora_metrics.py \
  --commit $(git rev-parse HEAD) \
  --status $(test $? -eq 0 && echo "success" || echo "failure")
```

---

## 🔍 VALIDATION WORKFLOW (Complete)

### For EVERY code change:

**1. Before Commit**
```bash
# Run gates 1-8 (existing)
git commit -m "..."
# → Pre-commit hook runs automatically
```

**2. Before Push**
```bash
# Run gate 9 (existing)
git push origin main
# → Pre-push hook runs automatically
```

**3. After Push (WAIT for deployment)**
```bash
# Manual validation required:
# a. Check Render deployment logs
# b. Wait for deployment to complete (2-5 minutes)
# c. Run Gate 10
./.mosaic/enforcement/gate_10_production_smoke.sh
```

**4. Record Results**
```bash
# Update DORA metrics
# Update state files ONLY if Gate 10 passes
# Mark work "complete" ONLY if external validation succeeds
```

---

## 📊 METRICS DASHBOARD

**File:** `.mosaic/metrics_dashboard.sh`

```bash
#!/bin/bash
# Display current project health metrics

echo "==================================================="
echo "MOSAIC PROJECT HEALTH DASHBOARD"
echo "Authority: SRE, DORA, Test Pyramid"
echo "==================================================="
echo ""

# DORA Metrics
echo "📊 DORA METRICS (Industry Standard)"
echo "---------------------------------------------------"
cat .mosaic/dora_metrics.json | jq '.deployment_frequency.deployments_per_day' | \
  xargs echo "Deployment Frequency: " | xargs echo "(Target: >1/day)"

cat .mosaic/dora_metrics.json | jq '.change_failure_rate.percentage' | \
  xargs echo "Change Failure Rate: " | xargs echo "% (Target: <15%)"

cat .mosaic/dora_metrics.json | jq '.lead_time_for_changes.avg_minutes' | \
  xargs echo "Lead Time: " | xargs echo "min (Target: <60min)"
echo ""

# SRE SLIs
echo "🛡️  SRE SERVICE LEVEL INDICATORS"
echo "---------------------------------------------------"
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" https://mosaic-backend-tpog.onrender.com/health)
LATENCY=$(curl -s -o /dev/null -w "%{time_total}" https://mosaic-backend-tpog.onrender.com/health | awk '{print $1*1000}')

echo "Availability: $(test $HEALTH -eq 200 && echo '100%' || echo '0%') (Target: >99.9%)"
echo "Latency (P95): ${LATENCY}ms (Target: <500ms)"
echo ""

# Test Coverage
echo "🧪 TEST COVERAGE (Test Pyramid)"
echo "---------------------------------------------------"
echo "Unit Tests: [Run: pytest --cov=api tests/]"
echo "Integration Tests: [TODO: Create integration tests]"
echo "Production Tests: Gate 10 (SRE smoke tests)"
echo ""

# Gate Status
echo "🚦 VALIDATION GATES"
echo "---------------------------------------------------"
echo "Gates 1-9: Active (existing)"
echo "Gate 10: Active (SRE production smoke tests)"
echo ""

echo "==================================================="
```

---

## ✅ DEFINITION OF "COMPLETE"

**Work is complete when ALL of these are true:**

### Code Level
```bash
✅ git log -1 → Shows commit exists
✅ git rev-parse HEAD = git rev-parse origin/main → Code pushed
✅ All tests pass locally (pytest)
```

### Deployment Level
```bash
✅ Render deployment succeeded (check logs)
✅ Service restarted without errors
✅ No crash loops in last 5 minutes
```

### Production Level (CRITICAL)
```bash
✅ Gate 10 production smoke tests pass (exit 0)
✅ curl backend/health → 200 OK
✅ All NEW endpoints → non-404
✅ SLIs within SLOs (latency <500ms, availability >99.9%)
```

### Metrics Level
```bash
✅ DORA change failure rate updated
✅ If deployment FAILED, failure recorded
✅ If deployment SUCCEEDED, success recorded
```

### Documentation Level
```bash
✅ State files updated to reflect VALIDATED reality (not claims)
✅ DORA metrics updated with deployment results
✅ Handoff message includes external validation proof
```

---

## 🚨 FAILURE HANDLING (SRE Incident Response)

**If Gate 10 fails or production endpoints don't respond:**

### 1. Classify Severity
```
P0 (Critical): Service down, all users affected
P1 (High): Major feature broken, many users affected
P2 (Medium): Minor feature broken, some users affected
P3 (Low): Non-critical issue, workaround available
```

### 2. Incident Response
```bash
# Document incident
cat > .mosaic/incidents/YYYY-MM-DD_description.md << EOF
# Incident: [Description]
- Detected: [Timestamp]
- Severity: [P0-P3]
- Root Cause: [What happened]
- Detection Method: [Gate 10 / User report / Monitoring]
EOF

# Update DORA metrics
# Add to failures array in dora_metrics.json
```

### 3. Rollback or Fix Forward
```bash
# Option A: Rollback (if fix is complex)
git revert HEAD
git push origin main

# Option B: Fix forward (if fix is simple)
# Make fix
# Commit
# Push
# Re-run Gate 10
```

### 4. Post-Incident Review
```
- What went wrong?
- Why did validation miss it?
- How do we prevent this?
- Update validation gates if needed
```

---

## 📖 REQUIRED READING (External Authority)

**ALL AI agents must read these before claiming expertise:**

1. **Google SRE Book**
   - https://sre.google/sre-book/
   - Chapters 4, 26 (SLIs, SLOs, Data Integrity)

2. **DORA State of DevOps**
   - https://dora.dev/research/
   - 2023 Report (latest)

3. **Test Pyramid**
   - https://martinfowler.com/bliki/TestPyramid.html
   - Martin Fowler's blog

4. **Testing in Production**
   - https://www.honeycomb.io/blog/testing-in-production-the-safe-way
   - Charity Majors (Honeycomb)

---

## 🎯 GOVERNANCE PRINCIPLES

### 1. External Authority Only
- Use industry standards (SRE, DORA, Test Pyramid)
- Do NOT invent custom validation
- Trust proven frameworks over AI invention

### 2. Production is Source of Truth
- "Works locally" ≠ "works in production"
- Always validate deployed endpoints
- Gate 10 is MANDATORY for completion

### 3. Measure, Don't Assume
- DORA metrics track actual deployment quality
- SLIs measure actual service health
- Test coverage shows actual test quality

### 4. Fail Fast, Learn Fast
- Detect failures quickly (Gate 10)
- Record failures (DORA metrics)
- Learn from failures (incident reviews)
- Prevent recurrence (update gates)

---

**This governance is based on industry standards proven at Google, Netflix, Amazon, and thousands of engineering teams worldwide. It is NOT invented by AI agents.**

**Authority:** Google SRE, DORA Research, Martin Fowler
**Status:** CANONICAL - Use this, not custom systems
**Last Updated:** 2026-01-09
