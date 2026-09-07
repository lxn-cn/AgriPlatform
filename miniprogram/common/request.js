// 基于 uni.request 的 Promise 封装
// - 自动携带 Authorization: Bearer <token>（token 存于本地缓存）
// - 响应 code==200 时 resolve(data)
// - code==401 时清除登录态并跳转登录页
// - 其他 code 用 uni.showToast 提示 msg 后 reject
import { BASE_URL } from './config.js'

let redirecting = false // 防止并发 401 时重复跳转

function redirectToLogin() {
    if (redirecting) return
    redirecting = true
    uni.removeStorageSync('token')
    uni.removeStorageSync('userInfo')
    uni.showToast({ title: '登录已失效，请重新登录', icon: 'none' })
    setTimeout(function () {
        uni.reLaunch({ url: '/pages/login/login' })
        redirecting = false
    }, 900)
}

/**
 * 发起请求
 * @param {Object} options { url, method, data, header }
 * @returns {Promise} 成功时 resolve 后端返回的 data 字段
 */
function request(options) {
    return new Promise(function (resolve, reject) {
        var token = uni.getStorageSync('token')
        var header = { 'Content-Type': 'application/json' }
        if (token) {
            header['Authorization'] = 'Bearer ' + token
        }
        if (options.header) {
            for (var k in options.header) {
                header[k] = options.header[k]
            }
        }
        uni.request({
            url: BASE_URL + options.url,
            method: options.method || 'GET',
            data: options.data || {},
            header: header,
            success: function (res) {
                if (res.statusCode === 401) {
                    redirectToLogin()
                    reject(res)
                    return
                }
                if (res.statusCode !== 200) {
                    uni.showToast({ title: '服务异常(' + res.statusCode + ')', icon: 'none' })
                    reject(res)
                    return
                }
                var body = res.data || {}
                if (body.code === 200) {
                    resolve(body.data)
                } else if (body.code === 401) {
                    redirectToLogin()
                    reject(body)
                } else {
                    uni.showToast({ title: body.msg || '请求失败', icon: 'none' })
                    reject(body)
                }
            },
            fail: function (err) {
                uni.showToast({ title: '网络连接失败，请检查后端服务是否启动', icon: 'none' })
                reject(err)
            }
        })
    })
}

export default request
export { request }
