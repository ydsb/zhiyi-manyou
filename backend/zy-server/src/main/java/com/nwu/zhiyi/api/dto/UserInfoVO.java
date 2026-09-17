package com.nwu.zhiyi.api.dto;

import lombok.Builder;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户信息视图对象（对外脱敏）。
 *
 * @author 李泽宬
 */
@Data
@Builder
public class UserInfoVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private String sno;

    /** 展示名（昵称优先） */
    private String displayName;

    private String college;

    private String major;

    private String grade;

    private String avatar;

    private String intro;

    /** 角色 */
    private String role;

    /** 认证方式 */
    private String authType;

    /** 实名核验状态 */
    private String authStatus;

    /** 信用值 */
    private Integer creditScore;

    /** 信用等级 */
    private Integer creditLevel;

    private LocalDateTime lastLoginAt;
}
