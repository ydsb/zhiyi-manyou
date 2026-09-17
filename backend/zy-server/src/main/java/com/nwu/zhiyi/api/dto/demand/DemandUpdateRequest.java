package com.nwu.zhiyi.api.dto.demand;

import lombok.Data;

import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 更新需求卡片请求（发布人可改标题、详述、时长与可见范围）。
 *
 * @author 李泽宬
 */
@Data
public class DemandUpdateRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @Size(max = 200, message = "标题长度不能超过 200 字")
    private String title;

    @Size(max = 2000, message = "需求详述不能超过 2000 字")
    private String description;

    private Long offerSkillId;

    private Integer expectedHours;

    @Size(max = 64, message = "期望时间段不能超过 64 字")
    private String expectedPeriod;

    private String visibility;
}
