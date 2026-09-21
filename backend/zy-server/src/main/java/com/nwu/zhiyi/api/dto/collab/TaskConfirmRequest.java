package com.nwu.zhiyi.api.dto.collab;

import jakarta.validation.constraints.Size;
import lombok.Data;

import java.io.Serializable;

/**
 * 阶段性成果确认请求（FR-M5-08）。
 *
 * <p>需求原文：「阶段性成果支持互相同步确认，避免单方面宣称完成」。
 *
 * <p><b>为什么只有"确认"而没有"驳回"</b>：
 * 驳回需要一个明确的语义终点 —— 驳回之后任务算什么状态？退回未完成？
 * 那本质就是"撤回 + 说明"，而撤回已经由任务状态接口承担
 * （`PUT /api/workspaces/{recordId}/tasks/{taskId}` 传 `status=DOING`）。
 * 另设一个"驳回"会造出两套相似而语义重叠的操作，用户分不清该用哪个。
 *
 * <p>因此本接口只做一件事：确认。有异议时不确认，直接在协作留言里说明，
 * 或让对方把任务退回重做 —— 两条路径都已存在，且都会留存协作事件。
 *
 * @author 李泽宬
 */
@Data
public class TaskConfirmRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 确认说明，可空。
     *
     * <p>确认为"通过"语义，因此说明是选填的（无异议时不必写）。
     * 这与"管理操作必须填说明"不同：那是处置他人，必须留依据；
     * 这里是协作双方之间的正向确认，强制写说明只会让人随手填"ok"。
     * 字段保留是为了让愿意补充说明的用户有地方写。
     */
    @Size(max = 255, message = "确认说明不能超过 255 字")
    private String remark;
}
