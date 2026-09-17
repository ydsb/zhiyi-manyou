package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 标准化技能标签实体 —— 对应表 {@code zy_skill}。
 *
 * <p>三层分类：{@code categoryL1}（学科门类）→ {@code categoryL2}（二级学科）→ 技能标签。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_skill")
public class Skill implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 技能标签名称（唯一） */
    private String name;

    /** 同义词/别名，逗号分隔，用于跨域术语映射 */
    private String alias;

    /** 一级门类，如 工学 / 艺术学 */
    private String categoryL1;

    /** 二级学科，如 计算机科学与技术 */
    private String categoryL2;

    private String description;

    /** 难度 1~5 */
    private Integer difficulty;

    /** 向量库（Elasticsearch）中的文档 ID */
    private String embeddingId;

    /** 热度分，用于冷启动排序 */
    private Integer hotScore;

    /** 状态：0停用 1启用 */
    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /** 判断别名中是否包含给定词（用于关键词降级匹配） */
    public boolean aliasContains(String keyword) {
        if (alias == null || keyword == null) {
            return false;
        }
        for (String item : alias.split("[,，]")) {
            if (item.trim().equalsIgnoreCase(keyword.trim())) {
                return true;
            }
        }
        return false;
    }
}
