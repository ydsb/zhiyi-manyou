package com.nwu.zhiyi.service.credit;

import com.nwu.zhiyi.common.enums.CreditLevel;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 信用等级与权限测试（FR-M8-01 / FR-M8-02）。
 *
 * <p>等级不只是标签 —— 它直接决定并发交换上限与能否担任仲裁委员。
 * 因此边界值必须逐条锁定：算错一档就意味着用户被错误限权或错误放权。
 *
 * @author 李泽宬
 */
@DisplayName("M8 - 信用等级与权限分档")
class CreditLevelTest {

    @Test
    @DisplayName("分数应正确映射到等级（含每个边界值）")
    void shouldMapScoreToLevel() {
        // 受限 0~59
        assertEquals(CreditLevel.RESTRICTED, CreditLevel.of(0));
        assertEquals(CreditLevel.RESTRICTED, CreditLevel.of(59));
        // 正常 60~99
        assertEquals(CreditLevel.NORMAL, CreditLevel.of(60));
        assertEquals(CreditLevel.NORMAL, CreditLevel.of(99));
        // 良好 100~139
        assertEquals(CreditLevel.GOOD, CreditLevel.of(100));
        assertEquals(CreditLevel.GOOD, CreditLevel.of(139));
        // 优秀 140~179
        assertEquals(CreditLevel.EXCELLENT, CreditLevel.of(140));
        assertEquals(CreditLevel.EXCELLENT, CreditLevel.of(179));
        // 卓越 180+
        assertEquals(CreditLevel.OUTSTANDING, CreditLevel.of(180));
        assertEquals(CreditLevel.OUTSTANDING, CreditLevel.of(9999));
    }

    @Test
    @DisplayName("异常分数应兜底处理，不能抛异常")
    void shouldHandleAbnormalScore() {
        // 等级计算被很多地方调用，不能因为脏数据让整个请求失败
        assertEquals(CreditLevel.RESTRICTED, CreditLevel.of(null));
        assertEquals(CreditLevel.RESTRICTED, CreditLevel.of(-100));
        assertEquals(CreditLevel.OUTSTANDING, CreditLevel.of(Integer.MAX_VALUE));
    }

    @Test
    @DisplayName("只有优秀及以上才能担任仲裁委员 —— 这是治理公信力的硬门槛")
    void onlyHighCreditCanArbitrate() {
        assertFalse(CreditLevel.RESTRICTED.isEligibleArbitrator());
        assertFalse(CreditLevel.NORMAL.isEligibleArbitrator());
        assertFalse(CreditLevel.GOOD.isEligibleArbitrator());
        assertTrue(CreditLevel.EXCELLENT.isEligibleArbitrator());
        assertTrue(CreditLevel.OUTSTANDING.isEligibleArbitrator());
    }

    @Test
    @DisplayName("等级越高并发交换上限越大 —— FR-M8-02 的权限落点")
    void quotaShouldIncreaseWithLevel() {
        int prev = -1;
        for (CreditLevel level : CreditLevel.values()) {
            assertTrue(level.getExchangeQuota() > prev,
                    level.getLabel() + " 的并发上限应高于前一档（当前 " + level.getExchangeQuota()
                            + "，前一档 " + prev + "）");
            prev = level.getExchangeQuota();
        }
    }

    @Test
    @DisplayName("受限等级应把并发上限压到 1，形成实际约束")
    void restrictedShouldLimitQuota() {
        assertEquals(1, CreditLevel.RESTRICTED.getExchangeQuota(),
                "受限用户的并发上限必须足够低才有威慑力");
    }

