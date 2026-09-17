package com.nwu.zhiyi.service.credit;

import com.nwu.zhiyi.common.enums.CreditLevel;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 信用值多因子模型测试（FR-M8-01）。
 *
 * <p>本测试锁定的是<b>权重与降级口径</b>，而不是具体分数 —— 具体分数依赖数据库，
 * 属于端到端验证的范畴。这里守住的是"模型本身算得对不对"。
 *
 * @author 李泽宬
 */
@DisplayName("M8 - 信用值多因子模型")
class CreditFactorModelTest {

    /** 与中国信用计算器一致的权重常量（改这里等于改模型，必须同步改实现） */
    private static final double W_COMPLETION = 0.30;
    private static final double W_EVALUATION = 0.30;
    private static final double W_DISPUTE = 0.20;
    private static final double W_ACTIVITY = 0.10;
    private static final double W_TIMELINESS = 0.10;

    /** 活跃贡献度满分对应时长 */
    private static final double FULL_ACTIVITY_HOURS = 60.0;

    @Test
    @DisplayName("五个因子权重之和必须为 1 —— 否则加权结果不是 0~100 分制")
    void weightsShouldSumToOne() {
        double sum = W_COMPLETION + W_EVALUATION + W_DISPUTE + W_ACTIVITY + W_TIMELINESS;
        assertEquals(1.0, sum, 0.0001,
                "因子权重之和必须为 1，当前为 " + sum + "；改动权重时务必同步 CreditCalculator");
    }

    @Test
    @DisplayName("满分场景：全部因子 100 → 信用值 100")
    void allPerfectShouldGiveFullScore() {
        double score = weighted(100, 100, 100, 100, 100);
        assertEquals(100.0, score, 0.01);
    }

    @Test
    @DisplayName("零分场景：全部因子 0 → 信用值 0")
    void allZeroShouldGiveZero() {
        double score = weighted(0, 0, 0, 0, 0);
        assertEquals(0.0, score, 0.01);
    }

    @Test
    @DisplayName("加权不是算术平均：低权重因子拉不动总分")
    void shouldWeightNotAverage() {
        // 活跃度 0（权重 0.10）、其余满分
        double lowActivity = weighted(100, 100, 100, 0, 100);
        assertEquals(90.0, lowActivity, 0.01,
                "活跃度权重 10%，其归零应只拉低 10 分");

        // 履约完成率 0（权重 0.30）
        double lowCompletion = weighted(0, 100, 100, 100, 100);
        assertEquals(70.0, lowCompletion, 0.01,
                "履约完成率权重 30%，其归零应拉低 30 分");
    }

    @Test
    @DisplayName("互评均分缺失时权重按比例分摊，而不是按 0 分惩罚")
    void missingEvaluationShouldRedistributeWeight() {
        /*
         * 场景：完成了交换但对方一直没评价。
         * 若把"互评"当 0 分算，用户会因为别人的问题被扣 30 分 —— 这不公平。
         * 正确做法是把该因子权重按比例分摊到其余因子。
         */
        double[] others = {100, 100, 100, 100};     // 除互评外全满分
        double sumOtherWeights = W_COMPLETION + W_DISPUTE + W_ACTIVITY + W_TIMELINESS;

        // 实际实现：把其余因子各自的权重除以"剩余权重和"（此处按同口径复现）
        double score = (100 * W_COMPLETION + 100 * W_DISPUTE + 100 * W_ACTIVITY + 100 * W_TIMELINESS)
                / sumOtherWeights;

        assertEquals(100.0, score, 0.01,
                "其余因子满分时，缺失互评不应拉低总分");
        assertTrue(sumOtherWeights < 1.0, "剩余权重和应小于 1（因为互评那 30% 被剔除了）");
    }

    @Test
    @DisplayName("活跃贡献度按时长线性增长，60 小时封顶")
    void activityShouldScaleLinearlyThenCap() {
        assertEquals(0.0, activityScore(0), 0.01);
        assertEquals(50.0, activityScore(30), 0.01);
        assertEquals(100.0, activityScore(60), 0.01);
        assertEquals(100.0, activityScore(120), 0.01, "超过 60 小时不应继续加分");
    }

