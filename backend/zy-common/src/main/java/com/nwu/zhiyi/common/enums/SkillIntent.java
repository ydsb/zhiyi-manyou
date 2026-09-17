package com.nwu.zhiyi.common.enums;

import lombok.Getter;

/**
 * 用户技能意图 —— 对应新手导引的三类标签选择。
 *
 * @author 李泽宬
 */
@Getter
public enum SkillIntent {

    /** 我擅长…（技能供给方） */
    SKILLED("我擅长"),

    /** 我正在研究…（在学/在研） */
    RESEARCHING("我正在研究"),

    /** 我急需…（技能需求方） */
    NEEDED("我急需");

    private final String label;

    SkillIntent(String label) {
        this.label = label;
    }
}
