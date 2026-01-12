#!/bin/bash
# scripts/check_ci_status.sh - Check GitHub Actions workflow status
# Run this after pushing to detect failures early

set -euo pipefail

REPO="DAMIANSEGUIN/wimd-railway-deploy"
BRANCH="main"

echo "🔍 Checking GitHub Actions workflow status..."
echo ""

# Get the latest workflow runs via GitHub CLI
if command -v gh &> /dev/null; then
    echo "📋 Latest workflow runs:"
    gh run list --repo "$REPO" --branch "$BRANCH" --limit 3 --json conclusion,name,status,url,createdAt --jq '.[] | "[\(.conclusion // .status)] \(.name) - \(.url)"'

    echo ""
    echo "📊 Current workflow status:"

    # Check if any workflows are failing
    FAILING=$(gh run list --repo "$REPO" --branch "$BRANCH" --limit 1 --json conclusion --jq '.[0].conclusion' 2>/dev/null || echo "unknown")

    if [ "$FAILING" = "failure" ]; then
        echo "❌ Latest workflow FAILED"
        echo ""
        echo "View details:"
        gh run list --repo "$REPO" --branch "$BRANCH" --limit 1 --json url --jq '.[0].url'
        echo ""
        echo "To diagnose:"
        echo "  1. Check workflow logs in GitHub Actions"
        echo "  2. Run: ./scripts/diagnose_deployment.sh"
        echo "  3. If backend healthy but workflow fails → CI config issue"
        exit 1
    elif [ "$FAILING" = "success" ]; then
        echo "✅ Latest workflow PASSED"
        exit 0
    elif [ "$FAILING" = "in_progress" ]; then
        echo "⏳ Workflow in progress..."
        echo ""
        echo "Wait for completion, then run this script again"
        exit 0
    else
        echo "⚠️  Cannot determine workflow status"
        echo "   Install GitHub CLI: brew install gh"
        echo "   Then authenticate: gh auth login"
        exit 1
    fi
else
    echo "⚠️  GitHub CLI (gh) not installed"
    echo ""
    echo "To install: brew install gh"
    echo "Then authenticate: gh auth login"
    echo ""
    echo "Manual check: https://github.com/$REPO/actions"
    exit 1
fi
