package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.api.PageResult;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.admin.AdminContentService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 管理后台 · 内容审核模块（FR-M9-03）。
 *
 * <p>两条并行的审核路径：
 * <ol>
 *   <li>自动审核命中（发卡片时的敏感词/广告检测）→ 待审卡片队列；</li>
 *   <li>用户举报 → 举报队列。</li>
 * </ol>
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/admin/content")
@RequiredArgsConstructor
public class AdminContentController {

    private final AdminContentService adminContentService;

    /**
     * 待审需求卡片队列。
     *
     * <pre>GET /api/admin/content/demands?page=1&amp;size=20</pre>
     */
    @GetMapping("/demands")
    public ApiResponse<PageResult<Map<String, Object>>> pendingDemands(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(adminContentService.pendingDemands(page, size));
    }

    /**
     * 审核需求卡片。**驳回必须填原因** —— 否则用户无从修改，只能反复提交。
     *
     * <pre>POST /api/admin/content/demands/{id}/audit</pre>
     */
    @PostMapping("/demands/{id}/audit")
    public ApiResponse<Map<String, Object>> auditDemand(@PathVariable Long id,
                                                        @RequestBody Map<String, Object> body) {
        boolean approved = Boolean.TRUE.equals(body.get("approved"));
        String remark = body.get("remark") == null ? null : String.valueOf(body.get("remark"));
        return ApiResponse.success(approved ? "卡片已通过审核" : "卡片已驳回",
                adminContentService.auditDemand(id, approved, remark, SecurityUtils.currentSno()));
    }

    /**
     * 举报队列。
     *
     * <pre>GET /api/admin/content/reports?status=PENDING&amp;page=1&amp;size=20</pre>
     */
    @GetMapping("/reports")
    public ApiResponse<PageResult<Map<String, Object>>> reports(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(adminContentService.listReports(status, page, size));
    }

    /**
     * 处理举报。举报成立时按对象类型自动执行处置（下架/停用/转复核）。
     *
     * <pre>POST /api/admin/content/reports/{id}/handle</pre>
     */
    @PostMapping("/reports/{id}/handle")
    public ApiResponse<Map<String, Object>> handleReport(@PathVariable Long id,
                                                         @RequestBody Map<String, Object> body) {
        boolean accepted = Boolean.TRUE.equals(body.get("accepted"));
        String remark = body.get("remark") == null ? null : String.valueOf(body.get("remark"));
        return ApiResponse.success(accepted ? "举报已成立并执行处置" : "举报已判定不成立",
                adminContentService.handleReport(id, accepted, remark, SecurityUtils.currentSno()));
    }

    /**
     * 管理端待办汇总（首页用）。
     *
     * <pre>GET /api/admin/content/todo</pre>
     */
    @GetMapping("/todo")
    public ApiResponse<Map<String, Object>> todo() {
        return ApiResponse.success(adminContentService.todoSummary());
    }
}
