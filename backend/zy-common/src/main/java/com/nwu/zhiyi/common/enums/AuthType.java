package com.nwu.zhiyi.common.enums;

/**
 * 身份认证方式。
 *
 * @author 李泽宬
 */
public enum AuthType {

    /** 学校统一身份认证（CAS） */
    CAS,

    /** OAuth 2.0 授权登录 */
    OAUTH2,

    /** 本地账号密码（开发/降级方案） */
    LOCAL,

    /** 邮箱/手机注册 + 学号人工核验 */
    VERIFY
}
