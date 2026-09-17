package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 交换意向状态（FR-M4-05：发起邀约 → 接受/拒绝）。
 *
 * @author 李泽宬
 */
@Getter
public enum DemandInterestStatus {

    /** 待响应 */
    PENDING("待响应"),

    /** 已接受（交换进入进行中） */
    ACCEPTED("已接受"),

    /** 已拒绝 */
    REJECTED("已拒绝"),

    /** 已撤回（申请人主动撤回） */
    WITHDRAWN("已撤回");

    private final String label;

    DemandInterestStatus(String label) {
        this.label = label;
    }
}
