package com.nwu.zhiyi.config;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/** Redis lease lock for scheduled jobs; JVM lock remains suitable for single-instance development. */
@Slf4j
@Aspect
@Component
public class DistributedJobLockAspect {
    private static final ConcurrentMap<String, String> LOCAL_LOCKS = new ConcurrentHashMap<>();
    private static final DefaultRedisScript<Long> RELEASE = new DefaultRedisScript<>(
            "if redis.call('GET',KEYS[1])==ARGV[1] then return redis.call('DEL',KEYS[1]) else return 0 end", Long.class);

    private final StringRedisTemplate redis;
    private final boolean redisEnabled;
    private final Duration lease;

    public DistributedJobLockAspect(StringRedisTemplate redis,
            @Value("${zhiyi.security.state-store:local}") String stateStore,
            @Value("${zhiyi.jobs.lock-lease-minutes:120}") long leaseMinutes) {
        this.redis = redis;
        this.redisEnabled = "redis".equalsIgnoreCase(stateStore);
        this.lease = Duration.ofMinutes(Math.max(1, leaseMinutes));
    }

    @Around("@annotation(lock)")
    public Object guard(ProceedingJoinPoint joinPoint, DistributedJob lock) throws Throwable {
        String name = "zhiyi:jobs:lock:" + lock.value();
        String owner = UUID.randomUUID().toString();
        boolean acquired;
        if (redisEnabled) {
            acquired = Boolean.TRUE.equals(redis.opsForValue().setIfAbsent(name, owner, lease));
        } else {
            acquired = LOCAL_LOCKS.putIfAbsent(name, owner) == null;
        }
        if (!acquired) {
            log.debug("[定时任务] 已有实例持有锁，跳过本轮：{}", lock.value());
            return null;
        }
        try {
            return joinPoint.proceed();
        } finally {
            if (redisEnabled) redis.execute(RELEASE, java.util.List.of(name), owner);
            else LOCAL_LOCKS.remove(name, owner);
        }
    }
}
