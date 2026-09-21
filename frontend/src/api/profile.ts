import { request } from './request'
import type {
  AbilityReport,
  Badge,
  DataExport,
  GrowthTrend,
  RadarChart,
  SkillProfile,
  SkillProfileSaveItem,
  UserInfo,
  WeeklyReport
} from './types'

/**
 * 数字档案与能力画像接口（模块 M7）。
 *
 * 全部返回"我的"数据，学号由服务端从登录态取，前端不传 —— 避免越权。
 */
export const profileApi = {
  /**
   * 修改个人资料（FR-M1-05）。
   *
   * 只能改"自我介绍类"字段：昵称、学院、专业、年级、头像、简介。
   * 学号、姓名、角色、信用值、核验状态由服务端保护，传了也不会生效。
   *
   * 字段语义：**不传（undefined）表示不修改，传空串表示清空**。
   * 切忌把未填写的字段补成 null —— 后端把 null 视为"不修改"，
   * 而 MyBatis-Plus 也会跳过 null 字段，两者叠加会让"清空"静默失效。
   */
  updateProfile(data: {
    nickname?: string
    college?: string
    major?: string
    grade?: string
    avatar?: string
    intro?: string
  }) {
    return request<UserInfo>({ url: '/profile', method: 'put', data })
  },

  /** 能力雷达图（FR-M7-01/02）。实时计算，完成交换后立即刷新。 */
  radar() {
    return request<RadarChart>({ url: '/profile/radar', method: 'get' })
  },

  /**
   * 导出我的全部个人数据（FR-M1-07）。
   *
   * 返回结构化 JSON，由 `downloadJson()` 落成文件。
   * 与《能力鉴定报告》分工不同：报告是给第三方看的凭证，
   * 本接口是给用户自己的完整底稿。
   */
  exportData() {
    return request<DataExport>({ url: '/profile/export', method: 'get' })
  },

  /** 成长轨迹（FR-M7-07）：基于月度快照的历史曲线 */
  growth(limit = 12) {
    return request<GrowthTrend>({ url: '/profile/growth', method: 'get', params: { limit } })
  },

  /** 勋章列表（FR-M7-04）：含未解锁项与进度提示 */
  badges() {
    return request<Badge[]>({ url: '/profile/badges', method: 'get' })
  },

  /** 固化当前画像为一个快照点，便于立刻在成长轨迹中看到变化 */
  snapshot() {
    return request<{ snapshotId: number | null; period: string; message: string }>({
      url: '/profile/snapshot',
      method: 'post'
    })
  },

  /** 《跨学科协作能力鉴定报告》（FR-M7-06/08），带 M6 校验码可验真 */
  report() {
    return request<AbilityReport>({ url: '/profile/report', method: 'get' })
  },

  /** 成长周报列表（FR-M7-05） */
  weeklyReports(limit = 12) {
    return request<WeeklyReport[]>({
      url: '/profile/weekly-reports',
      method: 'get',
      params: { limit }
    })
  },

  /**
   * 我的技能画像（FR-M1-03 / FR-M2-02），按三类意图分组。
   *
   * 导引页与「技能画像」编辑页共用：前者用它回显（通常是空的），
   * 后者用它进入编辑态。
   */
  mySkills() {
    return request<SkillProfile>({ url: '/profile/skills', method: 'get' })
  },

  /**
   * 保存技能画像（FR-M1-03），**整体覆盖**自评部分。
   *
   * 语义是覆盖而非追加：调用方必须提交用户当前的完整选择，
   * 否则未提交的标签会被当作"用户取消了勾选"而删除。
   * 互评/课程来源的记录不受影响。
   */
  saveSkills(items: SkillProfileSaveItem[]) {
    return request<SkillProfile>({
      url: '/profile/skills',
      method: 'post',
      data: { items }
    })
  }
}

/**
 * 把导出数据落成 JSON 文件并触发下载（FR-M1-07）。
 *
 * <p><b>为什么用前端生成文件而不是后端直接返回附件</b>：
 * 后端的统一响应体是 {@code {code,message,data,traceId,timestamp}}，
 * 若为导出单独返回 {@code Content-Disposition: attachment}，
 * 就得在响应约定上开一个例外（拦截器要判断 content-type、跳过 code 校验）。
 * 前端已有完整数据，用 Blob 落盘成本更低，且能顺便把文件名带上导出时间。
 *
 * @param data 导出数据
 * @returns 落盘的文件名
 */
