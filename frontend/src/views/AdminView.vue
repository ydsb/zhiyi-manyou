<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  adminApi,
  callTool,
  exportSkills,
  listTools,
  type AdminEvaluationReviewRow,
  type AdminReportRow,
  type AdminUserRow,
  type DashboardOverview
} from '@/api/admin'

/**
 * 管理后台（模块 M9）。
 *
 * 对应需求：
 *   FR-M9-01  用户管理：查询 / 禁用 / 角色分配 / 实名核验状态
 *   FR-M9-02  技能标签批量导入与批次回溯
 *   FR-M9-03  内容审核队列（待审卡片 + 举报处理）
 *   FR-M9-04  运营数据看板
 *   FR-M9-05  行为日志（表已建，采集由消息队列在 S4 阶段接入）
 *   FR-M9-07/08 开放能力接口（tools/list + tools/call）
 *
 * 设计取向：把"需要管理员处理的事"集中成一个待办数字，
 * 避免管理员在多个页面间来回找；所有写操作强制填说明并留痕。
 */
const activeTab = ref<'dashboard' | 'users' | 'review' | 'skills' | 'tools'>('dashboard')
const loading = ref(false)
const todo = ref({ pendingDemands: 0, pendingReports: 0, pendingEvaluations: 0 })

/* ---------------- 看板 ---------------- */
const overview = ref<DashboardOverview | null>(null)
const trend = ref<{ dates: string[]; activeUsers: number[]; exchangeFinished: number[]; snapshotCount: number; note: string } | null>(null)

/* ---------------- 用户 ---------------- */
const users = ref<AdminUserRow[]>([])
const userTotal = ref(0)
const userQuery = reactive({ keyword: '', college: '', status: undefined as number | undefined, page: 1, size: 10 })

/* ---------------- 审核 ---------------- */
const pendingDemands = ref<Array<Record<string, unknown>>>([])
const reports = ref<AdminReportRow[]>([])
const reportTotal = ref(0)
const reportStatus = ref('PENDING')

/**
 * 待复核互评（FR-M9-03）。
 *
 * 这批记录来自 M6 的互刷检测：评价提交时若命中风险特征
 * （如"进入待互评后仅 1 分钟即提交评价"），会被标为 PENDING 并写入风险说明，
 * 同时计入顶部"待办"数字。此前没有任何界面消费它，待办数字永远降不下来。
 */
const evaluations = ref<AdminEvaluationReviewRow[]>([])
const evalReviewStatus = ref<'PENDING' | 'PASSED' | 'REJECTED'>('PENDING')

/* ---------------- 技能导入 ---------------- */
const importText = ref('')
const importResult = ref<{
  batchNo: string
  total: number
  created: number
  updated: number
  failed: number
  errors: Array<{ line: number; content: string; reason: string }>
} | null>(null)
const batches = ref<Array<Record<string, unknown>>>([])

/* ---------------- 工具 ---------------- */
const tools = ref<Array<{ name: string; description: string; inputSchema: Record<string, unknown> }>>([])
const toolProtocol = ref('')
const toolArgs = reactive<Record<string, string>>({})
const toolResult = ref<Record<string, unknown> | null>(null)
const callingTool = ref('')

const totalTodo = computed(() =>
  todo.value.pendingDemands + todo.value.pendingReports + todo.value.pendingEvaluations
)

async function loadTodo() {
  try {
    todo.value = await adminApi.todo()
  } catch {
    // 非管理员会失败，拦截器已提示
  }
}

async function loadDashboard() {
  loading.value = true
  try {
    const [o, t] = await Promise.all([adminApi.overview(), adminApi.trend(14)])
    overview.value = o
    trend.value = t
  } catch {
    // 已提示
  } finally {
    loading.value = false
  }
}

async function makeSnapshot() {
  try {
    const r = await adminApi.makeSnapshot()
    ElMessage.success(`已生成 ${r.statDate} 的快照`)
    await loadDashboard()
  } catch {
    // 已提示
  }
}

async function loadUsers() {
  loading.value = true
  try {
    const r = await adminApi.users({
      keyword: userQuery.keyword || undefined,
      college: userQuery.college || undefined,
      status: userQuery.status,
      page: userQuery.page,
      size: userQuery.size
    })
    users.value = r.records
    userTotal.value = r.total
  } catch {
    // 已提示
  } finally {
    loading.value = false
  }
}

