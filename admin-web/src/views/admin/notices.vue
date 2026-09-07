<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">公告管理</div>

      <div class="toolbar">
        <el-input
          v-model="query.keyword"
          placeholder="公告标题关键词"
          clearable
          style="width: 220px"
          @keyup.enter="loadList(1)"
          @clear="loadList(1)"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-button type="primary" @click="loadList(1)">
          <el-icon><Search /></el-icon>&nbsp;查询
        </el-button>
        <div class="grow"></div>
        <el-button type="success" @click="openDialog()">
          <el-icon><Plus /></el-icon>&nbsp;新增公告
        </el-button>
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="title" label="公告标题" min-width="200" show-overflow-tooltip />
        <el-table-column prop="content" label="内容摘要" min-width="240" show-overflow-tooltip>
          <template #default="{ row }">{{ (row.content || '').slice(0, 50) || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '已发布' : '已下线' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="publishTime" label="发布时间" width="170" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.publishTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openDialog(row)">编辑</el-button>
            <el-button
              v-if="row.status === 1"
              link
              type="warning"
              size="small"
              @click="onToggle(row, 0)"
            >下线</el-button>
            <el-button
              v-else
              link
              type="success"
              size="small"
              @click="onToggle(row, 1)"
            >上线</el-button>
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
      :title="editingId ? '编辑公告' : '新增公告'"
      width="620px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="公告标题" prop="title">
          <el-input v-model="form.title" maxlength="128" placeholder="公告标题" />
        </el-form-item>
        <el-form-item label="公告内容" prop="content">
          <el-input
            v-model="form.content"
            type="textarea"
            :rows="6"
            maxlength="5000"
            show-word-limit
            placeholder="公告正文内容"
          />
        </el-form-item>
        <el-form-item label="发布状态">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="发布" inactive-text="下线" />
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
import { getNotices, createNotice, updateNotice, deleteNotice } from '../../api/admin'
import { datetime } from '../../utils/constants'

const loading = ref(false)
const saving = ref(false)
const list = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const editingId = ref(null)
const formRef = ref(null)

const query = reactive({ keyword: '', pageNum: 1, pageSize: 10 })

const form = reactive({
  title: '',
  content: '',
  status: 1
})

const rules = {
  title: [{ required: true, message: '请输入公告标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入公告内容', trigger: 'blur' }]
}

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getNotices({
      keyword: query.keyword || undefined,
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

function openDialog(row) {
  editingId.value = row ? row.id : null
  Object.assign(form, {
    title: '',
    content: '',
    status: 1
  })
  if (row) {
    Object.assign(form, {
      title: row.title || '',
      content: row.content || '',
      status: row.status != null ? row.status : 1
    })
  }
  dialogVisible.value = true
}

function onSave() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    saving.value = true
    const payload = { ...form }
    try {
      if (editingId.value) {
        await updateNotice(editingId.value, payload)
        ElMessage.success('公告已更新')
      } else {
        await createNotice(payload)
        ElMessage.success('公告已创建')
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

async function onToggle(row, status) {
  const action = status === 1 ? '上线' : '下线'
  try {
    await updateNotice(row.id, { status })
    ElMessage.success(action + '成功')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm(
      '确定删除公告「' + row.title + '」吗？',
      '删除确认',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'error' }
    )
  } catch (e) {
    return
  }
  try {
    await deleteNotice(row.id)
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
