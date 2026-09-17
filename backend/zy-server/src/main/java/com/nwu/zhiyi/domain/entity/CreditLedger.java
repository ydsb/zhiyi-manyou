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
 * 信用值变动流水实体 —— 对应表 {@code zy_credit_ledger}。
 *
 * <p>信用值只增不改：任何变动都追加一条流水，{@code scoreAfter} 记录变动后的快照，
 * 便于对账与申诉复查。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_credit_ledger")
public class CreditLedger implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String sno;

    /** 变动值（正加负减） */
    private Integer delta;

    /** 变动后信用值 */
    private Integer scoreAfter;

    /** 原因：EXCHANGE_DONE / EVAL_RECEIVED / TIMEOUT / DISPUTE_LOST / BADGE ... */
    private String reason;

    private Long refRecordId;

    private String remark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
