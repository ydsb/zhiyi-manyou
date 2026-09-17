<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { demandApi, exchangeApi, metaApi } from '@/api/demand'
import type { DemandInterest, Exchange, ExchangeStatusMeta } from '@/api/types'

/**
 * 我的交换（FR-M4-04 状态机 / FR-M4-05 邀约响应 / FR-M4-06 以技易技 / FR-M4-09 配额）。
 *
 * 数据来源：
 *   GET  /api/exchanges                     我作为供给方或需求方的交换
 *   GET  /api/demands/interests/received    我收到的邀约（待我响应）
 *   GET  /api/demands/interests/sent        我发出的邀约
 *   POST /api/exchanges/interests/{id}/accept | reject | withdraw
 *   POST /api/exchanges/{id}/status?target=...
 *   GET  /api/meta/exchange-status          状态机字典（合法后继由后端给出）
 */
const router = useRouter()
const loading = ref(false)
const exchanges = ref<Exchange[]>([])
const received = ref<DemandInterest[]>([])
const sent = ref<DemandInterest[]>([])
const statusMeta = ref<ExchangeStatusMeta[]>([])
const filter = ref<'ALL' | 'ONGOING' | 'DONE'>('ALL')
const activeTab = ref<'exchanges' | 'received' | 'sent'>('exchanges')

const ONGOING = ['NEGOTIATING', 'IN_PROGRESS', 'PENDING_EVAL', 'DISPUTED']

const list = computed(() =>
  exchanges.value.filter((e) => {
    if (filter.value === 'ONGOING') return ONGOING.includes(e.status)
    if (filter.value === 'DONE') return ['COMPLETED', 'CANCELLED'].includes(e.status)
    return true
  })
)

const summary = computed(() => ({
  ongoing: exchanges.value.filter((e) => ['NEGOTIATING', 'IN_PROGRESS'].includes(e.status)).length,
  pendingEval: exchanges.value.filter((e) => e.status === 'PENDING_EVAL').length,
  completed: exchanges.value.filter((e) => e.status === 'COMPLETED').length,
  pendingInterest: received.value.filter((i) => i.status === 'PENDING').length
}))

function statusTag(s: string): 'info' | 'warning' | 'success' | 'danger' | 'primary' {
  const meta = statusMeta.value.find((m) => m.value === s)
  if (meta && meta.final) return s === 'COMPLETED' ? 'success' : 'info'
  if (s === 'DISPUTED') return 'danger'
  if (s === 'IN_PROGRESS') return 'primary'
  if (s === 'PENDING_EVAL' || s === 'NEGOTIATING') return 'warning'
  return 'info'
}

function actionLabel(target: string) {
  switch (target) {
    case 'IN_PROGRESS':
      return '开始协作'
    case 'PENDING_EVAL':
      return '提交完成，进入互评'
    case 'COMPLETED':
      return '确认完成'
    case 'CANCELLED':
      return '取消交换'
    case 'DISPUTED':
      return '发起争议'
    default:
      return target
  }
}

function roleLabel(role?: string) {
  return role === 'GIVER' ? '我是供给方' : role === 'TAKER' ? '我是需求方' : ''
}

function interestTag(s: string): 'success' | 'warning' | 'info' | 'danger' {
  if (s === 'PENDING') return 'warning'
  if (s === 'ACCEPTED') return 'success'
  if (s === 'REJECTED') return 'danger'
  return 'info'
}

async function loadAll() {
  loading.value = true
  try {
    const [ex, recv, snt] = await Promise.all([
      exchangeApi.myExchanges(),
      demandApi.receivedInterests(),
      demandApi.sentInterests()
    ])
    exchanges.value = ex
    received.value = recv
    sent.value = snt
  } catch {
    // 提示由响应拦截器统一处理
  } finally {
    loading.value = false
  }
}

async function loadMeta() {
  try {
    statusMeta.value = await metaApi.exchangeStatusMeta()
  } catch {
    // 字典失败不影响主流程
  }
}

