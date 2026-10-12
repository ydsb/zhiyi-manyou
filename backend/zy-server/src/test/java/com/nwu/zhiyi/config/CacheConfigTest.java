package com.nwu.zhiyi.config;

import org.junit.jupiter.api.Test;
import org.springframework.cache.CacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.mock;

class CacheConfigTest {

    @Test
    void localCacheManagerKeepsDevelopmentFreeOfRedis() {
        CacheManager manager = new CacheConfig().localCacheManager();

        assertNotNull(manager.getCache(CacheConfig.CACHE_SKILL_SNAPSHOT));
        assertNotNull(manager.getCache(CacheConfig.CACHE_SKILL_TREE));
        assertNotNull(manager.getCache(CacheConfig.CACHE_ONTOLOGY_GRAPH));
    }

    @Test
    void redisCacheManagerDeclaresTheSameCacheRegions() {
        CacheManager manager = new CacheConfig().redisCacheManager(mock(RedisConnectionFactory.class));

        assertNotNull(manager.getCache(CacheConfig.CACHE_SKILL_SNAPSHOT));
        assertNotNull(manager.getCache(CacheConfig.CACHE_SKILL_SEARCH));
    }
}
