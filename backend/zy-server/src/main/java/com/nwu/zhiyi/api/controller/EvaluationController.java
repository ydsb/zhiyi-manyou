package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.evaluation.EvaluationAmendRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationDimensionVO;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationStatusVO;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationSubmitRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationVO;
import com.nwu.zhiyi.api.dto.evaluation.IntegrityResultVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.enums.EvaluationDimension;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 双向互评接口（模块 M6）。
 *
 * <p>鉴权约定：
 * <ul>
 *   <li>{@code /api/certificates/**} 匿名开放 —— 校验码本身就是凭证，
 *       用人单位或校内测评部门无需登录即可验真；</li>
 *   <li>其余接口需登录，且服务层校验调用者是交换参与方；</li>
 *   <li>{@code PUT /api/admin/evaluations/{id}/amend} 需 ADMIN。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/evaluations")
@RequiredArgsConstructor
public class EvaluationController {

    private final EvaluationService evaluationService;

    /**
     * 提交互评（FR-M6-01 / FR-M6-02）。
     *
     * <pre>POST /api/evaluations</pre>
     */
    @PostMapping
    public ApiResponse<EvaluationStatusVO> submit(@Valid @RequestBody EvaluationSubmitRequest request) {
        EvaluationStatusVO status = evaluationService.submit(SecurityUtils.currentSno(), request);
        String message = Boolean.TRUE.equals(status.getBothSubmitted())
                ? "评价已提交并哈希存证；双方互评完成，交换已流转为「已完成」"
                : "评价已提交并哈希存证。对方的评分将在其提交后可见";
        return ApiResponse.success(message, status);
    }

    /**
     * 某交换的互评进度与可见评分（FR-M6-05 的可见性由服务端强制）。
     *
     * <pre>GET /api/evaluations/records/{recordId}</pre>
     */
    @GetMapping("/records/{recordId}")
    public ApiResponse<EvaluationStatusVO> status(@PathVariable Long recordId) {
        return ApiResponse.success(evaluationService.status(recordId, SecurityUtils.currentSno()));
    }

    /**
     * 我的互评列表。
     *
     * <pre>GET /api/evaluations/mine?type=SENT|RECEIVED</pre>
     */
    @GetMapping("/mine")
    public ApiResponse<List<EvaluationVO>> mine(@RequestParam(required = false) String type) {
        return ApiResponse.success(evaluationService.myEvaluations(SecurityUtils.currentSno(), type));
    }

    /**
     * 评价详情。
     *
     * <pre>GET /api/evaluations/{id}</pre>
     */
    @GetMapping("/{id}")
    public ApiResponse<EvaluationVO> detail(@PathVariable Long id) {
        return ApiResponse.success(evaluationService.detail(id, SecurityUtils.currentSno()));
    }

    /**
     * 存证校验：按交换编号校验该交换下的全部评价（FR-M6-04）。
     *
     * <pre>GET /api/evaluations/verify?recordNo=ZY202609170201</pre>
     */
    @GetMapping("/verify")
    public ApiResponse<IntegrityResultVO> verifyByRecordNo(@RequestParam String recordNo) {
        return ApiResponse.success(evaluationService.verifyByRecordNo(recordNo));
    }

    /**
     * 互评维度字典（供前端渲染打分表单，避免硬编码维度与权重）。
     *
     * <pre>GET /api/evaluations/dimensions</pre>
     */
    @GetMapping("/dimensions")
    public ApiResponse<EvaluationDimensionVO> dimensions() {
        EvaluationDimensionVO vo = new EvaluationDimensionVO();
        List<EvaluationDimensionVO.Dimension> list = new ArrayList<>();
        for (EvaluationDimension d : EvaluationDimension.values()) {
            EvaluationDimensionVO.Dimension item = new EvaluationDimensionVO.Dimension();
            item.setKey(d.getKey());
            item.setLabel(d.getLabel());
            item.setWeight(d.getWeight());
            item.setGuidance(d.getGuidance());
            item.setMaxScore(100);
            list.add(item);
        }
        vo.setDimensions(list);
        vo.setWeights(EvaluationDimension.weightTable());
        vo.setLowScoreThreshold(60.0);
        vo.setLowScoreMinComment(15);
        vo.setVisibilityRule("双方互评完成前，任何一方不可见对方评分与评语（FR-M6-05）");
        return ApiResponse.success(vo);
    }

}
