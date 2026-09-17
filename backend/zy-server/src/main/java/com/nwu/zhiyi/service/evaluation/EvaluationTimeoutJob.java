package com.nwu.zhiyi.service.evaluation;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 互评超时提醒与默认计分任务（FR-M6-06）。
 *
 * <p><b>两段式处理</b>：
 * <ol>
 *   <li><b>提醒</b>：进入「待互评」超过 {@code remindDays} 天仍未提交 → 发提醒通知
 *       （每份交换每方只发一次，避免骚扰）；</li>
 *   <li><b>默认计分</b>：超过 {@code timeoutDays} 天仍未提交 → 按既定规则写入一条
 *       {@code timeout_flag = 1} 的默认评价，并记入信用影响。</li>
 * </ol>
 *
 * <p><b>默认分值为什么取 80 而不是 100 或 0</b>：
 * <ul>
 *   <li>取 100 会让"不评价"成为最优策略，激励反向；</li>
 *   <li>取 0 会把"忘记评价"等同于"协作失败"，对被评价人不公平；</li>
 *   <li>取 80（略低于"良好"）表达"无可指摘但也无额外证明"，同时通过
 *       {@code timeout_flag} 让这份分数在能力画像中可被识别与区别对待。</li>
 * </ul>
 * 默认评价<b>不产生有价值的哈希存证意义</b>以外的东西 —— 它会照常 sealed，
 * 因此同样可被校验；但它的 {@code comment} 明确写明是系统默认计分，
 * 不会冒充真实评价。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class EvaluationTimeoutJob {

    private final ExchangeRecordMapper exchangeMapper;
    private final EvaluationGradeMapper evaluationMapper;
    private final NotificationService notificationService;
    private final DimensionScoreCalculator calculator;

    /** 超时默认计分的分值 */
    private static final double DEFAULT_SCORE = 80.0;

    /** 默认评价的评语（如实标注来源，不冒充真实评价） */
    private static final String DEFAULT_COMMENT =
            "双方约定时间内未提交评价，系统按规则默认计分。该分不代表真实评价内容。";

    /** 首次提醒阈值（天） */
    @Value("${zhiyi.evaluation.remind-days:3}")
    private long remindDays;

    /** 默认计分阈值（天） */
    @Value("${zhiyi.evaluation.timeout-days:7}")
    private long timeoutDays;

    /**
     * 每 6 小时检查一次。
     *
     * <p>初始延迟 3 分钟，错开启动负载。
     */
    @Scheduled(initialDelay = 180_000, fixedDelay = 21_600_000)
    public void scanPendingEvaluations() {
        List<ExchangeRecord> pending = exchangeMapper.selectList(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.PENDING_EVAL)
                .isNotNull(ExchangeRecord::getPendingEvalAt));
        if (pending.isEmpty()) {
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        int reminded = 0;
        int defaulted = 0;

        for (ExchangeRecord record : pending) {
            long days = Duration.between(record.getPendingEvalAt(), now).toDays();

            // 已提交的评价人集合
            List<EvaluationGrade> submitted = evaluationMapper.selectList(
                    new LambdaQueryWrapper<EvaluationGrade>()
                            .select(EvaluationGrade::getFromSno)
                            .eq(EvaluationGrade::getRecordId, record.getId()));
            boolean giverSubmitted = submitted.stream()
                    .anyMatch(g -> record.getGiverSno().equals(g.getFromSno()));
            boolean takerSubmitted = submitted.stream()
                    .anyMatch(g -> record.getTakerSno().equals(g.getFromSno()));

            // ---------- 阶段二：超时默认计分 ----------
            if (days >= timeoutDays) {
                if (!giverSubmitted) {
                    writeDefaultEvaluation(record, record.getGiverSno(), record.getTakerSno());
                    defaulted++;
                }
                if (!takerSubmitted) {
                    writeDefaultEvaluation(record, record.getTakerSno(), record.getGiverSno());
                    defaulted++;
                }
                continue;
            }

            // ---------- 阶段一：超时提醒（幂等） ----------
            if (days >= remindDays) {
                if (!giverSubmitted) {
                    boolean sent = notificationService.sendOnce(record.getGiverSno(),
                            NotificationType.EVAL_REMIND, "互评即将超时",
                            String.format("交换「%s」已进入待互评 %d 天，超过 %d 天将按规则默认计分，请尽快完成评价",
                                    record.getTitle(), days, timeoutDays),
                            "EVALUATION", record.getId());
                    if (sent) {
                        reminded++;
                    }
                }
                if (!takerSubmitted) {
                    boolean sent = notificationService.sendOnce(record.getTakerSno(),
                            NotificationType.EVAL_REMIND, "互评即将超时",
                            String.format("交换「%s」已进入待互评 %d 天，超过 %d 天将按规则默认计分，请尽快完成评价",
                                    record.getTitle(), days, timeoutDays),
                            "EVALUATION", record.getId());
                    if (sent) {
                        reminded++;
                    }
                }
            }
        }

        if (reminded > 0 || defaulted > 0) {
            log.info("[互评超时] 本轮提醒 {} 条，默认计分 {} 条", reminded, defaulted);
        }
    }

    /**
     * 写入一条系统默认评价。
     *
     * <p>四个维度统一给默认分，{@code timeout_flag = 1} 标识来源，
     * 评语明确说明是系统生成 —— 避免它被误读为真实反馈。
     */
    private void writeDefaultEvaluation(ExchangeRecord record, String fromSno, String toSno) {
        if (fromSno == null || toSno == null) {
            return;
        }
        Long exists = evaluationMapper.selectCount(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getRecordId, record.getId())
                .eq(EvaluationGrade::getFromSno, fromSno));
        if (exists != null && exists > 0) {
            return;
        }

        java.util.Map<String, Object> dims = new java.util.LinkedHashMap<>();
        com.nwu.zhiyi.common.enums.EvaluationDimension.weightTable().keySet()
                .forEach(k -> dims.put(k, DEFAULT_SCORE));
        java.util.Map<String, Double> normalized = calculator.normalize(dims);

        EvaluationGrade grade = new EvaluationGrade()
                .setRecordId(record.getId())
                .setFromSno(fromSno)
                .setToSno(toSno)
                .setDimScores(calculator.toJson(normalized))
                .setDimCanonical(calculator.toCanonical(normalized))
                .setTotalScore(calculator.totalScore(normalized))
                .setComment(DEFAULT_COMMENT)
                .setAnonymous(0)
                .setDisputeFlag(0)
                .setTimeoutFlag(1)
                .setAuditStatus("PASSED")
                .setAuditRemark("系统超时默认计分（FR-M6-06）")
                .setSealedAt(LocalDateTime.now().withNano(0));
        grade.seal();
        evaluationMapper.insert(grade);

        log.info("[互评超时] 默认计分 record={} {} → {} 分值={}",
                record.getRecordNo(), fromSno, toSno, grade.getTotalScore());

        // 记入信用影响：超时未评价扣分（具体惩罚力度由 M8 的信用规则统一管理，
        // 这里只发通知告知后果，避免在 M6 里散落信用计算逻辑）
        notificationService.send(fromSno, NotificationType.EVAL_REMIND,
                "已按规则默认计分",
                "你未在规定时间内提交评价，系统已按规则默认计分，该记录会影响你的信用评价",
                "EVALUATION", record.getId());
    }

    /** 供测试与运维查看当前阈值 */
    public long getTimeoutDays() {
        return timeoutDays;
    }

    /** 供测试查看默认分值 */
    public BigDecimal getDefaultScore() {
        return BigDecimal.valueOf(DEFAULT_SCORE).setScale(2, java.math.RoundingMode.HALF_UP);
    }

    /** 供测试与前端展示默认评价说明 */
    public String getDefaultComment() {
        return DEFAULT_COMMENT;
    }

}
