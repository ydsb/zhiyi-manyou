package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.common.api.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 健康检查接口（匿名可访问）。
 *
 * <p>用于部署验证与前端连通性自测：
 * <pre>
 *   GET /api/health        —— 服务与数据库连通性
 *   GET /api/health/info   —— 平台信息
 * </pre>
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/health")
@RequiredArgsConstructor
public class HealthController {

    private final JdbcTemplate jdbcTemplate;

    /** 服务 + 数据库健康检查 */
    @GetMapping
    public ApiResponse<Map<String, Object>> health() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("application", "zhiyi-manyou");
        data.put("status", "UP");
        try {
            Integer one = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            data.put("database", one != null && one == 1 ? "UP" : "UNKNOWN");
        } catch (Exception e) {
            data.put("database", "DOWN");
            data.put("databaseError", e.getMessage());
        }
        return ApiResponse.success(data);
    }

    /** 平台基本信息 */
    @GetMapping("/info")
    public ApiResponse<Map<String, Object>> info() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("name", "知驿·漫游");
        data.put("fullName", "跨学科技能交换与学习记录平台");
        data.put("version", "1.0.0-SNAPSHOT");
        data.put("description", "以技易技 · 智能匹配 · 全过程学习记录 · 能力可视化");
        data.put("apiPrefix", "/api");
        return ApiResponse.success(data);
    }
}
