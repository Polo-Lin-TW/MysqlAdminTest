#!/bin/bash

echo "🧪 Quick Test - MySQL Admin Application"
echo "======================================="

echo ""
echo "1️⃣  Testing Backend API..."
BACKEND_RESPONSE=$(curl -s http://localhost:8000)
if [ $? -eq 0 ]; then
    echo "✅ Backend responding: $BACKEND_RESPONSE"
else
    echo "❌ Backend not responding"
    exit 1
fi

echo ""
echo "2️⃣  Testing API Documentation..."
DOC_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/docs)
if [ "$DOC_STATUS" = "200" ]; then
    echo "✅ API docs available at http://localhost:8000/docs"
else
    echo "❌ API docs not available (Status: $DOC_STATUS)"
fi

echo ""
echo "3️⃣  Testing Frontend..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081)
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ Frontend available at http://localhost:8081"
else
    echo "❌ Frontend not available (Status: $FRONTEND_STATUS)"
fi

echo ""
echo "🎉 All tests completed!"
echo ""
echo "🚀 Ready to use:"
echo "   Open http://localhost:8081 in your browser"