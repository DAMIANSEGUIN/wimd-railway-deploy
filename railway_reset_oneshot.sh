#!/bin/bash
set -e  # Exit on any error

# Railway Reset One-Shot Script
# Created: 2025-12-14
# Purpose: Clean up old Railway service and create new canonical service

PROJECT_DIR="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
cd "$PROJECT_DIR"

echo "========================================="
echo "Railway Reset - One-Shot Execution"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Confirm current state
echo -e "${YELLOW}Step 1: Confirming current Railway state...${NC}"
railway status --json > /tmp/railway_status_before.json
echo "✅ Current state saved to /tmp/railway_status_before.json"
echo ""

# Step 2: Verify PostgreSQL is separate service
echo -e "${YELLOW}Step 2: Verifying PostgreSQL service scope...${NC}"
POSTGRES_SERVICE_ID=$(jq -r '.services.edges[] | select(.node.name == "Postgres") | .node.id' /tmp/railway_status_before.json)
if [ -z "$POSTGRES_SERVICE_ID" ]; then
    echo -e "${RED}❌ CRITICAL: PostgreSQL service not found as separate service!${NC}"
    echo -e "${RED}ABORTING - Data loss risk!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ PostgreSQL confirmed as separate service (ID: $POSTGRES_SERVICE_ID)${NC}"
echo "   Database will survive service deletion"
echo ""

# Step 3: Backup environment variables (already done, but verify)
echo -e "${YELLOW}Step 3: Verifying environment variable backup...${NC}"
if [ ! -f /tmp/railway_env_backup.json ]; then
    echo -e "${YELLOW}⚠️  Backup not found, creating now...${NC}"
    railway variables --json > /tmp/railway_env_backup.json
fi
BACKUP_VAR_COUNT=$(jq 'length' /tmp/railway_env_backup.json)
echo -e "${GREEN}✅ Backup verified: ${BACKUP_VAR_COUNT} variables${NC}"
echo ""

# Step 4: Delete old service
echo -e "${YELLOW}Step 4: Deleting old 'what-is-my-delta-site' service...${NC}"
OLD_SERVICE_ID=$(jq -r '.services.edges[] | select(.node.name == "what-is-my-delta-site") | .node.id' /tmp/railway_status_before.json)
if [ -z "$OLD_SERVICE_ID" ]; then
    echo -e "${YELLOW}⚠️  Old service not found (may already be deleted)${NC}"
else
    echo "   Service ID: $OLD_SERVICE_ID"
    echo -e "${YELLOW}   Deleting service...${NC}"
    # Note: Railway CLI doesn't have direct service deletion command
    # This requires API call or dashboard action
    echo -e "${RED}⚠️  MANUAL ACTION REQUIRED:${NC}"
    echo "   Go to Railway dashboard and delete service: what-is-my-delta-site"
    echo "   Service ID: $OLD_SERVICE_ID"
    echo ""
    read -p "Press ENTER after you've deleted the service in the dashboard..."
fi
echo ""

# Step 5: Create new service
echo -e "${YELLOW}Step 5: Creating new canonical service 'mosaic-backend'...${NC}"
echo "   Repository: DAMIANSEGUIN/wimd-railway-deploy"
echo "   Branch: main"
echo ""

# Use Railway CLI to add service
railway add --repo DAMIANSEGUIN/wimd-railway-deploy

echo -e "${GREEN}✅ New service created${NC}"
echo ""

# Step 6: Link to new service
echo -e "${YELLOW}Step 6: Linking to new service...${NC}"
railway service mosaic-backend
echo -e "${GREEN}✅ Linked to mosaic-backend${NC}"
echo ""

# Step 7: Restore environment variables
echo -e "${YELLOW}Step 7: Restoring environment variables...${NC}"
echo "   Reading from: /tmp/railway_env_backup.json"

# Read variables and set them one by one
jq -r 'to_entries[] | "\(.key)=\(.value)"' /tmp/railway_env_backup.json | while IFS= read -r line; do
    KEY=$(echo "$line" | cut -d= -f1)
    VALUE=$(echo "$line" | cut -d= -f2-)
    echo "   Setting: $KEY"
    railway variables set "$KEY=$VALUE"
done

echo -e "${GREEN}✅ Environment variables restored${NC}"
echo ""

# Step 8: Deploy new service
echo -e "${YELLOW}Step 8: Deploying new service...${NC}"
railway up --detach

echo -e "${GREEN}✅ Deployment initiated${NC}"
echo ""

# Step 9: Wait and verify
echo -e "${YELLOW}Step 9: Waiting for deployment (60 seconds)...${NC}"
sleep 60

echo -e "${YELLOW}Checking deployment status...${NC}"
railway status

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Railway Reset Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Verify deployment: railway logs"
echo "2. Test health endpoint: curl https://[NEW-SERVICE-URL]/health"
echo "3. Update netlify.toml with new Railway URL"
echo "4. Delete obsolete Railway projects (6 projects)"
echo ""
echo "Backup files created:"
echo "- /tmp/railway_status_before.json (state before reset)"
echo "- /tmp/railway_env_backup.json (environment variables)"
echo ""
