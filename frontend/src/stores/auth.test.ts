import { createPinia, disposePinia, setActivePinia, type Pinia } from 'pinia'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { authApi } from '@/api/auth'
import { tokenStorage } from '@/api/request'
import { useAuthStore } from './auth'

vi.mock('element-plus', () => ({ ElMessage: { error: vi.fn(), warning: vi.fn() } }))
vi.mock('@/api/auth', () => ({ authApi: { me: vi.fn(), logout: vi.fn() } }))

let pinia: Pinia
const user = { sno: '20240001', displayName: '同学', role: 'USER' as const }

beforeEach(() => {
  vi.resetAllMocks()
  tokenStorage.clear()
  pinia = createPinia()
  setActivePinia(pinia)
})

afterEach(() => {
  disposePinia(pinia)
  tokenStorage.clear()
})

describe('authentication state synchronization', () => {
  it('updates the active access token when the request layer refreshes it', () => {
    const auth = useAuthStore()
    auth.setSession({ accessToken: 'old', refreshToken: 'refresh', user })
    tokenStorage.set('new', 'rotated-refresh')

    expect(auth.accessToken).toBe('new')
    expect(auth.user).toEqual(user)
    expect(auth.isLoggedIn).toBe(true)
  })

  it('immediately clears a loaded user and permissions when the session expires', () => {
    const auth = useAuthStore()
    auth.setSession({ accessToken: 'old', refreshToken: 'refresh', user: { ...user, role: 'ADMIN' }, firstLogin: true })
    tokenStorage.clear()

    expect(auth.accessToken).toBeNull()
    expect(auth.user).toBeNull()
    expect(auth.firstLogin).toBe(false)
    expect(auth.isLoggedIn).toBe(false)
    expect(auth.isAdmin).toBe(false)
  })

  it('keeps the session on a temporary user-info network error', async () => {
    const auth = useAuthStore()
    auth.setSession({ accessToken: 'valid', refreshToken: 'refresh', user })
    vi.mocked(authApi.me).mockRejectedValue(new Error('network unavailable'))

    await expect(auth.fetchUser()).rejects.toThrow('network unavailable')
    expect(auth.isLoggedIn).toBe(true)
    expect(auth.user).toEqual(user)
  })
})
