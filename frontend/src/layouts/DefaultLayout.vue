<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { notificationApi } from '@/api/workspace'
import type { NotificationItem } from '@/api/types'

/**
 * 主布局：左侧导航 + 顶部栏（含通知中心） + 内容区。
 */
const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

/* ---------------- 通知中心（FR-M5-05） ---------------- */
const notifications = ref<NotificationItem[]>([])
const unreadCount = ref(0)

async function loadUnread() {
  try {
    const r = await notificationApi.unreadCount()
    unreadCount.value = r.count
  } catch {
    // 未登录或网络异常时不显示红点
  }
}

async function loadNotifications() {
  try {
    notifications.value = await notificationApi.list({ limit: 20 })
    await loadUnread()
  } catch {
    // 已提示
  }
}

async function openNotification(n: NotificationItem) {
  if (!n.read) {
    try {
      await notificationApi.markRead(n.id)
      n.read = true
      await loadUnread()
    } catch {
      // 已提示
    }
  }
  if (n.linkPath) {
    router.push(n.linkPath)
  }
}

async function readAll() {
  try {
    await notificationApi.markAllRead()
    notifications.value = notifications.value.map((n) => ({ ...n, read: true }))
    unreadCount.value = 0
    ElMessage.success('已全部标记为已读')
  } catch {
    // 已提示
  }
}

function shortTime(t?: string) {
  if (!t) return ''
  return t.slice(5, 16)
}

interface NavItem {
  name: string
  label: string
  icon: string
  desc: string
}

const navItems: NavItem[] = [
  { name: 'Dashboard', label: '数字档案', icon: '📊', desc: '能力雷达图与成长轨迹' },
  { name: 'Market', label: '供需集市', icon: '🧭', desc: '技能需求与供给卡片' },
  { name: 'Skills', label: '技能图谱', icon: '🕸️', desc: '跨学科标签与关系网络' },
  { name: 'Exchanges', label: '我的交换', icon: '🔁', desc: '以技易技与协作工作台' },
  { name: 'Governance', label: '信用与治理', icon: '⚖️', desc: '信用明细、争议申诉与仲裁公示' },
  { name: 'Admin', label: '管理后台', icon: '🛠️', desc: '用户、审核队列与数据看板' },
  { name: 'Profile', label: '个人中心', icon: '🧱', desc: '资料与账号设置' }
]

const activeName = computed(() => route.name as string)

/**
 * 可见导航项：管理后台只对 ADMIN 显示。
 *
 * 这里只是隐藏入口 —— 真正的权限由后端 SecurityConfig 强制（/api/admin/** 需 ADMIN），
 * 前端隐藏只是避免普通用户点了看到 403。
 */
const visibleNavItems = computed(() =>
  navItems.filter((i) => i.name !== 'Admin' || auth.user?.role === 'ADMIN')
)

