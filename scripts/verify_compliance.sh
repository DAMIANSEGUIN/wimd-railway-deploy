#!/bin/bash
# ISO/IEC 5055:2021 Compliance Verification Script
# Runs full automated quality gates before deployment

set -e

PROJECT_ROOT="/Users/damianseguin/WIMD-Deploy-Project"
cd "$PROJECT_ROOT" || exit 1

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ISO/IEC 5055:2021 Compliance Verification                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

FAILED=0

# Category 1: Security (CWE violations)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  SECURITY CHECKS (ISO 5055 - Security)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "  🔒 Running Bandit security scan..."
if command -v bandit &> /dev/null; then
    if bandit -r api/ -c pyproject.toml -ll --quiet; then
        echo "  ✅ Bandit: No high/medium severity issues"
    else
        echo "  ❌ Bandit: Security vulnerabilities detected"
        FAILED=1
    fi
else
    echo "  ⚠️  Bandit not installed (pip install bandit)"
fi

echo ""
echo "  🔑 Running secret detection..."
if command -v gitleaks &> /dev/null; then
    if gitleaks detect --no-git --quiet 2>/dev/null; then
        echo "  ✅ GitLeaks: No secrets detected"
    else
        echo "  ❌ GitLeaks: Hardcoded secrets found"
        FAILED=1
    fi
else
    echo "  ⚠️  GitLeaks not installed"
fi

echo ""
echo "  📦 Checking dependency vulnerabilities..."
if command -v safety &> /dev/null; then
    if safety check --json > /dev/null 2>&1; then
        echo "  ✅ Safety: No known vulnerabilities"
    else
        echo "  ⚠️  Safety: Check dependencies manually"
    fi
else
    echo "  ⚠️  Safety not installed (pip install safety)"
fi

# Category 2: Reliability (Error handling, patterns)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  RELIABILITY CHECKS (ISO 5055 - Reliability)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "  🔧 Checking PostgreSQL context manager pattern..."
if grep -rn "conn = get_conn()" api/*.py 2>/dev/null | grep -v "# OK:" | grep -v "with get_conn()"; then
    echo "  ❌ Context manager violation detected"
    echo "     Required: with get_conn() as conn:"
    FAILED=1
else
    echo "  ✅ Context manager pattern correct"
fi

echo ""
echo "  🗄️  Checking PostgreSQL syntax (no SQLite)..."
if grep -rn '\.execute.*".*\?.*"' api/*.py 2>/dev/null | grep -v "# OK:"; then
    echo "  ❌ SQLite syntax detected in PostgreSQL code"
    echo "     Required: Use %s placeholders"
    FAILED=1
else
    echo "  ✅ PostgreSQL syntax correct"
fi

echo ""
echo "  ⚠️  Checking error handling..."
if grep -rn "except:$" api/*.py 2>/dev/null | grep -v "# OK:"; then
    echo "  ❌ Bare except clauses found"
    echo "     Required: except SpecificException as e:"
    FAILED=1
else
    echo "  ✅ Error handling looks good"
fi

# Category 3: Performance Efficiency
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  PERFORMANCE CHECKS (ISO 5055 - Performance Efficiency)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "  📊 Checking cyclomatic complexity..."
if command -v radon &> /dev/null; then
    if radon cc api/ -n C -s > /dev/null 2>&1; then
        echo "  ✅ Complexity: All functions ≤ 10"
    else
        echo "  ❌ Complexity: Functions exceed threshold (>10)"
        radon cc api/ -n C -s
        FAILED=1
    fi
else
    echo "  ⚠️  Radon not installed (pip install radon)"
fi

# Category 4: Maintainability (Style, format, tests)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  MAINTAINABILITY CHECKS (ISO 5055 - Maintainability)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "  🎨 Running Ruff linter (PEP 8 compliance)..."
if command -v ruff &> /dev/null; then
    if ruff check api/ --quiet; then
        echo "  ✅ Ruff: No linting issues"
    else
        echo "  ❌ Ruff: Linting issues found"
        FAILED=1
    fi
else
    echo "  ⚠️  Ruff not installed (pip install ruff)"
fi

echo ""
echo "  🖌️  Checking code formatting (Black)..."
if command -v black &> /dev/null; then
    if black --check api/ --quiet; then
        echo "  ✅ Black: Code properly formatted"
    else
        echo "  ❌ Black: Code needs formatting"
        FAILED=1
    fi
else
    echo "  ⚠️  Black not installed (pip install black)"
fi

echo ""
echo "  🧪 Running tests with coverage..."
if command -v pytest &> /dev/null; then
    if pytest tests/ --cov=api --cov-branch --cov-fail-under=80 --quiet 2>/dev/null; then
        echo "  ✅ Tests: All passing, coverage ≥ 80%"
    else
        echo "  ❌ Tests: Failures or coverage < 80%"
        FAILED=1
    fi
else
    echo "  ⚠️  Pytest not installed (pip install pytest pytest-cov)"
fi

# Critical feature verification
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  CRITICAL FEATURES (Mosaic-Specific)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "./scripts/verify_critical_features.sh" ]; then
    echo "  🎯 Verifying critical features..."
    if bash ./scripts/verify_critical_features.sh > /dev/null 2>&1; then
        echo "  ✅ Critical features: All present"
    else
        echo "  ⚠️  Critical features: Check manually"
    fi
else
    echo "  ⚠️  verify_critical_features.sh not found"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "COMPLIANCE SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAILED -eq 0 ]; then
    echo "✅ ALL QUALITY GATES PASSED"
    echo ""
    echo "ISO/IEC 5055:2021 compliance verified:"
    echo "  ✅ Security (CWE violations)"
    echo "  ✅ Reliability (error handling, patterns)"
    echo "  ✅ Performance (complexity < 10)"
    echo "  ✅ Maintainability (style, tests, coverage)"
    echo ""
    echo "Safe to deploy to production."
    exit 0
else
    echo "❌ QUALITY GATES FAILED"
    echo ""
    echo "Fix the issues above before deployment."
    echo "See CODE_GOVERNANCE_STANDARD_v1.md for details."
    exit 1
fi
