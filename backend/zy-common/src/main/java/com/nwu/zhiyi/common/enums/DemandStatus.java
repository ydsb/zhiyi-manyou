package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 需求卡片状态（FR-M4-01 / FR-M4-02）。
 *
 * @author 李泽宬
 */
@Getter
public enum DemandStatus {

    /** 招募中 */
    OPEN("招募中"),

    /** 已匹配（已有交换进入进行中） */
    MATCHED("已匹配"),

    /** 已关闭（发布人主动关闭或已过期） */
    CLOSED("已关闭");

    private final String label;

    DemandStatus(String label) {
        this.label = label;
    }

    /** 是否仍在招募中（可被发起交换） */
    public boolean isOpen() {
        return this == OPEN;
    }
}
