package com.nwu.zhiyi.api.dto.evaluation;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 * 交换的互评进度（FR-M6-01 / FR-M6-05）。
 *
 * <p>一次返回"谁评了、我能不能看对方的分、交换能否进入已完成"，
 * 供前端渲染互评界面并避免多次请求。
 *
 * @author 李泽宬
 */
@Data
public class EvaluationStatusVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long recordId;
    private String recordNo;
    private String status;
    private String statusLabel;

    /** 交换标题与对方信息，便于互评页直接展示上下文 */
    private String title;
    private String peerSno;
    private String peerName;
    private String peerProvideSkill;

    /** 我是否已提交评价 */
    private Boolean mySubmitted;
    /** 对方是否已提交评价 */
    private Boolean peerSubmitted;

    /** 双方是否都已完成互评（都完成即可流转为「已完成」） */
    private Boolean bothSubmitted;

    /** 当前用户能否提交评价（交换处于待互评且我尚未提交） */
    private Boolean canSubmit;

    /** 当前用户能否看到对方评分（FR-M6-05：双方都提交后才可见） */
    private Boolean peerScoreVisible;

    /** 我的评价（始终可见） */
    private EvaluationVO myEvaluation;

    /** 对方的评价（未满足可见条件时，其分值与评语为 null） */
    private EvaluationVO peerEvaluation;

    /** 我的总分（未提交时为 null） */
    private BigDecimal myTotalScore;

    /** 对方给我的总分（不可见时为 null） */
    private BigDecimal peerTotalScore;

    /** 进入待互评的时间与已过去的天数，用于超时提醒 */
    private String pendingEvalAt;
    private Long pendingDays;

    /** 提示信息（如"对方尚未评价，评分暂时隐藏"） */
    private String hint;

    /** 过程性指标摘要（来自 M5，用于互评时对照客观行为） */
    private String processDigest;

    /** 参与方过程指标明细（来自 M5） */
    private List<Object> processMetrics;
}
