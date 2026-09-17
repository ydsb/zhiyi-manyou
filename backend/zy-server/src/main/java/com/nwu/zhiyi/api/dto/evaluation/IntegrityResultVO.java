package com.nwu.zhiyi.api.dto.evaluation;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 存证校验结果（FR-M6-04）。
 *
 * <p>既支持按交换编号校验一条交换下的全部评价，也支持按校验码单独校验一条记录
 * （用于《跨学科协作能力鉴定报告》验真）。
 *
 * @author 李泽宬
 */
@Data
public class IntegrityResultVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 校验对象描述 */
    private String target;
    private Long recordId;
    private String recordNo;

    /** 整体结论：true 表示全部记录均未被改动 */
    private Boolean intact;

    /** 被校验的记录数 */
    private Integer checkedCount;

    /** 校验不通过的记录数 */
    private Integer brokenCount;

    /** 逐条明细 */
    private List<Item> items;

    /** 存证等级说明与被校验记录中的最低等级（如实告知可信程度） */
    private String evidenceLevel;
    private String evidenceNote;

    /** 能力鉴定报告相关（按校验码校验时返回） */
    private String verifyCode;
    private String ownerName;
    private String ownerCollege;
    private BigDecimal totalScore;
    private String dimensionSummary;
    private LocalDateTime sealedAt;

    /** 单条校验明细 */
    @Data
    public static class Item implements Serializable {

        private static final long serialVersionUID = 1L;

        private Long evaluationId;
        private String fromName;
        private String toName;
        private BigDecimal totalScore;
        /** 该条是否未被改动 */
        private Boolean intact;
        /** 存证哈希（完整值，便于人工比对） */
        private String recordHash;
        private String evidenceLevel;
        private LocalDateTime sealedAt;
        /** 结论说明 */
        private String message;
    }
}
