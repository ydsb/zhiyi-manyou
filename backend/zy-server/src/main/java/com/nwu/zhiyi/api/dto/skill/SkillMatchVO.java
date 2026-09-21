package com.nwu.zhiyi.api.dto.skill;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 技能匹配项（检索 / 解析结果）。
 *
 * <p>携带匹配依据，供前端展示"可解释的推荐理由"（FR-M3-03）。
 *
 * @author 李泽宬
 */
@Data
public class SkillMatchVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 技能标签 ID */
    private Long skillId;

    /** 技能名称 */
    private String name;

    private String categoryL1;
    private String categoryL2;

    /** 技能意图：SKILLED 我擅长 / RESEARCHING 我正在研究 / NEEDED 我急需 */
    private String intent;

    /** 匹配度 0~1 */
    private BigDecimal score;

    /** 匹配类型：EXACT 名称精确 / ALIAS 同义词 / KEYWORD 关键词 / SEMANTIC 语义相近 / GRAPH 图谱关联 */
    private String matchType;

    /** 匹配依据说明（可解释性） */
    private String reason;

    /**
     * 由标签构建匹配项。
     */
    public static SkillMatchVO of(SkillVO skill, String intent, double score, MatchType type, String reason) {
        SkillMatchVO vo = new SkillMatchVO();
        vo.setSkillId(skill.getId());
        vo.setName(skill.getName());
        vo.setCategoryL1(skill.getCategoryL1());
        vo.setCategoryL2(skill.getCategoryL2());
        vo.setIntent(intent);
        vo.setScore(BigDecimal.valueOf(score).setScale(4, java.math.RoundingMode.HALF_UP));
        vo.setMatchType(type.name());
        vo.setReason(reason);
        return vo;
    }

    /** 匹配方式枚举 */
    public enum MatchType {
        /** 名称完全命中 */
        EXACT(1.00),
        /** 同义词/别名命中 */
        ALIAS(0.90),
        /** 名称或描述包含关键词 */
        KEYWORD(0.70),
        /**
         * 语义相近（S3 向量检索）。
         *
         * <p>权重介于 KEYWORD 与 GRAPH 之间：向量召回能覆盖"字面没说但意思对得上"
         * 的情况（"求带机器学习" → "机器学习建模"），但它的分数是余弦相似度，
         * 天然比精确命中低，也不保证一定相关，因此不应压过规则命中。
         */
        SEMANTIC(0.60),
        /** 知识图谱关联（互补协作等） */
        GRAPH(0.55);

        private final double baseWeight;

        MatchType(double baseWeight) {
            this.baseWeight = baseWeight;
        }

        public double getBaseWeight() {
            return baseWeight;
        }
    }
}
