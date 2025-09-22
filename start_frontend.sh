#!/bin/bash

echo "啟動 Vue3 前端應用..."

cd frontend

# 檢查 node_modules 是否存在
if [ ! -d "node_modules" ]; then
    echo "安裝 npm 依賴..."
    npm install
fi

# 啟動前端開發服務器
echo "啟動前端服務 (http://localhost:5173)..."
npm run dev