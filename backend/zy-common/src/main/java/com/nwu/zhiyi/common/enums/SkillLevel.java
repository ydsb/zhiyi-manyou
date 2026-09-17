package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 技能掌握等级 / 画像来源。
 *
 * @author 李泽宬
 */
@Getter
public enum SkillLevel {

    /** 了解 */
    L1(1, "了解"),

    /** 入门 */
    L2(2, "入门"),

    /** 熟练 */
    L3(3, "熟练"),

    /** 精通 */
    L4(4, "精通"),

    /** 可教学 */
    L5(5, "可教学");

    private final int level;
    private final String label;

    SkillLevel(int level, String label) {
        this.level = level;
        this.label = label;
    }

    public static SkillLevel of(int level) {
        for (SkillLevel value : values()) {
            if (value.level == level) {
                return value;
            }
        }
        return L1;
    }
}
