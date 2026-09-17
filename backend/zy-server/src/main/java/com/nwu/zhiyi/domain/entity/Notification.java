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
 * 通知实体 —— 对应表 {@code zy_notification}。
 *
 * <p>覆盖：交换邀约、打卡提醒、互评提醒、裁决通知、勋章授予、系统公告。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_notification")
public class Notification implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 通知类型常量 */
    public static final String TYPE_INVITE = "INVITE";
    public static final String TYPE_TASK_REMIND = "TASK_REMIND";
    public static final String TYPE_EVAL_REMIND = "EVAL_REMIND";
    public static final String TYPE_DISPUTE = "DISPUTE";
    public static final String TYPE_BADGE = "BADGE";
    public static final String TYPE_SYSTEM = "SYSTEM";

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 接收人学号 */
    private String sno;

    private String type;

    private String title;

    private String content;

    /** 关联业务类型 */
    private String refType;

    /** 关联业务 ID */
    private Long refId;

    /** 是否已读：0未读 1已读 */
    private Integer readFlag;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
