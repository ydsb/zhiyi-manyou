<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { DISPUTE_TYPES, VOTE_OPTIONS, creditApi, governanceApi } from '@/api/governance'
import { exchangeApi } from '@/api/demand'
import type {
  CaseFile,
  CreditDetail,
  DisputeItem,
  GovernanceLog,
  GovernanceRule
} from '@/api/types'

/**
 * 信用与社区治理页面（模块 M8）。
 *
 * 对应需求：
 *   FR-M8-01/02  信用值多因子明细与等级权限
 *   FR-M8-03     争议申诉（附证据与陈述）
 *   FR-M8-04/05  仲裁卷宗与匿名表决
 *   FR-M8-07     治理规则与操作审计公示
 *   FR-M8-08     管理员紧急干预留痕（管理端入口在下方"治理审计"）
 *
 * 设计取向：把「规则」「我的信用怎么算的」「争议怎么裁的」都摊开给用户看。
 * 治理的公信力来自透明与可追溯，而不是把结论抛给用户。
 */
const activeTab = ref<'credit' | 'disputes' | 'rules'>('credit')
const loading = ref(false)

const credit = ref<CreditDetail | null>(null)
const rules = ref<GovernanceRule | null>(null)
const logs = ref<GovernanceLog[]>([])
const asParty = ref<DisputeItem[]>([])
const toArbitrate = ref<DisputeItem[]>([])

/* ---------------- 申诉表单 ---------------- */
const disputeDialog = ref(false)
const submitting = ref(false)
const myExchanges = ref<Array<{ id: number; recordNo: string; title: string; status: string }>>([])
const disputeForm = reactive({
  recordId: undefined as number | undefined,
  disputeType: '',
  reason: '',
  statement: '',
  evidenceText: ''
})

/* ---------------- 卷宗抽屉 ---------------- */
const caseDrawer = ref(false)
const caseFile = ref<CaseFile | null>(null)
const caseDispute = ref<(DisputeItem & { caseFile: CaseFile | null }) | null>(null)
const defenseText = ref('')
const voteForm = reactive({ vote: '', comment: '' })

const pendingCount = computed(() => toArbitrate.value.length)

async function load() {
  loading.value = true
  try {
    const [c, r, l, d] = await Promise.all([
      creditApi.me(),
      governanceApi.rules(),
      governanceApi.logs(20),
      governanceApi.myDisputes()
    ])
    credit.value = c
    rules.value = r
    logs.value = l
    asParty.value = d.asParty
    toArbitrate.value = d.toArbitrate
  } catch {
    // 拦截器已提示
  } finally {
    loading.value = false
  }
}

/* ---------------- 发起申诉 ---------------- */

async function openDispute() {
  disputeForm.recordId = undefined
  disputeForm.disputeType = ''
  disputeForm.reason = ''
  disputeForm.statement = ''
  disputeForm.evidenceText = ''
  disputeDialog.value = true
  try {
    const list = (await exchangeApi.myExchanges()) as Array<{
      id: number
      recordNo: string
      title: string
      status: string
    }>
    // 只有进入实质阶段的交换才可申诉（后端同样会校验）
    myExchanges.value = list.filter((e) =>
      ['IN_PROGRESS', 'PENDING_EVAL', 'COMPLETED', 'DISPUTED'].includes(e.status)
    )
  } catch {
    myExchanges.value = []
  }
}

