<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'

/**
 * 新手漫游导引（FR-M1-03 / FR-M1-04）。
 *
 * 三步引导：我擅长 → 我正在研究 → 我急需，
 * 选完后实时渲染"技能星图"，作为首次使用的仪式感载体。
 *
 * 待办：接入 POST /api/skills/parse 与画像保存接口后落库。
 */
const router = useRouter()
const auth = useAuthStore()

const step = ref(0)

/** 演示用标签池：接口就绪后改为从 /api/skills/tree 拉取 */
const candidateTags = [
  'Vue 前端开发', 'JS 动画与交互实现', 'UI/UX 设计', 'ECharts 数据可视化',
  '数据爬取与清洗', '学术论文写作', '数学建模', '英语口语陪练',
  '视频剪辑', '科研实验设计', 'PPT 与汇报表达', '算法与数据结构'
]

const selected = ref<[string[], string[], string[]]>([[], [], []])

const steps = [
  { title: '我擅长…', hint: '选择你可以教给别人的技能' },
  { title: '我正在研究…', hint: '选择你正在学习或研究的方向' },
  { title: '我急需…', hint: '选择你希望找人协助的技能' }
]

const currentTags = computed(() => selected.value[step.value])
const canNext = computed(() => currentTags.value.length > 0)

/** 技能星图节点：把已选标签布局成星图 */
const starNodes = computed(() => {
  const all = [
    ...selected.value[0].map((n) => ({ name: n, kind: 'skilled' as const })),
    ...selected.value[1].map((n) => ({ name: n, kind: 'researching' as const })),
    ...selected.value[2].map((n) => ({ name: n, kind: 'needed' as const }))
  ]
  const total = all.length || 1
  return all.map((node, i) => {
    const angle = (i / total) * Math.PI * 2 - Math.PI / 2
    const radius = 110 + (i % 2) * 34
    return {
      ...node,
      x: 190 + Math.cos(angle) * radius,
      y: 170 + Math.sin(angle) * radius * 0.78,
      size: node.kind === 'skilled' ? 14 : node.kind === 'needed' ? 12 : 10
    }
  })
})

function toggle(tag: string) {
  const list = selected.value[step.value]
  const idx = list.indexOf(tag)
  if (idx >= 0) {
    list.splice(idx, 1)
  } else {
    if (list.length >= 6) {
      ElMessage.warning('每步最多选择 6 个标签')
      return
    }
    list.push(tag)
  }
}

function next() {
  if (!canNext.value) {
    ElMessage.warning('请至少选择一个标签')
    return
  }
  if (step.value < steps.length - 1) {
    step.value += 1
  } else {
    finish()
  }
}

function finish() {
  // TODO: 调用画像保存接口
  auth.completeOnboarding()
  ElMessage.success('技能星图已生成，开始你的跨学科漫游吧')
  router.push({ name: 'Dashboard' })
}

function skip() {
  auth.completeOnboarding()
  router.push({ name: 'Dashboard' })
}
</script>

<template>
  <div class="zy-page onboarding">
    <div class="head">
      <div>
        <p class="zy-page-subtitle">
          三步选择，系统会实时渲染你的初始「技能星图」，并据此开始跨学科匹配。
        </p>
      </div>
      <el-button text @click="skip">跳过，稍后设置</el-button>
    </div>

    <el-steps :active="step" align-center class="steps">
      <el-step v-for="(s, i) in steps" :key="s.title" :title="s.title" :description="s.hint" />
    </el-steps>

    <el-row :gutter="14">
      <!-- 标签选择 -->
      <el-col :span="24" :md="13">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">{{ steps[step].title }}</span>
            <span class="panel__count">已选 {{ currentTags.length }} / 6</span>
          </div>

          <div class="tags">
            <button
              v-for="tag in candidateTags"
              :key="tag"
              type="button"
              class="tag"
              :class="{ 'tag--on': currentTags.includes(tag) }"
              @click="toggle(tag)"
            >
              {{ tag }}
            </button>
          </div>

          <div class="actions">
            <el-button v-if="step > 0" @click="step -= 1">上一步</el-button>
            <el-button type="primary" :disabled="!canNext" @click="next">
              {{ step === steps.length - 1 ? '生成技能星图' : '下一步' }}
            </el-button>
          </div>

          <p class="tip">
            提示：也可直接输入自然语言（如"我需要会做动态交互效果的同学"），
            系统会通过 NLP 抽取标准化标签（FR-M2-02），该能力将在 S3 阶段上线。
          </p>
        </div>
      </el-col>

      <!-- 技能星图 -->
      <el-col :span="24" :md="11">
        <div class="zy-card panel">
          <div class="panel__head">
            <span class="panel__title">技能星图</span>
            <el-tag size="small" effect="plain">实时预览</el-tag>
          </div>

          <div class="starmap">
            <svg viewBox="0 0 380 340" class="starmap__svg">
              <!-- 中心节点 -->
              <circle cx="190" cy="170" r="26" fill="rgba(47,125,143,0.12)" stroke="#2f7d8f" stroke-width="1.5" />
              <text x="190" y="175" text-anchor="middle" font-size="12" fill="#235f6e">
                {{ auth.displayName.slice(0, 3) }}
              </text>

              <!-- 连线 -->
              <line
                v-for="(n, i) in starNodes"
                :key="'l' + i"
                x1="190" y1="170" :x2="n.x" :y2="n.y"
                stroke="#d9e4e8" stroke-width="1"
              />

              <!-- 技能节点 -->
              <g v-for="(n, i) in starNodes" :key="'n' + i">
                <circle
                  :cx="n.x" :cy="n.y" :r="n.size"
                  :fill="n.kind === 'skilled' ? '#2f7d8f' : n.kind === 'needed' ? '#e08b3c' : '#7c8d95'"
                />
                <text
                  :x="n.x" :y="n.y - n.size - 5"
                  text-anchor="middle" font-size="10" fill="#46575f"
                >{{ n.name }}</text>
              </g>
            </svg>

            <div v-if="starNodes.length === 0" class="starmap__empty">
              选择标签后，星图会在这里实时生长
            </div>
          </div>

          <div class="legend">
            <span><i class="dot dot--skilled"></i>我擅长</span>
            <span><i class="dot dot--researching"></i>在研</span>
            <span><i class="dot dot--needed"></i>我急需</span>
          </div>
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

.steps {
  margin: 6px 0 18px;
}

.panel {
  padding: 16px 18px;
  height: 100%;
}

.panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.panel__title {
  font-size: 15px;
  font-weight: 600;
}

.panel__count {
  font-size: 12px;
  color: var(--zy-text-secondary);
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
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

.actions {
  display: flex;
  gap: 8px;
  margin-top: 20px;
}

.tip {
  margin: 16px 0 0;
  font-size: 11.5px;
  line-height: 1.7;
  color: var(--zy-text-placeholder);
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
  gap: 16px;
  justify-content: center;
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
