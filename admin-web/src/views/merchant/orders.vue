<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">订单管理</div>

      <el-tabs v-model="activeTab" @tab-change="loadList(1)">
        <el-tab-pane label="全部订单" name="all" />
        <el-tab-pane label="待发货" name="1" />
        <el-tab-pane label="待收货" name="2" />
        <el-tab-pane label="已完成" name="3" />
        <el-tab-pane label="退款中" name="5" />
      </el-tabs>

      <div class="toolbar">
        <el-input
          v-model="query.orderNo"
          placeholder="订单号"
          clearable
          style="width: 240px"
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
        <el-table-column type="expand">
          <template #default="{ row }">
            <div class="order-expand">
              <div class="expand-title">订单明细</div>
              <el-table :data="row.items || []" size="small" border>
                <el-table-column label="图片" width="76" align="center">
                  <template #default="{ row: it }">
                    <img v-if="it.mainImage" class="thumb" :src="it.mainImage" alt="商品图" />
                    <span v-else>-</span>
                  </template>
                </el-table-column>
                <el-table-column prop="productName" label="商品名称" min-width="180" show-overflow-tooltip />
                <el-table-column prop="spec" label="规格" width="100" align="center">
                  <template #default="{ row: it }">{{ it.spec || '-' }}</template>
                </el-table-column>
                <el-table-column label="单价" width="100" align="right">
                  <template #default="{ row: it }">{{ money(it.price) }}</template>
                </el-table-column>
                <el-table-column prop="quantity" label="数量" width="80" align="center" />
                <el-table-column label="小计" width="100" align="right">
                  <template #default="{ row: it }">{{ money(Number(it.price) * Number(it.quantity)) }}</template>
                </el-table-column>
              </el-table>
              <div class="expand-extra" v-if="row.remark || row.refundReason">
                <span v-if="row.remark">买家留言：{{ row.remark }}</span>
                <span v-if="row.refundReason" style="color: #f56c6c">退款原因：{{ row.refundReason }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="orderNo" label="订单号" min-width="180" show-overflow-tooltip />
        <el-table-column label="收货人" width="100" align="center">
          <template #default="{ row }">{{ row.receiver || '-' }}</template>
        </el-table-column>
        <el-table-column label="收货电话" width="130" align="center">
          <template #default="{ row }">{{ maskPhone(row.phone) }}</template>
        </el-table-column>
        <el-table-column prop="address" label="收货地址" min-width="200" show-overflow-tooltip />
        <el-table-column label="金额" width="100" align="right">
          <template #default="{ row }">
            <span style="color: #e6a23c; font-weight: 600">{{ money(row.totalAmount) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="(ORDER_STATUS[row.status] || {}).type || 'info'">
              {{ (ORDER_STATUS[row.status] || {}).text || '未知' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="下单时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-if="row.status === 1" link type="primary" size="small" @click="onShip(row)">发货</el-button>
            <el-button v-if="row.status === 5" link type="danger" size="small" @click="onRefund(row)">同意退款</el-button>
            <span v-if="row.status !== 1 && row.status !== 5" style="color: #c0c4cc">-</span>
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
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getMerchantOrders, shipOrder, agreeRefund } from '../../api/merchant'
import { ORDER_STATUS, money, datetime, maskPhone } from '../../utils/constants'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const activeTab = ref('all')

const query = reactive({ orderNo: '', pageNum: 1, pageSize: 10 })

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getMerchantOrders({
      status: activeTab.value === 'all' ? undefined : Number(activeTab.value),
      orderNo: query.orderNo || undefined,
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

async function onShip(row) {
  try {
    await ElMessageBox.confirm(
      '确认为订单 ' + row.orderNo + ' 发货吗？发货后订单进入“待收货”状态。',
      '发货确认',
      { confirmButtonText: '确认发货', cancelButtonText: '取消', type: 'warning' }
    )
  } catch (e) {
    return
  }
  try {
    await shipOrder(row.id)
    ElMessage.success('发货成功')
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

async function onRefund(row) {
  try {
    await ElMessageBox.confirm(
      '确定同意订单 ' + row.orderNo + ' 的退款申请吗？退款金额 ' + money(row.totalAmount) + '，库存将回滚。',
      '同意退款',
      { confirmButtonText: '同意退款', cancelButtonText: '取消', type: 'error' }
    )
  } catch (e) {
    return
  }
  try {
    await agreeRefund(row.id)
    ElMessage.success('已同意退款')
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
.order-expand {
  padding: 8px 16px 16px;
}

.expand-title {
  font-weight: 600;
  margin-bottom: 8px;
  color: #1f2d3d;
}

.expand-extra {
  margin-top: 10px;
  font-size: 13px;
  color: #909399;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
</style>
