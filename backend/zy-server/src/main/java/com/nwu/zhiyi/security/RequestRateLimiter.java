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
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.List;

/**
 * 轻量固定窗口限流器。
 *
 * <p>限流状态当前保存在本机内存，适用于单实例开发环境；多实例部署时应迁移到 Redis。
 */
@Component
public class RequestRateLimiter {

    private static final DefaultRedisScript<Long> REDIS_ACQUIRE = new DefaultRedisScript<>(
            "local n=redis.call('INCR',KEYS[1]); if n==1 then redis.call('PEXPIRE',KEYS[1],ARGV[1]); end; " +
                    "if n<=tonumber(ARGV[2]) then return 1 else return 0 end", Long.class);

    private final Map<String, Window> windows = new ConcurrentHashMap<>();
    private final StringRedisTemplate redis;
    private final boolean redisEnabled;

    public RequestRateLimiter() { this(null, false); }

    @Autowired
    public RequestRateLimiter(StringRedisTemplate redis,
            @Value("${zhiyi.security.state-store:local}") String stateStore) {
        this(redis, "redis".equalsIgnoreCase(stateStore));
    }

    private RequestRateLimiter(StringRedisTemplate redis, boolean redisEnabled) {
        this.redis = redis;
        this.redisEnabled = redisEnabled;
    }

    /** 超限时抛出统一业务异常。 */
    public void check(String key, int maxRequests, Duration window) {
        if (!tryAcquire(key, maxRequests, window)) {
            throw new BusinessException(ErrorCode.RATE_LIMITED);
        }
    }

    /** 尝试消耗一次配额。 */
    public boolean tryAcquire(String key, int maxRequests, Duration window) {
        if (maxRequests <= 0 || window == null || window.isZero() || window.isNegative()) {
            throw new IllegalArgumentException("maxRequests and window must be positive");
        }
        String normalizedKey = key == null || key.isBlank() ? "unknown" : key.trim();
        long windowMillis = Math.max(1, window.toMillis());
        if (redisEnabled) {
            Long allowed = redis.execute(REDIS_ACQUIRE, List.of("zhiyi:security:rate:" + normalizedKey),
                    Long.toString(windowMillis), Integer.toString(maxRequests));
            return Long.valueOf(1L).equals(allowed);
        }
        long now = System.currentTimeMillis();
        final boolean[] allowed = {false};
        windows.compute(normalizedKey, (ignored, current) -> {
            if (current == null || now - current.startedAt >= windowMillis) {
                allowed[0] = true;
                return new Window(now, windowMillis, 1);
            }
            if (current.count < maxRequests) {
                current.count++;
                allowed[0] = true;
            }
            return current;
        });
        return allowed[0];
    }

    /** 清理已过期窗口，避免低频 key 无限增长。 */
    public int cleanupExpired(Duration window) {
        if (window == null || window.isNegative() || window.isZero()) {
            throw new IllegalArgumentException("window must be positive");
        }
        long cutoff = System.currentTimeMillis() - window.toMillis();
        int removed = 0;
        for (Map.Entry<String, Window> entry : windows.entrySet()) {
            if (entry.getValue().startedAt <= cutoff && windows.remove(entry.getKey(), entry.getValue())) {
                removed++;
            }
        }
        return removed;
    }

    @Scheduled(fixedDelay = 600_000L, initialDelay = 600_000L)
    void scheduledCleanup() {
        long now = System.currentTimeMillis();
        for (Map.Entry<String, Window> entry : windows.entrySet()) {
            Window window = entry.getValue();
            if (now - window.startedAt >= window.windowMillis) {
                windows.remove(entry.getKey(), window);
            }
        }
    }

    private static final class Window {
        private final long startedAt;
        private final long windowMillis;
        private int count;

        private Window(long startedAt, long windowMillis, int count) {
            this.startedAt = startedAt;
            this.windowMillis = windowMillis;
            this.count = count;
        }
    }
}
