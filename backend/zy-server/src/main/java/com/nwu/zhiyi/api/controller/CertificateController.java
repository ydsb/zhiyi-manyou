package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.evaluation.IntegrityResultVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.service.evaluation.EvaluationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 凭证验真接口（匿名开放，FR-M6-04）。
 *
 * <p>《跨学科协作能力鉴定报告》上印的校验码通过这里验真，
 * 用人单位或校内测评部门<b>无需登录</b>即可核对凭证是否真实、内容是否被改动。
 * 之所以匿名开放，是因为验真场景天然发生在平台之外（投简历、评奖材料审核）。
 *
 * <p>返回内容包含存证等级与如实的能力边界说明，不做"物理不可篡改"这类夸大表述。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/certificates")
@RequiredArgsConstructor
public class CertificateController {

    private final EvaluationService evaluationService;

    /**
     * 按校验码验真。
     *
     * <pre>GET /api/certificates/{verifyCode}</pre>
     */
    @GetMapping("/{verifyCode}")
    public ApiResponse<IntegrityResultVO> verify(@PathVariable String verifyCode) {
        return ApiResponse.success(evaluationService.verifyByCode(verifyCode));
    }
}
