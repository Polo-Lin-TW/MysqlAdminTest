<template>
  <div class="selector">
    <div class="selector-row">
      <div class="selector-group">
        <label for="database-select">選擇數據庫:</label>
        <select 
          id="database-select"
          v-model="selectedDatabase" 
          @change="onDatabaseChange"
          :disabled="loadingDatabases"
        >
          <option value="">-- 請選擇數據庫 --</option>
          <option 
            v-for="database in databases" 
            :key="database.name" 
            :value="database.name"
          >
            {{ database.name }}
          </option>
        </select>
        <span v-if="loadingDatabases" class="loading-text">載入中...</span>
      </div>

      <div class="selector-group">
        <label for="table-select">選擇表:</label>
        <select 
          id="table-select"
          v-model="selectedTable" 
          @change="onTableChange"
          :disabled="!selectedDatabase || loadingTables"
        >
          <option value="">-- 請選擇表 --</option>
          <option 
            v-for="table in tables" 
            :key="table.name" 
            :value="table.name"
          >
            {{ table.name }}
          </option>
        </select>
        <span v-if="loadingTables" class="loading-text">載入中...</span>
      </div>
    </div>

    <div v-if="error" class="error">{{ error }}</div>

    <div v-if="selectedDatabase && selectedTable" class="selection-info">
      <strong>已選擇:</strong> {{ selectedDatabase }}.{{ selectedTable }}
    </div>
  </div>
</template>

<script>
import { mysqlApi } from '../api.js';

export default {
  name: 'DatabaseTableSelector',
  emits: ['database-selected', 'table-selected'],
  data() {
    return {
      databases: [],
      tables: [],
      selectedDatabase: '',
      selectedTable: '',
      loadingDatabases: false,
      loadingTables: false,
      error: null
    }
  },
  async mounted() {
    await this.fetchDatabases()
  },
  methods: {
    async fetchDatabases() {
      this.loadingDatabases = true
      this.error = null

      try {
        const response = await mysqlApi.getDatabases()
        this.databases = response.data

        // 自動選擇 "oa" 數據庫
        const oaDatabase = this.databases.find(db => db.name === 'oa')
        if (oaDatabase) {
          this.selectedDatabase = 'oa'
          await this.fetchTables('oa')
          this.$emit('database-selected', 'oa')
        }
      } catch (error) {
        this.error = `載入數據庫失敗: ${error.message}`
        console.error('Error fetching databases:', error)
      } finally {
        this.loadingDatabases = false
      }
    },

    async fetchTables(databaseName) {
      if (!databaseName) return
      
      this.loadingTables = true
      this.error = null
      
      try {
        const response = await mysqlApi.getTables(databaseName)
        this.tables = response.data
      } catch (error) {
        this.error = `載入表失敗: ${error.message}`
        console.error('Error fetching tables:', error)
        this.tables = []
      } finally {
        this.loadingTables = false
      }
    },

    async onDatabaseChange() {
      this.selectedTable = ''
      this.tables = []
      
      if (this.selectedDatabase) {
        await this.fetchTables(this.selectedDatabase)
        this.$emit('database-selected', this.selectedDatabase)
      }
    },

    onTableChange() {
      if (this.selectedTable) {
        this.$emit('table-selected', this.selectedTable)
      }
    }
  }
}
</script>

<style scoped>
.selector {
  margin-top: 10px;
}

.selector-row {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
  flex-wrap: wrap;
}

.selector-group {
  display: flex;
  flex-direction: column;
  min-width: 200px;
  flex: 1;
}

.selector-group label {
  margin-bottom: 5px;
  font-weight: bold;
  color: #333;
}

.selector-group select {
  padding: 10px;
  border: 2px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  background-color: white;
  transition: border-color 0.3s;
}

.selector-group select:focus {
  outline: none;
  border-color: #667eea;
}

.selector-group select:disabled {
  background-color: #f5f5f5;
  cursor: not-allowed;
}

.loading-text {
  font-size: 12px;
  color: #666;
  margin-top: 5px;
}

.error {
  color: #e74c3c;
  padding: 10px;
  background-color: #fdf2f2;
  border: 1px solid #e74c3c;
  border-radius: 4px;
  margin-bottom: 10px;
}

.selection-info {
  padding: 10px;
  background-color: #e8f5e8;
  border: 1px solid #27ae60;
  border-radius: 4px;
  color: #27ae60;
}

@media (max-width: 600px) {
  .selector-row {
    flex-direction: column;
  }
  
  .selector-group {
    min-width: auto;
  }
}
</style>