// @vitest-environment jsdom
import axios, { type AxiosAdapter, type InternalAxiosRequestConfig } from 'axios'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import http, { request, tokenStorage } from './request'

vi.mock('element-plus', () => ({
  ElMessage: {
    error: vi.fn(),
    warning: vi.fn()
  }
}))

type AdapterConfig = InternalAxiosRequestConfig

function unauthorized(config: AdapterConfig) {
  return Promise.reject({
    config,
    response: { status: 401, data: { code: 2001, message: 'token expired' } }
  })
}

function success(config: AdapterConfig, data: unknown = { value: 'ok' }) {
  return Promise.resolve({
    config,
    data: { code: 0, message: 'ok', data },
    headers: {},
    status: 200,
    statusText: 'OK'
  })
}

describe('request token refresh', () => {
  beforeEach(() => {
    tokenStorage.clear()
    vi.restoreAllMocks()
    http.defaults.adapter = vi.fn() as unknown as AxiosAdapter
  })

  afterEach(() => {
    tokenStorage.clear()
  })

  it('refreshes an expired access token and retries the original request once', async () => {
    tokenStorage.set('expired-access', 'refresh-token')
    let calls = 0
    http.defaults.adapter = (async (config: AdapterConfig) => {
      calls += 1
      return calls === 1 ? unauthorized(config) : success(config)
    }) as unknown as AxiosAdapter
    vi.spyOn(axios, 'post').mockResolvedValue({
      data: { code: 0, data: { accessToken: 'new-access', refreshToken: 'new-refresh' } }
    } as never)

    await expect(request<{ value: string }>({ url: '/protected', method: 'get' }))
      .resolves.toEqual({ value: 'ok' })
    expect(calls).toBe(2)
    expect(tokenStorage.getAccess()).toBe('new-access')
    expect(tokenStorage.getRefresh()).toBe('new-refresh')
  })

  it('shares one refresh request when several requests expire together', async () => {
    tokenStorage.set('expired-access', 'refresh-token')
    let calls = 0
    http.defaults.adapter = (async (config: AdapterConfig) => {
      calls += 1
      return calls <= 2 ? unauthorized(config) : success(config, { value: calls })
    }) as unknown as AxiosAdapter
    let release!: (value: unknown) => void
    const refreshResult = new Promise((resolve) => { release = resolve })
    const refresh = vi.spyOn(axios, 'post').mockReturnValue(refreshResult as never)

    const first = request({ url: '/one', method: 'get' })
    const second = request({ url: '/two', method: 'get' })
    await vi.waitFor(() => expect(refresh).toHaveBeenCalledOnce())
    release({ data: { code: 0, data: { accessToken: 'new-access', refreshToken: 'new-refresh' } } })

    await expect(Promise.all([first, second])).resolves.toEqual([{ value: 3 }, { value: 4 }])
    expect(refresh).toHaveBeenCalledOnce()
  })

  it('clears the session when the refresh token is rejected', async () => {
    tokenStorage.set('expired-access', 'bad-refresh')
    http.defaults.adapter = (async (config: AdapterConfig) => unauthorized(config)) as unknown as AxiosAdapter
    vi.spyOn(axios, 'post').mockRejectedValue(new Error('refresh failed'))
    vi.spyOn(globalThis, 'setTimeout').mockImplementation(() => 0 as never)

    await expect(request({ url: '/protected', method: 'get' })).rejects.toMatchObject({ code: 2001 })
    expect(tokenStorage.getAccess()).toBeNull()
    expect(tokenStorage.getRefresh()).toBeNull()
  })

  it('does not recursively refresh authentication endpoints', async () => {
    tokenStorage.set('expired-access', 'refresh-token')
    http.defaults.adapter = (async (config: AdapterConfig) => unauthorized(config)) as unknown as AxiosAdapter
    const refresh = vi.spyOn(axios, 'post')
    vi.spyOn(globalThis, 'setTimeout').mockImplementation(() => 0 as never)

    await expect(request({ url: 'auth/login', method: 'post', data: {} }))
      .rejects.toMatchObject({ code: 2001 })
    expect(refresh).not.toHaveBeenCalled()
  })
})
