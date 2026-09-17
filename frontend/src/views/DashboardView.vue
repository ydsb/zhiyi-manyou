<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { useAuthStore } from '@/stores/auth'
import { exchangeApi } from '@/api/demand'
import { exportReportAsPdf, profileApi } from '@/api/profile'
import type { Badge, GrowthTrend, RadarChart, WeeklyReport } from '@/api/types'

/**
 * 数字档案大屏（FR-M7-01 ~ FR-M7-08）。
 *
 * 数据来源全部为真实接口：
 *   FR-M7-01/02  雷达图    GET /api/profile/radar（实时计算，完成交换后立即变化 → AC-06）
 *   FR-M7-07     成长轨迹  GET /api/profile/growth（读月度快照序列）
 *   FR-M7-04     勋章      GET /api/profile/badges（含未解锁项与进度提示）
 *   FR-M7-05     成长周报  GET /api/profile/weekly-reports
 *   FR-M7-06/08  鉴定报告  GET /api/profile/report + 前端排版导出 PDF（带 M6 校验码）
 */
const router = useRouter()
const auth = useAuthStore()

const loading = ref(false)
const radar = ref<RadarChart | null>(null)
const badges = ref<Badge[]>([])
const growth = ref<GrowthTrend | null>(null)
const reports = ref<WeeklyReport[]>([])
const exchangeStats = ref({ ongoing: 0, completed: 0 })

const chartEl = ref<HTMLDivElement | null>(null)
const trendEl = ref<HTMLDivElement | null>(null)
let chart: echarts.ECharts | null = null
let trendChart: echarts.ECharts | null = null

/** 概览指标：全部来自真实数据 */
const stats = computed(() => [
  { label: '进行中的交换', value: exchangeStats.value.ongoing, unit: '项', hint: '以技易技进行中' },
  { label: '已完成交换', value: exchangeStats.value.completed, unit: '项', hint: '全过程留痕' },
  {
    label: '累计协作时长',
    value: radar.value?.totalHours ?? 0,
    unit: '小时',
    hint: '按实际投入统计'
  },
  {
    label: '解锁勋章',
    value: badges.value.filter((b) => b.unlocked).length + '/' + badges.value.length,
    unit: '枚',
    hint: '像素风格数字凭证'
  }
])

const unlockedBadges = computed(() => badges.value.filter((b) => b.unlocked))
const lockedBadges = computed(() => badges.value.filter((b) => !b.unlocked))

/** 勋章等级 → 配色（1 铜 2 银 3 金） */
function badgeColor(level: string | null): string {
  switch (level) {
    case '3':
      return 'var(--zy-accent)'
    case '2':
      return '#9fb4bd'
    default:
      return 'var(--zy-primary-light)'
  }
}

/* ---------------- 雷达图 ---------------- */

function renderChart() {
  if (!chartEl.value || !radar.value) return
  if (!chart) {
    chart = echarts.init(chartEl.value)
  }
  const dims = radar.value.dimensions
  chart.setOption(
    {
      tooltip: {
        trigger: 'item',
        formatter: () => {
          const lines = dims.map(
            (d) => `${d.label}：${d.score === null ? '暂无数据' : d.score + ' 分'}`
          )
          return `<b>${radar.value?.name ?? ''}</b><br/>${lines.join('<br/>')}`
        }
      },
      radar: {
        radius: '66%',
        splitNumber: 4,
        axisName: { color: '#46575f', fontSize: 12 },
        splitLine: { lineStyle: { color: '#e2e9ec' } },
        splitArea: { areaStyle: { color: ['rgba(244,247,248,0.6)', 'rgba(255,255,255,0.9)'] } },
        indicator: dims.map((d) => ({ name: d.label, max: 100 }))
      },
      series: [
        {
          type: 'radar',
          symbolSize: 6,
          areaStyle: { color: 'rgba(47,125,143,0.22)' },
          lineStyle: { color: '#2f7d8f', width: 2 },
          itemStyle: { color: '#2f7d8f' },
          data: [
            {
              // 无数据的维度用 null，ECharts 会把该顶点拉向中心 ——
              // 配合下方图例说明"暂无数据"，避免被误读为 0 分
              value: dims.map((d) => d.score ?? 0),
              name: '当前能力画像'
            }
          ]
        }
      ]
    },
    true
  )
}

