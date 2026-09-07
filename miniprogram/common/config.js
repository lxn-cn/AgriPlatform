// 全局配置
// BASE_URL：后端服务地址。三选一，把要用的那行放开、其余注释掉：
//  1. 本地开发（默认）——自己/队友在自己电脑上跑后端 + 模拟器调试用这个
//  2. 真机调试 —— 微信真机拦截 http 图片，必须走 https（cpolar 内网穿透，
//     黑窗口保持运行；免费版每次重启地址会变，变了更新这行）
//  3. 局域网备用 —— 手机与电脑同一 WiFi 时模拟器可用，真机图片出不来
const BASE_URL = 'http://localhost:8080'
// const BASE_URL = 'https://14a59966.r8.cpolar.top'
// const BASE_URL = 'http://10.2.185.213:8080'

export {
    BASE_URL
}
export default {
    BASE_URL
}
