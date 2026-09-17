import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'

/**
 * 路由表。
 * meta.requiresAuth —— 是否需要登录
 * meta.title        —— 页面标题
 * meta.public       —— 白名单（无需登录即可访问）
 */
const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('@/layouts/DefaultLayout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/DashboardView.vue'),
        meta: { title: '数字档案', requiresAuth: true }
      },
      {
        path: 'onboarding',
        name: 'Onboarding',
        component: () => import('@/views/OnboardingView.vue'),
        meta: { title: '新手漫游导引', requiresAuth: true }
      },
      {
        path: 'skills',
        name: 'Skills',
        component: () => import('@/views/SkillsView.vue'),
        meta: { title: '技能图谱', public: true }
      },
      {
        path: 'market',
        name: 'Market',
        component: () => import('@/views/MarketView.vue'),
        meta: { title: '供需集市' }
      },
      {
        path: 'exchanges',
        name: 'Exchanges',
        component: () => import('@/views/ExchangesView.vue'),
        meta: { title: '我的交换', requiresAuth: true }
      },      {
        path: 'workspace/:recordId',
        name: 'Workspace',
        component: () => import('@/views/WorkspaceView.vue'),
        meta: { title: '协作工作台', requiresAuth: true }
      },      {
        path: 'governance',
        name: 'Governance',
        component: () => import('@/views/GovernanceView.vue'),
        meta: { title: '信用与治理', requiresAuth: true }
      },      {
        path: 'admin',
        name: 'Admin',
        component: () => import('@/views/AdminView.vue'),
        meta: { title: '管理后台', requiresAuth: true, requiresAdmin: true }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/ProfileView.vue'),
        meta: { title: '个人中心', requiresAuth: true }
      }
    ]
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { title: '登录', public: true, blank: true }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/NotFoundView.vue'),
    meta: { title: '页面不存在', public: true, blank: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

/** 全局前置守卫：登录校验 */
router.beforeEach(async (to) => {
  const auth = useAuthStore()
  document.title = to.meta.title ? `${to.meta.title} · 知驿·漫游` : '知驿·漫游'

  const requiresAuth = to.meta.requiresAuth === true
  const isPublic = to.meta.public === true

  if (!auth.isLoggedIn && requiresAuth && !isPublic) {
    return { name: 'Login', query: { redirect: to.fullPath } }
  }

  // 已登录但用户信息尚未加载（例如刷新页面）
  if (auth.isLoggedIn && !auth.user) {
    try {
      await auth.fetchUser()
    } catch {
      // 令牌失效，交给响应拦截器处理跳转
    }
  }

  // 首次登录且尚未完成导引，强制进入新手导引
  if (auth.isLoggedIn && auth.firstLogin && to.name !== 'Onboarding') {
    return { name: 'Onboarding' }
  }

  // 已登录用户访问登录页 → 回首页
  if (auth.isLoggedIn && to.name === 'Login') {
    return { name: 'Dashboard' }
  }

  /*
   * 管理后台需要 ADMIN 角色。
   *
   * 真正的权限由后端 SecurityConfig 强制（/api/admin/** 需 ADMIN，返回 403），
   * 这里的前端拦截只是体验优化：避免普通用户点了直达链接看到一堆 403 错误提示。
   * 不能因为它而误以为前端是安全边界 —— 前端校验永远只是辅助。
   */
  if (to.meta.requiresAdmin === true && auth.user?.role !== 'ADMIN') {
    ElMessage.warning('该页面仅管理员可访问')
    return { name: 'Dashboard' }
  }

  return true
})

export default router
