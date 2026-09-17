package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.common.api.ErrorCode;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 技能交换流水实体（核心业务表）—— 对应表 {@code zy_exchange_record}。
 *
 * <p>体现平台"去货币化·以技易技"的核心交易逻辑：{@code giverSno} 提供
 * {@code giveSkillId}，{@code takerSno} 回馈 {@code learnSkillId}，全程无货币结算。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_exchange_record")
public class ExchangeRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 业务编号（对外展示，如 ZY2026XXXXXXXX） */
    private String recordNo;

    /** 供给方学号（提供技能的一方） */
    private String giverSno;

    /** 需求方学号（学习技能的一方） */
    private String takerSno;

    /** 供给方提供的技能 ID */
    private Long giveSkillId;

    /** 需求方回馈的技能 ID（以技易技） */
    private Long learnSkillId;

    private String title;

    private String description;

    /** 交换状态（状态机见 {@link ExchangeStatus}；数据库以枚举名存储） */
    private ExchangeStatus status;

    /** 来源需求卡片 ID（若由集市邀约产生） */
    private Long sourceDemandId;

    /** 匹配度分值 0~1 */
    private BigDecimal matchScore;

    /** 预计投入时长（小时） */
    private Integer expectedHours;

    /** 实际投入时长（小时） */
    private BigDecimal actualHours;

    private LocalDateTime startedAt;

    private LocalDateTime deadlineAt;

    /** 进入待互评的时间（用于超时未评价判定） */
    private LocalDateTime pendingEvalAt;

    private LocalDateTime finishedAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    @TableField(select = false)
    private Integer deleted;

    /* ---------------- 领域行为 ---------------- */

    /** 判断给定学号是否为本次交换的参与方 */
    public boolean isParticipant(String sno) {
        return sno != null && (sno.equals(giverSno) || sno.equals(takerSno));
    }

    /** 判断是否为供需双方（双方都存在） */
    public boolean hasBothParties() {
        return giverSno != null && takerSno != null && !giverSno.equals(takerSno);
    }

    /**
     * 流转状态，非法流转抛出业务异常。
     *
     * @param target 目标状态
     */
    public void transferTo(ExchangeStatus target) {
        if (target == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL, "目标状态不能为空");
        }
        ExchangeStatus current = this.status == null ? ExchangeStatus.PUBLISHED : this.status;
        if (!current.canTransferTo(target)) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    String.format("交换状态不允许从「%s」变更为「%s」", current.getLabel(), target.getLabel()));
        }
        this.status = target;
        LocalDateTime now = LocalDateTime.now();
        switch (target) {
            case IN_PROGRESS:
                this.startedAt = now;
                break;
            case PENDING_EVAL:
                this.pendingEvalAt = now;
                break;
            case COMPLETED:
            case CANCELLED:
                this.finishedAt = now;
                break;
            default:
                break;
        }
    }

    /** 当前状态是否允许提交互评 */
    public boolean canEvaluate() {
        return this.status == ExchangeStatus.PENDING_EVAL;
    }
}
