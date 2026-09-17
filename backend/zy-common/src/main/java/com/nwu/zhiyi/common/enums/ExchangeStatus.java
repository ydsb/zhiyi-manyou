package com.nwu.zhiyi.common.enums;

import lombok.Getter;

import java.util.Arrays;
import java.util.EnumSet;
import java.util.Set;

/**
 * 技能交换状态机。
 *
 * <pre>
 *   PUBLISHED ──▶ NEGOTIATING ──▶ IN_PROGRESS ──▶ PENDING_EVAL ──▶ COMPLETED
 *        │              │              │                │
 *        └──────────────┴──────────────┴────────────────┴──▶ CANCELLED
 *                                      │
 *                                      └──▶ DISPUTED ──▶ COMPLETED / CANCELLED
 * </pre>
 *
 * <p>流转规则定义在 {@link #canTransferTo(ExchangeStatus)} 内（方法体内求值，
 * 规避枚举常量实参不支持前向引用的限制）。
 *
 * @author 李泽宬
 */
@Getter
public enum ExchangeStatus {

    /** 已发布，尚未匹配 */
    PUBLISHED("已发布"),

    /** 洽谈中（已发起邀约，等待对方响应） */
    NEGOTIATING("洽谈中"),

    /** 进行中（协作空间已生成） */
    IN_PROGRESS("进行中"),

    /** 待互评 */
    PENDING_EVAL("待互评"),

    /** 已完成（双方互评完成） */
    COMPLETED("已完成"),

    /** 已取消 */
    CANCELLED("已取消"),

    /** 争议中 */
    DISPUTED("争议中");

    private final String label;

    ExchangeStatus(String label) {
        this.label = label;
    }

    /**
     * 判断能否从当前状态流转到目标状态。
     *
     * @param target 目标状态
     * @return 允许流转返回 true
     */
    public boolean canTransferTo(ExchangeStatus target) {
        if (target == null) {
            return false;
        }
        switch (this) {
            case PUBLISHED:
                return target == NEGOTIATING || target == CANCELLED;
            case NEGOTIATING:
                return target == IN_PROGRESS || target == CANCELLED;
            case IN_PROGRESS:
                return target == PENDING_EVAL || target == DISPUTED || target == CANCELLED;
            case PENDING_EVAL:
                return target == COMPLETED || target == DISPUTED;
            case DISPUTED:
                return target == COMPLETED || target == CANCELLED;
            case COMPLETED:
            case CANCELLED:
            default:
                return false;
        }
    }

    /** 是否为终态 */
    public boolean isFinal() {
        return this == COMPLETED || this == CANCELLED;
    }

    /**
     * 当前状态允许流转到的所有目标状态。
     *
     * <p>用于对外暴露"可用操作"，让前端无需硬编码状态机。
     *
     * @return 目标状态集合（终态返回空集）
     */
    public Set<ExchangeStatus> allowedNext() {
        EnumSet<ExchangeStatus> set = EnumSet.noneOf(ExchangeStatus.class);
        for (ExchangeStatus candidate : values()) {
            if (canTransferTo(candidate)) {
                set.add(candidate);
            }
        }
        return set;
    }

    /** 是否属于"进行中"（占用并发配额）的状态 */
    public boolean isOccupyingQuota() {
        return this == NEGOTIATING || this == IN_PROGRESS;
    }

    /**
     * 按名称安全解析状态。
     *
     * @param name 状态名
     * @return 匹配的状态，无匹配返回 null
     */
    public static ExchangeStatus of(String name) {
        if (name == null) {
            return null;
        }
        return Arrays.stream(values())
                .filter(status -> status.name().equalsIgnoreCase(name))
                .findFirst()
                .orElse(null);
    }
}
