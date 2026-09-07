<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">意见反馈</div>

      <div class="toolbar">
        <el-select v-model="query.status" placeholder="全部状态" clearable style="width: 140px" @change="loadList(1)">
          <el-option label="待处理" :value="0" />
          <el-option label="已处理" :value="1" />
        </el-select>
        <el-button type="primary" @click="loadList(1)">
          <el-icon><Search /></el-icon>&nbsp;查询
        </el-button>
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="userId" label="用户ID" width="90" align="center">
          <template #default="{ row }">#{{ row.userId }}</template>
        </el-table-column>
        <el-table-column prop="content" label="反馈内容" min-width="260" show-overflow-tooltip />
        <el-table-column prop="contact" label="联系方式" width="140" show-overflow-tooltip>
          <template #default="{ row }">{{ row.contact || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'warning'">
              {{ row.status === 1 ? '已处理' : '待处理' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reply" label="回复内容" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">{{ row.reply || '-' }}</template>
        </el-table-column>
        <el-table-column prop="createTime" label="反馈时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ datetime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="110" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openReply(row)">
              {{ row.status === 1 ? '查看/修改' : '回复' }}
            </el-button>
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

    <!-- 回复弹窗 -->
    <el-dialog v-model="replyVisible" title="反馈回复" width="560px" :close-on-click-modal="false">
      <el-descriptions v-if="replyRow" :column="2" border size="small" style="margin-bottom: 14px">
        <el-descriptions-item label="用户">#{{ replyRow.userId }}</el-descriptions-item>
        <el-descriptions-item label="反馈时间">{{ datetime(replyRow.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="联系方式">{{ replyRow.contact || '-' }}</el-descriptions-item>
        <el-descriptions-item label="处理状态">{{ replyRow.status === 1 ? '已处理' : '待处理' }}</el-descriptions-item>
        <el-descriptions-item label="反馈内容" :span="2">{{ replyRow.content }}</el-descriptions-item>
      </el-descriptions>
      <el-input
        v-model="replyText"
        type="textarea"
        :rows="4"
        maxlength="500"
        show-word-limit
        placeholder="请输入回复内容，提交后反馈将标记为已处理"
      />
      <template #footer>
        <el-button @click="replyVisible = false">取 消</el-button>
        <el-button type="primary" :loading="saving" @click="onReply">提交回复</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getFeedbacks, replyFeedback } from '../../api/admin'
import { datetime } from '../../utils/constants'

const loading = ref(false)
const saving = ref(false)
const list = ref([])
const total = ref(0)

const query = reactive({ status: null, pageNum: 1, pageSize: 10 })

const replyVisible = ref(false)
const replyRow = ref(null)
const replyText = ref('')

async function loadList(page) {
  if (page) query.pageNum = page
  loading.value = true
  try {
    const data = await getFeedbacks({
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

function openReply(row) {
  replyRow.value = row
  replyText.value = row.reply || ''
  replyVisible.value = true
}

async function onReply() {
  if (!replyText.value.trim()) {
    ElMessage.warning('请输入回复内容')
    return
  }
  saving.value = true
  try {
    await replyFeedback(replyRow.value.id, { reply: replyText.value.trim() })
    ElMessage.success('回复成功')
    replyVisible.value = false
    loadList()
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  loadList()
})
</script>
