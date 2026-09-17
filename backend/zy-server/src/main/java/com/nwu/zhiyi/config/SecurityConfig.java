package com.nwu.zhiyi.config;

import com.nwu.zhiyi.security.JwtAuthenticationFilter;
import com.nwu.zhiyi.security.RestAccessDeniedHandler;
import com.nwu.zhiyi.security.RestAuthenticationEntryPoint;
import jakarta.servlet.DispatcherType;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.DefaultSecurityFilterChain;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.Collections;
import java.util.Set;

/**
 * Spring Security 6 配置。
 *
 * <p>安全策略：
 * <ul>
 *   <li>无状态（STATELESS），采用 JWT 认证，不使用 Session</li>
 *   <li>关闭 CSRF（前后端分离 + 无 Cookie 会话）</li>
 *   <li>公开接口：登录、注册、健康检查、集市浏览、知识图谱</li>
 *   <li>其余接口需携带有效访问令牌</li>
 *   <li>管理端接口需 ADMIN 角色，仲裁接口需 ARBITRATOR 或 ADMIN 角色</li>
 * </ul>
 *
 * <p>迁移说明（Spring Boot 2.7 → 3.x）：
 * <ul>
 *   <li>{@code @EnableGlobalMethodSecurity(prePostEnabled = true)}
 *       已废弃，替换为 {@link EnableMethodSecurity}</li>
 *   <li>流式配置改为 Lambda DSL（Spring Security 6.1 起
 *       {@code and()} / 无参 {@code csrf()} 等已弃用）</li>
 *   <li>{@code antMatchers} → {@code requestMatchers}</li>
 *   <li>{@code javax.servlet} → {@code jakarta.servlet}（过滤器相关类）</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final RestAuthenticationEntryPoint authenticationEntryPoint;
    private final RestAccessDeniedHandler accessDeniedHandler;

    /** 无需认证即可访问的接口白名单 */
    private static final String[] PUBLIC_ENDPOINTS = {
            "/api/health/**",
            "/api/auth/login",
            "/api/auth/register",
            "/api/auth/refresh",
            // 技能本体：图谱与检索对未登录用户开放，先展示平台价值
            "/api/skills/tree",
            "/api/skills/search",
            "/api/ontology/**",
            // 供需集市：卡片列表与详情匿名可浏览；发布/修改/邀约等写操作需登录
            "/api/demands",
            "/api/demands/*",
            "/api/meta/**",
            /*
             * 凭证验真（FR-M6-04）：匿名开放。
             *
             * 验真场景天然发生在平台之外 —— 用人单位核对简历附件、评奖材料审核，
             * 对方不可能是平台用户。若要求登录就失去了"凭证可对外核验"的意义。
             * 安全上也不构成风险：校验码本身即凭证（8 位十六进制派生自 SHA-256），
             * 且接口只返回该凭证的存证状态与脱敏后的持有人信息。
             */
            "/api/certificates/**",
            "/actuator/health/**",
            "/actuator/info",
            // 容器错误页：放行后未匹配的路径才能被 DispatcherServlet 接管
            "/error"
    };

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 关闭 CSRF：前后端分离 + JWT，无 Cookie 会话
                .csrf(csrf -> csrf.disable())
                // 跨域
                .cors(Customizer.withDefaults())
                // 无状态会话
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // 认证/授权失败处理
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint(authenticationEntryPoint)
                        .accessDeniedHandler(accessDeniedHandler))
                // 授权规则
                .authorizeHttpRequests(auth -> auth
                        // 预检请求放行
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        // 管理端与仲裁端
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")
                        .requestMatchers("/api/arbitration/**").hasAnyRole("ARBITRATOR", "ADMIN")
                        /*
                         * 集市个人接口必须显式要求登录，且必须放在下面的
                         * "/api/demands/**" 放行规则之前 —— 规则按声明顺序匹配，先命中者生效。
                         *
                         * 这里是踩过坑后的修正：早前白名单里写了 "/api/demands/*"，
                         * 本意只想放行卡片详情，但 Ant 的 "*" 匹配任意单层路径段，
                         * 于是 /api/demands/mine 也被放行了。结果未登录访问会穿过安全过滤器
                         * 进到 Controller，由 SecurityUtils 抛业务异常返回
                         * "HTTP 200 + code 2001"，而不是标准的 HTTP 401 —— 语义不清且有隐患。
                         */
                        .requestMatchers(HttpMethod.GET,
                                "/api/demands/mine",
                                "/api/demands/interests/received",
                                "/api/demands/interests/sent").authenticated()
                        // 公开接口
                        .requestMatchers(PUBLIC_ENDPOINTS).permitAll()
                        // 其余接口需登录
                        .anyRequest().authenticated())
                // JWT 过滤器置于用户名密码认证过滤器之前
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        /*
         * 关键：只在 REQUEST 分发上启用安全过滤器链，不处理 ERROR 等内部转发。
         *
         * 为什么需要：Spring Security 6 默认对所有 DispatcherType 生效。当请求处理阶段
         * 抛异常时，容器会内部转发到 /error，而该转发不携带 Authorization 头，
         * 于是被 EntryPoint 拦成 401 —— 把真正的错误（参数校验失败、请求体解析异常等）
         * 掩盖成"未登录"，排查成本极高。
         *
         * 实现方式：在构建 SecurityFilterChain 时用 RequestMatcher 限定分发类型。
         * 这比依赖 HttpSecurity 的内部开关更确定，也不受废弃 API 影响。
         */
        DefaultSecurityFilterChain chain = http.build();
        return new DefaultSecurityFilterChain(
                new DispatcherTypeRequestMatcher(chain.getRequestMatcher(),
                        DispatcherType.REQUEST, DispatcherType.ASYNC),
                chain.getFilters());
    }

    /**
     * 分发类型受限的请求匹配器：先按原匹配器判断，再校验 DispatcherType。
     */
    private static final class DispatcherTypeRequestMatcher implements RequestMatcher {

        private final RequestMatcher delegate;
        private final Set<DispatcherType> allowed;

        private DispatcherTypeRequestMatcher(RequestMatcher delegate, DispatcherType... allowed) {
            this.delegate = delegate;
            this.allowed = java.util.EnumSet.copyOf(java.util.Arrays.asList(allowed));
        }

        @Override
        public boolean matches(jakarta.servlet.http.HttpServletRequest request) {
            return delegate.matches(request) && allowed.contains(request.getDispatcherType());
        }
    }

    /**
     * 密码编码器：BCrypt，强度 10。
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(10);
    }

    /**
     * 显式声明空的 UserDetailsService。
     *
     * <p>本项目认证由 {@code AuthService} + JWT 完成，不使用 Spring Security 的
     * DaoAuthenticationProvider。此处显式声明是为了关闭
     * {@code UserDetailsServiceAutoConfiguration} 在启动时生成的随机密码与告警。
     */
    @Bean
    public UserDetailsService userDetailsService() {
        return username -> {
            throw new UsernameNotFoundException("本项目使用 JWT 认证，请调用 /api/auth/login，用户名：" + username);
        };
    }

    /**
     * 跨域配置：允许本地前端开发端口访问。
     *
     * <p>生产环境应改为具体的域名白名单。
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList(
                "http://localhost:[*]",
                "http://127.0.0.1:[*]"
        ));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Collections.singletonList("*"));
        configuration.setExposedHeaders(Arrays.asList("X-Trace-Id", "Authorization"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
