package com.nwu.zhiyi.api.dto.match;

import lombok.Data;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;
import java.util.List;

/**
 * 语义检索请求（S3 · FR-M3-02）。
 *
 * @author 李泽宬
 */
@Data
public class SemanticMatchRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 查询文本：需求标题 + 描述，或技能名 */
    @NotBlank(message = "查询文本不能为空")
    @Size(max = 500, message = "查询文本不能超过 500 字")
    private String query;

    /** 返回条数 */
    @Min(value = 1, message = "topK 至少为 1")
    @Max(value = 100, message = "topK 最多为 100")
    private Integer topK = 10;

    /** 限定类型：SKILL / DEMAND / PROFILE，为空表示不限 */
    private String kind;

    /**
     * 查询已关联的技能 id。
     *
     * <p>传入后，命中这些技能在图谱上的邻居（同义/先决/互补）会获得关系加成。
     * 这是"标签 + 图谱"的结合点：用户已勾选的标签是最强的意图信号。
     */
    private List<Integer> seedSkillIds;
}
