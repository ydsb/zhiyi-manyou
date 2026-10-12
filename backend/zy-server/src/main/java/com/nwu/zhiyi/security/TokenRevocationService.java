package com.nwu.zhiyi.security;

import org.springframework.stereotype.Component;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 访问令牌撤销记录。
 *
 * <p>当前使用进程内存实现，适合单实例部署。记录带有过期时间，访问时会顺手清理，
 * 后续可以在不改变 {@link JwtTokenProvider} 接口的前提下替换为 Redis 实现。
 */
@Component
public class TokenRevocationService {

    private final Map<String, Instant> revokedTokens = new ConcurrentHashMap<>();
    private final StringRedisTemplate redis;
    private final boolean redisEnabled;

    public TokenRevocationService() { this(null, "local"); }

    @Autowired
    public TokenRevocationService(StringRedisTemplate redis,
            @Value("${zhiyi.security.state-store:local}") String stateStore) {
        this.redis = redis;
        this.redisEnabled = "redis".equalsIgnoreCase(stateStore);
    }

    /** 将 jti 撤销到令牌自然过期时间。 */
    public void revoke(String jti, Instant expiresAt) {
        if (jti == null || jti.isBlank() || expiresAt == null) {
            return;
        }
        if (redisEnabled) {
            long ttl = java.time.Duration.between(Instant.now(), expiresAt).toMillis();
            if (ttl > 0) redis.opsForValue().set(redisKey(jti), "1", java.time.Duration.ofMillis(ttl));
            else redis.delete(redisKey(jti));
            return;
        }
        if (expiresAt.isAfter(Instant.now())) {
            revokedTokens.put(jti, expiresAt);
        } else {
            revokedTokens.remove(jti);
        }
    }

    /** 判断 jti 是否仍在撤销期内。 */
    public boolean isRevoked(String jti) {
        if (jti == null || jti.isBlank()) {
            return false;
        }
        if (redisEnabled) return Boolean.TRUE.equals(redis.hasKey(redisKey(jti)));
        Instant expiresAt = revokedTokens.get(jti);
        if (expiresAt == null) {
            return false;
        }
        if (!expiresAt.isAfter(Instant.now())) {
            revokedTokens.remove(jti, expiresAt);
            return false;
        }
        return true;
    }

    /** 仅用于维护和测试，避免过期记录长期占用内存。 */
    public int cleanupExpired() {
        if (redisEnabled) return 0; // Redis expires entries by TTL.
        Instant now = Instant.now();
        int removed = 0;
        for (Map.Entry<String, Instant> entry : revokedTokens.entrySet()) {
            if (!entry.getValue().isAfter(now) && revokedTokens.remove(entry.getKey(), entry.getValue())) {
                removed++;
            }
        }
        return removed;
    }

    @Scheduled(fixedDelay = 3_600_000L, initialDelay = 3_600_000L)
    void scheduledCleanup() {
        cleanupExpired();
    }

    int size() {
        return revokedTokens.size();
    }

    private String redisKey(String jti) {
        return "zhiyi:security:revoked:" + jti;
    }
}