async function respond(interest: DemandInterest, accept: boolean) {
  if (!accept) {
    let reason = ''
    try {
      const res = await ElMessageBox.prompt('可以说明拒绝原因（可选）', '拒绝邀约', {
        confirmButtonText: '拒绝',
        cancelButtonText: '取消',
        inputPlaceholder: '如：时间安排不合适'
      })
      reason = res.value || ''
    } catch {
      return
    }
    try {
      const r = await exchangeApi.reject(interest.id, reason || undefined)
      ElMessage.success(r.message)
      await loadAll()
    } catch {
      // 已提示
    }
    return
  }

  try {
    await ElMessageBox.confirm(
      '接受后将立即生成协作空间，同一卡片上的其他邀约会自动拒绝。确定接受吗？',
      '接受邀约',
      { confirmButtonText: '接受', cancelButtonText: '取消', type: 'success' }
    )
  } catch {
    return
  }
  try {
    const r = await exchangeApi.accept(interest.id)
    ElMessage.success(r.message)
    await loadAll()
  } catch {
    // 已提示
  }
}

async function withdraw(interest: DemandInterest) {
  try {
    await ElMessageBox.confirm('确定撤回这条邀约吗？', '撤回邀约', {
      confirmButtonText: '撤回',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch {
    return
  }
  try {
    await exchangeApi.withdraw(interest.id)
    ElMessage.success('已撤回')
    await loadAll()
  } catch {
    // 已提示
  }
}

async function transition(ex: Exchange, target: string) {
  const label = actionLabel(target)
  let actualHours: number | undefined
  try {
    if (target === 'PENDING_EVAL') {
      const res = await ElMessageBox.prompt('请填写实际投入时长（小时，可选）', label, {
        confirmButtonText: '提交',
        cancelButtonText: '取消',
        inputPlaceholder: '如 6.5',
        inputValidator: (v) => v === '' || (!Number.isNaN(Number(v)) && Number(v) > 0) || '请输入正数'
      })
      actualHours = res.value ? Number(res.value) : undefined
    } else {
      await ElMessageBox.confirm('确定执行「' + label + '」吗？', '状态变更', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: target === 'CANCELLED' ? 'warning' : 'info'
      })
    }
  } catch {
    return
  }

  try {
    const updated = await exchangeApi.changeStatus(ex.id, target, actualHours)
    ElMessage.success('已更新为「' + updated.statusLabel + '」')
    await loadAll()
  } catch {
    // 已提示
  }
}

onMounted(() => {
  loadMeta()
  loadAll()
})
</script>

<template>
  <div class="zy-page">
    <p class="zy-page-subtitle">
      以技易技的全过程记录：邀约、协作、状态流转与双向互评。状态机由后端校验，
      按钮上的可用操作直接来自接口返回的合法后继状态。
    </p>

    <el-row :gutter="12" class="summary">
      <el-col :span="6">
        <div class="zy-card sum">
          <span class="sum__label">进行中</span>
          <span class="sum__value">{{ summary.ongoing }}</span>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="zy-card sum">
          <span class="sum__label">待我响应邀约</span>
          <span class="sum__value sum__value--warn">{{ summary.pendingInterest }}</span>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="zy-card sum">
          <span class="sum__label">待互评</span>
          <span class="sum__value sum__value--warn">{{ summary.pendingEval }}</span>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="zy-card sum">
          <span class="sum__label">已完成</span>
          <span class="sum__value sum__value--ok">{{ summary.completed }}</span>
        </div>
      </el-col>
    </el-row>

    <div class="zy-card tabs">
      <el-radio-group v-model="activeTab" size="small">
        <el-radio-button value="exchanges">我的交换（{{ exchanges.length }}）</el-radio-button>
        <el-radio-button value="received">
          收到的邀约（{{ summary.pendingInterest }}）
        </el-radio-button>
        <el-radio-button value="sent">我发出的邀约（{{ sent.length }}）</el-radio-button>
      </el-radio-group>

      <template v-if="activeTab === 'exchanges'">
        <div class="tabs__spacer"></div>
        <el-radio-group v-model="filter" size="small">
          <el-radio-button value="ALL">全部</el-radio-button>
          <el-radio-button value="ONGOING">进行中</el-radio-button>
          <el-radio-button value="DONE">已结束</el-radio-button>
        </el-radio-group>
      </template>
    </div>

    <!-- ---------------- 我的交换 ---------------- -->
    <div v-if="activeTab === 'exchanges'" v-loading="loading" class="list">
      <div v-for="ex in list" :key="ex.id" class="zy-card row">
        <div class="row__main">
          <div class="row__head">
            <span class="row__no">{{ ex.recordNo }}</span>
            <el-tag size="small" :type="statusTag(ex.status)" effect="plain">{{ ex.statusLabel }}</el-tag>
            <el-tag v-if="ex.myRole && ex.myRole !== 'OBSERVER'" size="small" effect="plain">
              {{ roleLabel(ex.myRole) }}
            </el-tag>
            <span v-if="ex.matchScore != null" class="row__score">
              匹配度 {{ Math.round(ex.matchScore * 100) }}%
            </span>
            <span class="row__time">{{ ex.createdAt }}</span>
          </div>

          <h3 class="row__title">{{ ex.title }}</h3>

          <div class="exchange">
            <span class="chip chip--give">
              <b>{{ ex.giver?.name || ex.giver?.sno }}</b> 提供 · {{ ex.giver?.provideSkillName || '—' }}
            </span>
            <span class="exchange__arrow">⇄</span>
            <span class="chip chip--learn">
              <b>{{ ex.taker?.name || ex.taker?.sno }}</b> 提供 · {{ ex.taker?.provideSkillName || '—' }}
            </span>
          </div>

          <div class="row__meta">
            <span v-if="ex.expectedHours">预计 {{ ex.expectedHours }} 小时</span>
            <span v-if="ex.actualHours">实际 {{ ex.actualHours }} 小时</span>
            <span v-if="ex.startedAt">开始于 {{ ex.startedAt }}</span>
            <span v-if="ex.pendingEvalAt">进入互评 {{ ex.pendingEvalAt }}</span>
            <span v-if="ex.finishedAt">结束于 {{ ex.finishedAt }}</span>
          </div>
        </div>

        <div class="row__side">
          <div class="row__actions">
            <el-button
              v-if="['IN_PROGRESS', 'PENDING_EVAL', 'DISPUTED'].includes(ex.status)"
              size="small"
              type="success"
              plain
              @click="router.push({ name: 'Workspace', params: { recordId: ex.id } })"
            >协作工作台</el-button>
            <el-button
              v-for="t in ex.allowedNextStatus ?? []"
              :key="t"
              size="small"
              :type="t === 'CANCELLED' ? 'default' : t === 'DISPUTED' ? 'danger' : 'primary'"
              :plain="t === 'CANCELLED'"
              @click="transition(ex, t)"
            >
              {{ actionLabel(t) }}
            </el-button>
          </div>
          <div v-if="ex.status === 'PENDING_EVAL'" class="row__hint">
            互评提交后将生成不可篡改的存证记录（M6 上线）
          </div>
          <div v-else-if="ex.status === 'DISPUTED'" class="row__hint row__hint--warn">
            争议中：将由社区仲裁委员会基于全过程数据集体裁决（M8 上线）
          </div>
        </div>
      </div>

      <el-empty v-if="!loading && list.length === 0" description="还没有交换记录，去集市看看？" />
    </div>

    <!-- ---------------- 收到的邀约 ---------------- -->
    <div v-else-if="activeTab === 'received'" v-loading="loading" class="list">
      <div v-for="i in received" :key="i.id" class="zy-card row row--slim">
        <div class="row__main">
          <div class="row__head">
            <span class="row__no">{{ i.demandNo }}</span>
            <el-tag size="small" :type="interestTag(i.status)" effect="plain">{{ i.statusLabel }}</el-tag>
            <span class="row__time">{{ i.createdAt }}</span>
          </div>
          <h3 class="row__title">{{ i.demandTitle }}</h3>
          <div class="row__meta">
            <span>申请人：{{ i.applicantName || i.applicantSno }}</span>
            <span>{{ i.applicantCollege }}</span>
            <span v-if="i.matchScore != null">匹配度 {{ Math.round(i.matchScore * 100) }}%</span>
          </div>
          <div v-if="i.message" class="row__message">留言：{{ i.message }}</div>
        </div>
        <div v-if="i.status === 'PENDING'" class="row__side row__side--compact">
          <el-button size="small" type="primary" @click="respond(i, true)">接受</el-button>
          <el-button size="small" plain @click="respond(i, false)">拒绝</el-button>
        </div>
        <div v-else class="row__side row__side--compact">
          <span class="row__done">已处理</span>
        </div>
      </div>

      <el-empty v-if="!loading && received.length === 0" description="暂时没有收到邀约" />
    </div>

    <!-- ---------------- 发出的邀约 ---------------- -->
    <div v-else v-loading="loading" class="list">
      <div v-for="i in sent" :key="i.id" class="zy-card row row--slim">
        <div class="row__main">
          <div class="row__head">
            <span class="row__no">{{ i.demandNo }}</span>
            <el-tag size="small" :type="interestTag(i.status)" effect="plain">{{ i.statusLabel }}</el-tag>
            <span class="row__time">{{ i.createdAt }}</span>
          </div>
          <h3 class="row__title">{{ i.demandTitle }}</h3>
          <div class="row__meta">
            <span v-if="i.recordNo">交换编号 {{ i.recordNo }}</span>
            <span v-if="i.matchScore != null">申请时匹配度 {{ Math.round(i.matchScore * 100) }}%</span>
          </div>
          <div v-if="i.message" class="row__message">我的留言：{{ i.message }}</div>
        </div>
        <div v-if="i.status === 'PENDING'" class="row__side row__side--compact">
          <el-button size="small" plain @click="withdraw(i)">撤回</el-button>
        </div>
      </div>

      <el-empty v-if="!loading && sent.length === 0" description="还没有发出邀约" />
    </div>
  </div>
</template>

<style scoped>
.summary {
  margin-bottom: 14px;
}

.sum {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 18px;
}

.sum__label {
  font-size: 13px;
  color: var(--zy-text-secondary);
}

.sum__value {
  font-size: 24px;
  font-weight: 700;
  color: var(--zy-primary-dark);
}

.sum__value--warn {
  color: var(--zy-accent);
}

.sum__value--ok {
  color: var(--zy-dim-data);
}

.tabs {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}

.tabs__spacer {
  flex: 1;
}

.list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 80px;
}

.row {
  display: flex;
  gap: 20px;
  padding: 16px 18px;
  flex-wrap: wrap;
}

.row--slim {
  padding: 14px 18px;
}

.row__main {
  flex: 1;
  min-width: 320px;
}

.row__head {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.row__no {
  font-family: ui-monospace, Consolas, monospace;
  font-size: 12px;
  color: var(--zy-text-placeholder);
}

.row__score {
  font-size: 11.5px;
  color: var(--zy-primary-dark);
  font-weight: 600;
}

.row__time {
  margin-left: auto;
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}

.row__title {
  margin: 8px 0 10px;
  font-size: 15px;
  line-height: 1.5;
}

.exchange {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 10px;
}

.chip {
  padding: 4px 10px;
  font-size: 12px;
  border-radius: var(--zy-radius-sm);
}

.chip b {
  margin-right: 4px;
  font-weight: 600;
}

.chip--give {
  background: rgba(47, 125, 143, 0.1);
  color: var(--zy-primary-dark);
}

.chip--learn {
  background: rgba(224, 139, 60, 0.13);
  color: #a8661f;
}

.exchange__arrow {
  color: var(--zy-accent);
  font-weight: 700;
}

.row__meta {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  font-size: 11.5px;
  color: var(--zy-text-secondary);
}

.row__message {
  margin-top: 6px;
  font-size: 12px;
  color: var(--zy-text-regular);
}

.row__side {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 8px;
  min-width: 210px;
  padding-left: 20px;
  border-left: 1px dashed var(--zy-border);
}

.row__side--compact {
  min-width: 130px;
  align-items: flex-end;
}

.row__actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.row__hint {
  font-size: 11px;
  line-height: 1.6;
  color: var(--zy-text-placeholder);
  text-align: right;
}

.row__hint--warn {
  color: #c96a4f;
}

.row__done {
  font-size: 12px;
  color: var(--zy-text-placeholder);
}
</style>
