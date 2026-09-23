<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">用户管理</div>

      <div class="toolbar">
        <el-input
          v-model="query.keyword"
          placeholder="昵称 / 手机号"
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
        <el-button type="success" @click="openCreate()">
          <el-icon><Plus /></el-icon>&nbsp;新增用户
        </el-button>
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column label="头像" width="76" align="center">
          <template #default="{ row }">
            <el-avatar v-if="row.avatar" :size="40" :src="row.avatar" />
            <el-avatar v-else :size="40">{{ (row.nickname || '用').slice(0, 1) }}</el-avatar>
          </template>
        </el-table-column>
        <el-table-column prop="nickname" label="昵称" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">{{ row.nickname || '-' }}</template>
        </el-table-column>
        <el-table-column label="手机号（脱敏）" width="140" align="center">
          <template #default="{ row }">{{ maskPhone(row.phone) }}</template>
        </el-table-column>
        <el-table-column prop="openid" label="OpenID" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ row.openid || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? '正常' : '已禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="注册时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-if="row.status === 1" link type="danger" size="small" @click="onToggle(row, 0)">禁用</el-button>
            <el-button v-else link type="success" size="small" @click="onToggle(row, 1)">启用</el-button>
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

    <!-- 新增用户弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      title="新增用户"
      width="480px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="form.nickname" maxlength="32" placeholder="如：王同学" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="form.phone" maxlength="11" placeholder="11 位手机号" />
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
import { getUsers, setUserStatus, createUser, deleteUser } from '../../api/admin'
import { datetime, maskPhone } from '../../utils/constants'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ keyword: '', pageNum: 1, pageSize: 10 })

const dialogVisible = ref(false)
const saving = ref(false)
const formRef = ref(null)
const form = reactive({ nickname: '', phone: '' })

const rules = {
  nickname: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ]
}

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getUsers({
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

async function onToggle(row, status) {
  const action = status === 1 ? '启用' : '禁用'
  try {
    await ElMessageBox.confirm(
      '确定要' + action + '用户「' + (row.nickname || row.id) + '」吗？' +
        (status === 0 ? '禁用后该用户将无法登录小程序。' : ''),
      action + '用户',
      { confirmButtonText: '确定' + action, cancelButtonText: '取消', type: status === 0 ? 'error' : 'warning' }
    )
  } catch (e) {
    return
  }
  try {
    await setUserStatus(row.id, { status })
    ElMessage.success(action + '成功')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

function openCreate() {
  form.nickname = ''
  form.phone = ''
  dialogVisible.value = true
}

function onSave() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    saving.value = true
    try {
      await createUser({ nickname: form.nickname.trim(), phone: form.phone.trim() })
      ElMessage.success('用户已新增')
      dialogVisible.value = false
      loadList(1)
    } catch (e) {
      /* 拦截器已提示 */
    } finally {
      saving.value = false
    }
  })
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm(
      '确定删除用户「' + (row.nickname || row.id) + '」吗？删除后不可恢复；名下有订单或预约的用户无法删除。',
      '删除用户',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'error' }
    )
  } catch (e) {
    return
  }
  try {
    await deleteUser(row.id)
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
