package com.nwu.zhiyi.security;

import cn.hutool.core.util.StrUtil;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
 * <p><b>失败原因如何传递</b>：本过滤器无法决定响应体（它不知道当前是公开接口还是
 * 受保护接口），所以只把失败的错误码挂到请求属性 {@link #AUTH_FAILURE_ATTRIBUTE} 上，
 * 由 {@code RestAuthenticationEntryPoint} 在真正需要拒绝时取用。若不这么做，
 * 「令牌过期」「令牌无效」「账号被禁用」「压根没带令牌」会全部退化成同一个 2001，
 * 前端就无法区分「该静默刷新」和「该跳登录页」。
 *
 * <p><b>两道校验</b>：
 * <ol>
 *   <li>令牌本身 —— 签名、签发者、是否已撤销、令牌类型，由
 *       {@link JwtTokenProvider#parseAccessToken(String)} 内聚完成，失败原因随异常带出；</li>
 *   <li>与数据库对账 —— 令牌是自述的，账号被禁用或注销后，未过期的旧令牌必须立即失效。</li>
 * </ol>
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    public static final String HEADER = "Authorization";
    public static final String PREFIX = "Bearer ";

    /** 认证失败原因（{@link ErrorCode}）的请求属性名，供 RestAuthenticationEntryPoint 读取 */
    public static final String AUTH_FAILURE_ATTRIBUTE = "zhiyi.authFailure";

    /** 无状态、线程安全，复用同一实例即可，无需每个请求新建 */
    private static final WebAuthenticationDetailsSource DETAILS_SOURCE = new WebAuthenticationDetailsSource();

    private final JwtTokenProvider tokenProvider;
    private final StudentMapper studentMapper;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        String token = resolveToken(request);
        if (StrUtil.isNotBlank(token) && SecurityContextHolder.getContext().getAuthentication() == null) {
            authenticate(request, token);
        }
        chain.doFilter(request, response);
    }

    /**
     * 尝试用令牌建立认证上下文。
     *
     * <p>任何失败都只记录原因、不抛出也不提前放行：是否拒绝该请求由后续授权规则决定。
     */
    private void authenticate(HttpServletRequest request, String token) {
        try {
            Claims claims = tokenProvider.parseAccessToken(token);

            String sno = claims.getSubject();
            if (StrUtil.isBlank(sno)) {
                // 令牌签名有效但缺少学号：不构造"已认证但主体为空"的上下文，
                // 否则后续 currentSno() 返回 null，一次认证问题会变成难查的 500。
                log.warn("[认证] 令牌缺少 sub（学号），已忽略该令牌");
                request.setAttribute(AUTH_FAILURE_ATTRIBUTE, ErrorCode.TOKEN_INVALID);
                return;
            }

            // 令牌自述有效还不够：账号被禁用（0）或注销（2）后，旧令牌必须立即失效
            Integer accountStatus = studentMapper.selectStatusBySno(sno);
            if (accountStatus == null || accountStatus != 1) {
                log.debug("[认证] 账号状态不可用（status={}），已忽略该令牌", accountStatus);
                request.setAttribute(AUTH_FAILURE_ATTRIBUTE, ErrorCode.ACCOUNT_DISABLED);
                return;
            }

            // 角色取值与非法值降级（-> USER）统一由 UserPrincipal.of 负责，这里只传原始声明，
            // 避免同一套解析逻辑在过滤器和 UserPrincipal 里各写一遍。
            UserPrincipal principal = UserPrincipal.of(sno, claims.get(JwtTokenProvider.CLAIM_ROLE, String.class));

            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
            authentication.setDetails(DETAILS_SOURCE.buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authentication);

        } catch (TokenAuthException e) {
            log.debug("[认证] 令牌校验失败：{}", e.getMessage());
            request.setAttribute(AUTH_FAILURE_ATTRIBUTE, e.getErrorCode());
        }
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