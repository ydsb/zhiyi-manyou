package com.nwu.zhiyi.service.match;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 语义匹配客户端 —— 调用 Python NLP 算法服务（S3）。
 *
 * <p><b>需求依据</b>：FR-M3-01/02（Embedding 向量化 + ANN 语义检索）、
 * FR-M3-05（展示可解释理由）、NFR-R-03（保留关键词降级通道）。
 *
 * <p><b>为什么单独抽一个客户端而不直接注入 RestClient</b>：
 * 语义匹配是"增强能力"而非"必须能力" —— 算法服务不可用时，
 * 系统必须能自动退回关键词匹配（M3 原有实现），业务不能中断。
 * 因此本类的核心职责之一是<b>把失败封装成"降级"而不是"异常"</b>，
 * 让上层调用方无需到处写 try/catch。
 *
 * <p><b>降级策略</b>：
 * <ul>
 *   <li>调用超时/连接失败 → 返回 {@code available=false}，上层走关键词通道；</li>
 *   <li>算法服务返回 503（模型未就绪）→ 同样降级，且短时间内不再重试，
 *       避免每次请求都白等一个超时；</li>
 *   <li>返回结果为空 → 视为"无匹配"，<b>不</b>降级 ——
 *       空结果是合法结论，不是故障。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Slf4j
@Component
public class SemanticMatchClient {

    private final ObjectMapper objectMapper;

    /** 算法服务地址 */
    @Value("${zhiyi.nlp.base-url:http://127.0.0.1:8901}")
    private String baseUrl;

    /** 是否启用语义匹配；关闭时直接走关键词通道（便于对比与排障） */
    @Value("${zhiyi.nlp.enabled:true}")
    private boolean enabled;

    /** 连接超时（毫秒）—— 算法服务在本机，超时设短一些 */
    @Value("${zhiyi.nlp.connect-timeout-ms:800}")
    private int connectTimeoutMs;

    /** 读取超时（毫秒）。NFR-P-01 要求 P95 ≤ 300ms，这里给足余量 */
    @Value("${zhiyi.nlp.read-timeout-ms:2500}")
    private int readTimeoutMs;

    /** 连续失败后暂停调用多久（毫秒），避免故障期间每次请求都白等超时 */
    private static final long CIRCUIT_OPEN_MS = 30_000;

    private volatile long circuitOpenUntil = 0L;
    private volatile String lastError = null;

    private volatile RestClient restClient;

