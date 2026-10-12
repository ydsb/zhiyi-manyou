package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.LoginRequest;
import com.nwu.zhiyi.api.dto.LoginVO;
import com.nwu.zhiyi.api.dto.RefreshTokenRequest;
import com.nwu.zhiyi.api.dto.RegisterRequest;
import com.nwu.zhiyi.api.dto.UserInfoVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.security.JwtTokenProvider;
import com.nwu.zhiyi.security.LoginProtectionService;
import com.nwu.zhiyi.security.RequestRateLimiter;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import jakarta.servlet.http.HttpServletRequest;

import java.time.Duration;
import java.util.Map;

/**
 * 认证接口。
 *
 * <p>对应需求 FR-M1-01（统一身份认证登录）、FR-M1-02（降级注册）、FR-M1-07（账号注销与导出）。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final JwtTokenProvider tokenProvider;
    private final LoginProtectionService loginProtectionService;
    private final RequestRateLimiter requestRateLimiter;

    /**
     * 账号密码登录。
     *
     * <pre>POST /api/auth/login</pre>
     */
    @PostMapping("/login")
    public ApiResponse<LoginVO> login(@Valid @RequestBody LoginRequest request,
                                      HttpServletRequest httpRequest) {
        String clientIp = clientIp(httpRequest);
        requestRateLimiter.check("auth:login:" + clientIp, 10, Duration.ofMinutes(5));
        loginProtectionService.ensureAllowed(request.getSno(), clientIp);
        try {
            LoginVO result = authService.login(request);
            loginProtectionService.recordSuccess(request.getSno(), clientIp);
            return ApiResponse.success("登录成功", result);
        } catch (BusinessException ex) {
            if (ex.getErrorCode() == ErrorCode.LOGIN_FAILED) {
                loginProtectionService.recordFailure(request.getSno(), clientIp);
            }
            throw ex;
        }
    }

    /**
     * 注册（降级方案）。生产环境对接 CAS/OAuth 2.0 后仍保留作为兜底入口。
     *
     * <pre>POST /api/auth/register</pre>
     */
    @PostMapping("/register")
    public ApiResponse<LoginVO> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.success("注册成功，请等待学号核验", authService.register(request));
    }

    /**
     * 刷新访问令牌。
     *
     * <pre>POST /api/auth/refresh</pre>
     */
    @PostMapping("/refresh")
    public ApiResponse<LoginVO> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ApiResponse.success(authService.refresh(request.getRefreshToken()));
    }

    /**
     * 获取当前登录用户信息。
     *
     * <pre>GET /api/auth/me</pre>
     */
    @GetMapping("/me")
    public ApiResponse<UserInfoVO> me() {
        return ApiResponse.success(authService.getUserInfo(SecurityUtils.currentSno()));
    }

    /**
     * 退出登录。
     *
     * <p>撤销当前访问令牌，前端随后清除本地令牌。
     *
     * <pre>POST /api/auth/logout</pre>
     */
    @PostMapping("/logout")
    public ApiResponse<Void> logout(HttpServletRequest request,
                                    @RequestBody(required = false) Map<String, String> body) {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            tokenProvider.revoke(header.substring("Bearer ".length()).trim());
        }
        if (body != null && body.get("refreshToken") != null) {
            tokenProvider.revoke(body.get("refreshToken"));
        }
        return ApiResponse.success("已退出登录", null);
    }

    private String clientIp(HttpServletRequest request) {
        // 默认只信任容器看到的对端地址，避免客户端伪造 X-Forwarded-For 绕过限流。
        // 若生产环境前置了反向代理，应在代理层先覆盖并校验该地址，再接入可信代理解析。
        return request.getRemoteAddr() == null ? "unknown" : request.getRemoteAddr();
    }
}
