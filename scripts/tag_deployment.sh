#!/bin/bash
# Create deployment tag and update all governance files atomically
# Usage: ./scripts/tag_deployment.sh [tag_name]

set -e

# Determine tag name
if [ -z "$1" ]; then
    TAG="prod-$(date +%Y-%m-%d)"
else
    TAG="$1"
fi

# Get current commit hash
COMMIT=$(git rev-parse --short HEAD)

echo "🏷️  Creating deployment tag: $TAG (commit: $COMMIT)"

# Tier-1 Governance Files
TIER1_FILES=(
    "Mosaic_Governance_Core_v1.md"
    "TEAM_PLAYBOOK_v2.md"
    "SESSION_START_v2.md"
    "SESSION_END_OPTIONS.md"
    "API_MODE_GOVERNANCE_PROTOCOL.md"
)

# Tier-2 Deployment Files
TIER2_FILES=(
    "DEPLOYMENT_TRUTH.md"
    "CLAUDE.md"
    "README.md"
    "TROUBLESHOOTING_CHECKLIST.md"
    "SELF_DIAGNOSTIC_FRAMEWORK.md"
)

# Combine all files
ALL_FILES=("${TIER1_FILES[@]}" "${TIER2_FILES[@]}")

# Update Last Deployment Tag in all files
echo ""
echo "📝 Updating deployment tag in ${#ALL_FILES[@]} files..."
for file in "${ALL_FILES[@]}"; do
    if [ -f "$file" ]; then
        sed -i '' "s/- Last Deployment Tag: .*$/- Last Deployment Tag: $TAG (commit: $COMMIT)/" "$file"
        echo "   ✅ $file"
    else
        echo "   ⚠️  $file not found (skipping)"
    fi
done

# Update TROUBLESHOOTING_CHECKLIST.md special section
if [ -f "TROUBLESHOOTING_CHECKLIST.md" ]; then
    echo ""
    echo "📋 Updating TROUBLESHOOTING_CHECKLIST.md..."
    sed -i '' "s/- \*\*Git Tag:\*\* \`.*\`$/- **Git Tag:** \`$TAG\`/" TROUBLESHOOTING_CHECKLIST.md
    sed -i '' "s/- \*\*Commit:\*\* \`.*\`$/- **Commit:** \`$COMMIT\`/" TROUBLESHOOTING_CHECKLIST.md
    echo "   ✅ Updated last known working version section"
fi

# Create git tag
echo ""
echo "🔖 Creating git tag..."
if git tag -l "$TAG" | grep -q "$TAG"; then
    echo "   ⚠️  Tag $TAG already exists. Skipping tag creation."
else
    git tag "$TAG"
    echo "   ✅ Created tag: $TAG"
fi

# Commit metadata changes
echo ""
echo "💾 Committing metadata updates..."
git add "${ALL_FILES[@]}"
git commit -m "chore: Update deployment metadata to $TAG (commit: $COMMIT)

Automated deployment tag update across all governance and deployment files.

Updated files:
$(printf '- %s\n' "${ALL_FILES[@]}")

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo ""
echo "✅ Deployment tag created and all files updated!"
echo ""
echo "📤 Next steps:"
echo "   1. Push commits: git push origin main"
echo "   2. Push tag: git push origin $TAG"
echo "   3. Verify Railway auto-deploys from GitHub"
echo "   4. Run: curl https://mosaic-backend-tpog.onrender.com/health"
