import request from '../utils/request'

// 分类树（两级），游客可用
export function getCategories() {
  return request.get('/categories')
}
