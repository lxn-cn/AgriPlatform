<template>
  <div class="page">
    <div class="page-card">
      <div class="page-title">我的店铺</div>

      <el-descriptions v-if="profile" :column="2" border class="profile-desc">
        <el-descriptions-item label="店铺名称">{{ profile.name || '-' }}</el-descriptions-item>
        <el-descriptions-item label="账号">{{ profile.username || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系人">{{ profile.contact || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ profile.phone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审核状态">
          <el-tag :type="(MERCHANT_STATUS[profile.status] || {}).type || 'info'">
            {{ (MERCHANT_STATUS[profile.status] || {}).text || '未知' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="入驻时间">{{ datetime(profile.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="资质信息" :span="2">{{ profile.licenseInfo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="驳回原因" :span="2" v-if="profile.rejectReason">
          <span style="color: #f56c6c">{{ profile.rejectReason }}</span>
        </el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left">编辑店铺信息</el-divider>

      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px" style="max-width: 560px">
        <el-form-item label="店铺名称" prop="name">
          <el-input v-model="form.name" maxlength="64" placeholder="如：蓟州盘山果业合作社" />
        </el-form-item>
        <el-form-item label="联系人" prop="contact">
          <el-input v-model="form.contact" maxlength="32" placeholder="联系人姓名" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="form.phone" maxlength="20" placeholder="联系电话" />
        </el-form-item>
        <el-form-item label="资质信息" prop="licenseInfo">
          <el-input v-model="form.licenseInfo" maxlength="255" placeholder="营业执照、经营许可证等" />
        </el-form-item>
        <el-form-item label="店铺简介" prop="intro">
          <el-input
            v-model="form.intro"
            type="textarea"
            :rows="4"
            maxlength="500"
            show-word-limit
            placeholder="介绍店铺特色、主营产品等"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="saving" @click="onSave">保存修改</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getMerchantProfile, updateMerchantProfile } from '../../api/merchant'
import { MERCHANT_STATUS, datetime } from '../../utils/constants'
import { useUserStore } from '../../stores/user'

const store = useUserStore()
const formRef = ref(null)
const saving = ref(false)
const profile = ref(null)

const form = reactive({
  name: '',
  contact: '',
  phone: '',
  licenseInfo: '',
  intro: ''
})

const rules = {
  name: [{ required: true, message: '请输入店铺名称', trigger: 'blur' }],
  phone: [
    { pattern: /^1[3-9]\d{9}$|^0\d{2,3}-?\d{7,8}$/, message: '手机号或座机格式不正确', trigger: 'blur' }
  ]
}

onMounted(async () => {
  try {
    const data = await getMerchantProfile()
    profile.value = data || {}
    Object.keys(form).forEach((k) => {
      if (profile.value[k] !== undefined && profile.value[k] !== null) {
        form[k] = profile.value[k]
      }
    })
    // 同步最新昵称到顶栏
    if (data && data.name) {
      store.setUserInfo({ ...store.userInfo, name: data.name })
    }
  } catch (e) {
    /* 拦截器已提示 */
  }
})

async function onSave() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  saving.value = true
  try {
    await updateMerchantProfile({ ...form })
    ElMessage.success('店铺信息已保存')
    const fresh = await getMerchantProfile().catch(() => null)
    if (fresh) profile.value = fresh
  } catch (e) {
    /* 拦截器已提示 */
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.profile-desc {
  margin: 18px 0;
}
</style>