async function handleLogout() {
  try {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '退出',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch {
    return
  }
  await auth.logout()
  ElMessage.success('已退出登录')
  router.push({ name: 'Login' })
}

onMounted(() => {
  if (auth.isLoggedIn) {
    loadUnread()
  }
})
</script>

<template>
  <div class="layout">
    <!-- 左侧导航 -->
    <aside class="layout__aside">
      <div class="brand">
        <span class="brand__mark" aria-hidden="true"></span>
        <div class="brand__text">
          <div class="brand__name">知驿·漫游</div>
          <div class="brand__sub">跨学科技能交换</div>
        </div>
      </div>

      <nav class="nav">
        <router-link
          v-for="item in visibleNavItems"
          :key="item.name"
          class="nav__item"
          :class="{ 'nav__item--active': activeName === item.name }"
          :to="{ name: item.name }"
        >
          <span class="nav__icon" aria-hidden="true">{{ item.icon }}</span>
          <span class="nav__body">
            <span class="nav__label">{{ item.label }}</span>
            <span class="nav__desc">{{ item.desc }}</span>
          </span>
        </router-link>
      </nav>

      <div class="aside-footer">
        <div class="pixel-strip" aria-hidden="true">
          <i v-for="n in 12" :key="n" class="zy-pixel-block" :style="{ background: n % 3 === 0 ? 'var(--zy-accent)' : 'var(--zy-primary-light)' }"></i>
        </div>
        <div class="aside-footer__text">西北大学 · 大创项目</div>
      </div>
    </aside>

    <!-- 右侧主体 -->
    <div class="layout__main">
      <header class="topbar">
        <div class="topbar__left">
          <h1 class="topbar__title">{{ route.meta.title || '知驿·漫游' }}</h1>
        </div>

        <div class="topbar__right">
          <el-tag v-if="auth.user?.college" size="small" type="info" effect="plain">
            {{ auth.user.college }}
          </el-tag>
          <el-tag v-if="auth.user?.creditScore != null" size="small" type="success" effect="plain">
            信用 {{ auth.user.creditScore }}
          </el-tag>

          <!-- 通知中心（FR-M5-05） -->
          <el-popover placement="bottom-end" :width="380" trigger="click" @show="loadNotifications">
            <template #reference>
              <el-badge :value="unreadCount" :hidden="unreadCount === 0" class="notify-badge">
                <span class="notify-btn" title="通知中心">🔔</span>
              </el-badge>
            </template>

            <div class="notify">
              <div class="notify__head">
                <span class="notify__title">通知中心</span>
                <el-link v-if="unreadCount > 0" type="primary" underline="never" @click="readAll">
                  全部已读
                </el-link>
              </div>
              <div v-if="notifications.length === 0" class="notify__empty">暂无通知</div>
              <div
                v-for="n in notifications"
                :key="n.id"
                class="notify__item"
                :class="{ 'notify__item--unread': !n.read }"
                @click="openNotification(n)"
              >
                <div class="notify__item-head">
                  <el-tag size="small" effect="plain">{{ n.typeLabel }}</el-tag>
                  <span class="notify__time">{{ shortTime(n.createdAt) }}</span>
                </div>
                <div class="notify__item-title">{{ n.title }}</div>
                <div v-if="n.content" class="notify__item-content">{{ n.content }}</div>
              </div>
            </div>
          </el-popover>

          <el-dropdown trigger="click">
            <span class="user-chip">
              <span class="user-chip__avatar">{{ auth.displayName.slice(0, 1) }}</span>
              <span class="user-chip__name">{{ auth.displayName }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="router.push({ name: 'Profile' })">个人中心</el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <main class="content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
    </div>
  </div>
</template>

<style scoped>
.layout {
  display: flex;
  min-height: 100vh;
  background: transparent;
}

/* ------------------------------ 侧栏 ------------------------------ */
.layout__aside {
  display: flex;
  flex-direction: column;
  width: 252px;
  flex-shrink: 0;
  padding: 22px 16px 18px;
  background: rgba(255, 255, 255, 0.82);
  border-right: 1px solid rgba(219, 233, 231, 0.9);
  box-shadow: 8px 0 30px rgba(24, 71, 77, 0.035);
  backdrop-filter: blur(14px);
}

.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 2px 8px 24px;
}

.brand__mark {
  width: 36px;
  height: 36px;
  border-radius: 12px;
  background:
    linear-gradient(135deg, var(--zy-primary) 0%, var(--zy-primary-dark) 100%);
  box-shadow: 4px 4px 0 rgba(35, 124, 120, 0.15), 0 8px 18px rgba(35, 124, 120, 0.18);
  position: relative;
}

.brand__mark::after {
  content: '';
  position: absolute;
  inset: 8px;
  background: var(--zy-accent);
  border-radius: 1px;
}

.brand__name {
  font-size: 16px;
  font-weight: 800;
  letter-spacing: 0.04em;
}

.brand__sub {
  font-size: 11px;
  color: var(--zy-text-secondary);
}

.nav {
  display: flex;
  flex-direction: column;
  gap: 6px;
  flex: 1;
}

.nav__item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 12px;
  border-radius: 12px;
  color: var(--zy-text-regular);
  transition: all 0.16s ease;
  border: 1px solid transparent;
}

.nav__item:hover {
  background: rgba(71, 166, 155, 0.08);
  border-color: rgba(71, 166, 155, 0.12);
  color: var(--zy-primary);
}

.nav__item--active {
  background: linear-gradient(100deg, rgba(71, 166, 155, 0.16), rgba(71, 166, 155, 0.04));
  border-color: rgba(71, 166, 155, 0.2);
  box-shadow: inset 3px 0 0 var(--zy-primary), 0 5px 12px rgba(35, 124, 120, 0.06);
  color: var(--zy-primary);
}

.nav__icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
}

.nav__body {
  display: flex;
  flex-direction: column;
  line-height: 1.25;
}

