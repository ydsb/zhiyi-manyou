package com.nwu.zhiyi.api.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 登录请求。
 *
 * @author 李泽宬
 */
@Data
public class LoginRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 学号 */
    @NotBlank(message = "学号不能为空")
    @Size(max = 32, message = "学号长度不能超过 32 位")
    private String sno;

    /** 密码 */
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 64, message = "密码长度需为 6~64 位")
    private String password;
}