export function downloadExportJson(data: DataExport): string {
  const stamp = new Date().toISOString().slice(0, 19).replace(/[:T]/g, '-')
  const filename = `知驿漫游-个人数据-${data.sno}-${stamp}.json`
  const blob = new Blob([JSON.stringify(data, null, 2)], {
    type: 'application/json;charset=utf-8'
  })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  // 释放对象 URL，否则这份数据会一直占着内存直到页面关闭
  URL.revokeObjectURL(url)
  return filename
}

/**
 * 导出能力鉴定报告为可打印的 HTML 并唤起浏览器打印（另存为 PDF）。
 *
 * <p><b>为什么用前端排版而不是后端生成 PDF</b>：
 * 服务端生成 PDF 需要引入中文字体（体积大，且开源中文字体授权需逐一确认），
 * 而浏览器打印天然支持中文与分页样式。FR-M7-08 只要求"PDF 规范排版"，
 * 浏览器"打印为 PDF"完全满足，且零依赖、样式可控。
 */
export function exportReportAsPdf(report: AbilityReport) {
  const win = window.open('', '_blank')
  if (!win) {
    throw new Error('浏览器拦截了弹出窗口，请允许本站弹出窗口后重试')
  }
  win.document.write(buildReportHtml(report))
  win.document.close()
}

