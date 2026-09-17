package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.SkillRelationType;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 技能知识图谱关系实体（图的边）—— 对应表 {@code zy_skill_ontology}。
 *
 * <p>节点是技能标签，边类型包含：先决条件 / 互补协作 / 同义。
 * 平台据此在字面匹配之外，通过图谱游走挖掘隐性需求
 * （例如"前端开发"与"UI/UX 设计"之间的互补协作边）。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_skill_ontology")
public class SkillOntology implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 源技能 ID */
    private Long srcSkillId;

    /** 目标技能 ID */
    private Long dstSkillId;

    /** 关系类型（数据库以枚举名存储） */
    private SkillRelationType relationType;

    /** 关系强度 0~1，作为随机游走的转移权重 */
    private BigDecimal weight;

    /** 是否有向：0无向 1有向 */
    private Integer directed;

    private String remark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
