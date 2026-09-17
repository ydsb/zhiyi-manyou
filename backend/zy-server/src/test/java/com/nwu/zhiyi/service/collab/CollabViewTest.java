package com.nwu.zhiyi.service.collab;

import com.nwu.zhiyi.api.dto.collab.CollabEventVO;
import com.nwu.zhiyi.api.dto.collab.CollabFileVO;
import com.nwu.zhiyi.api.dto.collab.CollabTaskVO;
import com.nwu.zhiyi.domain.entity.CollabEvent;
import com.nwu.zhiyi.domain.entity.CollabFile;
import com.nwu.zhiyi.domain.entity.CollabTask;
import com.nwu.zhiyi.common.enums.TaskStatus;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * M5 协作工作台的视图转换与状态判定测试。
 *
 * <p>这些逻辑虽然简单，但直接决定时间轴可读性与"逾期"这类<b>会进入评价语料</b>
 * 的判定结果，因此单独锁定行为。
 *
 * @author 李泽宬
 */
@DisplayName("M5 - 协作视图转换与状态判定")
class CollabViewTest {

    /* ==================== 任务 ==================== */

    @Test
    @DisplayName("未完成且已过截止时间的任务应判为逾期")
    void shouldDetectOverdueTask() {
        CollabTask overdue = new CollabTask().setStatus(TaskStatus.TODO)
                .setDeadline(LocalDateTime.now().minusHours(2));
        assertTrue(overdue.isOverdue(), "超过截止时间且未完成应判逾期");

        CollabTask future = new CollabTask().setStatus(TaskStatus.TODO)
                .setDeadline(LocalDateTime.now().plusHours(2));
        assertFalse(future.isOverdue());
    }

    @Test
    @DisplayName("已完成的任务即使超过截止时间也不算逾期（逾期看的是未完成）")
    void shouldNotMarkDoneTaskOverdue() {
        CollabTask done = new CollabTask().setStatus(TaskStatus.DONE)
                .setDeadline(LocalDateTime.now().minusDays(1))
                .setDoneAt(LocalDateTime.now().minusDays(2));
        assertFalse(done.isOverdue(), "已完成的任务不应计入逾期");
    }

    @Test
    @DisplayName("无截止时间的任务不算逾期")
    void shouldNotMarkTaskWithoutDeadlineOverdue() {
        CollabTask noDeadline = new CollabTask().setStatus(TaskStatus.TODO);
        assertFalse(noDeadline.isOverdue());
    }

    @Test
    @DisplayName("打卡（markDone）应同时写入完成时间")
    void shouldSetDoneAtOnMarkDone() {
        CollabTask task = new CollabTask().setStatus(TaskStatus.TODO);
        task.markDone();
        assertEquals(TaskStatus.DONE, task.getStatus());
        assertTrue(task.getDoneAt() != null, "打卡必须记录完成时间，否则无法计算按期率");
    }

    @Test
    @DisplayName("任务视图应带状态标签与逾期标记，并标识是否由我负责")
    void shouldBuildTaskView() {
        CollabTask task = new CollabTask()
                .setId(1L).setRecordId(9L).setTitle("完成交互稿")
                .setAssigneeSno("2024117420")
                .setStatus(TaskStatus.DOING)
                .setDeadline(LocalDateTime.now().minusHours(1))
                .setCreatedBy("2024117421");

        CollabTaskVO vo = CollabTaskVO.of(task);
        assertEquals("DOING", vo.getStatus());
        assertEquals("进行中", vo.getStatusLabel());
        assertTrue(vo.getOverdue(), "进行中且已超期应标记逾期");
        assertEquals("2024117420", vo.getAssigneeSno());
    }

    /* ==================== 文件版本 ==================== */

    @Test
    @DisplayName("文件大小应转为人类可读文本")
    void shouldFormatHumanSize() {
        assertEquals("0 B", CollabFileVO.humanSize(null));
        assertEquals("0 B", CollabFileVO.humanSize(0L));
        assertEquals("512 B", CollabFileVO.humanSize(512L));
        assertEquals("1.0 KB", CollabFileVO.humanSize(1024L));
        assertEquals("1.5 KB", CollabFileVO.humanSize(1536L));
        assertEquals("2.0 MB", CollabFileVO.humanSize(2L * 1024 * 1024));
        assertEquals("1.50 GB", CollabFileVO.humanSize(1610612736L));
    }

