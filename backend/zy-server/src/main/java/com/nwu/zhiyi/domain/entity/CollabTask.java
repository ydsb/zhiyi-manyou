package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.TaskStatus;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作空间任务项实体 —— 对应表 {@code zy_collab_task}。
 *
 * <p>交换匹配成功后，双方在专属协作空间内拆解任务、阶段打卡。
 * 任务的完成节奏、按期率等特征会作为过程性评价语料沉淀。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_collab_task")
public class CollabTask implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 所属交换记录 ID */
    private Long recordId;

    private String title;

    private String description;

    /**
     * 负责人学号。
     *
     * <p>FR-M5-06 要求把"任务拆解粒度、按期率"等指标落到<b>个人</b>维度，
     * 作为过程性评价语料。只有 {@code createdBy} 无法区分"谁负责做"，
     * 因此单独设负责人字段（见 sql/02-migration-m5.sql）。
     */
    private String assigneeSno;

    /** 截止时间 */
    private LocalDateTime deadline;

    /** 任务状态（数据库以枚举名存储） */
    private TaskStatus status;

    /** 成果证据地址（附件/链接） */
    private String evidenceUrl;

    private Integer sortOrder;

    private LocalDateTime doneAt;

    /** 创建人学号 */
    private String createdBy;

    /* ---------------- FR-M5-08 阶段性成果双向确认 ---------------- */

    /**
     * 打卡者学号 —— 记录"是谁宣称完成的"。
     *
     * <p>不能从 {@code assigneeSno} 推断：任务可能没有负责人（共同负责），
     * 打卡人也未必是负责人。而判定"谁有权确认"需要知道打卡人是谁
     * （自己不能确认自己），因此单独记录。
     */
    private String doneBy;

    /**
     * 对方是否已确认该阶段成果（FR-M5-08）。
     *
     * <p><b>命名踩坑记录（重要）</b>：本字段最初叫 {@code confirmed}，
     * 配套的领域方法叫 {@code isConfirmed()}，结果 MyBatis 抛
     * {@code Illegal overloaded getter method with ambiguous type for property 'confirmed'}。
     *
     * <p>原因是 MyBatis 会把 {@code getConfirmed()}（Lombok 生成）与
     * {@code isConfirmed()}（手写）都识别为属性 {@code confirmed} 的 reader，
     * 两者返回类型不同即判定为歧义。**把字段类型从 {@code Integer} 换成
     * {@code Boolean} 并不能解决** —— 对 {@code Boolean} 字段而言
     * {@code isXxx()} 依然是合法 reader。
     *
     * <p>唯一可靠的解法是让领域方法不带 getter 前缀，因此本字段对应的方法叫
     * {@link #confirmedAlready()}。领域内判断请用静态方法
     * {@link #isConfirmed(CollabTask)}。
     *
     * <p>同一个坑本项目此前在 {@code EvaluationGrade.anonymous} 上踩过一次，
     * 当时的处置是"换个不冲突的方法名" —— 这次把原因写清楚，避免第三次。
     */
    private Boolean confirmed;

    /** 确认人学号 */
    private String confirmedBy;

    /** 确认时间 */
    private LocalDateTime confirmedAt;

    /** 确认或提出异议的说明 */
    private String confirmRemark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /** 是否已逾期且未完成 */
    public boolean isOverdue() {
        return status != TaskStatus.DONE && deadline != null && deadline.isBefore(LocalDateTime.now());
    }

    /** 标记完成 */
    public void markDone() {
        this.status = TaskStatus.DONE;
        this.doneAt = LocalDateTime.now();
    }

    /**
     * 该任务是否已被协作方确认。
     *
     * <p><b>必须是静态方法，不能写成实例方法 {@code isConfirmed()}</b>：
     * 实例方法一旦以 {@code is} 开头，就会被 MyBatis 当成 {@code confirmed}
     * 属性的第二个 reader，与 Lombok 生成的 {@code getConfirmed()} 构成歧义，
     * 导致任何 insert/update 直接抛异常。详见 {@link #confirmed} 的说明。
     *
     * @param task 任务，可为 null
     * @return 已确认返回 true；任务为 null 或未确认返回 false
     */
    public static boolean isConfirmed(CollabTask task) {
        return task != null && Boolean.TRUE.equals(task.getConfirmed());
    }

    /**
     * 标记为"已由对方确认"。
     *
     * @param confirmer 确认人学号
     * @param remark    确认说明，可为 null
     */
    public void markConfirmed(String confirmer, String remark) {
        this.confirmed = Boolean.TRUE;
        this.confirmedBy = confirmer;
        this.confirmedAt = LocalDateTime.now();
        this.confirmRemark = remark;
    }

    /**
     * 清空确认状态（撤回重做时调用）。
     *
     * <p>撤回后"曾被确认"不再成立 —— 成果本身已经改变，
     * 旧的认可对新成果无效。这也是把确认单独存储、而不是做成状态机一态的原因：
     * 清空确认不会影响"曾经完成过"的历史事实。
     */
    public void clearConfirmation() {
        this.confirmed = Boolean.FALSE;
        this.confirmedBy = null;
        this.confirmedAt = null;
        this.confirmRemark = null;
    }

    /**
     * 是否有权确认本任务。
     *
     * <p>规则：确认人必须是<b>交换的任一方</b>（即协作方），且<b>不能是打卡者本人</b>。
     *
     * <p><b>为什么判据是"是否参与本次交换"而不是"是否任务的负责人/创建人"</b>：
     * 最初实现用的是后者，但测试立刻暴露出一个边界 ——
     * 任务允许没有负责人（共同负责，{@code assigneeSno} 为空），
     * 此时若由创建人打卡，就没有任何"负责人或创建人"剩下可以确认它，
     * FR-M5-08 在该场景下直接失效。
     *
     * <p>而需求原文说的是"<b>互相</b>同步确认"—— 语义上就是"由协作方确认"。
     * 交换双方对协作过程都有观察，任一方都有资格判断对方交付的成果是否成立。
     * 因此判据收敛为"是交换参与方，且不是打卡者"。
     *
     * <p><b>为什么仍然禁止自确认</b>：这是 FR-M5-08 的全部意义所在 ——
     * 若允许打卡者自己确认，"防止单方面宣称完成"就成了一句空话。
     *
     * @param sno        待判定的学号
     * @param giverSno   交换提供方学号
     * @param takerSno   交换需求方学号
     * @return 有权确认返回 true
     */
    public boolean canBeConfirmedBy(String sno, String giverSno, String takerSno) {
        if (sno == null || sno.isBlank()) {
            return false;
        }
        // 打卡者不能确认自己：否则"防止单方面宣称完成"形同虚设
        if (sno.equals(doneBy)) {
            return false;
        }
        return sno.equals(giverSno) || sno.equals(takerSno);
    }

    /**
     * 简化版判定：仅校验"不是打卡者"。
     *
     * <p>供无法拿到交换参与方信息的场景使用（如纯领域测试）。
     * 生产代码应使用 {@link #canBeConfirmedBy(String, String, String)}，
     * 否则非参与方也可能通过校验。
     *
     * @param sno 待判定的学号
     * @return 未被打卡者占用且非空白返回 true
     */
    public boolean isNotClaimedBy(String sno) {
        return sno != null && !sno.isBlank() && !sno.equals(doneBy);
    }
}
