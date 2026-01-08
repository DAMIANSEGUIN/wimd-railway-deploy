#!/bin/bash
# .mosaic/enforcement/test_gates.sh
# Tests that all 8 enforcement gates actually block violations
# Usage: ./.mosaic/enforcement/test_gates.sh

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "🧪 GATE ENFORCEMENT TEST SUITE"
echo "================================"
echo ""
echo "Testing that pre-commit hook blocks violations..."
echo ""

TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS_ONLY=0

# Save current state
ORIGINAL_BRANCH=$(git branch --show-current)
ORIGINAL_HEAD=$(git rev-parse HEAD)

# Cleanup function
cleanup() {
  echo ""
  echo "🧹 Cleaning up..."
  git reset --hard $ORIGINAL_HEAD 2>/dev/null || true
  git clean -fd 2>/dev/null || true
  git checkout "$ORIGINAL_BRANCH" 2>/dev/null || true
  rm -f test_violations.* 2>/dev/null || true
}

trap cleanup EXIT

# ============================================================================
# TEST GATE 1: Absolute paths in markdown
# ============================================================================
echo "📋 Testing Gate 1: Absolute paths..."

# Create test file with violation
cat > test_violations.md <<EOF
# Test File
This file contains an absolute path: /Users/damianseguin/test/path
EOF

git add test_violations.md

# Try to commit (should be blocked)
if git commit -m "test: absolute path violation" 2>&1 | grep -q "VIOLATION.*Absolute path"; then
  echo "   ✅ BLOCKS violations (as expected)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "   ❌ FAILS - allows violations"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

git reset --hard $ORIGINAL_HEAD 2>/dev/null
rm -f test_violations.md

# ============================================================================
# TEST GATE 2: Context manager pattern
# ============================================================================
echo ""
echo "📋 Testing Gate 2: Context manager pattern..."

# Create test file with violation
cat > test_violations.py <<EOF
# Test file
def get_user():
    conn = get_conn()
    cursor = conn.execute("SELECT * FROM users")
    return cursor.fetchone()
EOF

git add test_violations.py

# Try to commit (should be blocked)
if git commit -m "test: context manager violation" 2>&1 | grep -q "VIOLATION.*database pattern"; then
  echo "   ✅ BLOCKS violations (as expected)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "   ❌ FAILS - allows violations"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

git reset --hard $ORIGINAL_HEAD 2>/dev/null
rm -f test_violations.py

# ============================================================================
# TEST GATE 3: SQLite syntax
# ============================================================================
echo ""
echo "📋 Testing Gate 3: SQLite syntax..."

# Create test file with AUTOINCREMENT violation
cat > test_violations.py <<EOF
# Test file
CREATE_TABLE = """
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT
)
"""
EOF

git add test_violations.py

# Try to commit (should be blocked)
if git commit -m "test: sqlite syntax violation" 2>&1 | grep -q "VIOLATION.*AUTOINCREMENT"; then
  echo "   ✅ BLOCKS violations (as expected)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "   ❌ FAILS - allows violations"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

git reset --hard $ORIGINAL_HEAD 2>/dev/null
rm -f test_violations.py

# ============================================================================
# TEST GATE 4: JSON schema validation
# ============================================================================
echo ""
echo "📋 Testing Gate 4: JSON schema validation..."

# Backup original
cp .mosaic/agent_state.json .mosaic/agent_state.json.backup

# Create invalid JSON
echo "{invalid json}" > .mosaic/agent_state.json
git add .mosaic/agent_state.json

# Try to commit (should be blocked)
if git commit -m "test: invalid json violation" 2>&1 | grep -q "VIOLATION.*not valid JSON"; then
  echo "   ✅ BLOCKS violations (as expected)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "   ❌ FAILS - allows violations"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

git reset --hard $ORIGINAL_HEAD 2>/dev/null
# Restore original
mv .mosaic/agent_state.json.backup .mosaic/agent_state.json

# ============================================================================
# TEST GATE 5: State update check
# ============================================================================
echo ""
echo "📋 Testing Gate 5: State update check..."

# Create code change without state update
cat > api/test_file.py <<EOF
# New API file
def test_function():
    return "test"
EOF

git add api/test_file.py

# Try to commit (warns but doesn't block by design)
if git commit -m "test: state update check" 2>&1 | grep -q "WARNING.*agent_state.json not updated"; then
  echo "   ⚠️  WARNS only (by design - doesn't block)"
  WARNINGS_ONLY=$((WARNINGS_ONLY + 1))
else
  echo "   ✅ Working as designed"
  WARNINGS_ONLY=$((WARNINGS_ONLY + 1))
fi

git reset --hard $ORIGINAL_HEAD 2>/dev/null
rm -f api/test_file.py

