package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 通知类型（FR-M5-05：邀约、打卡提醒、互评提醒、裁决通知）。
 *
 * @author 李泽宬
 */
@Getter
public enum NotificationType {

    /** 收到交换邀约 */
    INVITE("交换邀约", "有人对你的需求发起了交换"),

    /** 邀约被接受/拒绝 */
    INVITE_RESULT("邀约结果", "你发出的邀约有了结果"),

    /** 打卡提醒（任务临近截止或已逾期） */
    TASK_REMIND("打卡提醒", "协作任务需要处理"),

    /** 对方完成任务打卡 */
    TASK_DONE("任务动态", "协作方更新了任务进度"),

    /** 有新留言 */
    NEW_MESSAGE("新的留言", "协作空间有新的留言"),

    /** 互评提醒 */
    EVAL_REMIND("互评提醒", "交换已进入待互评状态"),

    /** 收到评价 */
    EVAL_RECEIVED("收到评价", "你收到了一条协作评价"),

    /** 争议与裁决 */
    DISPUTE("争议处理", "争议有了新的进展"),

    /** 勋章授予 */
    BADGE("获得勋章", "你解锁了新的数字勋章"),

    /** 系统公告 */
    SYSTEM("系统通知", "平台通知");

    private final String label;
    private final String description;

    NotificationType(String label, String description) {
        this.label = label;
        this.description = description;
    }

    /**
     * 与 {@code zy_notification.type} 字段对应。
     *
     * <p>入库使用 {@link #name()}，与既有种子数据（INVITE / TASK_REMIND 等）一致。
     */
    public String code() {
        return name();
    }
}
