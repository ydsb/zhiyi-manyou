<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { skillApi, buildGraphView } from '@/api/skill'
import type { ParseResult, SkillRelation, SkillTree } from '@/api/types'

/**
 * 技能图谱页（FR-M2-04 / FR-M2-05 / FR-M2-08）。
 *
 * 数据来源（真实后端接口，不再使用演示数据）：
 *   GET  /api/skills/tree      三层标签树（匿名可访问）
 *   GET  /api/ontology/graph   跨学科关系边（匿名可访问）
 *   POST /api/skills/parse     自然语言解析（需登录）
 */
const loading = ref(false)
const tree = ref<SkillTree | null>(null)
const relations = ref<SkillRelation[]>([])
const keyword = ref('')
const activeL1 = ref('全部')

/* ---------------- 自然语言解析（FR-M2-01 ~ M2-03 / M2-06） ---------------- */
const parseText = ref('我需要会做动态交互效果的同学，帮我把作品集页面做得活一点')
const parsing = ref(false)
const parseResult = ref<ParseResult | null>(null)

const categories = computed(() => {
  const names = tree.value?.tree.map((c) => c.name) ?? []
  return ['全部', ...names]
})

/** 关键词过滤后的树（前端即时过滤以提升输入手感） */
const filteredTree = computed(() => {
  if (!tree.value) return []
  const kw = keyword.value.trim().toLowerCase()
  const byL1 =
    activeL1.value === '全部' ? tree.value.tree : tree.value.tree.filter((c) => c.name === activeL1.value)
  if (!kw) {
    return byL1
  }
  return byL1
    .map((c) => ({
      ...c,
      children: c.children
        .map((s) => ({
          ...s,
          skills: s.skills.filter(
            (k) =>
              k.name.toLowerCase().includes(kw) ||
              (k.alias ?? '').toLowerCase().includes(kw) ||
              s.name.toLowerCase().includes(kw)
          )
        }))
        .filter((s) => s.skills.length > 0)
    }))
    .filter((c) => c.children.length > 0)
})

const visibleSkillCount = computed(() =>
  filteredTree.value.reduce((sum, c) => sum + c.children.reduce((s, x) => s + x.skills.length, 0), 0)
)

const graphView = computed(() => buildGraphView(relations.value))

const nodeName = (id: number) => graphView.value.nodes.find((n) => n.id === id)?.name ?? String(id)

const relationTypeTag = (t: string) =>
  t === 'COMPLEMENT' ? 'success' : t === 'PREREQUISITE' ? 'warning' : 'info'

const matchTypeTag = (t: string) =>
  t === 'EXACT' ? 'success' : t === 'ALIAS' ? 'warning' : t === 'GRAPH' ? 'danger' : 'info'

const matchTypeLabel = (t: string) =>
  ({ EXACT: '名称精确', ALIAS: '同义词', KEYWORD: '关键词', GRAPH: '图谱关联' } as Record<string, string>)[t] ?? t

const intentLabel = (i?: string | null) =>
  i === 'SKILLED' ? '我擅长' : i === 'NEEDED' ? '我急需' : i === 'RESEARCHING' ? '在研究' : ''

const intentTag = (i?: string | null) =>
  i === 'SKILLED' ? 'success' : i === 'NEEDED' ? 'danger' : 'info'

async function loadTree() {
  loading.value = true
  try {
    tree.value = await skillApi.tree()
  } catch {
    // 提示由响应拦截器统一处理
  } finally {
    loading.value = false
  }
}

async function loadGraph() {
  try {
    relations.value = await skillApi.graph()
  } catch {
    // 图谱失败不阻塞页面
  }
}

async function runParse() {
  if (!parseText.value.trim()) {
    ElMessage.warning('请输入要解析的描述')
    return
  }
  parsing.value = true
  try {
    parseResult.value = await skillApi.parse({ text: parseText.value, limit: 8, withGraph: true })
  } catch {
    parseResult.value = null
  } finally {
    parsing.value = false
  }
}

function useSample(text: string) {
  parseText.value = text
  runParse()
}

onMounted(() => {
  loadTree()
  loadGraph()
})
</script>

