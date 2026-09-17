package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.DemandInterestStatus;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 需求交换意向实体 —— 对应表 {@code zy_demand_interest}。
 *
 * <p>记录"谁对哪张卡片发起了交换邀约"。唯一索引
 * {@code (demand_id, applicant_sno)} 保证同一人对同一卡片只能有一条记录，
 * 与 {@code Demand.matchCount} 配合用于刷单识别（FR-M4-07）。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_demand_interest")
public class DemandInterest implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private Long demandId;

    /** 申请人学号（提供技能的一方） */
    private String applicantSno;

    /** 发起后生成的交换记录 ID */
    private Long recordId;

    /** 申请时的匹配度快照 */
    private BigDecimal matchScore;

    private DemandInterestStatus status;

    /** 申请留言 */
    private String message;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /** 是否仍在等待响应 */
    public boolean isPending() {
        return status == DemandInterestStatus.PENDING;
    }
}
