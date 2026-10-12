package com.nwu.zhiyi.service.notify;

import com.nwu.zhiyi.domain.entity.NotificationOutboxEvent;
import com.nwu.zhiyi.domain.mapper.NotificationMapper;
import com.nwu.zhiyi.domain.mapper.NotificationOutboxMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** Polls durable outbox rows, delivers idempotently and retries transient failures with backoff. */
@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationOutboxJob {
    private final NotificationOutboxMapper outboxMapper;
    private final NotificationMapper notificationMapper;

    @Value("${zhiyi.notification.delivery:sync}")
    private String deliveryMode;

    @Value("${zhiyi.notification.outbox.max-attempts:8}")
    private int maxAttempts;

    @Scheduled(fixedDelayString = "${zhiyi.notification.outbox.poll-ms:1000}", initialDelay = 5000)
    @Transactional(rollbackFor = Exception.class)
    public void deliverBatch() {
        if (!"outbox".equalsIgnoreCase(deliveryMode)) return;
        outboxMapper.recoverAbandoned();
        List<NotificationOutboxEvent> events = outboxMapper.lockNextBatch(100);
        for (NotificationOutboxEvent event : events) {
            if (outboxMapper.markProcessing(event.getId()) == 0) continue;
            try {
                notificationMapper.insertOutboxDelivery(event.getSno(), event.getType(), event.getTitle(),
                        event.getContent(), event.getRefType(), event.getRefId(), event.getId());
                outboxMapper.markSent(event.getId());
            } catch (Exception e) {
                String message = e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage();
                if (message.length() > 480) message = message.substring(0, 480);
                outboxMapper.markFailed(event.getId(), message, Math.max(1, maxAttempts));
                log.warn("[通知Outbox] 投递失败，稍后重试 id={} attempt={} - {}",
                        event.getId(), event.getAttempts() + 1, message);
            }
        }
    }
}
