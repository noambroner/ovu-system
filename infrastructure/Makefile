# OVU System Makefile
.PHONY: help build up down restart logs clean test install dev prod

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

# Default target
help:
	@echo "$(BLUE)OVU Management System - Make Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@echo "  make dev          - Start all services in development mode"
	@echo "  make build        - Build all Docker images"
	@echo "  make up           - Start all services"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make logs         - View logs from all services"
	@echo "  make clean        - Clean up containers, volumes, and images"
	@echo ""
	@echo "$(GREEN)Services:$(NC)"
	@echo "  make ulm-up       - Start ULM service only"
	@echo "  make aam-up       - Start AAM service only"
	@echo "  make ulm-logs     - View ULM service logs"
	@echo "  make aam-logs     - View AAM service logs"
	@echo "  make ulm-shell    - Enter ULM backend container"
	@echo "  make aam-shell    - Enter AAM backend container"
	@echo ""
	@echo "$(GREEN)Database:$(NC)"
	@echo "  make db-shell     - Enter PostgreSQL shell"
	@echo "  make db-backup    - Backup all databases"
	@echo "  make db-restore   - Restore databases from backup"
	@echo "  make migrate      - Run database migrations"
	@echo ""
	@echo "$(GREEN)Testing:$(NC)"
	@echo "  make test         - Run all tests"
	@echo "  make test-ulm     - Run ULM tests"
	@echo "  make test-aam     - Run AAM tests"
	@echo ""
	@echo "$(GREEN)Utilities:$(NC)"
	@echo "  make install      - Install dependencies for local development"
	@echo "  make format       - Format code (Python & Dart)"
	@echo "  make lint         - Run linters"
	@echo "  make status       - Check status of all services"

# Development
dev: build
	@echo "$(GREEN)Starting development environment...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Services are starting up...$(NC)"
	@sleep 5
	@make status
	@echo ""
	@echo "$(BLUE)Access points:$(NC)"
	@echo "  - Main Portal:    http://localhost"
	@echo "  - ULM Service:    http://ulm.localhost"
	@echo "  - AAM Service:    http://aam.localhost"
	@echo "  - Database Admin: http://localhost:8080"
	@echo "  - RabbitMQ Admin: http://localhost:15672 (ovu_rabbit/ovu_rabbit_pass_2024)"
	@echo "  - Mail Testing:   http://localhost:8025"

build:
	@echo "$(GREEN)Building Docker images...$(NC)"
	docker-compose build

up:
	@echo "$(GREEN)Starting services...$(NC)"
	docker-compose up -d

down:
	@echo "$(YELLOW)Stopping services...$(NC)"
	docker-compose down

restart: down up

logs:
	docker-compose logs -f

clean:
	@echo "$(RED)Cleaning up...$(NC)"
	docker-compose down -v
	docker system prune -af

# Service-specific commands
ulm-up:
	@echo "$(GREEN)Starting ULM service...$(NC)"
	docker-compose up -d postgres redis ulm_backend ulm_flutter nginx

aam-up:
	@echo "$(GREEN)Starting AAM service...$(NC)"
	docker-compose up -d postgres redis aam_backend aam_flutter nginx

ulm-logs:
	docker-compose logs -f ulm_backend ulm_flutter

aam-logs:
	docker-compose logs -f aam_backend aam_flutter

ulm-shell:
	docker-compose exec ulm_backend /bin/bash

aam-shell:
	docker-compose exec aam_backend /bin/bash

# Database commands
db-shell:
	docker-compose exec postgres psql -U ovu_user -d ovu_main_db

db-backup:
	@echo "$(GREEN)Backing up databases...$(NC)"
	@mkdir -p backups
	@docker-compose exec -T postgres pg_dumpall -U ovu_user > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Backup completed!$(NC)"

db-restore:
	@echo "$(YELLOW)Restoring databases from latest backup...$(NC)"
	@if [ -z "$(FILE)" ]; then \
		FILE=$$(ls -t backups/*.sql | head -1); \
	fi; \
	docker-compose exec -T postgres psql -U ovu_user < $$FILE
	@echo "$(GREEN)Restore completed!$(NC)"

migrate:
	@echo "$(GREEN)Running migrations...$(NC)"
	docker-compose exec ulm_backend alembic upgrade head
	docker-compose exec aam_backend alembic upgrade head

# Testing
test:
	@make test-ulm
	@make test-aam

test-ulm:
	@echo "$(GREEN)Running ULM tests...$(NC)"
	docker-compose exec ulm_backend pytest tests/ -v

test-aam:
	@echo "$(GREEN)Running AAM tests...$(NC)"
	docker-compose exec aam_backend pytest tests/ -v

# Installation for local development
install:
	@echo "$(GREEN)Installing dependencies...$(NC)"
	# Python dependencies for ULM
	cd services/ulm/backend && python -m venv venv && . venv/bin/activate && pip install -r requirements.txt
	# Python dependencies for AAM
	cd services/aam/backend && python -m venv venv && . venv/bin/activate && pip install -r requirements.txt
	# Flutter dependencies
	cd services/ulm/frontend/flutter && flutter pub get
	cd services/aam/frontend/flutter && flutter pub get
	cd shared/interface-resources/flutter && flutter pub get
	@echo "$(GREEN)Installation completed!$(NC)"

# Code quality
format:
	@echo "$(GREEN)Formatting code...$(NC)"
	# Python formatting
	find services -name "*.py" -exec black {} \;
	# Dart formatting
	find services -name "*.dart" -exec dart format {} \;
	find shared/interface-resources/flutter -name "*.dart" -exec dart format {} \;

lint:
	@echo "$(GREEN)Running linters...$(NC)"
	# Python linting
	find services -name "*.py" -exec flake8 {} \;
	# Dart linting
	cd services/ulm/frontend/flutter && flutter analyze
	cd services/aam/frontend/flutter && flutter analyze

# Status check
status:
	@echo "$(BLUE)Service Status:$(NC)"
	@echo -n "PostgreSQL:  "; docker-compose exec -T postgres pg_isready -U ovu_user > /dev/null 2>&1 && echo "$(GREEN)✓ Running$(NC)" || echo "$(RED)✗ Not running$(NC)"
	@echo -n "Redis:       "; docker-compose exec -T redis redis-cli ping > /dev/null 2>&1 && echo "$(GREEN)✓ Running$(NC)" || echo "$(RED)✗ Not running$(NC)"
	@echo -n "RabbitMQ:    "; docker-compose exec -T rabbitmq rabbitmq-diagnostics ping > /dev/null 2>&1 && echo "$(GREEN)✓ Running$(NC)" || echo "$(RED)✗ Not running$(NC)"
	@echo -n "ULM Backend: "; curl -f http://localhost:8001/health > /dev/null 2>&1 && echo "$(GREEN)✓ Running$(NC)" || echo "$(RED)✗ Not running$(NC)"
	@echo -n "AAM Backend: "; curl -f http://localhost:8002/health > /dev/null 2>&1 && echo "$(GREEN)✓ Running$(NC)" || echo "$(RED)✗ Not running$(NC)"
	@echo -n "Nginx:       "; curl -f http://localhost > /dev/null 2>&1 && echo "$(GREEN)✓ Running$(NC)" || echo "$(RED)✗ Not running$(NC)"

# Production deployment
prod:
	@echo "$(YELLOW)Building for production...$(NC)"
	docker-compose -f docker-compose.prod.yml build
	docker-compose -f docker-compose.prod.yml up -d
	@echo "$(GREEN)Production deployment completed!$(NC)"
