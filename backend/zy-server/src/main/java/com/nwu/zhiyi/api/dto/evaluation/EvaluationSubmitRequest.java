package com.nwu.zhiyi.api.dto.evaluation;

import lombok.Data;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.io.Serializable;
import java.util.Map;

/**
 * 提交互评请求（FR-M6-01 / FR-M6-02）。
 *
 * @author 李泽宬
 */
@Data
public class EvaluationSubmitRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 交换记录 ID */
    @NotNull(message = "交换记录不能为空")
    private Long recordId;

    /**
     * 维度分，key 为维度键：
     * {@code task_completion}、{@code delivery_quality}、
     * {@code communication}、{@code cross_discipline}，取值 0~100。
     */
    @NotNull(message = "评价维度分不能为空")
    private Map<String, Object> dimScores;

    /** 文字评语（总分低于 60 时必填且不少于 15 字） */
    @Size(max = 1000, message = "评语不能超过 1000 字")
    private String comment;

    /** 是否匿名：true 表示对被评价人隐藏评价人身份 */
    private Boolean anonymous;
}
