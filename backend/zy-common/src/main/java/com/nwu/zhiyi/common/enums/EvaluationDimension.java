package com.nwu.zhiyi.common.enums;

import lombok.Getter;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 互评维度（FR-M6-02：任务完成度、交付质量、沟通效率、跨专业协作能力）。
 *
 * <p><b>为什么把权重放在枚举里</b>：总分口径必须唯一且可解释 —— 能力雷达图（M7）、
 * 信用计算（M8）都引用同一个总分。若各处自行加权，会出现"同一份评价在不同页面
 * 显示不同分数"的问题，且无法追溯。因此权重集中在此处定义，
 * {@code EvaluationGrade.totalScore} 只由它计算得出。
 *
 * <p>权重之和为 1.0，默认等权（各 0.25）；后续若需按学科调整，
 * 可改为配置项，但必须保持"总分 = Σ(维度分 × 权重)"这一不变式。
 *
 * @author 李泽宬
 */
@Getter
public enum EvaluationDimension {

    /** 任务完成度：是否按约定完成任务拆解 */
    TASK_COMPLETION("task_completion", "任务完成度", 0.25,
            "是否按约定完成任务拆解，有无烂尾"),

    /** 交付质量：成果的可用性与完成度 */
    DELIVERY_QUALITY("delivery_quality", "交付质量", 0.25,
            "成果是否可用、是否需要返工、细节完成度"),

    /** 沟通效率：响应速度与信息清晰度 */
    COMMUNICATION("communication", "沟通效率", 0.25,
            "响应速度、信息清晰度、协作配合度"),

    /** 跨专业协作能力：跨学科理解与表达 */
    CROSS_DISCIPLINE("cross_discipline", "跨专业协作能力", 0.25,
            "能否理解对方专业语境、能否把本专业知识讲清楚");

    /** JSON 字段名（存进 dim_scores） */
    private final String key;
    /** 中文展示名 */
    private final String label;
    /** 权重 0~1 */
    private final double weight;
    /** 评分指引，供前端展示给评价人 */
    private final String guidance;

    EvaluationDimension(String key, String label, double weight, String guidance) {
        this.key = key;
        this.label = label;
        this.weight = weight;
        this.guidance = guidance;
    }

    /**
     * 按 JSON key 解析维度。
     *
     * @param key 字段名
     * @return 维度，无匹配返回 null
     */
    public static EvaluationDimension ofKey(String key) {
        if (key == null) {
            return null;
        }
        return Arrays.stream(values())
                .filter(d -> d.key.equalsIgnoreCase(key.trim()))
                .findFirst()
                .orElse(null);
    }

    /**
     * 维度权重表（key → 权重），供计算器与前端共用。
     *
     * @return 有序权重表
     */
    public static Map<String, Double> weightTable() {
        Map<String, Double> table = new LinkedHashMap<>();
        for (EvaluationDimension d : values()) {
            table.put(d.key, d.weight);
        }
        return table;
    }

    /**
     * 校验权重配置是否合法（和为 1）。
     *
     * <p>供单元测试守护：一旦有人调整权重却忘了让总和为 1，测试会失败。
     *
     * @return 权重之和
     */
    public static double weightSum() {
        return Arrays.stream(values()).mapToDouble(EvaluationDimension::getWeight).sum();
    }
}
