package com.nwu.zhiyi.security;

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
 * <p>令牌载荷包含：{@code sub}=学号、{@code role}=角色、{@code typ}=access/refresh。
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

    /**
     * 获取已在启动时校验过长度的签名密钥。
     */
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
     * 解析令牌载荷。
     *
     * @param token JWT 字符串
     * @return 载荷，解析失败返回 null
     */
    public Claims parse(String token) {
        try {
            Claims claims = parseSignedClaims(token);
            return tokenRevocationService.isRevoked(claims.getId()) ? null : claims;
        } catch (ExpiredJwtException e) {
            log.debug("令牌已过期：{}", e.getMessage());
            return null;
        } catch (Exception e) {
            log.debug("令牌解析失败：{}", e.getMessage());
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

    /** 从已验签令牌中读取 jti，令牌无效时返回 null。 */
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
