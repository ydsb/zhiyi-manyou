package com.nwu.zhiyi.api.dto;

import lombok.Builder;
import lombok.Data;

import java.io.Serializable;

/**
 * 登录结果视图对象。
 *
 * @author 李泽宬
 */
@Data
@Builder
public class LoginVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 访问令牌 */
    private String accessToken;

    /** 刷新令牌 */
    private String refreshToken;

    /** 令牌类型，固定为 Bearer */
    private String tokenType;

    /** 访问令牌有效期（秒） */
    private Long expiresIn;

    /** 是否为首次登录（为 true 时前端触发"新手漫游导引"） */
    private Boolean firstLogin;

    /** 用户信息 */
    private UserInfoVO user;
}
