<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">轮播图管理</div>

      <div class="toolbar">
        <span class="toolbar-tip">维护小程序首页轮播图，支持新增、编辑、删除与排序调整</span>
        <div class="grow"></div>
        <el-button type="success" @click="openDialog()">
          <el-icon><Plus /></el-icon>&nbsp;新增轮播图
        </el-button>
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column label="图片" width="150" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.image"
              :src="row.image"
              :preview-src-list="[row.image]"
              preview-teleported
              fit="cover"
              style="width: 120px; height: 50px; border-radius: 6px"
            />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="标题" min-width="150" show-overflow-tooltip>
          <template #default="{ row }">{{ row.title || '-' }}</template>
        </el-table-column>
        <el-table-column label="跳转类型" width="110" align="center">
          <template #default="{ row }">
            <el-tag :type="linkTypeTag(row.linkType)" effect="plain">
              {{ linkTypeText(row.linkType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="linkValue" label="跳转目标" width="100" align="center">
          <template #default="{ row }">{{ row.linkValue || '-' }}</template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="140" align="center">
          <template #default="{ row }">
            <el-button link size="small" :disabled="loading" @click="moveSort(row, -1)">
              <el-icon><ArrowUp /></el-icon>
            </el-button>
            <span class="sort-num">{{ row.sort }}</span>
            <el-button link size="small" :disabled="loading" @click="moveSort(row, 1)">
              <el-icon><ArrowDown /></el-icon>
            </el-button>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '展示中' : '已隐藏' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="130" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openDialog(row)">编辑</el-button>
            <el-button link type="danger" size="small" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="editingId ? '编辑轮播图' : '新增轮播图'"
      width="560px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="form.title" maxlength="64" placeholder="如：秋收茶淀葡萄特惠" />
        </el-form-item>
        <el-form-item label="图片路径" prop="image">
          <el-input v-model="form.image" placeholder="/api/file/placeholder/banner1.png" />
        </el-form-item>
        <el-form-item label="跳转类型" prop="linkType">
          <el-select v-model="form.linkType" style="width: 100%">
            <el-option v-for="t in LINK_TYPES" :key="t.value" :label="t.label" :value="t.value" />
          </el-select>
        </el-form-item>
        <el-form-item
          v-if="form.linkType && form.linkType !== 'none'"
          label="跳转目标ID"
          prop="linkValue"
          :rules="[{ required: true, message: '请输入跳转目标 ID', trigger: 'blur' }]"
        >
          <el-input v-model="form.linkValue" placeholder="商品/农园/公告的 ID" />
        </el-form-item>
        <el-form-item label="排序值" prop="sort">
          <el-input-number v-model="form.sort" :min="0" :step="1" style="width: 160px" />
          <span class="form-tip">&nbsp;数值越小越靠前</span>
        </el-form-item>
        <el-form-item label="是否展示">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="展示" inactive-text="隐藏" />
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
import { getBanners, createBanner, updateBanner, deleteBanner } from '../../api/admin'
import { LINK_TYPES } from '../../utils/constants'

const loading = ref(false)
const saving = ref(false)
const list = ref([])
const dialogVisible = ref(false)
const editingId = ref(null)
const formRef = ref(null)

const query = reactive({ pageNum: 1, pageSize: 50 })

const form = reactive({
  title: '',
  image: '',
  linkType: 'none',
  linkValue: '',
  sort: 0,
  status: 1
})

const rules = {
  image: [{ required: true, message: '请输入图片路径', trigger: 'blur' }]
}

function linkTypeText(t) {
  const item = LINK_TYPES.find((x) => x.value === t)
  return item ? item.label : t || '无跳转'
}

function linkTypeTag(t) {
  if (t === 'product') return 'success'
  if (t === 'farm') return 'primary'
  if (t === 'notice') return 'warning'
  return 'info'
}

async function loadList() {
  loading.value = true
  try {
    const data = await getBanners()
    let arr = []
    if (Array.isArray(data)) {
      arr = data
    } else if (data && Array.isArray(data.list)) {
      arr = data.list
    }
    list.value = arr.slice().sort((a, b) => (a.sort || 0) - (b.sort || 0))
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    loading.value = false
  }
}

function openDialog(row) {
  editingId.value = row ? row.id : null
  Object.assign(form, {
    title: '',
    image: '',
    linkType: 'none',
    linkValue: '',
    sort: (list.value.length + 1) * 10,
    status: 1
  })
  if (row) {
    Object.assign(form, {
      title: row.title || '',
      image: row.image || '',
      linkType: row.linkType || 'none',
      linkValue: row.linkValue || '',
      sort: Number(row.sort) || 0,
      status: row.status != null ? row.status : 1
    })
  }
  dialogVisible.value = true
}

function onSave() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    saving.value = true
    const payload = {
      title: form.title.trim(),
      image: form.image.trim(),
      linkType: form.linkType,
      linkValue: form.linkType === 'none' ? '' : form.linkValue,
      sort: form.sort,
      status: form.status
    }
    try {
      if (editingId.value) {
        await updateBanner(editingId.value, payload)
        ElMessage.success('轮播图已更新')
      } else {
        await createBanner(payload)
        ElMessage.success('轮播图已新增')
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

// 上移 / 下移：调整排序值
async function moveSort(row, dir) {
  const newSort = Math.max(0, (Number(row.sort) || 0) + dir)
  try {
    await updateBanner(row.id, { sort: newSort })
    row.sort = newSort
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm(
      '确定删除该轮播图（' + (row.title || 'ID ' + row.id) + '）吗？',
      '删除确认',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'error' }
    )
  } catch (e) {
    return
  }
  try {
    await deleteBanner(row.id)
    ElMessage.success('删除成功')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

onMounted(() => {
  loadList()
})
</script>

<style scoped>
.toolbar-tip {
  font-size: 13px;
  color: #909399;
}

.sort-num {
  display: inline-block;
  min-width: 30px;
  text-align: center;
  font-weight: 600;
}

.form-tip {
  font-size: 12px;
  color: #a8abb2;
}
</style>
