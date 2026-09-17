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
    @DisplayName("维度齐全且 key / 中文名唯一")
    void shouldHaveDistinctDimensions() {
        AbilityDimension[] all = AbilityDimension.values();

        /*
         * 这里刻意**不**断言"正好 5 个"。
         *
         * FR-M7-02 的原文是「雷达图维度示例：工程逻辑、人文表达、数据分析、
         * 艺术审美、沟通协作（可配置）」—— 五个是示例而非上限。
         * 早先这个断言写成了 assertEquals(5, ...)，于是"映射表只覆盖 8 个
         * 学科门类、另有 4 个门类（173 个技能）无处可归"这个缺口
         * 就被测试固化成了"符合预期"，长期无人发现。
         *
         * 真正该守住的不变量是：key 与中文名不重复、且每个维度都有门类或被明确
         * 标注为非门类推导。维度数量本身是产品决策，不是不变量。
         */
        assertTrue(all.length >= 5,
                "FR-M7-02 至少定义了 5 个维度，当前只有 " + all.length + " 个");

        long distinct = java.util.Arrays.stream(all).map(AbilityDimension::getKey).distinct().count();
        assertEquals(all.length, distinct, "维度 key 不能重复");

        long labels = java.util.Arrays.stream(all).map(AbilityDimension::getLabel).distinct().count();
        assertEquals(all.length, labels, "维度中文名不能重复");
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
    @DisplayName("经管决策应覆盖管理与经济门类（超出 FR-M7-02 五个示例维度的扩展）")
    void businessShouldCoverManagementAndEconomics() {
        for (String c : List.of("管理学", "经济学")) {
            assertEquals(AbilityDimension.BUSINESS, AbilityDimension.ofCategory(c),
                    c + " 应映射到经管决策");
        }
    }

    @Test
    @DisplayName("生命健康应覆盖医学与农学门类（超出 FR-M7-02 五个示例维度的扩展）")
    void healthShouldCoverMedicineAndAgriculture() {
        for (String c : List.of("医学", "农学")) {
            assertEquals(AbilityDimension.HEALTH, AbilityDimension.ofCategory(c),
                    c + " 应映射到生命健康");
        }
    }

    @Test
    @DisplayName("真正未收录的门类仍应返回 null，而不是硬塞进某个维度")
    void shouldReturnNullForUnknownCategory() {
        // 原则不变：宁可"未映射"也不要给出没有依据的分数。
        // 注意这里刻意用"不存在的门类"，而不是曾经用过的"农学/医学" ——
        // 早期这两条断言把"映射表只覆盖 8 个门类"这一缺口固化成了设计意图，
        // 导致新增的四个门类（173 个技能）长期静默落空。见下方回归测试。
        assertNull(AbilityDimension.ofCategory("未知门类"));
        assertNull(AbilityDimension.ofCategory("军事学"));
        assertNull(AbilityDimension.ofCategory(null));
        assertNull(AbilityDimension.ofCategory(""));
        assertNull(AbilityDimension.ofCategory("   "));
    }

    @Test
    @DisplayName("回归：技能本体实际使用的 12 个学科门类必须全部可映射")
    void everyCategoryInOntologyShouldBeMapped() {
        /*
         * 本测试锁定一个真实缺陷：映射表最初只覆盖 8 个门类，
         * 而 zy_skill 里实际存在 12 个。管理学、医学、经济学、农学
         * 共 173 个技能（占本体 22%）无法归入任何维度 ——
         * 用户教"医学统计学""财务管理"做完交换，雷达图上依然什么都不显示，
         * 且不会有任何报错。
         *
         * 这份清单来自 `SELECT DISTINCT category_l1 FROM zy_skill`。
         * 往本体里新增门类时，请同步扩展 AbilityDimension 的映射，
         * 否则该门类的技能会在能力画像中静默消失。
         */
        List<String> ontologyCategories = List.of(
                "工学", "理学", "艺术学", "文学", "教育学", "历史学", "法学", "哲学",
                "管理学", "经济学", "医学", "农学");
        for (String c : ontologyCategories) {
            assertNotNull(AbilityDimension.ofCategory(c),
                    "门类「" + c + "」在技能本体里存在，却没有映射到任何能力维度 —— "
                            + "该门类下的技能不会出现在能力雷达图上");
        }
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
    @DisplayName("除沟通协作外，其余维度均由学科门类推导")
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
        // 扩展维度带来的四个门类（原先落空的 173 个技能）
        assertTrue(mapped.contains("管理学"));
        assertTrue(mapped.contains("经济学"));
        assertTrue(mapped.contains("医学"));
        assertTrue(mapped.contains("农学"));
        assertEquals(mapped.size(), mapped.stream().distinct().count(), "门类清单不应有重复");
    }

    @Test
    @DisplayName("标签表应含全部维度")
    void labelTableShouldContainAll() {
        var table = AbilityDimension.labelTable();
        // 同样不断言固定数量：从枚举自身推导，避免维度增删时又要改测试
        assertEquals(AbilityDimension.values().length, table.size(),
                "标签表应覆盖全部维度");
        assertEquals("工程逻辑", table.get("engineering"));
        assertEquals("数据分析", table.get("data_analysis"));
        assertEquals("艺术审美", table.get("artistic"));
        assertEquals("人文表达", table.get("humanities"));
        assertEquals("沟通协作", table.get("communication"));
        assertEquals("经管决策", table.get("business"));
        assertEquals("生命健康", table.get("health"));
    }
}
