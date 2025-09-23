from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from .database import db
from .models import DatabaseInfo, TableInfo, UserInfo, TableData, ColumnInfo

app = FastAPI(title="MySQL Admin API", version="1.0.0")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173", "http://localhost:8081"],  # Vue dev server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "MySQL Admin API"}

@app.get("/users", response_model=List[UserInfo])
async def get_users():
    """獲取MySQL用戶列表"""
    query = """
    SELECT
        user,
        host,
        account_locked,
        password_expired
    FROM mysql.user
    ORDER BY user, host
    """

    try:
        # Add debugging query to check connection
        debug_query = "SELECT @@hostname as hostname, @@port as port"
        debug_result = db.execute_query(debug_query, database="mysql")
        print(f"Connected to MySQL at: {debug_result}")

        # Connect to mysql database to query user table
        result = db.execute_query(query, database="mysql")
        if result is None:
            raise HTTPException(status_code=500, detail="Database connection failed")

        print(f"Found {len(result)} users")
        users = []
        for row in result:
            print(f"User: {row}")
            users.append(UserInfo(**row))

        return users
    except Exception as e:
        print(f"Error in get_users: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error fetching users: {str(e)}")

@app.get("/databases", response_model=List[DatabaseInfo])
async def get_databases():
    """獲取數據庫列表"""
    query = "SHOW DATABASES"
    
    try:
        result = db.execute_query(query)
        if result is None:
            raise HTTPException(status_code=500, detail="Database connection failed")
        
        databases = []
        for row in result:
            # SHOW DATABASES returns different column names
            db_name = row.get('Database') or row.get('database') or list(row.values())[0]
            databases.append(DatabaseInfo(name=db_name))
        
        return databases
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching databases: {str(e)}")

@app.get("/databases/{database_name}/tables", response_model=List[TableInfo])
async def get_tables(database_name: str):
    """獲取指定數據庫的表列表"""
    query = f"SHOW TABLES FROM `{database_name}`"
    
    try:
        result = db.execute_query(query, database=database_name)
        if result is None:
            raise HTTPException(status_code=500, detail="Database connection failed")
        
        tables = []
        for row in result:
            # SHOW TABLES returns different column names depending on database
            table_name = list(row.values())[0]  # Get the first (and only) value
            tables.append(TableInfo(name=table_name, database=database_name))
        
        return tables
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching tables: {str(e)}")

@app.get("/databases/{database_name}/tables/{table_name}/structure", response_model=List[ColumnInfo])
async def get_table_structure(database_name: str, table_name: str):
    """獲取表結構"""
    query = f"""
    SELECT 
        COLUMN_NAME as column_name,
        DATA_TYPE as data_type,
        IS_NULLABLE as is_nullable,
        COLUMN_DEFAULT as column_default,
        COLUMN_KEY as column_key,
        EXTRA as extra
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = '{database_name}' AND TABLE_NAME = '{table_name}'
    ORDER BY ORDINAL_POSITION
    """
    
    try:
        result = db.execute_query(query)
        if result is None:
            raise HTTPException(status_code=500, detail="Database connection failed")
        
        columns = []
        for row in result:
            columns.append(ColumnInfo(**row))
        
        return columns
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching table structure: {str(e)}")

@app.get("/databases/{database_name}/tables/{table_name}/data")
async def get_table_data(database_name: str, table_name: str, limit: int = 100, offset: int = 0):
    """獲取表數據"""
    try:
        # Get table structure first
        structure_query = f"""
        SELECT 
            COLUMN_NAME as column_name,
            DATA_TYPE as data_type,
            IS_NULLABLE as is_nullable,
            COLUMN_DEFAULT as column_default,
            COLUMN_KEY as column_key,
            EXTRA as extra
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = '{database_name}' AND TABLE_NAME = '{table_name}'
        ORDER BY ORDINAL_POSITION
        """
        
        structure_result = db.execute_query(structure_query)
        if structure_result is None:
            raise HTTPException(status_code=500, detail="Database connection failed")
        
        columns = [ColumnInfo(**row) for row in structure_result]
        
        # Get data
        data_query = f"SELECT * FROM `{database_name}`.`{table_name}` LIMIT {limit} OFFSET {offset}"
        data_result = db.execute_query(data_query, database=database_name)
        
        if data_result is None:
            data_result = []
        
        # Get total count
        count_query = f"SELECT COUNT(*) as total FROM `{database_name}`.`{table_name}`"
        count_result = db.execute_query(count_query, database=database_name)
        total_rows = count_result[0]['total'] if count_result else 0
        
        return TableData(
            columns=columns,
            rows=data_result,
            total_rows=total_rows
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching table data: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)