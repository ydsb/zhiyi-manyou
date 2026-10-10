import { describe, expect, it, vi } from 'vitest'
import type { RouteLocationNormalized } from 'vue-router'
import { createAuthGuard, type GuardAuth } from './guard'

function route(overrides: Partial<RouteLocationNormalized> = {}): RouteLocationNormalized {
  return {
    name: 'Dashboard',
    fullPath: '/dashboard?tab=skills',
    meta: { title: '数字档案', requiresAuth: true },
    ...overrides
  } as RouteLocationNormalized
}

function setup(overrides: Partial<GuardAuth> = {}) {
  const auth: GuardAuth = {
    isLoggedIn: false,
    firstLogin: false,
    user: null,
    fetchUser: vi.fn(async () => null),
    ...overrides
  }
  const setTitle = vi.fn()
  const warn = vi.fn()
  return { auth, setTitle, warn, guard: createAuthGuard({ auth, setTitle, warn }) }
}

describe('route access policy', () => {
  it('allows unauthenticated visits to public routes', async () => {
    const { guard } = setup()
    await expect(guard(route({ meta: { title: '技能图谱', public: true } }))).resolves.toBe(true)
  })

  it('redirects unauthenticated protected visits and preserves the target', async () => {
    const { guard, setTitle } = setup()
    await expect(guard(route())).resolves.toEqual({
      name: 'Login',
      query: { redirect: '/dashboard?tab=skills' }
    })
    expect(setTitle).toHaveBeenCalledWith('数字档案 · 知驿·漫游')
  })

  it('forces first-time users through onboarding', async () => {
    const { guard } = setup({ isLoggedIn: true, firstLogin: true })
    await expect(guard(route())).resolves.toEqual({ name: 'Onboarding' })
  })

  it('redirects signed-in users away from the login page', async () => {
    const { guard } = setup({ isLoggedIn: true, user: { role: 'USER' } })
    await expect(guard(route({ name: 'Login', fullPath: '/login', meta: { public: true } })))
      .resolves.toEqual({ name: 'Dashboard' })
  })

  it('allows admins and rejects non-admin users from admin routes', async () => {
    const adminRoute = route({ meta: { title: '管理后台', requiresAuth: true, requiresAdmin: true } })
    const denied = setup({ isLoggedIn: true, user: { role: 'USER' } })
    await expect(denied.guard(adminRoute)).resolves.toEqual({ name: 'Dashboard' })
    expect(denied.warn).toHaveBeenCalledWith('该页面仅管理员可访问')

    const allowed = setup({ isLoggedIn: true, user: { role: 'ADMIN' } })
    await expect(allowed.guard(adminRoute)).resolves.toBe(true)
  })

  it('loads the current user after refresh before applying role rules', async () => {
    const auth = {
      isLoggedIn: true,
      firstLogin: false,
      user: null as { role?: string } | null,
      fetchUser: vi.fn(async () => {
        auth.user = { role: 'ADMIN' }
        return auth.user
      })
    }
    const guard = createAuthGuard({ auth, setTitle: vi.fn(), warn: vi.fn() })
    const adminRoute = route({ meta: { title: '管理后台', requiresAdmin: true } })

    await expect(guard(adminRoute)).resolves.toBe(true)
    expect(auth.fetchUser).toHaveBeenCalledOnce()
  })
})
