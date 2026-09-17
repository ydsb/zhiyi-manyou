package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.admin.AdminSkillImportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * 管理后台 · 技能标签批量导入（FR-M9-02）。
 *
 * <p>支持「导出 → 修改 → 再导入」的运维循环：导出为同样的行格式，
 * 管理员在表格软件里改完直接贴回来即可。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/admin/skills")
@RequiredArgsConstructor
public class AdminSkillImportController {

    private final AdminSkillImportService importService;

    /**
     * 批量导入技能标签。
     *
     * <p>逐行校验，跳过错误行并返回明细 —— 而不是整批回滚。
     * 一次导入 500 行若有 3 行格式错就全部失败，管理员只能反复试错。
     *
     * <pre>POST /api/admin/skills/import</pre>
     */
    @PostMapping("/import")
    public ApiResponse<Map<String, Object>> importSkills(@RequestBody Map<String, Object> body) {
        String content = body.get("content") == null ? null : String.valueOf(body.get("content"));
        String source = body.get("source") == null ? "ADMIN_UI" : String.valueOf(body.get("source"));
        Map<String, Object> result = importService.importSkills(content, SecurityUtils.currentSno(), source);
        String message = String.format("导入完成：新增 %s 条、更新 %s 条、失败 %s 条",
                result.get("created"), result.get("updated"), result.get("failed"));
        return ApiResponse.success(message, result);
    }

    /**
     * 导入批次历史。
     *
     * <pre>GET /api/admin/skills/import/batches?limit=10</pre>
     */
    @GetMapping("/import/batches")
    public ApiResponse<List<Map<String, Object>>> batches(@RequestParam(defaultValue = "10") int limit) {
        return ApiResponse.success(importService.batchHistory(limit));
    }

    /**
     * 导出全部标签（返回纯文本，可直接另存为 .txt/.csv）。
     *
     * <pre>GET /api/admin/skills/export</pre>
     */
    @GetMapping("/export")
    public ResponseEntity<byte[]> export() {
        String content = importService.exportSkills();
        byte[] bytes = content.getBytes(StandardCharsets.UTF_8);
        String filename = URLEncoder.encode("zhiyi-skills-export.txt", StandardCharsets.UTF_8);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(new MediaType("text", "plain", StandardCharsets.UTF_8));
        headers.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"");
        headers.setContentLength(bytes.length);
        return ResponseEntity.ok().headers(headers).body(bytes);
    }
}
