<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">订单总览</div>

      <div class="toolbar">
        <el-select v-model="query.status" placeholder="全部状态" clearable style="width: 140px" @change="loadList(1)">
          <el-option v-for="(v, k) in ORDER_STATUS" :key="k" :label="v.text" :value="Number(k)" />
        </el-select>
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
        <el-table-column prop="userId" label="用户ID" width="80" align="center">
          <template #default="{ row }">#{{ row.userId }}</template>
        </el-table-column>
        <el-table-column label="收货人" width="100" align="center">
          <template #default="{ row }">{{ row.receiver || '-' }}</template>
        </el-table-column>
        <el-table-column label="收货电话" width="130" align="center">
          <template #default="{ row }">{{ maskPhone(row.phone) }}</template>
        </el-table-column>
        <el-table-column prop="address" label="收货地址" min-width="180" show-overflow-tooltip />
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
import { getAdminOrders } from '../../api/admin'
import { ORDER_STATUS, money, datetime, maskPhone } from '../../utils/constants'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ status: null, orderNo: '', pageNum: 1, pageSize: 10 })

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getAdminOrders({
      status: query.status === null || query.status === undefined ? undefined : query.status,
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
