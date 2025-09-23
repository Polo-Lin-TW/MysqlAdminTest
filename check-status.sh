#!/bin/bash

echo "🔍 MySQL Admin Test - Status Check"
echo "=================================="

echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "🌐 Testing Services:"

echo -n "  Backend (http://localhost:8001): "
if curl -s http://localhost:8001 > /dev/null 2>&1; then
    echo "✅ Running"
    BACKEND_RESPONSE=$(curl -s http://localhost:8001)
    echo "    Response: $BACKEND_RESPONSE"
else
    echo "❌ Not responding"
fi

echo -n "  Frontend (http://localhost:8081): "
if curl -s -I http://localhost:8081 | grep -q "200 OK"; then
    echo "✅ Running"
else
    echo "❌ Not responding"
fi

echo ""
echo "🔗 Access URLs:"
echo "  🌐 Frontend (Web UI): http://localhost:8081"
echo "  ⚙️  Backend API: http://localhost:8001"
echo "  📚 API Documentation: http://localhost:8001/docs"

echo ""
echo "📋 Recent logs:"
echo "--- Backend logs ---"
docker-compose logs --tail=5 mysql-admin-backend

echo "--- Frontend logs ---"
docker-compose logs --tail=5 mysql-admin-frontend