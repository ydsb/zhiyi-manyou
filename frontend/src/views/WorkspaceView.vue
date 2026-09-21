<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { downloadCollabFile, workspaceApi } from '@/api/workspace'
import { exchangeApi } from '@/api/demand'
import type { CollabFile, CollabMessage, CollabTask, ProcessSummary, Workspace } from '@/api/types'

/**
 * 协作工作台（模块 M5）。
 *
 * 对应需求：
 *   FR-M5-01 专属协作空间    —— 服务端强制只有参与方可访问（非参与方返回 3014）
 *   FR-M5-02 任务拆解与打卡  —— 任务清单 + 负责人指派 + 打卡
 *   FR-M5-03 文件版本回溯    —— 上传新版本、查看历史版本、下载
 *   FR-M5-04 时间轴          —— 全部协作事件按时间倒序
 *   FR-M5-06 过程性指标      —— 客观行为语料，供互评引用
 *   FR-M5-07 在线沟通        —— 文字 + 附件留言
 */
const route = useRoute()
const router = useRouter()

const recordId = Number(route.params.recordId)
const loading = ref(false)
const ws = ref<Workspace | null>(null)
/** 加载失败原因（用于展示错误态，避免页面空白无提示） */
const loadError = ref('')
const activeTab = ref<'tasks' | 'files' | 'messages' | 'timeline' | 'summary'>('tasks')

/**
 * 协作记录是否可读。
 *
 * 优先用后端的 collaborationReadable（已完成/已取消也为 true），
 * 回退到 collaborationActive 以兼容旧响应。
 */
const readable = computed(() => ws.value?.collaborationReadable ?? ws.value?.collaborationActive ?? false)

/* ---------------- 任务 ---------------- */
const taskDialog = ref(false)
const taskSaving = ref(false)
const editingTaskId = ref<number | null>(null)
const taskForm = reactive({
  title: '',
  description: '',
  assigneeSno: '' as string,
  deadline: '' as string
})

/* ---------------- 文件 ---------------- */
const uploading = ref(false)
const fileInput = ref<HTMLInputElement | null>(null)
const uploadGroupKey = ref<string | undefined>(undefined)
const uploadTaskId = ref<number | undefined>(undefined)
const uploadRemark = ref('')
const versionDialog = ref(false)
const versionList = ref<CollabFile[]>([])
const versionTitle = ref('')

/* ---------------- 留言 ---------------- */
const messageText = ref('')
const sending = ref(false)

const participants = computed(() => {
  if (!ws.value) return []
  return [ws.value.giver, ws.value.taker].filter(Boolean) as NonNullable<Workspace['giver']>[]
})

const summary = computed<ProcessSummary | undefined>(() => ws.value?.processSummary)

/** 任务按状态分组展示 */
const todoTasks = computed(() => ws.value?.tasks.filter((t) => t.status !== 'DONE') ?? [])
const doneTasks = computed(() => ws.value?.tasks.filter((t) => t.status === 'DONE') ?? [])

/**
 * 已完成任务中，已被协作方确认的数量（FR-M5-08）。
 *
 * 用于在"已完成"分组标题上直接显示"其中双方确认 N 个" ——
 * 这是本机制的价值所在：让"单方面宣称完成"在指标上一眼可见。
 */
const confirmedCount = computed(() => doneTasks.value.filter((t) => t.confirmed === true).length)

async function load() {
  loading.value = true
  loadError.value = ''
  try {
    ws.value = await workspaceApi.overview(recordId)
  } catch (e) {
    /*
     * 必须留下失败痕迹。
     *
     * 原先这里只写了一句注释（"拦截器已提示"）就吞掉异常，ws 保持 null，
     * 而模板里所有内容都挂在 v-if="ws" 下 —— 结果是整个 <main> 渲染为空，
     * 页面全白，用户看到的是"点了没反应/卡住"。
     * 这里记下原因，由模板的失败态展示出来。
     */
    ws.value = null
    loadError.value = e instanceof Error ? e.message : '该交换记录无法访问'
  } finally {
    loading.value = false
  }
}

/* ---------------- 任务操作 ---------------- */

function openCreateTask() {
  editingTaskId.value = null
  taskForm.title = ''
  taskForm.description = ''
  taskForm.assigneeSno = ''
  taskForm.deadline = ''
  taskDialog.value = true
}

function openEditTask(task: CollabTask) {
  editingTaskId.value = task.id
  taskForm.title = task.title
  taskForm.description = task.description ?? ''
  taskForm.assigneeSno = task.assigneeSno ?? ''
  taskForm.deadline = task.deadline ?? ''
  taskDialog.value = true
}

async function saveTask() {
  if (!taskForm.title.trim()) {
    ElMessage.warning('请填写任务标题')
    return
  }
  taskSaving.value = true
  try {
    const payload = {
      title: taskForm.title,
      description: taskForm.description || undefined,
      assigneeSno: taskForm.assigneeSno || undefined,
      deadline: taskForm.deadline || undefined
    }
    if (editingTaskId.value) {
      await workspaceApi.updateTask(recordId, editingTaskId.value, payload)
      ElMessage.success('任务已更新')
    } else {
      await workspaceApi.createTask(recordId, payload)
      ElMessage.success('任务已创建')
    }
    taskDialog.value = false
    await load()
  } catch {
    // 已提示
  } finally {
    taskSaving.value = false
  }
}

