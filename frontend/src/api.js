import axios from 'axios'

// Use relative URL to leverage nginx proxy configuration
const API_BASE_URL = '/api'
// const API_BASE_URL = 'http://localhost:8001'

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
})

export const mysqlApi = {
  // 獲取用戶列表
  getUsers: () => api.get('/users'),
  
  // 獲取數據庫列表
  getDatabases: () => api.get('/databases'),
  
  // 獲取指定數據庫的表列表
  getTables: (databaseName) => api.get(`/databases/${databaseName}/tables`),
  
  // 獲取表結構
  getTableStructure: (databaseName, tableName) => 
    api.get(`/databases/${databaseName}/tables/${tableName}/structure`),
  
  // 獲取表數據
  getTableData: (databaseName, tableName, limit = 100, offset = 0) => 
    api.get(`/databases/${databaseName}/tables/${tableName}/data`, {
      params: { limit, offset }
    })
}

export default api