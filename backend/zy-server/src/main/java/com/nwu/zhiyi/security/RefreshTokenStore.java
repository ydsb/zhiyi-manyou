package com.nwu.zhiyi.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 刷新令牌白名单（B 方案的核心）。
 *
 * <p>与 access token 的「jti 黑名单」相反：refresh token 采用<b>白名单</b>——
 * 签发时把它的 {@code jti} 登记进来，刷新时<b>原子消费</b>（删除）该条目。
 *
 * <ul>
 *   <li><b>一次性使用</b>：同一个 refresh token 只能成功刷新一次；并发刷新时只有一个请求能消费成功</li>
 *   <li><b>轮换</b>：刷新成功后签发新的 refresh token，并登记新的 jti</li>
 *   <li><b>登出</b>：删除对应的 jti，旧 refresh token 立即失效</li>
 *   <li><b>默认无效</b>：Redis/本地没有该 jti 就拒绝（不像黑名单是"默认有效"）</li>
 * </ul>
 *
 * <p>存储只放 {@code jti -> sno}，不保存令牌本身 —— Redis 泄露不等于凭证泄露。
 * 默认使用进程内 Map（便于单机开发），设置 {@code zhiyi.security.state-store=redis}
 * 后切换为 Redis，多实例共享。
 *
 * @author yueyong
 */
@Slf4j
@Component
public class RefreshTokenStore {

    private static final String KEY_PREFIX = "zhiyi:auth:refresh:";

    /** 原子消费：只有值匹配（同一用户）时才删除，返回 1 表示消费成功。 */
    private static final DefaultRedisScript<Long> CONSUME = new DefaultRedisScript<>(
            "if redis.call('GET',KEYS[1])==ARGV[1] then return redis.call('DEL',KEYS[1]) else return 0 end",
            Long.class);

    private final Map<String, Session> local = new ConcurrentHashMap<>();
    private final StringRedisTemplate redis;
    private final boolean redisEnabled;
    private final Duration ttl;

    public RefreshTokenStore() {
        this(null, "local", 10080);
    }

    @Autowired
    public RefreshTokenStore(StringRedisTemplate redis,
                             @Value("${zhiyi.security.state-store:local}") String stateStore,
                             @Value("${zhiyi.jwt.refresh-expire-minutes:10080}") long refreshExpireMinutes) {
        this.redis = redis;
        this.redisEnabled = "redis".equalsIgnoreCase(stateStore);
        this.ttl = Duration.ofMinutes(Math.max(1, refreshExpireMinutes));
    }

    /**
     * 登记一个刚签发的 refresh token。
     *
     * @param jti 刷新令牌的 jti
     * @param sno 持有者学号
     */
    public void register(String jti, String sno) {
        if (jti == null || jti.isBlank() || sno == null || sno.isBlank()) {
            throw new IllegalArgumentException("jti and sno must not be blank");
        }
        if (redisEnabled) {
            redis.opsForValue().set(KEY_PREFIX + jti, sno, ttl);
            return;
        }
        local.put(jti, new Session(sno, Instant.now().plus(ttl)));
    }

    /**
     * 原子地消费一个 refresh token：同一个 jti 只有一个调用者能成功。
     *
     * @param jti 刷新令牌的 jti
     * @param sno 令牌声称的持有者
     * @return true = 存在、属于该用户、未过期，且本次已消费；false = 其他所有情况
     */
    public boolean consume(String jti, String sno) {
        if (jti == null || jti.isBlank() || sno == null || sno.isBlank()) {
            return false;
        }
        if (redisEnabled) {
            Long removed = redis.execute(CONSUME, List.of(KEY_PREFIX + jti), sno);
            return Long.valueOf(1L).equals(removed);
        }
        Session session = local.get(jti);
        if (session == null) {
            return false;
        }
        if (!session.expiresAt.isAfter(Instant.now())) {
            local.remove(jti, session);
            return false;
        }
        if (!session.sno.equals(sno)) {
            return false;
        }
        // remove(key, value) 是原子的：并发时只有一个调用者能返回 true
        return local.remove(jti, session);
    }

    /** 删除一个 refresh token（登出时使用）。 */
    public void revoke(String jti) {
        if (jti == null || jti.isBlank()) {
            return;
        }
        if (redisEnabled) {
            redis.delete(KEY_PREFIX + jti);
            return;
        }
        local.remove(jti);
    }

    /** 清理本地过期记录；Redis 模式由 TTL 自动清理。 */
    @Scheduled(fixedDelay = 3_600_000L, initialDelay = 3_600_000L)
    void cleanupExpired() {
        if (redisEnabled) {
            return;
        }
        Instant now = Instant.now();
        local.entrySet().removeIf(e -> !e.getValue().expiresAt.isAfter(now));
    }

    int localSize() {
        return local.size();
    }

    private record Session(String sno, Instant expiresAt) {
    }
}