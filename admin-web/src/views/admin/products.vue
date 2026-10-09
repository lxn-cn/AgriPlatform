<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">商品管理（全平台）</div>

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
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column label="主图" width="76" align="center">
          <template #default="{ row }">
            <img v-if="row.mainImage" class="thumb" :src="row.mainImage" alt="主图" />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="商品名称" min-width="180" show-overflow-tooltip />
        <el-table-column prop="merchantName" label="所属商家" width="140" show-overflow-tooltip>
          <template #default="{ row }">{{ row.merchantName || '#' + row.merchantId }}</template>
        </el-table-column>
        <el-table-column label="价格" width="100" align="right">
          <template #default="{ row }">
            <span style="color: #e6a23c; font-weight: 600">{{ money(row.price) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="80" align="center" />
        <el-table-column prop="sales" label="销量" width="80" align="center" />
        <el-table-column prop="origin" label="产地" width="110" show-overflow-tooltip>
          <template #default="{ row }">{{ row.origin || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.status === 0 && row.rejectReason" type="danger">已驳回</el-tag>
            <el-tag v-else :type="(PRODUCT_STATUS[row.status] || {}).type || 'info'">
              {{ (PRODUCT_STATUS[row.status] || {}).text || '未知' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="推荐" width="70" align="center">
          <template #header>
            推荐<el-tooltip content="勾选后展示在小程序首页「当季推荐」，仅对上架商品生效；都没勾选时首页按销量自动推荐" placement="top">
              <el-icon style="vertical-align: -2px; margin-left: 2px; cursor: help; color: #909399"><QuestionFilled /></el-icon>
            </el-tooltip>
          </template>
          <template #default="{ row }">
            <el-switch
              :model-value="row.isRecommend === 1"
              :loading="row.recommendLoading"
              @change="(val) => onRecommend(row, val)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="170" fixed="right" align="center">
          <template #default="{ row }">
            <template v-if="row.status === 2">
              <el-button link type="success" size="small" @click="onAuditPass(row)">通过</el-button>
              <el-button link type="danger" size="small" @click="openReject(row)">驳回</el-button>
            </template>
            <el-button
              v-else-if="row.status === 1"
              link
              type="danger"
              size="small"
              @click="onForceOff(row)"
            >强制下架</el-button>
            <span v-else style="color: #c0c4cc">-</span>
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

    <!-- 驳回弹窗 -->
    <el-dialog v-model="rejectVisible" title="驳回商品" width="480px" :close-on-click-modal="false">
      <div style="color: #909399; font-size: 12px; line-height: 1.6; margin-bottom: 12px">
        驳回后商品将下架，商家可在商品列表查看驳回原因；商家修改商品后将重新提交审核。
      </div>
      <el-input
        v-model="rejectReason"
        type="textarea"
        :rows="3"
        maxlength="200"
        show-word-limit
        placeholder="请填写驳回原因（必填，将告知商家）"
      />
      <template #footer>
        <el-button @click="rejectVisible = false">取 消</el-button>
        <el-button type="danger" :loading="rejecting" @click="onRejectSubmit">确认驳回</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAdminProducts, forceOffProduct, auditProduct, setProductRecommend } from '../../api/admin'
import { PRODUCT_STATUS, money, datetime } from '../../utils/constants'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ keyword: '', status: null, pageNum: 1, pageSize: 10 })

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getAdminProducts({
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

// ===== 首页推荐开关（FR-01-04） =====
async function onRecommend(row, val) {
  row.recommendLoading = true
  try {
    await setProductRecommend(row.id, { recommend: val })
    row.isRecommend = val ? 1 : 0
    ElMessage.success(val ? '已设为首页推荐' : '已取消首页推荐')
  } catch (e) {
    /* 拦截器已提示；model-value 未变，开关自动回弹 */
  } finally {
    row.recommendLoading = false
  }
}

async function onForceOff(row) {
  try {
    await ElMessageBox.confirm(
      '确定强制下架商品「' + row.name + '」吗？该操作将记录操作日志，用于违规商品巡检处置。',
      '强制下架',
      { confirmButtonText: '确定下架', cancelButtonText: '取消', type: 'error' }
    )
  } catch (e) {
    return
  }
  try {
    await forceOffProduct(row.id)
    ElMessage.success('已强制下架')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

// ===== 审核：通过 / 驳回 =====
const rejectVisible = ref(false)
const rejecting = ref(false)
const rejectReason = ref('')
const rejectRow = ref(null)

async function onAuditPass(row) {
  try {
    await ElMessageBox.confirm(
      '确定通过审核并上架商品「' + row.name + '」吗？通过后小程序立即可见。',
      '审核通过',
      { confirmButtonText: '通过并上架', cancelButtonText: '取消', type: 'success' }
    )
  } catch (e) {
    return
  }
  try {
    await auditProduct(row.id, { pass: true, reason: '' })
    ElMessage.success('已通过，商品已上架')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

function openReject(row) {
  rejectRow.value = row
  rejectReason.value = ''
  rejectVisible.value = true
}

function onRejectSubmit() {
  const row = rejectRow.value
  if (!row) return
  if (!rejectReason.value.trim()) {
    ElMessage.warning('请填写驳回原因')
    return
  }
  rejecting.value = true
  auditProduct(row.id, { pass: false, reason: rejectReason.value.trim() })
    .then(() => {
      ElMessage.success('已驳回该商品')
      rejectVisible.value = false
      loadList()
    })
    .catch(() => {})
    .finally(() => {
      rejecting.value = false
    })
}

onMounted(() => {
  loadList()
})
</script>
