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

## 🚨 Troubleshooting

### Problem 1: Frontend cannot connect to Backend (Container Communication)

**Error symptoms:**
```
GET http://localhost:8001/users 500 (Internal Server Error)
Error fetching users: AxiosError: Request failed with status code 500
timeout of 10000ms exceeded
```

**Root cause:** Frontend container trying to connect to `localhost:8001` instead of using container network.

**Solution:**
1. **Fix API configuration** in `frontend/src/api.js`:
   ```javascript
   // Before (incorrect)
   const API_BASE_URL = 'http://localhost:8001'

   // After (correct)
   const API_BASE_URL = '/api'
   ```

2. **Rebuild frontend container:**
   ```bash
   docker stop mysql-admin-frontend
   docker rm mysql-admin-frontend
   docker build -t mysql-admin-frontend ./frontend
   docker run -d --name mysql-admin-frontend --network mysql-admin-network -p 8081:8081 -e BACKEND_HOST=mysql-admin-backend -e BACKEND_PORT=8001 mysql-admin-frontend
   ```

### Problem 2: Backend cannot connect to External MySQL Database

**Error symptoms:**
```
Error connecting to MySQL: 2003: Can't connect to MySQL server on 'car-mysql'
Connection parameters: host=car-mysql, port=3306, user=oa-admin, database=mysql
```

**Root cause:** Backend container and MySQL container (`car-mysql`) are on different Docker networks.

**Solution:**
1. **Identify MySQL container network:**
   ```bash
   docker inspect car-mysql | grep -A 10 NetworkSettings
   # Found: car-mysql is on kinit-practice_car_network
   ```

2. **Connect backend to MySQL network:**
   ```bash
   docker network connect kinit-practice_car_network mysql-admin-backend
   ```

3. **Verify connectivity:**
   ```bash
   docker exec mysql-admin-backend ping -c 2 car-mysql
   # Should show successful ping responses
   ```

### Problem 3: API Proxy Configuration

**Issue:** Nginx proxy configuration needs to match frontend API calls.

**Configuration in `frontend/nginx.conf`:**
```nginx
# Proxy API requests to FastAPI backend
location /api/ {
    proxy_pass http://${BACKEND_HOST}:${BACKEND_PORT}/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Manual Container Management (Alternative to docker-compose)

When using individual Docker commands instead of docker-compose:

```bash
# Stop and remove containers
docker stop mysql-admin-frontend mysql-admin-backend
docker rm mysql-admin-frontend mysql-admin-backend

# Rebuild images
docker build -t mysql-admin-backend ./backend
docker build -t mysql-admin-frontend ./frontend

# Start backend with proper network and environment
docker run -d --name mysql-admin-backend \
  --network mysql-admin-network \
  -p 8001:8001 \
  --env-file .env \
  mysql-admin-backend

# Connect backend to external MySQL network
docker network connect kinit-practice_car_network mysql-admin-backend

# Start frontend with backend connection
docker run -d --name mysql-admin-frontend \
  --network mysql-admin-network \
  -p 8081:8081 \
  -e BACKEND_HOST=mysql-admin-backend \
  -e BACKEND_PORT=8001 \
  mysql-admin-frontend
```

### Verification Commands

```bash
# Check container status
docker ps | grep mysql-admin

# Test backend API directly
curl -s http://localhost:8001/users

# Check backend logs for errors
docker logs mysql-admin-backend

# Test network connectivity
docker exec mysql-admin-backend ping -c 2 car-mysql

# Access frontend application
curl -s http://localhost:8081
```

## 📝 Notes

- The frontend depends on the backend and will wait for it to be healthy before starting
- Both services restart automatically unless stopped manually
- Persistent data can be added using Docker volumes if needed
- The network is created automatically and can be shared with other services
- When connecting to external databases, ensure containers are on the same network
- Frontend uses nginx proxy configuration to route `/api/*` requests to backend