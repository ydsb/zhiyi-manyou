package com.nwu.zhiyi.api.dto.collab;

import lombok.Data;

import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 修改协作任务项请求。只传需要改的字段。
 *
 * @author 李泽宬
 */
@Data
public class TaskUpdateRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @Size(max = 200, message = "任务标题不能超过 200 字")
    private String title;

    @Size(max = 500, message = "任务说明不能超过 500 字")
    private String description;

    private String assigneeSno;

    /** 截止时间，格式 yyyy-MM-dd HH:mm:ss；传空字符串表示清除 */
    private String deadline;

    /** 目标状态：TODO / DOING / DONE */
    private String status;

    /**
     * 成果证据地址。任务完成时建议填写，作为交付质量的依据
     * （也支持先上传文件再把文件设为证据，见文件上传接口的 taskId 参数）。
     */
    @Size(max = 500, message = "证据地址不能超过 500 字")
    private String evidenceUrl;

    private Integer sortOrder;
}
