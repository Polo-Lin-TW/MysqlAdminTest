# MySQL Admin Test - Docker Setup

This project uses Docker Compose to manage the MySQL Admin application with a FastAPI backend and Vue.js frontend.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │
│   Vue.js + Nginx│◄──►│   FastAPI       │
│   Port: 8081    │    │   Port: 8000    │
└─────────────────┘    └─────────────────┘
         │                        │
         └────────┬─────────────────┘
                  │
         ┌─────────────────┐
         │  Docker Network │
         │ mysql-admin-net │
         └─────────────────┘
```

## 🚀 Quick Start

### Option 1: Using Docker Compose directly
```bash
# Start all services
docker-compose up -d --build

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### Option 2: Using the management script
```bash
# Make script executable
chmod +x start.sh

# Start containers
./start.sh up

# Stop containers
./start.sh down

# Restart containers
./start.sh restart

# View logs
./start.sh logs

# Check status
./start.sh status

# Clean up everything
./start.sh clean
```

## 🌐 Access Points

- **Frontend (Web UI)**: http://localhost:8081
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **OpenAPI Schema**: http://localhost:8000/openapi.json

## 📋 Services

### Backend (mysql-admin-backend)
- **Technology**: FastAPI + Python 3.10
- **Port**: 8000
- **Health Check**: HTTP GET to `/`
- **Features**: REST API for MySQL administration

### Frontend (mysql-admin-frontend)
- **Technology**: Vue.js + Vite + Nginx
- **Port**: 8081
- **Health Check**: HTTP GET to `/`
- **Features**: Web interface for MySQL administration

## 🔧 Configuration

### Environment Variables

The frontend automatically configures itself to communicate with the backend using:
- `BACKEND_HOST=mysql-admin-backend`
- `BACKEND_PORT=8000`

### Network

Both services run on the `mysql-admin-network` Docker network, allowing them to communicate using container names.

## 📊 Health Checks

Both services include health checks:
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3
- **Start Period**: 5 seconds

## 🛠️ Development

### Rebuilding Services
```bash
# Rebuild and restart all services
docker-compose up -d --build

# Rebuild specific service
docker-compose build mysql-admin-backend
docker-compose up -d mysql-admin-backend
```

### Viewing Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f mysql-admin-backend
docker-compose logs -f mysql-admin-frontend
```

### Debugging
```bash
# Execute commands in running containers
docker-compose exec mysql-admin-backend /bin/sh
docker-compose exec mysql-admin-frontend /bin/sh
```

## 🧹 Cleanup

```bash
# Stop and remove containers
docker-compose down

# Remove containers, networks, and images
docker-compose down --rmi all --volumes --remove-orphans

# Or use the script
./start.sh clean
```

## 📝 Notes

- The frontend depends on the backend and will wait for it to be healthy before starting
- Both services restart automatically unless stopped manually
- Persistent data can be added using Docker volumes if needed
- The network is created automatically and can be shared with other services