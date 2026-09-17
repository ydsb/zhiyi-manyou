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
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 运营看板日快照 —— 对应表 {@code zy_dashboard_snapshot}（FR-M9-04）。
 *
 * <p><b>为什么必须落库</b>：趋势类指标（"上周三的日活"）在数据变化后无法回溯 ——
 * 只能靠当时记下来。因此定时任务按日写入本表，看板读快照画趋势曲线；
 * 而当天的实时数字仍走实时查询，保证不会滞后一天。
 *
 * <p>{@code stat_date} 有唯一键，同一天重跑批处理是覆盖而非追加，不会产生重复数据点。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_dashboard_snapshot")
public class DashboardSnapshot implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private LocalDate statDate;

    /** 当日活跃用户数（以 lastLoginAt 落在当天为准） */
    private Integer activeUsers;

    private Integer newUsers;

    private Integer demandPublished;

    private Integer exchangeStarted;

    private Integer exchangeFinished;

    /** 匹配成功率：当日发出的邀约中被接受的比率 */
    private BigDecimal matchSuccessRate;

    /** 扩展指标 JSON（学科分布、信用分布等） */
    private String metrics;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.UPDATE)
    private LocalDateTime updatedAt;
}