/** 打卡完成：DONE 需要填证据地址（可选） */
async function checkIn(task: CollabTask) {
  let evidenceUrl: string | undefined
  try {
    const res = await ElMessageBox.prompt('可以附上成果证据地址（可选，便于互评时佐证）', '任务打卡', {
      confirmButtonText: '确认完成',
      cancelButtonText: '取消',
      inputPlaceholder: '如 https://... 或文件链接',
      inputValue: task.evidenceUrl ?? ''
    })
    evidenceUrl = res.value || undefined
  } catch {
    return
  }
  try {
    await workspaceApi.updateTask(recordId, task.id, { status: 'DONE', evidenceUrl })
    ElMessage.success('已打卡完成')
    await load()
  } catch {
    // 已提示
  }
}

async function setTaskStatus(task: CollabTask, status: 'TODO' | 'DOING') {
  try {
    await workspaceApi.updateTask(recordId, task.id, { status })
    ElMessage.success(status === 'DOING' ? '已标记为进行中' : '已退回待开始')
    await load()
  } catch {
    // 已提示
  }
}

/* ---------------- FR-M5-08 阶段性成果双向确认 ---------------- */

/**
 * 确认协作方提交的阶段成果。
 *
 * <p>`canConfirm` 由服务端判定下发（"是交换参与方且不是打卡者"），
 * 前端不重复实现该规则 —— 复刻必然走样，走样的后果是
 * 用户看到可点的按钮、点下去却报错。
 */
async function confirmTask(task: CollabTask) {
  let remark: string | undefined
  try {
    const res = await ElMessageBox.prompt(
      `确认「${task.title}」这一阶段成果吗？确认后该成果将计入"双方认可"的过程指标。`,
      '确认阶段成果',
      {
        confirmButtonText: '确认通过',
        cancelButtonText: '再看看',
        inputPlaceholder: '确认说明（可选，有补充意见可写在这里）',
        inputValue: ''
      }
    )
    remark = res.value || undefined
  } catch {
    return
  }
  try {
    await workspaceApi.confirmTask(recordId, task.id, remark)
    ElMessage.success('已确认该阶段成果，双方达成一致')
    await load()
  } catch {
    // 已提示（自确认、重复确认等由服务端给出具体原因）
  }
}

/**
 * 撤回已完成的打卡，退回"进行中"重做。
 *
 * <p>撤回会同时清空对方的确认 —— 成果已经改变，旧的认可对新成果不成立。
 * 这一点必须在确认框里讲清楚，否则用户会以为只是改个状态而已。
 */
async function revertTask(task: CollabTask) {
  const hasConfirm = task.confirmed === true
  try {
    await ElMessageBox.confirm(
      hasConfirm
        ? `「${task.title}」已被协作方确认。撤回重做将同时清空该确认（成果已变更，原确认不再适用），确定继续吗？`
        : `确定把「${task.title}」退回「进行中」重做吗？`,
      '撤回完成状态',
      { confirmButtonText: '撤回重做', cancelButtonText: '取消', type: 'warning' }
    )
  } catch {
    return
  }
  try {
    await workspaceApi.updateTask(recordId, task.id, { status: 'DOING' })
    ElMessage.success(hasConfirm ? '已撤回，对方的确认已同时清空' : '已退回进行中')
    await load()
  } catch {
    // 已提示
  }
}

