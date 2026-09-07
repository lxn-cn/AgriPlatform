<template>
  <div class="page">
    <!-- 统计卡片 -->
    <div class="stat-row">
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #36b37e, #57cf9a)">
          <el-icon><Goods /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">商品销量</div>
          <div class="stat-value">{{ stats.salesCount }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #f5a623, #f7c154)">
          <el-icon><Wallet /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">销售额（元）</div>
          <div class="stat-value">{{ stats.salesAmount }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #4a90e2, #6fb1f5)">
          <el-icon><Calendar /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">预约人次</div>
          <div class="stat-value">{{ stats.appointmentCount }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #9b59b6, #bd7ce8)">
          <el-icon><Grape /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">在售商品</div>
          <div class="stat-value">{{ stats.productCount }}</div>
        </div>
      </div>
    </div>

    <!-- 近7日趋势 -->
    <div class="page-card">
      <div class="page-title">近 7 日经营趋势</div>
      <div ref="trendRef" class="chart-box"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getMerchantStats } from '../../api/merchant'
import { num, pick } from '../../utils/constants'

const trendRef = ref(null)
let chart = null

const stats = reactive({
  salesCount: 0,
  salesAmount: '0.00',
  appointmentCount: 0,
  productCount: 0
})

// 兼容后端多种可能的字段命名
function normalize(raw) {
  raw = raw || {}
  stats.salesCount = num(pick(raw, ['salesCount', 'sales', 'salesVolume', 'totalSales'], 0))
  const amount = num(pick(raw, ['salesAmount', 'totalAmount', 'amount', 'gmv'], 0))
  stats.salesAmount = amount.toFixed(2)
  stats.appointmentCount = num(
    pick(raw, ['appointmentCount', 'appointments', 'appointmentPeople', 'totalAppointments'], 0)
  )
  stats.productCount = num(pick(raw, ['productCount', 'productTotal', 'onSaleCount'], 0))

  let days = []
  let sales = []
  let amounts = []
  let appts = []
  if (Array.isArray(raw.trend) && raw.trend.length && typeof raw.trend[0] === 'object') {
    raw.trend.forEach((it) => {
      days.push(String(pick(it, ['date', 'day', 'label'], '')).slice(5))
      sales.push(num(pick(it, ['salesCount', 'sales', 'count'], 0)))
      amounts.push(num(pick(it, ['salesAmount', 'amount'], 0)))
      appts.push(num(pick(it, ['appointmentCount', 'appointments'], 0)))
    })
  } else {
    days = (raw.days || raw.dates || []).map((d) => String(d).slice(5))
    sales = raw.salesSeries || raw.sales || []
    amounts = raw.amountSeries || raw.amount || raw.salesAmount || []
    appts = raw.appointmentSeries || raw.appointments || []
  }
  return { days, sales, amounts, appts }
}

function renderChart(data) {
  if (!trendRef.value) return
  if (!chart) chart = echarts.init(trendRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['销售额', '商品销量', '预约人次'] },
    grid: { left: 60, right: 60, top: 50, bottom: 30 },
    xAxis: { type: 'category', data: data.days, boundaryGap: false },
    yAxis: [
      {
        type: 'value',
        name: '金额(元)',
        axisLabel: { formatter: '{value}' }
      },
      { type: 'value', name: '数量' }
    ],
    series: [
      {
        name: '销售额',
        type: 'line',
        smooth: true,
        data: data.amounts,
        itemStyle: { color: '#f5a623' },
        areaStyle: { color: 'rgba(245,166,35,0.12)' }
      },
      {
        name: '商品销量',
        type: 'line',
        smooth: true,
        yAxisIndex: 1,
        data: data.sales,
        itemStyle: { color: '#2e9e6b' }
      },
      {
        name: '预约人次',
        type: 'line',
        smooth: true,
        yAxisIndex: 1,
        data: data.appts,
        itemStyle: { color: '#4a90e2' }
      }
    ]
  })
}

function resize() {
  if (chart) chart.resize()
}

onMounted(async () => {
  await nextTick()
  try {
    const raw = await getMerchantStats()
    const data = normalize(raw)
    renderChart(data)
  } catch (e) {
    renderChart({ days: [], sales: [], amounts: [], appts: [] })
  }
  window.addEventListener('resize', resize)
})

onUnmounted(() => {
  window.removeEventListener('resize', resize)
  if (chart) {
    chart.dispose()
    chart = null
  }
})
</script>
