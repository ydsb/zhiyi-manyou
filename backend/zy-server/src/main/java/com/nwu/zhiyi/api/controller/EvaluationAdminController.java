package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.evaluation.EvaluationAmendRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.evaluation.EvaluationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

/**
 * 互评管理接口（FR-M6-03，需 ADMIN）。
 *
 * <p>评价本体写入后禁止修改（{@code record_hash} 已封存）。当争议裁决或笔误更正
 * 需要调整分值时，通过本接口<b>追加一条修正记录</b>：保留原因、前后分值与操作人，
 * 原始存证与修正历史都会在校验接口中返回，任何人可追溯。
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
