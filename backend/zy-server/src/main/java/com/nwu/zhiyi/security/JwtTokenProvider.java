package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.UserRole;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * JWT 令牌提供者：签发、解析、校验访问令牌。
 *
 * <p>令牌载荷包含：{@code sub}=学号、{@code role}=角色、{@code typ}=access/refresh、
 * {@code jti}=令牌唯一编号（撤销的依据）。
 *
 * <p><b>业务代码只应使用两个入口</b>：{@link #parseAccessToken(String)} 与
 * {@link #parseRefreshToken(String)}。它们把「签名 + 签发者 + 是否已撤销 + 令牌类型」
 * 四重校验内聚在 API 内部，失败时抛 {@link TokenAuthException} 并带上错误码
 * （2004 已过期 / 2003 无效、已撤销或类型不符）。
 *
 * <p><b>为什么把令牌类型校验收进这里</b>：一旦调用方忘记校验，刷新令牌（7 天）
 * 就能当作访问令牌（12 小时）使用，攻击窗口放大十几倍；而「忘记」迟早会发生 ——
 * 将来任何新增的解析入口（文件下载、SSE、WebSocket 握手）都是一次机会。
 * 把校验收敛进 API，调用方才不可能忘。
 *
 * <p>{@link #parse(String)} 为兼容保留的「宽松读取」：不校验令牌类型、失败返回 null，
 * 仅供撤销与测试等无需区分失败原因的场景使用。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
public class JwtTokenProvider {

    public static final String CLAIM_ROLE = "role";
    public static final String CLAIM_TYPE = "typ";
    public static final String CLAIM_JTI = "jti";
    public static final String TYPE_ACCESS = "access";
    public static final String TYPE_REFRESH = "refresh";

    private final JwtProperties jwtProperties;
    private final TokenRevocationService tokenRevocationService;

    private volatile SecretKey cachedKey;

    public JwtTokenProvider(JwtProperties jwtProperties) {
        this(jwtProperties, new TokenRevocationService());
    }

    @Autowired
    public JwtTokenProvider(JwtProperties jwtProperties, TokenRevocationService tokenRevocationService) {
        this.jwtProperties = jwtProperties;
        this.tokenRevocationService = tokenRevocationService;
        String secret = jwtProperties.getSecret();
        if (secret == null || secret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException(
                    "ZHIYI_JWT_SECRET must be configured with at least 32 UTF-8 bytes; refusing to start with an unsafe JWT key");
        }
    }

    /** 获取已在启动时校验过长度的签名密钥。 */
    private SecretKey signingKey() {
        if (cachedKey == null) {
            synchronized (this) {
                if (cachedKey == null) {
                    cachedKey = Keys.hmacShaKeyFor(jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8));
                }
            }
        }
        return cachedKey;
    }

    /**
     * 签发访问令牌。
     *
     * @param sno  学号
     * @param role 角色
     * @return JWT 字符串
     */
    public String createAccessToken(String sno, UserRole role) {
        return createToken(sno, role, TYPE_ACCESS, jwtProperties.getExpireMinutes());
    }

    /**
     * 签发刷新令牌。
     *
     * @param sno  学号
     * @param role 角色
     * @return JWT 字符串
     */
    public String createRefreshToken(String sno, UserRole role) {
        return createToken(sno, role, TYPE_REFRESH, jwtProperties.getRefreshExpireMinutes());
    }

    private String createToken(String sno, UserRole role, String type, long expireMinutes) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + expireMinutes * 60_000L);
        Map<String, Object> claims = new HashMap<>(4);
        claims.put(CLAIM_ROLE, role == null ? UserRole.USER.name() : role.name());
        claims.put(CLAIM_TYPE, type);
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(sno)
                .setId(UUID.randomUUID().toString())
                .setIssuer(jwtProperties.getIssuer())
                .setIssuedAt(now)
                .setExpiration(expiry)
                .signWith(signingKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * 解析并校验「访问令牌」：签名 + 签发者 + 撤销状态 + 类型必须为 {@code access}。
     *
     * @param token JWT 字符串
     * @return 令牌载荷
     * @throws TokenAuthException 已过期则错误码为 2004；无效 / 已撤销 / 类型不符则为 2003
     */
    public Claims parseAccessToken(String token) {
        Claims claims = verify(token);
        requireType(claims, TYPE_ACCESS);
        return claims;
    }

    /**
     * 解析并校验「刷新令牌」：签名 + 签发者 + 撤销状态 + 类型必须为 {@code refresh}。
     *
     * @param token JWT 字符串
     * @return 令牌载荷
     * @throws TokenAuthException 已过期则错误码为 2004；无效 / 已撤销 / 类型不符则为 2003
     */
    public Claims parseRefreshToken(String token) {
        Claims claims = verify(token);
        requireType(claims, TYPE_REFRESH);
        return claims;
    }

    /**
     * 宽松读取：失败一律返回 null，且<b>不校验令牌类型</b>。
     *
     * <p>保留此签名是为了兼容既有调用（{@link #validate}、{@link #getJti} 等）与测试；
     * 业务代码请改用 {@link #parseAccessToken} / {@link #parseRefreshToken}。
     *
     * @param token JWT 字符串
     * @return 载荷，失败返回 null
     */
    public Claims parse(String token) {
        try {
            return verify(token);
        } catch (TokenAuthException e) {
            return null;
        }
    }

    /** 撤销一个尚未过期的令牌。撤销接口不依赖 {@link #parse(String)}，避免重复撤销时无法读取 jti。 */
    public boolean revoke(String token) {
        try {
            Claims claims = parseSignedClaims(token);
            String jti = claims.getId();
            Date expiration = claims.getExpiration();
            if (jti == null || expiration == null || !expiration.after(new Date())) {
                return false;
            }
            tokenRevocationService.revoke(jti, expiration.toInstant());
            return true;
        } catch (Exception e) {
            log.debug("令牌撤销失败：{}", e.getMessage());
            return false;
        }
    }

    /** 从已验签令牌中读取 jti，令牌无效或已撤销时返回 null。 */
    public String getJti(String token) {
        Claims claims = parse(token);
        return claims == null ? null : claims.getId();
    }

    private Claims parseSignedClaims(String token) {
        Jws<Claims> jws = Jwts.parserBuilder()
                .setSigningKey(signingKey())
                .requireIssuer(jwtProperties.getIssuer())
                .build()
                .parseClaimsJws(token);
        return jws.getBody();
    }

    /**
     * 四重校验中的前三重：签名 + 签发者 + 撤销状态，失败抛带原因的异常。
     *
     * <p>刻意<b>不把失败原因压成 null</b> —— 前端需要区分「该静默刷新」与「该重新登录」。
     */
    private Claims verify(String token) {
        try {
            Claims claims = parseSignedClaims(token);
            if (tokenRevocationService.isRevoked(claims.getId())) {
                throw new TokenAuthException(ErrorCode.TOKEN_INVALID, "令牌已失效，请重新登录");
            }
            return claims;
        } catch (ExpiredJwtException e) {
            log.debug("[令牌] 已过期：{}", e.getMessage());
            throw new TokenAuthException(ErrorCode.TOKEN_EXPIRED, "令牌已过期", e);
        } catch (TokenAuthException e) {
            throw e;
        } catch (Exception e) {
            log.debug("[令牌] 校验失败：{}", e.getMessage());
            throw new TokenAuthException(ErrorCode.TOKEN_INVALID, "令牌无效", e);
        }
    }

    /** 第四重校验：令牌类型 */
    private void requireType(Claims claims, String expectedType) {
        String actualType = claims.get(CLAIM_TYPE, String.class);
        if (!expectedType.equals(actualType)) {
            String hint = TYPE_ACCESS.equals(expectedType) ? "访问令牌" : "刷新令牌";
            log.debug("[令牌] 类型不匹配：期望 {}，实际 {}", expectedType, actualType);
            throw new TokenAuthException(ErrorCode.TOKEN_INVALID, "令牌类型不正确，请使用" + hint);
        }
    }

    /**
     * 校验令牌是否有效。
     *
     * @param token JWT 字符串
     * @return 有效返回 true
     */
    public boolean validate(String token) {
        return parse(token) != null;
    }

    /** 从令牌提取学号 */
    public String getSno(String token) {
        Claims claims = parse(token);
        return claims == null ? null : claims.getSubject();
    }

    /** 从令牌提取角色 */
    public String getRole(String token) {
        Claims claims = parse(token);
        return claims == null ? null : claims.get(CLAIM_ROLE, String.class);
    }

    /** 从令牌提取令牌类型 */
    public String getType(String token) {
        Claims claims = parse(token);
        return claims == null ? null : claims.get(CLAIM_TYPE, String.class);
    }

    /** 访问令牌有效期的秒数（返回给前端用于续期提示） */
    public long getExpireSeconds() {
        return jwtProperties.getExpireMinutes() * 60L;
    }
}