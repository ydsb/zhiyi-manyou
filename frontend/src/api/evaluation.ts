import { request } from './request'

export type EvaluationScoreKey =
  | 'task_completion'
  | 'delivery_quality'
  | 'communication'
  | 'cross_discipline'

export interface EvaluationRecord {
  id: number
  recordId: number
  fromSno?: string
  fromName?: string
  toSno?: string
  toName?: string
  anonymous?: boolean
  mine?: boolean
  scoreVisible?: boolean
  dimScores?: Record<string, number>
  totalScore?: number
  comment?: string
  evidenceLevel?: string
  evidenceLevelLabel?: string
  evidenceDescription?: string
  recordHash?: string
  verifyCode?: string
  sealedAt?: string
  createdAt?: string
  timeoutScored?: boolean
  disputed?: boolean
  auditStatus?: string
  auditRemark?: string
}

export interface EvaluationStatus {
  recordId: number
  recordNo?: string
  title?: string
  status?: string
  statusLabel?: string
  peerSno?: string
  peerName?: string
  peerProvideSkill?: string
  mySubmitted?: boolean
  peerSubmitted?: boolean
  bothSubmitted?: boolean
  canSubmit?: boolean
  peerScoreVisible?: boolean
  myEvaluation?: EvaluationRecord
  peerEvaluation?: EvaluationRecord
  myTotalScore?: number
  peerTotalScore?: number
  pendingEvalAt?: string
  pendingDays?: number
  hint?: string
  processDigest?: string
  processMetrics?: unknown[]
}

export interface EvaluationSubmitPayload {
  recordId: number
  dimScores: Record<EvaluationScoreKey, number>
  comment?: string
  anonymous?: boolean
}

export const evaluationApi = {
  /** 某场交换的互评进度与可见评分 */
  status(recordId: number) {
    return request<EvaluationStatus>({
      url: `/evaluations/records/${recordId}`,
      method: 'get'
    })
  },

  /** 提交当前用户对交换对方的评价 */
  submit(data: EvaluationSubmitPayload) {
    return request<EvaluationStatus>({
      url: '/evaluations',
      method: 'post',
      data
    })
  }
}
