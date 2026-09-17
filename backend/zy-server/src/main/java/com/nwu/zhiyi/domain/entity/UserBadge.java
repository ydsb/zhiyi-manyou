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
 * 用户勋章授予记录实体 —— 对应表 {@code zy_user_badge}。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_user_badge")
public class UserBadge implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String sno;

    private Long badgeId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime grantedAt;

    /** 触发授予的交换记录 ID */
    private Long refRecordId;
}
