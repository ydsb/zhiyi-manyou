import { request } from './request'
import type { SemanticResult } from './types'

/**
 * 语义匹配接口（S3 · 模块 M3）。
 *
 * 与 `/skills/parse` 的分工 —— 两者互补，导引页两条都用：
 *
 * | 接口 | 底层 | 擅长 | 局限 |
 * |---|---|---|---|
 * | `/skills/parse` | 规则词典 + 三元组抽取 | 能给出标准化标签与 (主体,动作,技能) 三元组，可解释 | 只有**字面命中**的词才抽得到 |
 * | `/match/semantic` | TF-IDF + LSA 向量检索 + 图谱加成 | 能召回**字面不同但语义相近**的技能（"做数据"→"数据爬取与清洗"） | 不含意图判定，只给相似度 |
 *
 * 实测差距很明显：一句"我会做数学建模和统计分析，也常常用 Python 处理数据"
 * 走 parse 只抽出 1 个标签，走 semantic 能召回一组相关技能。
 */
export const matchApi = {
  /**
   * 语义检索 Top-K（POST /api/match/semantic）。
   *
   * @param data.query        查询文本
   * @param data.topK         返回条数
   * @param data.kind         限定类型，取 SKILL 只召回技能标签
   * @param data.seedSkillIds 已选技能 id，命中其图谱邻居会获得关系加成
   */
  semantic(data: { query: string; topK?: number; kind?: string; seedSkillIds?: number[] }) {
    return request<SemanticResult>({ url: '/match/semantic', method: 'post', data })
  }
}
