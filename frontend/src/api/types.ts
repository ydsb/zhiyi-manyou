/**
 * 与后端接口对应的类型定义。
 * 后端约定：所有接口返回 { code, message, data, traceId, timestamp }。
 */

/** 用户角色 */
export type UserRole = 'USER' | 'ARBITRATOR' | 'ADMIN'

/** 认证方式 */
export type AuthType = 'CAS' | 'OAUTH2' | 'LOCAL' | 'VERIFY'

/** 实名核验状态 */
export type AuthStatus = 'UNVERIFIED' | 'PENDING' | 'VERIFIED' | 'FAILED'

/** 用户信息（脱敏） */
export interface UserInfo {
  sno: string
  displayName: string
  college?: string
  major?: string
  grade?: string
  avatar?: string
  intro?: string
  role: UserRole
  authType?: AuthType
  authStatus?: AuthStatus
  creditScore?: number
  creditLevel?: number
  lastLoginAt?: string
}

/** 登录结果 */
export interface LoginResult {
  accessToken: string
  refreshToken: string
  tokenType: string
  expiresIn: number
  /** 是否首次登录 —— 为 true 时前端触发「新手漫游导引」 */
  firstLogin: boolean
  user: UserInfo
}

/** 登录请求 */
export interface LoginRequest {
  sno: string
  password: string
}

/** 注册请求（降级方案） */
export interface RegisterRequest {
  sno: string
  sname: string
  password: string
  email?: string
  phone?: string
  college?: string
  major?: string
  grade?: string
}

/** 健康检查 */
export interface HealthInfo {
  application: string
  status: string
  database: string
  databaseError?: string
}

/** 平台信息 */
export interface PlatformInfo {
  name: string
  fullName: string
  version: string
  description: string
  apiPrefix: string
}

/* ==================== 信用与社区治理（模块 M8） ==================== */

/** 信用因子明细 */
export interface CreditFactor {
  name: string
  /** null 表示该因子无数据（权重会被分摊到其他因子） */
  score: number | null
  weight: number
  weightPercent: number
  detail: string
}

/** 信用等级权限规则（公示用） */
export interface CreditLevelRule {
  level: string
  label: string
  minScore: number
  maxScore: number | null
  exchangeQuota: number
  eligibleArbitrator: boolean
  privilege: string
}

/** 我的信用详情 */
export interface CreditDetail {
  sno: string
  name: string
  creditScore: number
  creditLevel: string
  creditLevelLabel: string
  privilege: string
  exchangeQuota: number
  eligibleArbitrator: boolean
  computedScore: number
  isNewUser: boolean
  exchangeCount: number
  totalHours: number
  caliber: string
  factors: CreditFactor[]
  nextLevel: { label: string; needScore: number; gap: number; privilege: string } | null
  ledger: Array<{
    id: number
    delta: number
    scoreAfter: number
    reason: string
    remark: string | null
    createdAt: string
  }>
}

/** 治理规则公示 */
export interface GovernanceRule {
  creditLevels: CreditLevelRule[]
  disputeTypes: Array<{ code: string; label: string; description: string }>
  flow: {
    steps: string[]
    arbitratorEligibility: string
    voteRule: string
    penaltyRule: Record<string, string>
  }
  auditRule: string
}

/** 治理动态 / 审计记录 */
export interface GovernanceLog {
  id: number
  action: string
  actionLabel: string
  actorSno: string
  actorRole: string
  targetType: string | null
  targetId: string | null
  summary: string
  reason: string | null
  visible: boolean
  systemAction: boolean
  createdAt: string
}

/** 争议项 */
export interface DisputeItem {
  id: number
  recordId: number
  recordNo: string | null
  exchangeTitle: string | null
  disputeType: string
  disputeTypeLabel: string
  applicant: string
  applicantName: string
  respondent: string
  respondentName: string
  reason: string
  status: string
  statusLabel: string
  arbitratorCount: number
  voteCount: number
  voteDeadline: string | null
  voteExpired: boolean
  verdict: string | null
  resolvedBy: string | null
  resolvedAt: string | null
  createdAt: string
  myRole: 'APPLICANT' | 'RESPONDENT' | 'ARBITRATOR'
  /** 详情接口附加字段 */
  canDefense?: boolean
  canVote?: boolean
  myVote?: ArbitrationVote | null
  voteResult?: {
    total: number
    forApplicant: number
    forRespondent: number
    abstain: number
    comments: string[]
  } | null
  executionLog?: Record<string, unknown> | null
}

