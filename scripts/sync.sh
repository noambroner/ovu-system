#!/bin/bash

# OVU System - Main Sync Script
# סקריפט סנכרון מרכזי לניהול Monorepo <-> Multi-repo

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}   OVU System Sync Manager     ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

show_usage() {
    print_header
    echo "Usage: $0 {pull|push|auto|status} [commit-message]"
    echo ""
    echo "Commands:"
    echo "  pull          משיכת שינויים מ-GitHub ל-Monorepo"
    echo "  push          דחיפת שינויים מ-Monorepo ל-GitHub"
    echo "  auto          סנכרון דו-כיווני אוטומטי"
    echo "  status        הצגת סטטוס כל repositories"
    echo ""
    echo "Examples:"
    echo "  $0 pull"
    echo "  $0 push \"Added new feature\""
    echo "  $0 auto"
    exit 1
}

pull_from_github() {
    print_header
    echo -e "${BLUE}משיכת שינויים מ-GitHub...${NC}"
    echo ""
    bash "${SCRIPT_DIR}/sync-from-github.sh"
}

push_to_github() {
    print_header
    echo -e "${BLUE}דחיפת שינויים ל-GitHub...${NC}"
    echo ""
    bash "${SCRIPT_DIR}/sync-to-github.sh" "$1"
}

auto_sync() {
    print_header
    echo -e "${BLUE}סנכרון אוטומטי מלא...${NC}"
    echo ""
    
    # First pull from GitHub
    echo -e "${YELLOW}שלב 1: משיכת עדכונים${NC}"
    bash "${SCRIPT_DIR}/sync-from-github.sh"
    echo ""
    
    # Then push any local changes
    echo -e "${YELLOW}שלב 2: דחיפת שינויים מקומיים${NC}"
    bash "${SCRIPT_DIR}/sync-to-github.sh" "Auto-sync at $(date '+%Y-%m-%d %H:%M')"
    echo ""
    
    echo -e "${GREEN}=== סנכרון אוטומטי הושלם בהצלחה! ===${NC}"
}

show_status() {
    print_header
    echo -e "${BLUE}סטטוס Repositories:${NC}"
    echo ""
    
    BASE_DIR="/home/noam/projects/dev"
    REPOS=("ovu-ulm" "ovu-aam" "ovu-shared" "ovu-deployment" "ovu-docs")
    
    for repo in "${REPOS[@]}"; do
        echo -e "${YELLOW}${repo}:${NC}"
        cd "${BASE_DIR}/${repo}"
        
        # Check branch
        branch=$(git branch --show-current)
        echo -e "  Branch: ${BLUE}${branch}${NC}"
        
        # Check status
        if git diff --quiet && git diff --staged --quiet; then
            echo -e "  Status: ${GREEN}✓ Clean${NC}"
        else
            echo -e "  Status: ${RED}✗ Has changes${NC}"
            git status -s | sed 's/^/    /'
        fi
        
        # Check commits ahead/behind
        git fetch origin -q
        ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
        behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
        
        if [ "$ahead" != "0" ] || [ "$behind" != "0" ]; then
            echo -e "  Sync: ${YELLOW}↑${ahead} ↓${behind}${NC}"
        else
            echo -e "  Sync: ${GREEN}✓ Up to date${NC}"
        fi
        
        echo ""
    done
}

# Main logic
case "$1" in
    pull)
        pull_from_github
        ;;
    push)
        push_to_github "$2"
        ;;
    auto)
        auto_sync
        ;;
    status)
        show_status
        ;;
    *)
        show_usage
        ;;
esac

