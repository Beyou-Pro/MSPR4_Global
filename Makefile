# Makefile for PayeTonKawa Simple Orchestration

# Repository paths (adjust these to your actual paths)
CUSTOMER_REPO_PATH = ../MSPR4_Client
PRODUCT_REPO_PATH = ../MSPR4_Produits
ORDER_REPO_PATH = ../MSPR4_Commandes

# Docker image names
CUSTOMER_IMAGE = payetonkawa/customer-api:latest
PRODUCT_IMAGE = payetonkawa/product-api:latest
ORDER_IMAGE = payetonkawa/order-api:latest

.PHONY: help setup build-all up down restart logs status clean

# Default target
help: ## Show this help message
	@echo "PayeTonKawa Simple Orchestrator"
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup
setup: ## Create .env and check repos
	@echo "Setting up PayeTonKawa..."
	@if [ ! -f .env ]; then cp .env.example .env; echo ".env created"; fi
	@make check-repos
	@echo "Setup completed! Update your Supabase URLs in .env"

check-repos: ## Check if all repository paths exist
	@echo "Checking repositories..."
	@if [ ! -d "$(CUSTOMER_REPO_PATH)" ]; then \
		echo "Customer repo not found at $(CUSTOMER_REPO_PATH)"; \
	else \
		echo "Customer repo found"; \
	fi
	@if [ ! -d "$(PRODUCT_REPO_PATH)" ]; then \
		echo "Product repo not found at $(PRODUCT_REPO_PATH)"; \
	else \
		echo "Product repo found"; \
	fi
	@if [ ! -d "$(ORDER_REPO_PATH)" ]; then \
		echo "Order repo not found at $(ORDER_REPO_PATH)"; \
	else \
		echo "Order repo found"; \
	fi

# Build images from your repos
build-all: ## Build all API images from repositories
	@echo "Building all images..."
	@make build-customer
	@make build-product
	@make build-order
	@echo "All images built!"

build-customer: ## Build customer API image
	@echo "Building customer API..."
	@cd $(CUSTOMER_REPO_PATH) && docker build -t $(CUSTOMER_IMAGE) .
	@echo "Customer API built!"

build-product: ## Build product API image
	@echo "Building product API..."
	@cd $(PRODUCT_REPO_PATH) && docker build -t $(PRODUCT_IMAGE) .
	@echo "Product API built!"

build-order: ## Build order API image
	@echo "Building order API..."
	@cd $(ORDER_REPO_PATH) && docker build -t $(ORDER_IMAGE) .
	@echo "Order API built!"

# Docker operations
up: ## Start all services
	@echo "Starting PayeTonKawa platform..."
	@docker-compose up -d
	@make status

down: ## Stop all services
	@echo "Stopping platform..."
	@docker-compose down
	@echo "Platform stopped!"

restart: ## Restart everything (rebuild + restart)
	@make down
	@make build-all
	@make up

# Logs
logs: ## Show logs from all services
	@docker-compose logs -f

logs-rabbitmq: ## Show RabbitMQ logs
	@docker-compose logs -f rabbitmq

logs-apis: ## Show API logs only
	@docker-compose logs -f customer-api product-api order-api

# Status and health
status: ## Show service status and URLs
	@echo "Service Status:"
	@docker-compose ps
	@echo ""
	@echo "Access Your APIs:"
	@echo "  Customer API:  http://localhost:8001/docs (container port 8002)"
	@echo "  Product API:   http://localhost:8002/docs (container port 8003)"
	@echo "  Order API:     http://localhost:8003/docs (container port 8001)"
	@echo "  RabbitMQ UI:   http://localhost:15672 (admin/payetonkawa_rabbit)"
	@echo ""

health: ## Check API health
	@echo "Checking API health..."
	@for port in 8001 8002 8003; do \
		name=""; \
		if [ $$port -eq 8001 ]; then name="Customer"; \
		elif [ $$port -eq 8002 ]; then name="Product"; \
		elif [ $$port -eq 8003 ]; then name="Order"; \
		fi; \
		if curl -s http://localhost:$$port/health >/dev/null 2>&1; then \
			echo "$$name API ($$port) - OK"; \
		else \
			echo "$$name API ($$port) - FAIL"; \
		fi; \
	done

# Development workflow
dev: ## Quick development start (build + up)
	@make build-all
	@make up

quick: ## Quick start (assumes images exist)
	@make up

# Cleanup
clean: ## Clean up everything
	@echo "Cleaning up..."
	@docker-compose down -v
	@docker rmi $(CUSTOMER_IMAGE) $(PRODUCT_IMAGE) $(ORDER_IMAGE) 2>/dev/null || true
	@echo "Cleanup done!"

# Testing
test: ## Run tests on all APIs
	@echo "Running tests..."
	@docker-compose exec customer-api python -m pytest tests/ -v || true
	@docker-compose exec product-api python -m pytest tests/ -v || true
	@docker-compose exec order-api python -m pytest tests/ -v || true

# Utility
shell: ## Access specific service shell (usage: make shell SERVICE=customer-api)
	@if [ -z "$(SERVICE)" ]; then \
		echo "Specify SERVICE: make shell SERVICE=customer-api"; \
		exit 1; \
	fi
	@docker-compose exec $(SERVICE) /bin/bash

ps: ## Show running containers
	@docker-compose ps