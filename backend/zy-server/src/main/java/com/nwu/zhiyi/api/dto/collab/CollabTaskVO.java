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
        return vo;
    }
}
