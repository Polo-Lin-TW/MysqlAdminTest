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
import { mysqlApi } from '../api.js';

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
      pageSize: 20,
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
  color: var(--text-secondary);
  font-size: 1.1rem;
}

.error {
  color: #e74c3c;
  padding: 12px 16px;
  background: rgba(231, 76, 60, 0.1);
  border: 1px solid rgba(231, 76, 60, 0.3);
  border-radius: 10px;
  margin-bottom: 20px;
  backdrop-filter: blur(4px);
}

.structure-section,
.data-section {
  margin-bottom: 32px;
}

.structure-section h3,
.data-section h3 {
  margin-bottom: 16px;
  color: var(--text-primary);
  font-size: 1.2rem;
  font-weight: 600;
  padding-bottom: 8px;
  border-bottom: 2px solid var(--primary-color);
}

.data-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-wrap: wrap;
  gap: 12px;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.pagination-controls button {
  padding: 10px 20px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  background: rgba(255, 255, 255, 0.6);
  border-radius: 30px;
  cursor: pointer;
  transition: var(--transition);
  font-weight: 500;
  color: var(--text-primary);
}

.pagination-controls button:hover:not(:disabled) {
  background: var(--primary-gradient);
  color: white;
  border-color: transparent;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px var(--glow-color);
}

.pagination-controls button:disabled {
  cursor: not-allowed;
  opacity: 0.4;
}

.pagination-controls span {
  color: var(--text-secondary);
  font-weight: 500;
}

.table-container {
  overflow-x: auto;
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.3);
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
  padding: 14px 16px;
  text-align: left;
  border-bottom: 1px solid rgba(255, 255, 255, 0.3);
  border-right: 1px solid rgba(255, 255, 255, 0.3);
}

.structure-table th,
.data-table th {
  background: rgba(255, 255, 255, 0.5);
  font-weight: 600;
  color: var(--text-primary);
  position: sticky;
  top: 0;
  font-size: 0.9rem;
}

.structure-table tbody tr,
.data-table tbody tr {
  transition: var(--transition);
}

.structure-table tbody tr:hover,
.data-table tbody tr:hover {
  background: rgba(255, 255, 255, 0.4);
}

.structure-table tbody tr:last-child td,
.data-table tbody tr:last-child td {
  border-bottom: none;
}

.column-name {
  font-weight: 600;
  color: var(--text-primary);
}

.data-type {
  color: #8e44ad;
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
}

.nullable-yes {
  color: #27ae60;
  font-weight: 500;
}

.nullable-no {
  color: #e74c3c;
  font-weight: 500;
}

.key-primary {
  background: linear-gradient(135deg, #e74c3c, #c0392b);
  color: white;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  display: inline-block;
}

.key-unique {
  background: linear-gradient(135deg, #f39c12, #e67e22);
  color: white;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  display: inline-block;
}

.key-index {
  background: linear-gradient(135deg, #3498db, #2980b9);
  color: white;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  display: inline-block;
}

.cell-content {
  max-width: 200px;
  word-break: break-word;
}

.no-data {
  text-align: center;
  padding: 40px;
  color: var(--text-secondary);
  background: rgba(255, 255, 255, 0.2);
  border-radius: 10px;
  font-size: 1rem;
}

@media (max-width: 768px) {
  .data-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .pagination-controls {
    width: 100%;
    justify-content: space-between;
  }

  .cell-content {
    max-width: 150px;
  }
}
</style>