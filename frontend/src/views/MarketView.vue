<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { demandApi, exchangeApi, metaApi } from '@/api/demand'
import { skillApi } from '@/api/skill'
import type { DemandMeta, MarketCard, MatchFactor, SkillMatch } from '@/api/types'
import { useAuthStore } from '@/stores/auth'

/**
 * 供需集市（FR-M4-01 / FR-M4-02 / FR-M4-03）。
 *
 * 数据全部来自后端：
 *   GET  /api/demands            信息流（匹配度排序 + 高匹配高亮）
 *   GET  /api/demands/{id}       卡片详情（含匹配度拆解与意向）
 *   POST /api/demands            发布卡片
 *   POST /api/exchanges/apply    发起交换邀约
 *   GET  /api/meta/demands       枚举与阈值字典
 */
const auth = useAuthStore()

const loading = ref(false)
const cards = ref<MarketCard[]>([])
const total = ref(0)
const meta = ref<DemandMeta | null>(null)

const query = reactive({
  keyword: '',
  sort: 'MATCH' as 'MATCH' | 'LATEST' | 'HOT',
  onlyHighMatch: false,
  page: 1,
  size: 9
})

/* ---------------- 发布对话框 ---------------- */
const publishVisible = ref(false)
const publishing = ref(false)
const skillOptions = ref<SkillMatch[]>([])
const skillSearching = ref(false)

const form = reactive({
  title: '',
  description: '',
  expectedSkillId: undefined as number | undefined,
  offerSkillId: undefined as number | undefined,
  expectedHours: 6,
  expectedPeriod: '',
  visibility: 'PUBLIC' as 'PUBLIC' | 'COLLEGE' | 'PRIVATE'
})

/* ---------------- 详情抽屉 ---------------- */
const detailVisible = ref(false)
const detailCard = ref<MarketCard | null>(null)
const applying = ref(false)
const applyMessage = ref('')

const highMatchThreshold = computed(() => meta.value?.highMatchThreshold ?? 0.75)
const isOwner = (card: MarketCard | null) => !!card && card.ownerSno === auth.user?.sno

async function loadFeed() {
  loading.value = true
  try {
    const res = await demandApi.feed({
      keyword: query.keyword || undefined,
      sort: query.sort,
      onlyHighMatch: query.onlyHighMatch || undefined,
      page: query.page,
      size: query.size
    })
    cards.value = res.records
    total.value = res.total
  } catch {
    // 提示由响应拦截器统一处理
  } finally {
    loading.value = false
  }
}

async function loadMeta() {
  try {
    meta.value = await metaApi.demandMeta()
  } catch {
    // 字典加载失败不影响主流程
  }
}

async function searchSkills(kw: string) {
  if (!kw) {
    skillOptions.value = []
    return
  }
  skillSearching.value = true
  try {
    skillOptions.value = await skillApi.search({ keyword: kw, limit: 20 })
  } finally {
    skillSearching.value = false
  }
}

async function publish() {
  if (!form.title.trim()) {
    ElMessage.warning('请填写标题')
    return
  }
  if (!form.expectedSkillId) {
    ElMessage.warning('请选择你急需的技能')
    return
  }
  publishing.value = true
  try {
    const card = await demandApi.create({
      title: form.title,
      description: form.description || undefined,
      expectedSkillId: form.expectedSkillId,
      offerSkillId: form.offerSkillId,
      expectedHours: form.expectedHours,
      expectedPeriod: form.expectedPeriod || undefined,
      visibility: form.visibility
    })
    ElMessage.success(card.auditStatus === 'PENDING' ? '已发布，内容待人工复核' : '发布成功')
    publishVisible.value = false
    form.title = ''
    form.description = ''
    form.expectedSkillId = undefined
    form.offerSkillId = undefined
    form.expectedHours = 6
    form.expectedPeriod = ''
    form.visibility = 'PUBLIC'
    query.page = 1
    await loadFeed()
  } catch {
    // 提示已统一处理
  } finally {
    publishing.value = false
  }
}

async function openDetail(card: MarketCard) {
  try {
    detailCard.value = await demandApi.detail(card.id)
    detailVisible.value = true
  } catch {
    // 可见性受限时后端会返回业务错误码，拦截器已提示
  }
}

async function applyExchange() {
  if (!detailCard.value) return
  applying.value = true
  try {
    const res = await exchangeApi.apply({
      demandId: detailCard.value.id,
      message: applyMessage.value || undefined
    })
    ElMessage.success(res.message || '邀约已发送')
    detailVisible.value = false
    applyMessage.value = ''
    await loadFeed()
  } catch {
    // 提示已统一处理
  } finally {
    applying.value = false
  }
}

