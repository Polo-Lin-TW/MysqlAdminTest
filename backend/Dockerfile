# Backend Dockerfile for FastAPI application
FROM python:3.10-alpine

# Set working directory
WORKDIR /app

# Copy requirements file first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend source code only
COPY . .

# Create data directory for persistent marker files
RUN mkdir -p /app/data

# Set default environment variables
ENV MYSQL_HOST=car-mysql1 \
    MYSQL_PORT=3306 \
    MYSQL_USER=oa-admin \
    MYSQL_PASSWORD=Bdfrost168 \
    MYSQL_DATABASE=oa \
    DB_INIT_MARKER=/app/data/.db_initialized \
    DB_WAIT_TIMEOUT=30 \
    DB_WAIT_INTERVAL=2

# Copy startup script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose backend port
EXPOSE 8001

# Health check - using the root endpoint since there's no dedicated health endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8001/')" || exit 1

# Use entrypoint script to handle environment variables and startup
ENTRYPOINT ["/app/entrypoint.sh"]