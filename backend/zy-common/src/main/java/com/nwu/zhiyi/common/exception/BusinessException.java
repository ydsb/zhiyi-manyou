package com.nwu.zhiyi.common.exception;

import com.nwu.zhiyi.common.api.ErrorCode;
import lombok.Getter;

/**
 * 业务异常：由业务规则不满足时主动抛出，由全局异常处理器转换为统一响应体。
 *
 * @author 李泽宬
 */
@Getter
public class BusinessException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    private final ErrorCode errorCode;

    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }

    public BusinessException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public BusinessException(ErrorCode errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    /* ---------------- 便捷静态工厂 ---------------- */

    public static BusinessException of(ErrorCode errorCode) {
        return new BusinessException(errorCode);
    }

    public static BusinessException of(ErrorCode errorCode, String message) {
        return new BusinessException(errorCode, message);
    }

    public static BusinessException paramInvalid(String message) {
        return new BusinessException(ErrorCode.PARAM_INVALID, message);
    }

    public static BusinessException notFound(String message) {
        return new BusinessException(ErrorCode.NOT_FOUND, message);
    }
}
