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
 * 仲裁投票实体 —— 对应表 {@code zy_arbitration_vote}。
 *
 * <p>同一争议下每位委员仅能投一票（唯一索引保证），投票过程匿名、结果公示。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_arbitration_vote")
public class ArbitrationVote implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private Long disputeId;

    /** 仲裁委员学号 */
    private String voterSno;

    /** 投票：APPLICANT 支持申诉人 / RESPONDENT 支持被申诉人 / ABSTAIN 弃权 */
    private String vote;

    private String comment;

    /**
     * 投票内容 SHA-256（FR-M8-05 匿名表决的可核查存证）。
     *
     * <p>公示时只暴露票数分布，不暴露"谁投了什么"。但若事后出现舞弊指控
     * （例如怀疑某委员的票被篡改），可用该哈希验证"这条投票记录自提交起未被改动"。
     * 这是"匿名"与"可审计"的折中：<b>对社区匿名，对审计透明</b>。
     */
    private String voteHash;

    /** 委员抽取依据（如"信用 132、跨 3 个学院、非当事人"），保证程序正义可追溯 */
    private String selectionReason;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /* ---------------- 投票取值常量 ---------------- */

    public static final String VOTE_APPLICANT = "APPLICANT";
    public static final String VOTE_RESPONDENT = "RESPONDENT";
    public static final String VOTE_ABSTAIN = "ABSTAIN";

    /** 是否支持申诉人 */
    public boolean isForApplicant() {
        return VOTE_APPLICANT.equals(vote);
    }

    /** 是否支持被申诉人 */
    public boolean isForRespondent() {
        return VOTE_RESPONDENT.equals(vote);
    }

    /** 是否弃权 */
    public boolean isAbstain() {
        return VOTE_ABSTAIN.equals(vote);
    }
}