async function removeTask(task: CollabTask) {
  try {
    await ElMessageBox.confirm(`确定删除任务「${task.title}」吗？`, '删除任务', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch {
    return
  }
  try {
    await workspaceApi.deleteTask(recordId, task.id)
    ElMessage.success('已删除')
    await load()
  } catch {
    // 已完成任务不可删除，服务端会给出说明
  }
}

/* ---------------- 文件操作 ---------------- */

function pickFile(groupKey?: string, taskId?: number) {
  uploadGroupKey.value = groupKey
  uploadTaskId.value = taskId
  uploadRemark.value = ''
  fileInput.value?.click()
}

async function onFilePicked(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  uploading.value = true
  try {
    const res = await workspaceApi.upload(recordId, file, {
      groupKey: uploadGroupKey.value,
      taskId: uploadTaskId.value,
      remark: uploadRemark.value || undefined
    })
    ElMessage.success(res.version > 1 ? `已上传第 ${res.version} 版` : '文件已上传')
    await load()
  } catch {
    // 已提示
  } finally {
    uploading.value = false
    input.value = ''
  }
}

async function showVersions(file: CollabFile) {
  try {
    versionList.value = await workspaceApi.listFiles(recordId, file.groupKey)
    versionTitle.value = file.fileName
    versionDialog.value = true
  } catch {
    // 已提示
  }
}

async function download(file: CollabFile) {
  try {
    await downloadCollabFile(file.id, file.fileName)
  } catch (e) {
    ElMessage.error((e as Error).message)
  }
}

/* ---------------- 留言 ---------------- */

async function sendMessage() {
  if (!messageText.value.trim()) {
    ElMessage.warning('请输入留言内容')
    return
  }
  sending.value = true
  try {
    await workspaceApi.sendMessage(recordId, { content: messageText.value })
    messageText.value = ''
    await load()
  } catch {
    // 已提示
  } finally {
    sending.value = false
  }
}

/* ---------------- 状态流转 ---------------- */

function actionLabel(target: string) {
  switch (target) {
    case 'IN_PROGRESS':
      return '开始协作'
    case 'PENDING_EVAL':
      return '提交完成，进入互评'
    case 'COMPLETED':
      return '确认完成'
    case 'CANCELLED':
      return '取消交换'
    case 'DISPUTED':
      return '发起争议'
    default:
      return target
  }
}

async function transition(target: string) {
  try {
    await ElMessageBox.confirm(`确定执行「${actionLabel(target)}」吗？`, '状态变更', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: target === 'CANCELLED' ? 'warning' : 'info'
    })
  } catch {
    return
  }
  try {
    await exchangeApi.changeStatus(recordId, target)
    ElMessage.success('状态已更新')
    await load()
  } catch {
    // 已提示
  }
}

/**
 * 格式化日期时间。
 *
 * 参数接受 null：后端配了 `default-property-inclusion: non_null`，
 * 可空时间字段在响应里可能直接缺失或为 null，签名收得太窄会到处要加 `?? undefined`。
 */
function fmtDate(t?: string | null) {
  if (!t) return ''
  return t.replace('T', ' ').slice(0, 16)
}

function msgTime(t?: string) {
  if (!t) return ''
  return t.slice(11, 16)
}

onMounted(load)
</script>

<template>
  <div class="zy-page" v-loading="loading">
    <!-- 头部 -->
    <div v-if="ws" class="zy-card head">
      <div class="head__left">
        <div class="head__title-row">
          <h3 class="head__title">{{ ws.title }}</h3>
          <el-tag size="small" effect="plain">{{ ws.statusLabel }}</el-tag>
          <el-tag size="small" type="info" effect="plain">{{ ws.recordNo }}</el-tag>
          <el-tag v-if="ws.myRole && ws.myRole !== 'OBSERVER'" size="small" type="success" effect="plain">
            {{ ws.myRole === 'GIVER' ? '我是供给方' : '我是需求方' }}
          </el-tag>
          <el-tag v-if="ws.myRole === 'OBSERVER'" size="small" type="warning" effect="plain">
            管理员视角（只读）
          </el-tag>
        </div>

        <!-- 以技易技的双向置换 -->
        <div class="exchange">
          <div class="party">
            <span class="party__who">{{ ws.giver?.name }}</span>
            <span class="party__skill">提供「{{ ws.giver?.provideSkillName }}」</span>
          </div>
          <span class="exchange__arrow">⇄</span>
          <div class="party">
            <span class="party__who">{{ ws.taker?.name }}</span>
            <span class="party__skill">提供「{{ ws.taker?.provideSkillName }}」</span>
          </div>
        </div>

        <div class="head__meta">
          <span v-if="ws.startedAt">开始于 {{ fmtDate(ws.startedAt) }}</span>
          <span v-if="ws.expectedHours">预计 {{ ws.expectedHours }} 小时</span>
          <span v-if="ws.actualHours">实际 {{ ws.actualHours }} 小时</span>
        </div>
      </div>

      <div class="head__right">
        <el-button
          v-for="t in ws.allowedNextStatus ?? []"
          :key="t"
          size="small"
          :type="t === 'CANCELLED' ? 'default' : t === 'DISPUTED' ? 'danger' : 'primary'"
          :plain="t === 'CANCELLED'"
          @click="transition(t)"
        >{{ actionLabel(t) }}</el-button>
        <el-button size="small" text @click="router.push({ name: 'Exchanges' })">返回我的交换</el-button>
      </div>
    </div>

    <!--
      协作还没开始（洽谈中/已发布）：确实没有内容可看，给引导。
      注意判据用 collaborationReadable 而不是 collaborationActive ——
      后者在交换完成后为 false，会让已完成交换的页面整个变白。
    -->
    <el-alert
      v-if="ws && !readable"
      type="info"
      :closable="false"
      show-icon
      title="协作空间尚未开启"
      :description="`当前状态为「${ws.statusLabel}」，交换进入「进行中」后才能拆解任务、上传文件与留言。`"
    />

    <!-- 交换已结束：内容只读保留，让用户能回看自己做过什么 -->
    <el-alert
      v-else-if="ws && !ws.collaborationActive"
      type="success"
      :closable="false"
      show-icon
      title="该交换已结束，以下为只读的协作记录"
      :description="`当前状态为「${ws.statusLabel}」。任务、交付文件、留言与时间轴作为过程留痕永久保留，但不再允许修改。`"
    />

    <!--
      加载失败态。
      必须有这一块：此前 load() 的异常被 catch 吞掉、ws 保持 null，
      于是上面所有 v-if="ws" 都不成立 —— <main> 里一个元素都没有，
      页面完全空白且没有任何提示。用户点进来只会以为"卡住了"。
    -->
    <el-alert
      v-if="!loading && !ws"
      type="error"
      :closable="false"
      show-icon
      title="无法打开该协作空间"
      :description="loadError || '交换记录不存在，或你不是本次交换的参与方。'"
    />
    <div v-if="!loading && !ws" class="load-error-actions">
      <el-button @click="router.push({ name: 'Exchanges' })">返回我的交换</el-button>
    </div>

    <template v-if="ws && readable">
      <!-- 关键指标速览 -->
      <el-row :gutter="12" class="stats">
        <el-col :span="6">
          <div class="zy-card stat">
            <div class="stat__v">{{ summary?.taskDone ?? 0 }}/{{ summary?.taskTotal ?? 0 }}</div>
            <div class="stat__l">任务完成</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="zy-card stat">
            <div class="stat__v" :class="{ 'stat__v--warn': (summary?.taskOverdue ?? 0) > 0 }">
              {{ summary?.taskOverdue ?? 0 }}
            </div>
            <div class="stat__l">逾期任务</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="zy-card stat">
            <div class="stat__v">{{ summary?.messageTotal ?? 0 }}</div>
            <div class="stat__l">协作留言</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="zy-card stat">
            <div class="stat__v">{{ summary?.fileGroupTotal ?? 0 }}</div>
            <div class="stat__l">交付文件</div>
          </div>
        </el-col>
      </el-row>

      <!-- 选项卡 -->
      <div class="zy-card tabs">
        <el-radio-group v-model="activeTab" size="small">
          <el-radio-button value="tasks">任务（{{ ws.tasks.length }}）</el-radio-button>
          <el-radio-button value="files">文件（{{ ws.files.length }}）</el-radio-button>
          <el-radio-button value="messages">留言（{{ ws.messages.length }}）</el-radio-button>
          <el-radio-button value="timeline">时间轴（{{ ws.timeline.length }}）</el-radio-button>
          <el-radio-button value="summary">过程指标</el-radio-button>
        </el-radio-group>
      </div>

      <!-- ---------------- 任务 ---------------- -->
      <div v-if="activeTab === 'tasks'" class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">任务拆解与打卡</span>
          <div class="panel__actions">
            <el-button v-if="ws.canManageTasks" size="small" type="primary" @click="openCreateTask">
              新建任务
            </el-button>
          </div>
        </div>

        <div v-if="ws.tasks.length === 0" class="empty-hint">
          还没有任务。建议把协作拆成 3~5 个可交付的小任务，这样双方的投入都能被记录与评价。
        </div>

        <div v-for="task in todoTasks" :key="task.id" class="task">
          <div class="task__main">
            <div class="task__top">
              <el-tag size="small" :type="task.status === 'DOING' ? 'primary' : 'info'" effect="plain">
                {{ task.statusLabel }}
              </el-tag>
              <span class="task__title">{{ task.title }}</span>
              <el-tag v-if="task.overdue" size="small" type="danger" effect="plain">已逾期</el-tag>
              <el-tag v-if="task.assigneeName" size="small" effect="plain">{{ task.assigneeName }}</el-tag>
              <el-tag v-else size="small" type="warning" effect="plain">共同负责</el-tag>
              <span v-if="task.deadline" class="task__deadline">截止 {{ fmtDate(task.deadline) }}</span>
            </div>
            <div v-if="task.description" class="task__desc">{{ task.description }}</div>
            <div v-if="task.evidenceUrl" class="task__evidence">证据：{{ task.evidenceUrl }}</div>
          </div>
          <div class="task__ops">
            <el-button v-if="task.status === 'TODO'" size="small" plain @click="setTaskStatus(task, 'DOING')">
              开始
            </el-button>
            <el-button size="small" type="primary" @click="checkIn(task)">打卡完成</el-button>
            <el-button size="small" text @click="openEditTask(task)">编辑</el-button>
            <el-button size="small" text type="danger" @click="removeTask(task)">删除</el-button>
          </div>
        </div>

        <!--
          已完成分组（FR-M5-08）。
          「已完成」只是"某人宣称完成"，必须再区分"是否已被协作方确认" ——
          否则单方面打卡与双方认可在界面上看起来一样，本机制就白做了。
        -->
        <div v-if="doneTasks.length" class="done-group">
          <div class="done-group__title">
            已完成（{{ doneTasks.length }}）
            <span class="done-group__sub">
              其中已被协作方确认 {{ confirmedCount }} 个
            </span>
          </div>
          <div v-for="task in doneTasks" :key="task.id" class="task task--done">
            <div class="task__main">
              <div class="task__top">
                <el-tag size="small" type="success" effect="plain">已完成</el-tag>
                <el-tag
                  v-if="task.confirmed"
                  size="small"
                  type="success"
                  effect="dark"
                >双方已确认</el-tag>
                <el-tag v-else size="small" type="warning" effect="plain">待协作方确认</el-tag>
                <span class="task__title">{{ task.title }}</span>
                <el-tag v-if="task.assigneeName" size="small" effect="plain">{{ task.assigneeName }}</el-tag>
                <span class="task__deadline">完成于 {{ fmtDate(task.doneAt) }}</span>
              </div>
              <div v-if="task.description" class="task__desc">{{ task.description }}</div>
              <div v-if="task.evidenceUrl" class="task__evidence">证据：{{ task.evidenceUrl }}</div>
              <div v-if="task.confirmed" class="task__confirm">
                由 {{ task.confirmedByName || task.confirmedBy }} 于 {{ fmtDate(task.confirmedAt) }} 确认
                <template v-if="task.confirmRemark"> · {{ task.confirmRemark }}</template>
              </div>
            </div>
            <div class="task__ops">
              <!-- canConfirm 由服务端判定下发，前端不自行推断 -->
              <el-button
                v-if="task.canConfirm"
                size="small"
                type="success"
                @click="confirmTask(task)"
              >确认成果</el-button>
              <el-button size="small" text @click="openEditTask(task)">编辑</el-button>
              <el-button
                v-if="task.status === 'DONE'"
                size="small"
                text
                type="warning"
                @click="revertTask(task)"
              >撤回重做</el-button>
            </div>
          </div>
        </div>
      </div>

      <!-- ---------------- 文件 ---------------- -->
      <div v-else-if="activeTab === 'files'" class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">交付文件与版本</span>
          <div class="panel__actions">
            <el-button v-if="ws.canUpload" size="small" type="primary" :loading="uploading" @click="pickFile()">
              上传新文件
            </el-button>
          </div>
        </div>

        <div v-if="ws.files.length === 0" class="empty-hint">
          还没有文件。上传的同一文件重复上传会自动生成新版本，历史版本保留可回溯。
        </div>

        <div v-for="file in ws.files" :key="file.id" class="file">
          <div class="file__icon">📎</div>
          <div class="file__main">
            <div class="file__top">
              <span class="file__name">{{ file.fileName }}</span>
              <el-tag size="small" effect="plain">v{{ file.version }}</el-tag>
              <el-tag v-if="(file.versionCount ?? 1) > 1" size="small" type="warning" effect="plain">
                共 {{ file.versionCount }} 个版本
              </el-tag>
              <span class="file__size">{{ file.sizeText }}</span>
            </div>
            <div class="file__meta">
              <span>上传者：{{ file.uploaderName || file.uploaderSno }}</span>
              <span>{{ fmtDate(file.createdAt) }}</span>
              <span v-if="file.taskTitle">关联任务：{{ file.taskTitle }}</span>
            </div>
            <div v-if="file.remark" class="file__remark">{{ file.remark }}</div>
          </div>
          <div class="file__ops">
            <el-button size="small" plain @click="download(file)">下载</el-button>
            <el-button
              v-if="(file.versionCount ?? 1) > 1"
              size="small"
              text
              @click="showVersions(file)"
            >历史版本</el-button>
            <el-button
              v-if="ws.canUpload"
              size="small"
              text
              type="primary"
              @click="pickFile(file.groupKey)"
            >上传新版本</el-button>
          </div>
        </div>

        <!-- 隐藏的文件选择器 -->
        <input
          ref="fileInput"
          type="file"
          class="hidden-input"
          @change="onFilePicked"
        />
      </div>

      <!-- ---------------- 留言 ---------------- -->
      <div v-else-if="activeTab === 'messages'" class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">协作沟通</span>
          <span class="panel__hint">留言记录会永久留存，作为过程性评价与争议仲裁的依据</span>
        </div>

        <div class="chat">
          <div v-if="ws.messages.length === 0" class="empty-hint">还没有留言，打个招呼吧</div>
          <div
            v-for="m in ws.messages"
            :key="m.id"
            class="bubble"
            :class="{ 'bubble--mine': m.mine }"
          >
            <div class="bubble__head">
              <span class="bubble__who">{{ m.senderName || m.senderSno }}</span>
              <span class="bubble__time">{{ msgTime(m.createdAt) }}</span>
            </div>
            <div class="bubble__body">
              <span v-if="m.content">{{ m.content }}</span>
              <span v-if="m.fileId" class="bubble__file">📎 {{ m.fileName }}</span>
            </div>
          </div>
        </div>

        <div class="compose">
          <el-input
            v-model="messageText"
            type="textarea"
            :rows="2"
            maxlength="2000"
            placeholder="输入留言（Ctrl+Enter 发送）"
            @keydown.ctrl.enter="sendMessage"
          />
          <el-button type="primary" :loading="sending" :disabled="!ws.canSendMessage" @click="sendMessage">
            发送
          </el-button>
        </div>
      </div>

      <!-- ---------------- 时间轴 ---------------- -->
      <div v-else-if="activeTab === 'timeline'" class="zy-card panel">
        <div class="panel__head">
          <span class="panel__title">协作时间轴</span>
          <span class="panel__hint">按时间倒序记录全部协作事件（FR-M5-04）</span>
        </div>
        <div class="timeline">
          <div v-for="e in ws.timeline" :key="e.id" class="tl-item">
            <div class="tl-item__icon">{{ e.icon }}</div>
            <div class="tl-item__body">
              <div class="tl-item__title">{{ e.title }}</div>
              <div v-if="e.detail" class="tl-item__detail">{{ e.detail }}</div>
              <div class="tl-item__meta">
                <span v-if="e.actorName">{{ e.actorName }}</span>
                <span>{{ e.occurredAt }}</span>
              </div>
            </div>
          </div>
          <el-empty v-if="ws.timeline.length === 0" description="暂无协作事件" :image-size="60" />
        </div>
      </div>

      <!-- ---------------- 过程指标 ---------------- -->
      <div v-else class="panel-wrap">
        <el-alert
          class="mb"
          type="info"
          :closable="false"
          show-icon
          title="这些是客观行为数据，不是评分"
          description="它们会与双向互评一起呈现，用于互相印证，减少凭印象打分与互刷好评的空间（FR-M5-06）。"
        />

        <div v-if="summary" class="zy-card panel">
          <div class="panel__head"><span class="panel__title">整体指标</span></div>
          <div class="metric-grid">
            <div class="metric">
              <span class="metric__l">任务完成率</span>
              <span class="metric__v">
                {{ summary.taskCompletionRate != null ? Math.round(summary.taskCompletionRate * 100) + '%' : '—' }}
              </span>
              <span class="metric__d">{{ summary.taskDone ?? 0 }} / {{ summary.taskTotal ?? 0 }} 项</span>
            </div>
            <div class="metric">
              <span class="metric__l">按期完成率</span>
              <span class="metric__v">
                {{ summary.onTimeRate != null ? Math.round(summary.onTimeRate * 100) + '%' : '—' }}
              </span>
              <span class="metric__d">仅统计有截止时间的已完成任务</span>
            </div>
            <div class="metric">
              <span class="metric__l">任务拆解粒度</span>
              <span class="metric__v">{{ summary.decompositionGranularity ?? 0 }}</span>
              <span class="metric__d">任务数 / 参与人数</span>
            </div>
            <div class="metric">
              <span class="metric__l">启动速度</span>
              <span class="metric__v">{{ summary.firstActionDelayHours ?? '—' }}</span>
              <span class="metric__d">交换开始到首个动作的小时数</span>
            </div>
            <div class="metric">
              <span class="metric__l">停留时长</span>
              <span class="metric__v">
                {{ summary.durationMinutes != null ? Math.round(summary.durationMinutes / 60) : '—' }}
              </span>
              <span class="metric__d">小时（自交换开始）</span>
            </div>
            <div class="metric">
              <span class="metric__l">最近活跃</span>
              <span class="metric__v">
                {{ summary.idleMinutes != null ? summary.idleMinutes + ' 分钟前' : '—' }}
              </span>
              <span class="metric__d">距最后一次协作动作</span>
            </div>
          </div>
        </div>

        <div v-if="summary" class="zy-card panel mt">
          <div class="panel__head"><span class="panel__title">按参与方明细</span></div>
          <el-row :gutter="12">
            <el-col v-for="p in summary.participants" :key="p.sno" :span="12">
              <div class="pcard">
                <div class="pcard__head">
                  <span class="pcard__name">{{ p.name || p.sno }}</span>
                  <el-tag size="small" effect="plain">{{ p.role === 'GIVER' ? '供给方' : '需求方' }}</el-tag>
                </div>
                <div class="pcard__college">{{ p.college }}</div>
                <div class="pcard__rows">
                  <div class="prow"><span>负责任务</span><b>{{ p.assignedTasks ?? 0 }} 项（完成 {{ p.doneTasks ?? 0 }}）</b></div>
                  <div class="prow">
                    <span>完成率</span>
                    <b>{{ p.completionRate != null ? Math.round(p.completionRate * 100) + '%' : '—' }}</b>
                  </div>
                  <div class="prow">
                    <span>逾期任务</span>
                    <b :class="{ 'prow--warn': (p.overdueTasks ?? 0) > 0 }">{{ p.overdueTasks ?? 0 }} 项</b>
                  </div>
                  <div class="prow"><span>共同任务</span><b>{{ p.sharedTasks ?? 0 }} 项</b></div>
                  <div class="prow"><span>留言 / 上传</span><b>{{ p.messages ?? 0 }} 条 / {{ p.fileUploads ?? 0 }} 次</b></div>
                  <div class="prow"><span>协作事件</span><b>{{ p.eventCount ?? 0 }} 次</b></div>
                </div>
                <div class="pcard__digest">{{ p.digest }}</div>
              </div>
            </el-col>
          </el-row>
        </div>
      </div>
    </template>

    <!-- ---------------- 任务编辑对话框 ---------------- -->
    <el-dialog v-model="taskDialog" :title="editingTaskId ? '编辑任务' : '新建任务'" width="560px">
      <el-form label-width="88px" label-position="left">
        <el-form-item label="任务标题" required>
          <el-input v-model="taskForm.title" maxlength="200" show-word-limit
                    placeholder="如：完成交互稿 v1" />
        </el-form-item>
        <el-form-item label="任务说明">
          <el-input v-model="taskForm.description" type="textarea" :rows="3" maxlength="500" show-word-limit
                    placeholder="说明交付标准，便于双方对齐预期" />
        </el-form-item>
        <el-form-item label="负责人">
          <el-select v-model="taskForm.assigneeSno" clearable placeholder="留空表示双方共同负责" style="width: 100%">
            <el-option
              v-for="p in participants"
              :key="p.sno"
              :label="`${p.name || p.sno}（${p.sno === ws?.giver?.sno ? '供给方' : '需求方'}）`"
              :value="p.sno"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="截止时间">
          <el-date-picker
            v-model="taskForm.deadline"
            type="datetime"
            value-format="YYYY-MM-DD HH:mm:ss"
            placeholder="选择截止时间（留空则不计入按期率）"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="taskDialog = false">取消</el-button>
        <el-button type="primary" :loading="taskSaving" @click="saveTask">保存</el-button>
      </template>
    </el-dialog>

    <!-- ---------------- 历史版本对话框 ---------------- -->
    <el-dialog v-model="versionDialog" :title="`历史版本：${versionTitle}`" width="620px">
      <div v-for="v in versionList" :key="v.id" class="ver">
        <div class="ver__left">
          <el-tag size="small" :type="v.latest ? 'success' : 'info'" effect="plain">v{{ v.version }}</el-tag>
          <span class="ver__name">{{ v.fileName }}</span>
          <el-tag v-if="v.latest" size="small" type="success" effect="dark">当前版本</el-tag>
        </div>
        <div class="ver__right">
          <span class="ver__meta">{{ v.sizeText }} · {{ fmtDate(v.createdAt) }}</span>
          <el-button size="small" text type="primary" @click="download(v)">下载</el-button>
        </div>
        <div v-if="v.remark" class="ver__remark">{{ v.remark }}</div>
      </div>
    </el-dialog>
  </div>
</template>

<style scoped>
.mb {
  margin-bottom: 12px;
}

.mt {
  margin-top: 12px;
}

/* ---------------- 头部 ---------------- */
.head {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  padding: 16px 18px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.head__title-row {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.head__title {
  margin: 0;
  font-size: 17px;
}

.exchange {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 12px 0 8px;
  flex-wrap: wrap;
}

.party {
  display: flex;
  flex-direction: column;
  padding: 7px 11px;
  border-radius: var(--zy-radius);
  background: rgba(47, 125, 143, 0.08);
}

.party__who {
  font-size: 12.5px;
  font-weight: 600;
}

.party__skill {
  font-size: 11px;
  color: var(--zy-text-secondary);
}

.exchange__arrow {
  color: var(--zy-accent);
  font-size: 16px;
  font-weight: 700;
}

.head__meta {
  display: flex;
  gap: 12px;
  font-size: 11.5px;
  color: var(--zy-text-secondary);
  flex-wrap: wrap;
}

.head__right {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  flex-wrap: wrap;
}

/* ---------------- 概览 ---------------- */
.stats {
  margin-bottom: 12px;
}

.stat {
  padding: 12px 16px;
  text-align: center;
}

.stat__v {
  font-size: 20px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  line-height: 1.3;
}

.stat__v--warn {
  color: #c96a4f;
}

.stat__l {
  font-size: 11.5px;
  color: var(--zy-text-secondary);
}

.tabs {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  margin-bottom: 12px;
}

.panel {
  padding: 16px 18px;
}

.panel-wrap {
  display: flex;
  flex-direction: column;
}

.panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}

.panel__title {
  font-size: 15px;
  font-weight: 600;
}

.panel__hint {
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}

.panel__actions {
  display: flex;
  gap: 8px;
}

.empty-hint {
  padding: 18px 0;
  font-size: 12.5px;
  line-height: 1.8;
  color: var(--zy-text-placeholder);
  text-align: center;
}

/* ---------------- 任务 ---------------- */
.task {
  display: flex;
  justify-content: space-between;
  gap: 14px;
  padding: 11px 0;
  border-bottom: 1px dashed var(--zy-border-light);
  flex-wrap: wrap;
}

.task:last-child {
  border-bottom: none;
}

.task--done {
  opacity: 0.62;
}

.task__main {
  flex: 1;
  min-width: 280px;
}

.task__top {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.task__title {
  font-size: 13.5px;
  font-weight: 600;
}

.task__deadline {
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.task__desc {
  margin-top: 4px;
  font-size: 12px;
  color: var(--zy-text-regular);
}

.task__evidence {
  margin-top: 4px;
  font-size: 11px;
  color: var(--zy-dim-data);
  word-break: break-all;
}

.task__ops {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

.done-group {
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px solid var(--zy-border);
}

.done-group__title {
  font-size: 12.5px;
  font-weight: 600;
  color: var(--zy-text-secondary);
  margin-bottom: 6px;
}

/* ---------------- 文件 ---------------- */
.file {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 0;
  border-bottom: 1px dashed var(--zy-border-light);
  flex-wrap: wrap;
}

.file:last-of-type {
  border-bottom: none;
}

.file__icon {
  font-size: 20px;
}

.file__main {
  flex: 1;
  min-width: 260px;
}

.file__top {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.file__name {
  font-size: 13.5px;
  font-weight: 600;
}

.file__size {
  font-size: 11.5px;
  color: var(--zy-text-placeholder);
}

.file__meta {
  display: flex;
  gap: 12px;
  margin-top: 3px;
  font-size: 11px;
  color: var(--zy-text-secondary);
  flex-wrap: wrap;
}

.file__remark {
  margin-top: 3px;
  font-size: 11.5px;
  color: var(--zy-text-regular);
}

.file__ops {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.hidden-input {
  display: none;
}

/* ---------------- 留言 ---------------- */
.chat {
  max-height: 420px;
  overflow-y: auto;
  padding: 6px 2px 12px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.bubble {
  max-width: 76%;
  align-self: flex-start;
  padding: 8px 12px;
  border-radius: 10px;
  background: #f4f7f8;
}

.bubble--mine {
  align-self: flex-end;
  background: rgba(47, 125, 143, 0.1);
}

.bubble__head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 3px;
}

.bubble__who {
  font-size: 11.5px;
  font-weight: 600;
}

.bubble__time {
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
}

.bubble__body {
  font-size: 12.5px;
  line-height: 1.7;
  word-break: break-word;
}

.bubble__file {
  display: inline-block;
  margin-left: 6px;
  padding: 2px 7px;
  border-radius: var(--zy-radius-sm);
  background: rgba(224, 139, 60, 0.14);
  color: #a8661f;
  font-size: 11.5px;
}

.compose {
  display: flex;
  gap: 10px;
  align-items: flex-end;
  padding-top: 12px;
  border-top: 1px solid var(--zy-border);
}

.compose :deep(.el-textarea) {
  flex: 1;
}

/* ---------------- 时间轴 ---------------- */
.timeline {
  max-height: 520px;
  overflow-y: auto;
}

.tl-item {
  display: flex;
  gap: 12px;
  padding: 9px 0;
  border-left: 2px solid var(--zy-border);
  margin-left: 12px;
  padding-left: 16px;
  position: relative;
}

.tl-item__icon {
  position: absolute;
  left: -13px;
  top: 8px;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #fff;
  border: 1px solid var(--zy-border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.tl-item__body {
  flex: 1;
}

.tl-item__title {
  font-size: 13px;
  font-weight: 600;
}

.tl-item__detail {
  margin-top: 2px;
  font-size: 11.5px;
  color: var(--zy-text-regular);
}

.tl-item__meta {
  display: flex;
  gap: 10px;
  margin-top: 3px;
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
}

/* ---------------- 过程指标 ---------------- */
.metric-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 12px;
}

.metric {
  display: flex;
  flex-direction: column;
  padding: 12px 14px;
  border-radius: var(--zy-radius);
  background: #fbfdfe;
  border: 1px solid var(--zy-border-light);
}

.metric__l {
  font-size: 12px;
  color: var(--zy-text-secondary);
}

.metric__v {
  font-size: 20px;
  font-weight: 700;
  color: var(--zy-primary-dark);
  line-height: 1.4;
}

.metric__d {
  font-size: 10.5px;
  color: var(--zy-text-placeholder);
}

.pcard {
  padding: 14px;
  border-radius: var(--zy-radius);
  border: 1px solid var(--zy-border-light);
  background: #fbfdfe;
  margin-bottom: 12px;
}

.pcard__head {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pcard__name {
  font-size: 14px;
  font-weight: 700;
}

.pcard__college {
  margin-top: 2px;
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.pcard__rows {
  margin-top: 10px;
}

.prow {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 4px 0;
  font-size: 12px;
  color: var(--zy-text-secondary);
  border-bottom: 1px dashed var(--zy-border-light);
}

.prow b {
  color: var(--zy-text-primary);
  font-weight: 600;
}

.prow--warn {
  color: #c96a4f !important;
}

.pcard__digest {
  margin-top: 10px;
  padding: 8px 10px;
  border-radius: var(--zy-radius-sm);
  background: rgba(47, 125, 143, 0.07);
  font-size: 11.5px;
  line-height: 1.7;
  color: var(--zy-primary-dark);
}

/* ---------------- 版本对话框 ---------------- */
.ver {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px dashed var(--zy-border-light);
  flex-wrap: wrap;
}

.ver__left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.ver__name {
  font-size: 13px;
  font-weight: 600;
}

.ver__right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.ver__meta {
  font-size: 11px;
  color: var(--zy-text-placeholder);
}

.ver__remark {
  width: 100%;
  font-size: 11.5px;
  color: var(--zy-text-regular);
}
.load-error-actions {
  margin-top: 12px;
}

/* ---------------- FR-M5-08 双向确认 ---------------- */

.done-group__sub {
  margin-left: 8px;
  font-size: 11.5px;
  font-weight: 400;
  color: var(--zy-text-placeholder);
}

.task__confirm {
  margin-top: 4px;
  padding: 4px 8px;
  border-radius: var(--zy-radius-sm);
  background: rgba(103, 194, 58, 0.1);
  font-size: 11px;
  line-height: 1.6;
  color: #3f7a1f;
}
</style>
