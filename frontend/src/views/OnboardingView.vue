<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { skillApi } from '@/api/skill'
import { profileApi } from '@/api/profile'
import { matchApi } from '@/api/match'
import type { Skill, SkillIntent, SkillTree } from '@/api/types'

/**
 * 新手漫游导引（FR-M1-03 / FR-M1-04）。
 *
 * <p><b>本页在 M1 阶段是纯前端骨架，本次才接上真实能力</b>，记录一下为什么
 * 值得单独说明 —— 因为原实现的缺陷是"看起来能用、实际什么都没做"：
 *
 * <ol>
 *   <li>标签池是 12 个<b>硬编码</b>字符串，而平台已有 788 个真实技能标签
 *       分属 62 个学科、12 个门类。对跨学科定位的产品来说，
 *       只给 12 个计算机相关标签等于把产品最核心的资产藏起来了；</li>
 *   <li>{@code finish()} 里只有一句 TODO，<b>选完不落库</b>。
 *       而 {@code zy_user_skill_profile} 是集市匹配度、供需因子、
 *       能力雷达图、首登判断的公共输入 —— 空画像会让匹配因子恒为 0；</li>
 *   <li>于是"首次登录"永远为真：用户每次登录都被强制拉回本页，
 *       形成死循环式的骚扰。</li>
 * </ol>
 *
 * <p>现在：标签来自 {@code /api/skills/tree}（可搜索、按学科门类筛选），
 * 支持自然语言描述由 NLP 引擎（S3）抽取标签，选完调用
 * {@code POST /api/profile/skills} 落库。
 *
 * <p><b>为什么三步都允许"跳过"</b>：导引是首次体验，强制填满才放行会让
 * 新用户直接关掉页面。但"我擅长"必须至少选一个 —— 供给是平台运转的起点，
 * 一个只有需求的用户对其他人没有价值，也就匹配不到任何人。
 */
const router = useRouter()
const auth = useAuthStore()

const step = ref(0)
const tree = ref<SkillTree | null>(null)
const loadingTree = ref(false)
const saving = ref(false)

/** 三步：我擅长 / 我正在研究 / 我急需（与后端 SkillIntent 一一对应） */
const STEPS: Array<{ intent: SkillIntent; title: string; hint: string; required: boolean }> = [
  {
    intent: 'SKILLED',
    title: '我擅长…',
    hint: '选择你可以教给别人的技能。这是别人找到你的依据',
    required: true
  },
  {
    intent: 'RESEARCHING',
    title: '我正在研究…',
    hint: '选择你正在学、正在做的方向，便于遇到同路人',
    required: false
  },
  {
    intent: 'NEEDED',
    title: '我急需…',
    hint: '选择你希望找人协助的技能，发布需求时会用到',
    required: false
  }
]

/** 每步已选技能（整对象，便于渲染名称与回显） */
const picked = ref<Skill[][]>([[], [], []])

const currentStep = computed(() => STEPS[step.value])
const currentPicked = computed(() => picked.value[step.value])
const pickedIds = computed(() => new Set(currentPicked.value.map((s) => s.id)))

/* ------------------------------------------------------------------ */
/* 标签浏览与筛选                                                      */
/* ------------------------------------------------------------------ */

const keyword = ref('')
const activeL1 = ref('全部')
/** 每次渲染的标签上限 —— 788 个标签全铺开会把页面压垮，靠搜索收敛 */
const RENDER_LIMIT = 60
const renderLimit = ref(RENDER_LIMIT)

const categories = computed(() => ['全部', ...(tree.value?.tree.map((c) => c.name) ?? [])])

/**
 * 当前可见的候选标签。
 *
 * 搜索时跨全部门类检索（用户找"数学建模"时不该被"当前选的是工学"挡住），
 * 未搜索时按门类浏览并截断到 RENDER_LIMIT。
 */
const candidates = computed<Skill[]>(() => {
  if (!tree.value) {
    return []
  }
  const kw = keyword.value.trim().toLowerCase()
  const out: Skill[] = []

  for (const cat of tree.value.tree) {
    if (!kw && activeL1.value !== '全部' && cat.name !== activeL1.value) {
      continue
    }
    for (const sub of cat.children) {
      for (const s of sub.skills) {
        const hit =
          !kw ||
          s.name.toLowerCase().includes(kw) ||
          (s.alias ?? '').toLowerCase().includes(kw) ||
          sub.name.toLowerCase().includes(kw) ||
          cat.name.toLowerCase().includes(kw)
        if (hit) {
          out.push({ ...s, categoryL1: s.categoryL1 || cat.name, categoryL2: s.categoryL2 || sub.name })
        }
      }
    }
  }
  // 搜索时按热度优先，未搜索时保持门类顺序（浏览体验更稳定）
  if (kw) {
    out.sort((a, b) => (b.hotScore ?? 0) - (a.hotScore ?? 0))
  }
  return out
})

