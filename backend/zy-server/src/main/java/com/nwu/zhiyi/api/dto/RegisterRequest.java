package com.nwu.zhiyi.api.dto;

import lombok.Data;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 注册请求（降级方案：邮箱注册 + 学号人工核验）。
 *
 * @author 李泽宬
 */
@Data
public class RegisterRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotBlank(message = "学号不能为空")
    @Size(max = 32, message = "学号长度不能超过 32 位")
    private String sno;

    @NotBlank(message = "姓名不能为空")
    @Size(max = 64, message = "姓名长度不能超过 64 位")
    private String sname;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 64, message = "密码长度需为 6~64 位")
    private String password;

    @Email(message = "邮箱格式不正确")
    private String email;

    @Pattern(regexp = "^$|^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    private String college;

    private String major;

    private String grade;
}
