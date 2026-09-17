package com.nwu.zhiyi.api.dto.skill;

import lombok.Data;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 技能图谱关系新增请求（管理端，FR-M9-02）。
 *
 * @author 李泽宬
 */
@Data
public class SkillRelationSaveRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotNull(message = "源技能不能为空")
    private Long srcSkillId;

    @NotNull(message = "目标技能不能为空")
    private Long dstSkillId;

    /** PREREQUISITE / COMPLEMENT / SYNONYM */
    @NotNull(message = "关系类型不能为空")
    private String relationType;

    @DecimalMin(value = "0.0", message = "关系强度不能小于 0")
    @DecimalMax(value = "1.0", message = "关系强度不能大于 1")
    private BigDecimal weight;

    @Size(max = 255, message = "备注长度不能超过 255 位")
    private String remark;
}