/** 所有管理写操作统一走这里：强制要求填写说明（服务端也会校验） */
async function withRemark(title: string, tip: string): Promise<string | null> {
  try {
    const res = await ElMessageBox.prompt(tip, title, {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      inputPlaceholder: '例如：涉嫌发布广告内容 / 已核实为误报',
      inputValidator: (v: string) => (v && v.trim().length >= 2 ? true : '说明不能少于 2 个字')
    })
    return (res.value || '').trim()
  } catch {
    return null
  }
}

async function toggleUser(row: AdminUserRow) {
  const enable = row.status !== 1
  const remark = await withRemark(
    enable ? `启用账号 ${row.name}` : `禁用账号 ${row.name}`,
    enable
      ? '启用后该账号恢复使用，并发上限按信用等级重算。请填写操作说明（会写入治理审计并公示）。'
      : '禁用后该账号无法协作，并发上限置 0。请填写操作说明（会写入治理审计并公示）。'
  )
  if (!remark) return
  try {
    await adminApi.setUserStatus(row.sno, enable, remark)
    ElMessage.success(enable ? '账号已启用' : '账号已禁用')
    await loadUsers()
  } catch {
    // 已提示
  }
}

async function changeRole(row: AdminUserRow) {
  try {
    const res = await ElMessageBox.prompt(
      `当前角色：${row.role}。可填 USER / ARBITRATOR / ADMIN，并附操作说明。`,
      `分配角色 · ${row.name}`,
      {
        confirmButtonText: '下一步',
        cancelButtonText: '取消',
        inputValue: row.role,
        inputValidator: (v: string) =>
          ['USER', 'ARBITRATOR', 'ADMIN'].includes((v || '').trim().toUpperCase()) ||
          '角色只能是 USER / ARBITRATOR / ADMIN'
      }
    )
    const role = (res.value || '').trim().toUpperCase()
    const remark = await withRemark('填写操作说明', '角色变更会影响权限，请说明依据（会写入治理审计）。')
    if (!remark) return
    await adminApi.assignRole(row.sno, role, remark)
    ElMessage.success('角色已更新')
    await loadUsers()
  } catch {
    // 取消或已提示
  }
}

async function changeAuthStatus(row: AdminUserRow) {
  try {
    const res = await ElMessageBox.prompt(
      `当前核验状态：${row.authStatus}。可填 UNVERIFIED / PENDING / VERIFIED / FAILED。`,
      `实名核验 · ${row.name}`,
      {
        confirmButtonText: '下一步',
        cancelButtonText: '取消',
        inputValue: row.authStatus ?? '',
        inputValidator: (v: string) =>
          ['UNVERIFIED', 'PENDING', 'VERIFIED', 'FAILED'].includes((v || '').trim().toUpperCase()) ||
          '状态只能是 UNVERIFIED / PENDING / VERIFIED / FAILED'
      }
    )
    const status = (res.value || '').trim().toUpperCase()
    const remark = await withRemark('填写操作说明', '核验状态涉及个人身份信息，会留痕但不公示。请说明依据。')
    if (!remark) return
    await adminApi.setAuthStatus(row.sno, status, remark)
    ElMessage.success('核验状态已更新')
    await loadUsers()
  } catch {
    // 取消或已提示
  }
}

async function recalcCredit(row: AdminUserRow) {
  const remark = await withRemark(`重算信用值 · ${row.name}`, '按多因子模型重新计算，请说明触发原因。')
  if (!remark) return
  try {
    const r = await adminApi.recalculateCredit(row.sno, remark)
    ElMessage.success(`信用值 ${r.before} → ${r.after}（${r.levelLabel}）`)
    await loadUsers()
  } catch {
    // 已提示
  }
}

async function loadReview() {
  loading.value = true
  try {
    const [d, r, e] = await Promise.all([
      adminApi.pendingDemands(1, 20),
      adminApi.reports(reportStatus.value || undefined, 1, 20),
      adminApi.pendingEvaluations(evalReviewStatus.value, 1, 50)
    ])
    pendingDemands.value = d.records
    reports.value = r.records
    reportTotal.value = r.total
    evaluations.value = e.records
  } catch {
    // 已提示
  } finally {
    loading.value = false
  }
}

/** 只刷新待复核互评（切换状态筛选用，避免连带重载其余列表） */
async function loadEvaluations() {
  try {
    const e = await adminApi.pendingEvaluations(evalReviewStatus.value, 1, 50)
    evaluations.value = e.records
  } catch {
    // 已提示
  }
}

/**
 * 复核一条互评（FR-M9-03）。
 *
 * 结论必须附说明：被处置方有权知道依据，与"管理操作必须填写说明"同一口径
 * （后端也会强制校验 audit 说明非空）。
 */
