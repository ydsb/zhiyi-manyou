package com.nwu.zhiyi.api.dto.collab;

import com.nwu.zhiyi.domain.entity.Notification;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 通知视图对象（FR-M5-05）。
 *
 * @author 李泽宬
 */
@Data
public class NotificationVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private String type;
    private String typeLabel;
    private String title;
    private String content;
    private String refType;
    private Long refId;
    private Boolean read;
    private LocalDateTime createdAt;

    /** 点击后前端应跳转的路由（由服务端拼好，避免前端维护映射表） */
    private String linkPath;

    public static NotificationVO of(Notification n) {
        if (n == null) {
            return null;
        }
        NotificationVO vo = new NotificationVO();
        vo.setId(n.getId());
        vo.setType(n.getType());
        vo.setTypeLabel(labelOf(n.getType()));
        vo.setTitle(n.getTitle());
        vo.setContent(n.getContent());
        vo.setRefType(n.getRefType());
        vo.setRefId(n.getRefId());
        vo.setRead(n.getReadFlag() != null && n.getReadFlag() == 1);
        vo.setCreatedAt(n.getCreatedAt());
        vo.setLinkPath(linkOf(n.getRefType(), n.getRefId()));
        return vo;
    }

    private static String labelOf(String type) {
        if (type == null) {
            return "通知";
        }
        try {
            return com.nwu.zhiyi.common.enums.NotificationType.valueOf(type).getLabel();
        } catch (IllegalArgumentException e) {
            return type;
        }
    }

    /** 关联业务 → 前端路由 */
    private static String linkOf(String refType, Long refId) {
        if (refType == null) {
            return "/dashboard";
        }
        switch (refType) {
            case "EXCHANGE":
                return "/exchanges";
            case "DEMAND":
                return refId == null ? "/market" : "/market?demandId=" + refId;
            case "INTEREST":
                return "/exchanges?tab=received";
            case "EVALUATION":
                return "/exchanges?tab=pendingEval";
            case "DISPUTE":
                return "/exchanges?tab=disputed";
            default:
                return "/dashboard";
        }
    }
}
