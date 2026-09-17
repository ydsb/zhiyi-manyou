package com.nwu.zhiyi.api.dto.skill;

import lombok.Data;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 技能标签新增/修改请求（管理端，FR-M9-02）。
 *
 * @author 李泽宬
 */
@Data
public class SkillSaveRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 修改时必填 */
    private Long id;

    @NotBlank(message = "技能名称不能为空")
    @Size(max = 128, message = "技能名称长度不能超过 128 位")
    private String name;

    /** 同义词/别名，逗号分隔（跨域术语映射的关键字段） */
    @Size(max = 500, message = "别名长度不能超过 500 位")
    private String alias;

    @NotBlank(message = "一级门类不能为空")
    @Size(max = 64, message = "一级门类长度不能超过 64 位")
    private String categoryL1;

    @NotBlank(message = "二级学科不能为空")
    @Size(max = 64, message = "二级学科长度不能超过 64 位")
    private String categoryL2;

    @Size(max = 500, message = "技能描述长度不能超过 500 位")
    private String description;

    @Min(value = 1, message = "难度最小为 1")
    @Max(value = 5, message = "难度最大为 5")
    private Integer difficulty;

    /** 状态：0停用 1启用 */
    private Integer status;
}