async function reviewEvaluation(row: AdminEvaluationReviewRow, decision: 'PASSED' | 'REJECTED') {
  const remark = await withRemark(
    decision === 'PASSED' ? '通过该互评' : '驳回该互评',
    decision === 'PASSED'
      ? '通过后该评价正常计入能力画像与信用。请说明采信依据。'
      : '驳回表示不采信该评价。请说明判定依据（如确认存在互刷、无真实协作过程）。'
  )
  if (!remark) return
  try {
    await adminApi.reviewEvaluation(row.id, decision, remark)
    ElMessage.success(decision === 'PASSED' ? '已通过复核' : '已驳回该互评')
    // 复核后待办数字会变化，必须同时刷新 todo 与列表
    await Promise.all([loadEvaluations(), loadTodo()])
  } catch {
    // 已提示
  }
}

async function auditDemand(row: Record<string, unknown>, approved: boolean) {
  let remark = '审核通过'
  if (approved) {
    const r = await withRemark(`通过卡片审核`, '可填写审核备注（会通知发布者）。')
    if (r === null) return
    remark = r || '审核通过'
  } else {
    // 驳回必须填原因 —— 服务端也会强制校验（3093）
    const r = await withRemark('驳回卡片审核', '驳回必须写明原因，用户需要知道如何修改。')
    if (!r) return
    remark = r
  }
  try {
    await adminApi.auditDemand(Number(row.id), approved, remark)
    ElMessage.success(approved ? '已通过' : '已驳回')
    await Promise.all([loadReview(), loadTodo()])
  } catch {
    // 已提示
  }
}

async function handleReport(row: AdminReportRow, accepted: boolean) {
  const remark = await withRemark(
    accepted ? '判定举报成立' : '判定举报不成立',
    accepted
      ? '举报成立会按对象类型自动处置（卡片下架 / 标签停用 / 评价转复核）。请说明判定依据。'
      : '请说明为何判定不成立（举报人也会收到该说明）。'
  )
  if (!remark) return
  try {
    const r = await adminApi.handleReport(row.id, accepted, remark)
    ElMessage.success(`已处理${r.actions?.length ? '：' + r.actions.join('；') : ''}`)
    await Promise.all([loadReview(), loadTodo()])
  } catch {
    // 已提示
  }
}

async function doImport() {
  if (!importText.value.trim()) {
    ElMessage.warning('请粘贴要导入的内容')
    return
  }
  loading.value = true
  try {
    importResult.value = await adminApi.importSkills(importText.value)
    ElMessage.success(
      `导入完成：新增 ${importResult.value.created}、更新 ${importResult.value.updated}、失败 ${importResult.value.failed}`
    )
    batches.value = await adminApi.importBatches(5)
  } catch {
    // 已提示
  } finally {
    loading.value = false
  }
}

async function doExport() {
  try {
    await exportSkills()
    ElMessage.success('已导出，可在表格软件中修改后重新导入')
  } catch (e) {
    ElMessage.error((e as Error).message)
  }
}

async function loadBatches() {
  try {
    batches.value = await adminApi.importBatches(5)
  } catch {
    // 已提示
  }
}

async function loadTools() {
  try {
    const r = await listTools()
    tools.value = r.tools
    toolProtocol.value = r.protocol
    tools.value.forEach((t) => {
      if (!(t.name in toolArgs)) {
        const req = (t.inputSchema?.required as string[]) ?? []
        toolArgs[t.name] = req.length ? `{"${req[0]}":"2024117420"}` : '{}'
      }
    })
  } catch {
    // 已提示
  }
}

async function runTool(name: string) {
  callingTool.value = name
  try {
    let args: Record<string, unknown> = {}
    try {
      args = JSON.parse(toolArgs[name] || '{}')
    } catch {
      ElMessage.error('参数不是合法 JSON')
      return
    }
    toolResult.value = await callTool(name, args)
    ElMessage.success('调用成功')
  } catch {
    // 已提示
  } finally {
    callingTool.value = ''
  }
}

function switchTab(tab: typeof activeTab.value) {
  activeTab.value = tab
  if (tab === 'dashboard' && !overview.value) loadDashboard()
  if (tab === 'users' && users.value.length === 0) loadUsers()
  if (tab === 'review') loadReview()
  if (tab === 'skills' && batches.value.length === 0) loadBatches()
  if (tab === 'tools' && tools.value.length === 0) loadTools()
}

function fmt(t?: string | null) {
  return t ? t.replace('T', ' ').slice(0, 16) : '—'
}

onMounted(() => {
  loadTodo()
  loadDashboard()
})
</script>