const visibleCandidates = computed(() => candidates.value.slice(0, renderLimit.value))
const hasMore = computed(() => candidates.value.length > renderLimit.value)

/** 搜索词变化时重置分页，否则搜完再改词会看到"明明有结果却只剩几条" */
function onKeywordChange() {
  renderLimit.value = RENDER_LIMIT
}

function onCategoryChange() {
  renderLimit.value = RENDER_LIMIT
}

/* ------------------------------------------------------------------ */
/* 选择                                                                */
/* ------------------------------------------------------------------ */

const MAX_PER_STEP = 6

function toggle(skill: Skill) {
  const list = picked.value[step.value]
  const idx = list.findIndex((s) => s.id === skill.id)
  if (idx >= 0) {
    list.splice(idx, 1)
    return
  }
  if (list.length >= MAX_PER_STEP) {
    ElMessage.warning(`每步最多选择 ${MAX_PER_STEP} 个标签`)
    return
  }
  list.push(skill)
}

function removeAt(index: number) {
  picked.value[step.value].splice(index, 1)
}

/* ------------------------------------------------------------------ */
/* 自然语言抽取（FR-M2-02 + FR-M3-02）                                  */
/* ------------------------------------------------------------------ */

const nlText = ref('')
const parsing = ref(false)
/** 上一次抽取的说明（引擎 + 命中来源），让用户明白标签是怎么来的 */
const lastExtract = ref<{ engine: string; fromRule: number; fromVector: number } | null>(null)

/**
 * 一句话抽取标签。
 *
 * <p><b>为什么要同时用两个通道</b>：M1 阶段本页只调 {@code /skills/parse}
 * （规则词典），实测一句"我会做数学建模和统计分析，也常常用 Python 处理数据"
 * <b>只抽到 1 个标签</b> —— 因为规则词典只认字面命中的词，
 * "统计分析""处理数据"在词典里没有对应词条就全丢了。
 * 而平台 S3 阶段已经建好了 788 标签的向量索引，能召回"字面不同但语义相近"的技能。
 *
 * <p>两者互补而不是替代：
 * <ul>
 *   <li>{@code parse} 给标准化标签名 + 三元组，<b>还能判定意图</b>；</li>
 *   <li>{@code semantic} 给向量召回 + 图谱关系加成，<b>但不管意图</b>。</li>
 * </ul>
 * 因此以 parse 的意图判定为准，用 semantic 补召回，按 skillId 去重。
 */
