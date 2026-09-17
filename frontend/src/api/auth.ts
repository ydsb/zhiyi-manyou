import { request } from './request'
import type { LoginRequest, LoginResult, RegisterRequest, UserInfo } from './types'

/**
 * 认证相关接口。
 * 对应需求 FR-M1-01 ~ FR-M1-07。
 */
export const authApi = {
  /** 账号密码登录（POST /api/auth/login） */
  login(data: LoginRequest) {
    return request<LoginResult>({ url: '/auth/login', method: 'post', data })
  },

  /** 注册（POST /api/auth/register） */
  register(data: RegisterRequest) {
    return request<LoginResult>({ url: '/auth/register', method: 'post', data })
  },

  /** 刷新访问令牌（POST /api/auth/refresh） */
  refresh(refreshToken: string) {
    return request<LoginResult>({ url: '/auth/refresh', method: 'post', data: { refreshToken } })
  },

  /** 当前登录用户（GET /api/auth/me） */
  me() {
    return request<UserInfo>({ url: '/auth/me', method: 'get' })
  },

  /** 退出登录（POST /api/auth/logout） */
  logout() {
    return request<void>({ url: '/auth/logout', method: 'post' })
  }
}

/** 健康检查接口（匿名可访问） */
export const healthApi = {
  health() {
    return request<{ application: string; status: string; database: string }>({
      url: '/health',
      method: 'get'
    })
  },
  info() {
    return request<{
      name: string
      fullName: string
      version: string
      description: string
      apiPrefix: string
    }>({ url: '/health/info', method: 'get' })
  }
}
