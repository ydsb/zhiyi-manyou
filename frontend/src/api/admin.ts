import { request } from './request'
import type { PageData } from './types'

/**
 * 管理后台接口（模块 M9）。
 *
 * 全部路径都在 `/api/admin/**` 下，由 SecurityConfig 强制 ADMIN 角色。
 * 写操作都必须带 `remark`（操作说明），否则会被服务端拒绝（3093）。
 */

export interface AdminUserRow {
  id: number
  sno: string
  name: string
  sname: string
  nickname: string
  college: string
  major: string
  grade: string
  email: string | null
  authType: string | null
  authStatus: string | null
  role: string
  creditScore: number
  creditLevel: number
  creditLevelLabel: string
  exchangeQuota: number
  status: number
  statusLabel: string
  lastLoginAt: string | null
  createdAt: string
}

/**
 * 待复核互评的一行（FR-M9-03）。
 *
 * 字段刻意扁平、不复用面向被评价人的评价视图：审核需要知道
 * "谁评价谁、什么交换、命中了什么风险、存证是否完好"，
 * 而面向被评价人的视图会做匿名化与可见性处理，可能隐去管理所需信息。
 */
export interface AdminEvaluationReviewRow {
  id: number
  recordId: number
  recordNo: string | null
  recordTitle: string | null
  fromSno: string
  fromName: string
  toSno: string
  toName: string
  totalScore: number | null
  comment: string | null
  auditStatus: string
  /** 命中的风险特征说明，如"进入待互评后仅 1 分钟即提交" */
  auditRemark: string | null
  disputeFlag: number | null
  timeoutFlag: number | null
  sealedAt: string | null
  /** 存证校验是否通过；false 表示记录已被改动，需谨慎判断 */
  integrityOk: boolean | null
}

export interface AdminReportRow {
  id: number
  reporterSno: string
  reporterName: string
  targetType: string
  targetId: number
  targetSummary: string
  reasonType: string
  reasonLabel: string
  detail: string | null
  status: string
  statusLabel: string
  handlerSno: string | null
  handleRemark: string | null
  handledAt: string | null
  createdAt: string
}

export interface DashboardOverview {
  userTotal: number
  userActive: number
  bannedUsers: number
  newUsersToday: number
  activeUsersToday: number
  demandTotal: number
  demandOpen: number
  demandToday: number
  exchangeTotal: number
  exchangeInProgress: number
  exchangeCompleted: number
  exchangeStartedToday: number
  exchangeFinishedToday: number
  completionRate: string
  inviteTotal: number
  inviteAccepted: number
  matchSuccessRate: string
  skillTotal: number
  skillEnabled: number
  openDisputes: number
  collegeDistribution: Array<{ college: string; count: number }>
  creditDistribution: Array<{ label: string; count: number }>
  skillCategoryDistribution: Array<{ label: string; count: number }>
  generatedAt: string
}

