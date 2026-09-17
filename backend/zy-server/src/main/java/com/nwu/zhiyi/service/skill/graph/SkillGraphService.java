package com.nwu.zhiyi.service.skill.graph;

import com.nwu.zhiyi.api.dto.skill.ParseResultVO;
import com.nwu.zhiyi.api.dto.skill.SkillRelationVO;

import java.util.List;

/**
 * 技能知识图谱服务（FR-M2-05 / FR-M2-06 / FR-M2-08）。
 *
 * <p>节点为技能标签，边类型包括先决条件、互补协作、同义。
 *
 * @author 李泽宬
 */
public interface SkillGraphService {

    /**
     * 图谱补全：对字面匹配结果补充"互补协作"邻居标签，挖掘隐性跨学科需求（FR-M2-06）。
     *
     * <p>例：用户说要"做动态交互效果"，词典命中「JS 动画与交互实现」；
     * 通过互补协作边补出「UI/UX 设计」，因为这两个技能在跨学科协作中成对出现。
     *
     * @param result 解析结果（原地修改）
     * @param limit  结果总数上限
     */
    void augment(ParseResultVO result, int limit);

    /**
     * 查询整个图谱（可视化用，FR-M2-08）。
     *
     * @return 全部关系边（含两端技能名）
     */
    List<SkillRelationVO> getAllRelations();

    /**
     * 查询与指定技能直接相邻的关系。
     *
     * @param skillId      技能 ID
     * @param relationType 可选，按关系类型过滤
     * @return 关系列表
     */
    List<SkillRelationVO> getRelationsOf(Long skillId, String relationType);

    /**
     * 新增图谱关系（FR-M9-02）。
     *
     * @param srcSkillId   源技能
     * @param dstSkillId   目标技能
     * @param relationType 关系类型名
     * @param weight       关系强度 0~1，为空时按类型取默认值
     * @param remark       备注
     * @return 新增后的关系
     */
    SkillRelationVO createRelation(Long srcSkillId, Long dstSkillId, String relationType,
                                   java.math.BigDecimal weight, String remark);

    /**
     * 删除图谱关系。
     *
     * @param relationId 关系 ID
     */
    void deleteRelation(Long relationId);
}
