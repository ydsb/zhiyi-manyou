package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 信用等级（FR-M8-02：等级关联权限）。
 *
 * <p><b>等级不只是标签，它决定实际权限</b> —— 否则信用体系就只是个好看的分数：
 * <table border="1">
 *   <tr><th>等级</th><th>分数区间</th><th>权限差异</th></tr>
 *   <tr><td>受限</td><td>0~59</td><td>并发交换降至 1，不可担任仲裁委员</td></tr>
 *   <tr><td>正常</td><td>60~99</td><td>基础权限（并发 3）</td></tr>
 *   <tr><td>良好</td><td>100~139</td><td>并发交换提升至 5</td></tr>
 *   <tr><td>优秀</td><td>140~179</td><td>并发 8，**可被抽取为仲裁委员**</td></tr>
 *   <tr><td>卓越</td><td>180+</td><td>并发 12，优先被抽取为仲裁委员</td></tr>
 * </table>
 *
 * <p><b>为什么"担任仲裁委员"要求高信用</b>：FR-M8-04 要求委员会由跨学科、高信用用户组成。
 * 让信用不良者参与裁决会直接摧毁治理公信力。因此这是一条**硬门槛**，
 * 在抽取委员时校验，而不是靠人工筛选。
 *
 * @author 李泽宬
 */
@Getter
public enum CreditLevel {

    /** 受限：存在未履约、被处罚记录 */
    RESTRICTED("受限", 0, 59, 1, false,
            "并发交换上限 1 次；不可担任仲裁委员"),

    /** 正常：新用户与履约一般者 */
    NORMAL("正常", 60, 99, 3, false,
            "基础权限，并发交换上限 3 次"),

    /** 良好：履约稳定、评价良好 */
    GOOD("良好", 100, 139, 5, false,
            "并发交换上限 5 次"),

    /** 优秀：可担任仲裁委员 */
    EXCELLENT("优秀", 140, 179, 8, true,
            "并发交换上限 8 次；**可被抽取为仲裁委员**"),

    /** 卓越：优先担任仲裁委员 */
    OUTSTANDING("卓越", 180, Integer.MAX_VALUE, 12, true,
            "并发交换上限 12 次；优先被抽取为仲裁委员");

    /**
     * 新用户初始信用值（需求 3.2 节）。
     *
     * <p>放在枚举里而不是计算器里：它是"等级体系"的一部分，
     * 且被注册流程（AuthService）与计算器共同引用，
     * 放在 zy-common 才能避免模块间反向依赖。
     */
    public static final int INIT_SCORE = 100;

    /**
     * 信用值上限。
     *
     * <p><b>必须是 200，不能是 100</b>：本枚举定义了「优秀 140~179」「卓越 180+」，
     * 而 {@code CreditCalculator} 的计算输出是 0~100 —— 如果上限也定成 100，
     * 那两档永远无法通过正常途径达到，等级表就成了摆设。
     *
     * <p>这里曾出过一个严重缺陷：{@code CreditService.adjust()} 把结果钳在 0~100，
     * 而种子数据里用户信用是 150（对应「优秀」档）。于是"扣 15 分"的裁决
     * 把 150 直接钳到 100 —— <b>惩罚被吞掉了 35 分</b>；同理"补偿 +3 分"
     * 在 100 封顶时完全丢失。
     *
     * <p>之所以是 200 而不是更高：它是"卓越"档起点（180）之上的最近整百，
     * 留出 20 分余量。计算模型输出的 0~100 是<b>基准分</b>，
     * 裁决奖励/补偿叠加上去后可能超过 100，这正是"优秀/卓越"的来源。
     */
    public static final int RANGE_MAX = 200;

    /** 中文名 */
    private final String label;
    /** 分数下限（含） */
    private final int minScore;
    /** 分数上限（含） */
    private final int maxScore;
    /** 并发交换上限 —— FR-M8-02 的权限落点 */
    private final int exchangeQuota;
    /** 是否可担任仲裁委员 */
    private final boolean eligibleArbitrator;
    /** 权限说明（公示页展示，用户能查到"我这个等级能做什么"） */
    private final String privilege;

    CreditLevel(String label, int minScore, int maxScore, int exchangeQuota,
                boolean eligibleArbitrator, String privilege) {
        this.label = label;
        this.minScore = minScore;
        this.maxScore = maxScore;
        this.exchangeQuota = exchangeQuota;
        this.eligibleArbitrator = eligibleArbitrator;
        this.privilege = privilege;
    }

    /**
     * 分数 → 等级。
     *
     * <p>边界规则：取满足 {@code minScore <= score <= maxScore} 的档位；
     * 分数为 null 或负数按最低档处理（不抛异常 —— 等级计算被很多地方调用，
     * 不能因为脏数据让整个请求失败）。
     *
     * @param score 信用值
     * @return 等级
     */
    public static CreditLevel of(Integer score) {
        int v = score == null ? 0 : score;
        for (CreditLevel level : values()) {
            if (v >= level.minScore && v <= level.maxScore) {
                return level;
            }
        }
        // 负数或超出范围：按最低/最高档兜底
        return v < 0 ? RESTRICTED : OUTSTANDING;
    }

    /**
     * 等级序号（0 起），用于代码内部的比较与排序。
     *
     * <p><b>不要用它写库</b> —— 数据库 {@code zy_student.credit_level} 的约定是 1~5。
     *
     * @return 序号
     */
    public int levelIndex() {
        return ordinal();
    }

    /**
     * 落库用的等级编号（<b>1~5</b>，与 DDL 注释 {@code COMMENT '信用等级 1~5'} 一致）。
     *
     * <p>这里曾出过不一致：{@code CreditService} 写 {@code ordinal()}（0~4），
     * 而 {@code AuthService} 注册时写死 1，DDL 注释又声称 1~5，
     * 三处对"等级怎么存"的理解不同，导致库中出现 {@code credit_level = 0}
     * 这种非法值。现在统一收敛到本方法。
     *
     * @return 1~5
     */
    public int levelCode() {
        return ordinal() + 1;
    }

    /**
     * 由落库的等级编号还原枚举。
     *
     * @param code 1~5；越界时按 {@link #of(Integer)} 的方式兜底
     * @return 等级
     */
    public static CreditLevel ofCode(Integer code) {
        if (code == null) {
            return NORMAL;
        }
        int idx = code - 1;
        CreditLevel[] all = values();
        if (idx < 0 || idx >= all.length) {
            return NORMAL;
        }
        return all[idx];
    }

    /**
     * 等级是否高于另一个等级。
     *
     * @param other 另一等级
     * @return 高于返回 true
     */
    public boolean isHigherThan(CreditLevel other) {
        return other != null && this.ordinal() > other.ordinal();
    }
}
