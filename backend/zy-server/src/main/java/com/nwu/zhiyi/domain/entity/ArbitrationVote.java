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

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
