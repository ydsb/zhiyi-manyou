package com.nwu.zhiyi.api.dto.collab;

import lombok.Data;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 新增协作任务项请求（FR-M5-02 阶段性任务拆解）。
 *
 * @author 李泽宬
 */
@Data
public class TaskCreateRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotBlank(message = "任务标题不能为空")
    @Size(max = 200, message = "任务标题不能超过 200 字")
    private String title;

    @Size(max = 500, message = "任务说明不能超过 500 字")
    private String description;

    /**
     * 负责人学号。必须是本次交换的参与方之一。
     * 留空表示"双方共同负责"，此时不计入个人按期率。
     */
    private String assigneeSno;

    /** 截止时间，格式 yyyy-MM-dd HH:mm:ss */
    private String deadline;

    @Min(value = 1, message = "优先级最小为 1")
    @Max(value = 5, message = "优先级最大为 5")
    private Integer sortOrder;
}
