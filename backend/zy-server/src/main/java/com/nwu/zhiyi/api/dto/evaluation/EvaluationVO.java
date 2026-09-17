package com.nwu.zhiyi.api.dto.evaluation;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 互评记录视图对象（FR-M6-01 ~ FR-M6-05）。
 *
 * <p><b>可见性规则</b>（FR-M6-05 防报复性评价）：
 * <ul>
 *   <li>{@code scoreVisible = false} 时，{@code dimScores} / {@code totalScore} /
 *       {@code comment} 一律为 null —— 不是仅前端隐藏，而是<b>服务端根本不返回</b>；</li>
 *   <li>例外：{@code fromSno} 等于查看者本人时，自己的评价始终可见；</li>
 *   <li>交换进入终态或争议裁决后，双方都已提交，自然互相可见。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Data
public class EvaluationVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long recordId;

    /** 评价人学号（匿名且分数可见时才做脱敏） */
    private String fromSno;
    private String fromName;

    private String toSno;
    private String toName;

    /** 是否匿名 */
    private Boolean anonymous;

    /** 是否由当前用户发出 */
    private Boolean mine;

    /**
     * 当前用户能否看到具体分值。
     * false 表示对方尚未提交或你尚未提交，出于防报复性评价考虑暂时隐藏。
     */
    private Boolean scoreVisible;

    /** 维度分（标签 → 分值），不可见时为 null */
    private Map<String, BigDecimal> dimScores;

    /** 加权总分，不可见时为 null */
    private BigDecimal totalScore;

    private String comment;

    /* ---------------- 存证信息（始终可见） ---------------- */

    /** 存证等级：HASH / TIMESTAMP / CHAIN */
    private String evidenceLevel;
    private String evidenceLevelLabel;
    private String evidenceDescription;

    /** 存证哈希（截断展示足够，校验用完整值走校验接口） */
    private String recordHash;

    /** 对外校验码 */
    private String verifyCode;

    private LocalDateTime sealedAt;
    private LocalDateTime createdAt;

    /** 是否超时默认计分 */
    private Boolean timeoutScored;

    /** 是否被申诉 */
    private Boolean disputed;

    /** 审核状态与说明 */
    private String auditStatus;
    private String auditRemark;

    /** 修正记录（若有） */
    private List<AmendmentVO> amendments;

    /** 修正记录视图 */
    @Data
    public static class AmendmentVO implements Serializable {

        private static final long serialVersionUID = 1L;

        private Long id;
        private String reason;
        private BigDecimal scoreBefore;
        private BigDecimal scoreAfter;
        private String operator;
        private Long disputeId;
        private String status;
        private LocalDateTime createdAt;
    }
}
