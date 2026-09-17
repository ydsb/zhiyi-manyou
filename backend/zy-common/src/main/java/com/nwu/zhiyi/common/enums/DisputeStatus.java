package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 争议状态（FR-M8-03 ~ FR-M8-06）。
 *
 * <p>流转：待受理 → 投票中 → 已裁决 / 已驳回；已裁决后可再次申诉（重新进入待受理）。
 *
 * @author 李泽宬
 */
@Getter
public enum DisputeStatus {

    /** 待受理：刚提交，等待抽取仲裁委员 */
    PENDING("待受理"),

    /** 投票中：委员已抽取，等待表决（有截止时间） */
    VOTING("投票中"),

    /** 已裁决：按投票结果或管理员处置得出结论并执行 */
    RESOLVED("已裁决"),

    /** 已驳回：申诉不成立 */
    REJECTED("已驳回");

    private final String label;

    DisputeStatus(String label) {
        this.label = label;
    }

    /** 是否处于终态 */
    public boolean isFinal() {
        return this == RESOLVED || this == REJECTED;
    }
}
