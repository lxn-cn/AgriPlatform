import request from '../utils/request'

// 管理端登录（username / password / role: ADMIN | MERCHANT）
export function login(data) {
  return request.post('/auth/login', data)
}
