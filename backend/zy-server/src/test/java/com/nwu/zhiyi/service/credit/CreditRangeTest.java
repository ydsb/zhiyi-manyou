package com.nwu.zhiyi.service.credit;

import com.nwu.zhiyi.common.enums.CreditLevel;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 信用值域与等级阈值的自洽性测试。
 *
 * <p><b>本测试锁定一个真实缺陷</b>：早期 {@code CreditService.adjust()} 把信用值
 * 钳在 0~100，而等级表定义了「优秀 140~179」「卓越 180+」——
 * 用户信用 150（优秀）被裁决扣 15 分时，结果被钳成 100 而不是 135，
 * <b>惩罚被吞掉 35 分</b>；同理"补偿 +3"在 100 封顶时完全丢失。
 *
 * <p>根因是"值域上限"与"等级阈值"两处约束没对齐。这类问题不会抛异常，
 * 只会静默算错，因此必须有测试守住。
 *
 * @author 李泽宬
 */
@DisplayName("M8 - 信用值域与等级阈值自洽性")
class CreditRangeTest {

    @Test
    @DisplayName("信用值上限必须高于最高等级阈值，否则高档等级永远无法达到")
    void rangeMaxMustExceedTopLevelThreshold() {
        int topThreshold = CreditLevel.OUTSTANDING.getMinScore();
        assertTrue(CreditLevel.RANGE_MAX > topThreshold,
                String.format("RANGE_MAX(%d) 必须大于「卓越」档起点(%d)，否则该等级不可达",
                        CreditLevel.RANGE_MAX, topThreshold));
    }

    @Test
    @DisplayName("信用值上限必须能容纳「优秀」档，否则该等级不可达")
    void rangeMaxMustCoverExcellentLevel() {
        assertTrue(CreditLevel.RANGE_MAX >= CreditLevel.EXCELLENT.getMaxScore(),
                String.format("RANGE_MAX(%d) 必须 >= 「优秀」档上界(%d)",
                        CreditLevel.RANGE_MAX, CreditLevel.EXCELLENT.getMaxScore()));
    }

    @Test
    @DisplayName("重放缺陷场景：150 分扣 15 分必须得 135，不能被钳成 100")
    void penaltyMustNotBeSwallowedByClamping() {
        int before = 150;
        int delta = -15;
        int after = Math.max(0, Math.min(CreditLevel.RANGE_MAX, before + delta));
        assertEquals(135, after,
                "扣分被静默钳掉是最危险的缺陷类型 —— 不抛异常，只是算错");
    }

    @Test
    @DisplayName("重放缺陷场景：100 分补偿 +3 必须生效，不能被封顶丢弃")
    void compensationMustNotBeDiscardedAtCap() {
        int before = 100;
        int delta = 3;
        int after = Math.max(0, Math.min(CreditLevel.RANGE_MAX, before + delta));
        assertEquals(103, after, "补偿被封顶丢弃会让维权方得不到应有回报");
    }

    @Test
    @DisplayName("下界仍为 0，不允许负信用")
    void shouldNotAllowNegativeCredit() {
        int after = Math.max(0, Math.min(CreditLevel.RANGE_MAX, 20 - 100));
        assertEquals(0, after);
    }

    @Test
    @DisplayName("上界仍然存在，防止无限叠加")
    void shouldStillCapAtMax() {
        int after = Math.max(0, Math.min(CreditLevel.RANGE_MAX, 195 + 50));
        assertEquals(CreditLevel.RANGE_MAX, after);
    }

    @Test
    @DisplayName("等级表覆盖 0 到 RANGE_MAX 整个值域，不留空洞")
    void levelsShouldCoverWholeRange() {
        assertEquals(CreditLevel.RESTRICTED, CreditLevel.of(0), "下界应落在最低档");
        assertEquals(CreditLevel.OUTSTANDING, CreditLevel.of(CreditLevel.RANGE_MAX),
                "上界应落在最高档");
        // 逐档验证能覆盖到
        for (CreditLevel level : CreditLevel.values()) {
            int probe = Math.min(level.getMinScore(), CreditLevel.RANGE_MAX);
            assertEquals(level, CreditLevel.of(probe),
                    level.getLabel() + " 的起点 " + probe + " 应落在本档");
        }
    }
}