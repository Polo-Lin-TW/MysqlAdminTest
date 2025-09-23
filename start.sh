#!/bin/bash

# MySQL Admin Test - Docker Compose Management Script

echo "🚀 MySQL Admin Test - Container Management"
echo "=========================================="

case "$1" in
    "up"|"start")
        echo "📦 Starting MySQL Admin containers..."
        docker-compose up -d --build
        echo "✅ Containers started!"
        echo "🌐 Frontend: http://localhost:8081"
        echo "⚙️  Backend API: http://localhost:8001"
        echo "📚 API Docs: http://localhost:8001/docs"
        ;;
    "down"|"stop")
        echo "🛑 Stopping MySQL Admin containers..."
        docker-compose down
        echo "✅ Containers stopped!"
        ;;
    "restart")
        echo "🔄 Restarting MySQL Admin containers..."
        docker-compose down
        docker-compose up -d --build
        echo "✅ Containers restarted!"
        echo "🌐 Frontend: http://localhost:8081"
        echo "⚙️  Backend API: http://localhost:8001"
        ;;
    "logs")
        echo "📋 Showing container logs..."
        docker-compose logs -f
        ;;
    "status")
        echo "📊 Container Status:"
        docker-compose ps
        ;;
    "clean")
        echo "🧹 Cleaning up containers and images..."
        docker-compose down --rmi all --volumes --remove-orphans
        echo "✅ Cleanup completed!"
        ;;
    *)
        echo "Usage: $0 {up|down|restart|logs|status|clean}"
        echo ""
        echo "Commands:"
        echo "  up/start  - Start containers"
        echo "  down/stop - Stop containers"
        echo "  restart   - Restart containers"
        echo "  logs      - Show container logs"
        echo "  status    - Show container status"
        echo "  clean     - Clean up everything"
        exit 1
        ;;
esac