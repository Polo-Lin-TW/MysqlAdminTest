<template>
  <div class="user-list">
    <div v-if="loading" class="loading">載入中...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else>
      <table class="users-table">
        <thead>
          <tr>
            <th>用戶名</th>
            <th>主機</th>
            <th>帳戶狀態</th>
            <th>密碼狀態</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="`${user.user}@${user.host}`">
            <td>{{ user.user }}</td>
            <td>{{ user.host }}</td>
            <td>
              <span :class="user.account_locked === 'Y' ? 'status-locked' : 'status-unlocked'">
                {{ user.account_locked === 'Y' ? '已鎖定' : '正常' }}
              </span>
            </td>
            <td>
              <span :class="user.password_expired === 'Y' ? 'status-expired' : 'status-valid'">
                {{ user.password_expired === 'Y' ? '已過期' : '有效' }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { mysqlApi } from '../api.js'

export default {
  name: 'UserList',
  data() {
    return {
      users: [],
      loading: false,
      error: null
    }
  },
  async mounted() {
    await this.fetchUsers()
  },
  methods: {
    async fetchUsers() {
      this.loading = true
      this.error = null
      
      try {
        const response = await mysqlApi.getUsers()
        this.users = response.data
      } catch (error) {
        this.error = `載入用戶失敗: ${error.message}`
        console.error('Error fetching users:', error)
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.user-list {
  margin-top: 10px;
}

.loading {
  text-align: center;
  padding: 20px;
  color: var(--text-secondary);
  font-size: 1rem;
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

.users-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  overflow: hidden;
}

.users-table th,
.users-table td {
  padding: 14px 16px;
  text-align: left;
  border-bottom: 1px solid rgba(255, 255, 255, 0.3);
}

.users-table th {
  background: rgba(255, 255, 255, 0.5);
  font-weight: 600;
  color: var(--text-primary);
  font-size: 0.9rem;
}

.users-table tbody tr {
  transition: var(--transition);
}

.users-table tbody tr:hover {
  background: rgba(255, 255, 255, 0.4);
}

.users-table tbody tr:last-child td {
  border-bottom: none;
}

.status-locked {
  color: #e74c3c;
  font-weight: 600;
  padding: 4px 10px;
  background: rgba(231, 76, 60, 0.15);
  border-radius: 6px;
  display: inline-block;
}

.status-unlocked {
  color: #27ae60;
  font-weight: 600;
  padding: 4px 10px;
  background: rgba(39, 174, 96, 0.15);
  border-radius: 6px;
  display: inline-block;
}

.status-expired {
  color: #f39c12;
  font-weight: 600;
  padding: 4px 10px;
  background: rgba(243, 156, 18, 0.15);
  border-radius: 6px;
  display: inline-block;
}

.status-valid {
  color: #27ae60;
  font-weight: 600;
  padding: 4px 10px;
  background: rgba(39, 174, 96, 0.15);
  border-radius: 6px;
  display: inline-block;
}
</style>