<template>
  <div class="zy-page" v-loading="loading">
    <p class="zy-page-subtitle">
      管理后台 · 所有写操作都会写入治理审计日志并公示，权限越大留痕要求越高。
    </p>

    <el-radio-group v-model="activeTab" size="small" class="tabs" @change="switchTab(activeTab)">
      <el-radio-button value="dashboard">数据看板</el-radio-button>
      <el-radio-button value="users">用户管理</el-radio-button>
      <el-radio-button value="review">
        内容审核{{ totalTodo > 0 ? `（待办 ${totalTodo}）` : '' }}
      </el-radio-button>
      <el-radio-button value="skills">技能标签</el-radio-button>
      <el-radio-button value="tools">开放接口</el-radio-button>
    </el-radio-group>

    <!-- ==================== 数据看板 ==================== -->
    <template v-if="activeTab === 'dashboard' && overview">
      <el-row :gutter="12" class="stats">
        <el-col :span="6" :sm="12" :md="6">
          <div class="zy-card kpi">
            <div class="kpi__v">{{ overview.userTotal }}</div>
            <div class="kpi__l">注册用户</div>
            <div class="kpi__h">正常 {{ overview.userActive }} · 禁用 {{ overview.bannedUsers }}</div>
          </div>
        </el-col>
        <el-col :span="6" :sm="12" :md="6">
          <div class="zy-card kpi">
            <div class="kpi__v">{{ overview.activeUsersToday }}</div>
            <div class="kpi__l">今日活跃</div>
            <div class="kpi__h">今日新增 {{ overview.newUsersToday }}</div>
          </div>
        </el-col>
        <el-col :span="6" :sm="12" :md="6">
          <div class="zy-card kpi">
            <div class="kpi__v">{{ overview.exchangeCompleted }}<span class="kpi__u">/{{ overview.exchangeTotal }}</span></div>
            <div class="kpi__l">交换完成 / 总数</div>
            <div class="kpi__h">完成率 {{ overview.completionRate }} · 今日完成 {{ overview.exchangeFinishedToday }}</div>
          </div>
        </el-col>
        <el-col :span="6" :sm="12" :md="6">
          <div class="zy-card kpi">
            <div class="kpi__v">{{ overview.matchSuccessRate }}</div>
            <div class="kpi__l">匹配成功率</div>
            <div class="kpi__h">邀约 {{ overview.inviteTotal }} · 接受 {{ overview.inviteAccepted }}</div>
          </div>
        </el-col>
      </el-row>

      <el-row :gutter="12" class="mt">
        <el-col :span="24" :md="12">
          <div class="zy-card panel">
            <div class="panel__head"><span class="panel__title">信用等级分布</span></div>
            <div v-for="c in overview.creditDistribution" :key="c.label" class="bar">
              <span class="bar__label">{{ c.label }}</span>
              <el-progress
                :percentage="overview.userTotal ? Math.round((c.count / overview.userTotal) * 100) : 0"
                :stroke-width="10"
                :format="() => String(c.count)"
              />
            </div>
          </div>
        </el-col>
        <el-col :span="24" :md="12">
          <div class="zy-card panel">
            <div class="panel__head"><span class="panel__title">学科门类分布（技能标签）</span></div>
            <div v-for="c in overview.skillCategoryDistribution" :key="c.label" class="bar">
              <span class="bar__label">{{ c.label }}</span>
              <el-progress
                :percentage="overview.skillTotal ? Math.round((c.count / overview.skillTotal) * 100) : 0"
                :stroke-width="10"
                :format="() => String(c.count)"
              />
            </div>
          </div>
        </el-col>
      </el-row>

      <el-row :gutter="12" class="mt">
        <el-col :span="24" :md="14">
          <div class="zy-card panel">
            <div class="panel__head">
              <span class="panel__title">趋势（近 14 天快照）</span>
              <el-button size="small" plain @click="makeSnapshot">生成今日快照</el-button>
            </div>
            <div v-if="trend && trend.snapshotCount > 0" class="trend-table">
              <div v-for="(d, i) in trend.dates" :key="d" class="trend-row">
                <span class="trend-row__date">{{ d }}</span>
                <span>活跃 {{ trend.activeUsers[i] }}</span>
                <span>完成 {{ trend.exchangeFinished[i] }}</span>
              </div>
            </div>
            <div v-else class="empty-hint">{{ trend?.note }}</div>
          </div>
        </el-col>
        <el-col :span="24" :md="10">
          <div class="zy-card panel">
            <div class="panel__head"><span class="panel__title">其他指标</span></div>
            <div class="kv"><span>需求卡片</span><b>{{ overview.demandTotal }} 张（招募中 {{ overview.demandOpen }}）</b></div>
            <div class="kv"><span>技能标签</span><b>{{ overview.skillTotal }} 个（启用 {{ overview.skillEnabled }}）</b></div>
            <div class="kv"><span>未结争议</span><b>{{ overview.openDisputes }} 起</b></div>
            <div class="kv"><span>今日发布</span><b>{{ overview.demandToday }} 张卡片</b></div>
            <div class="kv"><span>今日开始</span><b>{{ overview.exchangeStartedToday }} 次交换</b></div>
            <div class="kv"><span>统计时间</span><b>{{ fmt(overview.generatedAt) }}</b></div>
          </div>
        </el-col>
      </el-row>
    </template>

    <!-- ==================== 用户管理 ==================== -->
    <template v-else-if="activeTab === 'users'">
      <div class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">用户列表（共 {{ userTotal }} 人）</span>
          <div class="filters">
            <el-input v-model="userQuery.keyword" size="small" placeholder="学号 / 姓名 / 昵称" style="width: 180px" clearable />
            <el-input v-model="userQuery.college" size="small" placeholder="学院" style="width: 140px" clearable />
            <el-select v-model="userQuery.status" size="small" placeholder="状态" style="width: 100px" clearable>
              <el-option label="正常" :value="1" />
              <el-option label="已禁用" :value="0" />
            </el-select>
            <el-button size="small" type="primary" @click="userQuery.page = 1; loadUsers()">查询</el-button>
          </div>
        </div>

        <el-table :data="users" size="small">
          <el-table-column prop="sno" label="学号" width="110" />
          <el-table-column prop="name" label="姓名" width="100" />
          <el-table-column prop="college" label="学院" width="130" />
          <el-table-column label="信用" width="110">
            <template #default="{ row }">
              {{ row.creditScore }}（{{ row.creditLevelLabel }}）
            </template>
          </el-table-column>
          <el-table-column prop="exchangeQuota" label="并发" width="70" />
          <el-table-column prop="role" label="角色" width="100" />
          <el-table-column label="核验" width="100">
            <template #default="{ row }">{{ row.authStatus }}</template>
          </el-table-column>
          <el-table-column label="状态" width="80">
            <template #default="{ row }">
              <el-tag size="small" :type="row.status === 1 ? 'success' : 'danger'" effect="plain">
                {{ row.statusLabel }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" min-width="260">
            <template #default="{ row }">
              <el-button size="small" text type="primary" @click="toggleUser(row)">
                {{ row.status === 1 ? '禁用' : '启用' }}
              </el-button>
              <el-button size="small" text @click="changeRole(row)">角色</el-button>
              <el-button size="small" text @click="changeAuthStatus(row)">核验</el-button>
              <el-button size="small" text @click="recalcCredit(row)">重算信用</el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="pager">
          <el-pagination
            v-model:current-page="userQuery.page"
            :page-size="userQuery.size"
            :total="userTotal"
            layout="prev, pager, next, total"
            small
            @current-change="loadUsers"
          />
        </div>

        <el-alert
          class="mt"
          type="info"
          :closable="false"
          show-icon
          title="两条自我保护规则"
          description="不能对自己执行禁用/降权（防止把自己锁在门外），也不能操作其他管理员账号（避免管理员互相封禁）。所有写操作必须填说明并写入治理审计。"
        />
      </div>
    </template>

    <!-- ==================== 内容审核 ==================== -->
    <template v-else-if="activeTab === 'review'">
      <!--
        待复核互评（FR-M9-03）。

        为什么必须放在最前面：M6 的互刷检测会把"进入待互评后极短时间内就互相打分"
        这类可疑评价标为 PENDING，并写清楚命中的风险特征；顶部标签的"待办 N"
        也把这批算进去。但此前没有任何界面能列出或处置它们 ——
        徽标显示"待办 6"，管理员点进来却只有卡片与举报两个列表，
        找不到那 6 条在哪，也无法让数字降下来。这里补上这个入口。
      -->
      <div class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">
            待复核互评
            <el-tag v-if="todo.pendingEvaluations" size="small" type="danger" effect="dark">
              {{ todo.pendingEvaluations }}
            </el-tag>
          </span>
          <el-radio-group v-model="evalReviewStatus" size="small" @change="loadEvaluations">
            <el-radio-button value="PENDING">待复核</el-radio-button>
            <el-radio-button value="PASSED">已通过</el-radio-button>
            <el-radio-button value="REJECTED">已驳回</el-radio-button>
          </el-radio-group>
        </div>

        <p class="panel__desc">
          互刷检测会标记"疑似未真实协作"的评价（如进入待互评后极短时间内即提交），
          由人工判定是否需要干预。复核只决定<b>是否采信</b>，不修改分值 ——
          需要调整分值时另行追加修正记录，使审计日志能区分两种操作。
        </p>

        <div v-if="evaluations.length === 0" class="empty-hint">
          {{ evalReviewStatus === 'PENDING' ? '没有待复核的互评。' : '该状态下没有记录。' }}
        </div>

        <div v-for="e in evaluations" :key="e.id" class="review-row">
          <div class="review-row__main">
            <div class="review-row__top">
              <span class="review-row__title">{{ e.fromName }} → {{ e.toName }}</span>
              <el-tag size="small" type="warning" effect="plain">互评总分 {{ e.totalScore ?? '—' }}</el-tag>
              <el-tag v-if="e.timeoutFlag === 1" size="small" type="info" effect="plain">超时默认计分</el-tag>
              <el-tag v-if="e.disputeFlag === 1" size="small" type="danger" effect="plain">已被申诉</el-tag>
              <el-tag
                v-if="e.integrityOk === false"
                size="small"
                type="danger"
                effect="dark"
              >存证校验未通过</el-tag>
            </div>
            <div class="review-row__desc">
              交换：{{ e.recordNo || ('#' + e.recordId) }}
              <template v-if="e.recordTitle"> · {{ e.recordTitle }}</template>
            </div>
            <div v-if="e.comment" class="review-row__desc">评语：{{ e.comment }}</div>
            <div v-if="e.auditRemark" class="review-row__remark">命中风险：{{ e.auditRemark }}</div>
            <div class="review-row__meta">封存于 {{ fmt(e.sealedAt) }}</div>
          </div>
          <div v-if="e.auditStatus === 'PENDING'" class="review-row__ops">
            <el-button size="small" type="primary" @click="reviewEvaluation(e, 'PASSED')">通过</el-button>
            <el-button size="small" type="danger" plain @click="reviewEvaluation(e, 'REJECTED')">驳回</el-button>
          </div>
        </div>
      </div>

      <div class="zy-card panel mt">
        <div class="panel__head">
          <span class="panel__title">待审需求卡片</span>
          <el-tag size="small" type="info" effect="plain">
            自动审核命中敏感词/广告特征的卡片会进入这里
          </el-tag>
        </div>
        <div v-if="pendingDemands.length === 0" class="empty-hint">没有待审卡片。</div>
        <div v-for="d in pendingDemands" :key="String(d.id)" class="review-row">
          <div class="review-row__main">
            <div class="review-row__top">
              <span class="review-row__title">{{ d.title }}</span>
              <el-tag size="small" type="warning" effect="plain">{{ d.ownerName }}</el-tag>
            </div>
            <div class="review-row__desc">{{ d.description }}</div>
            <div class="review-row__meta">
              需求：{{ d.expectedSkill }} · 可提供：{{ d.offerSkill }} · {{ fmt(String(d.createdAt)) }}
            </div>
            <div v-if="d.auditRemark" class="review-row__remark">自动审核：{{ d.auditRemark }}</div>
          </div>
          <div class="review-row__ops">
            <el-button size="small" type="primary" @click="auditDemand(d, true)">通过</el-button>
            <el-button size="small" type="danger" plain @click="auditDemand(d, false)">驳回</el-button>
          </div>
        </div>
      </div>

      <div class="zy-card panel mt">
        <div class="panel__head">
          <span class="panel__title">用户举报（共 {{ reportTotal }} 条）</span>
          <el-radio-group v-model="reportStatus" size="small" @change="loadReview">
            <el-radio-button value="PENDING">待处理</el-radio-button>
            <el-radio-button value="ACCEPTED">已成立</el-radio-button>
            <el-radio-button value="REJECTED">不成立</el-radio-button>
            <el-radio-button value="">全部</el-radio-button>
          </el-radio-group>
        </div>
        <div v-if="reports.length === 0" class="empty-hint">没有符合条件的举报记录。</div>
        <div v-for="r in reports" :key="r.id" class="review-row">
          <div class="review-row__main">
            <div class="review-row__top">
              <el-tag size="small" effect="plain">{{ r.reasonLabel }}</el-tag>
              <span class="review-row__title">{{ r.targetType }} #{{ r.targetId }}</span>
              <el-tag size="small" :type="r.status === 'PENDING' ? 'warning' : (r.status === 'ACCEPTED' ? 'danger' : 'info')" effect="plain">
                {{ r.statusLabel }}
              </el-tag>
            </div>
            <div class="review-row__desc">{{ r.targetSummary }}</div>
            <div v-if="r.detail" class="review-row__desc">举报说明：{{ r.detail }}</div>
            <div class="review-row__meta">举报人：{{ r.reporterName }} · {{ fmt(r.createdAt) }}</div>
            <div v-if="r.handleRemark" class="review-row__remark">处理：{{ r.handleRemark }}</div>
          </div>
          <div v-if="r.status === 'PENDING'" class="review-row__ops">
            <el-button size="small" type="primary" @click="handleReport(r, true)">举报成立</el-button>
            <el-button size="small" plain @click="handleReport(r, false)">不成立</el-button>
          </div>
        </div>
      </div>
    </template>

    <!-- ==================== 技能标签 ==================== -->
    <template v-else-if="activeTab === 'skills'">
      <div class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">批量导入（FR-M9-02）</span>
          <div class="filters">
            <el-button size="small" plain @click="doExport">导出全部标签</el-button>
            <el-button size="small" type="primary" :loading="loading" @click="doImport">开始导入</el-button>
          </div>
        </div>
        <el-alert
          class="mb"
          type="info"
          :closable="false"
          show-icon
          title="格式：名称,门类,二级学科,难度,别名(用|分隔),描述"
          description="每行一条；# 开头为注释行会被忽略；也支持从 Excel 直接粘贴的制表符分隔。逐行校验：错误行会被跳过并列出原因，正确行照常导入 —— 而不是整批回滚。同名标签视为更新（保留历史引用）。"
        />
        <el-input
          v-model="importText"
          type="textarea"
          :rows="8"
          placeholder="# 示例&#10;摄影构图,艺术学,美术学,3,摄影|构图,画面组织与取景&#10;数据标注,工学,计算机科学与技术,2,标注,为模型准备数据"
        />

        <div v-if="importResult" class="import-result">
          <div class="import-result__head">
            批次 <b>{{ importResult.batchNo }}</b>：提交 {{ importResult.total }} 条，
            新增 <b class="ok">{{ importResult.created }}</b>，
            更新 <b class="ok">{{ importResult.updated }}</b>，
            失败 <b :class="importResult.failed > 0 ? 'bad' : ''">{{ importResult.failed }}</b>
          </div>
          <el-table v-if="importResult.errors.length" :data="importResult.errors" size="small">
            <el-table-column prop="line" label="行号" width="70" />
            <el-table-column prop="content" label="内容" show-overflow-tooltip />
            <el-table-column prop="reason" label="失败原因" show-overflow-tooltip />
          </el-table>
        </div>
      </div>

      <div class="zy-card panel mt">
        <div class="panel__head">
          <span class="panel__title">导入批次历史</span>
          <el-tag size="small" effect="plain">可追溯"这批标签是谁什么时候导的"</el-tag>
        </div>
        <el-table :data="batches" size="small" empty-text="暂无导入记录">
          <el-table-column prop="batchNo" label="批次号" width="180" />
          <el-table-column prop="operatorSno" label="操作人" width="110" />
          <el-table-column prop="total" label="提交" width="70" />
          <el-table-column prop="success" label="成功" width="70" />
          <el-table-column prop="failed" label="失败" width="70" />
          <el-table-column prop="source" label="来源" width="110" />
          <el-table-column prop="createdAt" label="时间" width="160">
            <template #default="{ row }">{{ fmt(row.createdAt) }}</template>
          </el-table-column>
        </el-table>
      </div>
    </template>

    <!-- ==================== 开放接口 ==================== -->
    <template v-else-if="activeTab === 'tools'">
      <div class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">开放能力接口（FR-M9-07 / FR-M9-08）</span>
          <el-tag size="small" type="success" effect="plain">{{ toolProtocol }}</el-tag>
        </div>
        <el-alert
          class="mb"
          type="info"
          :closable="false"
          show-icon
          title="约定参考 MCP 的 tools/list + tools/call"
          description="把平台的核心计算能力暴露为可被发现、可调用、带参数校验的标准化工具，便于校内其他系统集成，也可直接喂给智能体作为工具调用。所有工具只返回聚合计算结果，不暴露他人协作明细与隐私。"
        />
        <div v-for="t in tools" :key="t.name" class="tool">
          <div class="tool__head">
            <code class="tool__name">{{ t.name }}</code>
            <el-button size="small" type="primary" plain :loading="callingTool === t.name" @click="runTool(t.name)">
              调用
            </el-button>
          </div>
          <div class="tool__desc">{{ t.description }}</div>
          <el-input v-model="toolArgs[t.name]" size="small" class="tool__args" placeholder='参数 JSON，如 {"sno":"2024117420"}' />
        </div>

        <div v-if="toolResult" class="tool-result">
          <div class="tool-result__title">调用结果</div>
          <pre>{{ JSON.stringify(toolResult, null, 2) }}</pre>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.tabs {
  margin-bottom: 14px;
}

.stats {
  margin-bottom: 4px;
}

.mt {
  margin-top: 14px;
}

.mb {
  margin-bottom: 12px;
}

.kpi {
  padding: 14px 16px;
  height: 100%;
}

.kpi__v {
  font-size: 24px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  line-height: 1.3;
}

.kpi__u {
  font-size: 13px;
  font-weight: 400;
  color: var(--zy-text-secondary);
}

.kpi__l {
  font-size: 12.5px;
  color: var(--zy-text-secondary);
}

.kpi__h {
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.panel {
  padding: 16px 18px;
}

.panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.panel__title {
  font-size: 15px;
  font-weight: 600;
}

.filters {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
}

.bar {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 4px 0;
}

.bar__label {
  width: 84px;
  font-size: 12px;
  color: var(--zy-text-secondary);
  flex-shrink: 0;
}

.bar :deep(.el-progress) {
  flex: 1;
}

.trend-table {
  max-height: 220px;
  overflow-y: auto;
}

.trend-row {
  display: flex;
  gap: 18px;
  padding: 5px 0;
  border-bottom: 1px dashed var(--zy-border-light);
  font-size: 12px;
}

.trend-row__date {
  width: 96px;
  color: var(--zy-text-secondary);
}

.kv {
  display: flex;
  justify-content: space-between;
  padding: 5px 0;
  border-bottom: 1px dashed var(--zy-border-light);
  font-size: 12.5px;
  color: var(--zy-text-secondary);
}

.kv b {
  color: var(--zy-text-primary);
}

.empty-hint {
  padding: 20px 0;
  text-align: center;
  font-size: 12.5px;
  line-height: 1.9;
  color: var(--zy-text-placeholder);
}

.review-row {
  display: flex;
  justify-content: space-between;
  gap: 14px;
  padding: 11px 0;
  border-bottom: 1px dashed var(--zy-border-light);
  flex-wrap: wrap;
}

.review-row:last-child {
  border-bottom: none;
}

.review-row__main {
  flex: 1;
  min-width: 260px;
}

.review-row__top {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.review-row__title {
  font-size: 13.5px;
  font-weight: 600;
}

.review-row__desc {
  margin-top: 3px;
  font-size: 12px;
  line-height: 1.7;
  color: var(--zy-text-regular);
}

.review-row__meta {
  margin-top: 3px;
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.review-row__remark {
  margin-top: 4px;
  padding: 5px 8px;
  border-radius: var(--zy-radius-sm);
  background: rgba(224, 139, 60, 0.1);
  font-size: 11.5px;
  line-height: 1.7;
}

.review-row__ops {
  display: flex;
  gap: 6px;
  align-items: center;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.import-result {
  margin-top: 12px;
  padding: 12px 14px;
  border-radius: var(--zy-radius);
  background: #fbfdfe;
  border: 1px solid var(--zy-border-light);
}

.import-result__head {
  font-size: 12.5px;
  margin-bottom: 8px;
}

.ok {
  color: #4d7a2a;
}

.bad {
  color: #c96a4f;
}

.tool {
  padding: 11px 0;
  border-bottom: 1px dashed var(--zy-border-light);
}

.tool:last-of-type {
  border-bottom: none;
}

.tool__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}

.tool__name {
  font-family: Consolas, monospace;
  font-size: 13px;
  font-weight: 700;
  color: var(--zy-primary-dark);
}

.tool__desc {
  margin-top: 3px;
  font-size: 12px;
  line-height: 1.7;
  color: var(--zy-text-secondary);
}

.tool__args {
  margin-top: 6px;
  max-width: 520px;
}

.tool-result {
  margin-top: 14px;
  padding: 12px 14px;
  border-radius: var(--zy-radius);
  background: #f7fafb;
  border: 1px solid var(--zy-border);
}

.tool-result__title {
  font-size: 12.5px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  margin-bottom: 6px;
}

.tool-result pre {
  margin: 0;
  max-height: 280px;
  overflow: auto;
  font-size: 11.5px;
  line-height: 1.7;
}
</style>
