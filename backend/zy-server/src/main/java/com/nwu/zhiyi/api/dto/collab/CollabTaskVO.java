package com.nwu.zhiyi.api.dto.collab;

import com.nwu.zhiyi.domain.entity.CollabTask;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作任务项视图对象（FR-M5-02）。
 *
 * @author 李泽宬
 */
@Data
public class CollabTaskVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long recordId;
    private String title;
    private String description;

    /** 负责人学号与展示名 */
    private String assigneeSno;
    private String assigneeName;
    private String assigneeCollege;

    private LocalDateTime deadline;

    private String status;
    private String statusLabel;

    /** 是否逾期（未完成且已过截止时间） */
    private Boolean overdue;

    private String evidenceUrl;
    private Integer sortOrder;

    private LocalDateTime doneAt;
    private LocalDateTime createdAt;

    /** 创建人与负责人是否为同一人（用于前端展示"我认领 vs 别人指派"） */
    private String createdBy;

    /** 是否由当前用户负责 */
    private Boolean mine;

    /* ---------------- FR-M5-08 阶段性成果双向确认 ---------------- */

    /**
     * 对方是否已确认该阶段成果。
     *
     * <p>与 {@link #status} 是两个独立事实：`DONE` 只说明"某人宣称完成"，
     * `confirmed` 才说明"对方认可"。前端必须把两者分开显示 ——
     * 否则"单方面宣称完成"与"双方确认完成"看起来一样，
     * FR-M5-08 想解决的问题就白做了。
     */
    private Boolean confirmed;

    /** 确认人学号 */
    private String confirmedBy;

    /** 确认人展示名 */
    private String confirmedByName;

    private LocalDateTime confirmedAt;

    /** 确认说明 */
    private String confirmRemark;

    /** 打卡者学号（宣称完成的人） */
    private String doneBy;

    /**
     * 当前查看者是否可以确认这个任务。
     *
     * <p>由服务端算好下发，而不是前端自己判断 —— 判定规则涉及
     * "打卡者不能自确认""必须是负责人或创建人"，前端复刻一遍必然会走样。
     */
    private Boolean canConfirm;

    public static CollabTaskVO of(CollabTask task) {
        if (task == null) {
            return null;
        }
        CollabTaskVO vo = new CollabTaskVO();
        vo.setId(task.getId());
        vo.setRecordId(task.getRecordId());
        vo.setTitle(task.getTitle());
        vo.setDescription(task.getDescription());
        vo.setAssigneeSno(task.getAssigneeSno());
        vo.setDeadline(task.getDeadline());
        if (task.getStatus() != null) {
            vo.setStatus(task.getStatus().name());
            vo.setStatusLabel(task.getStatus().getLabel());
        }
        vo.setOverdue(task.isOverdue());
        vo.setEvidenceUrl(task.getEvidenceUrl());
        vo.setSortOrder(task.getSortOrder());
        vo.setDoneAt(task.getDoneAt());
        vo.setCreatedAt(task.getCreatedAt());
        vo.setCreatedBy(task.getCreatedBy());
        vo.setConfirmed(CollabTask.isConfirmed(task));
        vo.setConfirmedBy(task.getConfirmedBy());
        vo.setConfirmedAt(task.getConfirmedAt());
        vo.setConfirmRemark(task.getConfirmRemark());
        vo.setDoneBy(task.getDoneBy());
        return vo;
    }
}
