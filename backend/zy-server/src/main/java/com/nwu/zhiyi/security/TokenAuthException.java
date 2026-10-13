package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;

/**
 * 令牌认证失败异常：携带失败原因（{@link ErrorCode}），不丢失信息。
 *
 * <p><b>为什么需要它</b>：把「已过期」与「无效」压成一个 {@code null} 会丢掉原因，
 * 前端因此无法区分「该静默刷新令牌」与「该跳登录页」。用异常承载错误码，原因就不会丢。
 *
 * <p><b>为什么继承 BusinessException</b>：这样 {@code AuthService.refresh} 不需要
 * try/catch，{@code GlobalExceptionHandler} 也会把它转成统一响应体 ——
 * 不必为令牌失败再引入第二套异常体系。
 *
 * <p>注意：{@link JwtAuthenticationFilter} 捕获它后<b>不会立刻拒绝请求</b>，
 * 只把错误码挂到请求属性上（公开接口仍需可匿名访问），最终由
 * {@code RestAuthenticationEntryPoint} 决定响应体。
 *
 * @author 李泽宬
 */
public class TokenAuthException extends BusinessException {

    private static final long serialVersionUID = 1L;

    public TokenAuthException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }

    public TokenAuthException(ErrorCode errorCode, String message, Throwable cause) {
        super(errorCode, message, cause);
    }
}