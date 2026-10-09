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
        <el-button :loading="exporting" @click="exportCsv">
          <el-icon><Download /></el-icon>&nbsp;导出
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
import { ElMessage } from 'element-plus'
import { getAdminAppointments } from '../../api/admin'
import { APPOINTMENT_STATUS, money, datetime, maskPhone } from '../../utils/constants'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ status: null, keyword: '', pageNum: 1, pageSize: 10 })
const exporting = ref(false)

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

// ================= 导出（前端直出 CSV，不改后端） =================

const EXPORT_HEADERS = ['预约编号', '用户ID', '预约人', '联系电话', '农园 / 项目', '预约日期', '场次', '人数', '金额', '状态', '提交时间']

/** 行数据 → 导出列，口径与表格显示保持一致（电话沿用脱敏） */
function toExportRow(row) {
  return [
    row.appointmentNo || '',
    row.userId != null ? `#${row.userId}` : '',
    row.contactName || '-',
    maskPhone(row.contactPhone),
    [row.farmName, row.projectName].filter(Boolean).join(' · ') || '-',
    row.appointDate || '-',
    row.session || '-',
    `${row.peopleCount != null ? row.peopleCount : 0} 人`,
    money(row.amount),
    (APPOINTMENT_STATUS[row.status] || {}).text || '未知',
    datetime(row.createTime)
  ]
}

/** CSV 单元格转义：含逗号/引号/换行的字段包引号，引号翻倍 */
function csvCell(v) {
  const s = String(v == null ? '' : v)
  return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s
}

/** 按当前筛选条件把全部分页拉齐（100 条/页循环取，导出条数与 total 一致） */
async function fetchAllRows() {
  const base = {
    status: query.status === null || query.status === undefined ? undefined : query.status,
    keyword: query.keyword || undefined
  }
  const first = await getAdminAppointments({ ...base, pageNum: 1, pageSize: 100 })
  const rows = ((first && first.list) || []).slice()
  const cnt = (first && first.total) || 0
  const pages = Math.ceil(cnt / 100)
  for (let p = 2; p <= pages; p++) {
    const data = await getAdminAppointments({ ...base, pageNum: p, pageSize: 100 })
    const part = (data && data.list) || []
    if (!part.length) break
    rows.push(...part)
  }
  return rows
}

async function exportCsv() {
  if (exporting.value) return
  exporting.value = true
  try {
    const rows = await fetchAllRows()
    if (!rows.length) {
      ElMessage.warning('当前筛选条件下没有可导出的数据')
      return
    }
    // 前置 ﻿ BOM，保证 Excel 双击打开中文不乱码
    const csv = [EXPORT_HEADERS, ...rows.map(toExportRow)]
      .map((line) => line.map(csvCell).join(','))
      .join('\r\n')
    const blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    const now = new Date()
    const pad = (n) => String(n).padStart(2, '0')
    a.href = url
    a.download = `预约总览_${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}_${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    ElMessage.success(`已按当前筛选条件导出 ${rows.length} 条预约记录`)
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    exporting.value = false
  }
}

onMounted(() => {
  loadList()
})
</script>
