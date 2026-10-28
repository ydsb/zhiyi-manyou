package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.common.enums.DemandVisibility;
import com.nwu.zhiyi.domain.entity.Demand;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@DisplayName("M4 - 需求卡片内容指纹")
class DemandFingerprintTest {

    private static final LocalDateTime EXPIRE_AT = LocalDateTime.of(2026, 11, 1, 18, 0, 0);

    @Test
    @DisplayName("空白和 null 归一化后指纹一致")
    void shouldNormalizeBlankTextAndNull() {
        String first = DemandFingerprint.of("  后端辅导  ", null, 12L, null, 8,
                " ", DemandVisibility.PUBLIC, EXPIRE_AT);
        String second = DemandFingerprint.of("后端辅导", "", 12L, null, 8,
                "", DemandVisibility.PUBLIC, EXPIRE_AT);

        assertEquals(first, second);
        assertEquals(64, first.length());
    }

    @Test
    @DisplayName("任一可编辑业务字段变化都会改变指纹")
    void shouldChangeWhenBusinessFieldChanges() {
        String base = DemandFingerprint.of("标题", "描述", 12L, 8L, 8,
                "周末", DemandVisibility.PUBLIC, EXPIRE_AT);

        assertNotEquals(base, DemandFingerprint.of("标题2", "描述", 12L, 8L, 8,
                "周末", DemandVisibility.PUBLIC, EXPIRE_AT));
        assertNotEquals(base, DemandFingerprint.of("标题", "描述2", 12L, 8L, 8,
                "周末", DemandVisibility.PUBLIC, EXPIRE_AT));
        assertNotEquals(base, DemandFingerprint.of("标题", "描述", 12L, 8L, 9,
                "周末", DemandVisibility.PUBLIC, EXPIRE_AT));
        assertNotEquals(base, DemandFingerprint.of("标题", "描述", 12L, 8L, 8,
                "周末", DemandVisibility.COLLEGE, EXPIRE_AT));
    }

    @Test
    @DisplayName("不同技能方向和回馈技能会形成不同指纹")
    void shouldDistinguishSkillDirection() {
        String first = DemandFingerprint.of("标题", null, 12L, 8L, null,
                null, DemandVisibility.PUBLIC, null);
        String reversed = DemandFingerprint.of("标题", null, 8L, 12L, null,
                null, DemandVisibility.PUBLIC, null);

        assertNotEquals(first, reversed);
        assertTrue(first.matches("[0-9a-f]{64}"));
    }

    @Test
    @DisplayName("实体字段与标量参数生成同一指纹")
    void shouldMatchDemandEntityInputs() {
        Demand demand = new Demand()
                .setTitle("标题")
                .setDescription("描述")
                .setExpectedSkillId(12L)
                .setOfferSkillId(8L)
                .setExpectedHours(8)
                .setExpectedPeriod("周末")
                .setVisibility(DemandVisibility.PUBLIC)
                .setExpireAt(EXPIRE_AT);

        assertEquals(DemandFingerprint.of(demand),
                DemandFingerprint.of("标题", "描述", 12L, 8L, 8,
                        "周末", DemandVisibility.PUBLIC, EXPIRE_AT));
    }
}
