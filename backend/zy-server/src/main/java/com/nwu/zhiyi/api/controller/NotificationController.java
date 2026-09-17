package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.collab.NotificationVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 通知中心接口（FR-M5-05）。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    /**
     * 我的通知列表。
     *
     * <pre>GET /api/notifications?onlyUnread=false&amp;limit=50</pre>
     */
    @GetMapping
    public ApiResponse<List<NotificationVO>> list(
            @RequestParam(defaultValue = "false") boolean onlyUnread,
            @RequestParam(defaultValue = "50") int limit) {
        return ApiResponse.success(notificationService.list(SecurityUtils.currentSno(), onlyUnread, limit));
    }

    /**
     * 未读数量（顶栏红点轮询用）。
     *
     * <pre>GET /api/notifications/unread-count</pre>
     */
    @GetMapping("/unread-count")
    public ApiResponse<Map<String, Object>> unreadCount() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("count", notificationService.unreadCount(SecurityUtils.currentSno()));
        return ApiResponse.success(data);
    }

    /**
     * 标记单条已读。
     *
     * <pre>POST /api/notifications/{id}/read</pre>
     */
    @PostMapping("/{id}/read")
    public ApiResponse<Void> markRead(@PathVariable Long id) {
        notificationService.markRead(SecurityUtils.currentSno(), id);
        return ApiResponse.success("已标记为已读", null);
    }

    /**
     * 全部标记已读。
     *
     * <pre>POST /api/notifications/read-all</pre>
     */
    @PostMapping("/read-all")
    public ApiResponse<Map<String, Object>> markAllRead() {
        int affected = notificationService.markAllRead(SecurityUtils.currentSno());
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("affected", affected);
        return ApiResponse.success("已全部标记为已读", data);
    }
}
