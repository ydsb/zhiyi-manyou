package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.enums.UserRole;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT 令牌提供者：签发、解析、校验访问令牌。
 *
 * <p>令牌载荷包含：{@code sub}=学号、{@code role}=角色、{@code typ}=access/refresh。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtTokenProvider {

    public static final String CLAIM_ROLE = "role";
    public static final String CLAIM_TYPE = "typ";
    public static final String TYPE_ACCESS = "access";
    public static final String TYPE_REFRESH = "refresh";

    private final JwtProperties jwtProperties;

    private volatile SecretKey cachedKey;

    /**
     * 获取签名密钥。密钥不足 32 字节时补零，保证 HS256 可用。
     */
    private SecretKey signingKey() {
        if (cachedKey == null) {
            synchronized (this) {
                if (cachedKey == null) {
                    byte[] raw = jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8);
                    if (raw.length < 32) {
                        byte[] padded = new byte[32];
                        System.arraycopy(raw, 0, padded, 0, raw.length);
                        raw = padded;
                    }
                    cachedKey = Keys.hmacShaKeyFor(raw);
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
            Jws<Claims> jws = Jwts.parserBuilder()
                    .setSigningKey(signingKey())
                    .requireIssuer(jwtProperties.getIssuer())
                    .build()
                    .parseClaimsJws(token);
            return jws.getBody();
        } catch (ExpiredJwtException e) {
            log.debug("令牌已过期：{}", e.getMessage());
            return null;
        } catch (Exception e) {
            log.debug("令牌解析失败：{}", e.getMessage());
            return null;
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
