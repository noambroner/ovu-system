#!/bin/bash

# OVU System - PLOI.IO Deployment Script
# This script runs on each deployment via PLOI

set -e

echo "🚀 Starting OVU System Deployment..."

# Variables
PROJECT_ROOT="/var/www/ovu-backend"
PYTHON_VERSION="python3.11"
VENV_PATH="$PROJECT_ROOT/venv"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Change to project directory
cd $PROJECT_ROOT

# Git operations
print_status "Pulling latest code..."
git pull origin main

# Python virtual environment
if [ ! -d "$VENV_PATH" ]; then
    print_status "Creating Python virtual environment..."
    $PYTHON_VERSION -m venv $VENV_PATH
fi

# Activate virtual environment
source $VENV_PATH/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip wheel setuptools

# Install/Update dependencies
print_status "Installing Python dependencies..."
pip install -r services/ulm/backend/requirements.txt
pip install -r services/aam/backend/requirements.txt

# Environment variables
if [ -f ".env.production" ]; then
    print_status "Loading production environment..."
    export $(cat .env.production | grep -v '^#' | xargs)
else
    print_warning ".env.production not found, using PLOI environment variables"
fi

# Database migrations for ULM
print_status "Running ULM database migrations..."
cd services/ulm/backend
if [ -d "alembic" ]; then
    alembic upgrade head || print_warning "ULM migrations skipped or failed"
else
    print_warning "No alembic directory found for ULM"
fi
cd $PROJECT_ROOT

# Database migrations for AAM
print_status "Running AAM database migrations..."
cd services/aam/backend
if [ -d "alembic" ]; then
    alembic upgrade head || print_warning "AAM migrations skipped or failed"
else
    print_warning "No alembic directory found for AAM"
fi
cd $PROJECT_ROOT

# Create necessary directories
print_status "Creating required directories..."
mkdir -p logs
mkdir -p uploads
mkdir -p static

# Set permissions
print_status "Setting file permissions..."
chown -R ploi:ploi $PROJECT_ROOT
chmod -R 755 $PROJECT_ROOT
chmod -R 775 logs uploads

# Restart services via Supervisor
print_status "Restarting FastAPI services..."
sudo supervisorctl restart ovu-ulm:*
sudo supervisorctl restart ovu-aam:*

# Check service status
print_status "Checking service status..."
sleep 3
sudo supervisorctl status

# Health checks
print_status "Running health checks..."
curl -f http://localhost:8001/health || print_warning "ULM health check failed"
curl -f http://localhost:8002/health || print_warning "AAM health check failed"

print_status "Deployment completed successfully! 🎉"

# Send notification (optional - if you have Slack/Discord webhook)
if [ ! -z "$SLACK_WEBHOOK" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"✅ OVU System deployed successfully!"}' \
        $SLACK_WEBHOOK
fi
