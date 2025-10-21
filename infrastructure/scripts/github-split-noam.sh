#!/bin/bash

# OVU System - GitHub Repository Splitter for Noam
# This script splits the monorepo into separate GitHub repositories

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# GitHub settings
GITHUB_USER="noambroner"
BASE_DIR=$(pwd)

echo -e "${BLUE}=== OVU System GitHub Splitter ===${NC}"
echo -e "${GREEN}Creating 4 separate repositories for: ${GITHUB_USER}${NC}"
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
    if [ -d "$source_dir" ]; then
        cp -r "$source_dir"/* "$temp_dir/" 2>/dev/null || true
    fi
    
    # Add .gitignore for service repos
    if [[ "$repo_name" == "ovu-ulm" ]] || [[ "$repo_name" == "ovu-aam" ]]; then
        cat > "$temp_dir/.gitignore" << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
venv/
.env
*.log
.pytest_cache/

# Flutter
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies

# IDE
.vscode/
.idea/
*.iml

# OS
.DS_Store
Thumbs.db
EOF
    fi
    
    # Create README if doesn't exist
    if [ ! -f "$temp_dir/README.md" ]; then
        echo "# ${repo_name}" > "$temp_dir/README.md"
        echo "" >> "$temp_dir/README.md"
        echo "${description}" >> "$temp_dir/README.md"
        echo "" >> "$temp_dir/README.md"
        echo "Part of OVU Management System" >> "$temp_dir/README.md"
        echo "" >> "$temp_dir/README.md"
        echo "## Installation" >> "$temp_dir/README.md"
        echo '```bash' >> "$temp_dir/README.md"
        echo "git clone https://github.com/${GITHUB_USER}/${repo_name}.git" >> "$temp_dir/README.md"
        echo '```' >> "$temp_dir/README.md"
    fi
    
    # Initialize git
    cd "$temp_dir"
    git init
    git add .
    git commit -m "Initial commit - ${repo_name}

${description}

Part of OVU Management System
- Multi-language support (Hebrew, English, Arabic)
- RTL support
- Docker ready
- PLOI.IO ready"
    
    # Create branch
    git branch -M main
    
    echo -e "${GREEN}✓ ${repo_name} ready for upload!${NC}"
    echo "Repository prepared at: ${temp_dir}"
    echo ""
    
    cd "$BASE_DIR"
}

# 1. Create ULM repository
echo -e "${BLUE}Step 1/4: Creating ULM Repository${NC}"
mkdir -p /tmp/ulm-prep
cp -r services/ulm/* /tmp/ulm-prep/ 2>/dev/null || true
# Include shared resources
mkdir -p /tmp/ulm-prep/shared
cp -r shared/* /tmp/ulm-prep/shared/ 2>/dev/null || true
create_repo "ovu-ulm" "/tmp/ulm-prep" "User Login Manager - Authentication & Authorization Service with FastAPI + Flutter"

# 2. Create AAM repository
echo -e "${BLUE}Step 2/4: Creating AAM Repository${NC}"
mkdir -p /tmp/aam-prep
cp -r services/aam/* /tmp/aam-prep/ 2>/dev/null || true
# Include shared resources
mkdir -p /tmp/aam-prep/shared
cp -r shared/* /tmp/aam-prep/shared/ 2>/dev/null || true
create_repo "ovu-aam" "/tmp/aam-prep" "Admin Area Manager - Central Administration Panel with FastAPI"

# 3. Create Shared repository
echo -e "${BLUE}Step 3/4: Creating Shared Repository${NC}"
create_repo "ovu-shared" "shared" "Shared Resources - UI Components, Localization, and Common Code for OVU System"

# 4. Create Deployment repository
echo -e "${BLUE}Step 4/4: Creating Deployment Repository${NC}"
mkdir -p /tmp/deploy-prep
cp -r .ploi /tmp/deploy-prep/ 2>/dev/null || true
cp -r infrastructure /tmp/deploy-prep/ 2>/dev/null || true
cp -r scripts /tmp/deploy-prep/ 2>/dev/null || true
cp docker-compose.yml /tmp/deploy-prep/ 2>/dev/null || true
cp Makefile /tmp/deploy-prep/ 2>/dev/null || true
cp *.md /tmp/deploy-prep/ 2>/dev/null || true
cp env.example /tmp/deploy-prep/ 2>/dev/null || true
cp .gitignore /tmp/deploy-prep/ 2>/dev/null || true
# Add GitHub Actions
mkdir -p /tmp/deploy-prep/.github
cp -r .github/* /tmp/deploy-prep/.github/ 2>/dev/null || true
create_repo "ovu-deployment" "/tmp/deploy-prep" "Deployment Configuration - Docker, PLOI, and Infrastructure for OVU System"

echo -e "${GREEN}=== All 4 repositories prepared! ===${NC}"
echo ""
echo -e "${BLUE}Now we'll create them on GitHub...${NC}"
echo ""

# Create GitHub repositories
echo -e "${YELLOW}Creating repositories on GitHub...${NC}"
echo ""

# Create upload script
cat > /tmp/upload_repos.sh << 'UPLOAD_SCRIPT'
#!/bin/bash

GITHUB_USER="noambroner"

# Function to create and push GitHub repo
push_to_github() {
    local repo_name=$1
    local temp_dir="/tmp/${repo_name}"
    
    echo "----------------------------------------"
    echo "Uploading ${repo_name} to GitHub..."
    echo "----------------------------------------"
    
    cd "$temp_dir"
    
    # Try to create repo (will fail if exists, that's ok)
    curl -u ${GITHUB_USER} https://api.github.com/user/repos \
        -d "{\"name\":\"${repo_name}\",\"description\":\"Part of OVU Management System\",\"private\":false}" \
        2>/dev/null || true
    
    # Add remote and push
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/${GITHUB_USER}/${repo_name}.git"
    
    # Push
    echo "Pushing to GitHub..."
    git push -u origin main --force 2>/dev/null || {
        echo "Note: If authentication fails, create repo manually at:"
        echo "https://github.com/new"
        echo "Name: ${repo_name}"
        echo ""
        echo "Then run:"
        echo "cd /tmp/${repo_name}"
        echo "git remote add origin https://github.com/${GITHUB_USER}/${repo_name}.git"
        echo "git push -u origin main"
    }
    
    echo "✓ Done with ${repo_name}"
    echo ""
}

# Upload all repos
push_to_github "ovu-ulm"
push_to_github "ovu-aam"
push_to_github "ovu-shared"
push_to_github "ovu-deployment"

echo "=== Upload Complete! ==="
echo ""
echo "Your repositories:"
echo "1. https://github.com/${GITHUB_USER}/ovu-ulm"
echo "2. https://github.com/${GITHUB_USER}/ovu-aam"
echo "3. https://github.com/${GITHUB_USER}/ovu-shared"
echo "4. https://github.com/${GITHUB_USER}/ovu-deployment"
UPLOAD_SCRIPT

chmod +x /tmp/upload_repos.sh

echo -e "${GREEN}=== Repositories Prepared Successfully! ===${NC}"
echo ""
echo -e "${BLUE}The 4 repositories are ready at:${NC}"
echo "1. /tmp/ovu-ulm"
echo "2. /tmp/ovu-aam"
echo "3. /tmp/ovu-shared"
echo "4. /tmp/ovu-deployment"
echo ""
echo -e "${YELLOW}Manual upload instructions:${NC}"
echo ""
echo "For each repository, do:"
echo "1. Go to https://github.com/new"
echo "2. Create repository with these names:"
echo "   - ovu-ulm"
echo "   - ovu-aam"
echo "   - ovu-shared"
echo "   - ovu-deployment"
echo ""
echo "3. Then for each repo run:"
echo -e "${GREEN}Repository 1 - ULM:${NC}"
echo "cd /tmp/ovu-ulm"
echo "git remote add origin https://github.com/${GITHUB_USER}/ovu-ulm.git"
echo "git push -u origin main"
echo ""
echo -e "${GREEN}Repository 2 - AAM:${NC}"
echo "cd /tmp/ovu-aam"
echo "git remote add origin https://github.com/${GITHUB_USER}/ovu-aam.git"
echo "git push -u origin main"
echo ""
echo -e "${GREEN}Repository 3 - Shared:${NC}"
echo "cd /tmp/ovu-shared"
echo "git remote add origin https://github.com/${GITHUB_USER}/ovu-shared.git"
echo "git push -u origin main"
echo ""
echo -e "${GREEN}Repository 4 - Deployment:${NC}"
echo "cd /tmp/ovu-deployment"
echo "git remote add origin https://github.com/${GITHUB_USER}/ovu-deployment.git"
echo "git push -u origin main"
echo ""
echo -e "${BLUE}=== PLOI Configuration ===${NC}"
echo "After uploading, configure PLOI with:"
echo "- ULM: https://github.com/${GITHUB_USER}/ovu-ulm"
echo "- AAM: https://github.com/${GITHUB_USER}/ovu-aam"
echo "- Deploy script: Use from ovu-deployment repo"
