package com.nwu.zhiyi.api.dto.evaluation;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 追加互评修正记录请求（FR-M6-03，管理端）。
 *
 * <p>评价本体不可修改，因此修正以"追加记录"的方式表达：
 * 保留原因、前后分值与操作人，再由服务端把新分补写到评价表。
 *
 * @author 李泽宬
 */
@Data
public class EvaluationAmendRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotBlank(message = "修正原因不能为空")
    @Size(max = 500, message = "修正原因不能超过 500 字")
    private String reason;

    /** 修正后总分（0~100）。为空表示只追加说明、不改分 */
    private Double totalScore;

    /** 关联争议 ID（若源于仲裁裁决） */
    private Long disputeId;
}
