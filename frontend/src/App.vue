<template>
  <div id="app">
    <div class="header">
      <h1>MySQL 管理工具</h1>
    </div>
    
    <div class="container">
      <!-- 用戶信息區域 -->
      <div class="section">
        <h2>MySQL 用戶</h2>
        <UserList />
      </div>

      <!-- 數據庫和表選擇區域 -->
      <div class="section">
        <h2>數據庫和表管理</h2>
        <DatabaseTableSelector 
          @database-selected="onDatabaseSelected"
          @table-selected="onTableSelected"
        />
      </div>

      <!-- 表結構和數據顯示區域 -->
      <div class="section" v-if="selectedTable">
        <h2>表: {{ selectedDatabase }}.{{ selectedTable }}</h2>
        <TableViewer 
          :database="selectedDatabase"
          :table="selectedTable"
          :key="tableKey"
        />
      </div>
    </div>
  </div>
</template>

<script>
import UserList from './components/UserList.vue'
import DatabaseTableSelector from './components/DatabaseTableSelector.vue'
import TableViewer from './components/TableViewer.vue'

export default {
  name: 'App',
  components: {
    UserList,
    DatabaseTableSelector,
    TableViewer
  },
  data() {
    return {
      selectedDatabase: '',
      selectedTable: '',
      tableKey: 0 // 用於強制重新渲染TableViewer
    }
  },
  methods: {
    onDatabaseSelected(database) {
      this.selectedDatabase = database
      this.selectedTable = ''
      this.tableKey++
    },
    onTableSelected(table) {
      this.selectedTable = table
      this.tableKey++
    }
  }
}
</script>

<style>
#app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.header {
  text-align: center;
  margin-bottom: 30px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 10px;
}

.header h1 {
  margin: 0;
  font-size: 2rem;
}

.container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.section h2 {
  margin-top: 0;
  color: #333;
  border-bottom: 2px solid #667eea;
  padding-bottom: 10px;
}

/* 響應式設計 */
@media (min-width: 768px) {
  .container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
  }
  
  .section:last-child {
    grid-column: 1 / -1;
  }
}
</style>