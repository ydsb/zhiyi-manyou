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
 * 争议申诉实体 —— 对应表 {@code zy_dispute}。
 *
 * <p>治理理念：摒弃单一管理员的中心化独断审核，由跨学科、高信用的"社区仲裁委员会"
 * 基于系统抽取的全过程交互数据卷宗进行匿名投票集体决议。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_dispute")
public class Dispute implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 争议交换记录 ID */
    private Long recordId;

    /** 申诉人学号 */
    private String applicant;

    /** 被申诉人学号 */
    private String respondent;

    private String reason;

    /** 证据材料（附件地址数组 JSON） */
    private String evidence;

    /** 状态：PENDING待受理 / VOTING投票中 / RESOLVED已裁决 / REJECTED已驳回 */
    private String status;

    /** 裁决结论 */
    private String verdict;

    private LocalDateTime resolvedAt;

    /* ==================== M8 新增字段 ==================== */

    /** 争议类型（{@code DisputeType}），用于治理规则迭代时的类型统计 */
    private String disputeType;

    /** 申诉人陈述 */
    private String statement;

    /**
     * 被申诉人答辩。
     *
     * <p>给被告申辩机会是程序正义的最低要求 —— 单方陈述即定罪，
     * 委员会看到的就只是片面事实，裁决必然不可靠。
     */
    private String defense;

    /** 表决截止时间（超时未投视为弃权） */
    private LocalDateTime voteDeadline;

    /**
     * 卷宗快照（JSON）：提交时抽取的协作全过程数据。
     *
     * <p><b>为什么存快照而不是每次实时拼接</b>：委员表决依据的必须是一份
     * <b>固定不变</b>的材料。若每次查看都重新查询，后续新产生的数据
     * （例如被申诉人又发了几条留言）会改变卷宗内容，导致"委员 A 与委员 B
     * 看到的事实不同"，裁决的正当性就站不住了。
     */
    private String caseFile;

    /** 裁决执行明细（JSON）：信用变动、评价修正、账号处置 */
    private String executionLog;

    /** 裁决方式：VOTE 委员会投票 / ADMIN 管理员紧急处置 */
    private String resolvedBy;

    /** 应参与仲裁的委员数 */
    private Integer arbitratorCount;

    /** 已投票数 */
    private Integer voteCount;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /** 是否仍在处理中 */
    public boolean isOpen() {
        return "PENDING".equals(status) || "VOTING".equals(status);
    }

    /** 是否处于投票阶段 */
    public boolean isVoting() {
        return "VOTING".equals(status);
    }

    /** 是否已结案（已裁决或已驳回） */
    public boolean isFinal() {
        return "RESOLVED".equals(status) || "REJECTED".equals(status);
    }

    /** 表决是否已截止 */
    public boolean isVoteExpired() {
        return voteDeadline != null && LocalDateTime.now().isAfter(voteDeadline);
    }
}
