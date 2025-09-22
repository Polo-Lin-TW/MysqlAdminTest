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
  color: #666;
}

.error {
  color: #e74c3c;
  padding: 10px;
  background-color: #fdf2f2;
  border: 1px solid #e74c3c;
  border-radius: 4px;
  margin-bottom: 10px;
}

.users-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}

.users-table th,
.users-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.users-table th {
  background-color: #f8f9fa;
  font-weight: bold;
  color: #333;
}

.users-table tr:hover {
  background-color: #f5f5f5;
}

.status-locked {
  color: #e74c3c;
  font-weight: bold;
}

.status-unlocked {
  color: #27ae60;
  font-weight: bold;
}

.status-expired {
  color: #f39c12;
  font-weight: bold;
}

.status-valid {
  color: #27ae60;
  font-weight: bold;
}
</style>