# Makefile for PayeTonKawa Simple Orchestration (Windows Compatible)

# Repository paths (adjust these to your actual paths)
CUSTOMER_REPO_PATH = ..\MSPR4_Client
PRODUCT_REPO_PATH = ..\MSPR4_Produits
ORDER_REPO_PATH = ..\MSPR4_Commandes

# Docker image names
CUSTOMER_IMAGE = payetonkawa/customer-api:latest
PRODUCT_IMAGE = payetonkawa/product-api:latest
ORDER_IMAGE = payetonkawa/order-api:latest

# Detect OS for cross-platform compatibility
ifeq ($(OS),Windows_NT)
    SHELL := cmd.exe
    RM := del /Q
    MKDIR := mkdir
    COPY := copy
    EXISTS := if exist
    NOT_EXISTS := if not exist
    ECHO := echo
    CD := cd /D
else
    RM := rm -f
    MKDIR := mkdir -p
    COPY := cp
    EXISTS := [ -d
    NOT_EXISTS := [ ! -d
    ECHO := echo
    CD := cd
endif

.PHONY: help setup build-all up down restart logs status clean

# Default target
help: ## Show this help message
	@$(ECHO) PayeTonKawa Simple Orchestrator
	@$(ECHO) Available commands:
	@powershell -Command "Get-Content $(MAKEFILE_LIST) | Select-String '^[a-zA-Z_-]+:.*?## ' | ForEach-Object { $$parts = $$_.Line -split ':.*?## '; Write-Host ('  {0,-15} {1}' -f $$parts[0], $$parts[1]) }"

# Setup
setup: ## Create .env and check repos
	@$(ECHO) Setting up PayeTonKawa...
	@if not exist .env $(COPY) .env.example .env && $(ECHO) .env created
	@$(MAKE) check-repos
	@$(ECHO) Setup completed! Update your Supabase URLs in .env

check-repos: ## Check if all repository paths exist
	@$(ECHO) Checking repositories...
	@if not exist "$(CUSTOMER_REPO_PATH)" ($(ECHO) Customer repo not found at $(CUSTOMER_REPO_PATH)) else ($(ECHO) Customer repo found)
	@if not exist "$(PRODUCT_REPO_PATH)" ($(ECHO) Product repo not found at $(PRODUCT_REPO_PATH)) else ($(ECHO) Product repo found)
	@if not exist "$(ORDER_REPO_PATH)" ($(ECHO) Order repo not found at $(ORDER_REPO_PATH)) else ($(ECHO) Order repo found)

# Build images from your repos
build-all: ## Build all API images from repositories
	@$(ECHO) Building all images...
	@$(MAKE) build-customer
	@$(MAKE) build-product
	@$(MAKE) build-order
	@$(ECHO) All images built!

build-customer: ## Build customer API image
	@$(ECHO) Building customer API...
	@$(CD) "$(CUSTOMER_REPO_PATH)" && docker build -t $(CUSTOMER_IMAGE) .
	@$(ECHO) Customer API built!

build-product: ## Build product API image
	@$(ECHO) Building product API...
	@$(CD) "$(PRODUCT_REPO_PATH)" && docker build -t $(PRODUCT_IMAGE) .
	@$(ECHO) Product API built!

build-order: ## Build order API image
	@$(ECHO) Building order API...
	@$(CD) "$(ORDER_REPO_PATH)" && docker build -t $(ORDER_IMAGE) .
	@$(ECHO) Order API built!

# Docker operations
up: ## Start all services
	@$(ECHO) Starting PayeTonKawa platform...
	@docker-compose up -d
	@$(MAKE) status

down: ## Stop all services
	@$(ECHO) Stopping platform...
	@docker-compose down
	@$(ECHO) Platform stopped!

restart: ## Restart everything (rebuild + restart)
	@$(MAKE) down
	@$(MAKE) build-all
	@$(MAKE) up

# Logs
logs: ## Show logs from all services
	@docker-compose logs -f

logs-rabbitmq: ## Show RabbitMQ logs
	@docker-compose logs -f rabbitmq

logs-apis: ## Show API logs only
	@docker-compose logs -f customer-api product-api order-api

# Status and health
status: ## Show service status and URLs
	@$(ECHO) Service Status:
	@docker-compose ps
	@$(ECHO).
	@$(ECHO) Access Your APIs:
	@$(ECHO)   Customer API:  http://localhost:8001/docs (container port 8002)
	@$(ECHO)   Product API:   http://localhost:8002/docs (container port 8003)
	@$(ECHO)   Order API:     http://localhost:8003/docs (container port 8001)
	@$(ECHO)   RabbitMQ UI:   http://localhost:15672 (admin/payetonkawa_rabbit)
	@$(ECHO).

health: ## Check API health
	@$(ECHO) Checking API health...
	@powershell -Command "$$ports = @(8001, 8002, 8003); $$names = @('Customer', 'Product', 'Order'); for ($$i=0; $$i -lt $$ports.Length; $$i++) { try { $$response = Invoke-WebRequest -Uri \"http://localhost:$$($$ports[$$i])/health\" -TimeoutSec 5 -UseBasicParsing; Write-Host \"$$($$names[$$i]) API ($$($$ports[$$i])) - OK\" } catch { Write-Host \"$$($$names[$$i]) API ($$($$ports[$$i])) - FAIL\" } }"

# Development workflow
dev: ## Quick development start (build + up)
	@$(MAKE) build-all
	@$(MAKE) up

quick: ## Quick start (assumes images exist)
	@$(MAKE) up

# Cleanup
clean: ## Clean up everything
	@$(ECHO) Cleaning up...
	@docker-compose down -v
	@docker rmi $(CUSTOMER_IMAGE) $(PRODUCT_IMAGE) $(ORDER_IMAGE) 2>nul || $(ECHO) Images removed or not found
	@$(ECHO) Cleanup done!

# Testing
test: ## Run tests on all APIs
	@$(ECHO) Running tests...
	@docker-compose exec customer-api python -m pytest tests/ -v || $(ECHO) Customer tests completed
	@docker-compose exec product-api python -m pytest tests/ -v || $(ECHO) Product tests completed
	@docker-compose exec order-api python -m pytest tests/ -v || $(ECHO) Order tests completed

# Utility
shell: ## Access specific service shell (usage: make shell SERVICE=customer-api)
ifdef SERVICE
	@docker-compose exec $(SERVICE) /bin/bash
else
	@$(ECHO) Specify SERVICE: make shell SERVICE=customer-api
endif

ps: ## Show running containers
	@docker-compose ps