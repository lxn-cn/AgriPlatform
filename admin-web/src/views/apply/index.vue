<template>
  <div class="login-bg">
    <el-card class="login-card apply-card" shadow="never">
      <!-- 提交成功态 -->
      <div v-if="done" class="done-box">
        <el-icon class="done-icon"><CircleCheckFilled /></el-icon>
        <div class="done-title">入驻申请已提交</div>
        <div class="done-desc">
          请耐心等待平台审核（平台端「商家审核」中可见）。审核通过后，使用账号
          <b>{{ form.username }}</b> 登录商家工作台即可开始经营。
        </div>
        <el-button type="primary" class="done-btn" @click="backLogin">返回登录</el-button>
      </div>

      <!-- 申请表单态 -->
      <template v-else>
        <div class="login-title">商家入驻申请</div>
        <div class="login-sub">填写店铺与资质信息，提交后等待平台审核</div>

        <el-form ref="formRef" :model="form" :rules="rules" label-width="90px" size="large">
          <el-divider content-position="left">登录账号（审核通过后登录商家工作台）</el-divider>
          <el-form-item label="登录账号" prop="username">
            <el-input v-model="form.username" placeholder="至少 4 位，字母 / 数字 / 下划线" clearable maxlength="30" />
          </el-form-item>
          <el-form-item label="登录密码" prop="password">
            <el-input v-model="form.password" type="password" placeholder="至少 6 位" show-password />
          </el-form-item>
          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input v-model="form.confirmPassword" type="password" placeholder="再次输入密码" show-password />
          </el-form-item>

          <el-divider content-position="left">店铺信息</el-divider>
          <el-form-item label="店铺名称" prop="name">
            <el-input v-model="form.name" placeholder="如：蓟州山货优品店" clearable maxlength="50" />
          </el-form-item>
          <el-form-item label="联系人" prop="contact">
            <el-input v-model="form.contact" placeholder="选填" clearable maxlength="20" />
          </el-form-item>
          <el-form-item label="联系电话" prop="phone">
            <el-input v-model="form.phone" placeholder="用于平台联系与审核通知" clearable maxlength="11" />
          </el-form-item>
          <el-form-item label="所在区县" prop="district">
            <el-select v-model="form.district" placeholder="请选择天津市所在区县" style="width: 100%">
              <el-option v-for="d in districts" :key="d" :label="d" :value="d" />
            </el-select>
          </el-form-item>
          <el-form-item label="详细地址" prop="address">
            <el-input v-model="form.address" placeholder="街道 / 镇 / 村及门牌号" clearable maxlength="100" />
          </el-form-item>
          <el-form-item label="资质信息" prop="licenseInfo">
            <el-input
              v-model="form.licenseInfo"
              type="textarea"
              :rows="3"
              maxlength="200"
              show-word-limit
              placeholder="如：营业执照（统一社会信用代码 9112xxxx…）、食品经营许可证编号等"
            />
          </el-form-item>

          <el-form-item>
            <el-button type="primary" class="submit-btn" :loading="loading" @click="onSubmit">
              {{ loading ? '提交中...' : '提交入驻申请' }}
            </el-button>
          </el-form-item>
        </el-form>

        <div class="login-tip">
          已有商家账号？
          <el-link type="success" :underline="false" class="tip-link" @click="backLogin">直接登录</el-link>
        </div>
      </template>
    </el-card>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { applyMerchant } from '../../api/auth'

document.title = '商家入驻申请 - 天津农特产平台管理端'

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const done = ref(false)

// 天津市 16 个行政区
const districts = [
  '和平区', '河东区', '河西区', '南开区', '河北区', '红桥区', '滨海新区',
  '东丽区', '西青区', '津南区', '北辰区', '武清区', '宝坻区', '静海区', '宁河区', '蓟州区'
]

const form = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  name: '',
  contact: '',
  phone: '',
  district: '',
  address: '',
  licenseInfo: ''
})

const rules = {
  username: [
    { required: true, message: '请输入登录账号', trigger: 'blur' },
    { min: 4, message: '登录账号至少 4 位', trigger: 'blur' },
    { pattern: /^[A-Za-z0-9_]+$/, message: '仅支持字母、数字和下划线', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入登录密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于 6 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== form.password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  name: [{ required: true, message: '请输入店铺名称', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  district: [{ required: true, message: '请选择所在区县', trigger: 'change' }],
  address: [{ required: true, message: '请输入详细地址', trigger: 'blur' }],
  licenseInfo: [{ required: true, message: '请填写资质信息', trigger: 'blur' }]
}

function onSubmit() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await applyMerchant({
        username: form.username.trim(),
        password: form.password,
        name: form.name.trim(),
        contact: form.contact.trim(),
        phone: form.phone.trim(),
        licenseInfo: form.licenseInfo.trim(),
        // 后端无区县/地址独立字段，按约定拼入简介，平台审核弹窗「简介」处可见
        intro: '天津市' + form.district + ' · ' + form.address.trim()
      })
      done.value = true
    } catch (e) {
      /* 错误已由拦截器提示（如"该登录账号已被占用，请更换"） */
    } finally {
      loading.value = false
    }
  })
}

function backLogin() {
  router.push('/login')
}
</script>

<style scoped>
.apply-card {
  width: 560px;
  max-width: 94vw;
}

.apply-card :deep(.el-divider__text) {
  font-size: 13px;
  font-weight: 600;
  color: #1d7a4f;
}

.submit-btn {
  width: 100%;
  background: #2e9e6b;
  border-color: #2e9e6b;
}

.submit-btn:hover,
.submit-btn:focus {
  background: #35b37b;
  border-color: #35b37b;
}

.tip-link {
  font-size: 12px;
  color: #2e9e6b;
}

.done-box {
  padding: 30px 10px 20px;
  text-align: center;
}

.done-icon {
  font-size: 64px;
  color: #2e9e6b;
}

.done-title {
  font-size: 20px;
  font-weight: 700;
  color: #1f2d3d;
  margin: 14px 0 10px;
}

.done-desc {
  font-size: 13px;
  color: #909399;
  line-height: 1.8;
  margin-bottom: 22px;
}

.done-btn {
  min-width: 180px;
  background: #2e9e6b;
  border-color: #2e9e6b;
}
</style>
