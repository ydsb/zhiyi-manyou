package com.nwu.zhiyi.api.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import java.io.Serializable;

/**
 * 刷新令牌请求。
 *
 * @author 李泽宬
 */
@Data
public class RefreshTokenRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotBlank(message = "刷新令牌不能为空")
    private String refreshToken;
}
