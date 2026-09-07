import request from '../utils/request'

// ================= 数据看板 =================

export function getOverviewStats() {
  return request.get('/admin/stats/overview')
}

// ================= 商家审核 =================

export function getMerchants(params) {
  return request.get('/admin/merchants', { params })
}
export function auditMerchant(id, data) {
  return request.post('/admin/merchants/' + id + '/audit', data)
}
export function banMerchant(id) {
  return request.post('/admin/merchants/' + id + '/ban')
}
export function unbanMerchant(id) {
  return request.post('/admin/merchants/' + id + '/unban')
}

// ================= 用户管理 =================

export function getUsers(params) {
  return request.get('/admin/users', { params })
}
export function setUserStatus(id, data) {
  return request.post('/admin/users/' + id + '/status', data)
}

// ================= 商品管理 =================

export function getAdminProducts(params) {
  return request.get('/admin/products', { params })
}
export function forceOffProduct(id) {
  return request.post('/admin/products/' + id + '/force-off')
}

// ================= 轮播图维护 =================

export function getBanners() {
  return request.get('/admin/banners')
}
export function createBanner(data) {
  return request.post('/admin/banners', data)
}
export function updateBanner(id, data) {
  return request.put('/admin/banners/' + id, data)
}
export function deleteBanner(id) {
  return request.delete('/admin/banners/' + id)
}

// ================= 公告维护 =================

export function getNotices(params) {
  return request.get('/admin/notices', { params })
}
export function createNotice(data) {
  return request.post('/admin/notices', data)
}
export function updateNotice(id, data) {
  return request.put('/admin/notices/' + id, data)
}
export function deleteNotice(id) {
  return request.delete('/admin/notices/' + id)
}

// ================= 分类维护 =================

export function getAdminCategories() {
  return request.get('/admin/categories')
}
export function createCategory(data) {
  return request.post('/admin/categories', data)
}
export function updateCategory(id, data) {
  return request.put('/admin/categories/' + id, data)
}
export function deleteCategory(id) {
  return request.delete('/admin/categories/' + id)
}

// ================= 订单 / 预约总览 =================

export function getAdminOrders(params) {
  return request.get('/admin/orders', { params })
}
export function getAdminAppointments(params) {
  return request.get('/admin/appointments', { params })
}

// ================= 意见反馈 =================

export function getFeedbacks(params) {
  return request.get('/admin/feedbacks', { params })
}
export function replyFeedback(id, data) {
  return request.post('/admin/feedbacks/' + id + '/reply', data)
}

// ================= 操作日志 =================

export function getLogs(params) {
  return request.get('/admin/logs', { params })
}

// ================= 管理员账号（SUPER） =================

export function getAdmins(params) {
  return request.get('/admin/admins', { params })
}
export function createAdmin(data) {
  return request.post('/admin/admins', data)
}
export function updateAdmin(id, data) {
  return request.put('/admin/admins/' + id, data)
}
