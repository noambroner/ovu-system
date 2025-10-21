#!/bin/bash

# OVU System - GitHub Repository Splitter
# This script splits the monorepo into separate GitHub repositories

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# GitHub settings (update these!)
GITHUB_ORG="your-github-org"  # או השם שלך ב-GitHub
BASE_DIR=$(pwd)

echo -e "${BLUE}=== OVU System GitHub Splitter ===${NC}"
echo ""

# Function to create and push repository
create_repo() {
    local repo_name=$1
    local source_dir=$2
    local description=$3
    
    echo -e "${YELLOW}Creating repository: ${repo_name}${NC}"
    
    # Create temp directory
    temp_dir="/tmp/${repo_name}"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    
    # Copy relevant files
    cp -r "$source_dir"/* "$temp_dir/" 2>/dev/null || true
    
    # Add common files if needed
    if [ "$repo_name" != "ovu-shared" ] && [ "$repo_name" != "ovu-deployment" ]; then
        # Add .gitignore
        cp "$BASE_DIR/.gitignore" "$temp_dir/" 2>/dev/null || true
    fi
    
    # Initialize git
    cd "$temp_dir"
    git init
    
    # Create README if doesn't exist
    if [ ! -f "README.md" ]; then
        echo "# ${repo_name}" > README.md
        echo "" >> README.md
        echo "${description}" >> README.md
    fi
    
    # Commit
    git add .
    git commit -m "Initial commit - ${repo_name}"
    
    # Create GitHub repo (requires GitHub CLI)
    if command -v gh &> /dev/null; then
        echo "Creating GitHub repository..."
        gh repo create "${GITHUB_ORG}/${repo_name}" --public --description "${description}" --confirm || true
        
        # Add remote and push
        git remote add origin "https://github.com/${GITHUB_ORG}/${repo_name}.git"
        git branch -M main
        git push -u origin main
    else
        echo -e "${YELLOW}GitHub CLI not found. Manual steps:${NC}"
        echo "1. Create repo at: https://github.com/new"
        echo "2. Name: ${repo_name}"
        echo "3. Run:"
        echo "   git remote add origin https://github.com/${GITHUB_ORG}/${repo_name}.git"
        echo "   git branch -M main"
        echo "   git push -u origin main"
    fi
    
    echo -e "${GREEN}✓ ${repo_name} ready!${NC}"
    echo ""
    
    cd "$BASE_DIR"
}

# 1. Create ULM repository
echo -e "${BLUE}Step 1: Creating ULM Repository${NC}"
mkdir -p /tmp/ulm-prep
cp -r services/ulm/* /tmp/ulm-prep/
cp -r shared /tmp/ulm-prep/  # Include shared resources
create_repo "ovu-ulm" "/tmp/ulm-prep" "User Login Manager - Authentication & Authorization Service"

# 2. Create AAM repository
echo -e "${BLUE}Step 2: Creating AAM Repository${NC}"
mkdir -p /tmp/aam-prep
cp -r services/aam/* /tmp/aam-prep/
cp -r shared /tmp/aam-prep/  # Include shared resources
create_repo "ovu-aam" "/tmp/aam-prep" "Admin Area Manager - Central Administration Panel"

# 3. Create Shared repository
echo -e "${BLUE}Step 3: Creating Shared Repository${NC}"
create_repo "ovu-shared" "shared" "Shared Resources - UI Components, Localization, and Common Code"

# 4. Create Deployment repository
echo -e "${BLUE}Step 4: Creating Deployment Repository${NC}"
mkdir -p /tmp/deploy-prep
cp -r .ploi /tmp/deploy-prep/
cp -r infrastructure /tmp/deploy-prep/
cp -r scripts /tmp/deploy-prep/
cp docker-compose.yml /tmp/deploy-prep/
cp Makefile /tmp/deploy-prep/
cp *.md /tmp/deploy-prep/
cp env.example /tmp/deploy-prep/
create_repo "ovu-deployment" "/tmp/deploy-prep" "Deployment Configuration - Docker, PLOI, and Infrastructure"

echo -e "${GREEN}=== All repositories created! ===${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Update submodules in ovu-deployment:"
echo "   git submodule add https://github.com/${GITHUB_ORG}/ovu-ulm.git services/ulm"
echo "   git submodule add https://github.com/${GITHUB_ORG}/ovu-aam.git services/aam"
echo "   git submodule add https://github.com/${GITHUB_ORG}/ovu-shared.git shared"
echo ""
echo "2. Configure PLOI to deploy from individual repos"
echo "3. Set up GitHub Actions for CI/CD"