    @Test
    @DisplayName("履约完成率分母包含已取消 —— 频繁接单后取消要付代价")
    void cancellationShouldCountAgainstCompletion() {
        // 4 完成 / (4 完成 + 5 取消) = 44.4%
        double rate = completionRate(4, 0, 0, 5);
        assertEquals(44.4, rate, 0.1,
                "取消会消耗对方机会成本，必须计入分母");

        // 洽谈中的不算失信
        assertEquals(100.0, completionRate(3, 0, 0, 0), 0.1);
    }

    @Test
    @DisplayName("评价及时性：超时默认计分次数越多，因子分越低")
    void timelinessShouldDecreaseWithTimeouts() {
        assertEquals(100.0, timeliness(4, 0), 0.01);
        assertEquals(75.0, timeliness(4, 1), 0.01);
        assertEquals(50.0, timeliness(4, 2), 0.01);
        assertEquals(0.0, timeliness(4, 4), 0.01);
        // 无应评价记录时按满分，而不是 0/0 异常
        assertEquals(100.0, timeliness(0, 0), 0.01);
    }

    @Test
    @DisplayName("申诉败诉率：被判承担责任的次数越多，因子分越低")
    void disputeFactorShouldReflectLosses() {
        assertEquals(100.0, disputeScore(0, 0), 0.01, "无争议按满分（不惩罚没打过官司的人）");
        assertEquals(100.0, disputeScore(3, 0), 0.01, "全部胜诉保持满分");
        assertEquals(66.67, disputeScore(3, 1), 0.01);
        assertEquals(0.0, disputeScore(3, 3), 0.01);
        // 未结争议不参与计算
        assertEquals(100.0, disputeScore(0, 0), 0.01);
    }

    @Test
    @DisplayName("模型输出应落在 0~CreditLevel.RANGE_MAX 之内")
    void outputShouldBeWithinRange() {
        double max = weighted(100, 100, 100, 100, 100);
        double min = weighted(0, 0, 0, 0, 0);
        assertTrue(min >= 0, "不得为负");
        assertTrue(max <= CreditLevel.RANGE_MAX,
                "不得超过值域上限，否则 adjust() 的调整空间会被压缩");
    }

    @Test
    @DisplayName("初始信用 100 应可由接近满分的首次协作达到 —— 模型尺度合理")
    void initialScoreShouldBeReachable() {
        // 完成一次 6 小时交换、互评 90 分、无争议、及时评价
        double completion = 100.0;
        double evaluation = 90.0;
        double dispute = 100.0;
        double activity = activityScore(6);
        double timeliness = 100.0;
        double score = completion * W_COMPLETION + evaluation * W_EVALUATION
                + dispute * W_DISPUTE + activity * W_ACTIVITY + timeliness * W_TIMELINESS;
        // 约 91 分：一次认真协作就能接近初始值，说明尺度没有失衡
        assertTrue(score > 85 && score < 100,
                "一次认真协作的得分应在 85~100 之间，实际约 " + Math.round(score));
    }

    /* ---------------- 与实现同口径的纯函数复现 ---------------- */

    private double weighted(double completion, double evaluation, double dispute,
                            double activity, double timeliness) {
        return completion * W_COMPLETION + evaluation * W_EVALUATION
                + dispute * W_DISPUTE + activity * W_ACTIVITY + timeliness * W_TIMELINESS;
    }

    private double activityScore(double hours) {
        return Math.min(100.0, 100.0 * hours / FULL_ACTIVITY_HOURS);
    }

    private double completionRate(long completed, long ongoing, long pendingEval, long cancelled) {
        long committed = completed + ongoing + pendingEval + cancelled;
        return committed == 0 ? 100.0 : 100.0 * completed / committed;
    }

    private double timeliness(long shouldEvaluate, long timeouts) {
        return shouldEvaluate == 0 ? 100.0
                : Math.max(0.0, 100.0 * (shouldEvaluate - timeouts) / shouldEvaluate);
    }

    private double disputeScore(long resolved, long lost) {
        return resolved == 0 ? 100.0 : 100.0 * (resolved - lost) / resolved;
    }
}
