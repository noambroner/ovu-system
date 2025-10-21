#!/bin/bash

# OVU System - Multi-Computer Sync Script
# This script helps sync development work between multiple computers

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BRANCH=${2:-main}  # Default branch is main, can be overridden

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}OVU System Sync Tool${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_git_status() {
    if [[ -n $(git status -s) ]]; then
        print_warning "יש שינויים לא מסונכרנים:"
        git status -s
        return 1
    fi
    return 0
}

pull_changes() {
    print_header
    echo -e "${BLUE}משיכת שינויים מה-Repository...${NC}\n"
    
    # Check for uncommitted changes
    if ! check_git_status; then
        print_error "יש שינויים מקומיים לא שמורים!"
        echo "אפשרויות:"
        echo "1. שמור את השינויים: git add . && git commit -m 'message'"
        echo "2. הסר את השינויים: git stash"
        echo "3. בטל שינויים: git checkout ."
        exit 1
    fi
    
    # Pull latest changes
    print_warning "משיכת שינויים אחרונים..."
    git fetch origin
    git pull origin $BRANCH
    print_success "שינויים נמשכו בהצלחה!"
    
    # Update submodules if any
    if [ -f .gitmodules ]; then
        print_warning "מעדכן submodules..."
        git submodule update --init --recursive
        print_success "Submodules עודכנו!"
    fi
    
    # Rebuild Docker containers
    echo -e "\n${BLUE}בונה מחדש את Docker containers...${NC}"
    docker-compose down
    docker-compose build
    docker-compose up -d
    print_success "Docker containers נבנו והורצו!"
    
    # Run migrations if needed
    echo -e "\n${BLUE}מריץ database migrations...${NC}"
    docker-compose exec -T ulm_backend alembic upgrade head 2>/dev/null || true
    docker-compose exec -T aam_backend alembic upgrade head 2>/dev/null || true
    print_success "Migrations הושלמו!"
    
    # Show status
    echo -e "\n${BLUE}סטטוס שירותים:${NC}"
    make status
    
    echo -e "\n${GREEN}✓ הסנכרון הושלם בהצלחה!${NC}"
}

push_changes() {
    print_header
    echo -e "${BLUE}דחיפת שינויים ל-Repository...${NC}\n"
    
    # Check for changes
    if check_git_status; then
        print_warning "אין שינויים לדחיפה"
        exit 0
    fi
    
    # Show changes
    echo -e "${BLUE}שינויים שיידחפו:${NC}"
    git status -s
    echo ""
    
    # Ask for confirmation
    read -p "האם להמשיך? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "דחיפה בוטלה"
        exit 0
    fi
    
    # Add all changes
    print_warning "מוסיף שינויים..."
    git add .
    
    # Get commit message
    echo -e "${BLUE}הזן הודעת commit:${NC}"
    read -r commit_message
    
    if [ -z "$commit_message" ]; then
        commit_message="Update from $(hostname) at $(date '+%Y-%m-%d %H:%M')"
    fi
    
    # Commit changes
    git commit -m "$commit_message"
    print_success "Commit נוצר!"
    
    # Push to remote
    print_warning "דוחף לשרת..."
    git push origin $BRANCH
    print_success "שינויים נדחפו בהצלחה!"
    
    echo -e "\n${GREEN}✓ הדחיפה הושלמה בהצלחה!${NC}"
}

backup() {
    print_header
    echo -e "${BLUE}יוצר backup...${NC}\n"
    
    # Create backup directory
    BACKUP_DIR="backups/sync_$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    
    # Backup databases
    print_warning "מגבה databases..."
    docker-compose exec -T postgres pg_dumpall -U ovu_user > "$BACKUP_DIR/database.sql"
    print_success "Database backup נוצר!"
    
    # Backup environment files
    if [ -f .env ]; then
        cp .env "$BACKUP_DIR/.env.backup"
        print_success "Environment files נשמרו!"
    fi
    
    # Create tar archive
    tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
    rm -rf "$BACKUP_DIR"
    
    print_success "Backup נוצר ב: $BACKUP_DIR.tar.gz"
}

status() {
    print_header
    echo -e "${BLUE}בודק סטטוס...${NC}\n"
    
    # Git status
    echo -e "${YELLOW}Git Status:${NC}"
    git status -sb
    echo ""
    
    # Docker status
    echo -e "${YELLOW}Docker Services:${NC}"
    docker-compose ps
    echo ""
    
    # Service health
    echo -e "${YELLOW}Service Health:${NC}"
    make status
}

auto_sync() {
    print_header
    echo -e "${BLUE}סנכרון אוטומטי מלא...${NC}\n"
    
    # First, try to push any local changes
    if ! check_git_status; then
        print_warning "נמצאו שינויים מקומיים, שומר..."
        git add .
        git commit -m "Auto-sync from $(hostname) at $(date '+%Y-%m-%d %H:%M')"
        git push origin $BRANCH
        print_success "שינויים מקומיים נשמרו!"
    fi
    
    # Then pull latest changes
    print_warning "משיכת שינויים אחרונים..."
    git pull origin $BRANCH --rebase
    print_success "שינויים נמשכו!"
    
    # Rebuild if needed
    if [ "$1" == "--rebuild" ]; then
        print_warning "בונה מחדש containers..."
        docker-compose down
        docker-compose build
        docker-compose up -d
        print_success "Containers נבנו מחדש!"
    fi
    
    echo -e "\n${GREEN}✓ סנכרון אוטומטי הושלם!${NC}"
}

# Main script logic
case "$1" in
    pull)
        pull_changes
        ;;
    push)
        push_changes
        ;;
    backup)
        backup
        ;;
    status)
        status
        ;;
    auto)
        auto_sync $2
        ;;
    *)
        print_header
        echo "Usage: $0 {pull|push|backup|status|auto} [branch]"
        echo ""
        echo "Commands:"
        echo "  pull    - משיכת שינויים מהשרת ובנייה מחדש"
        echo "  push    - דחיפת שינויים מקומיים לשרת"
        echo "  backup  - יצירת backup מקומי"
        echo "  status  - הצגת סטטוס נוכחי"
        echo "  auto    - סנכרון אוטומטי (push + pull)"
        echo ""
        echo "Options:"
        echo "  [branch] - ברירת מחדל: main"
        echo ""
        echo "Examples:"
        echo "  $0 pull"
        echo "  $0 push develop"
        echo "  $0 auto --rebuild"
        exit 1
        ;;
esac
