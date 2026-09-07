import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/login/index.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('../layout/index.vue'),
    children: [
      // ===== 商家（MERCHANT）=====
      {
        path: 'merchant/dashboard',
        name: 'MerchantDashboard',
        component: () => import('../views/merchant/dashboard.vue'),
        meta: { title: '经营统计', roles: ['MERCHANT'] }
      },
      {
        path: 'merchant/profile',
        name: 'MerchantProfile',
        component: () => import('../views/merchant/profile.vue'),
        meta: { title: '我的店铺', roles: ['MERCHANT'] }
      },
      {
        path: 'merchant/products',
        name: 'MerchantProducts',
        component: () => import('../views/merchant/products.vue'),
        meta: { title: '商品管理', roles: ['MERCHANT'] }
      },
      {
        path: 'merchant/farms',
        name: 'MerchantFarms',
        component: () => import('../views/merchant/farms.vue'),
        meta: { title: '农园管理', roles: ['MERCHANT'] }
      },
      {
        path: 'merchant/appointments',
        name: 'MerchantAppointments',
        component: () => import('../views/merchant/appointments.vue'),
        meta: { title: '预约管理', roles: ['MERCHANT'] }
      },
      {
        path: 'merchant/orders',
        name: 'MerchantOrders',
        component: () => import('../views/merchant/orders.vue'),
        meta: { title: '订单管理', roles: ['MERCHANT'] }
      },
      // ===== 平台管理员（ADMIN / SUPER）=====
      {
        path: 'admin/dashboard',
        name: 'AdminDashboard',
        component: () => import('../views/admin/dashboard.vue'),
        meta: { title: '数据看板', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/merchants',
        name: 'AdminMerchants',
        component: () => import('../views/admin/merchants.vue'),
        meta: { title: '商家审核', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/users',
        name: 'AdminUsers',
        component: () => import('../views/admin/users.vue'),
        meta: { title: '用户管理', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/products',
        name: 'AdminProducts',
        component: () => import('../views/admin/products.vue'),
        meta: { title: '商品管理', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/banners',
        name: 'AdminBanners',
        component: () => import('../views/admin/banners.vue'),
        meta: { title: '轮播图管理', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/notices',
        name: 'AdminNotices',
        component: () => import('../views/admin/notices.vue'),
        meta: { title: '公告管理', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/categories',
        name: 'AdminCategories',
        component: () => import('../views/admin/categories.vue'),
        meta: { title: '分类管理', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/orders',
        name: 'AdminOrders',
        component: () => import('../views/admin/orders.vue'),
        meta: { title: '订单总览', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/appointments',
        name: 'AdminAppointments',
        component: () => import('../views/admin/appointments.vue'),
        meta: { title: '预约总览', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/feedbacks',
        name: 'AdminFeedbacks',
        component: () => import('../views/admin/feedbacks.vue'),
        meta: { title: '意见反馈', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/logs',
        name: 'AdminLogs',
        component: () => import('../views/admin/logs.vue'),
        meta: { title: '操作日志', roles: ['ADMIN', 'SUPER'] }
      },
      {
        path: 'admin/admins',
        name: 'AdminAdmins',
        component: () => import('../views/admin/admins.vue'),
        meta: { title: '管理员账号', roles: ['SUPER'] }
      }
    ]
  },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 各角色登录后的首页
function roleHome(role) {
  if (role === 'MERCHANT') return '/merchant/dashboard'
  return '/admin/dashboard'
}

router.beforeEach((to, from, next) => {
  const store = useUserStore()
  if (to.path === '/login') {
    if (store.token) {
      next(roleHome(store.role))
    } else {
      next()
    }
    return
  }
  if (to.path === '/') {
    if (store.token) {
      next(roleHome(store.role))
    } else {
      next('/login')
    }
    return
  }
  if (!store.token) {
    next({ path: '/login', query: { redirect: to.fullPath } })
    return
  }
  // 角色限制：SUPER 视为 ADMIN 超集
  const roles = (to.meta && to.meta.roles) || []
  if (roles.length && !roles.includes(store.role)) {
    if (!(store.role === 'SUPER' && roles.includes('ADMIN'))) {
      next(roleHome(store.role))
      return
    }
  }
  document.title = (to.meta && to.meta.title ? to.meta.title + ' - ' : '') + '天津农特产平台管理端'
  next()
})

export default router