async function submitDispute() {
  if (!disputeForm.recordId || !disputeForm.disputeType || !disputeForm.reason.trim()) {
    ElMessage.warning('请选择交换记录、争议类型并填写理由')
    return
  }
  const evidence = disputeForm.evidenceText
    .split('\n')
    .map((s) => s.trim())
    .filter(Boolean)
  if (!disputeForm.statement.trim() && evidence.length === 0) {
    ElMessage.warning('请至少填写详细陈述或提供一项证据')
    return
  }
  try {
    await ElMessageBox.confirm(
      '申诉会启动仲裁流程。若最终认定申诉不成立，你的信用值将被扣减（滥用申诉有成本）。确认提交？',
      '确认发起申诉',
      { confirmButtonText: '提交申诉', cancelButtonText: '再想想', type: 'warning' }
    )
  } catch {
    return
  }
  submitting.value = true
  try {
    const res = await governanceApi.createDispute({
      recordId: disputeForm.recordId,
      disputeType: disputeForm.disputeType,
      reason: disputeForm.reason,
      statement: disputeForm.statement || undefined,
      evidence: evidence.length ? evidence : undefined
    })
    ElMessage.success(
      res.arbitratorCount > 0
        ? '申诉已受理，仲裁委员会已抽取并进入匿名表决'
        : '申诉已受理。当前合格委员不足，已转管理员处置（会留痕公示）'
    )
    disputeDialog.value = false
    await load()
  } catch {
    // 已提示
  } finally {
    submitting.value = false
  }
}

/* ---------------- 卷宗与表决 ---------------- */

async function openCase(d: DisputeItem) {
  try {
    const detail = await governanceApi.disputeDetail(d.id)
    caseDispute.value = detail
    caseFile.value = detail.caseFile
    defenseText.value = ''
    voteForm.vote = ''
    voteForm.comment = ''
    caseDrawer.value = true
  } catch {
    // 已提示
  }
}

async function submitDefense() {
  if (!caseDispute.value || !defenseText.value.trim()) {
    ElMessage.warning('请输入答辩内容')
    return
  }
  try {
    await governanceApi.submitDefense(caseDispute.value.id, defenseText.value)
    ElMessage.success('答辩已提交')
    await openCase(caseDispute.value)
    await load()
  } catch {
    // 已提示
  }
}

async function submitVote() {
  if (!caseDispute.value || !voteForm.vote) {
    ElMessage.warning('请选择投票选项')
    return
  }
  try {
    await ElMessageBox.confirm(
      '表决为匿名提交：公示只显示票数，不会暴露你的选择。提交后不可更改。',
      '确认表决',
      { confirmButtonText: '确认提交', cancelButtonText: '取消', type: 'info' }
    )
  } catch {
    return
  }
  try {
    await governanceApi.vote(caseDispute.value.id, {
      vote: voteForm.vote as 'APPLICANT' | 'RESPONDENT' | 'ABSTAIN',
      comment: voteForm.comment || undefined
    })
    ElMessage.success('表决已记录')
    await openCase(caseDispute.value)
    await load()
  } catch {
    // 已提示
  }
}

function statusTagType(status: string) {
  switch (status) {
    case 'PENDING':
      return 'info'
    case 'VOTING':
      return 'warning'
    case 'RESOLVED':
      return 'success'
    default:
      return 'danger'
  }
}

function fmt(t?: string | null) {
  return t ? t.replace('T', ' ').slice(0, 16) : '—'
}

onMounted(load)
</script>

