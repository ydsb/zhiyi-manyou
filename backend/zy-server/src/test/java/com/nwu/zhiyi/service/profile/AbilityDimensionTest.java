package com.nwu.zhiyi.service.profile;

import com.nwu.zhiyi.common.enums.AbilityDimension;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 能力维度映射测试（FR-M7-02）。
 *
 * <p>映射关系是雷达图分数的唯一来源，一旦错位用户会看到与事实不符的画像
 * （"我明明是写代码的，为什么工程逻辑是 0 分"），因此逐条锁定。
 *
 * @author 李泽宬
 */
@DisplayName("M7 - 能力维度与学科门类映射")
class AbilityDimensionTest {

    @Test
    @DisplayName("五个维度齐全且 key 唯一")
    void shouldHaveFiveDistinctDimensions() {
        AbilityDimension[] all = AbilityDimension.values();
        assertEquals(5, all.length, "FR-M7-02 定义的雷达图维度为 5 个");

        long distinct = java.util.Arrays.stream(all).map(AbilityDimension::getKey).distinct().count();
        assertEquals(5, distinct, "维度 key 不能重复");

        long labels = java.util.Arrays.stream(all).map(AbilityDimension::getLabel).distinct().count();
        assertEquals(5, labels, "维度中文名不能重复");
    }

    @Test
    @DisplayName("学科门类应正确映射到能力维度")
    void shouldMapCategories() {
        assertEquals(AbilityDimension.ENGINEERING, AbilityDimension.ofCategory("工学"));
        assertEquals(AbilityDimension.DATA_ANALYSIS, AbilityDimension.ofCategory("理学"));
        assertEquals(AbilityDimension.ARTISTIC, AbilityDimension.ofCategory("艺术学"));
        assertEquals(AbilityDimension.HUMANITIES, AbilityDimension.ofCategory("文学"));
    }

    @Test
    @DisplayName("人文表达应覆盖多个文科门类")
    void humanitiesShouldCoverLiberalArts() {
        for (String c : List.of("文学", "历史学", "哲学", "法学", "教育学")) {
            assertEquals(AbilityDimension.HUMANITIES, AbilityDimension.ofCategory(c),
                    c + " 应映射到人文表达");
        }
    }

    @Test
    @DisplayName("未收录门类应返回 null，而不是硬塞进某个维度")
    void shouldReturnNullForUnknownCategory() {
        // 宁可"未映射"也不要给出没有依据的分数
        assertNull(AbilityDimension.ofCategory("农学"));
        assertNull(AbilityDimension.ofCategory("医学"));
        assertNull(AbilityDimension.ofCategory("未知门类"));
        assertNull(AbilityDimension.ofCategory(null));
        assertNull(AbilityDimension.ofCategory(""));
        assertNull(AbilityDimension.ofCategory("   "));
    }

    @Test
    @DisplayName("门类匹配应容忍首尾空白")
    void shouldTrimCategory() {
        assertEquals(AbilityDimension.ENGINEERING, AbilityDimension.ofCategory("  工学  "));
    }

    @Test
    @DisplayName("沟通协作不由学科门类推导，而是取自互评维度分")
    void communicationIsNotCategoryDerived() {
        assertFalse(AbilityDimension.COMMUNICATION.isCategoryDerived(),
                "沟通协作不应由学科门类推导");
        assertTrue(AbilityDimension.COMMUNICATION.getCategories().isEmpty());
        // 任何学科门类都不应映射到沟通协作
        for (String c : List.of("工学", "理学", "艺术学", "文学")) {
            assertFalse(AbilityDimension.COMMUNICATION.equals(AbilityDimension.ofCategory(c)),
                    c + " 不应映射到沟通协作");
        }
    }

    @Test
    @DisplayName("其余四个维度均由学科门类推导")
    void otherDimensionsAreCategoryDerived() {
        for (AbilityDimension d : AbilityDimension.values()) {
            if (d == AbilityDimension.COMMUNICATION) {
                continue;
            }
            assertTrue(d.isCategoryDerived(), d.getLabel() + " 应由学科门类推导");
            assertFalse(d.getCategories().isEmpty(), d.getLabel() + " 应有映射的门类");
        }
    }

    @Test
    @DisplayName("每个被收录的门类只能映射到一个维度（避免归属歧义）")
    void categoriesShouldBeExclusive() {
        List<String> seen = new java.util.ArrayList<>();
        for (AbilityDimension d : AbilityDimension.values()) {
            for (String c : d.getCategories()) {
                assertFalse(seen.contains(c),
                        "门类「" + c + "」被多个维度重复收录，会导致同一交换归入两个维度");
                seen.add(c);
            }
        }
    }

    @Test
    @DisplayName("按 key 反查维度")
    void shouldResolveByKey() {
        assertEquals(AbilityDimension.ENGINEERING, AbilityDimension.ofKey("engineering"));
        assertEquals(AbilityDimension.COMMUNICATION, AbilityDimension.ofKey("COMMUNICATION"));
        assertEquals(AbilityDimension.DATA_ANALYSIS, AbilityDimension.ofKey("  data_analysis  "));
        assertNull(AbilityDimension.ofKey("unknown"));
        assertNull(AbilityDimension.ofKey(null));
    }

    @Test
    @DisplayName("每个维度都应有说明文案（前端展示，帮助用户理解分数含义）")
    void shouldHaveDescription() {
        for (AbilityDimension d : AbilityDimension.values()) {
            assertNotNull(d.getDescription(), d.getLabel() + " 缺少说明");
            assertTrue(d.getDescription().length() >= 8,
                    d.getLabel() + " 的说明过短，不足以解释维度含义");
        }
    }

    @Test
    @DisplayName("已映射门类清单应覆盖四种学科")
    void mappedCategoriesShouldCoverDisciplines() {
        List<String> mapped = AbilityDimension.mappedCategories();
        assertTrue(mapped.contains("工学"));
        assertTrue(mapped.contains("理学"));
        assertTrue(mapped.contains("艺术学"));
        assertTrue(mapped.contains("文学"));
        assertEquals(mapped.size(), mapped.stream().distinct().count(), "门类清单不应有重复");
    }

    @Test
    @DisplayName("标签表应含全部维度")
    void labelTableShouldContainAll() {
        var table = AbilityDimension.labelTable();
        assertEquals(5, table.size());
        assertEquals("工程逻辑", table.get("engineering"));
        assertEquals("数据分析", table.get("data_analysis"));
        assertEquals("艺术审美", table.get("artistic"));
        assertEquals("人文表达", table.get("humanities"));
        assertEquals("沟通协作", table.get("communication"));
    }
}
