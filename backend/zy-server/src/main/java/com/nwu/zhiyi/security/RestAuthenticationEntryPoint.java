package com.nwu.zhiyi.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.api.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * 未认证入口点：返回统一响应体的 401（而非 Spring Security 默认的 HTML 页面）。
 *
 * <p><b>错误码的选取</b>：优先采用 {@link JwtAuthenticationFilter} 记录在请求属性上的
 * 失败原因，让前端能区分：
 * <ul>
 *   <li>{@code 2001} 未登录或登录已过期 —— 压根没带令牌</li>
 *   <li>{@code 2004} 令牌已过期 —— 前端可尝试用刷新令牌静默续期</li>
 *   <li>{@code 2003} 令牌无效 / 已撤销 / 类型不符 —— 应引导重新登录</li>
 *   <li>{@code 2005} 账号已被禁用 —— 续期也不会成功，直接提示</li>
 * </ul>
 *
 * <p>注意：必须注入 Spring 容器管理的 {@link ObjectMapper}，
 * 直接 {@code new ObjectMapper()} 会缺少 JSR-310 模块，导致
 * {@code LocalDateTime} 序列化抛 InvalidDefinitionException。
 *
 * @author 李泽宬
 */
@Component
@RequiredArgsConstructor
public class RestAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
                         AuthenticationException authException) throws IOException {
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        ApiResponse<Void> body = ApiResponse.error(resolveErrorCode(request));
        response.getWriter().write(objectMapper.writeValueAsString(body));
    }

    /** 取出 JWT 过滤器记录的失败原因；没有记录说明请求压根没带令牌 */
    private static ErrorCode resolveErrorCode(HttpServletRequest request) {
        Object failure = request.getAttribute(JwtAuthenticationFilter.AUTH_FAILURE_ATTRIBUTE);
        if (failure instanceof ErrorCode errorCode) {
            return errorCode;
        }
        return ErrorCode.UNAUTHORIZED;
    }
}