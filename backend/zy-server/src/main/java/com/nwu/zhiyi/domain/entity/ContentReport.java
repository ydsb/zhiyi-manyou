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
 * 内容举报实体 —— 对应表 {@code zy_content_report}（FR-M9-03）。
 *
 * <p><b>与争议（zy_dispute）的分工</b>：
 * <ul>
 *   <li>争议：针对<b>交换履约</b>问题，有当事人双方，走仲裁委员会集体表决；</li>
 *   <li>举报：针对<b>内容违规</b>（广告、辱骂、虚假信息），由管理员直接处置。</li>
 * </ul>
 * 两者处理主体、时限与后果完全不同，因此分表而不是复用。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_content_report")
public class ContentReport implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String reporterSno;

    /** 被举报对象类型：DEMAND / MESSAGE / EVALUATION / SKILL */
    private String targetType;

    private Long targetId;

    /** 举报类型：AD / ABUSE / FAKE / PLAGIARISM / OTHER */
    private String reasonType;

    private String detail;

    /** 状态：PENDING / ACCEPTED / REJECTED */
    private String status;

    private String handlerSno;

    private String handleRemark;

    private LocalDateTime handledAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 是否仍在等待处理 */
    public boolean isPending() {
        return "PENDING".equals(status);
    }
}
