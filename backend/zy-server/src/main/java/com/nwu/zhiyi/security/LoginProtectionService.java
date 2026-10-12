package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.springframework.stereotype.Component;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.List;

/**
 * 登录失败保护：同一学号和客户端地址连续失败达到阈值后暂时锁定。
 */
@Component
public class LoginProtectionService {

    static final int MAX_FAILURES = 5;
    static final Duration LOCK_DURATION = Duration.ofMinutes(15);
    private static final DefaultRedisScript<Long> REDIS_FAILURE = new DefaultRedisScript<>(
            "local n=redis.call('HINCRBY',KEYS[1],'failures',1); " +
                    "redis.call('HSET',KEYS[1],'lastFailureAt',ARGV[1]); " +
                    "if n>=tonumber(ARGV[2]) then redis.call('HSET',KEYS[1],'lockedUntil',ARGV[3]); " +
                    "redis.call('PEXPIRE',KEYS[1],ARGV[4]); else redis.call('PEXPIRE',KEYS[1],ARGV[5]); end; return n",
            Long.class);

    private final Map<String, FailureState> states = new ConcurrentHashMap<>();
    private final StringRedisTemplate redis;
    private final boolean redisEnabled;

    public LoginProtectionService() { this(null, "local"); }

    @Autowired
    public LoginProtectionService(StringRedisTemplate redis,
            @Value("${zhiyi.security.state-store:local}") String stateStore) {
        this.redis = redis;
        this.redisEnabled = "redis".equalsIgnoreCase(stateStore);
    }

    public void ensureAllowed(String sno, String clientIp) {
        String key = key(sno, clientIp);
        if (redisEnabled) {
            Object value = redis.opsForHash().get(redisKey(key), "lockedUntil");
            String lockedUntil = value == null ? null : value.toString();
            if (lockedUntil != null && Long.parseLong(lockedUntil) > System.currentTimeMillis()) {
                throw new BusinessException(ErrorCode.LOGIN_RATE_LIMITED);
            }
            return;
        }
        FailureState state = states.get(key);
        if (state != null && state.lockedUntil != null) {
            if (state.lockedUntil.isAfter(Instant.now())) {
                throw new BusinessException(ErrorCode.LOGIN_RATE_LIMITED);
            }
            states.remove(key, state);
        }
    }

    public void recordFailure(String sno, String clientIp) {
        String key = key(sno, clientIp);
        if (redisEnabled) {
            long now = System.currentTimeMillis();
            redis.execute(REDIS_FAILURE, List.of(redisKey(key)), Long.toString(now),
                    Integer.toString(MAX_FAILURES), Long.toString(now + LOCK_DURATION.toMillis()),
                    Long.toString(LOCK_DURATION.toMillis()), Long.toString(Duration.ofHours(1).toMillis()));
            return;
        }
        states.compute(key, (ignored, current) -> {
            FailureState state = current == null ? new FailureState() : current;
            if (state.lockedUntil != null && state.lockedUntil.isAfter(Instant.now())) {
                return state;
            }
            state.failures++;
            state.lastFailureAt = Instant.now();
            if (state.failures >= MAX_FAILURES) {
                state.lockedUntil = Instant.now().plus(LOCK_DURATION);
            }
            return state;
        });
    }

    public void recordSuccess(String sno, String clientIp) {
        String key = key(sno, clientIp);
        if (redisEnabled) redis.delete(redisKey(key));
        else states.remove(key);
    }

    @Scheduled(fixedDelay = 3_600_000L, initialDelay = 3_600_000L)
    void scheduledCleanup() {
        Instant cutoff = Instant.now().minus(Duration.ofHours(1));
        for (Map.Entry<String, FailureState> entry : states.entrySet()) {
            FailureState state = entry.getValue();
            boolean expiredLock = state.lockedUntil != null && !state.lockedUntil.isAfter(Instant.now());
            boolean staleFailure = state.lockedUntil == null
                    && state.lastFailureAt != null
                    && state.lastFailureAt.isBefore(cutoff);
            if (expiredLock || staleFailure) {
                states.remove(entry.getKey(), state);
            }
        }
    }

    private String key(String sno, String clientIp) {
        return normalize(sno) + "@" + normalize(clientIp);
    }

    private String redisKey(String key) {
        try {
            byte[] digest = java.security.MessageDigest.getInstance("SHA-256")
                    .digest(key.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            return "zhiyi:security:login:" + java.util.HexFormat.of().formatHex(digest);
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 is unavailable", e);
        }
    }

    private String normalize(String value) {
        return value == null || value.isBlank() ? "unknown" : value.trim();
    }

    private static final class FailureState {
        private int failures;
        private Instant lockedUntil;
        private Instant lastFailureAt;
    }
}
