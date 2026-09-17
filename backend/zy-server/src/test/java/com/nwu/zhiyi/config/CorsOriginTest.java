package com.nwu.zhiyi.config;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 跨域来源白名单的行为测试（局域网部署的关键防线）。
 *
 * <p><b>本测试锁定一个真实缺陷</b>：为了让同一局域网内的其他设备能登录，
 * 最初把私有网段写成 {@code "http://10.[*].[*].[*]:[*]"}。日志打印出来的
 * 模式列表看起来完全正确，但登录接口始终返回 {@code 403 Invalid CORS request}。
 *
 * <p>根因在 Spring 6 的 {@code CorsConfiguration.OriginPattern}：它只把
 * <b>端口段</b>的 {@code [*]} 视为"任意端口"（内部正则
 * {@code (.*):\[(\*|\d+(,\d+)*)]}），主机名段里的 {@code [*]} 会被
 * {@link java.util.regex.Pattern#quote} 转义成**字面量**。
 * 于是整条规则静默失效 —— 不报错、日志照印，只是永远匹配不上。
 *
 * <p>这类"配置看着对、行为不对"的问题最难排查，因此必须用测试把
 * 正确写法与错误写法同时钉住。
 *
 * <p>验证手段说明：测试直接调用 {@link CorsConfiguration#checkOrigin(String)}
 * 与 {@link CorsConfiguration#checkHeaders(List)}，它们正是
 * {@code CorsFilter} 判定"是否放行"所调用的同一对方法，
 * 因此测的就是真实行为，而不是对字符串做断言。
 *
 * @author 李泽宬
 */
@DisplayName("配置 - 跨域来源白名单（局域网可访问）")
class CorsOriginTest {

    /** 局域网里其他设备真实使用的来源（本机当前网卡 IP 即 10.51.101.24） */
    private static final String LAN_ORIGIN = "http://10.51.101.24:5173";

    /**
     * 直接构造 {@link SecurityConfig} 只取 CORS 配置。
     *
     * <p>三个构造参数传 {@code null}：{@code corsConfigurationSource} 是普通
     * {@code @Bean} 方法，不依赖它们；本测试也不想为它们引入 Mock 框架依赖。
     */
    private CorsConfiguration defaultCors() {
        SecurityConfig config = new SecurityConfig(null, null, null);
        return corsOf(config.corsConfigurationSource(Collections.emptyList()));
    }

    private CorsConfiguration corsOf(CorsConfigurationSource source) {
        assertNotNull(source, "必须注册 CorsConfigurationSource，否则 Spring Security 无从放行");
        CorsConfiguration cfg = source.getCorsConfiguration(new MockHttpServletRequest("POST", "/api/auth/login"));
        assertNotNull(cfg, "所有路径都应命中同一份跨域配置");
        return cfg;
    }

    // ------------------------------------------------------------------
    // 缺陷重放
    // ------------------------------------------------------------------

    @Test
    @DisplayName("重放缺陷：主机名段误写 [*] 会让规则静默失效（403 Invalid CORS request）")
    void hostSegmentBracketStarIsNotAWildcard() {
        CorsConfiguration buggy = new CorsConfiguration();
        buggy.setAllowedOriginPatterns(Arrays.asList("http://10.[*].[*].[*]:[*]"));
        buggy.setAllowCredentials(true);

        assertNull(buggy.checkOrigin(LAN_ORIGIN),
                "若这里不再是 null，说明 Spring 改了 [*] 语义，本类的实现说明需要同步更新");
    }

    @Test
    @DisplayName("正确写法：主机名段用 * 才能匹配局域网来源")
    void hostSegmentPlainStarIsAWildcard() {
        CorsConfiguration fixed = new CorsConfiguration();
        fixed.setAllowedOriginPatterns(Arrays.asList("http://10.*.*.*:[*]"));
        fixed.setAllowCredentials(true);

        assertEquals(LAN_ORIGIN, fixed.checkOrigin(LAN_ORIGIN));
    }

    // ------------------------------------------------------------------
    // 默认白名单行为
    // ------------------------------------------------------------------

    @Test
    @DisplayName("局域网来源必须被放行：带端口的 10/172/192 网段")
    void shouldAllowPrivateLanOrigins() {
        CorsConfiguration cfg = defaultCors();
        for (String origin : Arrays.asList(
                LAN_ORIGIN,
                "http://10.51.101.24:8080",
                "http://192.168.1.5:5173",
                "http://172.16.3.9:5173")) {
            assertEquals(origin, cfg.checkOrigin(origin),
                    origin + " 属于私有网段，局域网部署必须允许 —— 否则其他设备登录会 403");
        }
    }

    @Test
    @DisplayName("本机来源必须被放行：localhost 与 127.0.0.1 任意端口")
    void shouldAllowLoopbackOrigins() {
        CorsConfiguration cfg = defaultCors();
        for (String origin : Arrays.asList(
                "http://localhost:5173",
                "http://localhost:3000",
                "http://127.0.0.1:5173")) {
            assertEquals(origin, cfg.checkOrigin(origin));
        }
    }

    @Test
    @DisplayName("省略端口（http 默认 80）的私有网段来源也要放行")
    void shouldAllowPrivateLanOriginsWithoutPort() {
        CorsConfiguration cfg = defaultCors();
        assertEquals("http://192.168.1.5", cfg.checkOrigin("http://192.168.1.5"),
                "主机构造里 * 不匹配空串，因此必须单独列一条无端口规则");
    }

    @Test
    @DisplayName("公网来源一律拒绝：不能把服务变成任人调用的开放接口")
    void shouldRejectPublicOrigins() {
        CorsConfiguration cfg = defaultCors();
        for (String origin : Arrays.asList(
                "http://evil.com:5173",
                "http://zhiyi.example.com",
                "http://10.evil.com:5173",
                "https://10.51.101.24:5173",
                "http://127.0.0.1.evil.com:5173")) {
            assertNull(cfg.checkOrigin(origin),
                    origin + " 不是受信任来源，绝不能被放行");
        }
    }

    @Test
    @DisplayName("配置项 zhiyi.cors.allowed-origin-patterns 能覆盖默认白名单")
    void configuredPatternsShouldOverrideDefaults() {
        SecurityConfig config = new SecurityConfig(null, null, null);
        CorsConfiguration cfg = corsOf(config.corsConfigurationSource(
                Arrays.asList("  http://demo.zhiyi.edu.cn  ", "")));

        assertEquals("http://demo.zhiyi.edu.cn", cfg.checkOrigin("http://demo.zhiyi.edu.cn"),
                "显式配置应生效，且前后空格需被裁剪");
        assertNull(cfg.checkOrigin(LAN_ORIGIN),
                "一旦显式配置，默认网段应被整体替换而不是叠加");
    }

    // ------------------------------------------------------------------
    // 预检请求（登录失败的直接原因就是它）
    // ------------------------------------------------------------------

    @Test
    @DisplayName("登录 POST 的预检必须被放行：请求头与请求方法都在允许范围内")
    void preflightForJsonPostMustPass() {
        CorsConfiguration cfg = defaultCors();

        assertEquals(LAN_ORIGIN, cfg.checkOrigin(LAN_ORIGIN));
        assertNotNull(cfg.checkHeaders(Arrays.asList(
                        HttpHeaders.CONTENT_TYPE, HttpHeaders.AUTHORIZATION)),
                "application/json 的 POST 会先发预检，请求头必须全部在允许列表内");
        assertTrue(cfg.getAllowCredentials(), "前端需要携带凭证");
        assertTrue(cfg.getMaxAge() != null && cfg.getMaxAge() > 0,
                "缓存预检结果可显著减少局域网下的往返延迟");
    }

    @Test
    @DisplayName("允许的方法需覆盖后端用到的全部动词")
    void shouldAllowAllMethodsUsedByBackend() {
        CorsConfiguration cfg = defaultCors();
        List<String> methods = cfg.getAllowedMethods();
        assertNotNull(methods);
        for (String m : Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")) {
            assertTrue(methods.contains(m), "缺少 " + m + "，相关接口在跨域场景下会被浏览器拦截");
        }
    }

    @Test
    @DisplayName("暴露 X-Trace-Id 与 Authorization，便于前端排查与续期")
    void shouldExposeTraceAndAuthHeaders() {
        CorsConfiguration cfg = defaultCors();
        List<String> exposed = cfg.getExposedHeaders();
        assertNotNull(exposed);
        assertTrue(exposed.contains("X-Trace-Id"));
        assertTrue(exposed.contains("Authorization"));
    }

    @Test
    @DisplayName("白名单中不得再出现主机名段带 [*] 的写法（端口段带 [*] 是合法的）")
    void patternsMustNotUseBracketStarInHostSegment() {
        CorsConfiguration cfg = defaultCors();
        for (String pattern : cfg.getAllowedOriginPatterns()) {
            // 先剥掉 scheme 与端口部分，只留主机名段 —— 端口段的 [*] 是正确的用法，
            // 早期版本的断言把整串都扫了，于是把 "http://localhost:[*]" 误判为违规。
            String hostPart = pattern.replaceFirst("^[a-zA-Z]+://", "")
                    .replaceFirst(":\\[\\*\\]$", "");
            assertFalse(hostPart.contains("[*]"),
                    pattern + " 的主机名段含 [*]，该写法不会被当作通配符，规则将静默失效");
        }
    }
}
