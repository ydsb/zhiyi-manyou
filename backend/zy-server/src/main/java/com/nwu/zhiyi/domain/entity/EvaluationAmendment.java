package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 互评修正记录实体 —— 对应表 {@code zy_evaluation_amendment}（FR-M6-03）。
 *
 * <p>评价本体写入后禁止 UPDATE。争议裁决或笔误更正需要调整分值时，
 * 追加一条修正记录（保留原因、前后分值与操作人），再由服务端把新分补写到
 * {@code zy_evaluation_grade}。这样"原始评价"与"修正历史"都能被追溯，
 * 而不是把历史直接抹掉。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_evaluation_amendment")
public class EvaluationAmendment implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 状态常量 */
    public static final String STATUS_EFFECTIVE = "EFFECTIVE";
    public static final String STATUS_REVOKED = "REVOKED";

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private Long evaluationId;

    private Long recordId;

    /** 修正原因 */
    private String reason;

    /** 变更明细快照（JSON） */
    private String changes;

    private BigDecimal scoreBefore;

    private BigDecimal scoreAfter;

    /** 操作人学号 */
    private String operator;

    private Long disputeId;

    private String status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 是否生效中 */
    public boolean isEffective() {
        return STATUS_EFFECTIVE.equals(status);
    }
}
