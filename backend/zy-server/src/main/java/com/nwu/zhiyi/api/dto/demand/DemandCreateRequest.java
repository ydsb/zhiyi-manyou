package com.nwu.zhiyi.api.dto.demand;

import lombok.Data;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 发布技能需求卡片请求（FR-M4-01）。
 *
 * @author 李泽宬
 */
@Data
public class DemandCreateRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotBlank(message = "标题不能为空")
    @Size(max = 200, message = "标题长度不能超过 200 字")
    private String title;

    @Size(max = 2000, message = "需求详述不能超过 2000 字")
    private String description;

    /** 期望技能 ID（我急需） */
    @NotNull(message = "期望技能不能为空")
    private Long expectedSkillId;

    /** 回馈技能 ID（我可提供，以技易技的另一半） */
    private Long offerSkillId;

    @Min(value = 1, message = "预计时长至少 1 小时")
    @Max(value = 500, message = "预计时长不能超过 500 小时")
    private Integer expectedHours;

    @Size(max = 64, message = "期望时间段不能超过 64 字")
    private String expectedPeriod;

    /** 可见范围：PUBLIC / COLLEGE / PRIVATE */
    private String visibility;

    /** 期望完成时间（可选） */
    private String expireAt;
}