async function parseAndAdd() {
  const text = nlText.value.trim()
  if (!text) {
    ElMessage.warning('请输入一句描述')
    return
  }
  parsing.value = true
  try {
    /*
     * 已选标签作为图谱种子：用户已勾的标签是最强意图信号，
     * 命中它们在图谱上的邻居（同义/先决/互补）会获得关系加成（FR-M2-06）。
     */
    const seeds = picked.value.flat().map((s) => s.id)

    const [parsed, semantic] = await Promise.all([
      skillApi.parse({ text, limit: 8, withGraph: true }).catch(() => null),
      matchApi
        .semantic({ query: text, topK: 10, kind: 'SKILL', seedSkillIds: seeds })
        .catch(() => null)
    ])

    const want = currentStep.value.intent
    const candidates: Array<{ skill: Skill; why: string }> = []
    const seen = new Set<number>()

    // 通道一：规则词典 + 三元组（带意图）
    for (const m of parsed?.matched ?? []) {
      if (m.intent && m.intent !== want) {
        continue
      }
      if (seen.has(m.skillId)) {
        continue
      }
      seen.add(m.skillId)
      candidates.push({
        skill: { id: m.skillId, name: m.name, categoryL1: m.categoryL1 ?? '', categoryL2: m.categoryL2 ?? '' },
        why: `${m.reason}（${Math.round(Number(m.score) * 100)}%）`
      })
    }
    const fromRule = candidates.length

    // 通道二：向量召回（补字面未命中的语义近邻）
    /*
     * 这里做两道约束，避免向量召回"吃掉"全部名额。
     *
     * 实测："我会做数学建模和统计分析，也常常用 Python 处理数据" 的 Top-10 稳居前列的是
     * R 语言统计分析 / 统计分析软件应用 / 多元统计分析 / 社会调查与统计分析。
     * 起初我以为这是数据重复，查库后确认**不是**：
     * 788 个技能零完全同名，"统计"相关的 16 个标签分属数学、统计学、生物学、
     * 大气科学、公共管理、医学等不同学科，都是合法标签。
     * 反复出现统计簇的真实原因是**用户在同一句话里说了两次"统计"**，
     * 向量检索忠实地反映了这一点。
     *
     * 所以这里不做"近义消解"（那需要先有同义词图谱，而当前
     * zy_skill_ontology 只有 3 条关系，远不够用），只做两件有把握的事：
     *   ① 每门类最多 2 个 —— 防止单一学科刷屏，保证跨学科广度；
     *   ② 兜底绝对阈值 0.22 —— 砍掉"传感器数据采集"这类长尾弱相关。
     */
    const semanticHits = (semantic?.hits ?? []).filter((h) => h.skillId != null)
    const PER_CATEGORY_LIMIT = 2
    const MIN_SEMANTIC_SCORE = 0.22
    const semanticBudget = Math.max(1, Math.floor(MAX_PER_STEP / 2))

    const categoryUsed = new Map<string, number>()
    let semanticAdded = 0
    for (const h of semanticHits) {
      if (semanticAdded >= semanticBudget) {
        break
      }
      const id = h.skillId as number
      if (seen.has(id)) {
        continue
      }
      if (Number(h.score) < MIN_SEMANTIC_SCORE) {
        continue
      }
      const meta = (h.meta ?? {}) as Record<string, unknown>
      const cat = String(meta.categoryL1 ?? meta.category_l1 ?? '未分类')
      if ((categoryUsed.get(cat) ?? 0) >= PER_CATEGORY_LIMIT) {
        continue
      }
      categoryUsed.set(cat, (categoryUsed.get(cat) ?? 0) + 1)
      seen.add(id)
      candidates.push({
        skill: {
          id,
          name: h.name,
          categoryL1: cat,
          categoryL2: String(meta.categoryL2 ?? meta.category_l2 ?? '')
        },
        why: h.reasons?.length
          ? `${cat} · ${h.reasons.join('；')}`
          : `${cat} · 语义相近（${Math.round(Number(h.score) * 100)}%）`
      })
      semanticAdded++
    }
    const fromVector = semanticAdded

    if (candidates.length === 0) {
      ElMessage.warning('没抽到匹配的标签，试试更具体的说法')
      return
    }

    let added = 0
    const whyList: string[] = []
    for (const c of candidates) {
      if (pickedIds.value.has(c.skill.id)) continue
      if (picked.value[step.value].length >= MAX_PER_STEP) break
      picked.value[step.value].push(c.skill)
      whyList.push(`${c.skill.name} —— ${c.why}`)
      added++
    }

    nlText.value = ''
    lastExtract.value = {
      engine: semantic?.available === false ? '规则词典（语义服务降级）' : (parsed?.engine ?? '规则词典'),
      fromRule,
      fromVector
    }

    if (added === 0) {
      ElMessage.info('抽到的标签已在你的选择里，或已选满')
    } else {
      ElMessage.success(
        `已抽取并加入 ${added} 个标签（规则词典 ${fromRule} 个 + 语义召回 ${fromVector} 个），可再手工增删`
      )
      // 把抽取依据展示出来 —— "为什么推荐它"是 FR-M3-05 的要求
      for (const w of whyList.slice(0, 3)) {
        ElMessage({ type: 'info', message: w, duration: 4000, grouping: true })
      }
    }
  } catch {
    // 提示由响应拦截器统一处理
  } finally {
    parsing.value = false
  }
}

/* ------------------------------------------------------------------ */
/* 步骤流转与保存                                                      */
/* ------------------------------------------------------------------ */

function next() {
  const list = currentPicked.value
  if (currentStep.value.required && list.length === 0) {
    ElMessage.warning('请至少选择一个你擅长的技能 —— 别人靠它找到你')
    return
  }
  if (step.value < STEPS.length - 1) {
    step.value += 1
    keyword.value = ''
    renderLimit.value = RENDER_LIMIT
  } else {
    finish()
  }
}

