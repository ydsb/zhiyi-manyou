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

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /** 是否仍在处理中 */
    public boolean isOpen() {
        return "PENDING".equals(status) || "VOTING".equals(status);
    }
}
