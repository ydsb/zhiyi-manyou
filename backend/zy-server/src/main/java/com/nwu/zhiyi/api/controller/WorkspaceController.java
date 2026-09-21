package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.collab.CollabEventVO;
import com.nwu.zhiyi.api.dto.collab.CollabFileVO;
import com.nwu.zhiyi.api.dto.collab.CollabMessageVO;
import com.nwu.zhiyi.api.dto.collab.CollabTaskVO;
import com.nwu.zhiyi.api.dto.collab.MessageSendRequest;
import com.nwu.zhiyi.api.dto.collab.ProcessSummaryVO;
import com.nwu.zhiyi.api.dto.collab.TaskConfirmRequest;
import com.nwu.zhiyi.api.dto.collab.TaskCreateRequest;
import com.nwu.zhiyi.api.dto.collab.TaskUpdateRequest;
import com.nwu.zhiyi.api.dto.collab.WorkspaceVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.domain.entity.CollabFile;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.collab.WorkspaceService;
import com.nwu.zhiyi.service.storage.FileStorage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * 协作工作台接口（模块 M5）。
 *
 * <p>所有接口都需要登录，且服务层会校验调用者是否为该交换的参与方
 * （FR-M5-01「专属协作空间，仅双方及必要时的仲裁员可见」）。
 *
 * @author 李泽宬
 */
@Slf4j
@RestController
@RequestMapping("/api/workspaces")
@RequiredArgsConstructor
public class WorkspaceController {

    private final WorkspaceService workspaceService;
    private final FileStorage fileStorage;

    /* ==================== 总览 ==================== */

    /**
     * 工作台总览：任务、文件、留言、时间轴、过程指标一次返回。
     *
     * <pre>GET /api/workspaces/{recordId}</pre>
     */
    @GetMapping("/{recordId}")
    public ApiResponse<WorkspaceVO> overview(@PathVariable Long recordId) {
        return ApiResponse.success(workspaceService.overview(recordId, SecurityUtils.currentSno()));
    }

    /* ==================== 任务（FR-M5-02） ==================== */

    /**
     * 任务清单。
     *
     * <pre>GET /api/workspaces/{recordId}/tasks</pre>
     */
    @GetMapping("/{recordId}/tasks")
    public ApiResponse<List<CollabTaskVO>> tasks(@PathVariable Long recordId) {
        return ApiResponse.success(workspaceService.listTasks(recordId, SecurityUtils.currentSno()));
    }

    /**
     * 新增任务项（阶段性任务拆解）。
     *
     * <pre>POST /api/workspaces/{recordId}/tasks</pre>
     */
    @PostMapping("/{recordId}/tasks")
    public ApiResponse<CollabTaskVO> createTask(@PathVariable Long recordId,
                                                @Valid @RequestBody TaskCreateRequest request) {
        return ApiResponse.success("任务已创建",
                workspaceService.createTask(recordId, SecurityUtils.currentSno(), request));
    }

    /**
     * 修改任务项；把 {@code status} 置为 {@code DONE} 即为"打卡完成"。
     *
     * <pre>PUT /api/workspaces/{recordId}/tasks/{taskId}</pre>
     */
    @PutMapping("/{recordId}/tasks/{taskId}")
    public ApiResponse<CollabTaskVO> updateTask(@PathVariable Long recordId,
                                                @PathVariable Long taskId,
                                                @Valid @RequestBody TaskUpdateRequest request) {
        CollabTaskVO vo = workspaceService.updateTask(recordId, taskId, SecurityUtils.currentSno(), request);
        String message = "DONE".equals(vo.getStatus()) ? "已打卡完成" : "任务已更新";
        return ApiResponse.success(message, vo);
    }

    /**
     * 确认阶段性成果（FR-M5-08）。
     *
     * <p>需求：「阶段性成果支持互相同步确认，避免单方面宣称完成」。
     * 打卡（`status=DONE`）只表示"某人宣称完成"，本接口才是"对方认可"。
     * 打卡者不能确认自己。
     *
     * <pre>POST /api/workspaces/{recordId}/tasks/{taskId}/confirm</pre>
     */
    @PostMapping("/{recordId}/tasks/{taskId}/confirm")
    public ApiResponse<CollabTaskVO> confirmTask(@PathVariable Long recordId,
                                                 @PathVariable Long taskId,
                                                 @RequestBody(required = false) TaskConfirmRequest request) {
        CollabTaskVO vo = workspaceService.confirmTask(
                recordId, taskId, SecurityUtils.currentSno(), request);
        return ApiResponse.success("已确认该阶段成果，双方达成一致", vo);
    }

    /**
     * 删除任务项（已完成的任务不可删除，它是过程性评价依据）。
     *
     * <pre>DELETE /api/workspaces/{recordId}/tasks/{taskId}</pre>
     */
    @DeleteMapping("/{recordId}/tasks/{taskId}")
    public ApiResponse<Void> deleteTask(@PathVariable Long recordId, @PathVariable Long taskId) {
        workspaceService.deleteTask(recordId, taskId, SecurityUtils.currentSno());
        return ApiResponse.success("任务已删除", null);
    }