    public SemanticMatchClient(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    /* ==================== 对外接口 ==================== */

    /**
     * 一次语义检索的结果。
     *
     * <p><b>available 的语义必须明确</b>：它表示<b>语义通道是否可用</b>，
     * 而不是"这次调用有没有返回东西"。
     * 早期实现写成 {@code !"unavailable".equals(channel)}，结果降级时
     * （channel=keyword）也返回 available=true，前端据此会误以为语义匹配正常。
     * 现在由调用处显式传入，不再靠字符串推断。
     *
     * @param available 语义通道是否可用；false 表示本次已降级到关键词通道
     * @param channel   实际使用的通道：semantic / keyword
     * @param hits      命中列表（降级时为空）
     * @param tookMs    耗时（毫秒）
     * @param message   降级原因或空结果说明（可直接展示给用户）
     */
    public record SearchResult(boolean available, String channel,
                              List<Hit> hits, long tookMs, String message) {

        /** 语义通道正常但无匹配 —— 这是合法结论，不是故障 */
        public static SearchResult noMatch(String message) {
            return new SearchResult(true, "semantic", List.of(), 0, message);
        }

        /** 降级：语义通道不可用，本次未产生结果 */
        public static SearchResult degraded(String message) {
            return new SearchResult(false, "keyword", List.of(), 0, message);
        }
    }

    /**
     * 单条命中。
     *
     * @param key           标识（skill:1 / demand:2）
     * @param kind          类型
     * @param text          原文
     * @param score         最终得分（含图谱加成）
     * @param semanticScore 纯语义得分
     * @param relationBoost 图谱加成
     * @param reasons       可解释理由（FR-M3-05）
     * @param meta          附加信息（技能 id、名称、门类等）
     */
    public record Hit(String key, String kind, String text, double score,
                      double semanticScore, double relationBoost,
                      List<String> reasons, Map<String, Object> meta) {

        /** 取技能数字 id（若为技能命中） */
        public Integer skillId() {
            Object v = meta == null ? null : meta.get("id");
            if (v instanceof Number n) {
                return n.intValue();
            }
            return null;
        }

        /** 取展示名（技能名 / 需求标题），无则退回原文截断 */
        public String displayName() {
            if (meta != null) {
                Object n = meta.get("name");
                if (n == null) {
                    n = meta.get("title");
                }
                if (n != null && !String.valueOf(n).isBlank()) {
                    return String.valueOf(n);
                }
            }
            return text == null ? key : (text.length() > 24 ? text.substring(0, 24) + "…" : text);
        }
    }

    /**
     * 语义检索。
     *
     * @param query        查询文本
     * @param topK         返回条数
     * @param kind         限定类型（SKILL / DEMAND / null 表示不限）
     * @param seedSkillIds 查询已关联的技能 id，用于图谱关系加成
     * @return 检索结果；算法服务不可用时 {@code available=false}
     */
    public SearchResult search(String query, int topK, String kind, List<Integer> seedSkillIds) {
        if (!enabled) {
            return SearchResult.degraded("语义匹配已在配置中关闭（zhiyi.nlp.enabled=false）");
        }
        if (query == null || query.isBlank()) {
            return SearchResult.noMatch("查询文本为空");
        }
        if (isCircuitOpen()) {
            return SearchResult.degraded(
                    "语义服务近期不可用，暂停调用 " + (CIRCUIT_OPEN_MS / 1000) + " 秒（最近错误：" + lastError + "）");
        }

        long t0 = System.currentTimeMillis();
        try {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("query", query);
            body.put("top_k", Math.max(1, Math.min(100, topK)));
            if (kind != null && !kind.isBlank()) {
                body.put("kind", kind);
            }
            if (seedSkillIds != null && !seedSkillIds.isEmpty()) {
                body.put("seed_skill_ids", seedSkillIds);
            }
            body.put("explain", true);

            String resp = client().post()
                    .uri("/search")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(String.class);

            long took = System.currentTimeMillis() - t0;
            JsonNode root = objectMapper.readTree(resp);
            List<Hit> hits = parseHits(root.path("hits"));
            closeCircuit();
            return new SearchResult(true, "semantic", hits, took,
                    hits.isEmpty() ? "语义通道无匹配（这是合法结论，不是故障）" : null);
        } catch (Exception e) {
            openCircuit(e);
            long took = System.currentTimeMillis() - t0;
            log.warn("[语义匹配] 调用失败（{} ms），已降级到关键词通道：{}", took, e.getMessage());
            return SearchResult.degraded("语义服务不可用：" + brief(e));
        }
    }

    /**
     * 计算两段文本的相似度。
     *
     * @param left  文本 A
     * @param right 文本 B
     * @return 相似度 0~1；不可用时返回 {@code null}（调用方据此决定是否用关键词兜底）
     */
    public Double similarity(String left, String right) {
        if (!enabled || isCircuitOpen() || left == null || right == null) {
            return null;
        }
        try {
            Map<String, Object> body = Map.of("left", left, "right", right);
            String resp = client().post()
                    .uri("/match")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(String.class);
            JsonNode root = objectMapper.readTree(resp);
            closeCircuit();
            return root.path("score").asDouble(0.0);
        } catch (Exception e) {
            openCircuit(e);
            log.warn("[语义匹配] 相似度计算失败，返回 null 以便上层兜底：{}", e.getMessage());
            return null;
        }
    }

    /**
     * 健康状态（供管理端与运维查看算法服务是否在线）。
     *
     * @return 状态信息
     */
    public Map<String, Object> health() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("enabled", enabled);
        m.put("baseUrl", baseUrl);
        m.put("circuitOpen", isCircuitOpen());
        m.put("lastError", lastError);
        if (!enabled) {
            m.put("ready", false);
            m.put("message", "语义匹配已关闭");
            return m;
        }
        try {
            String resp = client().get().uri("/health").retrieve().body(String.class);
            JsonNode root = objectMapper.readTree(resp);
            m.put("ready", root.path("ready").asBoolean(false));
            m.put("trainedAt", root.path("trainedAt").asText(null));
            JsonNode idx = root.path("index");
            if (!idx.isMissingNode()) {
                m.put("indexSize", idx.path("size").asInt());
                m.put("dim", idx.path("dim").asInt());
                m.put("indexMode", idx.path("mode").asText());
                m.put("relationEdges", idx.path("relation_edges").asInt());
            }
            closeCircuit();
        } catch (Exception e) {
            m.put("ready", false);
            m.put("message", "算法服务不可达：" + brief(e));
        }
        return m;
    }

    /* ==================== 内部实现 ==================== */

    private RestClient client() {
        RestClient c = restClient;
        if (c == null) {
            synchronized (this) {
                if (restClient == null) {
                    SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
                    factory.setConnectTimeout(Duration.ofMillis(connectTimeoutMs));
                    // Spring 6 起 setReadTimeout 接收 Duration；旧的 int 重载已废弃
                    factory.setReadTimeout(Duration.ofMillis(readTimeoutMs));
                    restClient = RestClient.builder()
                            .baseUrl(baseUrl)
                            .requestFactory(factory)
                            .build();
                }
                c = restClient;
            }
        }
        return c;
    }

    private List<Hit> parseHits(JsonNode arr) {
        List<Hit> hits = new ArrayList<>();
        if (arr == null || !arr.isArray()) {
            return hits;
        }
        for (JsonNode n : arr) {
            List<String> reasons = new ArrayList<>();
            for (JsonNode r : n.path("reasons")) {
                reasons.add(r.asText());
            }
            Map<String, Object> meta = new LinkedHashMap<>();
            JsonNode metaNode = n.path("meta");
            if (metaNode.isObject()) {
                metaNode.fields().forEachRemaining(e ->
                        meta.put(e.getKey(), e.getValue().isNull() ? null
                                : (e.getValue().isNumber() ? e.getValue().numberValue()
                                : e.getValue().asText())));
            }
            hits.add(new Hit(
                    n.path("key").asText(),
                    n.path("kind").asText(),
                    n.path("text").asText(),
                    n.path("score").asDouble(),
                    n.path("semanticScore").asDouble(),
                    n.path("relationBoost").asDouble(),
                    reasons, meta));
        }
        return hits;
    }

    /** 熔断是否处于打开状态 */
    private boolean isCircuitOpen() {
        return System.currentTimeMillis() < circuitOpenUntil;
    }

    private void openCircuit(Exception e) {
        lastError = brief(e);
        circuitOpenUntil = System.currentTimeMillis() + CIRCUIT_OPEN_MS;
    }

    private void closeCircuit() {
        circuitOpenUntil = 0L;
        lastError = null;
    }

    private static String brief(Exception e) {
        String m = e.getMessage();
        if (m == null) {
            m = e.getClass().getSimpleName();
        }
        return m.length() > 120 ? m.substring(0, 120) + "…" : m;
    }
}