.nav__label {
  font-size: 13.5px;
  font-weight: 500;
}

.nav__desc {
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
}

.aside-footer {
  padding-top: 12px;
  border-top: 1px solid var(--zy-border-light);
}

.pixel-strip {
  display: flex;
  gap: 3px;
  margin-bottom: 8px;
}

.aside-footer__text {
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

/* ------------------------------ 顶栏 ------------------------------ */
.layout__main {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 70px;
  padding: 0 32px;
  background: rgba(255, 255, 255, 0.72);
  border-bottom: 1px solid rgba(219, 233, 231, 0.9);
  position: sticky;
  top: 0;
  z-index: 10;
  backdrop-filter: blur(14px);
}

.topbar__title {
  margin: 0;
  font-size: 18px;
  font-weight: 750;
  letter-spacing: -0.02em;
}

.topbar__right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.user-chip {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 4px 10px 4px 4px;
  border-radius: 999px;
  background: rgba(243, 248, 247, 0.92);
  border: 1px solid var(--zy-border-light);
  cursor: pointer;
  outline: none;
}

.user-chip__avatar {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: var(--zy-primary);
  color: #fff;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-chip__name {
  font-size: 13px;
  color: var(--zy-text-regular);
}

/* ------------------------------ 通知中心 ------------------------------ */
.notify-badge {
  display: flex;
  align-items: center;
}

.notify-btn {
  font-size: 17px;
  line-height: 1;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  border-radius: 11px;
  background: rgba(243, 248, 247, 0.92);
  border: 1px solid var(--zy-border-light);
}

.notify {
  max-height: 420px;
  overflow-y: auto;
}

.notify__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 8px;
  margin-bottom: 6px;
  border-bottom: 1px solid var(--zy-border);
}

.notify__title {
  font-size: 13.5px;
  font-weight: 600;
}

.notify__empty {
  padding: 22px 0;
  text-align: center;
  font-size: 12.5px;
  color: var(--zy-text-placeholder);
}

.notify__item {
  padding: 9px 10px;
  border-radius: var(--zy-radius);
  cursor: pointer;
  transition: background 0.15s ease;
}

.notify__item:hover {
  background: var(--zy-bg-page);
}

.notify__item--unread {
  background: rgba(47, 125, 143, 0.06);
}

.notify__item-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.notify__time {
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
}

.notify__item-title {
  margin-top: 4px;
  font-size: 12.5px;
  font-weight: 600;
}

.notify__item-content {
  margin-top: 2px;
  font-size: 11.5px;
  line-height: 1.6;
  color: var(--zy-text-secondary);
}

.content {
  flex: 1;
  min-width: 0;
  overflow-x: hidden;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.18s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

@media (max-width: 900px) {
  .layout__aside {
    width: 76px;
    padding: 14px 8px;
  }
  .brand__text,
  .nav__body,
  .aside-footer__text {
    display: none;
  }
  .nav__item {
    justify-content: center;
  }
}

@media (max-width: 640px) {
  .layout__aside {
    position: fixed;
    z-index: 30;
    inset: auto 0 0;
    width: auto;
    height: calc(66px + env(safe-area-inset-bottom));
    padding: 5px 8px calc(5px + env(safe-area-inset-bottom));
    border-right: 0;
    border-top: 1px solid var(--zy-border);
    box-shadow: 0 -8px 24px rgba(24, 71, 77, 0.08);
  }

  .brand,
  .aside-footer {
    display: none;
  }

  .nav {
    flex-direction: row;
    align-items: stretch;
    justify-content: space-around;
    gap: 2px;
    overflow-x: auto;
  }

  .nav__item {
    flex: 1 0 52px;
    min-width: 48px;
    flex-direction: column;
    justify-content: center;
    gap: 1px;
    padding: 3px 2px;
    border-radius: 10px;
  }

  .nav__icon {
    font-size: 17px;
    line-height: 1.15;
  }

  .nav__body {
    display: flex;
  }

  .nav__label {
    font-size: 9px;
    line-height: 1.2;
    white-space: nowrap;
  }

  .nav__desc {
    display: none;
  }

  .topbar {
    min-height: 60px;
    padding: 0 16px;
  }

  .topbar__right {
    gap: 6px;
  }

  .user-chip__name {
    display: none;
  }

  .content {
    padding-bottom: calc(70px + env(safe-area-inset-bottom));
  }
}
</style>
