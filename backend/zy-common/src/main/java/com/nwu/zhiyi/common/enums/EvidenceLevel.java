package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 存证等级（FR-M6-03）。
 *
 * <p><b>为什么要分级</b>：哈希固化能检出"字段被改动"，但防不住"连哈希一起重算"。
 * 真正的抗篡改需要外部锚定。把等级显式记录在评价记录上，可以让
 * 「能力鉴定报告」如实标注该凭证的可信程度，而不是笼统宣称"不可篡改"。
 *
 * <p>技术路线（联盟链 vs 可信时间戳）由 S3 阶段确定，见需求文档 Q5。
 *
 * @author 李泽宬
 */
@Getter
public enum EvidenceLevel {

    /**
     * 仅哈希固化。
     *
     * <p>可检出字段级篡改；但有库权限者可同步重算哈希使其自洽。
     * S2 阶段的默认等级。
     */
    HASH("哈希固化", "已对评价内容计算 SHA-256 并固化，可检出字段级篡改"),

    /** 可信时间戳：由第三方时间戳服务对哈希出具时间证明 */
    TIMESTAMP("可信时间戳", "哈希已由第三方时间戳服务锚定，可证明该评价在某时刻已存在"),

    /** 链上锚定：哈希写入联盟链，具备抗篡改与可追溯性 */
    CHAIN("链上锚定", "哈希已写入联盟链，篡改需同时攻破链上多数节点");

    private final String label;
    private final String description;

    EvidenceLevel(String label, String description) {
        this.label = label;
        this.description = description;
    }
}
