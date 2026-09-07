<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">预约总览</div>

      <div class="toolbar">
        <el-select v-model="query.status" placeholder="全部状态" clearable style="width: 140px" @change="loadList(1)">
          <el-option v-for="(v, k) in APPOINTMENT_STATUS" :key="k" :label="v.text" :value="Number(k)" />
        </el-select>
        <el-input
          v-model="query.keyword"
          placeholder="预约编号 / 预约人"
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
        <el-table-column prop="appointmentNo" label="预约编号" min-width="170" show-overflow-tooltip />
        <el-table-column prop="userId" label="用户ID" width="80" align="center">
          <template #default="{ row }">#{{ row.userId }}</template>
        </el-table-column>
        <el-table-column label="预约人" width="100" align="center">
          <template #default="{ row }">{{ row.contactName || '-' }}</template>
        </el-table-column>
        <el-table-column label="联系电话" width="130" align="center">
          <template #default="{ row }">{{ maskPhone(row.contactPhone) }}</template>
        </el-table-column>
        <el-table-column label="农园 / 项目" min-width="170" show-overflow-tooltip>
          <template #default="{ row }">
            {{ [row.farmName, row.projectName].filter(Boolean).join(' · ') || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="预约日期 / 场次" width="150" align="center">
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
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="(APPOINTMENT_STATUS[row.status] || {}).type || 'info'">
              {{ (APPOINTMENT_STATUS[row.status] || {}).text || '未知' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="提交时间" width="160" show-overflow-tooltip>
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
import { getAdminAppointments } from '../../api/admin'
import { APPOINTMENT_STATUS, money, datetime, maskPhone } from '../../utils/constants'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ status: null, keyword: '', pageNum: 1, pageSize: 10 })

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getAdminAppointments({
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

onMounted(() => {
  loadList()
})
</script>
