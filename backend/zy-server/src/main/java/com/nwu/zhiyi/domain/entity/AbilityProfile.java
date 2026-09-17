package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 能力画像快照实体 —— 对应表 {@code zy_ability_profile}（FR-M7-03 / FR-M7-07）。
 *
 * <p><b>为什么必须落库快照</b>：实时计算只能得到"当前值"，画不出成长曲线 ——
 * 历史状态没有被记录。因此定时任务按周期写入快照，成长轨迹读的是快照序列。
 *
 * <p>同一用户同一周期只保留一条（唯一键 {@code uk_profile_sno_period}），
 * 重跑批处理不会产生重复数据点。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_ability_profile")
public class AbilityProfile implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 周期类型：月度快照（定时任务生成） */
    public static final String TYPE_MONTH = "MONTH";
    /** 周期类型：手动刷新（用户点击"刷新画像"） */
    public static final String TYPE_MANUAL = "MANUAL";

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String sno;

    /** 快照周期，如 2026-09（月度）或 2026-09-17（手动） */
    private String period;

    private String periodType;

    /**
     * 五维得分 JSON：{@code {"engineering":88.5,"humanities":null,...}}。
     *
     * <p>无样本的维度值为 null（而不是 0）—— 0 会被读成"能力很差"，
     * 而事实是"没有数据"。
     */
    private String dims;

    /** 参与计算的样本数（已完成且有互评的交换数） */
    private Integer sampleCount;

    /** 样本的平均互评总分 */
    private BigDecimal avgScore;

    /** 累计协作时长（小时） */
    private BigDecimal totalHours;

    /** 口径说明与原始计数 JSON（可解释性依据，能回答"这个分怎么来的"） */
    private String rawInputs;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.UPDATE)
    private LocalDateTime updatedAt;
}
