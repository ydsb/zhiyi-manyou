package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.AuditStatus;
import com.nwu.zhiyi.common.enums.DemandStatus;
import com.nwu.zhiyi.common.enums.DemandVisibility;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 技能需求卡片实体 —— 对应表 {@code zy_demand}（供需集市的 Issue 式卡片）。
 *
 * <p><b>字段语义（容易混淆，务必对齐）</b>：
 * <ul>
 *   <li>{@code expectedSkillId} —— 需求方「我急需」的技能，希望有人教/帮我做</li>
 *   <li>{@code offerSkillId} —— 需求方「我擅长」、愿意作为回报教给对方的技能</li>
 * </ul>
 * 与交换记录 {@link ExchangeRecord} 的对应关系：
 * <pre>
 *   exchange.giveSkillId  = demand.expectedSkillId   // 供给方提供这个技能
 *   exchange.learnSkillId = demand.offerSkillId      // 需求方回馈这个技能
 * </pre>
 * 这正是 FR-M4-06「以技易技」的落点：X ⇄ Y 双向置换，全程无货币结算。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_demand")
public class Demand implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 业务编号（对外展示，如 DM20260701001） */
    private String demandNo;

    /** 发布人学号 */
    private String ownerSno;

    private String title;

    private String description;

    /** 期望技能 ID（我急需） */
    private Long expectedSkillId;

    /** 回馈技能 ID（我可提供） */
    private Long offerSkillId;

    /** 预计投入时长（小时） */
    private Integer expectedHours;

    /** 期望时间段，如「周末下午」 */
    private String expectedPeriod;

    private DemandVisibility visibility;

    private DemandStatus status;

    /** 收到的交换邀约数 */
    private Integer matchCount;

    /** 浏览次数 */
    private Integer viewCount;

    private AuditStatus auditStatus;

    /** 审核说明（命中敏感词/广告特征时记录） */
    private String auditRemark;

    private LocalDateTime expireAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    @TableField(select = false)
    private Integer deleted;

    /* ---------------- 领域行为 ---------------- */

    /** 是否可被发起交换：仍在招募中且审核通过 */
    public boolean isAvailable() {
        return status != null && status.isOpen()
                && (auditStatus == null || auditStatus == AuditStatus.PASSED);
    }

    /** 是否为指定用户发布 */
    public boolean isOwnedBy(String sno) {
        return sno != null && sno.equals(ownerSno);
    }

    /** 是否已过期 */
    public boolean isExpired() {
        return expireAt != null && expireAt.isBefore(LocalDateTime.now());
    }

    /** 以技易技的完整描述 */
    public String describeExchange() {
        return offerSkillId == null
                ? "单向求助（未声明可提供的技能）"
                : "我提供 X ⇄ 我学习 Y";
    }
}
