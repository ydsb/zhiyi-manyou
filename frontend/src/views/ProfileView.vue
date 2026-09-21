<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { profileApi, exportReportAsPdf, downloadExportJson } from '@/api/profile'
import type { Badge, SkillProfile, SkillProfileEntry } from '@/api/types'

/**
 * 个人中心（FR-M1-05 / FR-M1-07 / FR-M7-04 / FR-M7-06 / FR-M7-08 / FR-M8-01）。
 */
const auth = useAuthStore()
const router = useRouter()

const form = ref({
  nickname: auth.user?.displayName || '',
  college: auth.user?.college || '',
  major: auth.user?.major || '',
  grade: auth.user?.grade || '',
  intro: auth.user?.intro || ''
})

/* ---------------- 信用与认证状态（FR-M8-01） ---------------- */

const creditPercent = computed(() => {
  const score = auth.user?.creditScore ?? 100
  // 信用值以 200 为满分展示（CreditLevel.RANGE_MAX = 200，不是 100）
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

/* ---------------- 技能画像（FR-M1-03 / FR-M2-02） ---------------- */

const skills = ref<SkillProfile | null>(null)
const loadingSkills = ref(false)

/**
 * 三类意图的展示元信息。
 *
 * 这里把"来源"也显示出来（互评 / 课程）：用户在导引页只填自评，
 * 若某技能旁边标着"互评"，说明它带来的分数来自协作成果，
 * 也让「取消勾选不会删掉互评分数」这一行为变得可预期。
 */
const INTENT_GROUPS = [
  { key: 'skilled' as const, label: '我擅长', type: 'success' as const },
  { key: 'researching' as const, label: '我正在研究', type: 'info' as const },
  { key: 'needed' as const, label: '我急需', type: 'danger' as const }
]

const sourceLabel = (s?: string) =>
  s === 'PEER' ? '互评' : s === 'COURSE' ? '课程' : '自评'

const sourceTagType = (s?: string) =>
  s === 'PEER' ? 'warning' as const : s === 'COURSE' ? 'success' as const : 'info' as const

function groupOf(key: 'skilled' | 'researching' | 'needed'): SkillProfileEntry[] {
  return skills.value?.[key] ?? []
}

/* ---------------- 勋章（FR-M7-04） ---------------- */

const badges = ref<Badge[]>([])
const loadingBadges = ref(false)

const unlockedCount = computed(() => badges.value.filter((b) => b.unlocked).length)

/* ---------------- 数据加载 ---------------- */

async function loadSkills() {
  loadingSkills.value = true
  try {
    skills.value = await profileApi.mySkills()
  } catch {
    // 提示由响应拦截器统一处理
  } finally {
    loadingSkills.value = false
  }
}

async function loadBadges() {
  loadingBadges.value = true
  try {
    badges.value = await profileApi.badges()
  } catch {
    // 勋章加载失败不阻塞页面
  } finally {
    loadingBadges.value = false
  }
}

onMounted(() => {
  loadSkills()
  loadBadges()
})

/* ---------------- 操作 ---------------- */

function editSkills() {
  router.push({ name: 'Onboarding' })
}

const saving = ref(false)

/**
 * 保存基本资料（FR-M1-05）。
 *
 * 提交前先做前端校验，是为了避免"点保存 → 服务端报错 → 用户不知道哪里填错"
 * 的往返。真正的约束仍由服务端 `@Size` 保证（前端校验永远只是体验优化）。
 */
async function save() {
  // 与服务端 @Size 上限对齐；前端先拦一道，省掉一次失败往返
  const limits: Array<[string, string, number]> = [
    ['nickname', '昵称', 64],
    ['college', '学院', 64],
    ['major', '专业', 64],
    ['grade', '年级', 16],
    ['intro', '简介', 500]
  ]
  for (const [key, label, max] of limits) {
    const v = (form.value as Record<string, string>)[key] ?? ''
    if (v.length > max) {
      ElMessage.warning(`${label}不能超过 ${max} 字，当前 ${v.length} 字`)
      return
    }
  }

  saving.value = true
  try {
    await profileApi.updateProfile({
      nickname: form.value.nickname,
      college: form.value.college,
      major: form.value.major,
      grade: form.value.grade,
      intro: form.value.intro
    })
    /*
     * 保存后必须重新拉取用户信息。
     * 顶栏的昵称、以及"对外展示名"都来自 auth store 里的 user，
     * 不刷新的话页面顶部还显示旧昵称，用户会以为没保存成功。
     */
    await auth.fetchUser()
    ElMessage.success('资料已保存')
  } catch {
    // 提示由响应拦截器统一处理
  } finally {
    saving.value = false
  }
}

/**
 * 导出能力鉴定报告。
 *
 * <p>原先这里是一句 `ElMessage.info('报告导出接口待开发')` —— 但后端
 * `GET /api/profile/report` 与前端 `exportReportAsPdf()` 早已实现，
 * 只是没人接上。提示"待开发"会让验收方以为功能缺失，属于误导性占位，
 * 因此改为真实调用。
 */
async function exportReport() {
  try {
    const report = await profileApi.report()
    exportReportAsPdf(report)
  } catch {
    // 数据不足时后端返回 PO​ROFILE_NOT_ENOUGH_DATA，由拦截器提示
  }
}

/**
 * 导出我的全部个人数据（FR-M1-07）。
 *
 * <p>原先这里是一句 `ElMessage.info('数据导出接口待开发（FR-M1-07）')` ——
 * 一个点得到的按钮却是死的。现在接真实接口，落成 JSON 文件供备份与迁移。
 */
const exporting = ref(false)

async function exportData() {
  exporting.value = true
  try {
    const data = await profileApi.exportData()
    const filename = downloadExportJson(data)
    const total = Object.values(data.counts ?? {}).reduce((s, n) => s + n, 0)
    ElMessage.success(`已导出 ${total} 条数据：${filename}`)
  } catch {
    // 提示由响应拦截器统一处理
  } finally {
    exporting.value = false
  }
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

          <el-button type="primary" :loading="saving" @click="save">保存资料</el-button>
          <span class="save-hint">可修改昵称、学院、专业、年级与简介；学号与姓名由学校核验，不可自行更改</span>
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
            <el-button text :loading="exporting" @click="exportData">导出我的数据</el-button>
          </div>
        </div>

        <div class="zy-card panel mt">
          <div class="panel__head">
            <span class="panel__title">数字勋章</span>
            <el-tag size="small" effect="plain">{{ unlockedCount }} / {{ badges.length }}</el-tag>
          </div>
          <div v-loading="loadingBadges" class="badges">
            <div
              v-for="b in badges"
              :key="b.code"
              class="badge"
              :class="{ 'badge--off': !b.unlocked }"
            >
              <div class="badge__top">
                <span class="badge__name">{{ b.name }}</span>
                <el-tag v-if="b.unlocked" size="small" type="success" effect="plain">已获得</el-tag>
                <span v-else class="badge__hint">{{ b.progressHint }}</span>
              </div>
              <div class="badge__desc">{{ b.description }}</div>
            </div>
            <el-empty v-if="!loadingBadges && badges.length === 0" description="暂无勋章定义" :image-size="60" />
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 技能画像 -->
    <div class="zy-card panel mt">
      <div class="panel__head">
        <span class="panel__title">我的技能画像</span>
        <div class="panel__actions">
          <el-tag size="small" effect="plain">共 {{ skills?.total ?? 0 }} 个标签</el-tag>
          <el-button size="small" type="primary" plain @click="editSkills">编辑画像</el-button>
        </div>
      </div>
      <p class="panel__desc">
        这是集市匹配度、供需排序与能力雷达图的数据来源。标签来源标注为
        <b>自评</b> 的可在此处增删；标注为 <b>互评</b> / <b>课程</b> 的来自协作成果，
        不会被编辑覆盖删除。
      </p>

      <div v-loading="loadingSkills" class="intents">
        <div v-for="g in INTENT_GROUPS" :key="g.key" class="intent">
          <div class="intent__head">
            <el-tag size="small" :type="g.type" effect="light">{{ g.label }}</el-tag>
            <span class="intent__count">{{ groupOf(g.key).length }} 个</span>
          </div>
          <div v-if="groupOf(g.key).length" class="intent__list">
            <div v-for="e in groupOf(g.key)" :key="e.skill.id" class="chip">
              <span class="chip__name">{{ e.skill.name }}</span>
              <el-tag size="small" :type="sourceTagType(e.source)" effect="plain">
                {{ sourceLabel(e.source) }}
              </el-tag>
              <span class="chip__lv">L{{ e.level ?? 1 }}</span>
            </div>
          </div>
          <p v-else class="intent__empty">尚未设置</p>
        </div>
      </div>

      <el-alert
        v-if="skills && skills.total === 0"
        type="warning"
        :closable="false"
        show-icon
        title="你还没有技能画像"
        description="没有画像时，集市匹配的「技能供需」因子恒为 0，排序与高匹配高亮都无法体现。建议先花一分钟完成导引。"
      />
      <div v-if="skills && skills.total === 0" class="empty-action">
        <el-button size="small" type="primary" @click="editSkills">去设置技能画像</el-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/*
 * 这里刻意**不**写 `height: 100%`。
 *
 * 曾经写过，结果把页面点坏了：`.panel` 自身有 `padding: 16px 18px`，
 * 而 `height: 100%` 在 `box-sizing: border-box` 下虽然会把 padding 算进高度，
 * 但当列内有多张卡片时，卡片被拉到列高后再叠加外边距，
 * 最后一张卡片溢出列底部约 14px，正好压住下方「我的技能画像」
 * 面板的标题行 —— 表现为**「编辑画像」按钮点不动**
 * （`elementFromPoint` 返回的是被遮挡的 panel__head，而不是按钮）。
 *
 * 这个缺陷很隐蔽：按钮可见、未禁用、hover 也有反馈，
 * 只是点击事件被上层元素吃掉，所以看起来像"功能没做"。
 * 个人中心不需要等高卡片，因此直接让卡片按内容自适应高度。
 */
.panel {
  padding: 16px 18px;
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

/* ---------------- 数字勋章 ---------------- */

.badges {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.badge {
  padding: 9px 11px;
  border: 1px solid var(--zy-border-light);
  border-radius: var(--zy-radius);
  background: #fbfdfe;
}

/* 未解锁的勋章降饱和度而不是隐藏：让用户知道"还差什么"才有引导作用 */
.badge--off {
  opacity: 0.62;
  background: #fafbfb;
}

.badge__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.badge__name {
  font-size: 13px;
  font-weight: 600;
}

.badge__hint {
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.badge__desc {
  margin-top: 3px;
  font-size: 11.5px;
  line-height: 1.6;
  color: var(--zy-text-secondary);
}

/* ---------------- 技能画像 ---------------- */

.intents {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 14px;
}

.intent {
  padding: 12px 13px;
  border: 1px solid var(--zy-border-light);
  border-radius: var(--zy-radius);
  background: #fbfdfe;
}

.intent__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 9px;
}

.intent__count {
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}

.intent__list {
  display: flex;
  flex-wrap: wrap;
  gap: 7px;
}

.chip {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 5px 9px;
  font-size: 12.5px;
  background: #fff;
  border: 1px solid var(--zy-border);
  border-radius: var(--zy-radius);
}

.chip__name {
  font-weight: 600;
}

.chip__lv {
  font-size: 11px;
  color: var(--zy-accent);
}

.intent__empty {
  margin: 0;
  font-size: 12px;
  color: var(--zy-text-placeholder);
}

.empty-action {
  margin-top: 12px;
}

.save-hint {
  margin-left: 10px;
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}
</style>
