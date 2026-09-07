import request from '../utils/request'

// ================= 商家资料 =================

// 商家信息
export function getMerchantProfile() {
  return request.get('/merchant/profile')
}
export function updateMerchantProfile(data) {
  return request.put('/merchant/profile', data)
}

// ================= 经营统计 =================

export function getMerchantStats() {
  return request.get('/merchant/stats')
}

// ================= 商品管理 =================

export function getMerchantProducts(params) {
  return request.get('/merchant/products', { params })
}
export function getMerchantProduct(id) {
  return request.get('/merchant/products/' + id)
}
export function createProduct(data) {
  return request.post('/merchant/products', data)
}
export function updateProduct(id, data) {
  return request.put('/merchant/products/' + id, data)
}
export function deleteProduct(id) {
  return request.delete('/merchant/products/' + id)
}

// ================= 农园与采摘项目 =================

export function getMerchantFarms(params) {
  return request.get('/merchant/farms', { params })
}
export function createFarm(data) {
  return request.post('/merchant/farms', data)
}
export function getMerchantFarm(id) {
  return request.get('/merchant/farms/' + id)
}
export function updateFarm(id, data) {
  return request.put('/merchant/farms/' + id, data)
}

export function getPickingProjects(params) {
  return request.get('/merchant/picking-projects', { params })
}
export function createPickingProject(data) {
  return request.post('/merchant/picking-projects', data)
}
export function updatePickingProject(id, data) {
  return request.put('/merchant/picking-projects/' + id, data)
}
export function deletePickingProject(id) {
  return request.delete('/merchant/picking-projects/' + id)
}

// ================= 预约管理 =================

export function getMerchantAppointments(params) {
  return request.get('/merchant/appointments', { params })
}
export function getUnreadCount() {
  return request.get('/merchant/appointments/unread-count')
}
export function markRead(id) {
  return request.post('/merchant/appointments/' + id + '/read')
}
export function confirmArrival(id, data) {
  return request.post('/merchant/appointments/' + id + '/confirm', data || {})
}

// ================= 订单管理 =================

export function getMerchantOrders(params) {
  return request.get('/merchant/orders', { params })
}
export function shipOrder(id) {
  return request.post('/merchant/orders/' + id + '/ship')
}
export function agreeRefund(id) {
  return request.post('/merchant/orders/' + id + '/refund-agree')
}
