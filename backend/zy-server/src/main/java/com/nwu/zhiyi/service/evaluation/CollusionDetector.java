package com.nwu.zhiyi.service.evaluation;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 互刷信用检测（FR-M6-07）。
 *
 * <p><b>四个风险模式</b>（需求明确点名的"同一对用户重复交换、闭环互评、异常时间间隔"，
 * 另补一条"高分低信息量"）：
 * <table border="1">
 *   <tr><th>模式</th><th>判据</th><th>风险</th></tr>
 *   <tr><td>重复交换</td><td>同一对用户已完成交换 ≥ {@code REPEAT_PAIR_LIMIT} 次</td>
 *       <td>互刷基础分</td></tr>
 *   <tr><td>异常时间间隔</td><td>进入待互评后极短时间内完成双方评价</td>
 *       <td>未真实协作就打分</td></tr>
 *   <tr><td>高分低信息量</td><td>总分很高但评语过短</td><td>模板化好评</td></tr>
 *   <tr><td>闭环互评</td><td>多对用户之间高频互评（小圈子）</td><td>信用内循环</td></tr>
 * </table>
 *
 * <p><b>为什么只标记不拦截</b>：真实校园场景里"同一个同学反复互相帮忙"是正常且值得鼓励的，
 * 直接拒评会误伤。因此检测结果只把记录置为待人工复核
 * （{@code audit_status = PENDING}），并如实记录命中的特征，由管理员或仲裁判断。
 * 需求 FR-M6-07 的措辞也是"模式识别"，不是"自动阻断"。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CollusionDetector {

    private final ExchangeRecordMapper exchangeMapper;
    private final EvaluationGradeMapper evaluationMapper;

    /** 同一对用户已完成交换达到该次数即标记 */
    private static final int REPEAT_PAIR_LIMIT = 3;

    /** 进入待互评后多久内完成评价算"异常快速"（小时） */
    private static final long SUSPICIOUS_FAST_HOURS = 2;

    /** 高分阈值（超过则审视信息量） */
    private static final double HIGH_SCORE = 95.0;

    /** 高分下的最小评语长度 */
    private static final int HIGH_SCORE_MIN_COMMENT = 10;

    /** 闭环互评：同一用户在窗口期内评价过的不同对象数达到该值视为小圈子 */
    private static final int CLIQUE_DISTINCT_PARTNERS = 4;

    /** 闭环互评的观察窗口（天） */
    private static final int CLIQUE_WINDOW_DAYS = 30;

    /**
     * 检测结果。
     *
     * @param suspected 是否疑似互刷
     * @param reasons   命中的风险特征
     */
    public record Result(boolean suspected, List<String> reasons) {

        static Result clean() {
            return new Result(false, List.of());
        }
    }

    /**
     * 对一次待提交的评价做检测。
     *
     * @param record     交换记录
     * @param fromSno    评价人
     * @param toSno      被评价人
     * @param totalScore 本次评价总分
     * @param comment    本次评语
     * @param now        提交时刻
     * @return 检测结果
     */
    public Result detect(ExchangeRecord record, String fromSno, String toSno,
                         BigDecimal totalScore, String comment, LocalDateTime now) {
        List<String> reasons = new ArrayList<>();

        // ① 重复交换
        int completed = exchangeMapper.countCompletedBetween(fromSno, toSno);
        if (completed >= REPEAT_PAIR_LIMIT) {
            reasons.add(String.format("同一对用户已完成 %d 次交换（阈值 %d）", completed, REPEAT_PAIR_LIMIT));
        }

        // ② 异常时间间隔：进入待互评后极快完成评价
        if (record.getPendingEvalAt() != null) {
            long minutes = Duration.between(record.getPendingEvalAt(), now).toMinutes();
            if (minutes >= 0 && minutes < SUSPICIOUS_FAST_HOURS * 60) {
                reasons.add(String.format("进入待互评后仅 %d 分钟即提交评价（阈值 %d 小时），可能未真实协作",
                        minutes, SUSPICIOUS_FAST_HOURS));
            }
        }

        // ③ 高分低信息量
        int commentLength = comment == null ? 0 : comment.trim().length();
        if (totalScore != null && totalScore.doubleValue() >= HIGH_SCORE
                && commentLength < HIGH_SCORE_MIN_COMMENT) {
            reasons.add(String.format("总分 %.1f 但评语仅 %d 字，信息量偏低（阈值 %d 字）",
                    totalScore.doubleValue(), commentLength, HIGH_SCORE_MIN_COMMENT));
        }

        // ④ 闭环互评：评价人近期是否在多个对象间高频互评
        LocalDateTime since = now.minusDays(CLIQUE_WINDOW_DAYS);
        int distinctPartners = evaluationMapper.selectList(new LambdaQueryWrapper<EvaluationGrade>()
                        .select(EvaluationGrade::getToSno)
                        .eq(EvaluationGrade::getFromSno, fromSno)
                        .ge(EvaluationGrade::getCreatedAt, since)).stream()
                .map(EvaluationGrade::getToSno)
                .distinct()
                .toList()
                .size();
        if (distinctPartners >= CLIQUE_DISTINCT_PARTNERS) {
            reasons.add(String.format("评价人近 %d 天内已评价 %d 个不同对象，需关注是否存在小圈子互评",
                    CLIQUE_WINDOW_DAYS, distinctPartners));
        }

        if (reasons.isEmpty()) {
            return Result.clean();
        }
        log.info("[互刷检测] 命中 {} 项风险特征：record={} {} → {} | {}",
                reasons.size(), record.getRecordNo(), fromSno, toSno, String.join("；", reasons));
        return new Result(true, reasons);
    }
}
