import type { RouteLocationNormalized, RouteLocationRaw } from 'vue-router'

export interface GuardAuth {
  isLoggedIn: boolean
  firstLogin: boolean
  user: { role?: string } | null
  fetchUser(): Promise<unknown>
}

export interface GuardDependencies {
  auth: GuardAuth
  setTitle(title: string): void
  warn(message: string): void
}

/** Create the route policy separately from router setup so its access rules can be tested. */
export function createAuthGuard({ auth, setTitle, warn }: GuardDependencies) {
  return async (to: RouteLocationNormalized): Promise<true | RouteLocationRaw> => {
    setTitle(to.meta.title ? `${String(to.meta.title)} · 知驿·漫游` : '知驿·漫游')

    const requiresAuth = to.meta.requiresAuth === true
    const isPublic = to.meta.public === true

    if (!auth.isLoggedIn && requiresAuth && !isPublic) {
      return { name: 'Login', query: { redirect: to.fullPath } }
    }

    if (auth.isLoggedIn && !auth.user) {
      try {
        await auth.fetchUser()
      } catch {
        // The request interceptor handles expired credentials.
      }
      // A failed refresh can clear the session while the guard is awaiting
      // /auth/me. Re-apply the protected-route rule using the fresh state.
      if (!auth.isLoggedIn && requiresAuth && !isPublic) {
        return { name: 'Login', query: { redirect: to.fullPath } }
      }
    }

    if (auth.isLoggedIn && auth.firstLogin && to.name !== 'Onboarding') {
      return { name: 'Onboarding' }
    }

    if (auth.isLoggedIn && to.name === 'Login') {
      return { name: 'Dashboard' }
    }

    if (to.meta.requiresAdmin === true && auth.user?.role !== 'ADMIN') {
      warn('该页面仅管理员可访问')
      return { name: 'Dashboard' }
    }

    return true
  }
}
