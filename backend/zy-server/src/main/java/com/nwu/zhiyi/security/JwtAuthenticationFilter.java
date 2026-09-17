package com.nwu.zhiyi.security;

import cn.hutool.core.util.StrUtil;
import com.nwu.zhiyi.common.enums.UserRole;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * JWT 认证过滤器：从 {@code Authorization: Bearer <token>} 中解析身份并写入安全上下文。
 *
 * <p>令牌无效或缺失时<b>不直接拒绝</b>，而是放行给后续的授权规则处理，
 * 这样公开接口（登录、注册、集市浏览）仍可匿名访问。
 *
 * @author 李泽宬
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    public static final String HEADER = "Authorization";
    public static final String PREFIX = "Bearer ";

    private final JwtTokenProvider tokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        String token = resolveToken(request);
        if (StrUtil.isNotBlank(token) && SecurityContextHolder.getContext().getAuthentication() == null) {
            Claims claims = tokenProvider.parse(token);
            if (claims != null && JwtTokenProvider.TYPE_ACCESS.equals(claims.get(JwtTokenProvider.CLAIM_TYPE, String.class))) {
                String sno = claims.getSubject();
                UserRole role;
                try {
                    role = UserRole.valueOf(claims.get(JwtTokenProvider.CLAIM_ROLE, String.class));
                } catch (Exception e) {
                    role = UserRole.USER;
                }
                UserPrincipal principal = UserPrincipal.of(sno, role.name());
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        }
        chain.doFilter(request, response);
    }

    /** 从请求头解析 Bearer 令牌 */
    private String resolveToken(HttpServletRequest request) {
        String header = request.getHeader(HEADER);
        if (StrUtil.isNotBlank(header) && header.startsWith(PREFIX)) {
            return header.substring(PREFIX.length()).trim();
        }
        return null;
    }
}
