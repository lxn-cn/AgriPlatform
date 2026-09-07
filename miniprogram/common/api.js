// 全部接口封装（与 docs/api.md 一一对应，仅封装小程序用户端用到的接口）
import request from './request.js'

/* ==================== 认证与账号 ==================== */
// 小程序登录：入参 {code, nickname?}，返回 {token, userInfo}
export function wxLogin(code, nickname) {
    return request({ url: '/api/auth/wx-login', method: 'POST', data: { code: code, nickname: nickname } })
}
// 当前用户信息
export function getUserMe() {
    return request({ url: '/api/user/me' })
}
// 修改昵称/头像/手机号
export function updateUserMe(data) {
    return request({ url: '/api/user/me', method: 'PUT', data: data })
}

/* ==================== 首页与通用 ==================== */
export function getBanners() {
    return request({ url: '/api/home/banners' })
}
export function getNotices() {
    return request({ url: '/api/home/notices' })
}
export function getRecommended() {
    return request({ url: '/api/home/recommended' })
}
export function getFarmsBrief() {
    return request({ url: '/api/home/farms-brief' })
}
// 聚合搜索 ?keyword=，返回 {products, farms}
export function searchAll(keyword) {
    return request({ url: '/api/search', data: { keyword: keyword } })
}

/* ==================== 农园（游客可浏览） ==================== */
// 农园列表：district/type/keyword/sort + 分页
export function getFarmList(params) {
    return request({ url: '/api/farms', data: params })
}
// 农园详情（含当季采摘项目列表 projects）
export function getFarmDetail(id) {
    return request({ url: '/api/farms/' + id })
}
// 农园评价分页
export function getFarmReviews(id, params) {
    return request({ url: '/api/farms/' + id + '/reviews', data: params })
}

/* ==================== 采摘预约 ==================== */
// 提交预约 {projectId, appointDate, session, peopleCount, contactName, contactPhone}
export function createAppointment(data) {
    return request({ url: '/api/appointments', method: 'POST', data: data })
}
// 我的预约列表 ?status=&pageNum=&pageSize=
export function getMyAppointments(params) {
    return request({ url: '/api/appointments/my', data: params })
}
// 预约详情
export function getAppointmentDetail(id) {
    return request({ url: '/api/appointments/' + id })
}
// 模拟支付 → 待使用
export function payAppointment(id) {
    return request({ url: '/api/appointments/' + id + '/pay', method: 'POST' })
}
// 取消预约
export function cancelAppointment(id) {
    return request({ url: '/api/appointments/' + id + '/cancel', method: 'POST' })
}

/* ==================== 评价（商品/农园通用） ==================== */
export function postReview(data) {
    return request({ url: '/api/reviews', method: 'POST', data: data })
}

/* ==================== 商城：商品 ==================== */
// 分类树（两级）
export function getCategories() {
    return request({ url: '/api/categories' })
}
// 商品列表 ?categoryId=&keyword=&sort=&pageNum=
export function getProducts(params) {
    return request({ url: '/api/products', data: params })
}
// 商品详情
export function getProductDetail(id) {
    return request({ url: '/api/products/' + id })
}
// 商品评价分页
export function getProductReviews(id, params) {
    return request({ url: '/api/products/' + id + '/reviews', data: params })
}

/* ==================== 收藏 ==================== */
export function addFavorite(productId) {
    return request({ url: '/api/products/' + productId + '/favorite', method: 'POST' })
}
export function removeFavorite(productId) {
    return request({ url: '/api/products/' + productId + '/favorite', method: 'DELETE' })
}
// 我的收藏
export function getMyFavorites() {
    return request({ url: '/api/favorites/my' })
}

/* ==================== 购物车 ==================== */
export function getCart() {
    return request({ url: '/api/cart' })
}
export function addToCart(data) {
    return request({ url: '/api/cart', method: 'POST', data: data })
}
export function updateCart(id, data) {
    return request({ url: '/api/cart/' + id, method: 'PUT', data: data })
}
export function deleteCart(id) {
    return request({ url: '/api/cart/' + id, method: 'DELETE' })
}

/* ==================== 订单 ==================== */
// 提交订单 {addressId, remark, items:[{productId, quantity, spec}], fromCart}
export function createOrder(data) {
    return request({ url: '/api/orders', method: 'POST', data: data })
}
// 我的订单 ?status=&pageNum=
export function getMyOrders(params) {
    return request({ url: '/api/orders/my', data: params })
}
export function getOrderDetail(id) {
    return request({ url: '/api/orders/' + id })
}
// 模拟支付 → 待发货
export function payOrder(id) {
    return request({ url: '/api/orders/' + id + '/pay', method: 'POST' })
}
// 取消订单（仅待付款）
export function cancelOrder(id) {
    return request({ url: '/api/orders/' + id + '/cancel', method: 'POST' })
}
// 确认收货 → 已完成
export function confirmOrder(id) {
    return request({ url: '/api/orders/' + id + '/confirm', method: 'POST' })
}
// 申请退款 {reason}
export function refundOrder(id, reason) {
    return request({ url: '/api/orders/' + id + '/refund', method: 'POST', data: { reason: reason } })
}

/* ==================== 收货地址 ==================== */
export function getAddresses() {
    return request({ url: '/api/addresses' })
}
export function addAddress(data) {
    return request({ url: '/api/addresses', method: 'POST', data: data })
}
export function updateAddress(id, data) {
    return request({ url: '/api/addresses/' + id, method: 'PUT', data: data })
}
export function deleteAddress(id) {
    return request({ url: '/api/addresses/' + id, method: 'DELETE' })
}
export function setDefaultAddress(id) {
    return request({ url: '/api/addresses/' + id + '/default', method: 'POST' })
}

/* ==================== 意见反馈 ==================== */
export function postFeedback(data) {
    return request({ url: '/api/feedback', method: 'POST', data: data })
}
