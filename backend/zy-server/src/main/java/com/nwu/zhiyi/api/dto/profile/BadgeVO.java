package com.nwu.zhiyi.api.dto.profile;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 勋章视图（FR-M7-04）。
 *
 * <p>未解锁的勋章也返回（带 {@code unlocked=false} 与 {@code progressHint}），
 * 让用户看到"还差什么"—— 这是激励设计的关键，只显示已获得的勋章会失去引导作用。
 *
 * @author 李泽宬
 */
@Data
public class BadgeVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private String code;
    private String name;
    private String description;
    private String icon;
    /** 勋章等级：BRONZE / SILVER / GOLD，用于前端配色 */
    private String level;

    /** 解锁条件表达式（人类可读形式） */
    private String conditionText;

    /** 是否已解锁 */
    private Boolean unlocked;

    private LocalDateTime grantedAt;

    /** 授予来源交换记录 ID（如有） */
    private Long refRecordId;

    /**
     * 进度提示，如「已完成 2/5 次交换」。
     * 未解锁时给出，帮助用户知道如何获得。
     */
    private String progressHint;

    /** 当前进度值 */
    private Integer currentValue;

    /** 目标值 */
    private Integer targetValue;

    /** 已解锁数量统计（仅列表接口的第一个元素带，或单独字段） */
    private List<BadgeVO> all;
}
