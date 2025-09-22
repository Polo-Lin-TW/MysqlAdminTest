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

# Expose backend port
EXPOSE 8000

# Health check - using the root endpoint since there's no dedicated health endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')" || exit 1

# Start FastAPI application using the existing app structure
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]