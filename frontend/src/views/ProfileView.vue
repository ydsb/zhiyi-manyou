<script setup lang="ts">
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'

/**
 * 个人中心（FR-M1-05 / FR-M1-07 / FR-M7-08 / FR-M8-01）。
 */
const auth = useAuthStore()

const form = ref({
  nickname: auth.user?.displayName || '',
  college: auth.user?.college || '',
  major: auth.user?.major || '',
  grade: auth.user?.grade || '',
  intro: auth.user?.intro || ''
})

const creditPercent = computed(() => {
  const score = auth.user?.creditScore ?? 100
  // 信用值以 200 为满分展示
  return Math.min(100, Math.round((score / 200) * 100))
})

const authStatusMeta = computed(() => {
  switch (auth.user?.authStatus) {
    case 'VERIFIED':
      return { label: '已核验', type: 'success' as const }
    case 'PENDING':
      return { label: '核验中', type: 'warning' as const }
    case 'FAILED':
      return { label: '核验失败', type: 'danger' as const }
    default:
      return { label: '未核验', type: 'info' as const }
  }
})

function save() {
  ElMessage.info('资料保存接口待开发（PUT /api/profile）')
}

function exportReport() {
  ElMessage.info('报告导出接口待开发（GET /api/profile/report/export，FR-M7-06）')
}

function exportData() {
  ElMessage.info('数据导出接口待开发（FR-M1-07）')
}
</script>

<template>
  <div class="zy-page">
    <p class="zy-page-subtitle">资料维护、信用与勋章、以及学习档案的导出。</p>

    <el-row :gutter="14">
      <!-- 基本资料 -->
      <el-col :span="24" :md="14">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">基本资料</span>
            <el-tag size="small" :type="authStatusMeta.type" effect="plain">
              实名{{ authStatusMeta.label }}
            </el-tag>
          </div>

          <el-form label-width="76px" label-position="left">
            <el-form-item label="学号">
              <el-input :model-value="auth.user?.sno" disabled />
            </el-form-item>
            <el-form-item label="昵称">
              <el-input v-model="form.nickname" placeholder="对外展示名" />
            </el-form-item>
            <el-form-item label="学院">
              <el-input v-model="form.college" placeholder="如 计算机学院" />
            </el-form-item>
            <el-form-item label="专业">
              <el-input v-model="form.major" placeholder="如 计算机科学与技术" />
            </el-form-item>
            <el-form-item label="年级">
              <el-input v-model="form.grade" placeholder="如 2024级" />
            </el-form-item>
            <el-form-item label="简介">
              <el-input v-model="form.intro" type="textarea" :rows="3" placeholder="一句话介绍你的技能与在研方向" />
            </el-form-item>
          </el-form>

          <el-button type="primary" @click="save">保存资料</el-button>
        </div>
      </el-col>

      <!-- 信用与档案 -->
      <el-col :span="24" :md="10">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">信用与角色</span>
          </div>

          <div class="credit">
            <div class="credit__value">{{ auth.user?.creditScore ?? 100 }}</div>
            <div class="credit__side">
              <div class="credit__label">当前信用值</div>
              <el-progress :percentage="creditPercent" :stroke-width="8" :show-text="false" />
              <div class="credit__hint">等级 L{{ auth.user?.creditLevel ?? 1 }} · 由履约与互评累积</div>
            </div>
          </div>

          <div class="kv">
            <span class="kv__k">角色</span>
            <el-tag size="small" effect="plain">{{ auth.user?.role }}</el-tag>
          </div>
          <div class="kv">
            <span class="kv__k">认证方式</span>
            <el-tag size="small" effect="plain">{{ auth.user?.authType || '-' }}</el-tag>
          </div>
          <div class="kv">
            <span class="kv__k">最近登录</span>
            <span class="kv__v">{{ auth.user?.lastLoginAt || '-' }}</span>
          </div>
        </div>

        <div class="zy-card panel mt">
          <div class="panel__head">
            <span class="panel__title">学习档案</span>
          </div>
          <p class="panel__desc">
            导出含唯一验证码的《跨学科协作能力鉴定报告》，可作为综合素质测评或简历的补充附件。
          </p>
          <div class="panel__actions">
            <el-button type="primary" plain @click="exportReport">导出能力鉴定报告</el-button>
            <el-button text @click="exportData">导出我的数据</el-button>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.panel {
  padding: 16px 18px;
  height: 100%;
}

.panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.panel__title {
  font-size: 15px;
  font-weight: 600;
}

.panel__desc {
  margin: 0 0 14px;
  font-size: 12.5px;
  line-height: 1.7;
  color: var(--zy-text-secondary);
}

.panel__actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.mt {
  margin-top: 14px;
}

.credit {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 14px;
  border-radius: var(--zy-radius);
  background: linear-gradient(135deg, rgba(47, 125, 143, 0.08), rgba(224, 139, 60, 0.08));
  margin-bottom: 14px;
}

.credit__value {
  font-size: 34px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  line-height: 1;
}

.credit__side {
  flex: 1;
}

.credit__label {
  font-size: 12.5px;
  color: var(--zy-text-regular);
  margin-bottom: 5px;
}

.credit__hint {
  margin-top: 5px;
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.kv {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 7px 0;
  border-bottom: 1px dashed var(--zy-border-light);
}

.kv:last-child {
  border-bottom: none;
}

.kv__k {
  font-size: 12.5px;
  color: var(--zy-text-secondary);
}

.kv__v {
  font-size: 12.5px;
  color: var(--zy-text-regular);
}
</style>
