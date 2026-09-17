package com.nwu.zhiyi.api.dto.profile;

import com.nwu.zhiyi.api.dto.skill.SkillVO;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 * 我的技能画像视图对象（FR-M1-03 / FR-M2-02）。
 *
 * <p>按意图分成三组返回，与导引页的三步一一对应；
 * 前端据此回显用户的选择，也让「技能画像」页面能直接进入编辑态。
 *
 * <p>同时返回 {@code total} 与 {@code firstLogin}：
 * <ul>
 *   <li>{@code total == 0} 即尚未建立画像，前端应引导去导引页；</li>
 *   <li>{@code firstLogin} 与 {@code /api/auth/login} 的同名字段语义一致，
 *       供已登录用户刷新页面时判断是否仍需要导引
 *       —— 早期只有登录响应带该字段，用户刷新页面后就丢了，
 *       导致"要不要导引"的判断只能依赖前端内存状态。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Data
public class SkillProfileVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 我擅长 */
    private List<Entry> skilled;

    /** 我正在研究 */
    private List<Entry> researching;

    /** 我急需 */
    private List<Entry> needed;

    /** 画像标签总数 */
    private int total;

    /** 是否尚无任何画像（等价于 firstLogin） */
    private boolean firstLogin;

    /**
     * 画像条目：技能本体 + 该用户在此技能上的状态。
     */
    @Data
    public static class Entry implements Serializable {

        private static final long serialVersionUID = 1L;

        private SkillVO skill;

        /** 掌握等级 1~5 */
        private Integer level;

        /** 来源：SELF 自评 / PEER 互评 / COURSE 课程 */
        private String source;

        /** 画像得分（由协作与互评累积） */
        private BigDecimal score;
    }
}
