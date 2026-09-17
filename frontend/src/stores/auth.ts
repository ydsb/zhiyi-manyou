import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { authApi } from '@/api/auth'
import { tokenStorage } from '@/api/request'
import type { LoginRequest, RegisterRequest, UserInfo } from '@/api/types'

/**
 * 认证状态：令牌、当前用户、首次登录标记。
 */
export const useAuthStore = defineStore('auth', () => {
  const user = ref<UserInfo | null>(null)
  const accessToken = ref<string | null>(tokenStorage.getAccess())
  /** 首次登录 —— 为 true 时进入「新手漫游导引」 */
  const firstLogin = ref(false)
  const loading = ref(false)

  const isLoggedIn = computed(() => !!accessToken.value)
  const isAdmin = computed(() => user.value?.role === 'ADMIN')
  const displayName = computed(() => user.value?.displayName || user.value?.sno || '访客')

  function setSession(result: {
    accessToken: string
    refreshToken: string
    user: UserInfo
    firstLogin?: boolean
  }) {
    tokenStorage.set(result.accessToken, result.refreshToken)
    accessToken.value = result.accessToken
    user.value = result.user
    firstLogin.value = result.firstLogin ?? false
  }

  async function login(payload: LoginRequest) {
    loading.value = true
    try {
      const result = await authApi.login(payload)
      setSession(result)
      return result
    } finally {
      loading.value = false
    }
  }

  async function register(payload: RegisterRequest) {
    loading.value = true
    try {
      const result = await authApi.register(payload)
      setSession(result)
      return result
    } finally {
      loading.value = false
    }
  }

  /** 拉取当前用户，用于刷新页面后恢复会话 */
  async function fetchUser() {
    if (!accessToken.value) return null
    const info = await authApi.me()
    user.value = info
    return info
  }

  async function logout() {
    try {
      if (accessToken.value) {
        await authApi.logout()
      }
    } catch {
      // 退出失败不阻塞本地清理
    } finally {
      tokenStorage.clear()
      accessToken.value = null
      user.value = null
      firstLogin.value = false
    }
  }

  function completeOnboarding() {
    firstLogin.value = false
  }

  return {
    user,
    accessToken,
    firstLogin,
    loading,
    isLoggedIn,
    isAdmin,
    displayName,
    setSession,
    login,
    register,
    fetchUser,
    logout,
    completeOnboarding
  }
})