/** 仲裁投票请求 */
export interface ArbitrationVote {
  vote: 'APPLICANT' | 'RESPONDENT' | 'ABSTAIN'
  comment?: string
}

/** 卷宗（FR-M8-04，委员表决的事实依据） */
export interface CaseFile {
  exchange: {
    recordNo: string
    title: string
    description: string | null
    statusLabel: string
    startedAt: string | null
    finishedAt: string | null
    expectedHours: number | null
    actualHours: number | null
  }
  parties: Array<{
    sno: string
    name: string
    college: string | null
    role: string
    creditScore: number | null
    provideSkill: string | null
  }>
  tasks: Array<{
    title: string
    assignee: string
    status: string | null
    deadline: string | null
    doneAt: string | null
    overdue: boolean
    evidenceUrl: string | null
  }>
  taskSummary: { total: number; done: number; overdue: number; completionRate: string | null }
  communication: { messageCount: number; giverMessages: number; takerMessages: number }
  evaluations: Array<{
    from: string
    to: string
    totalScore: number
    comment: string | null
    anonymous: boolean
    timeoutScored: boolean
    sealedAt: string
    /** 评价哈希是否完整 —— 若为 false 说明存证被改动，委员应当警惕 */
    integrityOk: boolean
  }>
  timeline: string[]
  claim: {
    type: string
    typeLabel: string
    reason: string
    statement: string | null
    evidence: string | null
    applicant: string
    respondent: string
  }
}

/* ==================== 数字档案与能力画像（模块 M7） ==================== */

/** 单个能力维度的得分与出处（FR-M7-02） */
export interface AbilityDimensionScore {
  key: string
  label: string
  description: string
  /** 为 null 表示该维度暂无样本，前端应画虚线或标注"暂无数据"，不要当作 0 分 */
  score: number | null
  sampleCount: number
  /** 分数出处说明，如「ECharts 数据可视化（工学）换过 2 次、共 6 小时，平均 88.75 分」 */
  evidence: string
  skills: string[]
  max: number
}

/** 能力雷达图数据（FR-M7-01/02，AC-06） */
export interface RadarChart {
  sno: string
  name: string
  college: string
  major: string
  dimensions: AbilityDimensionScore[]
  scoreMap: Record<string, number | null>
  insufficientData: boolean
  sampleCount: number
  avgScore: number | null
  totalHours: number | null
  overallScore: number | null
  /** 统计口径说明，页面上要展示，避免用户误解数字含义 */
  caliberNote: string
  snapshotPeriod?: string | null
}

/** 单个维度的变化摘要 */
export interface GrowthChange {
  key: string
  label: string
  first: number
  latest: number
  delta: number
  improved: boolean
}

/** 成长轨迹（FR-M7-07） */
export interface GrowthTrend {
  sno: string
  periods: string[]
  series: Record<string, (number | null)[]>
  dimensionLabels: Record<string, string>
  pointCount: number
  changes: GrowthChange[]
  note: string
}

/** 数字勋章（FR-M7-04） */
export interface Badge {
  id: number
  code: string
  name: string
  description: string
  icon: string
  /** 勋章等级：1 铜 / 2 银 / 3 金 */
  level: string | null
  conditionText: string
  unlocked: boolean
  grantedAt?: string | null
  refRecordId?: number | null
  progressHint?: string | null
  currentValue: number
  targetValue: number
}

/** 报告中的单条协作履历 */
export interface ReportExchange {
  recordNo: string
  title: string
  peerName: string
  providedSkill: string
  acquiredSkill: string
  statusLabel: string
  finishedAt: string | null
  hours: number | null
  receivedScore: number | null
  comment: string | null
}

