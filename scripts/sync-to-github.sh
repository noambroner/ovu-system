#!/bin/bash

# OVU System - Sync FROM Local Monorepo TO GitHub Multi-repos
# דחיפת שינויים מה-Monorepo המקומי לכל repositories

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

GITHUB_USER="noambroner"
BASE_DIR="/home/noam/projects/dev"
MONOREPO_DIR="${BASE_DIR}/ovu-system"

echo -e "${BLUE}=== OVU System - Sync TO GitHub ===${NC}"
echo -e "${YELLOW}דחיפת שינויים מהMonorepo ל-GitHub${NC}"
echo ""

# Get commit message
if [ -z "$1" ]; then
    echo -e "${YELLOW}הזן הודעת commit:${NC}"
    read -r COMMIT_MSG
else
    COMMIT_MSG="$1"
fi

if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="Update from monorepo at $(date '+%Y-%m-%d %H:%M')"
fi

echo -e "${BLUE}Commit message: ${COMMIT_MSG}${NC}"
echo ""

# Function to sync to repo
sync_to_repo() {
    local repo_name=$1
    local source_path=$2
    local repo_path="${BASE_DIR}/${repo_name}"
    
    echo -e "${BLUE}סנכרון ל-${repo_name}...${NC}"
    
    if [ ! -d "$repo_path" ]; then
        echo -e "${RED}✗ ${repo_path} לא קיים!${NC}"
        return 1
    fi
    
    # Remove old content (except .git)
    cd "$repo_path"
    find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
    
    # Copy new content from monorepo
    if [ -d "${MONOREPO_DIR}/${source_path}" ]; then
        cp -r "${MONOREPO_DIR}/${source_path}/." "$repo_path/"
    else
        echo -e "${RED}✗ ${MONOREPO_DIR}/${source_path} לא קיים!${NC}"
        return 1
    fi
    
    # Commit and push
    git add .
    
    if git diff --staged --quiet; then
        echo -e "${YELLOW}⚠ אין שינויים ב-${repo_name}${NC}"
    else
        git commit -m "$COMMIT_MSG"
        git push origin main || git push origin master
        echo -e "${GREEN}✓ ${repo_name} עודכן ב-GitHub${NC}"
    fi
    
    echo ""
}

# Sync all repositories
echo -e "${YELLOW}1/5: ovu-ulm${NC}"
sync_to_repo "ovu-ulm" "services/ulm"

echo -e "${YELLOW}2/5: ovu-aam${NC}"
sync_to_repo "ovu-aam" "services/aam"

echo -e "${YELLOW}3/5: ovu-shared${NC}"
sync_to_repo "ovu-shared" "shared"

echo -e "${YELLOW}4/5: ovu-deployment${NC}"
sync_to_repo "ovu-deployment" "infrastructure"

echo -e "${YELLOW}5/5: ovu-docs${NC}"
sync_to_repo "ovu-docs" "docs"

echo ""
echo -e "${GREEN}=== כל השינויים נדחפו ל-GitHub בהצלחה! ===${NC}"
echo ""
echo -e "${BLUE}ה-repositories עודכנו:${NC}"
echo "• https://github.com/${GITHUB_USER}/ovu-ulm"
echo "• https://github.com/${GITHUB_USER}/ovu-aam"
echo "• https://github.com/${GITHUB_USER}/ovu-shared"
echo "• https://github.com/${GITHUB_USER}/ovu-deployment"
echo "• https://github.com/${GITHUB_USER}/ovu-docs"

