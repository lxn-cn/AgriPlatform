<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">商品管理</div>

      <!-- 搜索工具栏 -->
      <div class="toolbar">
        <el-input
          v-model="query.keyword"
          placeholder="商品名称关键词"
          clearable
          style="width: 220px"
          @keyup.enter="loadList(1)"
          @clear="loadList(1)"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-select v-model="query.status" placeholder="全部状态" clearable style="width: 140px" @change="loadList(1)">
          <el-option label="销售中" :value="1" />
          <el-option label="已下架" :value="0" />
          <el-option label="待审核" :value="2" />
        </el-select>
        <el-button type="primary" @click="loadList(1)">
          <el-icon><Search /></el-icon>&nbsp;查询
        </el-button>
        <div class="grow"></div>
        <el-button type="success" @click="openDialog()">
          <el-icon><Plus /></el-icon>&nbsp;新增商品
        </el-button>
      </div>

      <!-- 商品列表 -->
      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column label="主图" width="76" align="center">
          <template #default="{ row }">
            <img v-if="row.mainImage" class="thumb" :src="row.mainImage" alt="主图" />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="商品名称" min-width="180" show-overflow-tooltip />
        <el-table-column prop="categoryId" label="分类" width="90" align="center">
          <template #default="{ row }">{{ categoryName(row.categoryId) }}</template>
        </el-table-column>
        <el-table-column label="价格" width="100" align="right">
          <template #default="{ row }">
            <span style="color: #e6a23c; font-weight: 600">{{ money(row.price) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="80" align="center" />
        <el-table-column prop="sales" label="销量" width="80" align="center" />
        <el-table-column prop="origin" label="产地" width="100" show-overflow-tooltip>
          <template #default="{ row }">{{ row.origin || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="(PRODUCT_STATUS[row.status] || {}).type || 'info'">
              {{ (PRODUCT_STATUS[row.status] || {}).text || '未知' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openDialog(row)">编辑</el-button>
            <el-button
              v-if="row.status === 1"
              link
              type="warning"
              size="small"
              @click="toggleStatus(row, 0)"
            >下架</el-button>
            <el-button
              v-else-if="row.status === 0"
              link
              type="success"
              size="small"
              @click="toggleStatus(row, 1)"
            >上架</el-button>
            <el-button link type="danger" size="small" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="query.pageNum"
          v-model:page-size="query.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadList(1)"
          @current-change="loadList()"
        />
      </div>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="editingId ? '编辑商品' : '新增商品'"
      width="640px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="商品分类" prop="categoryPath">
          <el-cascader
            v-model="form.categoryPath"
            :options="categoryOptions"
            placeholder="请选择商品分类"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="form.name" maxlength="128" placeholder="如：沙窝萝卜 10斤装" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="价格(元)" prop="price">
              <el-input-number v-model="form.price" :min="0" :precision="2" :step="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="库存" prop="stock">
              <el-input-number v-model="form.stock" :min="0" :step="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="可选规格" prop="specs">
          <el-input v-model="form.specs" placeholder="多个规格用英文逗号分隔，如：5斤装,10斤装" />
        </el-form-item>
        <el-form-item label="产地" prop="origin">
          <el-input v-model="form.origin" maxlength="64" placeholder="如：天津西青区辛口镇" />
        </el-form-item>
        <el-form-item label="商品主图" prop="mainImage">
          <div class="main-image-box">
            <el-upload
              :show-file-list="false"
              accept=".jpg,.jpeg,.png,.webp,.gif"
              :before-upload="beforeUpload"
              :http-request="uploadMain"
            >
              <img v-if="form.mainImage" :src="form.mainImage" class="main-preview" alt="主图预览" />
              <el-button v-else type="primary" plain>
                <el-icon><Plus /></el-icon>&nbsp;上传主图
              </el-button>
            </el-upload>
            <el-button v-if="form.mainImage" link type="danger" size="small" @click="form.mainImage = ''">
              移除
            </el-button>
          </div>
          <div class="form-tip">支持 jpg/png/webp/gif，不超过 5MB</div>
        </el-form-item>
        <el-form-item label="详情图">
          <el-upload
            v-model:file-list="detailFiles"
            list-type="picture-card"
            accept=".jpg,.jpeg,.png,.webp,.gif"
            :limit="9"
            :before-upload="beforeUpload"
            :http-request="uploadDetail"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
          <div class="form-tip">最多 9 张，保存后按列表顺序在小程序详情页轮播</div>
        </el-form-item>
        <el-form-item label="图文描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="4" maxlength="2000" placeholder="商品图文详情介绍" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保 存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getMerchantProducts,
  getMerchantProduct,
  createProduct,
  updateProduct,
  deleteProduct
} from '../../api/merchant'
import { uploadImage } from '../../api/upload'
import { getCategories } from '../../api/public'
import { PRODUCT_STATUS, money, datetime } from '../../utils/constants'

const loading = ref(false)
const saving = ref(false)
const list = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const editingId = ref(null)
const formRef = ref(null)

const query = reactive({ keyword: '', status: null, pageNum: 1, pageSize: 10 })

// 详情图 file-list（与 images 逗号串互转）
const detailFiles = ref([])

const form = reactive({
  categoryPath: [],
  name: '',
  price: 0,
  stock: 0,
  specs: '',
  origin: '',
  mainImage: '',
  description: ''
})

const rules = {
  categoryPath: [{ required: true, message: '请选择商品分类', trigger: 'change' }],
  name: [{ required: true, message: '请输入商品名称', trigger: 'blur' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }],
  stock: [{ required: true, message: '请输入库存', trigger: 'blur' }]
}

// ===== 分类（两级树 → cascader） =====
const categoryOptions = ref([])
const categoryMap = {}

function buildCategoryOptions(tree) {
  const res = []
  ;(tree || []).forEach((c) => {
    categoryMap[c.id] = c.name
    const node = { value: c.id, label: c.name, children: [] }
    const children = c.children || []
    children.forEach((cc) => {
      categoryMap[cc.id] = cc.name
      node.children.push({ value: cc.id, label: cc.name })
    })
    if (!node.children.length) delete node.children
    res.push(node)
  })
  return res
}

function categoryName(id) {
  return categoryMap[id] || (id != null ? '#' + id : '-')
}

async function loadCategories() {
  try {
    const tree = await getCategories()
    categoryOptions.value = buildCategoryOptions(tree || [])
  } catch (e) {
    /* 拦截器已提示 */
  }
}

// ===== 列表 =====
async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getMerchantProducts({
      keyword: query.keyword || undefined,
      status: query.status === null || query.status === undefined ? undefined : query.status,
      pageNum: query.pageNum,
      pageSize: query.pageSize
    })
    list.value = (data && data.list) || []
    total.value = (data && data.total) || 0
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    loading.value = false
  }
}

// ===== 图片上传 =====
// 前端预检大小（格式由 accept 初筛，后端白名单兜底）
function beforeUpload(file) {
  if (file.size > 5 * 1024 * 1024) {
    ElMessage.error('图片不能超过 5MB')
    return false
  }
  return true
}

// 主图：上传成功回填表单
async function uploadMain(options) {
  try {
    const res = await uploadImage(options.file)
    form.mainImage = res.url
  } catch (e) {
    /* 拦截器已提示 */
  }
}

// 详情图：上传成功追加到 file-list（旧占位图路径原样透传）
async function uploadDetail(options) {
  try {
    const res = await uploadImage(options.file)
    detailFiles.value.push({ name: res.url, url: res.url })
  } catch (e) {
    /* 拦截器已提示 */
  }
}

// images 逗号串 → file-list
function imagesToFiles(images) {
  return String(images || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean)
    .map((p) => ({ name: p, url: p }))
}

// file-list → images 逗号串
function filesToImages(files) {
  return (files || []).map((f) => f.url).filter(Boolean).join(',')
}

// ===== 新增 / 编辑 =====
async function openDialog(row) {
  editingId.value = row ? row.id : null
  Object.assign(form, {
    categoryPath: [],
    name: '',
    price: 0,
    stock: 0,
    specs: '',
    origin: '',
    mainImage: '',
    description: ''
  })
  detailFiles.value = []
  if (row) {
    try {
      const d = await getMerchantProduct(row.id)
      form.categoryPath = d.categoryId ? [d.categoryId] : []
      // 若为二级分类，补全父级路径
      if (d.categoryPath && Array.isArray(d.categoryPath)) {
        form.categoryPath = d.categoryPath
      } else if (d.parentCategoryId) {
        form.categoryPath = [d.parentCategoryId, d.categoryId]
      }
      form.name = d.name || ''
      form.price = Number(d.price) || 0
      form.stock = Number(d.stock) || 0
      form.specs = d.specs || ''
      form.origin = d.origin || ''
      form.mainImage = d.mainImage || ''
      form.description = d.description || ''
      detailFiles.value = imagesToFiles(d.images)
    } catch (e) {
      return
    }
  }
  dialogVisible.value = true
}

function onSave() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    const categoryId = form.categoryPath[form.categoryPath.length - 1]
    const payload = {
      categoryId,
      name: form.name.trim(),
      price: form.price,
      stock: form.stock,
      specs: form.specs,
      origin: form.origin,
      mainImage: form.mainImage,
      images: filesToImages(detailFiles.value),
      description: form.description,
      status: editingId.value ? undefined : 1
    }
    saving.value = true
    try {
      if (editingId.value) {
        await updateProduct(editingId.value, payload)
        ElMessage.success('商品已更新')
      } else {
        await createProduct(payload)
        ElMessage.success('商品已创建并提交上架')
      }
      dialogVisible.value = false
      loadList()
    } catch (e) {
      /* 拦截器已提示 */
    } finally {
      saving.value = false
    }
  })
}

// ===== 上架 / 下架 =====
async function toggleStatus(row, status) {
  const action = status === 1 ? '上架' : '下架'
  try {
    await ElMessageBox.confirm('确定要' + action + '商品「' + row.name + '」吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch (e) {
    return
  }
  try {
    await updateProduct(row.id, { status })
    ElMessage.success(action + '成功')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

// ===== 删除 =====
async function onDelete(row) {
  try {
    await ElMessageBox.confirm(
      '删除商品「' + row.name + '」后将无法恢复，确定删除吗？',
      '危险操作',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'error' }
    )
  } catch (e) {
    return
  }
  try {
    await deleteProduct(row.id)
    ElMessage.success('删除成功')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

onMounted(() => {
  loadCategories()
  loadList()
})
</script>

<style scoped>
.main-image-box {
  display: flex;
  align-items: center;
  gap: 8px;
}
.main-preview {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 6px;
  border: 1px solid #dcdfe6;
  cursor: pointer;
}
.form-tip {
  font-size: 12px;
  color: #909399;
  line-height: 1.6;
  width: 100%;
}
</style>
