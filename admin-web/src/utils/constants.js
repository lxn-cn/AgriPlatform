// ===== 业务枚举与通用工具 =====

// 订单状态：0待付款 1待发货 2待收货 3已完成 4已取消 5退款中 6已退款
export const ORDER_STATUS = {
  0: { text: '待付款', type: 'info' },
  1: { text: '待发货', type: 'warning' },
  2: { text: '待收货', type: 'primary' },
  3: { text: '已完成', type: 'success' },
  4: { text: '已取消', type: 'info' },
  5: { text: '退款中', type: 'danger' },
  6: { text: '已退款', type: 'info' }
}

// 预约状态：0待支付 1待使用 2已使用 3已取消 4已过期
export const APPOINTMENT_STATUS = {
  0: { text: '待支付', type: 'info' },
  1: { text: '待使用', type: 'warning' },
  2: { text: '已使用', type: 'success' },
  3: { text: '已取消', type: 'info' },
  4: { text: '已过期', type: 'info' }
}

// 商家状态：0待审核 1已通过 2已封禁（3 兼容“已驳回”）
export const MERCHANT_STATUS = {
  0: { text: '待审核', type: 'warning' },
  1: { text: '已通过', type: 'success' },
  2: { text: '已封禁', type: 'danger' },
  3: { text: '已驳回', type: 'danger' }
}

// 商品状态：0下架 1上架 2待审核
export const PRODUCT_STATUS = {
  0: { text: '已下架', type: 'info' },
  1: { text: '销售中', type: 'success' },
  2: { text: '待审核', type: 'warning' }
}

// 农园/采摘项目状态：1上架 0下架
export const SHELF_STATUS = {
  0: { text: '已下架', type: 'info' },
  1: { text: '已上架', type: 'success' }
}

// 天津全部区县
export const TIANJIN_DISTRICTS = [
  '和平区', '河东区', '河西区', '南开区', '河北区', '红桥区',
  '滨海新区', '东丽区', '西青区', '津南区', '北辰区',
  '武清区', '宝坻区', '静海区', '宁河区', '蓟州区'
]

// 农园类型
export const FARM_TYPES = ['果园', '有机蔬菜农场']

// 采摘计价方式
export const PRICE_MODES = ['按人头门票', '按采摘重量']

// 预约场次
export const SESSION_OPTIONS = ['上午', '下午']

// 轮播图跳转类型
export const LINK_TYPES = [
  { value: 'none', label: '无跳转' },
  { value: 'product', label: '跳转商品' },
  { value: 'farm', label: '跳转农园' },
  { value: 'notice', label: '跳转公告' }
]

// 金额格式化（元，两位小数）
export function money(v) {
  const n = Number(v || 0)
  return '¥' + (isNaN(n) ? '0.00' : n.toFixed(2))
}

// 数量格式化
export function num(v) {
  const n = Number(v || 0)
  return isNaN(n) ? 0 : n
}

// 日期时间格式化
export function datetime(v) {
  if (!v) return '-'
  const s = String(v).replace('T', ' ')
  return s.length > 16 ? s.slice(0, 19) : s
}

// 手机号脱敏兜底（后端已脱敏，双保险）
export function maskPhone(p) {
  if (!p) return '-'
  const s = String(p)
  if (s.includes('*')) return s
  if (s.length === 11) return s.slice(0, 3) + '****' + s.slice(7)
  return s
}

// 多候选字段取值（兼容后端字段命名差异）
export function pick(obj, keys, defaultVal) {
  if (!obj) return defaultVal
  for (let i = 0; i < keys.length; i++) {
    const k = keys[i]
    if (obj[k] !== undefined && obj[k] !== null) return obj[k]
  }
  return defaultVal
}
