package com.nwu.zhiyi.domain.entity;

import lombok.Data;

import java.time.LocalDateTime;

/** Durable notification delivery event stored in the transactional outbox. */
@Data
public class NotificationOutboxEvent {
    private Long id;
    private String sno;
    private String type;
    private String title;
    private String content;
    private String refType;
    private Long refId;
    private String idempotencyKey;
    private String status;
    private Integer attempts;
    private LocalDateTime nextAttemptAt;
    private String lastError;
}