/** 《跨学科协作能力鉴定报告》（FR-M7-06/08） */
export interface AbilityReport {
  reportNo: string
  verifyCode: string | null
  verifyUrl: string | null
  generatedAt: string
  sno: string
  name: string
  college: string
  major: string
  grade: string
  creditScore: number | null
  creditLevel: string | null
  dimensions: AbilityDimensionScore[]
  overallScore: number | null
  sampleCount: number
  totalHours: number | null
  avgScore: number | null
  periodText: string
  exchanges: ReportExchange[]
  badges: Badge[]
  strengths: string[]
  behaviorSummary: string
  evidenceLevel: string | null
  integrityNote: string
  disclaimer: string
  caliberNote?: string
  caliber?: Record<string, unknown>
}

/** 成长周报（FR-M7-05） */
export interface WeeklyReport {
  id: number
  weekKey: string
  weekStart: string
  weekEnd: string
  summary: string
  highlights: string[]
  metrics: Record<string, unknown>
  createdAt: string
}

/* ==================== 协作工作台（模块 M5） ==================== */

/** 协作任务状态 */
export type TaskStatus = 'TODO' | 'DOING' | 'DONE'

/** 协作任务项（FR-M5-02） */
export interface CollabTask {
  id: number
  recordId: number
  title: string
  description?: string
  /** 负责人：为空表示双方共同负责 */
  assigneeSno?: string
  assigneeName?: string
  assigneeCollege?: string
  deadline?: string
  status: TaskStatus
  statusLabel: string
  overdue?: boolean
  evidenceUrl?: string
  sortOrder?: number
  doneAt?: string
  createdAt?: string
  createdBy?: string
  /** 是否由当前用户负责 */
  mine?: boolean
}

/** 协作文件版本（FR-M5-03） */
export interface CollabFile {
  id: number
  recordId: number
  /** 逻辑文件标识：同一文件的多版本共享 */
  groupKey: string
  version: number
  /** 该逻辑文件的当前最大版本号 */
  latestVersion?: number
  latest?: boolean
  fileName: string
  contentType?: string
  sizeBytes?: number
  sizeText?: string
  sha256?: string
  taskId?: number
  taskTitle?: string
  uploaderSno?: string
  uploaderName?: string
  remark?: string
  createdAt?: string
  downloadUrl?: string
  versionCount?: number
}

/** 协作留言（FR-M5-07） */
export interface CollabMessage {
  id: number
  recordId: number
  senderSno?: string
  senderName?: string
  senderCollege?: string
  content?: string
  fileId?: number
  fileName?: string
  fileSizeBytes?: number
  messageType: 'TEXT' | 'FILE' | 'SYSTEM'
  createdAt?: string
  mine?: boolean
}

/** 协作时间轴事件（FR-M5-04） */
export interface CollabEvent {
  id: number
  recordId: number
  actorSno?: string
  actorName?: string
  eventType: string
  title: string
  detail?: string
  refType?: string
  refId?: number
  occurredAt?: string
  /** 展示图标（服务端给出，前端无需维护映射表） */
  icon?: string
}

/** 单方过程性指标（FR-M5-06） */
export interface ParticipantMetrics {
  sno: string
  name?: string
  college?: string
  /** GIVER 供给方 / TAKER 需求方 */
  role: string
  assignedTasks?: number
  doneTasks?: number
  completionRate?: number | null
  overdueTasks?: number
  sharedTasks?: number
  messages?: number
  fileUploads?: number
  eventCount?: number
  /** 一句话小结 */
  digest?: string
}

/** 协作过程性指标汇总（FR-M5-06，供互评与能力画像引用） */
export interface ProcessSummary {
  recordId: number
  recordNo: string
  status?: string
  statusLabel?: string
  startedAt?: string
  durationMinutes?: number
  taskTotal?: number
  taskDone?: number
  taskDoing?: number
  taskTodo?: number
  taskOverdue?: number
  taskCompletionRate?: number | null
  onTimeRate?: number | null
  decompositionGranularity?: number
  messageTotal?: number
  firstActionDelayHours?: number
  idleMinutes?: number
  fileUploadTotal?: number
  fileGroupTotal?: number
  participants: ParticipantMetrics[]
}

