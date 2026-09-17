package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.admin.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.Map;

/**
 * 管理后台 · 数据看板模块（FR-M9-04）。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/admin/dashboard")
@RequiredArgsConstructor
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;

    /**
     * 实时总览：日活、新增、卡片与交换量、匹配成功率、学科与信用分布。
     *
     * <pre>GET /api/admin/dashboard/overview</pre>
     */
    @GetMapping("/overview")
    public ApiResponse<Map<String, Object>> overview() {
        return ApiResponse.success(adminDashboardService.overview());
    }

    /**
     * 趋势（读日快照）。
     *
     * <pre>GET /api/admin/dashboard/trend?days=14</pre>
     */
    @GetMapping("/trend")
    public ApiResponse<Map<String, Object>> trend(@RequestParam(defaultValue = "14") int days) {
        return ApiResponse.success(adminDashboardService.trend(days));
    }

    /**
     * 手动生成当日快照（定时任务每日自动执行，此处用于补数据或演示）。
     *
     * <pre>POST /api/admin/dashboard/snapshot</pre>
     */
    @PostMapping("/snapshot")
    public ApiResponse<Map<String, Object>> snapshot(@RequestParam(required = false) String date) {
        LocalDate d = null;
        if (date != null && !date.isBlank()) {
            try {
                d = LocalDate.parse(date.trim());
            } catch (Exception e) {
                throw com.nwu.zhiyi.common.exception.BusinessException
                        .paramInvalid("日期格式应为 yyyy-MM-dd");
            }
        }
        Long id = adminDashboardService.snapshot(d);
        return ApiResponse.success("快照已生成",
                Map.of("snapshotId", id, "statDate", (d == null ? LocalDate.now() : d).toString()));
    }

    /**
     * 系统健康摘要（数据一致性抽查）。
     *
     * <pre>GET /api/admin/dashboard/health</pre>
     */
    @GetMapping("/health")
    public ApiResponse<Map<String, Object>> health() {
        return ApiResponse.success(adminDashboardService.health());
    }
}
