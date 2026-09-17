package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.match.SemanticMatchRequest;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.service.match.SemanticMatchClient;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 语义匹配接口（S3 · FR-M3-01 ~ 05）。
 *
 * <p>与 M4 集市的关键词降级版并存：
 * <ul>
 *   <li>本接口提供<b>语义通道</b>（理解"数据大屏"≈"ECharts 可视化"这类跨表述）；</li>
 *   <li>算法服务不可用时自动降级到关键词通道，并在响应里明确告知
 *       （{@code channel=keyword}），前端可据此提示用户"当前为关键词匹配"。</li>
 * </ul>
 *
 * <p><b>为什么响应里要带 channel</b>：降级如果对用户不可见，
 * 用户会觉得"系统怎么突然变笨了"却无从得知原因。
 * 明确标注通道，既是可观测性，也是对用户的诚实。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/match")
@RequiredArgsConstructor
public class MatchController {

    private final SemanticMatchClient semanticClient;

    /**
     * 语义检索 Top-K（FR-M3-02 / FR-M3-05）。
     *
     * <pre>POST /api/match/semantic</pre>
     */
    @PostMapping("/semantic")
    public ApiResponse<Map<String, Object>> semantic(@Valid @RequestBody SemanticMatchRequest request) {
        SemanticMatchClient.SearchResult result = semanticClient.search(
                request.getQuery(), request.getTopK(), request.getKind(),
                request.getSeedSkillIds());

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("channel", result.channel());
        data.put("available", result.available());
        data.put("count", result.hits().size());
        data.put("tookMs", result.tookMs());
        if (result.message() != null) {
            data.put("message", result.message());
        }

        List<Map<String, Object>> hits = new ArrayList<>();
        for (SemanticMatchClient.Hit h : result.hits()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("key", h.key());
            m.put("kind", h.kind());
            m.put("skillId", h.skillId());
            m.put("name", h.displayName());
            m.put("score", h.score());
            m.put("semanticScore", h.semanticScore());
            m.put("relationBoost", h.relationBoost());
            // 可解释理由：让用户看到"为什么推荐它"（FR-M3-05）
            m.put("reasons", h.reasons());
            m.put("meta", h.meta());
            hits.add(m);
        }
        data.put("hits", hits);

        // 三种情况分别给出可读提示：正常有结果 / 语义正常但无匹配 / 已降级
        String message;
        if (!result.available()) {
            message = "语义匹配服务暂不可用，已降级到关键词通道";
        } else if (hits.isEmpty()) {
            message = "未找到语义相关的技能";
        } else {
            message = "语义匹配完成";
        }
        return ApiResponse.success(message, data);
    }

    /**
     * 两段文本的语义相似度（用于前端"这条需求与这个技能有多相关"的即时提示）。
     *
     * <pre>POST /api/match/similarity</pre>
     */
    @PostMapping("/similarity")
    public ApiResponse<Map<String, Object>> similarity(
            @RequestBody Map<String, String> body) {
        String left = body.get("left");
        String right = body.get("right");
        Double score = semanticClient.similarity(left, right);

        Map<String, Object> data = new LinkedHashMap<>();
        if (score == null) {
            data.put("available", false);
            data.put("score", null);
            data.put("message", "语义服务不可用，无法计算相似度");
            return ApiResponse.success("语义服务不可用", data);
        }
        data.put("available", true);
        data.put("score", score);
        return ApiResponse.success(data);
    }

    /**
     * 语义匹配服务健康状态（管理端可查看算法服务是否在线）。
     *
     * <pre>GET /api/match/health</pre>
     */
    @GetMapping("/health")
    public ApiResponse<Map<String, Object>> health() {
        return ApiResponse.success(semanticClient.health());
    }
}
