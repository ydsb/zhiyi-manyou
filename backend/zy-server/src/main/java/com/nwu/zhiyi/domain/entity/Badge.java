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
 * 数字勋章定义实体 —— 对应表 {@code zy_badge}。
 *
 * <p>视觉上采用像素艺术 / 体素化模块风格：隐喻知识技能如同"基础方块"，
 * 可通过不断交换与重组构建宏大的复合型能力大厦。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_badge")
public class Badge implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 勋章编码（唯一） */
    private String code;

    private String name;

    private String description;

    /** 达成条件表达式，交由规则引擎解析 */
    private String conditionExpr;

    /** 像素/体素风格图标地址 */
    private String icon;

    /** 勋章等级 1~5 */
    private Integer level;

    /** 状态：0停用 1启用 */
    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
