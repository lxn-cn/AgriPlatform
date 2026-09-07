<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">分类管理（两级树）</div>

      <div class="toolbar">
        <span class="toolbar-tip">维护商城商品分类，支持两级：一级分类（如时令水果）与二级分类（如苹果类）</span>
        <div class="grow"></div>
        <el-button type="success" @click="openDialog()">
          <el-icon><Plus /></el-icon>&nbsp;新增一级分类
        </el-button>
      </div>

      <el-table
        v-loading="loading"
        :data="tree"
        row-key="id"
        :tree-props="{ children: 'children' }"
        default-expand-all
        stripe
      >
        <el-table-column prop="name" label="分类名称" min-width="220" />
        <el-table-column label="层级" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.parentId === 0 ? 'primary' : 'success'" effect="plain">
              {{ row.parentId === 0 ? '一级' : '二级' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="80" align="center" />
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="子分类数" width="90" align="center">
          <template #default="{ row }">{{ (row.children || []).length }}</template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-if="row.parentId === 0" link type="success" size="small" @click="openDialog(null, row)">加子分类</el-button>
            <el-button link type="primary" size="small" @click="openDialog(row)">编辑</el-button>
            <el-button link type="danger" size="small" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="520px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="上级分类">
          <el-select v-model="form.parentId" style="width: 100%" :disabled="isChildEdit">
            <el-option label="无（作为一级分类）" :value="0" />
            <el-option v-for="c in firstLevel" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="form.name" maxlength="32" placeholder="如：时令水果 / 苹果类" />
        </el-form-item>
        <el-form-item label="排序值" prop="sort">
          <el-input-number v-model="form.sort" :min="0" :step="1" style="width: 160px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="停用" />
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
import { computed, reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getAdminCategories,
  createCategory,
  updateCategory,
  deleteCategory
} from '../../api/admin'
import { datetime } from '../../utils/constants'

const loading = ref(false)
const saving = ref(false)
const dialogVisible = ref(false)
const editingId = ref(null)
const formRef = ref(null)

// 后端返回树或平铺列表均可处理
const rawList = ref([])
const tree = ref([])

const form = reactive({
  parentId: 0,
  name: '',
  sort: 0,
  status: 1
})

const rules = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }]
}

const firstLevel = computed(() =>
  rawList.value.filter((c) => !c.parentId || Number(c.parentId) === 0)
)

const isChildEdit = ref(false)

const dialogTitle = computed(() => {
  if (editingId.value) return '编辑分类'
  if (form.parentId) return '新增二级分类'
  return '新增一级分类'
})

function buildTree(rows) {
  const tops = []
  const childrenMap = {}
  rows.forEach((r) => {
    const pid = Number(r.parentId) || 0
    if (pid === 0) {
      tops.push({ ...r, children: [] })
    } else {
      if (!childrenMap[pid]) childrenMap[pid] = []
      childrenMap[pid].push({ ...r })
    }
  })
  tops.forEach((t) => {
    t.children = childrenMap[t.id] || []
    if (!t.children.length) delete t.children
  })
  tops.sort((a, b) => (a.sort || 0) - (b.sort || 0))
  return tops
}

async function loadList() {
  loading.value = true
  try {
    const data = await getAdminCategories()
    let rows = []
    if (Array.isArray(data)) {
      // 判断是树还是平铺
      if (data.length && Array.isArray(data[0].children)) {
        rows = []
        data.forEach((p) => {
          rows.push({ ...p, children: undefined })
          ;(p.children || []).forEach((c) => rows.push(c))
        })
        rawList.value = data.map((p) => ({ ...p }))
        // tree 直接用返回结构
        tree.value = data.map((p) => ({ ...p }))
        loading.value = false
        return
      }
      rows = data
    }
    rawList.value = rows.map((r) => ({ ...r }))
    tree.value = buildTree(rows)
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    loading.value = false
  }
}

function openDialog(row, parent) {
  editingId.value = row ? row.id : null
  isChildEdit.value = !!row && !!row.parentId && Number(row.parentId) !== 0
  Object.assign(form, {
    parentId: parent ? parent.id : row ? Number(row.parentId) || 0 : 0,
    name: '',
    sort: 0,
    status: 1
  })
  if (row) {
    Object.assign(form, {
      parentId: Number(row.parentId) || 0,
      name: row.name || '',
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
      parentId: Number(form.parentId) || 0,
      name: form.name.trim(),
      sort: form.sort,
      status: form.status
    }
    try {
      if (editingId.value) {
        await updateCategory(editingId.value, payload)
        ElMessage.success('分类已更新')
      } else {
        await createCategory(payload)
        ElMessage.success('分类已创建')
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

async function onDelete(row) {
  if ((row.children || []).length) {
    ElMessage.warning('该一级分类下存在子分类，请先删除子分类')
    return
  }
  try {
    await ElMessageBox.confirm(
      '确定删除分类「' + row.name + '」吗？若已有商品使用该分类，删除可能影响商品展示。',
      '删除确认',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'error' }
    )
  } catch (e) {
    return
  }
  try {
    await deleteCategory(row.id)
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
</style>