    @Test
    @DisplayName("文件视图应携带版本信息与受控下载地址，且不暴露存储路径")
    void shouldBuildFileViewWithoutStoragePath() {
        CollabFile file = new CollabFile()
                .setId(7L).setRecordId(9L)
                .setGroupKey("f_abc").setVersion(2).setIsLatest(1)
                .setFileName("设计稿.pdf").setContentType("application/pdf")
                .setSizeBytes(2048L)
                .setStorageType("LOCAL").setStoragePath("2026/09/17/xyz.pdf")
                .setUploaderSno("2024117420");

        CollabFileVO vo = CollabFileVO.of(file);
        assertEquals(2, vo.getVersion());
        assertTrue(vo.getLatest());
        assertEquals("2.0 KB", vo.getSizeText());
        assertEquals("/api/workspaces/files/7/download", vo.getDownloadUrl());
        assertTrue(vo.getLatest(), "isLatest=1 应判为最新版本");
    }

    @Test
    @DisplayName("版本标记：isLatest=0 应判为历史版本")
    void shouldDetectHistoryVersion() {
        CollabFile old = new CollabFile().setIsLatest(0);
        assertTrue(old.isHistoryVersion());
        assertFalse(old.isLatestVersion());
    }

    /* ==================== 时间轴 ==================== */

    @Test
    @DisplayName("时间轴事件应带展示图标，且每种事件类型都有映射")
    void shouldMapEventIcons() {
        String[] types = {
                CollabEvent.TYPE_EXCHANGE_START, CollabEvent.TYPE_TASK_CREATE,
                CollabEvent.TYPE_TASK_CLAIM, CollabEvent.TYPE_TASK_DONE,
                CollabEvent.TYPE_TASK_OVERDUE, CollabEvent.TYPE_FILE_UPLOAD,
                CollabEvent.TYPE_MESSAGE, CollabEvent.TYPE_STATUS_CHANGE,
                CollabEvent.TYPE_CONFIRM
        };
        for (String type : types) {
            String icon = CollabEventVO.iconOf(type);
            assertTrue(icon != null && !icon.isEmpty() && !"•".equals(icon),
                    "事件类型 " + type + " 应有专属图标，实际：" + icon);
        }
        assertEquals("•", CollabEventVO.iconOf(null), "未知类型应有兜底图标");
        assertEquals("•", CollabEventVO.iconOf("SOMETHING_NEW"));
    }

    @Test
    @DisplayName("时间轴事件视图应保留已渲染好的标题（前端不做二次拼装）")
    void shouldKeepRenderedTitle() {
        CollabEvent event = new CollabEvent()
                .setId(3L).setRecordId(9L)
                .setActorSno("2024117420")
                .setEventType(CollabEvent.TYPE_TASK_DONE)
                .setTitle("完成任务「完成交互稿」")
                .setDetail("按期完成；已提交证据")
                .setOccurredAt(LocalDateTime.now());

        CollabEventVO vo = CollabEventVO.of(event);
        assertEquals("完成任务「完成交互稿」", vo.getTitle());
        assertEquals("按期完成；已提交证据", vo.getDetail());
        assertEquals("✅", vo.getIcon());
        assertEquals(CollabEvent.TYPE_TASK_DONE, vo.getEventType());
    }

    @Test
    @DisplayName("空实体转换应安全返回 null")
    void shouldHandleNullEntities() {
        assertNull(CollabTaskVO.of(null));
        assertNull(CollabFileVO.of(null));
        assertNull(CollabEventVO.of(null));
        assertNull(com.nwu.zhiyi.api.dto.collab.CollabMessageVO.of(null));
        assertNull(com.nwu.zhiyi.api.dto.collab.NotificationVO.of(null));
    }
}
