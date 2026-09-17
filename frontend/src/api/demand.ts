import { request } from './request'
import type {
  DemandCreatePayload,
  DemandInterest,
  DemandMeta,
  Exchange,
  ExchangeApplyPayload,
  ExchangeStatusMeta,
  MarketCard,
  PageResult
} from './types'

/**
 * 供需集市与交换接口（模块 M4）。
 *
 * 鉴权说明：
 *   GET /demands、GET /demands/{id}  —— 匿名可访问
 *   发布 / 修改 / 邀约 / 交换流程      —— 需登录
 */
export const demandApi = {
  /** 集市信息流（GET /api/demands） */
  feed(params: {
    keyword?: string
    categoryL1?: string
    skillId?: number
    status?: string
    sort?: 'MATCH' | 'LATEST' | 'HOT'
    onlyHighMatch?: boolean
    mine?: boolean
    page?: number
    size?: number
  }) {
    return request<PageResult<MarketCard>>({ url: '/demands', method: 'get', params })
  },

  /** 卡片详情（GET /api/demands/{id}） */
  detail(id: number) {
    return request<MarketCard>({ url: `/demands/${id}`, method: 'get' })
  },

  /** 我发布的卡片（GET /api/demands/mine） */
  mine() {
    return request<MarketCard[]>({ url: '/demands/mine', method: 'get' })
  },

  /** 发布需求卡片（POST /api/demands） */
  create(payload: DemandCreatePayload) {
    return request<MarketCard>({ url: '/demands', method: 'post', data: payload })
  },

  /** 修改卡片（PUT /api/demands/{id}） */
  update(id: number, payload: Partial<DemandCreatePayload>) {
    return request<MarketCard>({ url: `/demands/${id}`, method: 'put', data: payload })
  },

  /** 关闭卡片（DELETE /api/demands/{id}） */
  close(id: number) {
    return request<void>({ url: `/demands/${id}`, method: 'delete' })
  },

  /** 我收到的邀约（GET /api/demands/interests/received） */
  receivedInterests() {
    return request<DemandInterest[]>({ url: '/demands/interests/received', method: 'get' })
  },

  /** 我发出的邀约（GET /api/demands/interests/sent） */
  sentInterests() {
    return request<DemandInterest[]>({ url: '/demands/interests/sent', method: 'get' })
  }
}

/** 技能交换接口 */
export const exchangeApi = {
  /** 发起交换邀约（POST /api/exchanges/apply） */
  apply(payload: ExchangeApplyPayload) {
    return request<{
      interestId: number
      recordId: number
      recordNo: string
      status: string
      message: string
    }>({ url: '/exchanges/apply', method: 'post', data: payload })
  },

  /** 接受邀约（POST /api/exchanges/interests/{id}/accept） */
  accept(interestId: number) {
    return request<{
      interestId: number
      accepted: boolean
      recordId: number
      recordNo: string
      status: string
      workspaceReady: boolean
      message: string
    }>({ url: `/exchanges/interests/${interestId}/accept`, method: 'post' })
  },

  /** 拒绝邀约（POST /api/exchanges/interests/{id}/reject） */
  reject(interestId: number, reason?: string) {
    return request<{ accepted: boolean; message: string }>({
      url: `/exchanges/interests/${interestId}/reject`,
      method: 'post',
      params: { reason }
    })
  },

  /** 撤回自己发起的邀约（POST /api/exchanges/interests/{id}/withdraw） */
  withdraw(interestId: number) {
    return request<void>({ url: `/exchanges/interests/${interestId}/withdraw`, method: 'post' })
  },

  /** 推进状态（POST /api/exchanges/{id}/status） */
  changeStatus(recordId: number, target: string, actualHours?: number) {
    return request<Exchange>({
      url: `/exchanges/${recordId}/status`,
      method: 'post',
      params: { target, actualHours }
    })
  },

  /** 我的交换列表（GET /api/exchanges） */
  myExchanges(status?: string) {
    return request<Exchange[]>({ url: '/exchanges', method: 'get', params: { status } })
  },

  /** 交换详情（GET /api/exchanges/{id}） */
  detail(recordId: number) {
    return request<Exchange>({ url: `/exchanges/${recordId}`, method: 'get' })
  }
}

/** 业务字典接口（枚举与阈值，避免前端硬编码） */
export const metaApi = {
  demandMeta() {
    return request<DemandMeta>({ url: '/meta/demands', method: 'get' })
  },
  exchangeStatusMeta() {
    return request<ExchangeStatusMeta[]>({ url: '/meta/exchange-status', method: 'get' })
  }
}
