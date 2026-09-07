<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">管理员账号</div>

      <div class="toolbar">
        <el-alert
          type="warning"
          :closable="false"
          show-icon
          style="flex: 1; padding: 4px 12px"
          title="仅超级管理员（SUPER）可维护管理员账号；ADMIN 为普通管理员，SUPER 拥有全部权限"
        />
        <el-button type="primary" @click="openDialog(null)">
          <el-icon><Plus /></el-icon>&nbsp;新增管理员
        </el-button>
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="username" label="账号" width="160" show-overflow-tooltip />
        <el-table-column prop="name" label="姓名" width="140" show-overflow-tooltip>
          <template #default="{ row }">{{ row.name || '-' }}</template>
        </el-table-column>
        <el-table-column label="角色" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="row.role === 'SUPER' ? 'danger' : 'primary'">
              {{ row.role === 'SUPER' ? '超级管理员' : '管理员' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="110" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openDialog(row)">编辑</el-button>
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
      :title="editingId ? '编辑管理员' : '新增管理员'"
      width="480px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="92px">
        <el-form-item label="登录账号" prop="username">
          <el-input
            v-model="form.username"
            :disabled="!!editingId"
            maxlength="32"
            placeholder="登录账号（创建后不可修改）"
          />
        </el-form-item>
        <el-form-item label="登录密码" prop="password">
          <el-input
            v-model="form.password"
            type="password"
            show-password
            maxlength="32"
            :placeholder="editingId ? '留空表示不修改密码' : '至少 6 位'"
          />
        </el-form-item>
        <el-form-item label="姓名" prop="name">
          <el-input v-model="form.name" maxlength="32" placeholder="管理员姓名" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-radio-group v-model="form.role">
            <el-radio label="ADMIN">管理员</el-radio>
            <el-radio label="SUPER">超级管理员</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="editingId" label="状态">
          <el-switch
            v-model="form.status"
            :active-value="1"
            :inactive-value="0"
            active-text="启用"
            inactive-text="停用"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">
          {{ editingId ? '保存修改' : '创建账号' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getAdmins, createAdmin, updateAdmin } from '../../api/admin'
import { datetime } from '../../utils/constants'

const loading = ref(false)
const saving = ref(false)
const list = ref([])
const total = ref(0)

const query = reactive({ pageNum: 1, pageSize: 10 })

const dialogVisible = ref(false)
const formRef = ref(null)
const editingId = ref(null)

const form = reactive({
  username: '',
  password: '',
  name: '',
  role: 'ADMIN',
  status: 1
})

const rules = {
  username: [{ required: true, message: '请输入登录账号', trigger: 'blur' }],
  password: [
    {
      validator: (rule, value, callback) => {
        if (!editingId.value && (!value || value.length < 6)) {
          callback(new Error('密码长度不能少于 6 位'))
          return
        }
        if (editingId.value && value && value.length < 6) {
          callback(new Error('密码长度不能少于 6 位'))
          return
        }
        callback()
      },
      trigger: 'blur'
    }
  ]
}

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getAdmins({ pageNum: query.pageNum, pageSize: query.pageSize })
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
  form.username = row ? row.username : ''
  form.password = ''
  form.name = row ? row.name || '' : ''
  form.role = row ? row.role || 'ADMIN' : 'ADMIN'
  form.status = row ? row.status : 1
  dialogVisible.value = true
}

function onSave() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    saving.value = true
    try {
      if (editingId.value) {
        await updateAdmin(editingId.value, {
          name: form.name.trim(),
          role: form.role,
          status: form.status,
          password: form.password || undefined
        })
        ElMessage.success('修改已保存')
      } else {
        await createAdmin({
          username: form.username.trim(),
          password: form.password,
          name: form.name.trim(),
          role: form.role
        })
        ElMessage.success('管理员账号已创建')
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

onMounted(() => {
  loadList()
})
</script>
