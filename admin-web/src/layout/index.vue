<template>
  <el-container class="layout">
    <!-- ===== 侧边栏 ===== -->
    <el-aside :width="isCollapse ? '64px' : '210px'" class="aside">
      <div class="logo" @click="$router.push('/')">
        <el-icon class="logo-icon"><Sunrise /></el-icon>
        <span v-if="!isCollapse" class="logo-text">津农优品管理端</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :collapse-transition="false"
        router
        background-color="#1f3d2b"
        text-color="#c7d5cd"
        active-text-color="#ffffff"
        class="aside-menu"
      >
        <div v-if="merchantMenus.length" class="menu-group-label">商家工作台</div>
        <template v-for="m in merchantMenus" :key="m.path">
          <el-menu-item :index="m.path">
            <el-icon><component :is="m.icon" /></el-icon>
            <template #title>
              <span>{{ m.title }}</span>
              <el-badge
                v-if="m.path === '/merchant/appointments' && store.unreadCount > 0"
                :value="store.unreadCount"
                :max="99"
                class="menu-badge"
              />
            </template>
          </el-menu-item>
        </template>

        <div v-if="adminMenus.length" class="menu-group-label">平台管理</div>
        <template v-for="m in adminMenus" :key="m.path">
          <el-menu-item :index="m.path">
            <el-icon><component :is="m.icon" /></el-icon>
            <template #title>
              <span>{{ m.title }}</span>
            </template>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>

    <el-container>
      <!-- ===== 顶栏 ===== -->
      <el-header class="header">
        <div class="header-left">
          <el-icon class="fold-btn" @click="isCollapse = !isCollapse">
            <Expand v-if="isCollapse" />
            <Fold v-else />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>{{ store.isMerchant ? '商家工作台' : '平台管理' }}</el-breadcrumb-item>
            <el-breadcrumb-item>{{ currentTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-tooltip v-if="store.isMerchant" :content="'未读预约通知 ' + store.unreadCount + ' 条'" placement="bottom">
            <el-badge :value="store.unreadCount" :hidden="store.unreadCount <= 0" :max="99">
              <el-icon class="header-icon" @click="goAppointments"><Bell /></el-icon>
            </el-badge>
          </el-tooltip>
          <el-divider direction="vertical" />
          <el-dropdown @command="onCommand">
            <span class="user-info">
              <el-avatar :size="30" class="user-avatar">{{ avatarText }}</el-avatar>
              <span class="user-name">{{ store.name }}</span>
              <el-tag size="small" :type="store.isMerchant ? 'success' : 'danger'" effect="plain">
                {{ roleText }}
              </el-tag>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile" v-if="store.isMerchant">
                  <el-icon><Shop /></el-icon>我的店铺
                </el-dropdown-item>
                <el-dropdown-item command="logout" divided>
                  <el-icon><SwitchButton /></el-icon>退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- ===== 主体 ===== -->
      <el-main class="main">
        <router-view v-if="isRouterAlive" :key="route.fullPath" />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, provide } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { useUserStore } from '../stores/user'
import { getUnreadCount } from '../api/merchant'

const route = useRoute()
const router = useRouter()
const store = useUserStore()

const isCollapse = ref(false)
const isRouterAlive = ref(true)
let pollTimer = null

// ===== 菜单（按角色过滤） =====
const allMenus = [
  // 商家
  { path: '/merchant/dashboard', title: '经营统计', icon: 'DataLine', roles: ['MERCHANT'] },
  { path: '/merchant/profile', title: '我的店铺', icon: 'Shop', roles: ['MERCHANT'] },
  { path: '/merchant/products', title: '商品管理', icon: 'Goods', roles: ['MERCHANT'] },
  { path: '/merchant/farms', title: '农园管理', icon: 'Grape', roles: ['MERCHANT'] },
  { path: '/merchant/appointments', title: '预约管理', icon: 'Calendar', roles: ['MERCHANT'] },
  { path: '/merchant/orders', title: '订单管理', icon: 'List', roles: ['MERCHANT'] },
  // 管理员
  { path: '/admin/dashboard', title: '数据看板', icon: 'Odometer', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/merchants', title: '商家审核', icon: 'Stamp', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/users', title: '用户管理', icon: 'User', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/products', title: '商品管理', icon: 'Goods', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/banners', title: '轮播图管理', icon: 'PictureFilled', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/notices', title: '公告管理', icon: 'Notification', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/categories', title: '分类管理', icon: 'Grid', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/orders', title: '订单总览', icon: 'Tickets', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/appointments', title: '预约总览', icon: 'AlarmClock', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/feedbacks', title: '意见反馈', icon: 'ChatDotRound', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/logs', title: '操作日志', icon: 'Document', roles: ['ADMIN', 'SUPER'] },
  { path: '/admin/admins', title: '管理员账号', icon: 'Key', roles: ['SUPER'] }
]

function hasRole(roles) {
  if (roles.includes(store.role)) return true
  if (store.role === 'SUPER' && roles.includes('ADMIN')) return true
  return false
}

const merchantMenus = computed(() => allMenus.filter((m) => hasRole(m.roles) && m.roles.includes('MERCHANT')))
const adminMenus = computed(() => allMenus.filter((m) => hasRole(m.roles) && !m.roles.includes('MERCHANT')))

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => (route.meta && route.meta.title) || '')

