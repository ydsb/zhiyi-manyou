package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.evaluation.EvaluationAmendRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationReviewRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.evaluation.EvaluationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

/**
 * 互评管理接口（FR-M6-03 / FR-M9-03，需 ADMIN）。
 *
 * <p>评价本体写入后禁止修改（{@code record_hash} 已封存）。当争议裁决或笔误更正
 * 需要调整分值时，通过 {@code /amend} 追加一条修正记录：保留原因、前后分值与操作人，
 * 原始存证与修正历史都会在校验接口中返回，任何人可追溯。
 *
 * <p>{@code /pending} 与 {@code /{id}/review} 负责<b>人工复核队列</b>：
 * 互刷检测会把可疑评价标为 {@code PENDING} 并记下命中的风险特征，
 * 管理端需要能看到这些记录并给出结论 —— 否则待办徽标算得出数字却无处处置。
 *
 * <p>单独成类是为了让 {@code /api/admin/**} 的授权规则（需 ADMIN）自然生效，
 * 不必与其他接口混在同一路径前缀下。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/admin/evaluations")
@RequiredArgsConstructor
public class EvaluationAdminController {

    private final EvaluationService evaluationService;

    /**
     * 待人工复核的互评列表（FR-M9-03）。
     *
     * <pre>GET /api/admin/evaluations/pending?status=PENDING&amp;page=1&amp;size=20</pre>
     *
     * @param status 审核状态，默认 PENDING（待复核）
     * @param page   页码，从 1 开始
     * @param size   每页条数
     */
    @GetMapping("/pending")
    public ApiResponse<EvaluationService.EvaluationReviewPage> pending(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(evaluationService.listForReview(status, page, size));
    }

    /**
     * 人工复核一条互评（FR-M9-03）。
     *
     * <p>只改"是否需要人工干预"的判断，不改分值；需要改分时另行调用
     * {@code /amend}，使审计日志能区分"复核后维持原分"与"复核并调整分值"。
     *
     * <pre>POST /api/admin/evaluations/{id}/review</pre>
     */
    @PostMapping("/{id}/review")
    public ApiResponse<EvaluationVO> review(@PathVariable Long id,
                                            @Valid @RequestBody EvaluationReviewRequest request) {
        String decision = request.getDecision().trim().toUpperCase();
        String message = "PASSED".equals(decision) ? "已通过复核，该互评计入画像与信用" : "已驳回该互评";
        return ApiResponse.success(message,
                evaluationService.review(id, SecurityUtils.currentSno(), request));
    }

    /**
     * 追加互评修正记录。
     *
     * <pre>POST /api/admin/evaluations/{id}/amend</pre>
     *
     * @param id      评价记录 ID
     * @param request 修正原因与（可选的）修正后总分
     */
    @PostMapping("/{id}/amend")
    public ApiResponse<EvaluationVO> amend(@PathVariable Long id,
                                           @Valid @RequestBody EvaluationAmendRequest request) {
        return ApiResponse.success("修正记录已追加",
                evaluationService.amend(id, SecurityUtils.currentSno(), request));
    }
}
