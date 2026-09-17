package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 内容审核状态（FR-M4-07）。
 *
 * @author 李泽宬
 */
@Getter
public enum AuditStatus {

    /** 通过（自动审核未命中风险特征） */
    PASSED("已通过"),

    /** 待人工复核（命中敏感词或广告/刷单特征） */
    PENDING("待复核"),

    /** 驳回 */
    REJECTED("已驳回");

    private final String label;

    AuditStatus(String label) {
        this.label = label;
    }
}
