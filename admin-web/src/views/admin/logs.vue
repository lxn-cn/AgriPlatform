<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">操作日志</div>

      <div class="toolbar">
        <el-alert
          type="info"
          :closable="false"
          show-icon
          style="flex: 1; padding: 4px 12px"
          title="商家审核、封禁、退款、强制下架、到园确认等关键操作均会记录在此，便于追溯"
        />
        <el-button type="primary" @click="loadList(1)">
          <el-icon><Refresh /></el-icon>&nbsp;刷新
        </el-button>
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column label="操作人类型" width="110" align="center">
          <template #default="{ row }">
            <el-tag :type="operatorTag(row.operatorType).type" effect="plain">
              {{ operatorTag(row.operatorType).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="operatorName" label="操作人" width="140" show-overflow-tooltip>
          <template #default="{ row }">{{ row.operatorName || ('#' + row.operatorId) }}</template>
        </el-table-column>
        <el-table-column label="动作" width="180" align="center">
          <template #default="{ row }">
            <el-tag :type="actionTag(row.action).type" size="small">{{ actionTag(row.action).text }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="detail" label="操作详情" min-width="320" show-overflow-tooltip />
        <el-table-column prop="createTime" label="操作时间" width="170" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
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
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { getLogs } from '../../api/admin'
import { datetime } from '../../utils/constants'

const loading = ref(false)
const list = ref([])
const total = ref(0)

const query = reactive({ pageNum: 1, pageSize: 10 })

const OPERATOR_TYPES = {
  ADMIN: { text: '管理员', type: 'primary' },
  MERCHANT: { text: '商家', type: 'success' },
  USER: { text: '用户', type: 'info' }
}

const ACTIONS = {
  MERCHANT_AUDIT: { text: '商家审核', type: 'warning' },
  MERCHANT_BAN: { text: '商家封禁', type: 'danger' },
  MERCHANT_UNBAN: { text: '商家解禁', type: 'success' },
  PRODUCT_FORCE_OFF: { text: '强制下架', type: 'danger' },
  ORDER_REFUND_AGREE: { text: '同意退款', type: 'warning' },
  APPOINTMENT_CONFIRM: { text: '到园确认', type: 'success' },
  USER_STATUS: { text: '用户启禁用', type: 'info' },
  ADMIN_CREATE: { text: '新增管理员', type: 'primary' },
  ADMIN_UPDATE: { text: '修改管理员', type: 'primary' }
}

function operatorTag(type) {
  return OPERATOR_TYPES[type] || { text: type || '未知', type: 'info' }
}

function actionTag(action) {
  return ACTIONS[action] || { text: action || '其他操作', type: 'info' }
}

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getLogs({ pageNum: query.pageNum, pageSize: query.pageSize })
    list.value = (data && data.list) || []
    total.value = (data && data.total) || 0
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadList()
})
</script>
