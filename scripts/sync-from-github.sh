#!/bin/bash

# OVU System - Sync FROM GitHub Multi-repos TO Local Monorepo
# משיכת עדכונים מכל repositories ל-Monorepo המקומי

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

GITHUB_USER="noambroner"
BASE_DIR="/home/noam/projects/dev"

echo -e "${BLUE}=== OVU System - Sync FROM GitHub ===${NC}"
echo -e "${YELLOW}משיכת עדכונים מ-GitHub ל-Monorepo המקומי${NC}"
echo ""

# Function to pull and copy
sync_repo() {
    local repo_name=$1
    local target_path=$2
    
    echo -e "${BLUE}סנכרון ${repo_name}...${NC}"
    
    cd "${BASE_DIR}/${repo_name}"
    
    # Pull latest changes
    git fetch origin
    git pull origin main || git pull origin master
    
    echo -e "${GREEN}✓ ${repo_name} עודכן${NC}"
}

# Sync all repositories
cd "$BASE_DIR"

echo -e "${YELLOW}1/5: ovu-ulm${NC}"
sync_repo "ovu-ulm" "ovu-system/services/ulm"

echo -e "${YELLOW}2/5: ovu-aam${NC}"
sync_repo "ovu-aam" "ovu-system/services/aam"

echo -e "${YELLOW}3/5: ovu-shared${NC}"
sync_repo "ovu-shared" "ovu-system/shared"

echo -e "${YELLOW}4/5: ovu-deployment${NC}"
sync_repo "ovu-deployment" "ovu-system/infrastructure"

echo -e "${YELLOW}5/5: ovu-docs${NC}"
sync_repo "ovu-docs" "ovu-system/docs"

echo ""
echo -e "${GREEN}=== כל ה-repositories סונכרנו בהצלחה! ===${NC}"
echo ""
echo -e "${BLUE}כעת תוכל לעבוד ב-Monorepo:${NC}"
echo "cd ${BASE_DIR}/ovu-system"

