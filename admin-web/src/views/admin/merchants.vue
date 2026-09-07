<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">商家审核</div>

      <div class="toolbar">
        <el-select v-model="query.status" placeholder="全部状态" clearable style="width: 150px" @change="loadList(1)">
          <el-option label="待审核" :value="0" />
          <el-option label="已通过" :value="1" />
          <el-option label="已封禁" :value="2" />
        </el-select>
        <el-input
          v-model="query.keyword"
          placeholder="商家名称 / 账号"
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
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="name" label="商家名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="username" label="账号" width="120" show-overflow-tooltip>
          <template #default="{ row }">{{ row.username || '-' }}</template>
        </el-table-column>
        <el-table-column prop="contact" label="联系人" width="100" align="center">
          <template #default="{ row }">{{ row.contact || '-' }}</template>
        </el-table-column>
        <el-table-column prop="phone" label="联系电话" width="130" align="center">
          <template #default="{ row }">{{ row.phone || '-' }}</template>
        </el-table-column>
        <el-table-column prop="licenseInfo" label="资质信息" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ row.licenseInfo || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="(MERCHANT_STATUS[row.status] || {}).type || 'info'">
              {{ (MERCHANT_STATUS[row.status] || {}).text || '未知' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="申请时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" type="primary" size="small" @click="openAudit(row)">审核</el-button>
            <el-button v-if="row.status === 1" link type="danger" size="small" @click="onBan(row, 1)">封禁</el-button>
            <el-button v-if="row.status === 2" link type="success" size="small" @click="onBan(row, 0)">解禁</el-button>
            <el-button link type="info" size="small" @click="showDetail(row)">详情</el-button>
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

    <!-- 审核弹窗 -->
    <el-dialog v-model="auditVisible" title="商家入驻审核" width="560px" :close-on-click-modal="false">
      <el-descriptions v-if="auditRow" :column="2" border size="small">
        <el-descriptions-item label="商家名称">{{ auditRow.name }}</el-descriptions-item>
        <el-descriptions-item label="账号">{{ auditRow.username }}</el-descriptions-item>
        <el-descriptions-item label="联系人">{{ auditRow.contact || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ auditRow.phone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="资质信息" :span="2">{{ auditRow.licenseInfo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="简介" :span="2">{{ auditRow.intro || '-' }}</el-descriptions-item>
      </el-descriptions>
      <el-divider content-position="left">审核结论</el-divider>
      <el-radio-group v-model="auditForm.pass">
        <el-radio :label="true">通过</el-radio>
        <el-radio :label="false">驳回</el-radio>
      </el-radio-group>
      <el-input
        v-model="auditForm.reason"
        type="textarea"
        :rows="2"
        maxlength="200"
        placeholder="驳回时必填驳回原因（将告知商家）"
        style="margin-top: 12px"
      />
      <template #footer>
        <el-button @click="auditVisible = false">取 消</el-button>
        <el-button type="primary" :loading="auditing" @click="onAuditSubmit">提交审核</el-button>
      </template>
    </el-dialog>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="商家详情" width="560px">
      <el-descriptions v-if="detailRow" :column="2" border size="small">
        <el-descriptions-item label="商家名称">{{ detailRow.name }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="(MERCHANT_STATUS[detailRow.status] || {}).type || 'info'">
            {{ (MERCHANT_STATUS[detailRow.status] || {}).text || '未知' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="联系人">{{ detailRow.contact || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ detailRow.phone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="资质信息" :span="2">{{ detailRow.licenseInfo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="简介" :span="2">{{ detailRow.intro || '-' }}</el-descriptions-item>
        <el-descriptions-item label="驳回原因" :span="2" v-if="detailRow.rejectReason">
          <span style="color: #f56c6c">{{ detailRow.rejectReason }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="申请时间" :span="2">{{ datetime(detailRow.createTime) }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getMerchants, auditMerchant, banMerchant, unbanMerchant } from '../../api/admin'
import { MERCHANT_STATUS, datetime } from '../../utils/constants'

const loading = ref(false)
const list = ref([])
const total = ref(0)

const query = reactive({ status: null, keyword: '', pageNum: 1, pageSize: 10 })

const auditVisible = ref(false)
const auditing = ref(false)
const auditRow = ref(null)
const auditForm = reactive({ pass: true, reason: '' })

const detailVisible = ref(false)
const detailRow = ref(null)

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getMerchants({
      status: query.status === null || query.status === undefined ? undefined : query.status,
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

function openAudit(row) {
  auditRow.value = row
  auditForm.pass = true
  auditForm.reason = ''
  auditVisible.value = true
}

function onAuditSubmit() {
  const row = auditRow.value
  if (!row) return
  if (!auditForm.pass && !auditForm.reason.trim()) {
    ElMessage.warning('驳回时请填写驳回原因')
    return
  }
  auditing.value = true
  auditMerchant(row.id, { pass: auditForm.pass, reason: auditForm.reason.trim() })
    .then(() => {
      ElMessage.success(auditForm.pass ? '已审核通过' : '已驳回该申请')
      auditVisible.value = false
      loadList()
    })
    .catch(() => {})
    .finally(() => {
      auditing.value = false
    })
}

async function onBan(row, ban) {
  const action = ban ? '封禁' : '解禁'
  try {
    await ElMessageBox.confirm(
      '确定要' + action + '商家「' + row.name + '」吗？' + (ban ? '封禁后该商家将无法登录管理端。' : '解禁后该商家可正常登录。'),
      action + '商家',
      { confirmButtonText: '确定' + action, cancelButtonText: '取消', type: ban ? 'error' : 'warning' }
    )
  } catch (e) {
    return
  }
  try {
    if (ban) {
      await banMerchant(row.id)
    } else {
      await unbanMerchant(row.id)
    }
    ElMessage.success(action + '成功')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

function showDetail(row) {
  detailRow.value = row
  detailVisible.value = true
}

onMounted(() => {
  loadList()
})
</script>
