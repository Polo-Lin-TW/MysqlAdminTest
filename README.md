# MySQL Admin Web App

一個基於FastAPI和Vue3的MySQL管理工具，可以連接MySQL數據庫並提供Web界面來查看用戶、數據庫、表結構和數據。

## 功能特性

1. **MySQL連接** - 連接到MySQL數據庫
2. **用戶管理** - 顯示MySQL用戶列表及其狀態
3. **數據庫瀏覽** - 列出所有數據庫
4. **表管理** - 下拉選單選擇數據庫和表
5. **表結構查看** - 顯示表的欄位信息
6. **數據瀏覽** - 分頁顯示表數據

## 項目結構

```
MysqlAdminTest/
├── backend/                # FastAPI 後端
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py        # 主應用程序
│   │   ├── database.py    # 數據庫連接
│   │   └── models.py      # 數據模型
│   └── run.py             # 後端啟動腳本
├── frontend/              # Vue3 前端
│   ├── src/
│   │   ├── components/    # Vue 組件
│   │   ├── App.vue        # 主組件
│   │   ├── main.js        # 主入口
│   │   └── api.js         # API 服務
│   ├── package.json
│   └── vite.config.js
├── .env.example           # 環境變量範例
├── requirements.txt       # Python 依賴
├── start_backend.sh       # 後端啟動腳本
└── start_frontend.sh      # 前端啟動腳本
```

## 安裝和運行

### 前置條件

- Python 3.10+
- Node.js 16+
- MySQL 數據庫服務器
- Visual Studio Code（推薦）

### 1. 配置數據庫連接

複製環境變量範例文件並配置：

```bash
cp .env.example .env
```

編輯 `.env` 文件，設置您的MySQL連接信息：

```env
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=your_mysql_user
MYSQL_PASSWORD=your_mysql_password
MYSQL_DATABASE=mysql
```

### 2. 啟動後端服務

```bash
# 方法1: 使用啟動腳本
./start_backend.sh

# 方法2: 手動啟動
source .venv/bin/activate
pip install -r requirements.txt
cd backend
python run.py
```

後端服務將在 http://localhost:8000 啟動

### 3. 啟動前端服務

打開新終端窗口：

```bash
# 方法1: 使用啟動腳本
./start_frontend.sh

# 方法2: 手動啟動
cd frontend
npm install
npm run dev
```

前端服務將在 http://localhost:5173 啟動

### 4. 使用VS Code調試（推薦）

如果您使用VS Code，可以使用預配置的調試設置：

1. **打開項目**：
   ```bash
   code .
   ```

2. **安裝推薦擴展**：VS Code會自動提示安裝推薦的擴展

3. **啟動調試**：
   - 按 `F5` 或去到「執行和調試」面板
   - 選擇以下配置之一：
     - `🚀 Start Backend (FastAPI)` - 啟動後端服務
     - `🎨 Start Frontend (Vue3)` - 啟動前端服務  
     - `🚀 Start Full Application` - 同時啟動前後端
     - `🔧 Backend Debug Mode` - 後端調試模式

4. **API測試**：
   - 打開 `.vscode/api-test.http` 文件
   - 點擊「Send Request」按鈕測試API端點

5. **任務運行**：
   - 按 `Ctrl+Shift+P` 輸入「Tasks: Run Task」
   - 選擇預定義的任務（安裝依賴、構建等）

### 5. 手動啟動（替代方案）

如果不使用VS Code，可以使用命令行：

```bash
# 方法1: 使用啟動腳本
./start_backend.sh
./start_frontend.sh

# 方法2: 手動啟動
source .venv/bin/activate
pip install -r requirements.txt
cd backend && python run.py

# 在新終端窗口
cd frontend
npm install
npm run dev
```

### 6. 訪問應用

打開瀏覽器訪問 http://localhost:5173

## API 端點

後端提供以下API端點：

- `GET /` - API根路徑
- `GET /users` - 獲取MySQL用戶列表
- `GET /databases` - 獲取數據庫列表
- `GET /databases/{database}/tables` - 獲取指定數據庫的表列表
- `GET /databases/{database}/tables/{table}/structure` - 獲取表結構
- `GET /databases/{database}/tables/{table}/data` - 獲取表數據（支持分頁）

## 使用說明

1. **查看用戶**: 應用啟動後會自動顯示MySQL用戶列表
2. **選擇數據庫**: 在下拉選單中選擇要查看的數據庫
3. **選擇表**: 選擇數據庫後，在表下拉選單中選擇要查看的表
4. **查看結構**: 選擇表後會顯示表的欄位結構信息
5. **瀏覽數據**: 在表數據區域可以分頁瀏覽表中的數據

## 安全注意事項

- 請勿在生產環境中使用默認配置
- 確保MySQL用戶權限最小化
- 不要將數據庫密碼提交到版本控制系統
- 考慮使用HTTPS和適當的身份驗證

## 開發

### 後端開發

- 後端使用FastAPI框架
- 數據庫連接使用mysql-connector-python
- 支持跨域請求(CORS)

### 前端開發

- 前端使用Vue3 + Vite
- 使用axios進行API請求
- 響應式設計，支持移動設備

## VS Code 調試功能詳細說明

### 調試配置說明

1. **🚀 Start Backend (FastAPI)**
   - 啟動FastAPI後端服務
   - 支持斷點調試
   - 自動載入.env環境變數

2. **🎨 Start Frontend (Vue3)**
   - 啟動Vue3開發服務器
   - 支持熱重載
   - 自動打開瀏覽器

3. **🚀 Start Full Application**
   - 同時啟動前後端服務
   - 一鍵啟動完整應用

4. **🔧 Backend Debug Mode**
   - 後端調試模式
   - 支持進階調試功能
   - 可設置斷點和步進執行

### 可用任務

- `📦 Install Backend Dependencies` - 安裝Python依賴
- `📦 Install Frontend Dependencies` - 安裝Node.js依賴
- `🔧 Activate Virtual Environment` - 激活虛擬環境
- `🏗️ Build Frontend` - 構建生產版本
- `🧪 Test Backend API` - 測試後端 API

### API 測試文件

使用 `.vscode/api-test.http` 文件可以直接在VS Code中測試API：
- 測試所有API端點
- 查看請求和回應
- 支持變數和環境配置

## 故障排除

1. **無法連接數據庫**: 檢查.env文件中的數據庫配置
2. **前端無法訪問後端**: 確保後端服務在8000端口運行
3. **權限錯誤**: 確保MySQL用戶有足夠的權限查看系統表
4. **VS Code Python解釋器**: 確保選擇了正確的Python解釋器 (`.venv/bin/python`)
5. **端口占用**: 如果8000或5173端口被占用，請停止相關服務

## License

MIT License