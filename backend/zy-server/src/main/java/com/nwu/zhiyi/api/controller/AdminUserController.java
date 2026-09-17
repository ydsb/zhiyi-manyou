package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.api.PageResult;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.admin.AdminContentService;
import com.nwu.zhiyi.service.admin.AdminDashboardService;
import com.nwu.zhiyi.service.admin.AdminUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理后台 · 用户模块（FR-M9-01）。
 *
 * <p>路径统一在 {@code /api/admin/**} 下，由 {@code SecurityConfig} 强制 ADMIN 角色。
 *
 * <p><b>所有写操作都必须带 {@code remark}</b>：管理权限越大，留痕要求越高。
 * 缺少说明会被服务层拒绝（错误码 3093）。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final AdminUserService adminUserService;

    /**
     * 分页查询用户。
     *
     * <pre>GET /api/admin/users?keyword=&amp;college=&amp;status=&amp;role=&amp;page=1&amp;size=20</pre>
     */
    @GetMapping
    public ApiResponse<PageResult<Map<String, Object>>> list(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String college,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String role,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(adminUserService.listUsers(keyword, college, status, role, page, size));
    }

    /**
     * 用户详情（含信用因子明细）。
     *
     * <pre>GET /api/admin/users/{sno}</pre>
     */
    @GetMapping("/{sno}")
    public ApiResponse<Map<String, Object>> detail(@PathVariable String sno) {
        return ApiResponse.success(adminUserService.userDetail(sno));
    }

    /**
     * 启用/禁用账号。禁用会同时把并发上限置 0。
     *
     * <pre>POST /api/admin/users/{sno}/status</pre>
     */
    @PostMapping("/{sno}/status")
    public ApiResponse<Map<String, Object>> setStatus(@PathVariable String sno,
                                                      @RequestBody Map<String, Object> body) {
        boolean enabled = Boolean.TRUE.equals(body.get("enabled"));
        String remark = asString(body.get("remark"));
        return ApiResponse.success(enabled ? "账号已启用" : "账号已禁用",
                adminUserService.setStatus(sno, enabled, SecurityUtils.currentSno(), remark));
    }

    /**
     * 分配角色。
     *
     * <pre>POST /api/admin/users/{sno}/role</pre>
     */
    @PostMapping("/{sno}/role")
    public ApiResponse<Map<String, Object>> assignRole(@PathVariable String sno,
                                                       @RequestBody Map<String, Object> body) {
        return ApiResponse.success("角色已更新",
                adminUserService.assignRole(sno, asString(body.get("role")),
                        SecurityUtils.currentSno(), asString(body.get("remark"))));
    }

    /**
     * 维护实名核验状态。
     *
     * <pre>POST /api/admin/users/{sno}/auth-status</pre>
     */
    @PostMapping("/{sno}/auth-status")
    public ApiResponse<Map<String, Object>> setAuthStatus(@PathVariable String sno,
                                                          @RequestBody Map<String, Object> body) {
        return ApiResponse.success("核验状态已更新",
                adminUserService.setAuthStatus(sno, asString(body.get("authStatus")),
                        SecurityUtils.currentSno(), asString(body.get("remark"))));
    }

    /**
     * 手动重算某用户信用值（排查"信用值看起来不对"的反馈）。
     *
     * <pre>POST /api/admin/users/{sno}/recalculate-credit</pre>
     */
    @PostMapping("/{sno}/recalculate-credit")
    public ApiResponse<Map<String, Object>> recalculateCredit(@PathVariable String sno,
                                                              @RequestBody Map<String, Object> body) {
        return ApiResponse.success("信用值已重算",
                adminUserService.recalculateCredit(sno, SecurityUtils.currentSno(),
                        asString(body.get("remark"))));
    }

    /**
     * 学院分布（看板用）。
     *
     * <pre>GET /api/admin/users/statistics/college</pre>
     */
    @GetMapping("/statistics/college")
    public ApiResponse<List<Map<String, Object>>> collegeDistribution() {
        return ApiResponse.success(adminUserService.collegeDistribution());
    }

    private static String asString(Object v) {
        return v == null ? null : String.valueOf(v);
    }
}
