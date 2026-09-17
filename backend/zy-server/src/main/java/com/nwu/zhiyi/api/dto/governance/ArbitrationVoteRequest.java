package com.nwu.zhiyi.api.dto.governance;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 仲裁投票请求（FR-M8-05）。
 *
 * @author 李泽宬
 */
@Data
public class ArbitrationVoteRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 投票：APPLICANT 支持申诉人 / RESPONDENT 支持被申诉人 / ABSTAIN 弃权 */
    @NotBlank(message = "请选择投票选项")
    private String vote;

    /** 投票说明（公示时匿名展示，帮助社区理解裁决理由） */
    @Size(max = 500, message = "投票说明不能超过 500 字")
    private String comment;
}
