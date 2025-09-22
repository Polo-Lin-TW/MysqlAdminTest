#!/bin/bash

echo "啟動 FastAPI 後端服務..."

# 檢查虛擬環境是否已激活
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "激活虛擬環境..."
    source .venv/bin/activate
fi

# 安裝依賴
echo "安裝 Python 依賴..."
uv pip install -r requirements.txt

# 設置環境變量
export PYTHONPATH="${PYTHONPATH}:$(pwd)/backend"

# 啟動後端服務
echo "啟動後端服務 (http://localhost:8000)..."
cd backend
python run.py