/** 协作工作台总览 */
export interface Workspace {
  recordId: number
  recordNo: string
  title: string
  description?: string
  status: ExchangeStatus
  statusLabel: string
  giver?: { sno: string; name?: string; college?: string; provideSkillName?: string; acquireSkillName?: string }
  taker?: { sno: string; name?: string; college?: string; provideSkillName?: string; acquireSkillName?: string }
  myRole?: 'GIVER' | 'TAKER' | 'OBSERVER'
  allowedNextStatus?: string[]
  canManageTasks?: boolean
  canUpload?: boolean
  canSendMessage?: boolean
  canSubmitEval?: boolean
  startedAt?: string
  deadlineAt?: string
  expectedHours?: number
  actualHours?: number
  /** 是否已进入协作阶段（进行中/待互评/争议中） */
  collaborationActive?: boolean
  tasks: CollabTask[]
  files: CollabFile[]
  messages: CollabMessage[]
  timeline: CollabEvent[]
  processSummary?: ProcessSummary
}

/** 通知项（FR-M5-05） */
export interface NotificationItem {
  id: number
  type: string
  typeLabel: string
  title: string
  content?: string
  refType?: string
  refId?: number
  read: boolean
  createdAt?: string
  /** 服务端拼好的跳转路由 */
  linkPath?: string
}

/* ==================== 交换领域（模块 M4） ==================== */

/** 技能交换状态 */
export type ExchangeStatus =
  | 'PUBLISHED'
  | 'NEGOTIATING'
  | 'IN_PROGRESS'
  | 'PENDING_EVAL'
  | 'COMPLETED'
  | 'CANCELLED'
  | 'DISPUTED'

/** 需求卡片状态 */
export type DemandStatus = 'OPEN' | 'MATCHED' | 'CLOSED'

/** 可见范围 */
export type DemandVisibility = 'PUBLIC' | 'COLLEGE' | 'PRIVATE'

/** 交换意向状态 */
export type DemandInterestStatus = 'PENDING' | 'ACCEPTED' | 'REJECTED' | 'WITHDRAWN'

/** 分页结果 */
export interface PageResult<T> {
  records: T[]
  total: number
  page: number
  size: number
  pages: number
}

/** 技能简要信息 */
export interface SkillBrief {
  id: number
  name: string
  categoryL1?: string
  categoryL2?: string
}

/** 匹配度因子（可解释推荐） */
export interface MatchFactor {
  name: string
  score: number
  weight: number
  contribution: number
  detail: string
}

/** 交换意向 */
export interface DemandInterest {
  id: number
  demandId: number
  demandTitle?: string
  demandNo?: string
  applicantSno: string
  applicantName?: string
  applicantCollege?: string
  recordId?: number
  recordNo?: string
  matchScore?: number
  status: DemandInterestStatus
  statusLabel: string
  message?: string
  createdAt?: string
}

/** 集市卡片 */
export interface MarketCard {
  id: number
  demandNo: string
  title: string
  description?: string
  ownerSno: string
  ownerName?: string
  ownerCollege?: string
  ownerCreditScore?: string
  /** 我急需 */
  expectSkill?: SkillBrief
  /** 我可提供 */
  offerSkill?: SkillBrief
  expectedHours?: number
  expectedPeriod?: string
  visibility?: DemandVisibility
  visibilityLabel?: string
  status?: DemandStatus
  statusLabel?: string
  auditStatus?: string
  matchCount?: number
  viewCount?: number
  interests?: DemandInterest[]
  /** 综合匹配度 0~1 */
  matchScore?: number
  /** 是否高匹配（用于高亮置顶） */
  highMatch?: boolean
  matchFactors?: MatchFactor[]
  createdAt?: string
  expireAt?: string
}

/** 发布需求卡片请求 */
export interface DemandCreatePayload {
  title: string
  description?: string
  expectedSkillId: number
  offerSkillId?: number
  expectedHours?: number
  expectedPeriod?: string
  visibility?: DemandVisibility
}