<template>
  <div class="zy-page">
    <p class="zy-page-subtitle">
      三层分类（学科门类 → 二级学科 → 技能标签）与跨学科关系网络。数据来自后端真实接口
      <code>/api/skills/tree</code> 与 <code>/api/ontology/graph</code>。
    </p>

    <!-- 概览 -->
    <el-row :gutter="12" class="stat-row">
      <el-col :span="8">
        <div class="zy-card stat">
          <div class="stat__v">{{ tree?.categoryCount ?? 0 }}</div>
          <div class="stat__l">学科门类</div>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="zy-card stat">
          <div class="stat__v">{{ tree?.subCategoryCount ?? 0 }}</div>
          <div class="stat__l">二级学科</div>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="zy-card stat">
          <div class="stat__v">{{ tree?.skillCount ?? 0 }}</div>
          <div class="stat__l">技能标签</div>
        </div>
      </el-col>
    </el-row>

    <!-- 自然语言解析 -->
    <div class="zy-card panel parse-panel">
      <div class="panel__head">
        <span class="panel__title">自然语言解析</span>
        <el-tag size="small" :type="parseResult?.degraded ? 'warning' : 'success'" effect="plain">
          {{ parseResult ? parseResult.engine : 'FR-M2-02' }}
        </el-tag>
      </div>
      <p class="panel__desc">
        输入口语化的跨专业描述，系统抽取标准化技能标签与
        <code>(主体, 动作, 技能实体)</code> 三元组；开启图谱补全后，还会带出字面未命中的跨学科关联标签。
      </p>

      <div class="parse-input">
        <el-input
          v-model="parseText"
          type="textarea"
          :rows="2"
          placeholder="例如：我需要会做动态交互效果的同学 / 我会 Vue 前端开发，想找人教我数学建模"
        />
        <el-button type="primary" :loading="parsing" @click="runParse">解析</el-button>
      </div>

      <div class="samples">
        <span class="samples__label">试试：</span>
        <el-link
          v-for="s in [
            '我需要会做动态交互效果的同学',
            '我会 Vue 前端开发，想找人教我数学建模',
            '急需一位会界面设计的同学',
            '想学 Python 数据爬取，愿意用视频剪辑交换'
          ]"
          :key="s"
          type="primary"
          underline="never"
          class="samples__item"
          @click="useSample(s)"
        >{{ s }}</el-link>
      </div>

      <div v-if="parseResult" class="parse-result">
        <div class="parse-result__grid">
          <div>
            <div class="mini-title">标准化技能标签（{{ parseResult.matched.length }}）</div>
            <div v-if="parseResult.matched.length === 0" class="empty-hint">未匹配到标签，可尝试更具体的描述</div>
            <div v-for="m in parseResult.matched" :key="m.skillId" class="hit">
              <div class="hit__top">
                <span class="hit__name">{{ m.name }}</span>
                <el-tag size="small" :type="matchTypeTag(m.matchType)" effect="plain">
                  {{ matchTypeLabel(m.matchType) }}
                </el-tag>
                <el-tag v-if="m.intent" size="small" :type="intentTag(m.intent)" effect="light">
                  {{ intentLabel(m.intent) }}
                </el-tag>
                <span class="hit__score">{{ (Number(m.score) * 100).toFixed(0) }}%</span>
              </div>
              <div class="hit__reason">{{ m.reason }}</div>
            </div>
          </div>

          <div>
            <div class="mini-title">三元组（{{ parseResult.triples.length }}）</div>
            <div v-if="parseResult.triples.length === 0" class="empty-hint">无</div>
            <div v-for="(t, i) in parseResult.triples" :key="i" class="triple">
              <span class="triple__s">{{ t.subject }}</span>
              <span class="triple__a">{{ t.action }}</span>
              <span class="triple__o">{{ t.object }}</span>
            </div>
            <div v-if="parseResult.hint" class="parse-hint">{{ parseResult.hint }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 工具栏 -->
    <div class="zy-card toolbar">
      <el-input v-model="keyword" placeholder="筛选技能或学科（如 动画 / 设计）" clearable class="toolbar__search" />
      <el-radio-group v-model="activeL1" size="small">
        <el-radio-button v-for="c in categories" :key="c" :value="c">{{ c }}</el-radio-button>
      </el-radio-group>
      <el-tag size="small" type="warning" effect="plain">共 {{ visibleSkillCount }} 个标签</el-tag>
    </div>

    <el-row :gutter="14">
      <!-- 标签库 -->
      <el-col :span="24" :md="15">
        <div class="zy-card panel" v-loading="loading">
          <div class="panel__head">
            <span class="panel__title">技能标签库</span>
            <el-tag size="small" effect="plain">目标 ≥ 50 学科 / 1000 标签</el-tag>
          </div>

          <div v-for="cat in filteredTree" :key="cat.name" class="cat">
            <div class="cat__name">
              {{ cat.name }}<span class="cat__count">{{ cat.skillCount }}</span>
            </div>
            <div v-for="sub in cat.children" :key="sub.name" class="sub">
              <div class="sub__name">{{ sub.name }}</div>
              <div class="sub__skills">
                <div v-for="s in sub.skills" :key="s.id" class="skill" :title="s.description || ''">
                  <div class="skill__name">{{ s.name }}</div>
                  <div class="skill__alias">{{ s.alias || '—' }}</div>
                  <div class="skill__meta">
                    <el-rate :model-value="s.difficulty ?? 3" disabled size="small" :max="5" />
                    <span class="skill__hot">{{ s.hotScore ?? 0 }}°</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <el-empty v-if="filteredTree.length === 0 && !loading" description="没有匹配的技能标签" />
        </div>
      </el-col>

      <!-- 关系网络 -->
      <el-col :span="24" :md="9">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">跨学科关系</span>
            <el-tag size="small" effect="plain">
              {{ graphView.nodes.length }} 节点 / {{ graphView.edges.length }} 边
            </el-tag>
          </div>

          <div class="rel-list">
            <div v-for="e in graphView.edges" :key="`${e.source}-${e.target}`" class="rel">
              <div class="rel__edge">
                <span class="rel__node">{{ nodeName(e.source) }}</span>
                <span class="rel__arrow">{{ e.type === 'PREREQUISITE' ? '→' : '↔' }}</span>
                <span class="rel__node">{{ nodeName(e.target) }}</span>
              </div>
              <div class="rel__meta">
                <el-tag size="small" :type="relationTypeTag(e.type)" effect="plain">{{ e.label }}</el-tag>
                <span class="rel__weight">权重 {{ Number(e.weight).toFixed(2) }}</span>
              </div>
            </div>
            <el-empty v-if="graphView.edges.length === 0" description="暂无图谱关系" :image-size="60" />
          </div>

          <p class="panel__foot">
            「互补协作」边用于图谱游走，挖掘字面匹配之外的隐性跨学科需求（FR-M2-06）。
          </p>
        </div>

        <div class="zy-card panel mt">
          <div class="panel__head"><span class="panel__title">节点活跃度</span></div>
          <div
            v-for="n in graphView.nodes.slice().sort((a, b) => b.degree - a.degree).slice(0, 8)"
            :key="n.id"
            class="degree"
          >
            <span class="degree__name">{{ n.name }}</span>
            <span class="degree__bar"><i :style="{ width: `${Math.min(100, n.degree * 25)}%` }"></i></span>
            <span class="degree__v">{{ n.degree }}</span>
          </div>
          <el-empty v-if="graphView.nodes.length === 0" description="暂无数据" :image-size="60" />
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
code {
  padding: 1px 5px;
  font-size: 11.5px;
  border-radius: 3px;
  background: rgba(47, 125, 143, 0.09);
  color: var(--zy-primary-dark);
}

.stat-row {
  margin-bottom: 14px;
}

.stat {
  padding: 12px 16px;
  text-align: center;
}

.stat__v {
  font-size: 22px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  line-height: 1.2;
}

.stat__l {
  font-size: 11.5px;
  color: var(--zy-text-secondary);
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

.panel__desc {
  margin: 0 0 12px;
  font-size: 12.5px;
  line-height: 1.7;
  color: var(--zy-text-secondary);
}

.panel__foot {
  margin: 12px 0 0;
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}

.parse-panel {
  margin-bottom: 14px;
}

.parse-input {
  display: flex;
  gap: 10px;
  align-items: flex-start;
}

.parse-input :deep(.el-textarea) {
  flex: 1;
}

.samples {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}

.samples__label {
  font-size: 12px;
  color: var(--zy-text-placeholder);
}

.samples__item {
  font-size: 12px;
}

.parse-result {
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px dashed var(--zy-border);
}

.parse-result__grid {
  display: grid;
  grid-template-columns: 1.6fr 1fr;
  gap: 18px;
}

.mini-title {
  font-size: 12.5px;
  font-weight: 600;
  color: var(--zy-text-regular);
  margin-bottom: 8px;
}

.empty-hint {
  font-size: 12px;
  color: var(--zy-text-placeholder);
}

.hit {
  padding: 8px 10px;
  margin-bottom: 8px;
  border: 1px solid var(--zy-border-light);
  border-radius: var(--zy-radius);
  background: #fbfdfe;
}

.hit__top {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

.hit__name {
  font-size: 13px;
  font-weight: 600;
}

.hit__score {
  margin-left: auto;
  font-size: 12px;
  font-weight: 600;
  color: var(--zy-primary-dark);
}

.hit__reason {
  margin-top: 4px;
  font-size: 11px;
  line-height: 1.6;
  color: var(--zy-text-placeholder);
}

.triple {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 6px;
  font-size: 12px;
  flex-wrap: wrap;
}

.triple__s,
.triple__o {
  padding: 2px 7px;
  border-radius: var(--zy-radius-sm);
  background: rgba(47, 125, 143, 0.09);
  color: var(--zy-primary-dark);
}

.triple__a {
  padding: 2px 7px;
  border-radius: var(--zy-radius-sm);
  background: rgba(224, 139, 60, 0.13);
  color: #a8661f;
}

.parse-hint {
  margin-top: 8px;
  font-size: 11.5px;
  color: var(--zy-text-secondary);
}

.toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}

.toolbar__search {
  max-width: 280px;
}

.cat {
  margin-bottom: 16px;
}

.cat__name {
  font-size: 13px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  padding-bottom: 6px;
  margin-bottom: 8px;
  border-bottom: 1px solid var(--zy-border);
}

.cat__count {
  margin-left: 6px;
  font-size: 11px;
  font-weight: 500;
  color: var(--zy-text-placeholder);
}

.sub {
  margin: 0 0 10px 2px;
}

.sub__name {
  font-size: 12px;
  color: var(--zy-text-secondary);
  margin-bottom: 6px;
}

.sub__skills {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 8px;
}

.skill {
  padding: 9px 11px;
  border: 1px solid var(--zy-border-light);
  border-radius: var(--zy-radius);
  background: #fbfdfe;
  transition: all 0.15s ease;
}

.skill:hover {
  border-color: var(--zy-primary-light);
  box-shadow: var(--zy-pixel-shadow);
}

.skill__name {
  font-size: 13px;
  font-weight: 600;
}

.skill__alias {
  margin: 2px 0 4px;
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.skill__meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.skill__hot {
  font-size: 10.5px;
  color: var(--zy-accent);
}

.rel-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.rel {
  padding: 9px 11px;
  border: 1px solid var(--zy-border-light);
  border-radius: var(--zy-radius);
  background: #fbfdfe;
}

.rel__edge {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
  margin-bottom: 6px;
}

.rel__node {
  font-size: 12px;
  font-weight: 600;
  padding: 2px 7px;
  border-radius: var(--zy-radius-sm);
  background: rgba(47, 125, 143, 0.09);
  color: var(--zy-primary-dark);
}

.rel__arrow {
  color: var(--zy-accent);
  font-weight: 700;
}

.rel__meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.rel__weight {
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.mt {
  margin-top: 14px;
}

.degree {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 5px 0;
}

.degree__name {
  font-size: 12px;
  width: 118px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.degree__bar {
  flex: 1;
  height: 6px;
  border-radius: 3px;
  background: var(--zy-border);
  overflow: hidden;
}

.degree__bar i {
  display: block;
  height: 100%;
  background: linear-gradient(90deg, var(--zy-primary), var(--zy-accent));
}

.degree__v {
  font-size: 11.5px;
  color: var(--zy-text-secondary);
  width: 16px;
  text-align: right;
}

@media (max-width: 900px) {
  .parse-result__grid {
    grid-template-columns: 1fr;
  }
}
</style>
