<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { ApiError } from '@/api/request'

/**
 * 登录页（FR-M1-01 / FR-M1-02）。
 *
 * 当前实现：本地账号密码登录。
 * 待办：对接学校 CAS / OAuth 2.0 统一身份认证（见需求 Q1）。
 */
const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const formRef = ref<FormInstance>()
const submitting = ref(false)
const showRegister = ref(false)

const form = reactive({
  sno: 'admin',
  password: '123456'
})

const registerForm = reactive({
  sno: '',
  sname: '',
  password: '',
  college: '',
  major: '',
  grade: ''
})

const rules: FormRules = {
  sno: [{ required: true, message: '请输入学号', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 64, message: '密码长度需为 6~64 位', trigger: 'blur' }
  ]
}

const registerRules: FormRules = {
  sno: [{ required: true, message: '请输入学号', trigger: 'blur' }],
  sname: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 64, message: '密码长度需为 6~64 位', trigger: 'blur' }
  ]
}

async function handleLogin() {
  if (!formRef.value) return
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    const result = await auth.login({ sno: form.sno.trim(), password: form.password })
    ElMessage.success(`欢迎回来，${result.user.displayName}`)
    // 首次登录由路由守卫带入新手导引
    const redirect = (route.query.redirect as string) || '/dashboard'
    router.push(result.firstLogin ? { name: 'Onboarding' } : redirect)
  } catch (e) {
    if (e instanceof ApiError) {
      // 错误提示已由响应拦截器统一处理
    }
  } finally {
    submitting.value = false
  }
}