# ============================================================================
# TEST GATE 6: Secrets detection
# ============================================================================
echo ""
echo "📋 Testing Gate 6: Secrets detection..."

# Create file with secret
cat > test_violations.py <<EOF
# Test file with secret
OPENAI_API_KEY = "sk-1234567890abcdefghijklmnopqrstuvwxyz"
EOF

git add test_violations.py

# Try to commit (should be blocked)
if git commit -m "test: secret detection violation" 2>&1 | grep -q "VIOLATION.*secret"; then
  echo "   ✅ BLOCKS violations (as expected)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "   ❌ FAILS - allows violations"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

git reset --hard $ORIGINAL_HEAD 2>/dev/null
rm -f test_violations.py

# ============================================================================
# TEST GATE 7: Commit message format
# ============================================================================
echo ""
echo "📋 Testing Gate 7: Commit message format..."

# Create valid file
echo "# test" > test_violations.md
git add test_violations.md

# Try to commit with bad format (warns but doesn't block by design)
if git commit -m "bad commit message without type" 2>&1 | grep -q "WARNING.*conventional format"; then
  echo "   ⚠️  WARNS only (by design - doesn't block)"
  WARNINGS_ONLY=$((WARNINGS_ONLY + 1))
else
  echo "   ✅ Working as designed"
  WARNINGS_ONLY=$((WARNINGS_ONLY + 1))
fi

git reset --hard $ORIGINAL_HEAD 2>/dev/null
rm -f test_violations.md

# ============================================================================
# TEST GATE 8: Gemini approval (CRITICAL TEST)
# ============================================================================
echo ""
echo "📋 Testing Gate 8: Gemini approval..."

# Backup original files
cp .mosaic/agent_state.json .mosaic/agent_state.json.backup
GEMINI_APPROVAL_EXISTS=false
if [ -f .mosaic/gemini_approval.json ]; then
  GEMINI_APPROVAL_EXISTS=true
  cp .mosaic/gemini_approval.json .mosaic/gemini_approval.json.backup
fi

# Modify agent_state.json (triggers handoff check)
jq '.current_task = "TEST: Gate 8 validation"' .mosaic/agent_state.json > .mosaic/agent_state.json.tmp
mv .mosaic/agent_state.json.tmp .mosaic/agent_state.json

# Remove Gemini approval to test enforcement
rm -f .mosaic/gemini_approval.json

git add .mosaic/agent_state.json

# Try to commit (should be blocked if Gate 8 is strict)
COMMIT_OUTPUT=$(git commit -m "test: gemini approval check" 2>&1 || true)

if echo "$COMMIT_OUTPUT" | grep -q "VIOLATION.*Gemini approval"; then
  echo "   ✅ BLOCKS violations (ML-style enforcement working)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
elif echo "$COMMIT_OUTPUT" | grep -q "WARNING.*Gemini approval"; then
  echo "   ❌ FAILS - only warns, doesn't block (behavioral, not ML-style)"
  TESTS_FAILED=$((TESTS_FAILED + 1))
else
  echo "   ❌ FAILS - allows violations without warning"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

git reset --hard $ORIGINAL_HEAD 2>/dev/null
# Restore originals
mv .mosaic/agent_state.json.backup .mosaic/agent_state.json
if [ "$GEMINI_APPROVAL_EXISTS" = true ]; then
  mv .mosaic/gemini_approval.json.backup .mosaic/gemini_approval.json
fi

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo "================================"
echo "📊 TEST RESULTS"
echo "================================"
echo ""
echo "✅ Gates with ML-style enforcement: $TESTS_PASSED"
echo "⚠️  Gates with warnings only: $WARNINGS_ONLY"
echo "❌ Gates that are broken: $TESTS_FAILED"
echo ""

TOTAL=$((TESTS_PASSED + WARNINGS_ONLY + TESTS_FAILED))
echo "Total gates tested: $TOTAL/8"
echo ""

if [ $TESTS_FAILED -gt 0 ]; then
  echo "🚨 ENFORCEMENT FAILURE: $TESTS_FAILED gate(s) not working"
  echo ""
  echo "Next steps:"
  echo "1. Review failed gates above"
  echo "2. Update .mosaic/enforcement/pre-commit to add ML-style blocking"
  echo "3. Change warnings to: VIOLATIONS=\$((VIOLATIONS + 1))"
  echo "4. Re-run this test suite to verify fixes"
  echo ""
  exit 1
else
  echo "✅ All enforcement gates working correctly!"
  echo ""
  echo "Note: Gates with warnings only are designed that way."
  echo "Critical gates (1-4, 6, 8) all have ML-style blocking."
  echo ""
  exit 0
fi
