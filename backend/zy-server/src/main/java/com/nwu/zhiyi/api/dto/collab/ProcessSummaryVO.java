package com.nwu.zhiyi.api.dto.collab;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 协作过程性指标汇总（FR-M5-06）。
 *
 * <p><b>这份数据是做什么用的</b>：创新点 1 声称"把无法在成绩单上体现的复合型隐性技能
 * 转化为可视化数字档案"，其原始语料就来自这里。它与 M6 双向互评的关系是
 * <b>互相印证</b>：互评是主观打分，这些指标是客观行为，两者并列呈现给评价人，
 * 可以显著削弱"凭印象打分"与"互刷好评"的空间。
 *
 * <p><b>设计原则</b>：只输出可解释的原始计数与时长，<b>不输出综合评分</b>。
 * 加权打分是 M6/M7 的职责（需要与互评维度对齐、并落库为不可篡改记录），
 * 在这里算分会导致口径分散、无法追溯。
 *
 * @author 李泽宬
 */
@Data
public class ProcessSummaryVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long recordId;
    private String recordNo;
    private String status;
    private String statusLabel;

    /** 交换开始时间与已持续时长（分钟） */
    private LocalDateTime startedAt;
    private Long durationMinutes;

    /* ---------------- 任务维度 ---------------- */

    private Integer taskTotal;
    private Integer taskDone;
    /**
     * 其中已被协作方确认的任务数（FR-M5-08）。
     *
     * <p><b>为什么必须与 {@link #taskDone} 分开统计</b>：`taskDone` 只说明
     * "有人点了完成"，而 FR-M5-08 要解决的正是"单方面宣称完成"。
     * 若两者合并成一个数字，单方面打卡与双方认可在指标上完全一样，
     * 这个机制就白做了 —— 指标必须能反映协作的真实质量，而不是谁点得快。
     */
    private Integer taskConfirmed;
    private Integer taskDoing;
    private Integer taskTodo;
    /** 已逾期且未完成的任务数 */
    private Integer taskOverdue;
    /** 任务完成率 0~1 */
    private Double taskCompletionRate;
    /** 有截止时间的任务中按期完成的比例 0~1（无截止时间的任务不计入分母） */
    private Double onTimeRate;
    /** 任务拆解粒度：任务数 / 参与人数，反映"拆得够不够细" */
    private Double decompositionGranularity;

    /* ---------------- 沟通维度 ---------------- */

    /** 全体留言条数（不含系统消息） */
    private Integer messageTotal;
    /** 首个任务创建距交换开始的小时数：越小说明"启动越快" */
    private Double firstActionDelayHours;
    /** 最后一次协作动作距现在的分钟数：用于判断"是否已停滞" */
    private Long idleMinutes;

    /* ---------------- 交付维度 ---------------- */

    /** 文件上传总次数（含历史版本） */
    private Integer fileUploadTotal;
    /** 逻辑文件数（去重后的交付物个数） */
    private Integer fileGroupTotal;

    /** 按参与方拆分的明细 */
    private List<ParticipantMetrics> participants;

    /** 单方指标 */
    @Data
    public static class ParticipantMetrics implements Serializable {

        private static final long serialVersionUID = 1L;

        private String sno;
        private String name;
        private String college;

        /** 该方在本交换中的角色：GIVER 供给方 / TAKER 需求方 */
        private String role;

        /* 任务 */
        private Integer assignedTasks;
        private Integer doneTasks;
        /** 该方负责任务的完成率 0~1 */
        private Double completionRate;
        /** 该方逾期未完成的任务数 */
        private Integer overdueTasks;
        /** 该方"共同负责"（未指定负责人）的任务数 */
        private Integer sharedTasks;

        /* 沟通 */
        private Integer messages;
        /** 该方文件上传次数 */
        private Integer fileUploads;
        /** 该方触发的协作事件总数（活跃度） */
        private Integer eventCount;

        /** 一句话小结，供互评页面直接展示 */
        private String digest;
    }
}
