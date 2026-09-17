package com.nwu.zhiyi.api.dto.skill;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 非结构化文本解析请求（FR-M2-02）。
 *
 * @author 李泽宬
 */
@Data
public class SkillParseRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 用户输入的自然语言描述，如"我需要会做动态交互效果的同学" */
    @NotBlank(message = "解析文本不能为空")
    @Size(max = 1000, message = "解析文本长度不能超过 1000 字")
    private String text;

    /** 返回的最大标签数，默认 10，上限 50 */
    private Integer limit;

    /** 是否通过知识图谱补充隐性关联标签（默认 true） */
    private Boolean withGraph;
}
