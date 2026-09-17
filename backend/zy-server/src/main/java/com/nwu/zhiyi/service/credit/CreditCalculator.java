package com.nwu.zhiyi.service.credit;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.common.enums.CreditLevel;
import com.nwu.zhiyi.common.enums.DisputeStatus;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.domain.entity.Dispute;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.mapper.DisputeMapper;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 信用值计算器（FR-M8-01）。
 *
 * <p><b>模型：五因子加权（0~100 分制，与互评同尺度便于对照）</b>
 * <table border="1">
 *   <tr><th>因子</th><th>权重</th><th>计算方式</th></tr>
 *   <tr><td>履约完成率</td><td>0.30</td>
 *       <td>已完成 / (已完成 + 进行中 + 协商中 + 已取消中自己造成的部分)</td></tr>
 *   <tr><td>互评均分</td><td>0.30</td>
 *       <td>收到评价的平均总分（无评价时不参与计算，见下）</td></tr>
 *   <tr><td>申诉败诉率</td><td>0.20</td>
 *       <td>因子分 = 100 × (1 − 败诉次数 / 参与争议次数)，无争议记 100</td></tr>
 *   <tr><td>活跃贡献度</td><td>0.10</td>
 *       <td>按累计协作时长分段：0h=0，≥60h=100</td></tr>
 *   <tr><td>评价及时性</td><td>0.10</td>
 *       <td>100 × (1 − 超时默认计分次数 / 应评价次数)</td></tr>
 * </table>
 *
 * <p><b>为什么用"组合式"而不是"基础分 + 加减分"</b>：
 * 组合式让"没有真实协作"无法刷分 —— 刷 10 次低质量交换，互评均分与履约完成率都会被拉低，
 * 而每次交换都要付出时间成本；反过来，认真做 1~2 次交换就能拿到接近 100 的信用。
 * 如果只是"完成一次 +2 分"，刷量就成了最优策略（这是 M6 互刷检测要防的同一件事）。
 *
 * <p><b>新用户为什么记 100 而不是 0</b>：零交易记录的信用为 0 会让新人寸步难行，
 * 且"没有不良记录"本身应是中性偏好而非差评。这与需求 3.2 节"初始信用值 100"一致。
 *
 * <p><b>无互评记录时怎么算</b>：把该因子权重按比例分摊到其余因子，
 * 而不是给它 0 分 —— 否则"完成了交换但对方没评价"会被当成失信惩罚，
 * 而这可能只是对方的问题。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CreditCalculator {

    private final ExchangeRecordMapper exchangeMapper;
    private final EvaluationGradeMapper evaluationMapper;
    private final DisputeMapper disputeMapper;

    /**
     * 新用户初始信用值。
     *
     * <p>常量本体定义在 {@link CreditLevel#INIT_SCORE}（zy-common 内，
     * 供注册流程复用），此处仅做转发，避免出现两个"初始信用"定义。
     */
    public static final int INIT_SCORE = CreditLevel.INIT_SCORE;

    /** 活跃贡献度满分对应的累计协作时长（小时） */
    private static final double FULL_ACTIVITY_HOURS = 60.0;

    /** 各因子权重 */
    private static final double W_COMPLETION = 0.30;
    private static final double W_EVALUATION = 0.30;
    private static final double W_DISPUTE = 0.20;
    private static final double W_ACTIVITY = 0.10;
    private static final double W_TIMELINESS = 0.10;

    /**
     * 计算结果。
     *
     * @param score        最终信用值（0~100）
     * @param factors      各因子明细（键为因子名）
     * @param exchangeCount 已完成交换数
     * @param totalHours   累计协作时长
     * @param isNewUser    是否无任何交易记录（此时返回初始分）
     */
    public record Result(int score,
                         Map<String, Factor> factors,
                         int exchangeCount,
                         double totalHours,
                         boolean isNewUser) {

        /** 供前端展示的因子说明文本 */
        public String describe() {
            StringBuilder sb = new StringBuilder();
            factors.forEach((name, f) -> {
                if (sb.length() > 0) {
                    sb.append("；");
                }
                sb.append(String.format("%s %.1f 分（权重 %.0f%%）%s",
                        name, f.score(), f.weight() * 100, f.detail()));
            });
            return sb.toString();
        }
    }

    /**
     * 单个因子的得分与说明。
     *
     * @param name   因子名
     * @param score  因子分 0~100
     * @param weight 实际参与计算的权重（可能因无数据被重分配）
     * @param detail 人类可读的依据
     */
    public record Factor(String name, double score, double weight, String detail) {
    }

    /**
     * 计算某用户的信用值。
     *
     * @param sno 学号
     * @return 计算结果（含可解释的因子明细）
     */
    public Result compute(String sno) {
        List<ExchangeRecord> records = exchangeMapper.selectList(new LambdaQueryWrapper<ExchangeRecord>()
                .and(w -> w.eq(ExchangeRecord::getGiverSno, sno).or().eq(ExchangeRecord::getTakerSno, sno)));

        long completed = records.stream().filter(r -> r.getStatus() == ExchangeStatus.COMPLETED).count();
        long ongoing = records.stream().filter(r -> r.getStatus() == ExchangeStatus.IN_PROGRESS).count();
        long negotiating = records.stream().filter(r -> r.getStatus() == ExchangeStatus.NEGOTIATING).count();
        long cancelled = records.stream().filter(r -> r.getStatus() == ExchangeStatus.CANCELLED).count();
        long pendingEval = records.stream().filter(r -> r.getStatus() == ExchangeStatus.PENDING_EVAL).count();

        // ---------- 因子 1：履约完成率 ----------
        // 分母 = 所有"已进入实质阶段"的交换。洽谈中（还没开始）不算失信，
        // 但取消计入分母 —— 频繁接单后取消同样消耗了对方的机会成本。
        long committed = completed + ongoing + pendingEval + cancelled;
        double completionRate;
        String completionDetail;
        if (committed == 0) {
            completionRate = 100.0;
            completionDetail = "暂无交换记录，按满分计";
        } else {
            completionRate = 100.0 * completed / committed;
            completionDetail = String.format("已完成 %d / 实质参与 %d（进行中 %d、待互评 %d、已取消 %d）",
                    completed, committed, ongoing, pendingEval, cancelled);
        }

        // ---------- 因子 2：互评均分 ----------
        List<EvaluationGrade> received = evaluationMapper.selectList(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getToSno, sno));
        Double evalScore = null;
        String evalDetail;
        if (received.isEmpty()) {
            evalDetail = "尚未收到互评，该因子权重按比例分摊到其他因子";
        } else {
            evalScore = received.stream()
                    .filter(g -> g.getTotalScore() != null)
                    .map(EvaluationGrade::getTotalScore)
                    .reduce(BigDecimal.ZERO, BigDecimal::add)
                    .divide(BigDecimal.valueOf(received.size()), 2, RoundingMode.HALF_UP)
                    .doubleValue();
            evalDetail = String.format("收到 %d 条互评，平均 %.2f 分", received.size(), evalScore);
        }

        // ---------- 因子 3：申诉败诉率 ----------
        List<Dispute> disputes = disputeMapper.selectList(new LambdaQueryWrapper<Dispute>()
                .and(w -> w.eq(Dispute::getApplicant, sno).or().eq(Dispute::getRespondent, sno)));
        long lost = disputes.stream()
                .filter(d -> isLost(d, sno))
                .count();
        long resolvedDisputes = disputes.stream()
                .filter(d -> DisputeStatus.RESOLVED.equals(d.getStatus()) || DisputeStatus.REJECTED.equals(d.getStatus()))
                .count();
        double disputeScore;
        String disputeDetail;
        if (resolvedDisputes == 0) {
            disputeScore = 100.0;
            disputeDetail = disputes.isEmpty() ? "无争议记录" : "存在未结争议，结案后再计入";
        } else {
            disputeScore = 100.0 * (resolvedDisputes - lost) / resolvedDisputes;
            disputeDetail = String.format("已结争议 %d 起，其中被判承担责任 %d 起", resolvedDisputes, lost);
        }

        // ---------- 因子 4：活跃贡献度 ----------
        double totalHours = sumHours(records);
        double activityScore = Math.min(100.0, 100.0 * totalHours / FULL_ACTIVITY_HOURS);
        String activityDetail = String.format("累计协作 %s 小时（满 %.0f 小时得 100 分）",
                strip(totalHours), FULL_ACTIVITY_HOURS);

        // ---------- 因子 5：评价及时性 ----------
        long timeoutCount = received.stream().filter(EvaluationGrade::isTimeoutScored).count();
        // 应评价次数 = 我完成的交换数（每次完成后我都该给对方评价）
        long shouldEvaluate = completed;
        double timelinessScore;
        String timelinessDetail;
        if (shouldEvaluate == 0) {
            timelinessScore = 100.0;
            timelinessDetail = "暂无应评价记录，按满分计";
        } else {
            timelinessScore = Math.max(0.0, 100.0 * (shouldEvaluate - timeoutCount) / shouldEvaluate);
            timelinessDetail = String.format("%d 次应评价中 %d 次超时未评", shouldEvaluate, timeoutCount);
        }

        // ---------- 加权 ----------
        Map<String, Factor> factors = new LinkedHashMap<>();
        factors.put("履约完成率", new Factor("履约完成率", round1(completionRate), W_COMPLETION, completionDetail));
        factors.put("互评均分", new Factor("互评均分", evalScore == null ? -1 : round1(evalScore),
                evalScore == null ? 0 : W_EVALUATION, evalDetail));
        factors.put("申诉败诉率", new Factor("申诉败诉率", round1(disputeScore), W_DISPUTE, disputeDetail));
        factors.put("活跃贡献度", new Factor("活跃贡献度", round1(activityScore), W_ACTIVITY, activityDetail));
        factors.put("评价及时性", new Factor("评价及时性", round1(timelinessScore), W_TIMELINESS, timelinessDetail));

        BigDecimal weighted = BigDecimal.ZERO;
        double weightSum = 0;
        for (Factor f : factors.values()) {
            if (f.score() < 0) {
                continue;
            }
            weighted = weighted.add(BigDecimal.valueOf(f.score() * f.weight()));
            weightSum += f.weight();
        }

        int score;
        boolean isNewUser = records.isEmpty() && received.isEmpty();
        if (isNewUser || weightSum <= 0) {
            score = INIT_SCORE;
        } else if (Math.abs(weightSum - 1.0) > 0.0001) {
            // 有因子缺失（如无互评）→ 按剩余权重归一到 100 分制
            score = weighted.divide(BigDecimal.valueOf(weightSum), 2, RoundingMode.HALF_UP).intValue();
        } else {
            score = weighted.setScale(2, RoundingMode.HALF_UP).intValue();
        }
        // 计算输出理论上落在 0~100（权重和为 1），但仍做一次防御性钳制；
        // 上界用 RANGE_MAX 而非 100，以免未来权重调整时被静默截断
        score = Math.max(0, Math.min(CreditLevel.RANGE_MAX, score));

        // 无互评价时把权重重新标注，便于前端解释"为什么权重不是 30%"
        if (evalScore == null) {
            Map<String, Factor> adjusted = new LinkedHashMap<>();
            for (Map.Entry<String, Factor> e : factors.entrySet()) {
                Factor f = e.getValue();
                adjusted.put(e.getKey(), f.score() < 0
                        ? new Factor(f.name(), 0, 0, f.detail())
                        : new Factor(f.name(), f.score(), round3(f.weight() / weightSum), f.detail()));
            }
            factors = adjusted;
        }

        return new Result(score, factors, (int) completed, totalHours, isNewUser);
    }

    /**
     * 判断某用户在争议中是否"败诉"。
     *
     * <p>判定依据是裁决结论文本里是否指名该用户承担责任。现实中裁决由委员投票产生，
     * verdict 是结构化文本（如"认定被申诉人未履约"），这里做关键词匹配。
     * 匹配不到则视为不承担责任 —— 疑罪从无，不能因为结案就让双方都掉信用。
     *
     * @param dispute 争议
     * @param sno     学号
     * @return 该用户被判承担责任返回 true
     */
    private boolean isLost(Dispute dispute, String sno) {
        if (!DisputeStatus.RESOLVED.equals(dispute.getStatus())) {
            return false;
        }
        String verdict = dispute.getVerdict();
        if (verdict == null || verdict.isBlank()) {
            return false;
        }
        /*
         * 判定依据与实际裁决书用词精确对齐（见 ArbitrationService 的 verdict 构造），
         * 而不是靠模糊的关键词猜测：
         *   - 申诉人败诉：裁决书写入「申诉未获支持」或「申诉不成立」
         *   - 被申诉人败诉：裁决书写入「认定被申诉人存在…问题」
         * 平票的裁决书写明「双方均不受处罚」，两边都不会命中 —— 这是刻意的：
         * 事实未认定时不应让任何人掉信用。
         */
        boolean isApplicant = sno.equals(dispute.getApplicant());
        if (isApplicant) {
            return verdict.contains("申诉未获支持") || verdict.contains("申诉不成立");
        }
        return verdict.contains("认定被申诉人");
    }

    /** 累计协作时长（小时），优先取实际投入 */
    private double sumHours(List<ExchangeRecord> records) {
        double sum = 0;
        for (ExchangeRecord r : records) {
            if (r.getActualHours() != null) {
                sum += r.getActualHours().doubleValue();
            } else if (r.getExpectedHours() != null) {
                sum += r.getExpectedHours();
            }
        }
        return sum;
    }

    private static double round1(double v) {
        return Math.round(v * 10) / 10.0;
    }

    private static double round3(double v) {
        return Math.round(v * 1000) / 1000.0;
    }

    private static String strip(double v) {
        return BigDecimal.valueOf(v).setScale(1, RoundingMode.HALF_UP).stripTrailingZeros().toPlainString();
    }

    /** 供测试：两个时间点之间的天数（保留给后续"活跃衰减"扩展） */
    static long daysBetween(LocalDateTime from, LocalDateTime to) {
        return Math.abs(Duration.between(from, to).toDays());
    }
}