async function closeCard(card: MarketCard) {
  try {
    await ElMessageBox.confirm('确定关闭这张需求卡片吗？关闭后不再出现在集市。', '提示', {
      confirmButtonText: '关闭',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch {
    return
  }
  try {
    await demandApi.close(card.id)
    ElMessage.success('已关闭')
    await loadFeed()
  } catch {
    // 已提示
  }
}

function factorColor(f: MatchFactor) {
  return f.score >= 0.75 ? 'var(--zy-dim-data)'
    : f.score >= 0.4 ? 'var(--zy-accent)'
    : 'var(--zy-text-placeholder)'
}

/**
 * 把后端时间字符串转成可解析的本地时间。
 *
 * 后端统一输出 `yyyy-MM-dd HH:mm:ss`；带 `T` 的 ISO 形式也兼容
 * （历史上 DTO 曾把时间声明为 String，产出过带 T 的格式）。
 * 显式按本地时间构造，避免各浏览器对"无时区字符串"的解释差异。
 */
function parseTime(t?: string): Date | null {
  if (!t) return null
  const m = t.match(/^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2}):(\d{2})/)
  if (m) {
    return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]),
      Number(m[4]), Number(m[5]), Number(m[6]))
  }
  const fallback = new Date(t)
  return Number.isNaN(fallback.getTime()) ? null : fallback
}

function humanTime(t?: string) {
  const d = parseTime(t)
  if (!d) return ''
  const min = Math.floor((Date.now() - d.getTime()) / 60000)
  if (min < 1) return '刚刚'
  if (min < 60) return `${min} 分钟前`
  const h = Math.floor(min / 60)
  if (h < 24) return `${h} 小时前`
  const days = Math.floor(h / 24)
  if (days < 30) return `${days} 天前`
  return d.toLocaleDateString('zh-CN')
}

onMounted(() => {
  loadMeta()
  loadFeed()
})
</script>