async function finish() {
  const items = STEPS.flatMap((s, i) =>
    picked.value[i].map((skill) => ({ skillId: skill.id, intent: s.intent }))
  )
  if (items.length === 0) {
    ElMessage.warning('请至少选择一个技能标签')
    return
  }
  saving.value = true
  try {
    const saved = await profileApi.saveSkills(items)
    // 画像一旦建立，firstLogin 即为 false，路由守卫不再把用户拉回本页
    auth.completeOnboarding()
    ElMessage.success(`已保存 ${saved.total} 个技能标签，开始你的跨学科漫游吧`)
    router.push({ name: 'Dashboard' })
  } catch {
    // 保存失败不跳转：跳走会让用户以为已保存，实际画像仍为空
  } finally {
    saving.value = false
  }
}

/* ------------------------------------------------------------------ */
/* 技能星图                                                            */
/* ------------------------------------------------------------------ */

/** 星图节点：三步选择的并集，半径随节点数自适应以防重叠 */
const starNodes = computed(() => {
  const all = [
    ...picked.value[0].map((s) => ({ id: s.id, name: s.name, kind: 'skilled' as const })),
    ...picked.value[1].map((s) => ({ id: s.id, name: s.name, kind: 'researching' as const })),
    ...picked.value[2].map((s) => ({ id: s.id, name: s.name, kind: 'needed' as const }))
  ]
  const total = all.length
  if (total === 0) {
    return []
  }
  // 单环排布，节点多时把环放大一点，避免标签互相压住
  const radius = total <= 8 ? 108 : Math.min(150, 96 + total * 5)
  return all.map((node, i) => {
    const angle = (i / total) * Math.PI * 2 - Math.PI / 2
    return {
      ...node,
      x: 190 + Math.cos(angle) * radius,
      y: 170 + Math.sin(angle) * radius * 0.76,
      size: node.kind === 'skilled' ? 13 : node.kind === 'needed' ? 11 : 9
    }
  })
})

const totalPicked = computed(() => picked.value.reduce((sum, l) => sum + l.length, 0))

/* ------------------------------------------------------------------ */
/* 初始化                                                              */
/* ------------------------------------------------------------------ */

onMounted(async () => {
  loadingTree.value = true
  try {
    tree.value = await skillApi.tree()
  } catch {
    // 树加载失败时页面仍可用"自然语言抽取"这条路径，故不阻断
  } finally {
    loadingTree.value = false
  }

  /*
   * 回显已有画像：用户可能从「技能画像」页跳回来修改。
   * 导引页原先假设"进来就是空的"，直接跳步会覆盖掉已有选择。
   */
  try {
    const mine = await profileApi.mySkills()
    if (mine.total > 0) {
      const byId = new Map<number, Skill>()
      for (const cat of tree.value?.tree ?? []) {
        for (const sub of cat.children) {
          for (const s of sub.skills) {
            byId.set(s.id, s)
          }
        }
      }
      const map = (list: typeof mine.skilled) =>
        list
          .map((e) => byId.get(e.skill.id) ?? e.skill)
          .filter((s): s is Skill => Boolean(s))
      picked.value = [map(mine.skilled), map(mine.researching), map(mine.needed)]
    }
  } catch {
    // 回显失败不影响新填
  }
})
</script>

