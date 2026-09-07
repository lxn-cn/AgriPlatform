<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">农园管理</div>

      <div class="toolbar">
        <el-select v-model="query.type" placeholder="全部类型" clearable style="width: 160px" @change="loadFarms(1)">
          <el-option v-for="t in FARM_TYPES" :key="t" :label="t" :value="t" />
        </el-select>
        <el-input
          v-model="query.keyword"
          placeholder="农园名称关键词"
          clearable
          style="width: 220px"
          @keyup.enter="loadFarms(1)"
          @clear="loadFarms(1)"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-button type="primary" @click="loadFarms(1)">
          <el-icon><Search /></el-icon>&nbsp;查询
        </el-button>
        <div class="grow"></div>
        <el-button type="success" @click="openFarmDialog()">
          <el-icon><Plus /></el-icon>&nbsp;新增农园
        </el-button>
      </div>

      <el-table v-loading="loading" :data="farmList" stripe>
        <el-table-column label="封面" width="76" align="center">
          <template #default="{ row }">
            <img v-if="row.coverImage" class="thumb" :src="row.coverImage" alt="封面" />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="农园名称" min-width="160" show-overflow-tooltip />
        <el-table-column label="类型" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="row.type === '果园' ? 'success' : 'primary'" effect="plain">
              {{ row.type }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="district" label="所在区县" width="100" align="center" />
        <el-table-column prop="address" label="地址" min-width="180" show-overflow-tooltip />
        <el-table-column prop="businessHours" label="营业时间" width="120" align="center" />
        <el-table-column label="人均" width="90" align="right">
          <template #default="{ row }">{{ money(row.avgPrice) }}</template>
        </el-table-column>
        <el-table-column label="评分" width="80" align="center">
          <template #default="{ row }">{{ row.rating || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="(SHELF_STATUS[row.status] || {}).type || 'info'">
              {{ (SHELF_STATUS[row.status] || {}).text || '未知' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openFarmDialog(row)">编辑</el-button>
            <el-button link type="success" size="small" @click="openProjects(row)">采摘项目</el-button>
            <el-button
              v-if="row.status === 1"
              link
              type="warning"
              size="small"
              @click="toggleFarm(row, 0)"
            >下架</el-button>
            <el-button
              v-else
              link
              type="success"
              size="small"
              @click="toggleFarm(row, 1)"
            >上架</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="query.pageNum"
          v-model:page-size="query.pageSize"
          :total="farmTotal"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadFarms(1)"
          @current-change="loadFarms()"
        />
      </div>
    </div>

    <!-- 农园 新增/编辑 弹窗 -->
    <el-dialog
      v-model="farmDialogVisible"
      :title="editingFarmId ? '编辑农园' : '新增农园'"
      width="660px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form ref="farmFormRef" :model="farmForm" :rules="farmRules" label-width="100px">
        <el-form-item label="农园名称" prop="name">
          <el-input v-model="farmForm.name" maxlength="64" placeholder="如：盘山红富士采摘园" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="农园类型" prop="type">
              <el-select v-model="farmForm.type" style="width: 100%">
                <el-option v-for="t in FARM_TYPES" :key="t" :label="t" :value="t" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所在区县" prop="district">
              <el-select v-model="farmForm.district" filterable style="width: 100%">
                <el-option v-for="d in TIANJIN_DISTRICTS" :key="d" :label="d" :value="d" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="详细地址" prop="address">
          <el-input v-model="farmForm.address" maxlength="255" placeholder="文字地址，用户可一键复制" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="营业时间" prop="businessHours">
              <el-input v-model="farmForm.businessHours" placeholder="如：08:30-17:00" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="人均价格" prop="avgPrice">
              <el-input-number v-model="farmForm.avgPrice" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="交通指引" prop="trafficGuide">
          <el-input
            v-model="farmForm.trafficGuide"
            type="textarea"
            :rows="2"
            maxlength="500"
            placeholder="公交路线、自驾提示等"
          />
        </el-form-item>
        <el-form-item label="农园简介" prop="intro">
          <el-input
            v-model="farmForm.intro"
            type="textarea"
            :rows="4"
            maxlength="2000"
            placeholder="农园图文简介"
          />
        </el-form-item>
        <el-form-item label="封面图路径" prop="coverImage">
          <el-input v-model="farmForm.coverImage" placeholder="/api/file/placeholder/farm1.png（可留空）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="farmDialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="savingFarm" @click="onSaveFarm">保 存</el-button>
      </template>
    </el-dialog>

    <!-- 采摘项目 抽屉 -->
    <el-drawer v-model="projectsVisible" :title="'采摘项目管理 - ' + (currentFarm ? currentFarm.name : '')" size="880px">
      <div class="toolbar">
        <el-tag v-if="currentFarm" type="info" effect="plain">
          {{ currentFarm.type }} · {{ currentFarm.district }}
        </el-tag>
        <div class="grow"></div>
        <el-button type="success" @click="openProjectDialog()">
          <el-icon><Plus /></el-icon>&nbsp;新增采摘项目
        </el-button>
      </div>
      <el-table v-loading="projectLoading" :data="projectList" stripe>
        <el-table-column prop="name" label="品种名称" min-width="150" show-overflow-tooltip />
        <el-table-column label="当季时间" width="190" align="center">
          <template #default="{ row }">{{ (row.seasonStart || '-') + ' ~ ' + (row.seasonEnd || '-') }}</template>
        </el-table-column>
        <el-table-column prop="priceMode" label="计价方式" width="110" align="center" />
        <el-table-column label="价格" width="90" align="right">
          <template #default="{ row }">{{ money(row.price) }}</template>
        </el-table-column>
        <el-table-column prop="session" label="可约场次" width="110" align="center" />
        <el-table-column prop="stock" label="库存" width="80" align="center" />
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="(SHELF_STATUS[row.status] || {}).type || 'info'">
              {{ (SHELF_STATUS[row.status] || {}).text || '未知' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openProjectDialog(row)">编辑</el-button>
            <el-button link type="danger" size="small" @click="onDeleteProject(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-drawer>

    <!-- 采摘项目 新增/编辑 弹窗 -->
    <el-dialog
      v-model="projectDialogVisible"
      :title="editingProjectId ? '编辑采摘项目' : '新增采摘项目'"
      width="600px"
      :close-on-click-modal="false"
      destroy-on-close
      append-to-body
    >
      <el-form ref="projectFormRef" :model="projectForm" :rules="projectRules" label-width="100px">
        <el-form-item label="品种名称" prop="name">
          <el-input v-model="projectForm.name" maxlength="64" placeholder="如：红富士苹果采摘" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="当季开始" prop="seasonStart">
              <el-date-picker v-model="projectForm.seasonStart" type="date" value-format="YYYY-MM-DD" placeholder="开始日期" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="当季结束" prop="seasonEnd">
              <el-date-picker v-model="projectForm.seasonEnd" type="date" value-format="YYYY-MM-DD" placeholder="结束日期" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="计价方式" prop="priceMode">
              <el-select v-model="projectForm.priceMode" style="width: 100%">
                <el-option v-for="m in PRICE_MODES" :key="m" :label="m" :value="m" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="价格(元)" prop="price">
              <el-input-number v-model="projectForm.price" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="可约场次" prop="sessions">
          <el-checkbox-group v-model="projectForm.sessions">
            <el-checkbox v-for="s in SESSION_OPTIONS" :key="s" :label="s">{{ s }}</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="场次库存" prop="stock">
          <el-input-number v-model="projectForm.stock" :min="0" :step="5" style="width: 100%" />
          <div class="form-tip">每场次可预约总人数</div>
        </el-form-item>
        <el-form-item label="上架状态">
          <el-switch v-model="projectForm.status" :active-value="1" :inactive-value="0" active-text="上架" inactive-text="下架" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="projectDialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="savingProject" @click="onSaveProject">保 存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getMerchantFarms,
  createFarm,
  updateFarm,
  getPickingProjects,
  createPickingProject,
  updatePickingProject,
  deletePickingProject
} from '../../api/merchant'
import {
  FARM_TYPES,
  PRICE_MODES,
  SESSION_OPTIONS,
  TIANJIN_DISTRICTS,
  SHELF_STATUS,
  money
} from '../../utils/constants'

// ================= 农园列表 =================
const loading = ref(false)
const farmList = ref([])
const farmTotal = ref(0)
const query = reactive({ keyword: '', type: '', pageNum: 1, pageSize: 10 })

async function loadFarms(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getMerchantFarms({
      keyword: query.keyword || undefined,
      type: query.type || undefined,
      pageNum: query.pageNum,
      pageSize: query.pageSize
    })
    farmList.value = (data && data.list) || []
    farmTotal.value = (data && data.total) || 0
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    loading.value = false
  }
}

// ================= 农园表单 =================
const farmDialogVisible = ref(false)
const savingFarm = ref(false)
const editingFarmId = ref(null)
const farmFormRef = ref(null)

const farmForm = reactive({
  name: '',
  type: '果园',
  district: '',
  address: '',
  businessHours: '08:30-17:00',
  avgPrice: 0,
  trafficGuide: '',
  intro: '',
  coverImage: ''
})

const farmRules = {
  name: [{ required: true, message: '请输入农园名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择农园类型', trigger: 'change' }],
  district: [{ required: true, message: '请选择所在区县', trigger: 'change' }],
  address: [{ required: true, message: '请输入详细地址', trigger: 'blur' }],
  businessHours: [{ required: true, message: '请输入营业时间', trigger: 'blur' }]
}

function openFarmDialog(row) {
  editingFarmId.value = row ? row.id : null
  Object.assign(farmForm, {
    name: '',
    type: '果园',
    district: '',
    address: '',
    businessHours: '08:30-17:00',
    avgPrice: 0,
    trafficGuide: '',
    intro: '',
    coverImage: ''
  })
  if (row) {
    Object.assign(farmForm, {
      name: row.name || '',
      type: row.type || '果园',
      district: row.district || '',
      address: row.address || '',
      businessHours: row.businessHours || '08:30-17:00',
      avgPrice: Number(row.avgPrice) || 0,
      trafficGuide: row.trafficGuide || '',
      intro: row.intro || '',
      coverImage: row.coverImage || ''
    })
  }
  farmDialogVisible.value = true
}

function onSaveFarm() {
  farmFormRef.value.validate(async (valid) => {
    if (!valid) return
    savingFarm.value = true
    try {
      if (editingFarmId.value) {
        await updateFarm(editingFarmId.value, { ...farmForm })
        ElMessage.success('农园信息已更新')
      } else {
        await createFarm({ ...farmForm, status: 1 })
        ElMessage.success('农园已创建')
      }
      farmDialogVisible.value = false
      loadFarms()
    } catch (e) {
      /* 拦截器已提示 */
    } finally {
      savingFarm.value = false
    }
  })
}

async function toggleFarm(row, status) {
  const action = status === 1 ? '上架' : '下架'
  try {
    await ElMessageBox.confirm('确定要' + action + '农园「' + row.name + '」吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch (e) {
    return
  }
  try {
    await updateFarm(row.id, { status })
    ElMessage.success(action + '成功')
    loadFarms()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

// ================= 采摘项目 =================
const projectsVisible = ref(false)
const projectLoading = ref(false)
const projectList = ref([])
const currentFarm = ref(null)

const projectDialogVisible = ref(false)
const savingProject = ref(false)
const editingProjectId = ref(null)
const projectFormRef = ref(null)

const projectForm = reactive({
  name: '',
  seasonStart: '',
  seasonEnd: '',
  priceMode: '按人头门票',
  price: 0,
  sessions: ['上午', '下午'],
  stock: 50,
  status: 1
})

const projectRules = {
  name: [{ required: true, message: '请输入品种名称', trigger: 'blur' }],
  priceMode: [{ required: true, message: '请选择计价方式', trigger: 'change' }],
  sessions: [{ required: true, type: 'array', min: 1, message: '请至少选择一个场次', trigger: 'change' }],
  stock: [{ required: true, message: '请输入场次库存', trigger: 'blur' }]
}

async function openProjects(farm) {
  currentFarm.value = farm
  projectsVisible.value = true
  await loadProjects()
}

async function loadProjects() {
  if (!currentFarm.value) return
  projectLoading.value = true
  try {
    const data = await getPickingProjects({ farmId: currentFarm.value.id })
    if (Array.isArray(data)) {
      projectList.value = data
    } else {
      projectList.value = (data && data.list) || []
    }
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    projectLoading.value = false
  }
}

function openProjectDialog(row) {
  editingProjectId.value = row ? row.id : null
  Object.assign(projectForm, {
    name: '',
    seasonStart: '',
    seasonEnd: '',
    priceMode: '按人头门票',
    price: 0,
    sessions: ['上午', '下午'],
    stock: 50,
    status: 1
  })
  if (row) {
    Object.assign(projectForm, {
      name: row.name || '',
      seasonStart: row.seasonStart || '',
      seasonEnd: row.seasonEnd || '',
      priceMode: row.priceMode || '按人头门票',
      price: Number(row.price) || 0,
      sessions: (row.session || '上午,下午').split(',').filter((s) => s),
      stock: Number(row.stock) || 0,
      status: row.status != null ? row.status : 1
    })
  }
  projectDialogVisible.value = true
}

function onSaveProject() {
  projectFormRef.value.validate(async (valid) => {
    if (!valid) return
    savingProject.value = true
    const payload = {
      farmId: currentFarm.value.id,
      name: projectForm.name.trim(),
      seasonStart: projectForm.seasonStart || undefined,
      seasonEnd: projectForm.seasonEnd || undefined,
      priceMode: projectForm.priceMode,
      price: projectForm.price,
      session: projectForm.sessions.join(','),
      stock: projectForm.stock,
      status: projectForm.status
    }
    try {
      if (editingProjectId.value) {
        await updatePickingProject(editingProjectId.value, payload)
        ElMessage.success('采摘项目已更新')
      } else {
        await createPickingProject(payload)
        ElMessage.success('采摘项目已创建')
      }
      projectDialogVisible.value = false
      loadProjects()
    } catch (e) {
      /* 拦截器已提示 */
    } finally {
      savingProject.value = false
    }
  })
}

async function onDeleteProject(row) {
  try {
    await ElMessageBox.confirm(
      '确定删除采摘项目「' + row.name + '」吗？删除后用户将无法预约该项目。',
      '危险操作',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'error' }
    )
  } catch (e) {
    return
  }
  try {
    await deletePickingProject(row.id)
    ElMessage.success('删除成功')
    loadProjects()
  } catch (e) {
    /* 拦截器已提示 */
  }
}

onMounted(() => {
  loadFarms()
})
</script>

<style scoped>
.form-tip {
  font-size: 12px;
  color: #a8abb2;
  line-height: 1.6;
}
</style>
