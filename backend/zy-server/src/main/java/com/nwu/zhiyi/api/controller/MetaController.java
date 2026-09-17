package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.enums.DemandStatus;
import com.nwu.zhiyi.common.enums.DemandVisibility;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.service.demand.MatchScoreCalculator;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 业务字典接口：把枚举与阈值暴露给前端，避免在界面里硬编码。
 *
 * <p>单独放在 {@code /api/meta} 下，而不是 {@code /api/demands/meta}，
 * 以免与 {@code /api/demands/{id}} 这类模板路径产生歧义。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/meta")
public class MetaController {

    /**
     * 集市与交换相关的可选值与阈值。
     *
     * <pre>GET /api/meta/demands</pre>
     */
    @GetMapping("/demands")
    public ApiResponse<Map<String, Object>> demandMeta() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("visibility", options(DemandVisibility.values()));
        data.put("demandStatus", options(DemandStatus.values()));
        data.put("sort", List.of(
                Map.of("value", "MATCH", "label", "匹配度优先"),
                Map.of("value", "LATEST", "label", "最新发布"),
                Map.of("value", "HOT", "label", "最活跃")));
        data.put("highMatchThreshold", MatchScoreCalculator.HIGH_MATCH_THRESHOLD);
        return ApiResponse.success(data);
    }

    /**
     * 交换状态机：状态标签与合法后继，供前端渲染操作按钮。
     *
     * <pre>GET /api/meta/exchange-status</pre>
     */
    @GetMapping("/exchange-status")
    public ApiResponse<List<Map<String, Object>>> exchangeStatusMeta() {
        List<Map<String, Object>> list = Arrays.stream(ExchangeStatus.values())
                .map(s -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("value", s.name());
                    m.put("label", s.getLabel());
                    m.put("final", s.isFinal());
                    m.put("occupiesQuota", s.isOccupyingQuota());
                    m.put("allowedNext", s.allowedNext().stream().map(Enum::name).sorted()
                            .collect(Collectors.toList()));
                    return m;
                })
                .collect(Collectors.toList());
        return ApiResponse.success(list);
    }

    private List<Map<String, String>> options(Enum<?>[] values) {
        return Arrays.stream(values)
                .map(v -> Map.of("value", v.name(), "label", labelOf(v)))
                .collect(Collectors.toList());
    }

    private String labelOf(Enum<?> value) {
        if (value instanceof DemandVisibility v) {
            return v.getLabel();
        }
        if (value instanceof DemandStatus v) {
            return v.getLabel();
        }
        return value.name();
    }
}
