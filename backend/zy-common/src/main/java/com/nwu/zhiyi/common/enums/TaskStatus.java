package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 协作任务状态。
 *
 * @author 李泽宬
 */
@Getter
public enum TaskStatus {

    /** 待开始 */
    TODO("待开始"),

    /** 进行中 */
    DOING("进行中"),

    /** 已完成 */
    DONE("已完成");

    private final String label;

    TaskStatus(String label) {
        this.label = label;
    }
}