<template>
  <div class="zy-page" v-loading="loading">
    <p class="zy-page-subtitle">
      信用不是黑箱：每一次加扣分都能查到依据，每一次裁决都能查到过程。
    </p>

    <el-radio-group v-model="activeTab" size="small" class="tabs">
      <el-radio-button value="credit">我的信用</el-radio-button>
      <el-radio-button value="disputes">
        争议与仲裁{{ pendingCount > 0 ? `（待我表决 ${pendingCount}）` : '' }}
      </el-radio-button>
      <el-radio-button value="rules">治理规则与公示</el-radio-button>
    </el-radio-group>

    <!-- ==================== 我的信用 ==================== -->
    <template v-if="activeTab === 'credit' && credit">
      <el-row :gutter="14" class="stats">
        <el-col :span="6" :sm="12" :md="6">
          <div class="zy-card stat">
            <div class="stat__label">信用值</div>
            <div class="stat__value">{{ credit.creditScore }}</div>
            <div class="stat__hint">等级「{{ credit.creditLevelLabel }}」</div>
          </div>
        </el-col>
        <el-col :span="6" :sm="12" :md="6">
          <div class="zy-card stat">
            <div class="stat__label">并发交换上限</div>
            <div class="stat__value">{{ credit.exchangeQuota }}<span class="stat__unit">次</span></div>
            <div class="stat__hint">由信用等级决定</div>
          </div>
        </el-col>
        <el-col :span="6" :sm="12" :md="6">
          <div class="zy-card stat">
            <div class="stat__label">仲裁委员资格</div>
            <div class="stat__value">{{ credit.eligibleArbitrator ? '具备' : '未具备' }}</div>
            <div class="stat__hint">需等级「优秀」以上</div>
          </div>
        </el-col>
        <el-col :span="6" :sm="12" :md="6">
          <div class="zy-card stat">
            <div class="stat__label">已完成协作</div>
            <div class="stat__value">{{ credit.exchangeCount }}<span class="stat__unit">次</span></div>
            <div class="stat__hint">累计 {{ credit.totalHours }} 小时</div>
          </div>
        </el-col>
      </el-row>

      <div class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">信用值构成（可追溯）</span>
          <el-tag size="small" effect="plain">{{ credit.privilege }}</el-tag>
        </div>
        <p class="caliber">{{ credit.caliber }}</p>

        <div v-for="f in credit.factors" :key="f.name" class="factor">
          <div class="factor__head">
            <span class="factor__name">{{ f.name }}</span>
            <span class="factor__weight">权重 {{ f.weightPercent }}%</span>
            <span v-if="f.score !== null" class="factor__score">{{ f.score }}</span>
            <span v-else class="factor__score factor__score--none">无数据</span>
          </div>
          <el-progress
            v-if="f.score !== null"
            :percentage="Math.min(100, f.score)"
            :stroke-width="6"
            :show-text="false"
          />
          <div class="factor__detail">{{ f.detail }}</div>
        </div>

        <el-alert
          v-if="credit.nextLevel"
          class="mt"
          type="info"
          :closable="false"
          show-icon
          :title="`距离「${credit.nextLevel.label}」还差 ${credit.nextLevel.gap} 分`"
          :description="`达到后可获得：${credit.nextLevel.privilege}`"
        />
      </div>

      <div class="zy-card panel mt">
        <div class="panel__head"><span class="panel__title">信用变动流水</span></div>
        <el-table :data="credit.ledger" size="small" empty-text="暂无变动记录">
          <el-table-column prop="createdAt" label="时间" width="150">
            <template #default="{ row }">{{ fmt(row.createdAt) }}</template>
          </el-table-column>
          <el-table-column prop="reason" label="原因" width="150" />
          <el-table-column label="变动" width="90">
            <template #default="{ row }">
              <span :class="row.delta >= 0 ? 'delta-up' : 'delta-down'">
                {{ row.delta > 0 ? '+' : '' }}{{ row.delta }}
              </span>
            </template>
          </el-table-column>
          <el-table-column prop="scoreAfter" label="变动后" width="80" />
          <el-table-column prop="remark" label="因子明细" show-overflow-tooltip />
        </el-table>
      </div>
    </template>

    <!-- ==================== 争议与仲裁 ==================== -->
    <template v-else-if="activeTab === 'disputes'">
      <div class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">待我表决（我是仲裁委员）</span>
          <el-button size="small" type="primary" @click="openDispute">发起申诉</el-button>
        </div>
        <div v-if="toArbitrate.length === 0" class="empty-hint">
          暂无需你表决的争议。
          <template v-if="!credit?.eligibleArbitrator">
            成为仲裁委员需要信用等级达到「优秀」以上 —— 当前为「{{ credit?.creditLevelLabel }}」。
          </template>
        </div>
        <div v-for="d in toArbitrate" :key="d.id" class="dispute">
          <div class="dispute__main">
            <div class="dispute__top">
              <el-tag size="small" type="warning" effect="plain">{{ d.disputeTypeLabel }}</el-tag>
              <span class="dispute__title">{{ d.exchangeTitle }}</span>
              <el-tag size="small" :type="statusTagType(d.status)" effect="plain">
                {{ d.statusLabel }}
              </el-tag>
            </div>
            <div class="dispute__meta">
              <span>{{ d.applicantName }} 申诉 {{ d.respondentName }}</span>
              <span>已投 {{ d.voteCount }} / {{ d.arbitratorCount }}</span>
              <span>截止 {{ fmt(d.voteDeadline) }}</span>
            </div>
          </div>
          <el-button size="small" type="primary" @click="openCase(d)">查阅卷宗并表决</el-button>
        </div>
      </div>

      <div class="zy-card panel mt">
        <div class="panel__head"><span class="panel__title">我的争议</span></div>
        <div v-if="asParty.length === 0" class="empty-hint">暂无争议记录。希望大家都能顺利协作。</div>
        <div v-for="d in asParty" :key="d.id" class="dispute">
          <div class="dispute__main">
            <div class="dispute__top">
              <el-tag size="small" effect="plain">{{ d.disputeTypeLabel }}</el-tag>
              <span class="dispute__title">{{ d.exchangeTitle }}</span>
              <el-tag size="small" :type="statusTagType(d.status)" effect="plain">
                {{ d.statusLabel }}
              </el-tag>
              <el-tag size="small" type="info" effect="plain">
                {{ d.myRole === 'APPLICANT' ? '我是申诉人' : '我是被申诉人' }}
              </el-tag>
            </div>
            <div class="dispute__meta">
              <span>{{ d.reason }}</span>
            </div>
            <div v-if="d.verdict" class="dispute__verdict">裁决：{{ d.verdict }}</div>
          </div>
          <el-button size="small" plain @click="openCase(d)">查看详情</el-button>
        </div>
      </div>
    </template>

    <!-- ==================== 治理规则与公示 ==================== -->
    <template v-else-if="activeTab === 'rules' && rules">
      <div class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">信用等级与权限</span>
          <el-tag size="small" type="success" effect="plain">等级决定实际权限，不只是标签</el-tag>
        </div>
        <el-table :data="rules.creditLevels" size="small">
          <el-table-column prop="label" label="等级" width="80" />
          <el-table-column label="分数区间" width="110">
            <template #default="{ row }">
              {{ row.minScore }} ~ {{ row.maxScore === null ? '∞' : row.maxScore }}
            </template>
          </el-table-column>
          <el-table-column prop="exchangeQuota" label="并发上限" width="90" />
          <el-table-column label="仲裁委员" width="90">
            <template #default="{ row }">
              <el-tag v-if="row.eligibleArbitrator" size="small" type="success" effect="plain">可担任</el-tag>
              <span v-else class="text-muted">—</span>
            </template>
          </el-table-column>
          <el-table-column prop="privilege" label="权限说明" show-overflow-tooltip />
        </el-table>
      </div>

      <el-row :gutter="14" class="mt">
        <el-col :span="24" :md="14">
          <div class="zy-card panel">
            <div class="panel__head"><span class="panel__title">仲裁流程</span></div>
            <ol class="steps">
              <li v-for="(s, i) in rules.flow.steps" :key="i">{{ s }}</li>
            </ol>
            <div class="rule-block">
              <div class="rule-block__label">委员资格</div>
              <div>{{ rules.flow.arbitratorEligibility }}</div>
            </div>
            <div class="rule-block">
              <div class="rule-block__label">表决规则</div>
              <div>{{ rules.flow.voteRule }}</div>
            </div>
            <div class="rule-block">
              <div class="rule-block__label">处罚力度</div>
              <div v-for="(v, k) in rules.flow.penaltyRule" :key="k" class="penalty">
                <span class="penalty__k">{{ k }}</span>{{ v }}
              </div>
            </div>
            <div class="rule-block">
              <div class="rule-block__label">审计规则</div>
              <div>{{ rules.auditRule }}</div>
            </div>
          </div>
        </el-col>

        <el-col :span="24" :md="10">
          <div class="zy-card panel">
            <div class="panel__head">
              <span class="panel__title">争议类型</span>
            </div>
            <div v-for="t in rules.disputeTypes" :key="t.code" class="dtype">
              <div class="dtype__label">{{ t.label }}</div>
              <div class="dtype__desc">{{ t.description }}</div>
            </div>
          </div>
        </el-col>
      </el-row>

      <div class="zy-card panel mt">
        <div class="panel__head">
          <span class="panel__title">治理动态公示</span>
          <el-tag size="small" effect="plain">涉及隐私的操作留痕但不公示</el-tag>
        </div>
        <div v-if="logs.length === 0" class="empty-hint">暂无治理记录。</div>
        <div v-for="l in logs" :key="l.id" class="glog">
          <el-tag size="small" effect="plain">{{ l.actionLabel }}</el-tag>
          <div class="glog__body">
            <div class="glog__summary">{{ l.summary }}</div>
            <div v-if="l.reason" class="glog__reason">理由：{{ l.reason }}</div>
            <div class="glog__meta">
              <span>{{ l.actorSno }}（{{ l.actorRole }}）</span>
              <span>{{ fmt(l.createdAt) }}</span>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- ---------------- 发起申诉 ---------------- -->
    <el-dialog v-model="disputeDialog" title="发起争议申诉" width="620px">
      <el-alert
        class="mb"
        type="warning"
        :closable="false"
        show-icon
        title="申诉会启动仲裁流程"
        description="委员会将依据系统自动生成的协作卷宗表决。若最终认定申诉不成立，你的信用值会被扣减 —— 请如实提交。"
      />
      <el-form label-width="88px" label-position="left">
        <el-form-item label="交换记录" required>
          <el-select v-model="disputeForm.recordId" placeholder="选择要申诉的交换" style="width: 100%">
            <el-option
              v-for="e in myExchanges"
              :key="e.id"
              :label="`${e.recordNo} ${e.title}`"
              :value="e.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="争议类型" required>
          <el-select v-model="disputeForm.disputeType" placeholder="请选择" style="width: 100%">
            <el-option v-for="t in DISPUTE_TYPES" :key="t.code" :label="t.label" :value="t.code">
              <span>{{ t.label }}</span>
              <span class="opt-desc">{{ t.desc }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="申诉理由" required>
          <el-input v-model="disputeForm.reason" maxlength="500" show-word-limit
                    placeholder="一句话概括，如：对方接受邀约后长期失联" />
        </el-form-item>
        <el-form-item label="详细陈述">
          <el-input v-model="disputeForm.statement" type="textarea" :rows="4" maxlength="1000"
                    show-word-limit placeholder="按时间线说明事实经过，委员会将据此判断" />
        </el-form-item>
        <el-form-item label="证据材料">
          <el-input v-model="disputeForm.evidenceText" type="textarea" :rows="3"
                    placeholder="每行一条：附件链接或文字说明（至少与详细陈述填写其一）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="disputeDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitDispute">提交申诉</el-button>
      </template>
    </el-dialog>

    <!-- ---------------- 卷宗抽屉 ---------------- -->
    <el-drawer v-model="caseDrawer" title="仲裁卷宗" size="52%" direction="rtl">
      <template v-if="caseDispute">
        <div class="case-head">
          <h4>{{ caseDispute.exchangeTitle }}</h4>
          <div class="case-head__meta">
            <el-tag size="small" effect="plain">{{ caseDispute.disputeTypeLabel }}</el-tag>
            <el-tag size="small" :type="statusTagType(caseDispute.status)" effect="plain">
              {{ caseDispute.statusLabel }}
            </el-tag>
            <span>{{ caseDispute.applicantName }} 申诉 {{ caseDispute.respondentName }}</span>
          </div>
        </div>

        <el-alert
          v-if="caseDispute.verdict"
          class="mb"
          type="success"
          :closable="false"
          show-icon
          title="裁决结论"
          :description="caseDispute.verdict"
        />

        <!-- 表决区 -->
        <div v-if="caseDispute.canVote" class="zy-card vote-box">
          <div class="vote-box__title">匿名表决</div>
          <p class="vote-box__hint">
            公示只显示票数分布，不会暴露你的选择。投票内容会做哈希存证，
            出现舞弊指控时可验证该票自提交起未被改动（对社区匿名，对审计透明）。
          </p>
          <el-radio-group v-model="voteForm.vote" class="vote-box__options">
            <el-radio v-for="o in VOTE_OPTIONS" :key="o.value" :value="o.value" border>
              {{ o.label }}
            </el-radio>
          </el-radio-group>
          <el-input v-model="voteForm.comment" type="textarea" :rows="2" maxlength="500"
                    class="mb" placeholder="投票说明（可选，公示时匿名展示，帮助社区理解裁决理由）" />
          <el-button type="primary" @click="submitVote">提交表决</el-button>
        </div>

        <div v-else-if="caseDispute.myVote" class="zy-card vote-box">
          <div class="vote-box__title">你已表决</div>
          <p>选择：{{ caseDispute.myVote.vote }}；说明：{{ caseDispute.myVote.comment || '—' }}</p>
        </div>

        <!-- 答辩区 -->
        <div v-if="caseDispute.canDefense" class="zy-card vote-box">
          <div class="vote-box__title">提交答辩</div>
          <p class="vote-box__hint">你有权对申诉内容作出说明，委员会将一并参考。</p>
          <el-input v-model="defenseText" type="textarea" :rows="3" maxlength="1000" class="mb"
                    placeholder="说明你的立场与事实依据" />
          <el-button @click="submitDefense">提交答辩</el-button>
        </div>

        <!-- 投票结果 -->
        <div v-if="caseDispute.voteResult" class="zy-card vote-box">
          <div class="vote-box__title">表决结果（匿名）</div>
          <div class="vote-result">
            <span>共 {{ caseDispute.voteResult.total }} 票</span>
            <span>支持申诉 {{ caseDispute.voteResult.forApplicant }}</span>
            <span>支持被申诉 {{ caseDispute.voteResult.forRespondent }}</span>
            <span>弃权 {{ caseDispute.voteResult.abstain }}</span>
          </div>
          <ul v-if="caseDispute.voteResult.comments?.length" class="vote-comments">
            <li v-for="(c, i) in caseDispute.voteResult.comments" :key="i">{{ c }}</li>
          </ul>
        </div>

        <!-- 卷宗内容 -->
        <template v-if="caseFile">
          <el-divider content-position="left">协作卷宗（自动生成，委员表决的事实依据）</el-divider>

          <div class="case-section">
            <div class="case-section__title">交换概况</div>
            <div class="kv">
              <span>编号</span><b>{{ caseFile.exchange.recordNo }}</b>
              <span>状态</span><b>{{ caseFile.exchange.statusLabel }}</b>
              <span>实际工时</span><b>{{ caseFile.exchange.actualHours ?? '—' }}</b>
            </div>
            <div class="case-desc">{{ caseFile.exchange.description }}</div>
          </div>

          <div class="case-section">
            <div class="case-section__title">双方</div>
            <div v-for="p in caseFile.parties" :key="p.sno" class="kv">
              <span>{{ p.role }}</span>
              <b>{{ p.name }}（{{ p.college }}）信用 {{ p.creditScore }}</b>
              <span>提供技能</span><b>{{ p.provideSkill }}</b>
            </div>
          </div>

          <div class="case-section">
            <div class="case-section__title">任务与打卡</div>
            <div class="kv">
              <span>共</span><b>{{ caseFile.taskSummary.total }} 项</b>
              <span>完成</span><b>{{ caseFile.taskSummary.done }}</b>
              <span>逾期</span><b>{{ caseFile.taskSummary.overdue }}</b>
              <span>完成率</span><b>{{ caseFile.taskSummary.completionRate ?? '—' }}</b>
            </div>
            <div v-for="(t, i) in caseFile.tasks" :key="i" class="case-task">
              {{ t.title }} —— {{ t.assignee }} / {{ t.status }}
              <el-tag v-if="t.overdue" size="small" type="danger" effect="plain">逾期</el-tag>
            </div>
          </div>

          <div class="case-section">
            <div class="case-section__title">沟通与交付</div>
            <div class="kv">
              <span>留言总数</span><b>{{ caseFile.communication.messageCount }} 条</b>
              <span>供给方</span><b>{{ caseFile.communication.giverMessages }} 条</b>
              <span>需求方</span><b>{{ caseFile.communication.takerMessages }} 条</b>
            </div>
          </div>

          <div class="case-section">
            <div class="case-section__title">双向互评</div>
            <div v-for="(e, i) in caseFile.evaluations" :key="i" class="case-eval">
              <div class="case-eval__top">
                <span>{{ e.from }} → {{ e.to }}</span>
                <b>{{ e.totalScore }} 分</b>
                <el-tag size="small" :type="e.integrityOk ? 'success' : 'danger'" effect="plain">
                  {{ e.integrityOk ? '存证完整' : '存证异常' }}
                </el-tag>
                <el-tag v-if="e.timeoutScored" size="small" type="warning" effect="plain">超时默认计分</el-tag>
              </div>
              <div class="case-eval__comment">{{ e.comment }}</div>
            </div>
          </div>

          <div class="case-section">
            <div class="case-section__title">时间轴</div>
            <div v-for="(t, i) in caseFile.timeline" :key="i" class="case-tl">{{ t }}</div>
          </div>

          <div class="case-section">
            <div class="case-section__title">申诉主张</div>
            <div class="case-desc">{{ caseFile.claim.statement }}</div>
            <div v-if="caseFile.claim.evidence" class="case-desc">证据：{{ caseFile.claim.evidence }}</div>
          </div>
        </template>
        <el-empty v-else description="你没有查看该卷宗的权限" :image-size="60" />
      </template>
    </el-drawer>
  </div>
</template>

<style scoped>
.tabs {
  margin-bottom: 14px;
}

.stats {
  margin-bottom: 14px;
}

.stat {
  padding: 14px 16px;
  height: 100%;
}

.stat__label {
  font-size: 12.5px;
  color: var(--zy-text-secondary);
}

.stat__value {
  font-size: 24px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  line-height: 1.4;
}

.stat__unit {
  font-size: 12px;
  font-weight: 400;
  color: var(--zy-text-secondary);
  margin-left: 2px;
}

.stat__hint {
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

.caliber {
  margin: 0 0 12px;
  font-size: 11.5px;
  line-height: 1.8;
  color: var(--zy-text-secondary);
}

.factor {
  padding: 8px 0;
  border-bottom: 1px dashed var(--zy-border-light);
}

.factor:last-of-type {
  border-bottom: none;
}

.factor__head {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.factor__name {
  font-size: 13px;
  font-weight: 600;
  min-width: 84px;
}

.factor__weight {
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.factor__score {
  margin-left: auto;
  font-size: 14px;
  font-weight: 700;
  color: var(--zy-primary-dark);
}

.factor__score--none {
  font-size: 11.5px;
  font-weight: 400;
  color: var(--zy-text-placeholder);
}

.factor__detail {
  margin-top: 4px;
  font-size: 11px;
  color: var(--zy-text-secondary);
}

.delta-up {
  color: #4d7a2a;
  font-weight: 600;
}

.delta-down {
  color: #c96a4f;
  font-weight: 600;
}

.empty-hint {
  padding: 18px 0;
  font-size: 12.5px;
  line-height: 1.9;
  color: var(--zy-text-placeholder);
  text-align: center;
}

.dispute {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 11px 0;
  border-bottom: 1px dashed var(--zy-border-light);
  flex-wrap: wrap;
}

.dispute:last-child {
  border-bottom: none;
}

.dispute__main {
  flex: 1;
  min-width: 260px;
}

.dispute__top {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.dispute__title {
  font-size: 13.5px;
  font-weight: 600;
}

.dispute__meta {
  display: flex;
  gap: 12px;
  margin-top: 3px;
  font-size: 11.5px;
  color: var(--zy-text-secondary);
  flex-wrap: wrap;
}

.dispute__verdict {
  margin-top: 5px;
  padding: 6px 9px;
  border-radius: var(--zy-radius-sm);
  background: rgba(122, 158, 91, 0.1);
  font-size: 11.5px;
  line-height: 1.7;
}

.mt {
  margin-top: 14px;
}

.mb {
  margin-bottom: 12px;
}

/* ---------------- 规则 ---------------- */
.steps {
  margin: 0 0 14px;
  padding-left: 20px;
  font-size: 12.5px;
  line-height: 2;
}

.rule-block {
  margin-top: 10px;
  padding: 9px 11px;
  border-radius: var(--zy-radius-sm);
  background: #fbfdfe;
  font-size: 12px;
  line-height: 1.8;
}

.rule-block__label {
  font-weight: 600;
  color: var(--zy-primary-dark);
  margin-bottom: 2px;
}

.penalty {
  font-size: 12px;
}

.penalty__k {
  display: inline-block;
  min-width: 96px;
  font-weight: 600;
}

.dtype {
  padding: 8px 0;
  border-bottom: 1px dashed var(--zy-border-light);
}

.dtype:last-child {
  border-bottom: none;
}

.dtype__label {
  font-size: 13px;
  font-weight: 600;
}

.dtype__desc {
  font-size: 11.5px;
  color: var(--zy-text-secondary);
}

.glog {
  display: flex;
  gap: 10px;
  padding: 9px 0;
  border-bottom: 1px dashed var(--zy-border-light);
}

.glog:last-child {
  border-bottom: none;
}

.glog__body {
  flex: 1;
}

.glog__summary {
  font-size: 12.5px;
  font-weight: 600;
}

.glog__reason {
  margin-top: 2px;
  font-size: 11.5px;
  line-height: 1.7;
  color: var(--zy-text-secondary);
}

.glog__meta {
  display: flex;
  gap: 10px;
  margin-top: 3px;
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
}

.opt-desc {
  float: right;
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

/* ---------------- 卷宗抽屉 ---------------- */
.case-head h4 {
  margin: 0 0 6px;
  font-size: 15px;
}

.case-head__meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 11.5px;
  color: var(--zy-text-secondary);
  flex-wrap: wrap;
}

.vote-box {
  padding: 12px 14px;
  margin-bottom: 12px;
}

.vote-box__title {
  font-size: 13.5px;
  font-weight: 700;
  margin-bottom: 4px;
}

.vote-box__hint {
  margin: 0 0 10px;
  font-size: 11.5px;
  line-height: 1.75;
  color: var(--zy-text-secondary);
}

.vote-box__options {
  display: flex;
  gap: 8px;
  margin-bottom: 10px;
  flex-wrap: wrap;
}

.vote-result {
  display: flex;
  gap: 14px;
  font-size: 12.5px;
  flex-wrap: wrap;
}

.vote-comments {
  margin: 8px 0 0;
  padding-left: 18px;
  font-size: 11.5px;
  line-height: 1.8;
  color: var(--zy-text-secondary);
}

.case-section {
  margin-bottom: 14px;
}

.case-section__title {
  font-size: 12.5px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  margin-bottom: 5px;
}

.kv {
  display: flex;
  gap: 8px;
  padding: 3px 0;
  font-size: 12px;
  flex-wrap: wrap;
}

.kv span {
  color: var(--zy-text-placeholder);
  min-width: 62px;
}

.kv b {
  font-weight: 600;
  margin-right: 12px;
}

.case-desc {
  font-size: 11.5px;
  line-height: 1.8;
  color: var(--zy-text-regular);
}

.case-task {
  padding: 3px 0;
  font-size: 11.5px;
}

.case-eval {
  padding: 6px 0;
  border-bottom: 1px dashed var(--zy-border-light);
}

.case-eval__top {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  flex-wrap: wrap;
}

.case-eval__comment {
  margin-top: 2px;
  font-size: 11px;
  line-height: 1.7;
  color: var(--zy-text-secondary);
}

.case-tl {
  padding: 2px 0;
  font-size: 11px;
  color: var(--zy-text-secondary);
}

.text-muted {
  color: var(--zy-text-placeholder);
}
</style>
