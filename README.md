# PayeTonKawa Microservices Platform 🏪☕

A microservices architecture platform for PayeTonKawa coffee business, built with FastAPI, Docker, and RabbitMQ.

## 📋 Overview

PayeTonKawa is a coffee import company that sells to both individuals and professional restaurants. This project implements a modern microservices architecture to replace their monolithic system.

### 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Customer API│    │ Product API │    │  Order API  │
│   Port 8001 │    │   Port 8002 │    │  Port 8003  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                  ┌─────────────┐
                  │  RabbitMQ   │
                  │ Port 15672  │
                  └─────────────┘
```

### 🛠️ Technology Stack

- **Backend**: FastAPI (Python 3.11)
- **Database**: Supabase (PostgreSQL)
- **Message Broker**: RabbitMQ
- **Containerization**: Docker & Docker Compose
- **Orchestration**: Make (cross-platform)

## 🚀 Quick Start

### Prerequisites

- Docker Desktop
- Make (Windows: `choco install make` or `scoop install make`)
- Git

### Installation

1. **Clone the orchestrator repository and the APIs repositories:**
   ```bash
   git clone https://github.com/Beyou-Pro/MSPR4_Global
   git clone https://github.com/Annarummaarthur/MSPR4_Produits
   git clone https://github.com/Annarummaarthur/MSPR4_Client
   git clone https://github.com/Annarummaarthur/MSPR4_Commandes
   ```

2. **Ensure your API repositories are in the correct locations:**
   ```
   MSPR4_Global/          # Orchestration
   MSPR4_Client/          # Customer API
   MSPR4_Produits/        # Product API  
   MSPR4_Commandes/       # Order API
   ```

3. **Setup environment:**
   ```bash
   make setup
   ```

4. **Build and start all services:**
   ```bash
   make dev
   ```

5. **Check status:**
   ```bash
   make status
   ```

## 🌐 Access URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Customer API** | http://localhost:8001/docs | Customer management API documentation |
| **Product API** | http://localhost:8002/docs | Product catalog API documentation |
| **Order API** | http://localhost:8003/docs | Order processing API documentation |
| **RabbitMQ Management** | http://localhost:15672 | Message broker dashboard (admin/payetonkawa_rabbit) |

## 📝 Available Commands

### 🔧 Setup & Management
```bash
make help           # Show all available commands
make setup          # Initial project setup
make check-repos    # Verify repository locations
```

### 🏗️ Build & Deploy
```bash
make build-all      # Build all API images
make build-customer # Build customer API only
make build-product  # Build product API only
make build-order    # Build order API only
```

### 🚀 Service Control
```bash
make up             # Start all services
make down           # Stop all services
make restart        # Full restart (rebuild + restart)
make quick          # Quick start (assumes images exist)
make dev            # Development workflow (build + up)
```

### 📊 Monitoring & Logs
```bash
make status         # Show service status and URLs
make health         # Check API health status
make logs           # Show logs from all services
make logs-rabbitmq  # Show RabbitMQ logs only
make logs-apis      # Show API logs only
make ps             # Show running containers
```

### 🧹 Cleanup
```bash
make clean          # Remove containers and images
```

## 🏢 Services Description

### Customer API (Port 8001)
- **Repository**: MSPR4_Client
- **Database**: Supabase Customer DB
- **Features**: Customer profiles, authentication, account management

### Product API (Port 8002)  
- **Repository**: MSPR4_Produits
- **Database**: Supabase Product DB
- **Features**: Coffee catalog, inventory, product information

### Order API (Port 8003)
- **Repository**: MSPR4_Commandes  
- **Database**: Supabase Order DB
- **Features**: Order processing, status tracking, order history

### RabbitMQ (Port 15672)
- **Purpose**: Inter-service communication
- **Events**: Customer events, product updates, order notifications

## 🔧 Configuration

### Environment Variables

The platform uses environment variables defined in `.env`:

```bash
# Supabase Database URLs
CUSTOMER_DATABASE_URL=postgresql://postgres:MSPR4_Client@db.kziubeguijtomrtufrlm.supabase.co:5432/postgres
PRODUCT_DATABASE_URL=postgresql://postgres:MSPR4_Produits@db.ujlbrsnqmxxdsibznybx.supabase.co:5432/postgres
ORDER_DATABASE_URL=postgresql://postgres:MSPR4_Commandes@db.kmchiernfkyehxovldwa.supabase.co:5432/postgres