function esc(v: unknown): string {
  if (v === null || v === undefined) return '—'
  return String(v)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

function buildReportHtml(r: AbilityReport): string {
  const dimRows = (r.dimensions ?? [])
    .filter((d) => d.score !== null && d.score !== undefined)
    .map(
      (d) => `<tr>
        <td class="dim">${esc(d.label)}</td>
        <td class="score">${esc(d.score)}</td>
        <td class="ev">${esc(d.evidence)}</td>
      </tr>`
    )
    .join('')

  const exchangeRows = (r.exchanges ?? [])
    .map(
      (e) => `<tr>
        <td>${esc(e.recordNo)}</td>
        <td>${esc(e.title)}</td>
        <td>${esc(e.peerName)}</td>
        <td>${esc(e.providedSkill)}</td>
        <td>${esc(e.acquiredSkill)}</td>
        <td class="num">${esc(e.hours)}</td>
        <td class="num">${esc(e.receivedScore)}</td>
      </tr>`
    )
    .join('')

  const badgeText = (r.badges ?? []).map((b) => esc(b.name)).join('、') || '暂无'
  const strengthText = (r.strengths ?? []).map((s) => `<li>${esc(s)}</li>`).join('')

  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<title>跨学科协作能力鉴定报告 · ${esc(r.name)}</title>
<style>
  @page { size: A4; margin: 18mm 16mm; }
  * { box-sizing: border-box; }
  body { font-family: "Microsoft YaHei", "PingFang SC", sans-serif; color: #1f2d33; margin: 0; font-size: 12px; line-height: 1.7; }
  .head { border-bottom: 3px solid #2f7d8f; padding-bottom: 10px; margin-bottom: 16px; }
  h1 { font-size: 20px; margin: 0 0 6px; letter-spacing: 1px; }
  .sub { color: #5c7178; font-size: 11px; }
  .meta { display: flex; flex-wrap: wrap; gap: 6px 22px; margin-top: 10px; font-size: 11.5px; }
  .meta b { color: #1f2d33; }
  h2 { font-size: 13.5px; margin: 18px 0 8px; padding-left: 8px; border-left: 3px solid #e08b3c; }
  table { width: 100%; border-collapse: collapse; font-size: 11px; }
  th, td { border: 1px solid #cfdde1; padding: 5px 7px; text-align: left; vertical-align: top; }
  th { background: #f1f7f9; font-weight: 600; }
  td.num, th.num { text-align: right; }
  td.score { text-align: right; font-weight: 700; color: #2f7d8f; }
  td.dim { width: 90px; font-weight: 600; }
  td.ev { color: #5c7178; font-size: 10.5px; }
  .kpis { display: flex; gap: 10px; flex-wrap: wrap; margin: 8px 0 4px; }
  .kpi { flex: 1 1 120px; border: 1px solid #cfdde1; border-radius: 6px; padding: 8px 10px; }
  .kpi .v { font-size: 18px; font-weight: 700; color: #1f5f6e; }
  .kpi .l { font-size: 10.5px; color: #5c7178; }
  .box { border: 1px solid #cfdde1; border-radius: 6px; padding: 10px 12px; background: #fbfdfe; }
  .verify { margin-top: 18px; border: 2px dashed #2f7d8f; border-radius: 8px; padding: 12px 14px; background: #f4fafb; }
  .verify .code { font-family: Consolas, monospace; font-size: 20px; font-weight: 700; color: #1f5f6e; letter-spacing: 3px; }
  .foot { margin-top: 16px; padding-top: 10px; border-top: 1px solid #cfdde1; color: #7b8f96; font-size: 10px; line-height: 1.6; }
  ul { margin: 4px 0 0; padding-left: 18px; }
  .toolbar { text-align: right; margin-bottom: 8px; }
  .toolbar button { padding: 6px 16px; font-size: 13px; cursor: pointer; border-radius: 4px; border: 1px solid #2f7d8f; background: #2f7d8f; color: #fff; }
  @media print { .toolbar { display: none; } }
</style>
</head>
<body>
  <div class="toolbar"><button onclick="window.print()">打印 / 另存为 PDF</button></div>

  <div class="head">
    <h1>跨学科协作能力鉴定报告</h1>
    <div class="sub">知驿·漫游 —— 跨学科技能交换与学习记录平台　·　西北大学计算机学院</div>
    <div class="meta">
      <span>报告编号：<b>${esc(r.reportNo)}</b></span>
      <span>持有人：<b>${esc(r.name)}</b></span>
      <span>学院：<b>${esc(r.college)}</b></span>
      <span>专业：<b>${esc(r.major)}</b></span>
      <span>年级：<b>${esc(r.grade)}</b></span>
      <span>信用值：<b>${esc(r.creditScore)}</b></span>
      <span>生成时间：<b>${esc(r.generatedAt)}</b></span>
    </div>
  </div>

  <h2>一、能力画像概览</h2>
  <div class="kpis">
    <div class="kpi"><div class="v">${esc(r.overallScore)}</div><div class="l">综合能力值</div></div>
    <div class="kpi"><div class="v">${esc(r.sampleCount)}</div><div class="l">已完成协作（次）</div></div>
    <div class="kpi"><div class="v">${esc(r.totalHours)}</div><div class="l">累计协作时长（小时）</div></div>
    <div class="kpi"><div class="v">${esc(r.avgScore)}</div><div class="l">互评平均分</div></div>
  </div>
  <div class="sub" style="margin-top:4px">统计区间：${esc(r.periodText)}</div>

  <table style="margin-top:8px">
    <thead><tr><th>能力维度</th><th class="num">得分</th><th>分数出处（可追溯）</th></tr></thead>
    <tbody>${dimRows || '<tr><td colspan="3">暂无数据</td></tr>'}</tbody>
  </table>

  <h2>二、代表性长项</h2>
  <div class="box">
    ${strengthText ? `<ul>${strengthText}</ul>` : '暂无可展示的长项'}
  </div>

  <h2>三、客观协作行为</h2>
  <div class="box">${esc(r.behaviorSummary)}</div>

  <h2>四、协作履历</h2>
  <table>
    <thead><tr>
      <th>交换编号</th><th>协作主题</th><th>协作对象</th>
      <th>我提供的技能</th><th>我学到的技能</th>
      <th class="num">时长(h)</th><th class="num">互评分</th>
    </tr></thead>
    <tbody>${exchangeRows || '<tr><td colspan="7">暂无已完成协作</td></tr>'}</tbody>
  </table>

  <h2>五、数字勋章</h2>
  <div class="box">${badgeText}</div>

  <div class="verify">
    <div style="font-size:11.5px;color:#5c7178">在线验真校验码（任何第三方可核对本报告是否真实、内容是否被改动）</div>
    <div class="code">${esc(r.verifyCode)}</div>
    <div style="font-size:11px;color:#5c7178;margin-top:4px">
      验真接口：GET ${esc(r.verifyUrl)}　（无需登录，凭校验码即可查询）
    </div>
    <div style="font-size:11px;color:#5c7178;margin-top:6px">存证等级：<b>${esc(r.evidenceLevel)}</b>　${esc(r.integrityNote)}</div>
  </div>

  <div class="foot">
    <b>统计口径：</b>${esc(r.caliberNote ?? '')}<br>
    <b>声明：</b>${esc(r.disclaimer)}
  </div>
</body>
</html>`
}
