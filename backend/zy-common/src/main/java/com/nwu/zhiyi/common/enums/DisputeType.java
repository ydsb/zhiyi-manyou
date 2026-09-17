package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 争议类型（FR-M8-03）。
 *
 * <p>分类的意义不只是归档 —— 治理规则的迭代依据就是"哪类问题最多"。
 * 公示页会按类型统计，让社区看到问题分布并据此讨论规则调整（FR-M8-07）。
 *
 * @author 李泽宬
 */
@Getter
public enum DisputeType {

    /** 未履约：一方接受邀约后不参与协作 */
    NO_SHOW("未履约", "对方接受邀约后不参与协作、长期失联"),

    /** 交付质量问题 */
    QUALITY("交付质量", "交付成果与约定严重不符、需要大量返工"),

    /** 评价不公：恶意差评或刷好评 */
    EVAL_UNFAIR("评价不公", "评价明显偏离事实，涉嫌恶意差评或刷好评"),

    /** 抄袭：成果非本人完成 */
    PLAGIARISM("成果抄袭", "交付成果非本人完成，或抄袭他人作品"),

    /** 其他：无法归入上述类型的情况（保留出口，避免强制归类导致统计失真） */
    OTHER("其他", "不属于上述类型，由仲裁委员根据卷宗判断");

    private final String label;
    private final String description;

    DisputeType(String label, String description) {
        this.label = label;
        this.description = description;
    }
}
