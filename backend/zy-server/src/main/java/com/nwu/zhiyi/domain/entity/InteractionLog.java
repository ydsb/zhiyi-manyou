package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 全过程行为日志实体 —— 对应表 {@code zy_interaction_log}。
 *
 * <p>用户的点击流、停留时长、沟通频次等作为过程性评价的<b>无损原始素材</b>，
 * 先进入消息队列削峰填谷，再落盘；同时为构建用户数字画像提供数据源。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName(value = "zy_interaction_log", autoResultMap = true)
public class InteractionLog implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 行为类型常量 */
    public static final String ACTION_PUBLISH = "PUBLISH";
    public static final String ACTION_VIEW = "VIEW";
    public static final String ACTION_INVITE = "INVITE";
    public static final String ACTION_TASK_DONE = "TASK_DONE";
    public static final String ACTION_UPLOAD = "UPLOAD";
    public static final String ACTION_CHAT = "CHAT";
    public static final String ACTION_EVAL = "EVAL";

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 行为主体学号 */
    private String sno;

    /** 关联交换记录 ID */
    private Long recordId;

    private String actionType;

    private String targetType;

    private Long targetId;

    /** 停留/处理时长（毫秒） */
    private Integer duration;

    /** 行为附加数据（JSON） */
    @TableField(typeHandler = com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler.class)
    private String payload;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
