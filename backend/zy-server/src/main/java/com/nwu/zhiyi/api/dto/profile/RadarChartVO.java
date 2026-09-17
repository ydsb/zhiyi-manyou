package com.nwu.zhiyi.api.dto.profile;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 能力雷达图数据（FR-M7-01 / FR-M7-02 / AC-06）。
 *
 * <p><b>可解释性是硬要求</b>：每个维度都带 {@code evidence}（分数出处）与
 * {@code sampleCount}（样本数）。用户必须能回答"我这个分是怎么来的"，
 * 否则雷达图就只是个好看的黑箱。
 *
 * @author 李泽宬
 */
@Data
public class RadarChartVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private String sno;
    private String name;
    private String college;
    private String major;

    /** 雷达图指标（有序，顺序即图形顶点顺序） */
    private List<DimensionScore> dimensions;

    /** 是否整体数据不足（样本数为 0 时前端给引导提示而非画空图） */
    private Boolean insufficientData;

    /** 参与计算的样本数（已完成且有互评的交换数） */
    private Integer sampleCount;

    /** 样本平均互评总分 */
    private BigDecimal avgScore;

    /** 累计协作时长（小时） */
    private BigDecimal totalHours;

    /** 综合能力值：有数据维度的均值（仅作概览，不作评价依据） */
    private BigDecimal overallScore;

    /** 统计口径说明（前端直接展示，避免用户误解数字含义） */
    private String caliberNote;

    /** 快照时间；null 表示本次为实时计算、尚未落库 */
    private String snapshotPeriod;

    /** 单个维度的得分与出处 */
    @Data
    public static class DimensionScore implements Serializable {

        private static final long serialVersionUID = 1L;

        private String key;
        private String label;
        private String description;

        /**
         * 得分 0~100。
         * <b>为 null 表示该维度暂无样本</b>——前端应画成虚线或标注"暂无数据"，
         * 不要当作 0 分（0 分会被读成"能力很差"，与事实不符）。
         */
        private BigDecimal score;

        /** 本维度的样本数（参与计算的交换数） */
        private Integer sampleCount;

        /** 分数出处说明，如「学术论文写作（人文表达）互评 90 分 × 1 次交换」 */
        private String evidence;

        /** 贡献该维度的技能名（用于前端展开明细） */
        private List<String> skills;

        /** 满分 */
        private Integer max = 100;
    }

    /** 维度键 → 分数（便于前端画图） */
    private Map<String, BigDecimal> scoreMap;
}
