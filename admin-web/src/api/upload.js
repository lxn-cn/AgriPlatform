import request from '../utils/request'

// ================= 文件上传 =================

/**
 * 上传单张图片：拦截器自动附 JWT、剥掉 Result 包装，成功返回 { url: '/upload/xxx.jpg' }
 * 注意：勿手动设置 Content-Type，axios 对 FormData 会自动带 boundary
 */
export function uploadImage(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request.post('/file/upload', formData)
}
