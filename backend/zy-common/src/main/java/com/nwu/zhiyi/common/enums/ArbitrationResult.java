package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 仲裁裁决结果（FR-M8-05 / FR-M8-06）。
 *
 * <p><b>为什么把 TIE 单列而不是并入"不成立"</b>：
 * 平票意味着委员会对事实存在实质分歧，此时"不成立"会给申诉人贴上
 * "诬告"的隐含标签，是不公平的。因此平票单列为一种结果：
 * <b>不作责任认定，双方均不受处罚</b>（疑罪从无）。
 *
 * @author 李泽宬
 */
@Getter
public enum ArbitrationResult {

    /** 申诉成立：被申诉人被认定承担责任 */
    UPHELD("申诉成立"),

    /** 申诉未获支持：有效票中支持被申诉人更多，或无人形成多数意见 */
    NOT_UPHELD("申诉未获支持"),

    /** 平票：事实存在争议，不作责任认定 */
    TIE("平票未认定责任");

    private final String label;

    ArbitrationResult(String label) {
        this.label = label;
    }

    /** 是否需要执行处罚 */
    public boolean needsPenalty() {
        return this == UPHELD || this == NOT_UPHELD;
    }
}
