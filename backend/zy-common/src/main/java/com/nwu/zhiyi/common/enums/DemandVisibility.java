package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 需求卡片可见范围（FR-M4-01）。
 *
 * @author 李泽宬
 */
@Getter
public enum DemandVisibility {

    /** 全校可见 */
    PUBLIC("全校"),

    /** 本院系可见 */
    COLLEGE("本院系"),

    /** 仅受邀可见 */
    PRIVATE("仅受邀");

    private final String label;

    DemandVisibility(String label) {
        this.label = label;
    }
}
