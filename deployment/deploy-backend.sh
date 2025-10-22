#!/bin/bash

# OVU ULM Backend Deployment Script
# Server: 64.176.171.223 (ploi@ulm.bflow.co.il)

set -e

echo "🚀 Starting Backend Deployment..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
BACKEND_DIR="/home/ploi/ulm.bflow.co.il"
SERVICE_NAME="ulm-backend"

echo -e "${BLUE}Step 1/6: Checking current status...${NC}"
cd $BACKEND_DIR
git status

echo ""
echo -e "${BLUE}Step 2/6: Creating backup of database...${NC}"
timestamp=$(date +%Y%m%d_%H%M%S)
sudo -u postgres pg_dump ovu_ulm > "backup_before_refresh_token_${timestamp}.sql"
echo -e "${GREEN}✓ Backup created: backup_before_refresh_token_${timestamp}.sql${NC}"

echo ""
echo -e "${BLUE}Step 3/6: Pulling latest code from GitHub...${NC}"
git fetch origin
git pull origin main
echo -e "${GREEN}✓ Code updated${NC}"

echo ""
echo -e "${BLUE}Step 4/6: Installing dependencies...${NC}"
cd backend
source venv/bin/activate
pip install -r requirements.txt
echo -e "${GREEN}✓ Dependencies installed${NC}"

echo ""
echo -e "${BLUE}Step 5/6: Running database migration...${NC}"
python run_migration_simple.py migrations/002_add_refresh_tokens.sql
echo -e "${GREEN}✓ Migration completed${NC}"

echo ""
echo -e "${BLUE}Step 6/6: Restarting backend service...${NC}"
systemctl --user restart $SERVICE_NAME
sleep 3
systemctl --user status $SERVICE_NAME

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Backend Deployment Completed!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Testing the service:${NC}"
echo "curl -X POST https://ulm.bflow.co.il/api/v1/auth/login -H 'Content-Type: application/json' -d '{\"username\":\"test\",\"password\":\"test\"}'"
echo ""
echo -e "${YELLOW}Check logs:${NC}"
echo "journalctl --user -u $SERVICE_NAME -f"