export const adminApi = {
  /* ---------------- 数据看板（FR-M9-04） ---------------- */
  overview() {
    return request<DashboardOverview>({ url: '/admin/dashboard/overview', method: 'get' })
  },

  trend(days = 14) {
    return request<{
      dates: string[]
      activeUsers: number[]
      exchangeFinished: number[]
      demandPublished: number[]
      snapshotCount: number
      note: string
    }>({ url: '/admin/dashboard/trend', method: 'get', params: { days } })
  },

  /** 手动生成当日快照（补数据或演示用） */
  makeSnapshot(date?: string) {
    return request<{ snapshotId: number; statDate: string }>({
      url: '/admin/dashboard/snapshot',
      method: 'post',
      params: { date }
    })
  },

  health() {
    return request<Record<string, unknown>>({ url: '/admin/dashboard/health', method: 'get' })
  },

  /* ---------------- 用户管理（FR-M9-01） ---------------- */
  users(params: {
    keyword?: string
    college?: string
    status?: number
    role?: string
    page?: number
    size?: number
  }) {
    return request<PageData<AdminUserRow>>({ url: '/admin/users', method: 'get', params })
  },

  userDetail(sno: string) {
    return request<AdminUserRow & { creditDetail?: unknown }>({
      url: `/admin/users/${sno}`,
      method: 'get'
    })
  },

  /** 启用/禁用账号。禁用会同时把并发上限置 0 */
  setUserStatus(sno: string, enabled: boolean, remark: string) {
    return request<AdminUserRow>({
      url: `/admin/users/${sno}/status`,
      method: 'post',
      data: { enabled, remark }
    })
  },

  assignRole(sno: string, role: string, remark: string) {
    return request<AdminUserRow>({
      url: `/admin/users/${sno}/role`,
      method: 'post',
      data: { role, remark }
    })
  },

  setAuthStatus(sno: string, authStatus: string, remark: string) {
    return request<AdminUserRow>({
      url: `/admin/users/${sno}/auth-status`,
      method: 'post',
      data: { authStatus, remark }
    })
  },

  recalculateCredit(sno: string, remark: string) {
    return request<{ before: number; after: number; levelLabel: string; changed: boolean }>({
      url: `/admin/users/${sno}/recalculate-credit`,
      method: 'post',
      data: { remark }
    })
  },

  /* ---------------- 内容审核（FR-M9-03） ---------------- */
  pendingDemands(page = 1, size = 20) {
    return request<PageData<Record<string, unknown>>>({
      url: '/admin/content/demands',
      method: 'get',
      params: { page, size }
    })
  },

  auditDemand(id: number, approved: boolean, remark: string) {
    return request<Record<string, unknown>>({
      url: `/admin/content/demands/${id}/audit`,
      method: 'post',
      data: { approved, remark }
    })
  },

  reports(status?: string, page = 1, size = 20) {
    return request<PageData<AdminReportRow>>({
      url: '/admin/content/reports',
      method: 'get',
      params: { status, page, size }
    })
  },

  handleReport(id: number, accepted: boolean, remark: string) {
    return request<AdminReportRow & { actions: string[] }>({
      url: `/admin/content/reports/${id}/handle`,
      method: 'post',
      data: { accepted, remark }
    })
  },

  /**
   * 待人工复核的互评列表（FR-M9-03）。
   *
   * 互刷检测会把可疑评价标为 PENDING 并记下命中的风险特征
   * （如"进入待互评后仅 1 分钟即提交，可能未真实协作"）。
   * 待办徽标把这些算作待处理事项，因此必须有对应的处置入口。
   */
  pendingEvaluations(status = 'PENDING', page = 1, size = 20) {
    return request<PageData<AdminEvaluationReviewRow>>({
      url: '/admin/evaluations/pending',
      method: 'get',
      params: { status, page, size }
    })
  },

  /**
   * 人工复核一条互评（FR-M9-03）。
   *
   * 只判定"是否需要人工干预"，不改分值；需要改分请另调 amendEvaluation。
   */
  reviewEvaluation(id: number, decision: 'PASSED' | 'REJECTED', remark: string) {
    return request<Record<string, unknown>>({
      url: `/admin/evaluations/${id}/review`,
      method: 'post',
      data: { decision, remark }
    })
  },

  todo() {
    return request<{ pendingDemands: number; pendingReports: number; pendingEvaluations: number }>({
      url: '/admin/content/todo',
      method: 'get'
    })
  },

  /* ---------------- 技能标签导入（FR-M9-02） ---------------- */
  importSkills(content: string) {
    return request<{
      batchNo: string
      total: number
      created: number
      updated: number
      failed: number
      errors: Array<{ line: number; content: string; reason: string }>
    }>({ url: '/admin/skills/import', method: 'post', data: { content } })
  },

  importBatches(limit = 10) {
    return request<
      Array<{
        id: number
        batchNo: string
        operatorSno: string
        total: number
        success: number
        failed: number
        source: string
        createdAt: string
        errors: Array<{ line: number; content: string; reason: string }>
      }>
    >({ url: '/admin/skills/import/batches', method: 'get', params: { limit } })
  }
}

/** 导出技能标签（触发浏览器下载） */
export async function exportSkills() {
  const token = localStorage.getItem('zhiyi.accessToken')
  const res = await fetch('/api/admin/skills/export', {
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  })
  if (!res.ok) {
    throw new Error(`导出失败（HTTP ${res.status}）`)
  }
  const blob = await res.blob()
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'zhiyi-skills-export.txt'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

/* ---------------- 开放工具接口（FR-M9-07/08） ---------------- */

/** 工具清单（含 JSON Schema，可直接喂给 LLM 函数调用协议） */
export function listTools() {
  return request<{
    protocol: string
    tools: Array<{ name: string; description: string; inputSchema: Record<string, unknown> }>
    note: string
  }>({ url: '/tools', method: 'get' })
}

/** 调用工具 */
export function callTool(name: string, args: Record<string, unknown>) {
  return request<Record<string, unknown>>({
    url: '/tools/call',
    method: 'post',
    data: { name, arguments: args }
  })
}
