package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.credit.CreditService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * 信用体系接口（模块 M8，FR-M8-01 / FR-M8-02）。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/credit")
@RequiredArgsConstructor
public class CreditController {

    private final CreditService creditService;

    /**
     * 我的信用详情：当前值、等级、权限、**因子明细**与最近流水。
     *
     * <p>返回因子明细是关键 —— 用户必须能回答"我的信用为什么是这个数"，
     * 否则信用体系就只是一个让人困惑的数字。
     *
     * <pre>GET /api/credit/me</pre>
     */
    @GetMapping("/me")
    public ApiResponse<Map<String, Object>> me() {
        return ApiResponse.success(creditService.detail(SecurityUtils.currentSno()));
    }

    /**
     * 信用等级权限公示（FR-M8-07）：任何人可查"各等级能做什么"。
     *
     * <pre>GET /api/credit/levels</pre>
     */
    @GetMapping("/levels")
    public ApiResponse<List<Map<String, Object>>> levels() {
        return ApiResponse.success(creditService.levelRules());
    }
}
