#!/bin/bash

# OVU System - GitHub Monorepo Upload
# This script uploads the entire project as a single repository

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== OVU System GitHub Monorepo Upload ===${NC}"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Initializing Git repository...${NC}"
    git init
    git branch -M main
fi

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
    echo -e "${RED}GitHub CLI not installed!${NC}"
    echo "Install it from: https://cli.github.com/"
    echo ""
    echo -e "${YELLOW}Manual steps:${NC}"
    echo "1. Create repository at: https://github.com/new"
    echo "2. Repository name: ovu-system"
    echo "3. Run these commands:"
    echo ""
    echo "   git add ."
    echo "   git commit -m \"Initial commit - OVU Management System\""
    echo "   git remote add origin https://github.com/YOUR_USERNAME/ovu-system.git"
    echo "   git push -u origin main"
    exit 1
fi

# Get GitHub username
echo -e "${BLUE}Enter your GitHub username or organization:${NC}"
read -r GITHUB_USER

# Repository settings
REPO_NAME="ovu-system"
REPO_DESCRIPTION="OVU Management System - Microservices Architecture with FastAPI + Flutter"

# Create .gitignore if doesn't exist
if [ ! -f ".gitignore" ]; then
    echo -e "${YELLOW}Creating .gitignore...${NC}"
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
venv/
.env
*.log

# Flutter
.dart_tool/
.packages
build/
.flutter-plugins*

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Docker
*.sql
EOF
fi

# Add all files
echo -e "${YELLOW}Adding files to Git...${NC}"
git add .

# Commit
echo -e "${YELLOW}Creating commit...${NC}"
git commit -m "Initial commit - OVU Management System

- ULM: User Login Manager (Authentication & Authorization)
- AAM: Admin Area Manager (Central Administration)
- Multi-language support (Hebrew, English, Arabic) with RTL
- Docker + PLOI.IO deployment ready
- FastAPI Backend + Flutter Frontend" || true

# Create GitHub repository
echo -e "${YELLOW}Creating GitHub repository...${NC}"
gh repo create "${GITHUB_USER}/${REPO_NAME}" \
    --public \
    --description "${REPO_DESCRIPTION}" \
    --homepage "https://${GITHUB_USER}.github.io/${REPO_NAME}" \
    --confirm || true

# Add remote
echo -e "${YELLOW}Adding remote origin...${NC}"
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

# Push
echo -e "${YELLOW}Pushing to GitHub...${NC}"
git push -u origin main

# Create additional branches
echo -e "${YELLOW}Creating development branch...${NC}"
git checkout -b develop
git push -u origin develop
git checkout main

echo ""
echo -e "${GREEN}=== Upload Complete! ===${NC}"
echo ""
echo -e "${BLUE}Repository URL:${NC}"
echo "https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo ""
echo -e "${BLUE}Clone command:${NC}"
echo "git clone https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
echo ""
echo -e "${BLUE}Recommended next steps:${NC}"
echo "1. Add README badges:"
echo "   - Build status"
echo "   - License"
echo "   - Version"
echo ""
echo "2. Set up GitHub Actions:"
echo "   - Python tests"
echo "   - Flutter tests"
echo "   - Docker build"
echo ""
echo "3. Configure branch protection:"
echo "   - Require pull request reviews"
echo "   - Require status checks"
echo ""
echo "4. Add collaborators at:"
echo "   https://github.com/${GITHUB_USER}/${REPO_NAME}/settings/access"
