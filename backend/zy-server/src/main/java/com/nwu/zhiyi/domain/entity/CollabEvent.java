package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作事件实体 —— 对应表 {@code zy_collab_event}（FR-M5-04 时间轴 / FR-M5-06 过程性评价语料）。
 *
 * <p><b>为什么单独建表而不复用 zy_interaction_log</b>：
 * <ul>
 *   <li>本表是<b>面向协作进度</b>的结构化事件，{@code title} 已渲染好可直接展示在时间轴，
 *       且带 {@code actorSno} 与 {@code occurredAt}，能直接聚合出"个人响应时长/按期率"；</li>
 *   <li>{@code zy_interaction_log} 是<b>面向埋点</b>的原始点击流，量大且语义粗糙，
 *       用于用户画像与削峰落盘，不适合当作业务时间轴。</li>
 * </ul>
 * 两者互补：同一个"打卡"动作会写一条协作事件（可读、可聚合）+ 可选一条埋点（频率统计）。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_collab_event")
public class CollabEvent implements Serializable {

    private static final long serialVersionUID = 1L;

    /* 事件类型常量 —— 与前端时间轴图标映射一一对应 */
    public static final String TYPE_EXCHANGE_START = "EXCHANGE_START";
    public static final String TYPE_TASK_CREATE = "TASK_CREATE";
    public static final String TYPE_TASK_CLAIM = "TASK_CLAIM";
    public static final String TYPE_TASK_DONE = "TASK_DONE";
    public static final String TYPE_TASK_OVERDUE = "TASK_OVERDUE";
    public static final String TYPE_FILE_UPLOAD = "FILE_UPLOAD";
    public static final String TYPE_MESSAGE = "MESSAGE";
    public static final String TYPE_STATUS_CHANGE = "STATUS_CHANGE";
    public static final String TYPE_CONFIRM = "CONFIRM";

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 所属交换记录 ID */
    private Long recordId;

    /** 行为主体学号（系统事件可为空） */
    private String actorSno;

    private String eventType;

    /** 时间轴标题（已渲染完毕，前端直接展示） */
    private String title;

    private String detail;

    /** 关联对象类型：TASK / FILE / MESSAGE / EXCHANGE */
    private String refType;

    /** 关联对象 ID */
    private Long refId;

    /**
     * 发生时间。
     *
     * <p><b>必须用自动填充，不能依赖数据库默认值</b>：建表时写了
     * {@code DEFAULT CURRENT_TIMESTAMP}，但 MyBatis-Plus 的 insert 会把实体的
     * 全部字段（含 null）写进 SQL，显式传 null 会<b>覆盖</b>数据库默认值，
     * 从而触发 {@code Column 'occurred_at' cannot be null}。
     * 由 {@code MybatisPlusConfig} 的 MetaObjectHandler 在插入时填入。
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime occurredAt;
}