/* ---------------- 成长趋势 ---------------- */

function renderTrend() {
  if (!trendEl.value || !growth.value || growth.value.pointCount < 2) return
  if (!trendChart) {
    trendChart = echarts.init(trendEl.value)
  }
  const g = growth.value
  const colors = ['#2f7d8f', '#e08b3c', '#7a9e5b', '#a06c9e', '#5b7fbd']
  const series = Object.keys(g.series).map((key, i) => ({
    name: g.dimensionLabels[key] ?? key,
    type: 'line',
    smooth: true,
    // null 位置断线处理：不要用 0 连接，那会造成"能力暴跌"的假象
    connectNulls: false,
    data: g.series[key],
    itemStyle: { color: colors[i % colors.length] },
    lineStyle: { width: 2 }
  }))
  trendChart.setOption(
    {
      tooltip: { trigger: 'axis' },
      legend: { bottom: 0, itemWidth: 12, itemHeight: 8, textStyle: { fontSize: 11 } },
      grid: { left: 40, right: 16, top: 20, bottom: 40 },
      xAxis: { type: 'category', data: g.periods, axisLabel: { fontSize: 11 } },
      yAxis: { type: 'value', min: 0, max: 100, axisLabel: { fontSize: 11 } },
      series
    },
    true
  )
}

function handleResize() {
  chart?.resize()
  trendChart?.resize()
}

/* ---------------- 数据加载 ---------------- */

async function load() {
  loading.value = true
  try {
    const [radarData, badgeData, growthData, reportData, exchanges] = await Promise.all([
      profileApi.radar(),
      profileApi.badges(),
      profileApi.growth(12),
      profileApi.weeklyReports(6),
      exchangeApi.myExchanges()
    ])
    radar.value = radarData
    badges.value = badgeData
    growth.value = growthData
    reports.value = reportData
    const list = exchanges as Array<{ status: string }>
    exchangeStats.value = {
      ongoing: list.filter((e) => e.status === 'IN_PROGRESS' || e.status === 'NEGOTIATING').length,
      completed: list.filter((e) => e.status === 'COMPLETED').length
    }
    // 等 DOM 渲染完再画图，否则容器宽度为 0
    requestAnimationFrame(() => {
      renderChart()
      renderTrend()
    })
  } catch {
    // 错误提示由请求拦截器统一处理
  } finally {
    loading.value = false
  }
}

/** 固化当前画像为一个快照点，让成长轨迹立刻有数据 */
async function refreshSnapshot() {
  try {
    const r = await profileApi.snapshot()
    ElMessage.success(r.message)
    growth.value = await profileApi.growth(12)
    requestAnimationFrame(renderTrend)
  } catch {
    // 已提示
  }
}

/** 导出能力鉴定报告（浏览器打印为 PDF） */
async function exportReport() {
  try {
    const rep = await profileApi.report()
    exportReportAsPdf(rep)
    ElMessage.success('报告已生成，请在打印窗口中选择「另存为 PDF」')
  } catch (e) {
    ElMessage.error((e as Error).message || '报告导出失败')
  }
}

onMounted(() => {
  load()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  chart?.dispose()
  trendChart?.dispose()
  chart = null
  trendChart = null
})
</script>

