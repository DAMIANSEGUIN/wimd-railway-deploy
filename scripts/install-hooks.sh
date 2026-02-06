#!/bin/bash
# Install git hooks for enforcement
# Run this after cloning the repository

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "Installing git hooks..."

# Install pre-push hook
if [ -f "scripts/pre-push.hook" ]; then
    cp scripts/pre-push.hook .git/hooks/pre-push
    chmod +x .git/hooks/pre-push
    echo "✅ Installed pre-push hook (runs Playwright tests)"
else
    echo "❌ scripts/pre-push.hook not found"
    exit 1
fi

echo ""
echo "✅ Git hooks installed successfully"
echo ""
echo "The pre-push hook will:"
echo "  - Check production health (Gate 9)"
echo "  - Run Playwright E2E tests (BLOCKING)"
echo "  - Prevent push if tests fail"
echo ""
echo "To bypass in emergency: git push --no-verify"
