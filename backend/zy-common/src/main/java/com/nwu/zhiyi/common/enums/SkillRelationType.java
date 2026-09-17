package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 技能知识图谱关系类型（图的边）。
 *
 * @author 李泽宬
 */
@Getter
public enum SkillRelationType {

    /** 先决条件：学 A 之前需要先掌握 B */
    PREREQUISITE("先决条件", true),

    /** 互补协作：两个技能常在跨学科协作中配对出现 */
    COMPLEMENT("互补协作", false),

    /** 同义关系：跨领域术语的语义等价映射 */
    SYNONYM("同义", false);

    private final String label;

    /** 是否为有向边 */
    private final boolean directed;

    SkillRelationType(String label, boolean directed) {
        this.label = label;
        this.directed = directed;
    }
}
