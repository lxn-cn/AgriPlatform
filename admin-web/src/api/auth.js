import request from '../utils/request'

// 管理端登录（username / password / role: ADMIN | MERCHANT）
export function login(data) {
  return request.post('/auth/login', data)
}

// 商家入驻申请（免登录，WebConfig 已放行 /api/merchant/apply）
export function applyMerchant(data) {
  return request.post('/merchant/apply', data)
}
