<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">预约管理</div>

      <el-alert
        v-if="store.unreadCount > 0"
        :title="'您有 ' + store.unreadCount + ' 条未读预约通知，请及时处理'"
        type="warning"
        show-icon
        :closable="false"
        style="margin: 12px 0"
      />

      <!-- 筛选 -->
      <div class="toolbar">
        <el-select v-model="query.status" placeholder="全部状态" clearable style="width: 140px" @change="loadList(1)">
          <el-option v-for="(v, k) in APPOINTMENT_STATUS" :key="k" :label="v.text" :value="Number(k)" />
        </el-select>
        <el-date-picker
          v-model="query.date"
          type="date"
          placeholder="按预约日期筛选"
          value-format="YYYY-MM-DD"
          clearable
          style="width: 180px"
          @change="loadList(1)"
        />
        <el-button type="primary" @click="loadList(1)">
          <el-icon><Search /></el-icon>&nbsp;查询
        </el-button>
        <div class="grow"></div>
        <el-button :loading="unreadLoading" @click="refreshUnread">
          <el-icon><Refresh /></el-icon>&nbsp;刷新未读数
        </el-button>
      </div>

      <!-- 预约列表 -->
      <el-table v-loading="loading" :data="list" stripe :row-class-name="rowClass">
        <el-table-column label="未读" width="70" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.merchantRead === 0" type="danger" size="small" effect="dark">新</el-tag>
            <span v-else style="color: #c0c4cc">已读</span>
          </template>
        </el-table-column>
        <el-table-column prop="appointmentNo" label="预约编号" min-width="170" show-overflow-tooltip />
        <el-table-column label="预约人" width="100" align="center">
          <template #default="{ row }">{{ row.contactName || '-' }}</template>
        </el-table-column>
        <el-table-column label="联系电话" width="130" align="center">
          <template #default="{ row }">
            <span class="phone-text">{{ row.contactPhone || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="预约日期 / 场次" width="160" align="center">
          <template #default="{ row }">
            <div>{{ row.appointDate || '-' }}</div>
            <el-tag size="small" effect="plain" type="info">{{ row.session || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="人数" width="70" align="center">
          <template #default="{ row }">{{ row.peopleCount + ' 人' }}</template>
        </el-table-column>
        <el-table-column label="金额" width="90" align="right">
          <template #default="{ row }">{{ money(row.amount) }}</template>
        </el-table-column>
        <el-table-column label="农园 / 项目" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">
            {{ [row.farmName, row.projectName].filter(Boolean).join(' · ') || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="(APPOINTMENT_STATUS[row.status] || {}).type || 'info'">
              {{ (APPOINTMENT_STATUS[row.status] || {}).text || '未知' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="下单时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 1"
              type="success"
              size="small"
              @click="openConfirmDialog(row)"
            >到园确认</el-button>
            <el-button
              v-if="row.merchantRead === 0"
              link
              type="primary"
              size="small"
              @click="onMarkRead(row)"
            >标记已读</el-button>
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

    <!-- 到园确认弹窗 -->
    <el-dialog v-model="confirmVisible" title="到园确认 · 核对预约信息" width="480px" :close-on-click-modal="false">
      <div v-if="confirmRow" class="confirm-box">
        <el-icon class="confirm-icon" color="#2e9e6b" :size="44"><CircleCheckFilled /></el-icon>
        <div class="confirm-name">{{ confirmRow.contactName }}</div>
        <div class="confirm-phone">{{ confirmRow.contactPhone }}</div>
        <div class="confirm-desc">
          请与到场用户核对其预留姓名与手机号，确认无误后点击下方按钮完成到园确认。
        </div>
        <el-descriptions :column="2" border size="small" style="margin-top: 16px">
          <el-descriptions-item label="预约日期">{{ confirmRow.appointDate }}</el-descriptions-item>
          <el-descriptions-item label="场次">{{ confirmRow.session }}</el-descriptions-item>
          <el-descriptions-item label="人数">{{ confirmRow.peopleCount }} 人</el-descriptions-item>
          <el-descriptions-item label="金额">{{ money(confirmRow.amount) }}</el-descriptions-item>
        </el-descriptions>
        <el-form label-width="120px" style="margin-top: 18px">
          <el-form-item label="核对手机尾号">
            <el-input
              v-model="phoneTail"
              maxlength="4"
              placeholder="选填：输入用户报出的手机号后 4 位"
              style="width: 220px"
            />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="confirmVisible = false">取 消</el-button>
        <el-button type="success" :loading="confirming" @click="onConfirmArrival">确认已到园</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getMerchantAppointments,
  getUnreadCount,
  markRead,
  confirmArrival
} from '../../api/merchant'
import { useUserStore } from '../../stores/user'
import { APPOINTMENT_STATUS, money, datetime } from '../../utils/constants'

const store = useUserStore()
const loading = ref(false)
const list = ref([])
const total = ref(0)
const unreadLoading = ref(false)

const query = reactive({ status: null, date: '', pageNum: 1, pageSize: 10 })

// 到园确认
const confirmVisible = ref(false)
const confirmRow = ref(null)
const confirming = ref(false)
const phoneTail = ref('')

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getMerchantAppointments({
      status: query.status === null || query.status === undefined ? undefined : query.status,
      date: query.date || undefined,
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

async function refreshUnread() {
  unreadLoading.value = true
  try {
    const data = await getUnreadCount()
    const n = typeof data === 'number' ? data : Number(data && (data.count != null ? data.count : data.unreadCount)) || 0
    store.setUnread(n)
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    unreadLoading.value = false
  }
}

function rowClass({ row }) {
  return row.merchantRead === 0 ? 'unread-row' : ''
}

async function onMarkRead(row) {
  try {
    await markRead(row.id)
    row.merchantRead = 1
    ElMessage.success('已标记为已读')
    refreshUnread()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

function openConfirmDialog(row) {
  confirmRow.value = row
  phoneTail.value = ''
  confirmVisible.value = true
}

async function onConfirmArrival() {
  const row = confirmRow.value
  if (!row) return
  try {
    await ElMessageBox.confirm(
      '确认「' + row.contactName + '（' + row.contactPhone + '）」已到园吗？确认后预约单状态将变为“已使用”。',
      '到园确认',
      { confirmButtonText: '确认到园', cancelButtonText: '再核对一下', type: 'warning' }
    )
  } catch (e) {
    return
  }
  confirming.value = true
  try {
    await confirmArrival(row.id, phoneTail.value ? { phoneTail: phoneTail.value.trim() } : {})
    ElMessage.success('到园确认成功，预约单已变为“已使用”')
    confirmVisible.value = false
    loadList()
    refreshUnread()
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    confirming.value = false
  }
}

onMounted(() => {
  loadList()
  refreshUnread()
})
</script>

<style scoped>
.phone-text {
  font-weight: 600;
  color: #1f2d3d;
  letter-spacing: 0.5px;
}

:deep(.unread-row) {
  background: #fdf6ec !important;
}

.confirm-box {
  text-align: center;
}

.confirm-name {
  font-size: 22px;
  font-weight: 700;
  margin-top: 8px;
}

.confirm-phone {
  font-size: 20px;
  font-weight: 700;
  color: #2e9e6b;
  letter-spacing: 2px;
  margin-top: 4px;
}

.confirm-desc {
  font-size: 13px;
  color: #909399;
  margin-top: 10px;
  line-height: 1.6;
}
</style>
