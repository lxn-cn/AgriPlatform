<template>
  <div class="login-bg">
    <el-card class="login-card" shadow="never">
      <div class="login-title">天津地方农特产推广服务平台</div>
      <div class="login-sub">管理端登录 · 商家工作台 / 平台管理</div>

      <el-form ref="formRef" :model="form" :rules="rules" size="large" @keyup.enter="onSubmit">
        <el-form-item prop="role">
          <el-radio-group v-model="form.role" class="role-group">
            <el-radio-button label="ADMIN">平台管理员</el-radio-button>
            <el-radio-button label="MERCHANT">商家</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="请输入账号" clearable>
            <template #prefix><el-icon><User /></el-icon></template>
          </el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="请输入密码"
            show-password
          >
            <template #prefix><el-icon><Lock /></el-icon></template>
          </el-input>
        </el-form-item>
        <el-form-item>
          <el-button
            type="primary"
            class="login-btn"
            :loading="loading"
            @click="onSubmit"
          >
            {{ loading ? '登录中...' : '登 录' }}
          </el-button>
        </el-form-item>
      </el-form>

      <div class="login-tip">
        演示账号：管理员 admin / 123456；商家 merchant01 / merchant123
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { login } from '../../api/auth'
import { useUserStore } from '../../stores/user'

const router = useRouter()
const route = useRoute()
const store = useUserStore()

const formRef = ref(null)
const loading = ref(false)
const form = reactive({
  username: '',
  password: '',
  role: 'ADMIN'
})

const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于 6 位', trigger: 'blur' }
  ]
}

function onSubmit() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      const data = await login({
        username: form.username.trim(),
        password: form.password,
        role: form.role
      })
      const token = data && data.token
      const userInfo = (data && data.userInfo) || {}
      if (!token) {
        ElMessage.error('登录返回数据异常')
        return
      }
      if (userInfo.role !== form.role) {
        userInfo.role = userInfo.role || form.role
      }
      store.setLogin(token, userInfo)
      ElMessage.success('登录成功，欢迎您：' + (userInfo.name || form.username))
      const redirect = route.query.redirect
      if (redirect && redirect !== '/login') {
        router.push(redirect)
      } else {
        router.push(form.role === 'MERCHANT' ? '/merchant/dashboard' : '/admin/dashboard')
      }
    } catch (e) {
      /* 错误已在拦截器提示 */
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped>
.role-group {
  width: 100%;
  display: flex;
}

.role-group :deep(.el-radio-button) {
  flex: 1;
}

.role-group :deep(.el-radio-button__inner) {
  width: 100%;
}

.login-btn {
  width: 100%;
  background: #2e9e6b;
  border-color: #2e9e6b;
}

.login-btn:hover,
.login-btn:focus {
  background: #35b37b;
  border-color: #35b37b;
}
</style>
