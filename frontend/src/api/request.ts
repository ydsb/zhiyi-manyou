import axios, { type AxiosInstance, type AxiosRequestConfig, type AxiosResponse } from 'axios'
import { ElMessage } from 'element-plus'

/**
 * 统一响应体 —— 与后端 ApiResponse 对应。
 * code 为 0 表示成功；非 0 表示失败（HTTP 状态码此时通常仍是 200）。
 */
export interface ApiResult<T = unknown> {
  code: number
  message: string
  data: T
  traceId?: string
  timestamp?: string
}

/** 业务错误对象 */
export class ApiError extends Error {
  code: number
  traceId?: string

  constructor(code: number, message: string, traceId?: string) {
    super(message)
    this.name = 'ApiError'
    this.code = code
    this.traceId = traceId
  }
}

const TOKEN_KEY = 'zhiyi.accessToken'
const REFRESH_KEY = 'zhiyi.refreshToken'
const tokenListeners = new Set<(access: string | null) => void>()

export const tokenStorage = {
  getAccess: () => localStorage.getItem(TOKEN_KEY),
  getRefresh: () => localStorage.getItem(REFRESH_KEY),
  set(access: string, refresh: string) {
    localStorage.setItem(TOKEN_KEY, access)
    localStorage.setItem(REFRESH_KEY, refresh)
    tokenListeners.forEach((listener) => listener(access))
  },
  clear() {
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(REFRESH_KEY)
    tokenListeners.forEach((listener) => listener(null))
  },
  subscribe(listener: (access: string | null) => void) {
    tokenListeners.add(listener)
    return () => { tokenListeners.delete(listener) }
  }
}

const http: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 20000,
  headers: { 'Content-Type': 'application/json;charset=utf-8' }
})

type RetryableRequestConfig = AxiosRequestConfig & { _tokenRefreshRetried?: boolean }
let refreshing: Promise<string | null> | null = null

function isAuthEndpoint(url?: string): boolean {
  return typeof url === 'string' && /(?:^|\/)auth\/(login|register|refresh|logout)(?:$|\?)/.test(url)
}

async function refreshAccessToken(): Promise<string | null> {
  const refreshToken = tokenStorage.getRefresh()
  if (!refreshToken) return null
  if (!refreshing) {
    refreshing = axios.post<ApiResult<{ accessToken: string; refreshToken: string }>>(
      `${http.defaults.baseURL || ''}/auth/refresh`,
      { refreshToken },
      { headers: { 'Content-Type': 'application/json;charset=utf-8' } }
    ).then(({ data }) => {
      if (data?.code !== 0 || !data.data?.accessToken || !data.data?.refreshToken) return null
      tokenStorage.set(data.data.accessToken, data.data.refreshToken)
      return data.data.accessToken
    }).catch(() => null).finally(() => {
      refreshing = null
    })
  }
  return refreshing
}

/* ---------------- 请求拦截：注入访问令牌 ---------------- */
http.interceptors.request.use((config) => {
  const token = tokenStorage.getAccess()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

/* ---------------- 响应拦截：解包统一响应体 ---------------- */
let redirecting = false

http.interceptors.response.use(
  (response: AxiosResponse<ApiResult>) => {
    const body = response.data
    // 非 JSON 响应（如文件下载）直接返回
    if (body == null || typeof body !== 'object' || !('code' in body)) {
      return response
    }
    if (body.code === 0) {
      return response
    }
    // 业务失败
    ElMessage.error(body.message || '操作失败')
    return Promise.reject(new ApiError(body.code, body.message, body.traceId))
  },
  async (error) => {
    const status = error?.response?.status
    const body = error?.response?.data as ApiResult | undefined

    if (status === 401) {
      const original = error.config as RetryableRequestConfig | undefined
      if (original && !original._tokenRefreshRetried && !isAuthEndpoint(original.url)) {
        original._tokenRefreshRetried = true
        const accessToken = await refreshAccessToken()
        if (accessToken) {
          original.headers = original.headers || {}
          original.headers.Authorization = `Bearer ${accessToken}`
          return http.request(original)
        }
      }
      tokenStorage.clear()
      if (!redirecting) {
        redirecting = true
        ElMessage.warning(body?.message || '登录已过期，请重新登录')
        const redirect = encodeURIComponent(window.location.pathname + window.location.search)
        setTimeout(() => {
          window.location.href = `/login?redirect=${redirect}`
          redirecting = false
        }, 600)
      }
      return Promise.reject(new ApiError(2001, '未登录或登录已过期'))
    }

    if (status === 403) {
      ElMessage.error(body?.message || '无权限执行该操作')
      return Promise.reject(new ApiError(2002, '无权限'))
    }

    const message = body?.message || error?.message || '网络异常，请稍后重试'
    ElMessage.error(message)
    return Promise.reject(new ApiError(-1, message))
  }
)

/**
 * 发起请求并直接返回业务数据（已解包 data 字段）。
 */
export async function request<T>(config: AxiosRequestConfig): Promise<T> {
  const response = await http.request<ApiResult<T>>(config)
  return response.data.data
}

export default http
