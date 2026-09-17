import { request } from './request'
import type {
  ArbitrationVote,
  CaseFile,
  CreditDetail,
  CreditLevelRule,
  DisputeItem,
  GovernanceLog,
  GovernanceRule
} from './types'

/**
 * 信用与社区治理接口（模块 M8）。
 *
 * 注意：治理规则与公示类接口是**匿名开放**的 —— 治理透明是平台公信力的前提。
 */
export const creditApi = {
  /** 我的信用详情：当前值、等级、权限、因子明细与流水 */
  me() {
    return request<CreditDetail>({ url: '/credit/me', method: 'get' })
  },

  /** 信用等级权限公示（匿名可访问） */
  levels() {
    return request<CreditLevelRule[]>({ url: '/credit/levels', method: 'get' })
  }
}

export const governanceApi = {
  /** 治理规则公示（匿名可访问） */
  rules() {
    return request<GovernanceRule>({ url: '/governance/rules', method: 'get' })
  },

  /** 治理动态公示（匿名可访问，仅可见项） */
  logs(limit = 30) {
    return request<GovernanceLog[]>({ url: '/governance/logs', method: 'get', params: { limit } })
  },

  /** 治理统计 */
  statistics() {
    return request<{ total: number; byAction: Record<string, number>; actionLabels: Record<string, string> }>({
      url: '/governance/statistics',
      method: 'get'
    })
  },

  /** 发起申诉 */
  createDispute(data: {
    recordId: number
    disputeType: string
    reason: string
    statement?: string
    evidence?: string[]
  }) {
    return request<DisputeItem>({ url: '/governance/disputes', method: 'post', data })
  },

  /** 我的争议（作为当事人 + 待我仲裁） */
  myDisputes() {
    return request<{ asParty: DisputeItem[]; toArbitrate: DisputeItem[] }>({
      url: '/governance/disputes/mine',
      method: 'get'
    })
  },

  /** 争议详情（含卷宗） */
  disputeDetail(id: number) {
    return request<DisputeItem & { caseFile: CaseFile | null }>({
      url: `/governance/disputes/${id}`,
      method: 'get'
    })
  },

  /** 被申诉人提交答辩 */
  submitDefense(id: number, defense: string) {
    return request<DisputeItem>({
      url: `/governance/disputes/${id}/defense`,
      method: 'post',
      data: { defense }
    })
  },

  /** 提交仲裁投票（匿名表决） */
  vote(id: number, data: ArbitrationVote) {
    return request<DisputeItem>({
      url: `/governance/disputes/${id}/vote`,
      method: 'post',
      data
    })
  },

  /** 审计日志（管理员视角，含不公示项） */
  audits(params?: { targetId?: string; action?: string; limit?: number }) {
    return request<GovernanceLog[]>({ url: '/governance/audits', method: 'get', params })
  }
}

/** 争议类型选项（与后端 DisputeType 枚举一致） */
export const DISPUTE_TYPES = [
  { code: 'NO_SHOW', label: '未履约', desc: '对方接受邀约后不参与协作、长期失联' },
  { code: 'QUALITY', label: '交付质量', desc: '交付成果与约定严重不符、需要大量返工' },
  { code: 'EVAL_UNFAIR', label: '评价不公', desc: '评价明显偏离事实，涉嫌恶意差评或刷好评' },
  { code: 'PLAGIARISM', label: '成果抄袭', desc: '交付成果非本人完成，或抄袭他人作品' },
  { code: 'OTHER', label: '其他', desc: '不属于上述类型，由仲裁委员根据卷宗判断' }
] as const

/** 投票选项 */
export const VOTE_OPTIONS = [
  { value: 'APPLICANT', label: '支持申诉人', desc: '认为被申诉人确实存在所诉问题' },
  { value: 'RESPONDENT', label: '支持被申诉人', desc: '认为申诉主张不成立' },
  { value: 'ABSTAIN', label: '弃权', desc: '事实不清或存在利益关联，不参与判断' }
] as const
