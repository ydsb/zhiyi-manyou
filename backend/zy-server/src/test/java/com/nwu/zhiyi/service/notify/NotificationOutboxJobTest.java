package com.nwu.zhiyi.service.notify;

import com.nwu.zhiyi.domain.entity.NotificationOutboxEvent;
import com.nwu.zhiyi.domain.mapper.NotificationMapper;
import com.nwu.zhiyi.domain.mapper.NotificationOutboxMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class NotificationOutboxJobTest {
    private NotificationOutboxMapper outbox;
    private NotificationMapper notifications;
    private NotificationOutboxJob job;

    @BeforeEach
    void setUp() {
        outbox = mock(NotificationOutboxMapper.class);
        notifications = mock(NotificationMapper.class);
        job = new NotificationOutboxJob(outbox, notifications);
        ReflectionTestUtils.setField(job, "deliveryMode", "outbox");
        ReflectionTestUtils.setField(job, "maxAttempts", 4);
    }

    @Test
    void persistsNotificationBeforeMarkingEventSent() {
        NotificationOutboxEvent event = event(7L);
        when(outbox.lockNextBatch(100)).thenReturn(List.of(event));
        when(outbox.markProcessing(7L)).thenReturn(1);

        job.deliverBatch();

        verify(notifications).insertOutboxDelivery("sno-1", "SYSTEM", "title", "body", "REF", 9L, 7L);
        verify(outbox).markSent(7L);
        verify(outbox, never()).markFailed(eq(7L), anyString(), anyInt());
    }

    @Test
    void recordsFailureForRetryAndDoesNotMarkEventSent() {
        NotificationOutboxEvent event = event(8L);
        when(outbox.lockNextBatch(100)).thenReturn(List.of(event));
        when(outbox.markProcessing(8L)).thenReturn(1);
        org.mockito.Mockito.doThrow(new IllegalStateException("database unavailable"))
                .when(notifications).insertOutboxDelivery("sno-1", "SYSTEM", "title", "body", "REF", 9L, 8L);

        job.deliverBatch();

        verify(outbox).markFailed(8L, "database unavailable", 4);
        verify(outbox, never()).markSent(8L);
    }

    @Test
    void doesNotPollWhenDeliveryModeIsSynchronous() {
        ReflectionTestUtils.setField(job, "deliveryMode", "sync");

        job.deliverBatch();

        verify(outbox, never()).lockNextBatch(anyInt());
    }

    private NotificationOutboxEvent event(long id) {
        NotificationOutboxEvent event = new NotificationOutboxEvent();
        event.setId(id);
        event.setSno("sno-1");
        event.setType("SYSTEM");
        event.setTitle("title");
        event.setContent("body");
        event.setRefType("REF");
        event.setRefId(9L);
        event.setAttempts(0);
        return event;
    }
}
