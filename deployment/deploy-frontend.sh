#!/bin/bash

# OVU ULM Frontend Deployment Script
# Server: 64.176.173.105 (ploi@ovu-frontend)

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
REPO_DIR="ovu-ulm"
BUILD_DIR="$REPO_DIR/frontend/react"
PUBLIC_DIR="ulm-rct.ovu.co.il/public"

echo -e "${BLUE}Step 1/5: Checking current status...${NC}"
cd ~/$REPO_DIR
git status

echo ""
echo -e "${BLUE}Step 2/5: Pulling latest code from GitHub...${NC}"
git fetch origin
git pull origin main
echo -e "${GREEN}✓ Code updated${NC}"

echo ""
echo -e "${BLUE}Step 3/5: Building React application...${NC}"
cd ~/$BUILD_DIR
npm install
npm run build
echo -e "${GREEN}✓ Build completed${NC}"

echo ""
echo -e "${BLUE}Step 4/5: Deploying to production...${NC}"
# Copy build to nginx public directory
rm -rf ~/$PUBLIC_DIR/assets/*
cp -r dist/* ~/$PUBLIC_DIR/
echo -e "${GREEN}✓ Files deployed to $PUBLIC_DIR${NC}"

echo ""
echo -e "${BLUE}Step 5/5: Verifying deployment...${NC}"
ls -lh ~/$PUBLIC_DIR/assets/
echo -e "${GREEN}✓ Deployment verified${NC}"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Frontend Deployment Completed!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Test the application:${NC}"
echo "https://ulm-rct.ovu.co.il"
echo ""
echo -e "${YELLOW}Clear browser cache and test:${NC}"
echo "- Token Control page should appear in sidebar"
echo "- Login should save refresh token"
echo "- Auto-refresh should work after 15 minutes"