<template>
  <div class="zy-page" v-loading="loading">
    <p class="zy-page-subtitle">
      把跨学科协作中的隐性能力，沉淀为可视化、可追溯、可导出的成长档案。
    </p>

    <!-- 数据不足引导：不要画一张空雷达图，那会被误读成"能力为零" -->
    <el-alert
      v-if="radar?.insufficientData"
      type="info"
      show-icon
      :closable="false"
      class="mb"
      title="还没有可用于生成画像的协作记录"
      description="完成一次技能交换（双方互评后交换进入「已完成」），这里就会出现你的能力雷达图。可以先去供需集市看看有没有合适的需求。"
    />

    <!-- 概览指标 -->
    <el-row :gutter="14" class="stats">
      <el-col v-for="s in stats" :key="s.label" :span="6" :sm="12" :md="6">
        <div class="zy-card stat">
          <div class="stat__label">{{ s.label }}</div>
          <div class="stat__value">
            {{ s.value }}<span class="stat__unit">{{ s.unit }}</span>
          </div>
          <div class="stat__hint">{{ s.hint }}</div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="14" class="mt">
      <!-- 能力雷达图 -->
      <el-col :span="24" :md="14">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">多维能力雷达</span>
            <el-tag v-if="radar?.sampleCount" size="small" type="success" effect="plain">
              {{ radar.sampleCount }} 次协作 · 平均 {{ radar.avgScore }} 分
            </el-tag>
            <el-tag v-else size="small" type="info" effect="plain">暂无数据</el-tag>
          </div>
          <div ref="chartEl" class="radar"></div>

          <!-- 维度明细：可解释性是硬要求，用户必须能回答"这个分怎么来的" -->
          <div v-if="radar" class="dims">
            <div v-for="d in radar.dimensions" :key="d.key" class="dim">
              <div class="dim__top">
                <span class="dim__label">{{ d.label }}</span>
                <span v-if="d.score !== null" class="dim__score">{{ d.score }}</span>
                <span v-else class="dim__score dim__score--none">暂无数据</span>
              </div>
              <div class="dim__desc">{{ d.description }}</div>
              <div class="dim__evidence">{{ d.evidence }}</div>
            </div>
          </div>

          <p class="panel__foot">{{ radar?.caliberNote }}</p>
        </div>
      </el-col>

      <!-- 数字勋章 -->
      <el-col :span="24" :md="10">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">数字勋章</span>
            <el-tag size="small" effect="plain">
              已解锁 {{ unlockedBadges.length }} / {{ badges.length }}
            </el-tag>
          </div>

          <div class="badges">
            <div
              v-for="b in badges"
              :key="b.id"
              class="badge"
              :class="{ 'badge--locked': !b.unlocked }"
            >
              <div class="badge__icon" :title="b.name">
                <i
                  v-for="n in 9"
                  :key="n"
                  class="zy-pixel-block"
                  :style="{
                    background: b.unlocked
                      ? n % 4 === 0
                        ? 'var(--zy-accent)'
                        : badgeColor(b.level)
                      : '#c8d6db'
                  }"
                ></i>
              </div>
              <div class="badge__meta">
                <div class="badge__name">
                  {{ b.name }}
                  <span v-if="b.unlocked" class="badge__got">已获得</span>
                </div>
                <div class="badge__desc">{{ b.description }}</div>
                <!-- 未解锁时显示进度：只展示已获得的勋章会失去引导作用 -->
                <div v-if="!b.unlocked && b.targetValue" class="badge__progress">
                  <el-progress
                    :percentage="Math.min(100, Math.round((b.currentValue / b.targetValue) * 100))"
                    :stroke-width="5"
                    :show-text="false"
                  />
                  <span class="badge__progress-text">{{ b.currentValue }} / {{ b.targetValue }}</span>
                </div>
              </div>
            </div>
            <el-empty v-if="badges.length === 0" description="暂无勋章定义" :image-size="50" />
          </div>
          <p class="panel__foot">勋章按协作成果自动授予，解锁情况会出现在能力鉴定报告中。</p>
        </div>
      </el-col>
    </el-row>

    <!-- 成长轨迹 -->
    <div class="zy-card panel mt">
      <div class="panel__head">
        <span class="panel__title">成长轨迹</span>
        <div class="panel__actions">
          <el-tag v-if="growth?.pointCount" size="small" effect="plain">
            {{ growth.pointCount }} 个快照点
          </el-tag>
          <el-button size="small" plain @click="refreshSnapshot">记录当前画像</el-button>
        </div>
      </div>

      <div v-if="growth && growth.pointCount >= 2" ref="trendEl" class="trend"></div>
      <div v-else class="trend-empty">
        <p>成长轨迹需要至少 2 个快照点才能画线（每月自动记录一次）。</p>
        <p class="trend-empty__hint">
          点击右上角「记录当前画像」可以立刻固化一个数据点，用于查看当前能力构成。
        </p>
      </div>

      <!-- 变化摘要 -->
      <div v-if="growth && growth.changes.length" class="changes">
        <div v-for="c in growth.changes" :key="c.key" class="change">
          <span class="change__label">{{ c.label }}</span>
          <span class="change__value">{{ c.first }} → {{ c.latest }}</span>
          <span class="change__delta" :class="{ 'change__delta--down': !c.improved }">
            {{ c.delta > 0 ? '+' : '' }}{{ c.delta }}
          </span>
        </div>
      </div>
      <p class="panel__foot">{{ growth?.note }}</p>
    </div>

    <el-row :gutter="14" class="mt">
      <!-- 成长周报 -->
      <el-col :span="24" :md="14">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">智能成长周报</span>
            <el-tag size="small" effect="plain">每周一自动生成</el-tag>
          </div>
          <div v-if="reports.length === 0" class="trend-empty">
            <p>还没有周报。系统每周一为有协作活动的同学自动生成并推送。</p>
          </div>
          <div v-for="w in reports" :key="w.id" class="weekly">
            <div class="weekly__head">
              <span class="weekly__week">{{ w.weekKey }}</span>
              <span class="weekly__range">{{ w.weekStart }} ~ {{ w.weekEnd }}</span>
            </div>
            <div class="weekly__summary">{{ w.summary }}</div>
            <ul v-if="w.highlights?.length" class="weekly__list">
              <li v-for="(h, i) in w.highlights" :key="i">{{ h }}</li>
            </ul>
          </div>
        </div>
      </el-col>

      <!-- 能力鉴定报告 -->
      <el-col :span="24" :md="10">
        <div class="zy-card panel report-panel">
          <div class="panel__head">
            <span class="panel__title">跨学科协作能力鉴定报告</span>
          </div>
          <div class="report-panel__desc">
            一键导出含唯一验证码的报告，可作为综合素质测评或求职简历的补充附件。
            报告上的校验码可由任何第三方在线验真（无需登录），用于核对内容是否被改动。
          </div>
          <ul class="report-panel__list">
            <li>能力画像五维得分 + 每项分数的出处</li>
            <li>代表性长项与客观协作行为摘要</li>
            <li>完整协作履历与数字勋章</li>
            <li>哈希存证校验码与验真入口</li>
          </ul>
          <div class="report-panel__actions">
            <el-button type="primary" @click="exportReport">导出 PDF 报告</el-button>
            <el-button plain @click="router.push({ name: 'Exchanges' })">我的交换记录</el-button>
          </div>
          <p class="panel__foot">
            导出后浏览器会打开打印窗口，选择「另存为 PDF」即可。报告中的校验码可在
            <code>/api/certificates/{校验码}</code> 处验真。
          </p>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.stats {
  margin-bottom: 14px;
}

