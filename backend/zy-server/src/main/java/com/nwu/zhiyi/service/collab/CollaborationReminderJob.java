package com.nwu.zhiyi.service.collab;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.enums.TaskStatus;
import com.nwu.zhiyi.domain.entity.CollabEvent;
import com.nwu.zhiyi.domain.entity.CollabTask;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.mapper.CollabEventMapper;
import com.nwu.zhiyi.domain.mapper.CollabTaskMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 协作出勤提醒任务（FR-M5-05「打卡提醒」）。
 *
 * <p><b>做两件事</b>：
 * <ol>
 *   <li><b>临近截止提醒</b>：任务将在 24 小时内到期且未完成 → 提醒该任务的负责人；</li>
 *   <li><b>逾期标记</b>：任务已过期且未完成 → 写一条 {@code TASK_OVERDUE} 协作事件
 *       （只写一次，用于时间轴与 M6 的按期率举证）并提醒双方。</li>
 * </ol>
 *
 * <p><b>为什么用定时任务而不是实时判断</b>：逾期是"时间流逝"产生的事实，
 * 没有用户动作触发，只能在时间维度上扫描。协作任务量级很小
 * （单个交换通常 3~10 项），每 30 分钟扫一次的成本可以忽略。
 *
 * <p>本类只依赖 Mapper 与通知服务，不依赖 WorkspaceService，避免与其形成循环依赖。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CollaborationReminderJob {

    private final CollabTaskMapper taskMapper;
    private final CollabEventMapper eventMapper;
    private final ExchangeRecordMapper exchangeMapper;
    private final NotificationService notificationService;

    /** 提前提醒的时间窗（小时） */
    private static final long DUE_SOON_HOURS = 24;

    /**
     * 每 30 分钟执行一次。
     *
     * <p>初始延迟 2 分钟，错开应用启动时的初始化负载。
     */
    @Scheduled(initialDelay = 120_000, fixedDelay = 1_800_000)
    public void scanTasks() {
        // 只扫描仍处于协作中的交换，终态交换无需提醒
        List<CollabTask> pending = taskMapper.selectList(new LambdaQueryWrapper<CollabTask>()
                .ne(CollabTask::getStatus, TaskStatus.DONE)
                .isNotNull(CollabTask::getDeadline));

        if (pending.isEmpty()) {
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        int dueSoon = 0;
        int overdue = 0;

        for (CollabTask task : pending) {
            ExchangeRecord record = exchangeMapper.selectById(task.getRecordId());
            if (record == null || record.getStatus() == null || record.getStatus().isFinal()) {
                continue;
            }

            long minutesLeft = Duration.between(now, task.getDeadline()).toMinutes();

            if (minutesLeft < 0) {
                /*
                 * 逾期：只在第一次逾期时写事件与提醒，避免每轮重复骚扰。
                 * 判据是"该任务是否已有 TASK_OVERDUE 事件"，用 ref_id 精确匹配
                 * （detail 里也留了 taskId 便于人工排查）。
                 */
                String marker = "taskId=" + task.getId();
                boolean markedForThisTask = eventMapper.selectList(new LambdaQueryWrapper<CollabEvent>()
                                .eq(CollabEvent::getRecordId, task.getRecordId())
                                .eq(CollabEvent::getEventType, CollabEvent.TYPE_TASK_OVERDUE)
                                .like(CollabEvent::getDetail, marker)).size() > 0;
                if (!markedForThisTask) {
                    long overdueHours = Math.abs(minutesLeft) / 60;
                    eventMapper.insert(new CollabEvent()
                            .setRecordId(task.getRecordId())
                            .setActorSno(null)
                            .setEventType(CollabEvent.TYPE_TASK_OVERDUE)
                            .setTitle("任务「" + task.getTitle() + "」已逾期")
                            .setDetail("已超期 " + overdueHours + " 小时未完成（" + marker + "）")
                            .setRefType("TASK")
                            .setRefId(task.getId()));
                    overdue++;
                    if (task.getAssigneeSno() != null) {
                        notificationService.sendOnce(task.getAssigneeSno(), NotificationType.TASK_REMIND,
                                "任务已逾期", "「" + task.getTitle() + "」已超过约定时间，请尽快处理",
                                "EXCHANGE", task.getRecordId());
                    } else {
                        notificationService.sendToExchangeParties(task.getRecordId(), null,
                                NotificationType.TASK_REMIND, "协作任务已逾期",
                                "「" + task.getTitle() + "」已超过约定时间");
                    }
                    log.info("[出勤提醒] 标记逾期 record={} task={} 超期 {} 小时",
                            task.getRecordId(), task.getId(), overdueHours);
                }
            } else if (minutesLeft <= DUE_SOON_HOURS * 60) {
                // 临近截止：同类型通知按业务对象幂等，一天内不会重复轰炸
                long hoursLeft = Math.max(1, minutesLeft / 60);
                if (task.getAssigneeSno() != null) {
                    boolean sent = notificationService.sendOnce(task.getAssigneeSno(),
                            NotificationType.TASK_REMIND, "任务即将到期",
                            "「" + task.getTitle() + "」还有约 " + hoursLeft + " 小时到期",
                            "TASK", task.getId());
                    if (sent) {
                        dueSoon++;
                    }
                } else {
                    notificationService.sendToExchangeParties(task.getRecordId(), null,
                            NotificationType.TASK_REMIND, "协作任务即将到期",
                            "「" + task.getTitle() + "」还有约 " + hoursLeft + " 小时到期");
                    dueSoon++;
                }
            }
        }

        if (dueSoon > 0 || overdue > 0) {
            log.info("[出勤提醒] 本轮完成：临近截止 {} 条，逾期标记 {} 条", dueSoon, overdue);
        }
    }
}
