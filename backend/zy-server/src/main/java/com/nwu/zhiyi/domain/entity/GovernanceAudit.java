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
 * 治理操作审计日志 —— 对应表 {@code zy_governance_audit}
 * （FR-M8-07 治理过程可追溯 / FR-M8-08 管理员干预须留痕）。
 *
 * <p><b>只追加，不修改不删除</b>。治理的公信力来自"能查"：
 * 每一次信用调整、裁决、封禁、评价修正都必须能回答
 * "谁、在什么时候、依据什么、改了什么"。
 *
 * <p><b>visible 字段的用意</b>：大多数操作应公示（让社区看到治理是透明的），
 * 但涉及个人隐私的操作（如休学账号处理）不宜公示。这类操作
 * {@code visible = 0}：仍然完整留痕、管理员可查，但不出现在公示页。
 * 也就是"可以不公示，但不能不留痕"。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_governance_audit")
public class GovernanceAudit implements Serializable {

    private static final long serialVersionUID = 1L;

    /* ---------------- 操作类型常量 ---------------- */

    /** 信用值调整 */
    public static final String ACTION_CREDIT_ADJUST = "CREDIT_ADJUST";
    /** 争议裁决 */
    public static final String ACTION_DISPUTE_RESOLVE = "DISPUTE_RESOLVE";
    /** 评价修正 */
    public static final String ACTION_EVALUATION_AMEND = "EVALUATION_AMEND";
    /** 账号封禁/解封 */
    public static final String ACTION_ACCOUNT_BAN = "ACCOUNT_BAN";
    /** 治理规则更新 */
    public static final String ACTION_RULE_UPDATE = "RULE_UPDATE";
    /** 管理员紧急干预 */
    public static final String ACTION_ADMIN_INTERVENE = "ADMIN_INTERVENE";
    /** 勋章授予（也记录，便于追溯授予依据） */
    public static final String ACTION_BADGE_GRANT = "BADGE_GRANT";

    /* ---------------- 操作人身份 ---------------- */

    public static final String ROLE_USER = "USER";
    public static final String ROLE_ARBITRATOR = "ARBITRATOR";
    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_SYSTEM = "SYSTEM";

    /** 系统自动执行时使用的操作人标识 */
    public static final String SYSTEM_ACTOR = "SYSTEM";

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String action;

    /** 操作人学号；系统自动执行时为 SYSTEM */
    private String actorSno;

    /** 操作人身份：USER / ARBITRATOR / ADMIN / SYSTEM */
    private String actorRole;

    private String targetType;

    private String targetId;

    /** 人类可读的操作摘要（公示页直接展示） */
    private String summary;

    /** 操作明细 JSON（变更前后值、依据等） */
    private String detail;

    /** 操作理由（管理员紧急干预时必填） */
    private String reason;

    /** 是否在公示页展示：1是 0否 */
    private Integer visible;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 是否公示 */
    public boolean isPublic() {
        return visible != null && visible == 1;
    }

    /** 是否由系统自动执行 */
    public boolean isSystemAction() {
        return SYSTEM_ACTOR.equals(actorSno);
    }
}
