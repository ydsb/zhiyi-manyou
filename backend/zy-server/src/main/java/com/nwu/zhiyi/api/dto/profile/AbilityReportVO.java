package com.nwu.zhiyi.api.dto.profile;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 《跨学科协作能力鉴定报告》（FR-M7-06 / FR-M7-08）。
 *
 * <p>报告本身是一份**结构化数据**，前端可据此排版为 PDF。
 * 报告携带 M6 的校验码，任何第三方可通过
 * {@code GET /api/certificates/{verifyCode}}（匿名）在线验真 ——
 * 这条链路 M6 已经打通，本模块只需把编码印上去。
 *
 * <p><b>如实标注</b>：报告会带上 {@code evidenceLevel} 与 {@code integrityNote}，
 * 说明存证的强度与边界（哈希固化可检出字段级篡改，但不防有库权限者重算哈希）。
 * 对外材料里不应宣称"物理上不可篡改"。
 *
 * @author 李泽宬
 */
@Data
public class AbilityReportVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /* ---------------- 报告标识 ---------------- */

    /** 报告编号，如 RPT-20260917-A49F439A */
    private String reportNo;

    /** 验真校验码（对应某条核心互评记录的 M6 校验码） */
    private String verifyCode;

    /** 验真地址（前端可生成二维码） */
    private String verifyUrl;

    private LocalDateTime generatedAt;

    /* ---------------- 持有人信息 ---------------- */

    private String sno;
    private String name;
    private String college;
    private String major;
    private String grade;
    private Integer creditScore;
    private String creditLevel;

    /* ---------------- 能力画像 ---------------- */

    private List<RadarChartVO.DimensionScore> dimensions;

    private BigDecimal overallScore;
    private Integer sampleCount;
    private BigDecimal totalHours;
    private BigDecimal avgScore;

    /** 统计区间说明 */
    private String periodText;

    /* ---------------- 协作履历 ---------------- */

    private List<ExchangeRecordItem> exchanges;

    /** 已获勋章 */
    private List<BadgeVO> badges;

    /** 代表性强项（得分最高的 2 个维度 + 出处） */
    private List<String> strengths;

    /** 客观行为摘要（来自 M5 过程性指标） */
    private String behaviorSummary;

    /* ---------------- 存证与声明 ---------------- */

    private String evidenceLevel;
    private String integrityNote;

    /** 报告说明（口径与免责声明，PDF 页脚用） */
    private String disclaimer;

    /** 单条协作履历 */
    @Data
    public static class ExchangeRecordItem implements Serializable {

        private static final long serialVersionUID = 1L;

        private String recordNo;
        private String title;
        private String peerName;
        /** 我提供出去的技能 */
        private String providedSkill;
        /** 我学到的技能 */
        private String acquiredSkill;
        private String statusLabel;
        private LocalDate finishedAt;
        private BigDecimal hours;
        /** 对方给我的互评总分 */
        private BigDecimal receivedScore;
        /** 评语（匿名评价时为"匿名评价"） */
        private String comment;
    }

    /** 报告统计口径的补充说明 */
    private Map<String, Object> caliber;
}
