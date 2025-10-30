#!/bin/sh

# 設置環境變數 (優先使用環境變數,如果沒有則使用預設值)
export MYSQL_HOST=${MYSQL_HOST:-car-mysql}
export MYSQL_PORT=${MYSQL_PORT:-3306}
export MYSQL_USER=${MYSQL_USER:-oa-admin}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-Bdfrost168}
export MYSQL_DATABASE=${MYSQL_DATABASE:-oa}

# 設置持久化標記檔案路徑
export DB_INIT_MARKER=${DB_INIT_MARKER:-/app/data/.db_initialized}

# 設置資料庫連接超時配置
export DB_WAIT_TIMEOUT=${DB_WAIT_TIMEOUT:-30}    # 最多等待次數 (預設30次)
export DB_WAIT_INTERVAL=${DB_WAIT_INTERVAL:-2}   # 每次等待間隔秒數 (預設2秒)

echo "========================================="
echo "Environment variables:"
echo "========================================="
echo "MYSQL_HOST: $MYSQL_HOST"
echo "MYSQL_PORT: $MYSQL_PORT"
echo "MYSQL_USER: $MYSQL_USER"
echo "MYSQL_DATABASE: $MYSQL_DATABASE"
echo "DB_WAIT_TIMEOUT: $DB_WAIT_TIMEOUT (total wait: $((DB_WAIT_TIMEOUT * DB_WAIT_INTERVAL))s)"
echo "DB_INIT_MARKER: $DB_INIT_MARKER"
echo "========================================="

# 等待 MySQL 資料庫準備就緒
echo "Waiting for MySQL database to be ready..."
counter=0
while [ $counter -lt $DB_WAIT_TIMEOUT ]; do
    # 使用 Python 檢查資料庫連接
    python3 -c "
import mysql.connector
import os
import sys

try:
    conn = mysql.connector.connect(
        host='${MYSQL_HOST}',
        port=${MYSQL_PORT},
        user='${MYSQL_USER}',
        password='${MYSQL_PASSWORD}',
        database='${MYSQL_DATABASE}',
        connect_timeout=5
    )
    conn.close()
    print('Database connection successful!')
    sys.exit(0)
except Exception as e:
    print(f'Database connection failed: {e}')
    sys.exit(1)
" 2>&1

    if [ $? -eq 0 ]; then
        echo "Database is ready!"

        # 檢查是否需要創建初始化標記
        if [ ! -f "$DB_INIT_MARKER" ]; then
            echo "Creating initialization marker at $DB_INIT_MARKER"
            touch "$DB_INIT_MARKER"
            echo "Database initialized at $(date)" > "$DB_INIT_MARKER"
        else
            echo "Database already initialized. Marker found at $DB_INIT_MARKER"
        fi

        break
    fi

    counter=$((counter + 1))
    echo "Attempt $counter/$DB_WAIT_TIMEOUT failed. Waiting ${DB_WAIT_INTERVAL}s before retry..."
    sleep $DB_WAIT_INTERVAL
done

if [ $counter -eq $DB_WAIT_TIMEOUT ]; then
    echo "ERROR: Could not connect to database after $((DB_WAIT_TIMEOUT * DB_WAIT_INTERVAL)) seconds"
    exit 1
fi

echo "========================================="
echo "Starting FastAPI application..."
echo "========================================="

# 啟動 FastAPI 應用
exec uvicorn app.main:app --host 0.0.0.0 --port 8001
