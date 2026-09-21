import { request } from './request'
import type {
  CollabEvent,
  CollabFile,
  CollabMessage,
  CollabTask,
  NotificationItem,
  ProcessSummary,
  Workspace
} from './types'

/**
 * 协作工作台接口（模块 M5）。
 *
 * 访问控制由服务端强制：只有交换参与方（及管理员）能读写，
 * 非参与方访问会返回业务码 3014。
 */
export const workspaceApi = {
  /** 工作台总览：任务、文件、留言、时间轴、过程指标一次返回（GET /api/workspaces/{recordId}） */
  overview(recordId: number) {
    return request<Workspace>({ url: `/workspaces/${recordId}`, method: 'get' })
  },

  /* ---------------- 任务（FR-M5-02） ---------------- */

  listTasks(recordId: number) {
    return request<CollabTask[]>({ url: `/workspaces/${recordId}/tasks`, method: 'get' })
  },

  createTask(recordId: number, data: {
    title: string
    description?: string
    assigneeSno?: string
    deadline?: string
    sortOrder?: number
  }) {
    return request<CollabTask>({ url: `/workspaces/${recordId}/tasks`, method: 'post', data })
  },

  /** 修改任务；把 status 置为 DONE 即为打卡完成 */
  updateTask(recordId: number, taskId: number, data: {
    title?: string
    description?: string
    assigneeSno?: string
    deadline?: string
    status?: 'TODO' | 'DOING' | 'DONE'
    evidenceUrl?: string
    sortOrder?: number
  }) {
    return request<CollabTask>({ url: `/workspaces/${recordId}/tasks/${taskId}`, method: 'put', data })
  },

  deleteTask(recordId: number, taskId: number) {
    return request<void>({ url: `/workspaces/${recordId}/tasks/${taskId}`, method: 'delete' })
  },

  /**
   * 确认阶段性成果（FR-M5-08）。
   *
   * 打卡（`status=DONE`）只表示"某人宣称完成"，本接口才是"协作方认可"。
   * 打卡者不能确认自己；是否有权确认由服务端判定并下发给 `canConfirm`。
   */
  confirmTask(recordId: number, taskId: number, remark?: string) {
    return request<CollabTask>({
      url: `/workspaces/${recordId}/tasks/${taskId}/confirm`,
      method: 'post',
      data: { remark }
    })
  },

  /* ---------------- 文件（FR-M5-03） ---------------- */

  /** 不传 groupKey → 各文件最新版；传 groupKey → 该文件全部历史版本 */
  listFiles(recordId: number, groupKey?: string) {
    return request<CollabFile[]>({
      url: `/workspaces/${recordId}/files`,
      method: 'get',
      params: { groupKey }
    })
  },

  /** 上传文件（multipart）。同一 groupKey 重复上传自动生成新版本 */
  upload(recordId: number, file: File, options?: { groupKey?: string; taskId?: number; remark?: string }) {
    const form = new FormData()
    form.append('file', file)
    if (options?.groupKey) form.append('groupKey', options.groupKey)
    if (options?.taskId != null) form.append('taskId', String(options.taskId))
    if (options?.remark) form.append('remark', options.remark)
    return request<CollabFile>({
      url: `/workspaces/${recordId}/files`,
      method: 'post',
      data: form,
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },

  /* ---------------- 留言（FR-M5-07） ---------------- */

  listMessages(recordId: number, limit = 50) {
    return request<CollabMessage[]>({
      url: `/workspaces/${recordId}/messages`,
      method: 'get',
      params: { limit }
    })
  },

  sendMessage(recordId: number, data: { content?: string; fileId?: number }) {
    return request<CollabMessage>({ url: `/workspaces/${recordId}/messages`, method: 'post', data })
  },

  /* ---------------- 时间轴（FR-M5-04） ---------------- */

  timeline(recordId: number, limit = 100) {
    return request<CollabEvent[]>({
      url: `/workspaces/${recordId}/timeline`,
      method: 'get',
      params: { limit }
    })
  },

  /* ---------------- 过程性指标（FR-M5-06） ---------------- */

  processSummary(recordId: number) {
    return request<ProcessSummary>({
      url: `/workspaces/${recordId}/process-summary`,
      method: 'get'
    })
  }
}

/** 通知中心接口（FR-M5-05） */
export const notificationApi = {
  list(params?: { onlyUnread?: boolean; limit?: number }) {
    return request<NotificationItem[]>({ url: '/notifications', method: 'get', params })
  },

  unreadCount() {
    return request<{ count: number }>({ url: '/notifications/unread-count', method: 'get' })
  },

  markRead(id: number) {
    return request<void>({ url: `/notifications/${id}/read`, method: 'post' })
  },

  markAllRead() {
    return request<{ affected: number }>({ url: '/notifications/read-all', method: 'post' })
  }
}

/**
 * 下载协作文件。
 *
 * 不能用普通的 axios 请求：响应是二进制流且带 Content-Disposition，
 * 需要手动取 blob 并触发浏览器下载。
 *
 * @param fileId   文件 ID
 * @param fileName 保存的文件名
 */
export async function downloadCollabFile(fileId: number, fileName: string) {
  const token = localStorage.getItem('zhiyi.accessToken')
  const res = await fetch(`/api/workspaces/files/${fileId}/download`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  })
  if (!res.ok) {
    throw new Error(`下载失败（HTTP ${res.status}）`)
  }
  const blob = await res.blob()
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = fileName
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}
