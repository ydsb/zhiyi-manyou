import { request } from './request'
import type {
  ParseResult,
  Skill,
  SkillMatch,
  SkillRelation,
  SkillSavePayload,
  SkillTree
} from './types'

/**
 * 技能本体接口（模块 M2）。
 *
 * 鉴权：`/skills/tree`、`/skills/search`、`/ontology/**` 匿名可访问；
 *      其余需登录；`/admin/**` 需 ADMIN。
 */
export const skillApi = {
  /** 三层技能标签树（GET /api/skills/tree） */
  tree(params?: { categoryL1?: string; keyword?: string }) {
    return request<SkillTree>({ url: '/skills/tree', method: 'get', params })
  },

  /** 关键词检索（GET /api/skills/search） */
  search(params: { keyword?: string; categoryL1?: string; limit?: number }) {
    return request<SkillMatch[]>({ url: '/skills/search', method: 'get', params })
  },

  /** 门类覆盖度统计（GET /api/skills/stats） */
  stats() {
    return request<Array<{ name: string; count: number }>>({ url: '/skills/stats', method: 'get' })
  },

  /** 非结构化文本解析（POST /api/skills/parse） */
  parse(data: { text: string; limit?: number; withGraph?: boolean }) {
    return request<ParseResult>({ url: '/skills/parse', method: 'post', data })
  },

  /** 技能详情（GET /api/skills/{id}） */
  detail(id: number) {
    return request<Skill>({ url: `/skills/${id}`, method: 'get' })
  },

  /** 全量图谱关系（GET /api/ontology/graph） */
  graph() {
    return request<SkillRelation[]>({ url: '/ontology/graph', method: 'get' })
  },

  /** 某技能的相邻关系（GET /api/ontology/skills/{id}/relations） */
  relationsOf(skillId: number, relationType?: string) {
    return request<SkillRelation[]>({
      url: `/ontology/skills/${skillId}/relations`,
      method: 'get',
      params: { relationType }
    })
  }
}

/** 管理端：技能标签与图谱维护（需 ADMIN） */
export const skillAdminApi = {
  create(payload: SkillSavePayload) {
    return request<Skill>({ url: '/admin/skills', method: 'post', data: payload })
  },

  update(id: number, payload: SkillSavePayload) {
    return request<Skill>({ url: `/admin/skills/${id}`, method: 'put', data: payload })
  },

  remove(id: number) {
    return request<void>({ url: `/admin/skills/${id}`, method: 'delete' })
  },

  createRelation(payload: {
    srcSkillId: number
    dstSkillId: number
    relationType: string
    weight?: number
    remark?: string
  }) {
    return request<SkillRelation>({ url: '/admin/ontology/relations', method: 'post', data: payload })
  },

  removeRelation(id: number) {
    return request<void>({ url: `/admin/ontology/relations/${id}`, method: 'delete' })
  }
}

/** 图谱视图：由关系边推导节点（前端可视化用） */
export interface GraphView {
  nodes: Array<{ id: number; name: string; categoryL1?: string; degree: number }>
  edges: Array<{ source: number; target: number; type: string; label: string; weight: number }>
}

/**
 * 把关系边列表转换为 { nodes, edges } 结构，便于图谱可视化组件消费。
 *
 * @param relations 关系边
 * @returns 节点与边
 */
export function buildGraphView(relations: SkillRelation[]): GraphView {
  const nodeMap = new Map<number, { id: number; name: string; degree: number }>()
  const edges: GraphView['edges'] = []

  for (const r of relations) {
    for (const [id, name] of [
      [r.srcSkillId, r.srcSkillName],
      [r.dstSkillId, r.dstSkillName]
    ] as Array<[number, string]>) {
      if (!nodeMap.has(id)) {
        nodeMap.set(id, { id, name, degree: 0 })
      }
      nodeMap.get(id)!.degree += 1
    }
    edges.push({
      source: r.srcSkillId,
      target: r.dstSkillId,
      type: r.relationType,
      label: r.relationLabel,
      weight: Number(r.weight ?? 1)
    })
  }

  return { nodes: Array.from(nodeMap.values()), edges }
}
