<template>
  <div class="page">
    <!-- 统计卡片 -->
    <div class="stat-row">
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #e6a23c, #f0c060)">
          <el-icon><Coin /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">总交易额（元）</div>
          <div class="stat-value">{{ overview.totalAmount }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #2e9e6b, #57cf9a)">
          <el-icon><Tickets /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">总订单量</div>
          <div class="stat-value">{{ overview.totalOrders }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #4a90e2, #6fb1f5)">
          <el-icon><AlarmClock /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">总预约量</div>
          <div class="stat-value">{{ overview.totalAppointments }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #9b59b6, #bd7ce8)">
          <el-icon><User /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-label">平台用户数</div>
          <div class="stat-value">{{ overview.totalUsers }}</div>
        </div>
      </div>
    </div>

    <el-row :gutter="16">
      <!-- 近7日趋势 -->
      <el-col :span="14">
        <div class="page-card" style="height: 100%">
          <div class="page-title">近 7 日订单量与预约量趋势</div>
          <div ref="trendRef" class="chart-box"></div>
        </div>
      </el-col>
      <!-- 分类销售额占比 -->
      <el-col :span="10">
        <div class="page-card" style="height: 100%">
          <div class="page-title">分类销售额占比</div>
          <div ref="pieRef" class="chart-box"></div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted, onUnmounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getOverviewStats } from '../../api/admin'
import { num, pick } from '../../utils/constants'

const trendRef = ref(null)
const pieRef = ref(null)
let trendChart = null
let pieChart = null

const overview = reactive({
  totalAmount: '0.00',
  totalOrders: 0,
  totalAppointments: 0,
  totalUsers: 0
})

function normalize(raw) {
  raw = raw || {}
  overview.totalAmount = num(pick(raw, ['totalAmount', 'totalSalesAmount', 'gmv', 'amount'], 0)).toFixed(2)
  overview.totalOrders = num(pick(raw, ['totalOrders', 'totalOrderCount', 'orderCount', 'orders'], 0))
  overview.totalAppointments = num(
    pick(raw, ['totalAppointments', 'totalAppointmentCount', 'appointmentCount', 'appointments'], 0)
  )
  overview.totalUsers = num(pick(raw, ['totalUsers', 'userCount', 'users'], 0))

  // ---- 近7日趋势 ----
  let days = []
  let orderSeries = []
  let apptSeries = []
  if (Array.isArray(raw.trend) && raw.trend.length && typeof raw.trend[0] === 'object') {
    raw.trend.forEach((it) => {
      days.push(String(pick(it, ['date', 'day', 'label'], '')).slice(5))
      orderSeries.push(num(pick(it, ['orderCount', 'orders'], 0)))
      apptSeries.push(num(pick(it, ['appointmentCount', 'appointments'], 0)))
    })
  } else if (Array.isArray(raw.orderTrend) && raw.orderTrend.length && typeof raw.orderTrend[0] === 'object') {
    raw.orderTrend.forEach((it, i) => {
      days.push(String(pick(it, ['date', 'day', 'label'], i + 1)).slice(5))
      orderSeries.push(num(pick(it, ['count', 'orderCount'], 0)))
    })
    ;(raw.appointmentTrend || []).forEach((it) => {
      apptSeries.push(num(pick(it, ['count', 'appointmentCount'], 0)))
    })
  } else {
    days = (raw.days || raw.dates || []).map((d) => String(d).slice(5))
    orderSeries = raw.orderSeries || raw.orders || []
    apptSeries = raw.appointmentSeries || raw.appointments || []
  }

  // ---- 分类销售额占比 ----
  let pieData = []
  const cs = raw.categoryShare || raw.categorySalesRatio || raw.categorySales || raw.categories
  if (Array.isArray(cs)) {
    cs.forEach((it) => {
      const name = pick(it, ['name', 'categoryName', 'label'], '未知')
      const value = num(pick(it, ['value', 'amount', 'salesAmount'], 0))
      if (value > 0) pieData.push({ name, value })
    })
  } else if (cs && typeof cs === 'object') {
    Object.keys(cs).forEach((k) => {
      const v = num(cs[k])
      if (v > 0) pieData.push({ name: k, value: v })
    })
  }
  return { days, orderSeries, apptSeries, pieData }
}

const PIE_COLORS = ['#2e9e6b', '#4a90e2', '#e6a23c', '#9b59b6', '#f56c6c', '#00b8d9', '#ff7f50', '#8e44ad']

function renderTrend(data) {
  if (!trendRef.value) return
  if (!trendChart) trendChart = echarts.init(trendRef.value)
  trendChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['订单量', '预约量'] },
    grid: { left: 50, right: 30, top: 50, bottom: 30 },
    xAxis: { type: 'category', data: data.days, boundaryGap: false },
    yAxis: { type: 'value', minInterval: 1 },
    series: [
      {
        name: '订单量',
        type: 'line',
        smooth: true,
        data: data.orderSeries,
        itemStyle: { color: '#2e9e6b' },
        areaStyle: { color: 'rgba(46,158,107,0.12)' }
      },
      {
        name: '预约量',
        type: 'line',
        smooth: true,
        data: data.apptSeries,
        itemStyle: { color: '#4a90e2' },
        areaStyle: { color: 'rgba(74,144,226,0.10)' }
      }
    ]
  })
}

function renderPie(pieData) {
  if (!pieRef.value) return
  if (!pieChart) pieChart = echarts.init(pieRef.value)
  pieChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}<br/>{c} 元（{d}%）' },
    legend: { orient: 'vertical', right: 10, top: 'center', type: 'scroll' },
    color: PIE_COLORS,
    series: [
      {
        name: '分类销售额',
        type: 'pie',
        radius: ['40%', '68%'],
        center: ['38%', '52%'],
        avoidLabelOverlap: true,
        itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
        label: { show: false },
        data: pieData.length
          ? pieData
          : [{ name: '暂无数据', value: 0 }]
      }
    ]
  })
}

function resize() {
  if (trendChart) trendChart.resize()
  if (pieChart) pieChart.resize()
}

onMounted(async () => {
  await nextTick()
  try {
    const raw = await getOverviewStats()
    const data = normalize(raw)
    renderTrend(data)
    renderPie(data.pieData)
  } catch (e) {
    renderTrend({ days: [], orderSeries: [], apptSeries: [] })
    renderPie([])
  }
  window.addEventListener('resize', resize)
})

onUnmounted(() => {
  window.removeEventListener('resize', resize)
  if (trendChart) {
    trendChart.dispose()
    trendChart = null
  }
  if (pieChart) {
    pieChart.dispose()
    pieChart = null
  }
})
</script>
