package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 成长周报实体 —— 对应表 {@code zy_growth_report}（FR-M7-05）。
 *
 * <p>由定时任务每周生成，内容为结构化指标 + 自然语言总结，
 * 生成后通过 M5 的通知中心推送。
 *
 * <p><b>为什么用 ISO 周（yyyy-Www）做唯一键</b>：自然周跨越月份与年份边界
 * （如 12 月 31 日可能属于次年第 1 周），用月份做键会重复或遗漏。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_growth_report")
public class GrowthReport implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String sno;

    /** 周标识：yyyy-Www（ISO 周） */
    private String weekKey;

    private LocalDate weekStart;

    private LocalDate weekEnd;

    /** 自然语言总结 */
    private String summary;

    /** 本期亮点（结构化 JSON） */
    private String highlights;

    /** 本期量化指标（结构化 JSON） */
    private String metrics;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
