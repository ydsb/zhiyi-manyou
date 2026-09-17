package com.nwu.zhiyi.config;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 缓存配置。
 *
 * <p>当前阶段使用 JVM 进程内缓存（{@link ConcurrentMapCacheManager}）：
 * <ul>
 *   <li>技能标签快照、标签树、图谱关系都是"读多写极少"的字典数据，进程内缓存
 *       即可满足 NFR-P-01 的响应时间目标；</li>
 *   <li>不引入 Redis，避免在 S2 阶段增加部署依赖（Redis 将在 M5 行为日志削峰时引入）；</li>
 *   <li>替换为 Redis 只需新增一个 {@link CacheManager} Bean，调用方无感知。</li>
 * </ul>
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
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager(
                CACHE_SKILL_SNAPSHOT,
                CACHE_SKILL_TREE,
                CACHE_SKILL_SEARCH,
                CACHE_ONTOLOGY_GRAPH
        );
    }
}
