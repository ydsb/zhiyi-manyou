package com.nwu.zhiyi.api.dto.evaluation;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.io.Serializable;

/**
 * 互评人工复核请求（FR-M9-03 / FR-M6-03）。
 *
 * <p><b>为什么需要这个接口</b>：M6 的互刷检测会把"进入待互评后极短时间内就互相打分"
 * 这类可疑评价标为 {@code audit_status = PENDING} 并写入 {@code audit_remark}
 * （命中的风险特征）。管理端的待办徽标也把这批记录算作待处理事项。
 *
 * <p>但此前<b>只有"追加修正记录"接口（amend），它不改 audit_status</b> ——
 * 结果是待办数字永远降不下来，管理员看得到"待办 6"却没有任何入口去处置。
 * 本请求补齐这个动作：给出复核结论并把记录移出待办队列。
 *
 * <p><b>复核与修正的分工</b>：
 * <ul>
 *   <li>本接口只管"这条评价是否需要人工干预"这一判断，<b>不改分值</b>；</li>
 *   <li>若判定确实需要改分，再调用 {@code POST /api/admin/evaluations/{id}/amend}
 *       追加修正记录（保留前后分值、原因与操作人，可追溯）。</li>
 * </ul>
 * 两者刻意分开：把"定性"和"改数"混在一个接口里，会让审计日志说不清
 * 究竟是"复核后维持原分"还是"复核并调了分"。
 *
 * @author 李泽宬
 */
@Data
public class EvaluationReviewRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 复核结论：{@code PASSED} 通过（维持原评价） / {@code REJECTED} 驳回。
     *
     * <p>用 String 而非枚举：传错值时应返回本项目约定的
     * "HTTP 200 + 非零 code"（3101），而不是 Jackson 反序列化失败的 400。
     */
    @NotBlank(message = "复核结论不能为空")
    private String decision;

    /**
     * 复核说明。
     *
     * <p><b>必填</b>：这是治理透明度的要求 —— 被处置的用户有权知道依据。
     * 与 {@code ADMIN_REMARK_REQUIRED}（管理操作必须填写说明）同一口径。
     */
    @NotBlank(message = "复核说明不能为空，被处置方需要知道依据")
    @Size(max = 255, message = "复核说明不能超过 255 字")
    private String remark;
}
