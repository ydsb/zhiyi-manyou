package com.nwu.zhiyi.common.enums;

import lombok.Getter;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 能力维度（FR-M7-02 雷达图维度）。
 *
 * <p><b>维度口径的唯一来源</b>：雷达图、成长轨迹、能力鉴定报告都从这里取维度定义。
 * 若各处自行定义，会出现"同一份数据在不同页面画出不同雷达图"，且无法解释分数来源。
 *
 * <p><b>分数怎么来（可解释性是设计目标）</b>：
 * <table border="1">
 *   <tr><th>维度</th><th>数据来源</th></tr>
 *   <tr><td>工程逻辑 / 数据分析 / 艺术审美 / 人文表达 / 经管决策 / 生命健康</td>
 *       <td>该用户参与过的技能交换、按<b>技能所属学科门类</b>归入对应维度，
 *           以其<b>互评总分</b>为质量、<b>协作时长</b>为权重做加权平均</td></tr>
 *   <tr><td>沟通协作</td>
 *       <td>直接取 M6 互评的 {@code communication} 维度分（本身就在衡量沟通）</td></tr>
 * </table>
 *
 * <p>换句话说，用户能回答"我的人文表达为什么是 86 分"——因为那是"学术论文写作"
 * 这次交换中对方给的互评分。这正是创新点 1「隐性能力 → 显性数字凭证」的要求：
 * 数字必须有出处，不能是黑箱算出来的。
 *
 * <p><b>为什么"无数据"返回 null 而不是 0</b>：0 分会被读成"能力很差"，
 * 而事实是"没有样本"。前端据此把该维度画成虚线或标注"暂无数据"，
 * 避免对用户造成误导。
 *
 * <p><b>关于维度数量（FR-M7-02 只写了五个"示例"）</b>：
 * 需求原文是「雷达图维度示例：工程逻辑、人文表达、数据分析、艺术审美、沟通协作
 * <b>（可配置）</b>」，即五个维度是示例而非上限。最初的映射表确实只覆盖了
 * 工学/理学/艺术学/文学/历史学/哲学/法学/教育学 八个门类，
 * 导致 <b>管理学、医学、经济学、农学四个门类（合计 173 个技能，占本体 22%）
 * 全部落空</b> —— 教"医学统计学"或"财务管理"的用户做完交换，
 * 雷达图上依然什么都不显示，这个缺口是静默的。
 * 因此补上 BUSINESS（经管决策）与 HEALTH（生命健康）两个维度，
 * 使 12 个门类全部可归入某个维度。
 *
 * @author 李泽宬
 */
@Getter
public enum AbilityDimension {

    /** 工程逻辑：工科门类技能 */
    ENGINEERING("engineering", "工程逻辑",
            "把想法落成可用产物、拆解并实现复杂系统的能力",
            List.of("工学")),

    /** 数据分析：理科门类技能 */
    DATA_ANALYSIS("data_analysis", "数据分析",
            "用数学与实验方法处理数据、验证结论的能力",
            List.of("理学")),

    /** 艺术审美：艺术学门类技能 */
    ARTISTIC("artistic", "艺术审美",
            "视觉、影像与呈现方式的审美判断与表达能力",
            List.of("艺术学")),

    /** 人文表达：文学等门类技能 */
    HUMANITIES("humanities", "人文表达",
            "语言组织、书面与口头表达、跨文化沟通的能力",
            List.of("文学", "历史学", "哲学", "法学", "教育学")),

    /**
     * 经管决策：管理与经济门类技能。
     *
     * <p>超出 FR-M7-02 所列五个示例维度的扩展维度，理由见类注释。
     * 图书情报与档案管理放在这里而非人文表达：它归根结底是
     * <b>信息与档案的组织管理</b>，与公共管理、工商管理同属一类问题域。
     */
    BUSINESS("business", "经管决策",
            "组织协调、资源配置与基于数据的商业判断能力",
            List.of("管理学", "经济学")),

    /**
     * 生命健康：医学与农学门类技能。
     *
     * <p>超出 FR-M7-02 所列五个示例维度的扩展维度。
     * 医学与农学共享"以实验和观察认识生命体、并据以干预"的方法论，
     * 故合为一个维度；它们既不属理工的造物逻辑，也不属人文的表达逻辑。
     */
    HEALTH("health", "生命健康",
            "认识生命现象、开展实验观察与健康干预的能力",
            List.of("医学", "农学")),

    /**
     * 沟通协作：来自互评的 communication 维度分。
     *
     * <p>它不从学科门类推导（任何学科的交换都能体现沟通能力），
     * 而是直接取 M6 互评中「沟通效率」的分数。
     */
    COMMUNICATION("communication", "沟通协作",
            "响应速度、信息清晰度与配合度（取自互评的沟通效率维度）",
            List.of());

    /** JSON key */
    private final String key;
    /** 中文展示名 */
    private final String label;
    /** 维度说明（前端展示，帮助用户理解分数含义） */
    private final String description;
    /** 映射到本维度的学科门类（category_l1） */
    private final List<String> categories;

    AbilityDimension(String key, String label, String description, List<String> categories) {
        this.key = key;
        this.label = label;
        this.description = description;
        this.categories = categories;
    }

    /** 是否由学科门类推导（false 表示取自互评维度分） */
    public boolean isCategoryDerived() {
        return !categories.isEmpty();
    }

    /**
     * 按 JSON key 反查维度。
     *
     * @param key 维度键
     * @return 维度，无匹配返回 null
     */
    public static AbilityDimension ofKey(String key) {
        if (key == null) {
            return null;
        }
        return Arrays.stream(values())
                .filter(d -> d.key.equalsIgnoreCase(key.trim()))
                .findFirst()
                .orElse(null);
    }

    /**
     * 学科门类 → 能力维度。
     *
     * <p>未收录的门类返回 null（而非硬塞进某个维度）—— 宁可"未映射"，
     * 也不要给出没有依据的分数。管理员可通过 {@code /api/admin/skills} 补充门类，
     * 届时在此扩展即可。
     *
     * @param categoryL1 学科门类，如「工学」
     * @return 对应维度，未映射返回 null
     */
    public static AbilityDimension ofCategory(String categoryL1) {
        if (categoryL1 == null || categoryL1.isBlank()) {
            return null;
        }
        String c = categoryL1.trim();
        return Arrays.stream(values())
                .filter(d -> d.categories.contains(c))
                .findFirst()
                .orElse(null);
    }

    /**
     * 维度键 → 中文名（批量转换，用于报告排版）。
     *
     * @return 有序映射
     */
    public static Map<String, String> labelTable() {
        Map<String, String> table = new LinkedHashMap<>();
        for (AbilityDimension d : values()) {
            table.put(d.key, d.label);
        }
        return table;
    }

    /** 已收录的全部学科门类（供前端与文档展示映射关系） */
    public static List<String> mappedCategories() {
        return Arrays.stream(values())
                .flatMap(d -> d.categories.stream())
                .distinct()
                .toList();
    }
}
