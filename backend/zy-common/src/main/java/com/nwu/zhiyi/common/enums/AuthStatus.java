package com.nwu.zhiyi.common.enums;

/**
 * 实名核验状态。
 *
 * @author 李泽宬
 */
public enum AuthStatus {

    /** 未核验 */
    UNVERIFIED,

    /** 核验中 */
    PENDING,

    /** 已核验 */
    VERIFIED,

    /** 核验失败 */
    FAILED;

    /** 是否已通过核验 */
    public boolean isVerified() {
        return this == VERIFIED;
    }
}