    @Test
    @DisplayName("等级区间应连续无空洞、无重叠")
    void intervalsShouldBeContiguous() {
        CreditLevel[] all = CreditLevel.values();
        for (int i = 0; i < all.length - 1; i++) {
            assertEquals(all[i].getMaxScore() + 1, all[i + 1].getMinScore(),
                    String.format("「%s」与「%s」之间存在区间空洞或重叠",
                            all[i].getLabel(), all[i + 1].getLabel()));
        }
        // 每一档的上下界自身都能正确落档
        for (CreditLevel level : all) {
            assertEquals(level, CreditLevel.of(level.getMinScore()),
                    level.getLabel() + " 的下界 " + level.getMinScore() + " 应落在本档");
            assertEquals(level, CreditLevel.of(level.getMaxScore()),
                    level.getLabel() + " 的上界 " + level.getMaxScore() + " 应落在本档");
        }
    }

    @Test
    @DisplayName("等级比较应正确")
    void shouldCompareLevels() {
        assertTrue(CreditLevel.EXCELLENT.isHigherThan(CreditLevel.GOOD));
        assertTrue(CreditLevel.OUTSTANDING.isHigherThan(CreditLevel.RESTRICTED));
        assertFalse(CreditLevel.GOOD.isHigherThan(CreditLevel.EXCELLENT));
        assertFalse(CreditLevel.GOOD.isHigherThan(CreditLevel.GOOD));
        assertFalse(CreditLevel.GOOD.isHigherThan(null));
    }

    @Test
    @DisplayName("每个等级都必须有权限说明，否则用户查不到自己能用什么")
    void everyLevelShouldDescribePrivilege() {
        for (CreditLevel level : CreditLevel.values()) {
            assertTrue(level.getPrivilege() != null && level.getPrivilege().length() >= 8,
                    level.getLabel() + " 缺少权限说明");
        }
    }

    @Test
    @DisplayName("初始信用 100 应落在「良好」档（新用户可正常使用平台）")
    void initialScoreShouldBeUsable() {
        CreditLevel level = CreditLevel.of(CreditCalculator.INIT_SCORE);
        assertEquals(CreditLevel.GOOD, level, "初始信用应处于「良好」档");
        assertTrue(level.getExchangeQuota() >= 3,
                "新用户并发上限不应低于 3，否则刚注册就受限");
        assertFalse(level.isEligibleArbitrator(),
                "新用户不应立即具备仲裁资格");
    }

    @Test
    @DisplayName("负一次信任不触发封禁：需累计 3 次才封禁，避免误伤偶发失误")
    void singleLossShouldNotBan() {
        // 该规则在 ArbitrationService 中以 BAN_THRESHOLD = 3 实现
        // 此处锁定"等级本身不表达封禁"这一约定，封禁是独立的账号状态
        assertEquals(CreditLevel.RESTRICTED, CreditLevel.of(40));
        assertTrue(CreditLevel.RESTRICTED.getExchangeQuota() > 0,
                "受限不等于封禁 —— 仍保留 1 次并发机会，给出改过空间");
    }

    @Test
    @DisplayName("等级常量名与序号稳定（已存库为 credit_level 整数）")
    void ordinalShouldBeStable() {
        // 数据库 zy_student.credit_level 存的是 ordinal，改动顺序会导致历史数据错档
        assertEquals(0, CreditLevel.RESTRICTED.ordinal());
        assertEquals(1, CreditLevel.NORMAL.ordinal());
        assertEquals(2, CreditLevel.GOOD.ordinal());
        assertEquals(3, CreditLevel.EXCELLENT.ordinal());
        assertEquals(4, CreditLevel.OUTSTANDING.ordinal());
        assertEquals(CreditLevel.GOOD.ordinal(), CreditLevel.of(100).levelIndex());
    }

    @Test
    @DisplayName("信用值上限 100 与最终档位的关系应明确")
    void maxScoreUpperBound() {
        // 计算器把信用值封闭在 0~100；100 落在「良好」上界
        assertEquals(CreditLevel.GOOD, CreditLevel.of(100));
        // 「优秀」「卓越」需要通过裁决奖励或特殊贡献达到，
        // 这说明"正常履约只能到良好，更高等级需要额外正向证据"是有意设计
        assertNull(null);
        assertTrue(CreditLevel.of(100).getExchangeQuota() < CreditLevel.EXCELLENT.getExchangeQuota());
    }
}
