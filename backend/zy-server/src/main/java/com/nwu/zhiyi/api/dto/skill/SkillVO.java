package com.nwu.zhiyi.api.dto.skill;

import com.nwu.zhiyi.domain.entity.Skill;
import lombok.Data;

import java.io.Serializable;

/**
 * 技能标签视图对象。
 *
 * @author 李泽宬
 */
@Data
public class SkillVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private String name;

    /** 同义词/别名，逗号分隔 */
    private String alias;

    private String categoryL1;
    private String categoryL2;
    private String description;

    /** 难度 1~5 */
    private Integer difficulty;

    /** 热度分 */
    private Integer hotScore;

    /** 向量库文档 ID（S3 阶段由 Embedding 服务写入） */
    private String embeddingId;

    /**
     * 实体 → 视图对象。
     *
     * @param skill 技能实体
     * @return 视图对象，入参为空时返回 null
     */
    public static SkillVO of(Skill skill) {
        if (skill == null) {
            return null;
        }
        SkillVO vo = new SkillVO();
        vo.setId(skill.getId());
        vo.setName(skill.getName());
        vo.setAlias(skill.getAlias());
        vo.setCategoryL1(skill.getCategoryL1());
        vo.setCategoryL2(skill.getCategoryL2());
        vo.setDescription(skill.getDescription());
        vo.setDifficulty(skill.getDifficulty());
        vo.setHotScore(skill.getHotScore());
        vo.setEmbeddingId(skill.getEmbeddingId());
        return vo;
    }
}