const roleText = computed(() => {
  if (store.role === 'MERCHANT') return '商家'
  if (store.role === 'SUPER') return '超级管理员'
  if (store.role === 'ADMIN') return '管理员'
  return '未知'
})

const avatarText = computed(() => (store.name || '?').slice(0, 1))

// ===== 预约通知角标（商家） =====
async function loadUnread() {
  if (!store.isMerchant) return
  try {
    const data = await getUnreadCount()
    const n = typeof data === 'number' ? data : Number(data && data.count) || Number(data && (data.count ?? data.unreadCount)) || 0
    store.setUnread(n)
  } catch (e) {
    /* 静默失败，不打扰 */
  }
}

function goAppointments() {
  router.push('/merchant/appointments')
}

// ===== 用户下拉 =====
function onCommand(cmd) {
  if (cmd === 'logout') {
    ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(() => {
      store.logout()
      router.push('/login')
    }).catch(() => {})
  } else if (cmd === 'profile') {
    router.push('/merchant/profile')
  }
}

// 提供刷新能力（子页面调用 reload 刷新当前路由）
provide('reload', () => {
  isRouterAlive.value = false
  nextTickSafe()
})
function nextTickSafe() {
  setTimeout(() => {
    isRouterAlive.value = true
  }, 0)
}

onMounted(() => {
  loadUnread()
  pollTimer = setInterval(loadUnread, 60000)
})

onUnmounted(() => {
  if (pollTimer) clearInterval(pollTimer)
})
</script>

<style scoped>
.layout {
  height: 100%;
}

.aside {
  background: #1f3d2b;
  transition: width 0.2s;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: #fff;
  cursor: pointer;
  flex-shrink: 0;
}

.logo-icon {
  font-size: 26px;
  color: #7fce9f;
}

.logo-text {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 1px;
  white-space: nowrap;
}

.aside-menu {
  border-right: none;
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
}

.menu-group-label {
  padding: 14px 20px 6px;
  font-size: 12px;
  color: #7a9184;
  white-space: nowrap;
}

:deep(.el-menu-item.is-active) {
  background: #2e9e6b !important;
}

.menu-badge {
  margin-left: 8px;
  transform: translateY(-2px);
}

.header {
  height: 60px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  z-index: 5;
  padding: 0 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.fold-btn {
  font-size: 20px;
  cursor: pointer;
  color: #5a6b60;
}

.fold-btn:hover {
  color: #2e9e6b;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-icon {
  font-size: 20px;
  color: #5a6b60;
  cursor: pointer;
}

.header-icon:hover {
  color: #2e9e6b;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.user-avatar {
  background: #2e9e6b;
  color: #fff;
  font-size: 14px;
}

.user-name {
  font-size: 14px;
  color: #303133;
}

.main {
  background: #f5f7fa;
  padding: 0;
  overflow-y: auto;
}
</style>
