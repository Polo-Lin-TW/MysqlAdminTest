# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a MySQL Admin Web Application built with FastAPI (backend) and Vue3 (frontend). The application provides a web interface to connect to MySQL databases and view users, databases, tables, table structures, and data with dropdown selection functionality.

## Development Environment

The project uses:
- **Backend**: Python 3.10.18 with FastAPI, managed via uv virtual environment
- **Frontend**: Vue3 with Vite build tool
- **Database**: MySQL connector for Python
- **Git** for version control

## Essential Commands

### Backend Development
```bash
# Activate virtual environment
source .venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Start backend server (development)
cd backend && python run.py
# Or use the startup script
./start_backend.sh

# Backend runs on http://localhost:8000
```

### Frontend Development
```bash
# Install Node.js dependencies
cd frontend && npm install

# Start frontend development server
npm run dev
# Or use the startup script
./start_frontend.sh

# Frontend runs on http://localhost:5173
```

### Database Configuration
Copy and configure environment variables:
```bash
cp .env.example .env
# Edit .env with your MySQL connection details
```

## Project Structure

```
MysqlAdminTest/
├── backend/                # FastAPI backend application
│   ├── app/
│   │   ├── main.py        # Main FastAPI application with API endpoints
│   │   ├── database.py    # MySQL connection and query execution
│   │   ├── models.py      # Pydantic data models
│   │   └── __init__.py
│   └── run.py             # Backend startup script
├── frontend/              # Vue3 frontend application
│   ├── src/
│   │   ├── components/    # Vue components
│   │   │   ├── UserList.vue           # MySQL users display
│   │   │   ├── DatabaseTableSelector.vue  # Dropdown selectors
│   │   │   └── TableViewer.vue        # Table structure and data viewer
│   │   ├── App.vue        # Main application component
│   │   ├── main.js        # Vue application entry point
│   │   └── api.js         # API service layer
│   ├── package.json       # Node.js dependencies
│   └── vite.config.js     # Vite configuration
├── .env.example           # Environment variables template
├── requirements.txt       # Python dependencies
└── startup scripts        # start_backend.sh, start_frontend.sh
```

## Architecture Notes

### Backend Architecture (FastAPI)
- **main.py**: Contains all API endpoints with CORS configuration
- **database.py**: MySQL connection management and query execution
- **models.py**: Pydantic models for API responses
- **API Endpoints**:
  - `/users` - Get MySQL users list
  - `/databases` - Get databases list
  - `/databases/{db}/tables` - Get tables in database
  - `/databases/{db}/tables/{table}/structure` - Get table structure
  - `/databases/{db}/tables/{table}/data` - Get table data with pagination

### Frontend Architecture (Vue3)
- **App.vue**: Main layout with three sections (users, selectors, table viewer)
- **UserList.vue**: Displays MySQL users with status information
- **DatabaseTableSelector.vue**: Dropdown menus for database and table selection
- **TableViewer.vue**: Shows table structure and paginated data
- **api.js**: Centralized API service using axios

### Database Connection
- Uses mysql-connector-python for database connectivity
- Connection configuration via environment variables
- Supports multiple database selection and querying

## Dependencies

### Backend (Python)
- `fastapi==0.104.1` - Web framework
- `uvicorn==0.24.0` - ASGI server
- `mysql-connector-python==8.2.0` - MySQL database connector
- `python-dotenv==1.0.0` - Environment variable management
- `pydantic==2.5.0` - Data validation

### Frontend (Node.js)
- `vue@^3.3.8` - Vue.js framework
- `axios@^1.6.0` - HTTP client
- `@vitejs/plugin-vue@^4.5.0` - Vite Vue plugin
- `vite@^5.0.0` - Build tool

## Development Workflow

1. **Environment Setup**: Configure .env file with MySQL credentials
2. **Backend Development**: Start with `./start_backend.sh` or manual commands
3. **Frontend Development**: Start with `./start_frontend.sh` or npm commands
4. **Testing**: Access application at http://localhost:5173
5. **API Testing**: Backend API docs available at http://localhost:8000/docs

## Security Considerations

- Database credentials stored in .env file (not committed)
- CORS configured for development (localhost:5173)
- MySQL user permissions should be minimal for security
- No authentication implemented (development only)

## Common Development Tasks

- **Add new API endpoint**: Modify `backend/app/main.py`
- **Add new Vue component**: Create in `frontend/src/components/`
- **Update database queries**: Modify `backend/app/database.py`
- **Change API responses**: Update `backend/app/models.py`
- **Frontend styling**: Modify component `<style>` sections