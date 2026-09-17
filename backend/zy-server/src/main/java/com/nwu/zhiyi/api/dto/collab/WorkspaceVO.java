package com.nwu.zhiyi.api.dto.collab;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 协作工作台总览（FR-M5-01：进入交换后的首屏）。
 *
 * <p>一次请求返回工作台所需的全部内容，避免前端串行发多个请求
 * （对 NFR-P-02 的响应时间目标更友好）。
 *
 * @author 李泽宬
 */
@Data
public class WorkspaceVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long recordId;
    private String recordNo;
    private String title;
    private String description;
    private String status;
    private String statusLabel;

    /* ---------------- 参与方与以技易技的双向描述 ---------------- */
    private Party giver;
    private Party taker;

    /** 我的角色与可用操作 */
    private String myRole;
    private List<String> allowedNextStatus;
    private Boolean canManageTasks;
    private Boolean canUpload;
    private Boolean canSendMessage;
    private Boolean canSubmitEval;

    private LocalDateTime startedAt;
    private LocalDateTime deadlineAt;
    private Integer expectedHours;
    private Double actualHours;

    /** 是否已进入协作阶段（IN_PROGRESS / PENDING_EVAL / DISPUTED 为 true） */
    private Boolean collaborationActive;

    /** 任务清单 */
    private List<CollabTaskVO> tasks;

    /** 文件（默认只返回各逻辑文件的最新版本） */
    private List<CollabFileVO> files;

    /** 最近留言（默认 50 条，倒序给前端自行正序渲染） */
    private List<CollabMessageVO> messages;

    /** 时间轴（倒序，最新在前） */
    private List<CollabEventVO> timeline;

    /** 过程性指标（FR-M5-06） */
    private ProcessSummaryVO processSummary;

    /** 参与方 */
    @Data
    public static class Party implements Serializable {

        private static final long serialVersionUID = 1L;

        private String sno;
        private String name;
        private String college;
        private String provideSkillName;
        private String acquireSkillName;
    }
}
