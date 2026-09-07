// 通用工具函数
import { BASE_URL } from './config.js'

/**
 * 图片地址拼接：后端图片字段为相对路径（如 /api/file/placeholder/p1.png），
 * 展示时拼接 BASE_URL；为空时用占位图服务按 seed 生成。
 */
function imgUrl(path, seed) {
    if (!path) {
        return BASE_URL + '/api/file/placeholder/' + (seed || 'default') + '.png'
    }
    if (path.indexOf('http://') === 0 || path.indexOf('https://') === 0) {
        return path
    }
    return BASE_URL + path
}

// 价格格式化：数字 → '12.00'
function priceText(v) {
    var n = Number(v)
    if (isNaN(n)) { n = 0 }
    return n.toFixed(2)
}

// 金额显示：'¥12.00'
function money(v) {
    return '¥' + priceText(v)
}

// 日期格式化 yyyy-MM-dd
function fmtDate(d) {
    var t = (d instanceof Date) ? d : new Date(d)
    var y = t.getFullYear()
    var m = t.getMonth() + 1
    var day = t.getDate()
    return y + '-' + pad(m) + '-' + pad(day)
}
function pad(n) {
    return n < 10 ? ('0' + n) : ('' + n)
}

// 订单状态文案 0待付款 1待发货 2待收货 3已完成 4已取消 5退款中 6已退款
var ORDER_STATUS = { 0: '待付款', 1: '待发货', 2: '待收货', 3: '已完成', 4: '已取消', 5: '退款中', 6: '已退款' }
function orderStatusText(s) {
    return ORDER_STATUS[s] || '未知'
}
// 订单状态标签样式
function orderTagClass(s) {
    var map = { 0: 'tag-orange', 1: 'tag-blue', 2: 'tag-green', 3: 'tag-gray', 4: 'tag-gray', 5: 'tag-red', 6: 'tag-gray' }
    return map[s] || 'tag-gray'
}

// 预约状态文案 0待支付 1待使用 2已使用 3已取消 4已过期
var APPOINT_STATUS = { 0: '待支付', 1: '待使用', 2: '已使用', 3: '已取消', 4: '已过期' }
function appointStatusText(s) {
    return APPOINT_STATUS[s] || '未知'
}
function appointTagClass(s) {
    var map = { 0: 'tag-orange', 1: 'tag-blue', 2: 'tag-green', 3: 'tag-gray', 4: 'tag-gray' }
    return map[s] || 'tag-gray'
}

// 是否已登录
function isLoggedIn() {
    return !!uni.getStorageSync('token')
}

// 登录校验：未登录时提示并跳转登录页，返回 false
function requireLogin() {
    if (isLoggedIn()) { return true }
    uni.showToast({ title: '请先登录', icon: 'none' })
    setTimeout(function () {
        uni.navigateTo({ url: '/pages/login/login' })
    }, 700)
    return false
}

/**
 * 待使用的预约是否可取消：
 * 契约要求“待使用的需在预约日期前一天 24:00 前取消”，
 * 即只有在“今天 < 预约日期”时才允许取消。
 */
function canCancelAppointment(item) {
    if (item.status !== 1) { return false }
    var today = fmtDate(new Date())
    return today < item.appointDate
}

// 手机号校验（11 位，1 开头）
function isPhone(v) {
    return /^1\d{10}$/.test(String(v || ''))
}

// 天津市区县列表（地址/筛选用）
var DISTRICTS = ['和平区', '河东区', '河西区', '南开区', '河北区', '红桥区', '东丽区', '西青区', '津南区', '北辰区', '宝坻区', '滨海新区', '宁河区', '静海区', '蓟州区']

// 列表页兼容分页返回结构：优先取 {total, list}，否则按数组处理
function parsePage(res) {
    if (res && res.list) {
        return { total: Number(res.total || res.list.length), list: res.list }
    }
    if (Object.prototype.toString.call(res) === '[object Array]') {
        return { total: res.length, list: res }
    }
    return { total: 0, list: [] }
}

export {
    imgUrl,
    priceText,
    money,
    fmtDate,
    orderStatusText,
    orderTagClass,
    appointStatusText,
    appointTagClass,
    isLoggedIn,
    requireLogin,
    canCancelAppointment,
    isPhone,
    DISTRICTS,
    parsePage
}
