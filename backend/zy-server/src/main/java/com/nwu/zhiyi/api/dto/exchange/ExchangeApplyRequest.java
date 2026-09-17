package com.nwu.zhiyi.api.dto.exchange;

import lombok.Data;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 发起交换邀约请求（FR-M4-05）。
 *
 * <p>申请人 = 提供技能的一方（giver）；卡片发布人 = 学习技能的一方（taker）。
 * 交换双方的技能由卡片自动带入，申请人无需重复填写，避免与卡片描述不一致。
 *
 * @author 李泽宬
 */
@Data
public class ExchangeApplyRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 目标需求卡片 ID */
    @NotNull(message = "需求卡片不能为空")
    private Long demandId;

    /** 申请留言（可选） */
    @Size(max = 255, message = "留言长度不能超过 255 字")
    private String message;

    /** 计划完成时间（可选），格式 yyyy-MM-dd HH:mm:ss */
    private String deadlineAt;
}
