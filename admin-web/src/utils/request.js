import axios from 'axios'
import { ElMessage } from 'element-plus'

const TOKEN_KEY = 'agri_admin_token'
const USER_KEY = 'agri_admin_user'

const service = axios.create({
  baseURL: '/api',
  timeout: 20000
})

// 请求拦截：附加 JWT
service.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem(TOKEN_KEY)
    if (token) {
      config.headers.Authorization = 'Bearer ' + token
    }
    return config
  },
  (error) => Promise.reject(error)
)

function handleUnauthorized() {
  const hadToken = !!localStorage.getItem(TOKEN_KEY)
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(USER_KEY)
  if (hadToken && window.location.pathname !== '/login') {
    ElMessage.warning('登录已失效，请重新登录')
    window.location.href = '/login'
  }
}

// 响应拦截：统一处理 code / 401 / 网络异常
service.interceptors.response.use(
  (response) => {
    // 非标准 JSON（如文件流）直接返回
    const res = response.data
    if (res === null || res === undefined || typeof res === 'string' || Array.isArray(res)) {
      return res
    }
    if (typeof res.code === 'undefined') return res
    if (res.code === 200) {
      return res.data // 直接返回业务数据
    }
    if (res.code === 401) {
      handleUnauthorized()
      return Promise.reject(new Error(res.msg || '未登录'))
    }
    ElMessage.error(res.msg || '操作失败')
    return Promise.reject(new Error(res.msg || '操作失败'))
  },
  (error) => {
    const resp = error.response
    let msg = (error && error.message) || '网络异常'
    if (resp && resp.data && resp.data.msg) msg = resp.data.msg
    if (resp && resp.status === 401) {
      handleUnauthorized()
      return Promise.reject(error)
    }
    if (resp && resp.status === 403) {
      ElMessage.error(msg || '无权限执行该操作')
      return Promise.reject(error)
    }
    ElMessage.error(msg || '网络异常，请稍后重试')
    return Promise.reject(error)
  }
)

export default service