    /* ==================== 文件（FR-M5-03） ==================== */

    /**
     * 文件列表。
     *
     * <p>不传 {@code groupKey} 返回各逻辑文件的最新版本；
     * 传入则返回该文件的全部历史版本（版本回溯）。
     *
     * <pre>GET /api/workspaces/{recordId}/files?groupKey=xxx</pre>
     */
    @GetMapping("/{recordId}/files")
    public ApiResponse<List<CollabFileVO>> files(@PathVariable Long recordId,
                                                 @RequestParam(required = false) String groupKey) {
        return ApiResponse.success(workspaceService.listFiles(recordId, SecurityUtils.currentSno(), groupKey));
    }

    /**
     * 上传文件。
     *
     * <p>同一 {@code groupKey} 重复上传自动生成新版本并保留历史版本。
     *
     * <pre>POST /api/workspaces/{recordId}/files （multipart/form-data）</pre>
     */
    @PostMapping("/{recordId}/files")
    public ApiResponse<CollabFileVO> upload(@PathVariable Long recordId,
                                            @RequestParam("file") MultipartFile file,
                                            @RequestParam(required = false) String groupKey,
                                            @RequestParam(required = false) Long taskId,
                                            @RequestParam(required = false) String remark) {
        CollabFileVO vo = workspaceService.upload(recordId, SecurityUtils.currentSno(),
                file, groupKey, taskId, remark);
        String message = vo.getVersion() > 1
                ? "已上传第 " + vo.getVersion() + " 版" : "文件已上传";
        return ApiResponse.success(message, vo);
    }

    /**
     * 下载文件（带参与方权限校验，不直连存储）。
     *
     * <pre>GET /api/workspaces/files/{fileId}/download</pre>
     */
    @GetMapping("/files/{fileId}/download")
    public ResponseEntity<InputStreamResource> download(@PathVariable Long fileId) {
        CollabFile file = workspaceService.requireDownloadable(fileId, SecurityUtils.currentSno());
        InputStream in = fileStorage.retrieve(file.getStoragePath());

        String encoded = URLEncoder.encode(file.getFileName(), StandardCharsets.UTF_8)
                .replace("+", "%20");
        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.CONTENT_DISPOSITION,
                "attachment; filename=\"" + encoded + "\"; filename*=UTF-8''" + encoded);
        headers.setContentType(file.getContentType() == null
                ? MediaType.APPLICATION_OCTET_STREAM : MediaType.parseMediaType(file.getContentType()));
        headers.setContentLength(file.getSizeBytes() == null ? 0 : file.getSizeBytes());
        // 便于前端显示版本号
        headers.set("X-File-Version", String.valueOf(file.getVersion()));

        log.info("[协作文件] 下载 fileId={} name={} v{} by={}",
                fileId, file.getFileName(), file.getVersion(), SecurityUtils.currentSno());
        return ResponseEntity.ok().headers(headers).body(new InputStreamResource(in));
    }

    /* ==================== 留言（FR-M5-07） ==================== */

    /**
     * 留言列表（时间正序）。
     *
     * <pre>GET /api/workspaces/{recordId}/messages?limit=50</pre>
     */
    @GetMapping("/{recordId}/messages")
    public ApiResponse<List<CollabMessageVO>> messages(@PathVariable Long recordId,
                                                       @RequestParam(defaultValue = "50") int limit) {
        return ApiResponse.success(workspaceService.listMessages(recordId, SecurityUtils.currentSno(), limit));
    }

    /**
     * 发送留言（文字与附件至少填一个）。
     *
     * <pre>POST /api/workspaces/{recordId}/messages</pre>
     */
    @PostMapping("/{recordId}/messages")
    public ApiResponse<CollabMessageVO> sendMessage(@PathVariable Long recordId,
                                                    @Valid @RequestBody MessageSendRequest request) {
        return ApiResponse.success("已发送",
                workspaceService.sendMessage(recordId, SecurityUtils.currentSno(), request));
    }

    /* ==================== 时间轴（FR-M5-04） ==================== */

    /**
     * 协作时间轴（最新在前）。
     *
     * <pre>GET /api/workspaces/{recordId}/timeline?limit=100</pre>
     */
    @GetMapping("/{recordId}/timeline")
    public ApiResponse<List<CollabEventVO>> timeline(@PathVariable Long recordId,
                                                     @RequestParam(defaultValue = "100") int limit) {
        return ApiResponse.success(workspaceService.timeline(recordId, SecurityUtils.currentSno(), limit));
    }

    /* ==================== 过程性指标（FR-M5-06） ==================== */

    /**
     * 协作过程性指标（客观行为语料，供互评与能力画像引用）。
     *
     * <pre>GET /api/workspaces/{recordId}/process-summary</pre>
     */
    @GetMapping("/{recordId}/process-summary")
    public ApiResponse<ProcessSummaryVO> processSummary(@PathVariable Long recordId) {
        return ApiResponse.success(workspaceService.processSummary(recordId, SecurityUtils.currentSno()));
    }
}