async function handleRegister() {
  submitting.value = true
  try {
    const result = await auth.register({
      sno: registerForm.sno.trim(),
      sname: registerForm.sname.trim(),
      password: registerForm.password,
      college: registerForm.college || undefined,
      major: registerForm.major || undefined,
      grade: registerForm.grade || undefined
    })
    ElMessage.success('注册成功，请等待学号核验')
    showRegister.value = false
    router.push(result.firstLogin ? { name: 'Onboarding' } : '/dashboard')
  } catch {
    // 提示已统一处理
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="login">
    <!-- 左侧品牌区 -->
    <section class="login__brand">
      <div class="brand-inner">
        <div class="brand-logo" aria-hidden="true">
          <i v-for="n in 16" :key="n" class="zy-pixel-block"
             :style="{ background: n % 5 === 0 ? 'var(--zy-accent)' : 'rgba(255,255,255,0.85)' }"></i>
        </div>
        <h1 class="brand-title">知驿·漫游</h1>
        <p class="brand-desc">跨学科技能交换与学习记录平台</p>

        <ul class="brand-points">
          <li><b>以技易技</b> —— 去货币化的知识流转，我教你 X，你教我 Y</li>
          <li><b>语义撮合</b> —— 用知识图谱与 NLP 打通专业术语的"语义鸿沟"</li>
          <li><b>全过程留痕</b> —— 协作打卡、双向互评、哈希存证不可篡改</li>
          <li><b>能力可视化</b> —— 多维雷达图与像素风数字勋章沉淀成长轨迹</li>
        </ul>

        <div class="brand-foot">西北大学 · 大学生创新训练计划项目</div>
      </div>
    </section>

    <!-- 右侧表单区 -->
    <section class="login__form">
      <div class="form-card">
        <template v-if="!showRegister">
          <h2 class="form-title">登录</h2>
          <p class="form-sub">使用学号登录，或等待学校统一身份认证接入</p>

          <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @submit.prevent>
            <el-form-item label="学号" prop="sno">
              <el-input v-model="form.sno" size="large" placeholder="请输入学号" clearable />
            </el-form-item>
            <el-form-item label="密码" prop="password">
              <el-input
                v-model="form.password"
                size="large"
                type="password"
                placeholder="请输入密码"
                show-password
                @keyup.enter="handleLogin"
              />
            </el-form-item>
          </el-form>

          <el-button
            type="primary"
            size="large"
            class="submit"
            :loading="submitting"
            @click="handleLogin"
          >
            登录
          </el-button>

          <div class="form-foot">
            <span>还没有账号？</span>
            <el-link type="primary" underline="never" @click="showRegister = true">注册（学号核验）</el-link>
          </div>

          <el-alert
            class="demo-tip"
            type="info"
            :closable="false"
            show-icon
            title="测试账号"
            description="admin / 2024117420 / 2024117421 / 2024117422，密码均为 123456"
          />
        </template>

        <template v-else>
          <h2 class="form-title">注册</h2>
          <p class="form-sub">注册后需通过学号人工核验，核验前仅具备游客权限</p>

          <el-form :model="registerForm" :rules="registerRules" label-position="top" @submit.prevent>
            <el-form-item label="学号" prop="sno">
              <el-input v-model="registerForm.sno" placeholder="请输入学号" />
            </el-form-item>
            <el-form-item label="姓名" prop="sname">
              <el-input v-model="registerForm.sname" placeholder="请输入姓名" />
            </el-form-item>
            <el-form-item label="密码" prop="password">
              <el-input v-model="registerForm.password" type="password" show-password placeholder="6~64 位" />
            </el-form-item>
            <el-row :gutter="10">
              <el-col :span="12">
                <el-form-item label="学院">
                  <el-input v-model="registerForm.college" placeholder="如 计算机学院" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="专业">
                  <el-input v-model="registerForm.major" placeholder="如 计算机科学与技术" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>

          <el-button type="primary" size="large" class="submit" :loading="submitting" @click="handleRegister">
            注册
          </el-button>
          <div class="form-foot">
            <el-link type="primary" underline="never" @click="showRegister = false">返回登录</el-link>
          </div>
        </template>
      </div>
    </section>
  </div>
</template>

<style scoped>
.login {
  display: flex;
  min-height: 100vh;
}

/* ------------------------------ 品牌区 ------------------------------ */
.login__brand {
  flex: 1.1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px;
  background:
    radial-gradient(1200px 600px at 15% 10%, rgba(224, 139, 60, 0.22), transparent 60%),
    linear-gradient(150deg, #235f6e 0%, #2f7d8f 55%, #3f94a5 100%);
  color: #fff;
}

.brand-inner {
  max-width: 480px;
}

.brand-logo {
  display: grid;
  grid-template-columns: repeat(4, 14px);
  gap: 4px;
  margin-bottom: 26px;
}

.brand-logo .zy-pixel-block {
  width: 14px;
  height: 14px;
  box-shadow: 3px 3px 0 rgba(0, 0, 0, 0.18);
}

.brand-title {
  margin: 0 0 6px;
  font-size: 34px;
  letter-spacing: 0.06em;
}

.brand-desc {
  margin: 0 0 30px;
  font-size: 15px;
  color: rgba(255, 255, 255, 0.82);
}

.brand-points {
  margin: 0;
  padding: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.brand-points li {
  position: relative;
  padding-left: 18px;
  font-size: 13.5px;
  line-height: 1.65;
  color: rgba(255, 255, 255, 0.9);
}

.brand-points li::before {
  content: '';
  position: absolute;
  left: 0;
  top: 8px;
  width: 8px;
  height: 8px;
  background: var(--zy-accent);
  box-shadow: 2px 2px 0 rgba(0, 0, 0, 0.2);
}

.brand-points b {
  color: #fff;
}

.brand-foot {
  margin-top: 34px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
}

/* ------------------------------ 表单区 ------------------------------ */
.login__form {
  flex: 0 0 460px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
  background: var(--zy-bg-page);
}

.form-card {
  width: 100%;
  max-width: 360px;
}

.form-title {
  margin: 0 0 4px;
  font-size: 24px;
}

.form-sub {
  margin: 0 0 22px;
  font-size: 12.5px;
  color: var(--zy-text-secondary);
}

.submit {
  width: 100%;
  margin-top: 4px;
}

.form-foot {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  margin-top: 16px;
  font-size: 12.5px;
  color: var(--zy-text-secondary);
}

.demo-tip {
  margin-top: 22px;
}

@media (max-width: 860px) {
  .login__brand {
    display: none;
  }
  .login__form {
    flex: 1;
  }
}
</style>
