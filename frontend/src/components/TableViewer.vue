<template>
  <div class="table-viewer">
    <div v-if="loading" class="loading">載入中...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    
    <div v-else>
      <!-- 表結構顯示 -->
      <div class="structure-section">
        <h3>表結構</h3>
        <div class="table-container">
          <table class="structure-table">
            <thead>
              <tr>
                <th>欄位名稱</th>
                <th>數據類型</th>
                <th>允許NULL</th>
                <th>默認值</th>
                <th>鍵</th>
                <th>額外</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="column in tableStructure" :key="column.column_name">
                <td class="column-name">{{ column.column_name }}</td>
                <td class="data-type">{{ column.data_type }}</td>
                <td :class="column.is_nullable === 'YES' ? 'nullable-yes' : 'nullable-no'">
                  {{ column.is_nullable === 'YES' ? '是' : '否' }}
                </td>
                <td class="default-value">{{ column.column_default || '-' }}</td>
                <td class="key-info">
                  <span v-if="column.column_key === 'PRI'" class="key-primary">主鍵</span>
                  <span v-else-if="column.column_key === 'UNI'" class="key-unique">唯一</span>
                  <span v-else-if="column.column_key === 'MUL'" class="key-index">索引</span>
                  <span v-else>-</span>
                </td>
                <td class="extra-info">{{ column.extra || '-' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- 表數據顯示 -->
      <div class="data-section">
        <div class="data-header">
          <h3>表數據 (總計: {{ totalRows }} 行)</h3>
          <div class="pagination-controls">
            <button @click="previousPage" :disabled="currentPage === 1">上一頁</button>
            <span>第 {{ currentPage }} 頁 (每頁 {{ pageSize }} 行)</span>
            <button @click="nextPage" :disabled="!hasNextPage">下一頁</button>
          </div>
        </div>
        
        <div class="table-container" v-if="tableData.length > 0">
          <table class="data-table">
            <thead>
              <tr>
                <th v-for="column in tableStructure" :key="column.column_name">
                  {{ column.column_name }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, index) in tableData" :key="index">
                <td v-for="column in tableStructure" :key="column.column_name">
                  <div class="cell-content">{{ formatCellValue(row[column.column_name]) }}</div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <div v-else class="no-data">
          該表沒有數據
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mysqlApi } from '../api.js'

export default {
  name: 'TableViewer',
  props: {
    database: {
      type: String,
      required: true
    },
    table: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      tableStructure: [],
      tableData: [],
      totalRows: 0,
      currentPage: 1,
      pageSize: 50,
      loading: false,
      error: null
    }
  },
  computed: {
    hasNextPage() {
      return this.currentPage * this.pageSize < this.totalRows
    }
  },
  watch: {
    database: 'fetchTableInfo',
    table: 'fetchTableInfo'
  },
  async mounted() {
    await this.fetchTableInfo()
  },
  methods: {
    async fetchTableInfo() {
      if (!this.database || !this.table) return
      
      this.loading = true
      this.error = null
      
      try {
        // 並行獲取表結構和數據
        const [structureResponse, dataResponse] = await Promise.all([
          mysqlApi.getTableStructure(this.database, this.table),
          mysqlApi.getTableData(this.database, this.table, this.pageSize, (this.currentPage - 1) * this.pageSize)
        ])
        
        this.tableStructure = structureResponse.data
        this.tableData = dataResponse.data.rows
        this.totalRows = dataResponse.data.total_rows
        
      } catch (error) {
        this.error = `載入表信息失敗: ${error.message}`
        console.error('Error fetching table info:', error)
      } finally {
        this.loading = false
      }
    },

    async fetchTableData() {
      this.loading = true
      this.error = null
      
      try {
        const response = await mysqlApi.getTableData(
          this.database, 
          this.table, 
          this.pageSize, 
          (this.currentPage - 1) * this.pageSize
        )
        
        this.tableData = response.data.rows
        this.totalRows = response.data.total_rows
        
      } catch (error) {
        this.error = `載入表數據失敗: ${error.message}`
        console.error('Error fetching table data:', error)
      } finally {
        this.loading = false
      }
    },

    async nextPage() {
      if (this.hasNextPage) {
        this.currentPage++
        await this.fetchTableData()
      }
    },

    async previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        await this.fetchTableData()
      }
    },

    formatCellValue(value) {
      if (value === null) return 'NULL'
      if (value === '') return '(空字符串)'
      if (typeof value === 'string' && value.length > 100) {
        return value.substring(0, 100) + '...'
      }
      return value
    }
  }
}
</script>

<style scoped>
.table-viewer {
  margin-top: 20px;
}

.loading {
  text-align: center;
  padding: 40px;
  color: #666;
  font-size: 18px;
}

.error {
  color: #e74c3c;
  padding: 15px;
  background-color: #fdf2f2;
  border: 1px solid #e74c3c;
  border-radius: 4px;
  margin-bottom: 20px;
}

.structure-section,
.data-section {
  margin-bottom: 30px;
}

.structure-section h3,
.data-section h3 {
  margin-bottom: 15px;
  color: #333;
  border-bottom: 2px solid #667eea;
  padding-bottom: 5px;
}

.data-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  flex-wrap: wrap;
  gap: 10px;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 10px;
}

.pagination-controls button {
  padding: 8px 16px;
  border: 1px solid #ddd;
  background-color: white;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.pagination-controls button:hover:not(:disabled) {
  background-color: #f0f0f0;
}

.pagination-controls button:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.table-container {
  overflow-x: auto;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.structure-table,
.data-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 600px;
}

.structure-table th,
.structure-table td,
.data-table th,
.data-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #ddd;
  border-right: 1px solid #ddd;
}

.structure-table th,
.data-table th {
  background-color: #f8f9fa;
  font-weight: bold;
  color: #333;
  position: sticky;
  top: 0;
}

.structure-table tr:hover,
.data-table tr:hover {
  background-color: #f5f5f5;
}

.column-name {
  font-weight: bold;
  color: #2c3e50;
}

.data-type {
  color: #8e44ad;
  font-family: monospace;
}

.nullable-yes {
  color: #27ae60;
}

.nullable-no {
  color: #e74c3c;
}

.key-primary {
  background-color: #e74c3c;
  color: white;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 12px;
}

.key-unique {
  background-color: #f39c12;
  color: white;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 12px;
}

.key-index {
  background-color: #3498db;
  color: white;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 12px;
}

.cell-content {
  max-width: 200px;
  word-break: break-word;
}

.no-data {
  text-align: center;
  padding: 40px;
  color: #666;
  background-color: #f9f9f9;
  border-radius: 4px;
}

@media (max-width: 768px) {
  .data-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .pagination-controls {
    flex-direction: column;
    gap: 5px;
  }
  
  .cell-content {
    max-width: 150px;
  }
}
</style>