<template>
  <div class="zy-page">
    <p class="zy-page-subtitle">
      以技易技的信息流：发起需求就像在开源社区提一个 Issue。系统按
      <b>「我能帮上他」×「他能回报我」</b> 双向计算匹配度，把高匹配卡片高亮置顶。
    </p>

    <div class="zy-card toolbar">
      <el-input
        v-model="query.keyword"
        placeholder="搜索需求或技能（如 动画 / 可视化）"
        clearable
        class="toolbar__search"
        @keyup.enter="query.page = 1; loadFeed()"
      />
      <el-select v-model="query.sort" style="width: 132px" @change="query.page = 1; loadFeed()">
        <el-option v-for="s in meta?.sort ?? []" :key="s.value" :label="s.label" :value="s.value" />
      </el-select>
      <el-checkbox v-model="query.onlyHighMatch" @change="query.page = 1; loadFeed()">
        只看高匹配（≥{{ Math.round(highMatchThreshold * 100) }}%）
      </el-checkbox>
      <div class="toolbar__spacer"></div>
      <el-button type="primary" :disabled="!auth.isLoggedIn" @click="publishVisible = true">
        发布需求
      </el-button>
    </div>

    <el-alert
      v-if="!auth.isLoggedIn"
      class="mb"
      type="info"
      :closable="false"
      show-icon
      title="当前未登录"
      description="未登录只按卡片客观质量排序；登录后系统会结合你的技能画像计算技能级匹配度。"
    />

    <div v-loading="loading" class="grid">
      <article
        v-for="card in cards"
        :key="card.id"
        class="zy-card card"
        :class="{ 'card--hot': card.highMatch }"
        @click="openDetail(card)"
      >
        <div v-if="card.highMatch" class="card__ribbon">高匹配</div>

        <header class="card__head">
          <span class="card__no">#{{ card.demandNo }}</span>
          <el-tag size="small" :type="card.status === 'OPEN' ? 'info' : 'success'" effect="plain">
            {{ card.statusLabel }}
          </el-tag>
          <el-tag
            v-if="card.visibility && card.visibility !== 'PUBLIC'"
            size="small"
            type="warning"
            effect="plain"
          >{{ card.visibilityLabel }}</el-tag>
          <span class="card__time">{{ humanTime(card.createdAt) }}</span>
        </header>

        <h3 class="card__title">{{ card.title }}</h3>
        <p class="card__desc">{{ card.description }}</p>

        <div class="exchange">
          <span class="chip chip--need"><b>我急需</b>{{ card.expectSkill?.name ?? '—' }}</span>
          <span class="exchange__arrow">⇄</span>
          <span class="chip chip--offer"><b>我可提供</b>{{ card.offerSkill?.name ?? '未声明' }}</span>
        </div>

        <footer class="card__foot">
          <div class="card__meta">
            <span>{{ card.ownerName || card.ownerSno }}</span>
            <span>·</span>
            <span>{{ card.ownerCollege || '—' }}</span>
            <span v-if="card.expectedHours">· {{ card.expectedHours }} 小时</span>
          </div>
          <div class="card__match">
            <template v-if="card.matchScore != null">
              <span class="match__bar">
                <i :style="{ width: Math.round(card.matchScore * 100) + '%' }"></i>
              </span>
              <span class="match__val">{{ Math.round(card.matchScore * 100) }}%</span>
            </template>
            <span v-else class="match__na">—</span>
          </div>
        </footer>

        <div v-if="isOwner(card)" class="card__owner-actions" @click.stop>
          <el-button size="small" text type="danger" @click="closeCard(card)">关闭需求</el-button>
        </div>
      </article>
    </div>

    <el-empty v-if="!loading && cards.length === 0" description="没有匹配的需求卡片" />

    <div v-if="total > query.size" class="pager">
      <el-pagination
        v-model:current-page="query.page"
        :page-size="query.size"
        :total="total"
        layout="prev, pager, next, total"
        @current-change="loadFeed"
      />
    </div>

    <!-- ---------------- 发布 ---------------- -->
    <el-dialog v-model="publishVisible" title="发布技能需求" width="620px">
      <el-form label-width="96px" label-position="left">
        <el-form-item label="标题" required>
          <el-input v-model="form.title" maxlength="200" show-word-limit
                    placeholder="如：需要会做动态交互效果的同学" />
        </el-form-item>
        <el-form-item label="需求详述">
          <el-input v-model="form.description" type="textarea" :rows="4" maxlength="2000" show-word-limit
                    placeholder="说明具体需求、期望产出与时间安排" />
        </el-form-item>
        <el-form-item label="我急需" required>
          <el-select
            v-model="form.expectedSkillId"
            filterable remote reserve-keyword
            placeholder="搜索技能标签（如 动画）"
            :remote-method="searchSkills"
            :loading="skillSearching"
            style="width: 100%"
          >
            <el-option
              v-for="s in skillOptions"
              :key="s.skillId"
              :label="s.name + '（' + s.categoryL1 + ' / ' + s.categoryL2 + '）'"
              :value="s.skillId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="我可提供">
          <el-select
            v-model="form.offerSkillId"
            filterable remote reserve-keyword clearable
            placeholder="作为回报我能教什么（以技易技）"
            :remote-method="searchSkills"
            :loading="skillSearching"
            style="width: 100%"
          >
            <el-option
              v-for="s in skillOptions"
              :key="s.skillId"
              :label="s.name + '（' + s.categoryL1 + ' / ' + s.categoryL2 + '）'"
              :value="s.skillId"
            />
          </el-select>
        </el-form-item>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="预计时长">
              <el-input-number v-model="form.expectedHours" :min="1" :max="500" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="期望时段">
              <el-input v-model="form.expectedPeriod" placeholder="如 周末下午" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="可见范围">
          <el-radio-group v-model="form.visibility">
            <el-radio v-for="v in meta?.visibility ?? []" :key="v.value" :value="v.value">
              {{ v.label }}
            </el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="publishVisible = false">取消</el-button>
        <el-button type="primary" :loading="publishing" @click="publish">发布</el-button>
      </template>
    </el-dialog>

    <!-- ---------------- 详情 ---------------- -->
    <el-drawer v-model="detailVisible" size="540px" :title="detailCard?.demandNo">
      <template v-if="detailCard">
        <h3 class="d-title">{{ detailCard.title }}</h3>
        <p class="d-desc">{{ detailCard.description }}</p>

        <div class="d-exchange">
          <div class="d-party d-party--need">
            <span class="d-party__label">我急需</span>
            <span class="d-party__skill">{{ detailCard.expectSkill?.name }}</span>
            <span class="d-party__cat">
              {{ detailCard.expectSkill?.categoryL1 }} / {{ detailCard.expectSkill?.categoryL2 }}
            </span>
          </div>
          <div class="d-arrow">⇄</div>
          <div class="d-party d-party--offer">
            <span class="d-party__label">我可提供</span>
            <span class="d-party__skill">{{ detailCard.offerSkill?.name ?? '未声明' }}</span>
            <span class="d-party__cat">{{ detailCard.offerSkill ? detailCard.offerSkill.categoryL1 + ' / ' + detailCard.offerSkill.categoryL2 : '单向求助' }}</span>
          </div>
        </div>

        <div class="d-meta">
          <span>发布人：{{ detailCard.ownerName }}</span>
          <span>{{ detailCard.ownerCollege }}</span>
          <span v-if="detailCard.ownerCreditScore">信用 {{ detailCard.ownerCreditScore }}</span>
        </div>
        <div class="d-meta">
          <span>预计 {{ detailCard.expectedHours }} 小时</span>
          <span v-if="detailCard.expectedPeriod">期望时段：{{ detailCard.expectedPeriod }}</span>
          <span>{{ detailCard.matchCount }} 次邀约 / {{ detailCard.viewCount }} 次浏览</span>
        </div>

        <div v-if="detailCard.matchFactors && detailCard.matchFactors.length" class="d-factors">
          <div class="d-head">
            <span>匹配度拆解</span>
            <span class="d-total">
              {{ detailCard.matchScore != null ? Math.round(detailCard.matchScore * 100) : 0 }}%
            </span>
          </div>
          <div v-for="f in detailCard.matchFactors" :key="f.name" class="d-factor">
            <div class="d-factor__top">
              <span class="d-factor__name">{{ f.name }}</span>
              <span class="d-factor__w">权重 {{ Math.round(f.weight * 100) }}%</span>
              <span class="d-factor__s" :style="{ color: factorColor(f) }">
                {{ Math.round(f.score * 100) }}%
              </span>
            </div>
            <div class="d-factor__bar">
              <i :style="{ width: Math.round(f.score * 100) + '%', background: factorColor(f) }"></i>
            </div>
            <div class="d-factor__detail">{{ f.detail }}</div>
          </div>
        </div>

        <div v-if="isOwner(detailCard) && detailCard.interests && detailCard.interests.length" class="d-section">
          <div class="d-head"><span>收到的邀约（{{ detailCard.interests.length }}）</span></div>
          <div v-for="i in detailCard.interests" :key="i.id" class="d-interest">
            <span class="d-interest__who">{{ i.applicantName || i.applicantSno }}</span>
            <el-tag size="small" effect="plain">{{ i.statusLabel }}</el-tag>
            <span class="d-interest__msg">{{ i.message }}</span>
          </div>
          <el-alert class="mt-s" type="success" :closable="false" show-icon
                    title="到「我的交换」处理邀约"
                    description="接受后会立即生成协作空间（任务打卡与时间轴在 M5 上线）。" />
        </div>

        <div v-if="!isOwner(detailCard) && detailCard.status === 'OPEN'" class="d-apply">
          <el-input v-model="applyMessage" placeholder="留言：说明你能提供什么、方便的时间（可选）" />
          <el-button type="primary" :loading="applying" :disabled="!auth.isLoggedIn" @click="applyExchange">
            发起交换
          </el-button>
        </div>
        <el-alert v-else-if="isOwner(detailCard)" class="mt-s" type="info" :closable="false" show-icon
                  title="这是你发布的需求" description="其他同学发起邀约后可在「我的交换」中处理。" />
        <el-alert v-else-if="detailCard.status !== 'OPEN'" class="mt-s" type="warning" :closable="false"
                  show-icon title="该需求已停止招募" />
      </template>
    </el-drawer>
  </div>