.stat {
  padding: 14px 16px;
  height: 100%;
}

.stat__label {
  font-size: 12.5px;
  color: var(--zy-text-secondary);
}

.stat__value {
  font-size: 26px;
  font-weight: 700;
  line-height: 1.3;
  color: var(--zy-primary-dark);
}

.stat__unit {
  font-size: 13px;
  font-weight: 500;
  margin-left: 3px;
  color: var(--zy-text-secondary);
}

.stat__hint {
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}

.mt {
  margin-top: 14px;
}

.panel {
  padding: 16px 18px;
  height: 100%;
}

.panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.panel__title {
  font-size: 15px;
  font-weight: 600;
}

.panel__foot {
  margin: 12px 0 0;
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}

.radar {
  width: 100%;
  height: 320px;
}

.badges {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.badge {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  border: 1px solid var(--zy-border-light);
  border-radius: var(--zy-radius);
  background: #fbfdfe;
}

.badge--locked {
  opacity: 0.55;
}

.badge__icon {
  display: grid;
  grid-template-columns: repeat(3, 10px);
  gap: 2px;
}

.badge__name {
  font-size: 13px;
  font-weight: 600;
}

.badge__desc {
  font-size: 11px;
  color: var(--zy-text-secondary);
}

.report {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 16px 18px;
  flex-wrap: wrap;
}

.report__title {
  font-size: 15px;
  font-weight: 600;
}

.report__desc {
  font-size: 12.5px;
  color: var(--zy-text-secondary);
  max-width: 720px;
}
.mb {
  margin-bottom: 12px;
}

.panel__actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* ---------------- 维度明细（可解释性展示） ---------------- */
.dims {
  margin-top: 10px;
  border-top: 1px dashed var(--zy-border-light);
  padding-top: 10px;
}

.dim {
  padding: 7px 0;
  border-bottom: 1px dashed var(--zy-border-light);
}

.dim:last-child {
  border-bottom: none;
}

.dim__top {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 10px;
}

.dim__label {
  font-size: 13px;
  font-weight: 600;
}

.dim__score {
  font-size: 15px;
  font-weight: 700;
  color: var(--zy-primary-dark);
}

.dim__score--none {
  font-size: 11.5px;
  font-weight: 400;
  color: var(--zy-text-placeholder);
}

.dim__desc {
  margin-top: 1px;
  font-size: 11px;
  color: var(--zy-text-secondary);
}

.dim__evidence {
  margin-top: 3px;
  padding: 5px 8px;
  border-radius: var(--zy-radius-sm);
  background: rgba(47, 125, 143, 0.06);
  font-size: 10.5px;
  line-height: 1.65;
  color: var(--zy-primary-dark);
}

/* ---------------- 勋章 ---------------- */
.badges {
  display: flex;
  flex-direction: column;
  gap: 9px;
  max-height: 460px;
  overflow-y: auto;
}

.badge--locked {
  opacity: 0.62;
}

.badge__name {
  display: flex;
  align-items: center;
  gap: 6px;
}

.badge__got {
  padding: 0 5px;
  border-radius: 3px;
  background: rgba(122, 158, 91, 0.18);
  color: #4d7a2a;
  font-size: 10px;
  font-weight: 400;
}

.badge__progress {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 5px;
}

.badge__progress :deep(.el-progress) {
  flex: 1;
}

.badge__progress-text {
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
  white-space: nowrap;
}

/* ---------------- 成长轨迹 ---------------- */
.trend {
  width: 100%;
  height: 240px;
}

.trend-empty {
  padding: 26px 0;
  text-align: center;
  font-size: 12.5px;
  line-height: 1.9;
  color: var(--zy-text-placeholder);
}

.trend-empty__hint {
  margin: 4px 0 0;
  font-size: 11.5px;
}

.changes {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px dashed var(--zy-border-light);
}

.change {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 10px;
  border-radius: 20px;
  background: #f4f9fa;
  font-size: 11.5px;
}

.change__label {
  font-weight: 600;
}

.change__value {
  color: var(--zy-text-secondary);
}

.change__delta {
  font-weight: 700;
  color: #4d7a2a;
}

.change__delta--down {
  color: #c96a4f;
}

/* ---------------- 周报 ---------------- */
.weekly {
  padding: 10px 0;
  border-bottom: 1px dashed var(--zy-border-light);
}

.weekly:last-child {
  border-bottom: none;
}

.weekly__head {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.weekly__week {
  font-size: 13px;
  font-weight: 700;
  color: var(--zy-primary-dark);
}

.weekly__range {
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.weekly__summary {
  margin-top: 3px;
  font-size: 12px;
  line-height: 1.75;
}

.weekly__list {
  margin: 5px 0 0;
  padding-left: 18px;
  font-size: 11.5px;
  line-height: 1.75;
  color: var(--zy-text-secondary);
}

/* ---------------- 报告面板 ---------------- */
.report-panel__desc {
  font-size: 12.5px;
  line-height: 1.85;
  color: var(--zy-text-regular);
}

.report-panel__list {
  margin: 10px 0;
  padding-left: 18px;
  font-size: 12px;
  line-height: 1.95;
  color: var(--zy-text-secondary);
}

.report-panel__actions {
  display: flex;
  gap: 10px;
  margin-top: 12px;
  flex-wrap: wrap;
}
</style>
