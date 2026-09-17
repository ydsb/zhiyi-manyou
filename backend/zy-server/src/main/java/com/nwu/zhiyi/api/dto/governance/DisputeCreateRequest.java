package com.nwu.zhiyi.api.dto.governance;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.io.Serializable;
import java.util.List;

/**
 * 发起争议申诉请求（FR-M8-03）。
 *
 * @author 李泽宬
 */
@Data
public class DisputeCreateRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotNull(message = "交换记录不能为空")
    private Long recordId;

    /** 争议类型：NO_SHOW / QUALITY / EVAL_UNFAIR / PLAGIARISM */
    @NotBlank(message = "请选择争议类型")
    private String disputeType;

    /** 申诉理由（简题，列表页展示） */
    @NotBlank(message = "请填写申诉理由")
    @Size(max = 500, message = "理由不能超过 500 字")
    private String reason;

    /** 详细陈述（给委员会看的事实经过） */
    @Size(max = 1000, message = "陈述不能超过 1000 字")
    private String statement;

    /** 证据材料（附件地址数组；也可直接填文字说明） */
    private List<String> evidence;
}
