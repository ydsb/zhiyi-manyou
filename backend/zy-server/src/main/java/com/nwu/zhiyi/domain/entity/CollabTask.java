package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.TaskStatus;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作空间任务项实体 —— 对应表 {@code zy_collab_task}。
 *
 * <p>交换匹配成功后，双方在专属协作空间内拆解任务、阶段打卡。
 * 任务的完成节奏、按期率等特征会作为过程性评价语料沉淀。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_collab_task")
public class CollabTask implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 所属交换记录 ID */
    private Long recordId;

    private String title;

    private String description;

    /**
     * 负责人学号。
     *
     * <p>FR-M5-06 要求把"任务拆解粒度、按期率"等指标落到<b>个人</b>维度，
     * 作为过程性评价语料。只有 {@code createdBy} 无法区分"谁负责做"，
     * 因此单独设负责人字段（见 sql/02-migration-m5.sql）。
     */
    private String assigneeSno;

    /** 截止时间 */
    private LocalDateTime deadline;

    /** 任务状态（数据库以枚举名存储） */
    private TaskStatus status;

    /** 成果证据地址（附件/链接） */
    private String evidenceUrl;

    private Integer sortOrder;

    private LocalDateTime doneAt;

    /** 创建人学号 */
    private String createdBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /** 是否已逾期且未完成 */
    public boolean isOverdue() {
        return status != TaskStatus.DONE && deadline != null && deadline.isBefore(LocalDateTime.now());
    }

    /** 标记完成 */
    public void markDone() {
        this.status = TaskStatus.DONE;
        this.doneAt = LocalDateTime.now();
    }
}
