#!/bin/bash
# One-Shot Railway Deployment Script
# Deploys commit 799046f (Day 1 blocker fixes)

set -e  # Exit on any error

echo "========================================"
echo "Railway Deployment - Commit 799046f"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Step 1: Verifying current commit...${NC}"
CURRENT_COMMIT=$(git rev-parse HEAD)
TARGET_COMMIT="799046f065fa99eea8bfa59f91dfbff61e3772d3"

if [[ $CURRENT_COMMIT == $TARGET_COMMIT* ]]; then
    echo -e "${GREEN}✓ Currently on commit 799046f${NC}"
else
    echo -e "${YELLOW}⚠ Not on commit 799046f, checking out...${NC}"
    git checkout 799046f
fi

echo ""
echo -e "${YELLOW}Step 2: Checking Railway CLI authentication...${NC}"
if railway whoami > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Railway CLI authenticated${NC}"
    railway whoami
else
    echo -e "${RED}✗ Railway CLI not authenticated${NC}"
    echo "Please run: railway login"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 3: Verifying Railway project link...${NC}"
if railway status > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Linked to Railway project${NC}"
    railway status
else
    echo -e "${RED}✗ Not linked to Railway project${NC}"
    echo "Please run: railway link"
    echo "Then select:"
    echo "  - Project: wimd-career-coaching"
    echo "  - Service: what-is-my-delta-site"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 4: Pushing to Railway origin...${NC}"
echo "This will trigger Railway deployment via GitHub integration..."

# Push to origin main (Railway watches this)
git push origin HEAD:main

echo -e "${GREEN}✓ Pushed to origin/main${NC}"

echo ""
echo -e "${YELLOW}Step 5: Waiting for Railway to detect changes (30 seconds)...${NC}"
sleep 30

echo ""
echo -e "${YELLOW}Step 6: Checking deployment status...${NC}"
echo "If auto-deploy is configured, Railway should be building now."
echo "Check Railway dashboard: https://railway.app"

echo ""
echo -e "${GREEN}========================================"
echo "Deployment Triggered!"
echo "========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Monitor: railway logs"
echo "2. Wait 2-5 minutes for deployment to complete"
echo "3. Test schema version:"
echo "   curl https://whatismydelta.com/config | jq '.schemaVersion'"
echo "   (Should return: \"v2\")"
echo ""
echo "Full test suite: See POST_DEPLOYMENT_TESTING.md"
echo ""
