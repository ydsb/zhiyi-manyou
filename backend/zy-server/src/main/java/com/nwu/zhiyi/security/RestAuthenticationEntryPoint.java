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
        ApiResponse<Void> body = ApiResponse.error(ErrorCode.UNAUTHORIZED);
        response.getWriter().write(objectMapper.writeValueAsString(body));
    }
}
