import { defineStore } from 'pinia'

const TOKEN_KEY = 'agri_admin_token'
const USER_KEY = 'agri_admin_user'

function readUser() {
  try {
    return JSON.parse(localStorage.getItem(USER_KEY) || 'null')
  } catch (e) {
    return null
  }
}

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY) || '',
    userInfo: readUser(),
    unreadCount: 0 // 商家未读预约通知数
  }),
  getters: {
    role: (state) => (state.userInfo && state.userInfo.role) || '',
    name: (state) =>
      (state.userInfo && (state.userInfo.name || state.userInfo.username)) || '未登录',
    isMerchant: (state) => (state.userInfo && state.userInfo.role) === 'MERCHANT',
    isAdmin: (state) => {
      const r = state.userInfo && state.userInfo.role
      return r === 'ADMIN' || r === 'SUPER'
    },
    isSuper: (state) => (state.userInfo && state.userInfo.role) === 'SUPER'
  },
  actions: {
    setLogin(token, userInfo) {
      this.token = token || ''
      this.userInfo = userInfo || null
      localStorage.setItem(TOKEN_KEY, this.token)
      localStorage.setItem(USER_KEY, JSON.stringify(this.userInfo))
    },
    setUserInfo(userInfo) {
      this.userInfo = userInfo || null
      localStorage.setItem(USER_KEY, JSON.stringify(this.userInfo))
    },
    setUnread(n) {
      this.unreadCount = Math.max(0, Number(n) || 0)
    },
    logout() {
      this.token = ''
      this.userInfo = null
      this.unreadCount = 0
      localStorage.removeItem(TOKEN_KEY)
      localStorage.removeItem(USER_KEY)
    }
  }
})
