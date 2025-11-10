<template>
  <div id="app">
    <div class="app-header">
      <h1>MySQL 管理工具</h1>
      <p>現代化數據庫管理介面</p>
    </div>

    <div class="container">
      <!-- 用戶信息區域 -->
      <div class="glass-card">
        <h1>MySQL 用戶</h1>
        <UserList />
      </div>

      <!-- 數據庫和表選擇區域 -->
      <div class="glass-card">
        <h1>數據庫和表管理</h1>
        <DatabaseTableSelector
          @database-selected="onDatabaseSelected"
          @table-selected="onTableSelected"
        />
      </div>

      <!-- 表結構和數據顯示區域 -->
      <div class="glass-card" v-if="selectedTable">
        <h1>表: {{ selectedDatabase }}.{{ selectedTable }}</h1>
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
  width: 100%;
  max-width: 1400px;
  margin: 0 auto;
}

.app-header {
  text-align: center;
  margin-bottom: 40px;
  animation: slideIn 0.8s ease forwards;
}

.app-header h1 {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 8px;
  background: var(--primary-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.app-header p {
  font-size: 1.1rem;
  color: var(--text-secondary);
  margin: 0;
}

.container {
  display: flex;
  flex-direction: column;
  gap: 30px;
  align-items: center;
}

.glass-card {
  width: 100%;
  max-width: 900px;
}

/* 響應式設計 */
@media (min-width: 1200px) {
  .container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 30px;
    align-items: start;
  }

  .glass-card:last-child {
    grid-column: 1 / -1;
    max-width: 100%;
  }
}

@media (max-width: 768px) {
  .app-header h1 {
    font-size: 2rem;
  }

  .app-header p {
    font-size: 1rem;
  }
}
</style>