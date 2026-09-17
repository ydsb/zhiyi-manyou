package com.nwu.zhiyi.api.dto.skill;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 技能标签树（三层：学科门类 → 二级学科 → 技能标签）。
 *
 * <p>对应需求 FR-M2-04。
 *
 * @author 李泽宬
 */
@Data
public class SkillTreeVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 一级门类总数 */
    private int categoryCount;

    /** 二级学科总数 */
    private int subCategoryCount;

    /** 技能标签总数 */
    private int skillCount;

    /** 树结构 */
    private List<CategoryNode> tree;

    /** 学科门类节点 */
    @Data
    public static class CategoryNode implements Serializable {

        private static final long serialVersionUID = 1L;

        /** 门类名称，如 工学 */
        private String name;

        /** 该门类下的标签数 */
        private int skillCount;

        /** 二级学科子节点 */
        private List<SubCategoryNode> children;
    }

    /** 二级学科节点 */
    @Data
    public static class SubCategoryNode implements Serializable {

        private static final long serialVersionUID = 1L;

        /** 二级学科名称，如 计算机科学与技术 */
        private String name;

        /** 该学科下的标签数 */
        private int skillCount;

        /** 技能标签 */
        private List<SkillVO> skills;
    }
}
