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
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.selector-group {
  display: flex;
  flex-direction: column;
  min-width: 200px;
  flex: 1;
}

.selector-group label {
  margin-bottom: 8px;
  font-weight: 600;
  color: var(--text-primary);
  font-size: 0.95rem;
}

.selector-group select {
  padding: 12px 16px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  border-radius: 10px;
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.6);
  color: var(--text-primary);
  transition: var(--transition);
  cursor: pointer;
}

.selector-group select:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 12px var(--glow-color);
  background: rgba(255, 255, 255, 0.8);
}

.selector-group select:disabled {
  background: rgba(255, 255, 255, 0.3);
  cursor: not-allowed;
  opacity: 0.6;
}

.loading-text {
  font-size: 0.85rem;
  color: var(--text-secondary);
  margin-top: 6px;
  font-style: italic;
}

.error {
  color: #e74c3c;
  padding: 12px 16px;
  background: rgba(231, 76, 60, 0.1);
  border: 1px solid rgba(231, 76, 60, 0.3);
  border-radius: 10px;
  margin-bottom: 16px;
  backdrop-filter: blur(4px);
}

.selection-info {
  padding: 12px 16px;
  background: rgba(39, 174, 96, 0.15);
  border: 1px solid rgba(39, 174, 96, 0.3);
  border-radius: 10px;
  color: #27ae60;
  font-weight: 500;
  backdrop-filter: blur(4px);
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