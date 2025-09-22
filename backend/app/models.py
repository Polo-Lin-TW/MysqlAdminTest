from pydantic import BaseModel
from typing import List, Any, Optional

class DatabaseInfo(BaseModel):
    name: str

class TableInfo(BaseModel):
    name: str
    database: str

class ColumnInfo(BaseModel):
    column_name: str
    data_type: str
    is_nullable: str
    column_default: Optional[str]
    column_key: str
    extra: str

class UserInfo(BaseModel):
    user: str
    host: str
    account_locked: str
    password_expired: str

class TableData(BaseModel):
    columns: List[ColumnInfo]
    rows: List[dict]
    total_rows: int