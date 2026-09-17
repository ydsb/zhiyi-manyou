package com.nwu.zhiyi.api.dto.skill;

import com.nwu.zhiyi.domain.entity.SkillOntology;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 技能图谱关系视图对象（图的边）。
 *
 * @author 李泽宬
 */
@Data
public class SkillRelationVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;

    private Long srcSkillId;
    private String srcSkillName;

    private Long dstSkillId;
    private String dstSkillName;

    /** PREREQUISITE 先决条件 / COMPLEMENT 互补协作 / SYNONYM 同义 */
    private String relationType;
    private String relationLabel;

    /** 关系强度 0~1 */
    private BigDecimal weight;

    /** 是否有向 */
    private Boolean directed;

    private String remark;

    public static SkillRelationVO of(SkillOntology ontology, String srcName, String dstName) {
        if (ontology == null) {
            return null;
        }
        SkillRelationVO vo = new SkillRelationVO();
        vo.setId(ontology.getId());
        vo.setSrcSkillId(ontology.getSrcSkillId());
        vo.setSrcSkillName(srcName);
        vo.setDstSkillId(ontology.getDstSkillId());
        vo.setDstSkillName(dstName);
        if (ontology.getRelationType() != null) {
            vo.setRelationType(ontology.getRelationType().name());
            vo.setRelationLabel(ontology.getRelationType().getLabel());
        }
        vo.setWeight(ontology.getWeight());
        vo.setDirected(ontology.getDirected() != null && ontology.getDirected() == 1);
        vo.setRemark(ontology.getRemark());
        return vo;
    }
}