/** 发起交换邀约请求 */
export interface ExchangeApplyPayload {
  demandId: number
  message?: string
  deadlineAt?: string
}

/** 交换参与方技能信息 */
export interface ExchangeParty {
  sno: string
  name?: string
  college?: string
  provideSkillId?: number
  provideSkillName?: string
  acquireSkillId?: number
  acquireSkillName?: string
}

/** 交换记录 */
export interface Exchange {
  id: number
  recordNo: string
  title: string
  description?: string
  giver?: ExchangeParty
  taker?: ExchangeParty
  status: ExchangeStatus
  statusLabel: string
  /** 当前状态下允许流转到的目标状态 */
  allowedNextStatus?: string[]
  /** 当前用户在本记录中的角色 */
  myRole?: 'GIVER' | 'TAKER' | 'OBSERVER'
  canAccept?: boolean
  canReject?: boolean
  canCancel?: boolean
  canStart?: boolean
  canSubmitEval?: boolean
  canDispute?: boolean
  sourceDemandId?: number
  matchScore?: number
  expectedHours?: number
  actualHours?: number
  startedAt?: string
  deadlineAt?: string
  pendingEvalAt?: string
  finishedAt?: string
  createdAt?: string
}

/** 业务字典：集市 */
export interface DemandMeta {
  visibility: Array<{ value: string; label: string }>
  demandStatus: Array<{ value: string; label: string }>
  sort: Array<{ value: string; label: string }>
  highMatchThreshold: number
}

/** 业务字典：交换状态机 */
export interface ExchangeStatusMeta {
  value: ExchangeStatus
  label: string
  final: boolean
  occupiesQuota: boolean
  allowedNext: string[]
}

/* ==================== 技能本体（模块 M2） ==================== */

/** 技能意图：我擅长 / 我正在研究 / 我急需 */
export type SkillIntent = 'SKILLED' | 'RESEARCHING' | 'NEEDED'

/** 技能标签 */
export interface Skill {
  id: number
  name: string
  alias?: string
  categoryL1: string
  categoryL2: string
  description?: string
  difficulty?: number
  hotScore?: number
  embeddingId?: string
}

/** 匹配方式 */
export type SkillMatchType = 'EXACT' | 'ALIAS' | 'KEYWORD' | 'GRAPH'

/** 技能匹配项（带可解释依据） */
export interface SkillMatch {
  skillId: number
  name: string
  categoryL1?: string
  categoryL2?: string
  /** SKILLED 我擅长 / RESEARCHING 我正在研究 / NEEDED 我急需 */
  intent?: SkillIntent | null
  score: number
  matchType: SkillMatchType
  reason: string
}

/** 技能标签树 */
export interface SkillTree {
  categoryCount: number
  subCategoryCount: number
  skillCount: number
  tree: Array<{
    name: string
    skillCount: number
    children: Array<{
      name: string
      skillCount: number
      skills: Skill[]
    }>
  }>
}

/** 图谱关系类型 */
export type SkillRelationType = 'PREREQUISITE' | 'COMPLEMENT' | 'SYNONYM'

/** 图谱关系边 */
export interface SkillRelation {
  id: number
  srcSkillId: number
  srcSkillName: string
  dstSkillId: number
  dstSkillName: string
  relationType: SkillRelationType
  relationLabel: string
  weight: number
  directed: boolean
  remark?: string
}

/** 三元组 */
export interface ParseTriple {
  subject: string
  action: string
  object: string
}

/** 文本解析结果 */
export interface ParseResult {
  text: string
  subject: string
  matched: SkillMatch[]
  triples: ParseTriple[]
  /** RULE_LEXICON 规则词典引擎 / NLP_MODEL 预训练模型（S3 阶段） */
  engine: string
  /** 是否为降级结果（语义服务不可用） */
  degraded: boolean
  hint?: string
}

/** 技能标签新增/修改请求 */
export interface SkillSavePayload {
  id?: number
  name: string
  alias?: string
  categoryL1: string
  categoryL2: string
  description?: string
  difficulty?: number
  status?: number
}
