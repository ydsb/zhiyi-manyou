package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.LoginRequest;
import com.nwu.zhiyi.api.dto.LoginVO;
import com.nwu.zhiyi.api.dto.RefreshTokenRequest;
import com.nwu.zhiyi.api.dto.RegisterRequest;
import com.nwu.zhiyi.api.dto.UserInfoVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

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

    /**
     * 账号密码登录。
     *
     * <pre>POST /api/auth/login</pre>
     */
    @PostMapping("/login")
    public ApiResponse<LoginVO> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.success("登录成功", authService.login(request));
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
     * <p>JWT 为无状态令牌，服务端不维护会话；前端清除本地令牌即可。
     * 若后续引入 Redis 黑名单，可在此处写入失效记录。
     *
     * <pre>POST /api/auth/logout</pre>
     */
    @PostMapping("/logout")
    public ApiResponse<Void> logout() {
        return ApiResponse.success("已退出登录", null);
    }
}
