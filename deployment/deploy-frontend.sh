#!/bin/bash

# OVU ULM Frontend Deployment Script
# Server: 64.176.173.105 (ploi@ulm-frontend)

set -e

echo "🚀 Starting Frontend Deployment..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
FRONTEND_DIR="/home/ploi/ulm-frontend.bflow.co.il"
BUILD_DIR="frontend/react"

echo -e "${BLUE}Step 1/4: Checking current status...${NC}"
cd $FRONTEND_DIR
git status

echo ""
echo -e "${BLUE}Step 2/4: Pulling latest code from GitHub...${NC}"
git fetch origin
git pull origin main
echo -e "${GREEN}✓ Code updated${NC}"

echo ""
echo -e "${BLUE}Step 3/4: Building React application...${NC}"
cd $BUILD_DIR
npm install
npm run build
echo -e "${GREEN}✓ Build completed${NC}"

echo ""
echo -e "${BLUE}Step 4/4: Deploying to production...${NC}"
# Copy build to nginx directory
sudo rm -rf /var/www/ulm-frontend.bflow.co.il/public/*
sudo cp -r dist/* /var/www/ulm-frontend.bflow.co.il/public/
sudo chown -R www-data:www-data /var/www/ulm-frontend.bflow.co.il/public/
echo -e "${GREEN}✓ Files deployed${NC}"

echo ""
echo -e "${BLUE}Restarting nginx...${NC}"
sudo systemctl restart nginx
echo -e "${GREEN}✓ Nginx restarted${NC}"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Frontend Deployment Completed!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Test the application:${NC}"
echo "https://ulm-frontend.bflow.co.il"
echo ""
echo -e "${YELLOW}Clear browser cache and test:${NC}"
echo "- Token Control page should appear in sidebar"
echo "- Login should save refresh token"
echo "- Auto-refresh should work after 15 minutes"

