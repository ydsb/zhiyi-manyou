package com.nwu.zhiyi.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.time.Duration;
import java.util.Map;

/**
 * 缓存配置。
 *
 * <p>默认使用 JVM 进程内缓存；设置 {@code zhiyi.cache.type=redis} 后切换到 Redis，
 * 调用方无需修改。Redis 模式设置 TTL 和 JSON 序列化，避免缓存永久占用空间。
 *
 * <p>缓存区域：
 * <table border="1">
 *   <tr><th>名称</th><th>内容</th><th>失效时机</th></tr>
 *   <tr><td>skillSnapshot</td><td>全量启用技能标签（解析词典）</td><td>标签增删改</td></tr>
 *   <tr><td>skillTree</td><td>三层标签树</td><td>标签增删改</td></tr>
 *   <tr><td>skillSearch</td><td>关键词检索结果</td><td>标签增删改</td></tr>
 *   <tr><td>ontologyGraph</td><td>图谱全部关系边</td><td>关系增删</td></tr>
 * </table>
 *
 * @author 李泽宬
 */
@Configuration
@EnableCaching
public class CacheConfig {

    public static final String CACHE_SKILL_SNAPSHOT = "skillSnapshot";
    public static final String CACHE_SKILL_TREE = "skillTree";
    public static final String CACHE_SKILL_SEARCH = "skillSearch";
    public static final String CACHE_ONTOLOGY_GRAPH = "ontologyGraph";

    @Bean
    @ConditionalOnProperty(prefix = "zhiyi.cache", name = "type", havingValue = "redis")
    public CacheManager redisCacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration defaults = RedisCacheConfiguration.defaultCacheConfig()
                .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(
                        new StringRedisSerializer()))
                .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(
                        new GenericJackson2JsonRedisSerializer()))
                .entryTtl(Duration.ofMinutes(30))
                .disableCachingNullValues();

        Map<String, RedisCacheConfiguration> cacheConfigurations = Map.of(
                CACHE_SKILL_SNAPSHOT, defaults.entryTtl(Duration.ofHours(1)),
                CACHE_SKILL_TREE, defaults.entryTtl(Duration.ofMinutes(30)),
                CACHE_SKILL_SEARCH, defaults.entryTtl(Duration.ofMinutes(10)),
                CACHE_ONTOLOGY_GRAPH, defaults.entryTtl(Duration.ofMinutes(30))
        );

        return RedisCacheManager.builder(connectionFactory)
                .cacheDefaults(defaults)
                .withInitialCacheConfigurations(cacheConfigurations)
                .transactionAware()
                .build();
    }

    @Bean
    @ConditionalOnProperty(prefix = "zhiyi.cache", name = "type", havingValue = "local", matchIfMissing = true)
    public CacheManager localCacheManager() {
        return new ConcurrentMapCacheManager(
                CACHE_SKILL_SNAPSHOT,
                CACHE_SKILL_TREE,
                CACHE_SKILL_SEARCH,
                CACHE_ONTOLOGY_GRAPH
        );
    }
}
