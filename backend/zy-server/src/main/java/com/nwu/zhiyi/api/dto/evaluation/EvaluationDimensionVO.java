package com.nwu.zhiyi.api.dto.evaluation;

import lombok.Data;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * 互评维度字典（供前端渲染打分表单，避免硬编码维度与权重）。
 *
 * @author 李泽宬
 */
@Data
public class EvaluationDimensionVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private List<Dimension> dimensions;

    /** 低分强制说明的阈值 */
    private Double lowScoreThreshold;

    /** 低分评语的最小长度 */
    private Integer lowScoreMinComment;

    /** 互评可见性规则说明 */
    private String visibilityRule;

    /** 维度定义 */
    @Data
    public static class Dimension implements Serializable {

        private static final long serialVersionUID = 1L;

        /** JSON key */
        private String key;
        /** 中文名 */
        private String label;
        /** 权重 */
        private Double weight;
        /** 评分指引 */
        private String guidance;
        /** 满分 */
        private Integer maxScore;
    }

    /** 权重表（key → 权重），便于前端实时预览加权总分 */
    private Map<String, Double> weights;
}