<template>
  <div class="zy-page onboarding">
    <div class="head">
      <div>
        <h2 class="head__title">新手漫游导引</h2>
        <p class="zy-page-subtitle">
          三步选择，系统实时渲染你的初始「技能星图」，并据此开始跨学科匹配。
          标签来自平台 <b>{{ tree?.skillCount ?? 0 }}</b> 个技能本体的
          <b>{{ tree?.subCategoryCount ?? 0 }}</b> 个二级学科，可搜索、可按门类浏览。
        </p>
      </div>
      <el-button text @click="router.push({ name: 'Dashboard' })">稍后设置</el-button>
    </div>

    <el-steps :active="step" align-center class="steps">
      <el-step
        v-for="s in STEPS"
        :key="s.intent"
        :title="s.title"
        :description="s.hint"
      />
    </el-steps>

    <el-row :gutter="14">
      <!-- 标签选择 -->
      <el-col :span="24" :md="14">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">{{ currentStep.title }}</span>
            <span class="panel__count">
              已选 {{ currentPicked.length }} / {{ MAX_PER_STEP }}
              <el-tag v-if="currentStep.required" size="small" type="danger" effect="plain">必选</el-tag>
            </span>
          </div>

          <!-- 已选 -->
          <div v-if="currentPicked.length" class="picked">
            <el-tag
              v-for="(s, i) in currentPicked"
              :key="s.id"
              closable
              type="primary"
              effect="light"
              @close="removeAt(i)"
            >{{ s.name }}</el-tag>
          </div>
          <p v-else class="picked__empty">
            还没有选择 —— 从下面挑，或直接用一句话描述
          </p>

          <!-- 自然语言抽取 -->
          <div class="nl">
            <el-input
              v-model="nlText"
              :placeholder="`用一句话描述，例如：${
                currentStep.intent === 'SKILLED'
                  ? '我会做动态交互效果和作品集页面'
                  : currentStep.intent === 'NEEDED'
                    ? '我需要有人帮我做数学建模和数据分析'
                    : '我在研究推荐算法与用户行为分析'
              }`"
              @keyup.enter="parseAndAdd"
            >
              <template #append>
                <el-button :loading="parsing" @click="parseAndAdd">智能抽取</el-button>
              </template>
            </el-input>
            <span class="nl__tip">由平台 NLP 引擎抽取标准化标签，抽完可再手工增删</span>
            <div v-if="lastExtract" class="nl__engine">
              <el-tag size="small" effect="plain">{{ lastExtract.engine }}</el-tag>
              <span class="nl__engine-text">
                规则词典命中 {{ lastExtract.fromRule }} 个 · 语义召回补充 {{ lastExtract.fromVector }} 个
                <template v-if="lastExtract.fromVector > 0">
                  —— 后者是字面没说但语义相近的标签
                </template>
              </span>
            </div>
          </div>

          <!-- 搜索与门类 -->
          <div class="toolbar">
            <el-input
              v-model="keyword"
              placeholder="搜索技能、同义词或学科（如 动画 / 建模 / 设计）"
              clearable
              class="toolbar__search"
              @input="onKeywordChange"
            />
            <el-select
              v-model="activeL1"
              size="small"
              class="toolbar__cat"
              :disabled="!!keyword.trim()"
              @change="onCategoryChange"
            >
              <el-option v-for="c in categories" :key="c" :label="c" :value="c" />
            </el-select>
            <el-tag size="small" type="warning" effect="plain">
              {{ candidates.length }} 个匹配
            </el-tag>
          </div>

          <!-- 标签云 -->
          <div v-loading="loadingTree" class="tags">
            <button
              v-for="s in visibleCandidates"
              :key="s.id"
              type="button"
              class="tag"
              :class="{ 'tag--on': pickedIds.has(s.id) }"
              :title="`${s.categoryL1} · ${s.categoryL2}${s.alias ? ' · 别名：' + s.alias : ''}`"
              @click="toggle(s)"
            >
              {{ s.name }}
            </button>
            <el-empty
              v-if="!loadingTree && candidates.length === 0"
              description="没有匹配的标签，换个说法试试"
              :image-size="60"
            />
          </div>

          <div v-if="hasMore" class="more">
            <el-button text type="primary" @click="renderLimit += RENDER_LIMIT">
              还有 {{ candidates.length - renderLimit }} 个，加载更多
            </el-button>
          </div>

          <div class="actions">
            <el-button v-if="step > 0" @click="step -= 1">上一步</el-button>
            <el-button type="primary" :loading="saving" @click="next">
              {{ step === STEPS.length - 1 ? '生成技能星图并保存' : '下一步' }}
            </el-button>
          </div>
        </div>
      </el-col>

      <!-- 技能星图 -->
      <el-col :span="24" :md="10">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">技能星图</span>
            <el-tag size="small" effect="plain">实时预览 · 共 {{ totalPicked }} 个</el-tag>
          </div>

          <div class="starmap">
            <svg viewBox="0 0 380 340" class="starmap__svg">
              <circle cx="190" cy="170" r="26" fill="rgba(47,125,143,0.12)" stroke="#2f7d8f" stroke-width="1.5" />
              <text x="190" y="175" text-anchor="middle" font-size="12" fill="#235f6e">
                {{ auth.displayName.slice(0, 3) }}
              </text>

              <line
                v-for="(n, i) in starNodes"
                :key="'l' + i"
                x1="190" y1="170" :x2="n.x" :y2="n.y"
                stroke="#d9e4e8" stroke-width="1"
              />

              <g v-for="(n, i) in starNodes" :key="'n' + n.id + '-' + i">
                <circle
                  :cx="n.x" :cy="n.y" :r="n.size"
                  :fill="n.kind === 'skilled' ? '#2f7d8f' : n.kind === 'needed' ? '#e08b3c' : '#7c8d95'"
                />
                <text
                  :x="n.x" :y="n.y - n.size - 5"
                  text-anchor="middle" font-size="9.5" fill="#46575f"
                >{{ n.name.length > 10 ? n.name.slice(0, 9) + '…' : n.name }}</text>
              </g>
            </svg>

            <div v-if="starNodes.length === 0" class="starmap__empty">
              选择标签后，星图会在这里实时生长
            </div>
          </div>

          <div class="legend">
            <span><i class="dot dot--skilled"></i>我擅长（{{ picked[0].length }}）</span>
            <span><i class="dot dot--researching"></i>在研（{{ picked[1].length }}）</span>
            <span><i class="dot dot--needed"></i>我急需（{{ picked[2].length }}）</span>
          </div>

          <p class="panel__foot">
            保存后，技能画像会成为集市匹配、供需排序与能力雷达图的数据来源。
            你也可以随时在「技能画像」页修改。
          </p>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.head__title {
  margin: 0 0 4px;
  font-size: 19px;
}

.steps {
  margin: 6px 0 18px;
}

.steps :deep(.el-step__description) {
  font-size: 11.5px;
}

.panel {
  padding: 16px 18px;
  height: 100%;
}

.panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 12px;
}

.panel__title {
  font-size: 15px;
  font-weight: 600;
}

.panel__count {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: var(--zy-text-secondary);
}

.panel__foot {
  margin: 10px 0 0;
  font-size: 11.5px;
  line-height: 1.7;
  color: var(--zy-text-placeholder);
}

.picked {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  min-height: 30px;
  padding: 8px 10px;
  border: 1px dashed var(--zy-border);
  border-radius: var(--zy-radius);
  background: #fbfdfe;
}

.picked__empty {
  margin: 0;
  padding: 8px 10px;
  font-size: 12px;
  color: var(--zy-text-placeholder);
  border: 1px dashed var(--zy-border);
  border-radius: var(--zy-radius);
}

.nl {
  margin-top: 12px;
}

.nl__tip {
  display: block;
  margin-top: 5px;
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.nl__engine {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 7px;
  flex-wrap: wrap;
}

.nl__engine-text {
  font-size: 11px;
  color: var(--zy-text-secondary);
}

.toolbar {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 14px 0 10px;
  flex-wrap: wrap;
}

.toolbar__search {
  flex: 1;
  min-width: 200px;
}

.toolbar__cat {
  width: 130px;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  min-height: 120px;
  max-height: 300px;
  overflow-y: auto;
  padding: 2px;
}

.tag {
  padding: 7px 12px;
  font-size: 13px;
  font-family: inherit;
  color: var(--zy-text-regular);
  background: #fff;
  border: 1px solid var(--zy-border);
  border-radius: var(--zy-radius);
  cursor: pointer;
  transition: all 0.15s ease;
}

.tag:hover {
  border-color: var(--zy-primary-light);
  color: var(--zy-primary);
}

.tag--on {
  background: rgba(47, 125, 143, 0.1);
  border-color: var(--zy-primary);
  color: var(--zy-primary-dark);
  font-weight: 600;
  box-shadow: var(--zy-pixel-shadow);
}

.more {
  margin-top: 8px;
  text-align: center;
}

.actions {
  display: flex;
  gap: 8px;
  margin-top: 18px;
}

.starmap {
  position: relative;
}

.starmap__svg {
  width: 100%;
  height: 320px;
  display: block;
}

.starmap__empty {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12.5px;
  color: var(--zy-text-placeholder);
}

.legend {
  display: flex;
  gap: 14px;
  justify-content: center;
  flex-wrap: wrap;
  font-size: 12px;
  color: var(--zy-text-secondary);
}

.dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  margin-right: 5px;
  border-radius: 1px;
}

.dot--skilled {
  background: #2f7d8f;
}
.dot--researching {
  background: #7c8d95;
}
.dot--needed {
  background: #e08b3c;
}
</style>