</template>

<style scoped>
.mb {
  margin-bottom: 14px;
}

.mt-s {
  margin-top: 12px;
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

.toolbar__spacer {
  flex: 1;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(370px, 1fr));
  gap: 14px;
  min-height: 80px;
}

.card {
  position: relative;
  padding: 16px 18px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  cursor: pointer;
  transition: all 0.16s ease;
}

.card:hover {
  box-shadow: var(--zy-shadow);
  transform: translateY(-1px);
}

.card--hot {
  border-color: rgba(224, 139, 60, 0.55);
  box-shadow: 0 0 0 1px rgba(224, 139, 60, 0.12);
}

.card__ribbon {
  position: absolute;
  top: 0;
  right: 0;
  padding: 3px 10px;
  font-size: 11px;
  color: #fff;
  background: var(--zy-accent);
  border-radius: 0 var(--zy-radius) 0 var(--zy-radius);
}

.card__head {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.card__no {
  font-size: 11.5px;
  font-family: ui-monospace, Consolas, monospace;
  color: var(--zy-text-placeholder);
}

.card__time {
  margin-left: auto;
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}

.card__title {
  margin: 0;
  font-size: 15px;
  line-height: 1.45;
}

.card__desc {
  margin: 0;
  font-size: 12.5px;
  line-height: 1.7;
  color: var(--zy-text-regular);
  display: -webkit-box;
  -webkit-line-clamp: 3;
  line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.exchange {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.chip {
  padding: 3px 9px;
  font-size: 12px;
  border-radius: var(--zy-radius-sm);
}

.chip b {
  margin-right: 5px;
  font-weight: 600;
  opacity: 0.75;
}

.chip--need {
  background: rgba(224, 139, 60, 0.13);
  color: #a8661f;
}

.chip--offer {
  background: rgba(47, 125, 143, 0.1);
  color: var(--zy-primary-dark);
}

.exchange__arrow {
  color: var(--zy-accent);
  font-weight: 700;
}

.card__foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-top: auto;
  padding-top: 10px;
  border-top: 1px dashed var(--zy-border);
}

.card__meta {
  display: flex;
  gap: 5px;
  font-size: 11.5px;
  color: var(--zy-text-secondary);
  flex-wrap: wrap;
}

.card__match {
  display: flex;
  align-items: center;
  gap: 6px;
}

.match__bar {
  display: inline-block;
  width: 56px;
  height: 6px;
  border-radius: 3px;
  background: var(--zy-border);
  overflow: hidden;
}

.match__bar i {
  display: block;
  height: 100%;
  background: linear-gradient(90deg, var(--zy-primary), var(--zy-accent));
}

.match__val {
  font-size: 12px;
  font-weight: 600;
  color: var(--zy-primary-dark);
}

.match__na {
  font-size: 12px;
  color: var(--zy-text-placeholder);
}

.card__owner-actions {
  display: flex;
  justify-content: flex-end;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 18px;
}

/* ---------------- 抽屉 ---------------- */
.d-title {
  margin: 0 0 8px;
  font-size: 17px;
  line-height: 1.5;
}

.d-desc {
  margin: 0 0 16px;
  font-size: 13px;
  line-height: 1.8;
  color: var(--zy-text-regular);
}

.d-exchange {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}

.d-party {
  flex: 1;
  padding: 10px 12px;
  border-radius: var(--zy-radius);
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.d-party--need {
  background: rgba(224, 139, 60, 0.1);
}

.d-party--offer {
  background: rgba(47, 125, 143, 0.09);
}

.d-party__label {
  font-size: 11px;
  color: var(--zy-text-secondary);
}

.d-party__skill {
  font-size: 13.5px;
  font-weight: 600;
}

.d-party__cat {
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
}

.d-arrow {
  color: var(--zy-accent);
  font-size: 18px;
  font-weight: 700;
}

.d-meta {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  font-size: 12px;
  color: var(--zy-text-secondary);
  margin-bottom: 6px;
}

.d-factors,
.d-section {
  margin-top: 18px;
  padding-top: 14px;
  border-top: 1px dashed var(--zy-border);
}

.d-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 12px;
}

.d-total {
  color: var(--zy-primary-dark);
  font-size: 16px;
}

.d-factor {
  margin-bottom: 12px;
}

.d-factor__top {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
}

.d-factor__name {
  font-weight: 600;
}

.d-factor__w {
  color: var(--zy-text-placeholder);
  font-size: 11px;
}

.d-factor__s {
  margin-left: auto;
  font-weight: 700;
}

.d-factor__bar {
  height: 5px;
  margin: 4px 0;
  border-radius: 3px;
  background: var(--zy-border);
  overflow: hidden;
}

.d-factor__bar i {
  display: block;
  height: 100%;
}

.d-factor__detail {
  font-size: 11px;
  line-height: 1.6;
  color: var(--zy-text-placeholder);
}

.d-interest {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 7px 0;
  font-size: 12px;
  border-bottom: 1px dashed var(--zy-border-light);
  flex-wrap: wrap;
}

.d-interest__who {
  font-weight: 600;
}

.d-interest__msg {
  color: var(--zy-text-placeholder);
  font-size: 11.5px;
}

.d-apply {
  display: flex;
  gap: 10px;
  margin-top: 18px;
  padding-top: 14px;
  border-top: 1px dashed var(--zy-border);
}
</style>
