package com.nwu.zhiyi.service.collab;

import com.nwu.zhiyi.common.enums.TaskStatus;
import com.nwu.zhiyi.domain.entity.CollabTask;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.DisplayNameGeneration;
import org.junit.jupiter.api.DisplayNameGenerator;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 阶段性成果双向确认的规则测试（FR-M5-08）。
 *
 * <p>需求原文：「阶段性成果支持互相同步确认，避免单方面宣称完成」。
 * 因此本功能的核心不是"能不能点确认"，而是<b>谁有权确认</b> ——
 * 规则写错会让"防止单方面宣称"变成一句空话。
 *
 * <p>这里把四条规则用测试固定下来：
 * <ol>
 *   <li>打卡者不能确认自己（否则机制失效）；</li>
 *   <li>负责人可以确认；</li>
 *   <li>创建人可以确认（任务可能没有负责人，此时创建人即对方）；</li>
 *   <li>与任务无关的人不能确认。</li>
 * </ol>
 *
 * <p>另外锁定"撤回重做必须清空确认"：成果已变，旧的认可对新成果不成立。
 *
 * @author 李泽宬
 */
@DisplayName("M5 - 阶段性成果双向确认规则（FR-M5-08）")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
class TaskConfirmationTest {

    private static final String ALICE = "2024117420";
    private static final String BOB = "2024117421";
    private static final String STRANGER = "2024117422";

    /** 一个典型的"负责人完成、创建人是对方"的任务 */
    private CollabTask taskAssignedToAliceCreatedByBob() {
        return new CollabTask()
                .setId(1L)
                .setRecordId(9L)
                .setTitle("整理数据集")
                .setAssigneeSno(ALICE)
                .setCreatedBy(BOB)
                .setStatus(TaskStatus.DONE)
                .setDoneBy(ALICE);
    }

    @Test
    @DisplayName("打卡者不能确认自己：否则「防止单方面宣称完成」形同虚设")
    void doneByCannotConfirmSelf() {
        CollabTask task = taskAssignedToAliceCreatedByBob();
        assertFalse(task.canBeConfirmedBy(ALICE, ALICE, BOB),
                "ALICE 是打卡者，即使她也是负责人，也不能确认自己提交的成果");
    }

    @Test
    @DisplayName("协作方（交换另一方）可以确认")
    void counterpartyCanConfirm() {
        CollabTask task = taskAssignedToAliceCreatedByBob();
        assertTrue(task.canBeConfirmedBy(BOB, ALICE, BOB), "BOB 是交换另一方且不是打卡者，应可确认");
    }

    @Test
    @DisplayName("共同负责（无 assignee）且由创建人打卡时，交换另一方仍可确认")
    void counterpartyCanConfirmWhenNoAssignee() {
        /*
         * 这是最初实现的真实缺陷：判据用的是"负责人或创建人"，
         * 而共同负责的任务 assignee 为空、打卡者就是创建人，
         * 于是没有任何人剩下可以确认它 —— FR-M5-08 在该场景下直接失效。
         *
         * 需求原文说的是「互相」同步确认，语义上就是"协作方确认"，
         * 因此判据收敛为"是交换参与方，且不是打卡者"。
         */
        CollabTask task = new CollabTask()
                .setId(2L).setRecordId(9L).setTitle("共同调研")
                .setAssigneeSno(null)
                .setCreatedBy(BOB)
                .setStatus(TaskStatus.DONE)
                .setDoneBy(BOB);

        assertFalse(task.canBeConfirmedBy(BOB, ALICE, BOB), "打卡者不能确认自己");
        assertTrue(task.canBeConfirmedBy(ALICE, ALICE, BOB),
                "ALICE 是交换另一方，应能确认 —— 否则共同负责的任务永远无法被确认");
    }

    @Test
    @DisplayName("非本次交换参与方不能确认")
    void strangerCannotConfirm() {
        CollabTask task = taskAssignedToAliceCreatedByBob();
        assertFalse(task.canBeConfirmedBy(STRANGER, ALICE, BOB),
                "STRANGER 未参与本次交换，即使不是打卡者也不能确认");
    }

    @Test
    @DisplayName("空学号或空白不能确认（防止未登录/脏数据绕过）")
    void nullOrBlankCannotConfirm() {
        CollabTask task = taskAssignedToAliceCreatedByBob();
        assertFalse(task.canBeConfirmedBy(null, ALICE, BOB));
        assertFalse(task.canBeConfirmedBy("", ALICE, BOB));
        assertFalse(task.canBeConfirmedBy("   ", ALICE, BOB));
    }

    @Test
    @DisplayName("确认后记录确认人、时间与说明")
    void markConfirmedRecordsAuditFields() {
        CollabTask task = taskAssignedToAliceCreatedByBob();
        assertFalse(CollabTask.isConfirmed(task), "初始状态应为未确认");

        task.markConfirmed(BOB, "数据完整，口径与我理解一致");

        assertTrue(CollabTask.isConfirmed(task));
        assertEquals(BOB, task.getConfirmedBy());
        assertEquals("数据完整，口径与我理解一致", task.getConfirmRemark());
        assertNotNull(task.getConfirmedAt(), "必须记录确认时间（审计需要）");
    }

    @Test
    @DisplayName("确认说明可以为空（确认是正向操作，强制填说明只会让人随手写 ok）")
    void remarkMayBeNull() {
        CollabTask task = taskAssignedToAliceCreatedByBob();
        task.markConfirmed(BOB, null);
        assertTrue(CollabTask.isConfirmed(task));
        assertNull(task.getConfirmRemark());
    }

    @Test
    @DisplayName("撤回重做必须清空确认：成果已变，旧认可对新成果不成立")
    void clearConfirmationWipesAllFields() {
        CollabTask task = taskAssignedToAliceCreatedByBob();
        task.markConfirmed(BOB, "通过");
        assertTrue(CollabTask.isConfirmed(task));

        task.clearConfirmation();

        assertFalse(CollabTask.isConfirmed(task), "撤回重做后不应保留确认状态");
        assertNull(task.getConfirmedBy(), "确认人应被清空，否则会显示一个不再成立的认可");
        assertNull(task.getConfirmedAt());
        assertNull(task.getConfirmRemark());
    }

    @Test
    @DisplayName("确认与状态是两个独立事实：DONE 不等于已确认")
    void doneDoesNotImplyConfirmed() {
        CollabTask task = taskAssignedToAliceCreatedByBob();
        assertEquals(TaskStatus.DONE, task.getStatus());
        assertFalse(CollabTask.isConfirmed(task),
                "标记完成只说明「某人宣称完成」，FR-M5-08 要求的正是把这两件事分开");
    }
}