# API Authentication
CUSTOMER_API_TOKEN=supersecrettoken123
PRODUCT_API_TOKEN=supersecrettoken123
ORDER_API_TOKEN=default_token_mspr4_commandes

# RabbitMQ Configuration
RABBITMQ_DEFAULT_USER=admin
RABBITMQ_DEFAULT_PASS=payetonkawa_rabbit
RABBITMQ_DEFAULT_VHOST=payetonkawa
```

### Port Mapping

| Service | External Port | Internal Port | Dockerfile Port |
|---------|---------------|---------------|-----------------|
| Customer API | 8001 | 8002 | 8002 |
| Product API | 8002 | 8003 | 8003 |
| Order API | 8003 | 8001 | 8001 |

## 🔄 Inter-Service Communication

### Message Events

The services communicate via RabbitMQ events:

**Customer Events:**
- `customer.created` - New customer registered
- `customer.updated` - Customer profile updated
- `customer.deleted` - Customer account deleted

**Product Events:**
- `product.created` - New product added
- `product.updated` - Product information updated
- `product.deleted` - Product removed

**Order Events:**
- `order.created` - New order placed
- `order.updated` - Order status changed
- `order.cancelled` - Order cancelled

### API Endpoints

Each service exposes RESTful endpoints:

```
GET    /health                    # Health check
GET    /{resource}               # List all resources
GET    /{resource}/{id}          # Get specific resource
POST   /{resource}               # Create new resource
PUT    /{resource}/{id}          # Update resource
DELETE /{resource}/{id}          # Delete resource
```

## 🧪 Testing

### Manual Testing

1. **Test APIs individually:**
   ```bash
   curl http://localhost:8001/health  # Customer API
   curl http://localhost:8002/health  # Product API
   curl http://localhost:8003/health  # Order API
   ```

2. **Test with authentication:**
   ```bash
   curl -H "Authorization: Bearer supersecrettoken123" \
        http://localhost:8001/clients
   ```

### Automated Testing

```bash
# Run all tests
make test

# Test specific service
docker-compose exec customer-api python -m pytest tests/ -v
```

## 🐛 Troubleshooting

### Common Issues

**🔴 "Connection refused" errors:**
- Check if all services are running: `make status`
- Verify port mapping in docker-compose.yml
- Check Docker Desktop is running

**🔴 "Network unreachable" errors:**
- Verify Supabase connectivity
- Check IPv6 support in Docker Desktop
- Verify database URLs in `.env`

### Debug Commands

```bash
# Check what's running
make ps

# View logs
make logs

# Check specific service
docker-compose logs customer-api

# Access service shell
make shell SERVICE=customer-api

# Test network connectivity
docker exec payetonkawa-customer-api curl http://product-api:8003/health
```

## 📁 Project Structure

```
PayeTonKawa-Orchestrator/
├── docker-compose.yml         # Service orchestration
├── Makefile                   # Automation commands
├── .env                       # Environment variables
├── .env.example              # Environment template
└── README.md                 # This file

../MSPR4_Client/              # Customer API repository
├── app/
├── tests/
├── Dockerfile
└── requirements.txt

../MSPR4_Produits/            # Product API repository  
├── app/
├── tests/
├── Dockerfile
└── requirements.txt

../MSPR4_Commandes/           # Order API repository
├── app/
├── tests/  
├── Dockerfile
└── requirements.txt
```

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [RabbitMQ Management](https://www.rabbitmq.com/management.html)
- [Supabase Documentation](https://supabase.com/docs)
