package com.nwu.zhiyi.api.dto.profile;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 成长轨迹（FR-M7-07）：按时间排列的维度得分序列，用于画折线/面积图。
 *
 * @author 李泽宬
 */
@Data
public class GrowthTrendVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private String sno;

    /** 时间点（快照周期，如 2026-07） */
    private List<String> periods;

    /**
     * 每个维度一条序列：key=维度键，value=与 periods 等长的分值数组。
     * 某期无数据的位置为 null（前端断线处理，不要用 0 连接）。
     */
    private Map<String, List<BigDecimal>> series;

    /** 维度键 → 中文名 */
    private Map<String, String> dimensionLabels;

    /** 数据点数量（快照数） */
    private Integer pointCount;

    /** 变化摘要，如「工程逻辑 3 个月内 +8.5」 */
    private List<ChangeSummary> changes;

    /** 说明 */
    private String note;

    /** 单个维度的变化摘要 */
    @Data
    public static class ChangeSummary implements Serializable {

        private static final long serialVersionUID = 1L;

        private String key;
        private String label;
        private BigDecimal first;
        private BigDecimal latest;
        /** 变化量（latest - first），正数为进步 */
        private BigDecimal delta;
        /** 是否为进步 */
        private Boolean improved;
    }
}
