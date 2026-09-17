package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.exchange.ExchangeApplyRequest;
import com.nwu.zhiyi.api.dto.exchange.ExchangeVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.exchange.ExchangeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;

/**
 * 技能交换接口（模块 M4 的流程部分，FR-M4-04 / FR-M4-05 / FR-M4-06 / FR-M4-09）。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/exchanges")
@RequiredArgsConstructor
public class ExchangeController {

    private final ExchangeService exchangeService;

    /**
     * 对需求卡片发起交换邀约。
     *
     * <pre>POST /api/exchanges/apply</pre>
     */
    @PostMapping("/apply")
    public ApiResponse<Map<String, Object>> apply(@Valid @RequestBody ExchangeApplyRequest request) {
        return ApiResponse.success(exchangeService.apply(SecurityUtils.currentSno(), request));
    }

    /**
     * 接受交换邀约（FR-M4-05：接受后生成协作空间）。
     *
     * <pre>POST /api/exchanges/interests/{interestId}/accept</pre>
     */
    @PostMapping("/interests/{interestId}/accept")
    public ApiResponse<Map<String, Object>> accept(@PathVariable Long interestId) {
        return ApiResponse.success(exchangeService.respond(SecurityUtils.currentSno(), interestId, true, null));
    }

    /**
     * 拒绝交换邀约。
     *
     * <pre>POST /api/exchanges/interests/{interestId}/reject?reason=时间不合适</pre>
     */
    @PostMapping("/interests/{interestId}/reject")
    public ApiResponse<Map<String, Object>> reject(@PathVariable Long interestId,
                                                   @RequestParam(required = false) String reason) {
        return ApiResponse.success(exchangeService.respond(SecurityUtils.currentSno(), interestId, false, reason));
    }

    /**
     * 撤回自己发起的邀约。
     *
     * <pre>POST /api/exchanges/interests/{interestId}/withdraw</pre>
     */
    @PostMapping("/interests/{interestId}/withdraw")
    public ApiResponse<Void> withdraw(@PathVariable Long interestId) {
        exchangeService.withdraw(SecurityUtils.currentSno(), interestId);
        return ApiResponse.success("已撤回邀约", null);
    }

    /**
     * 推进交换状态（FR-M4-04 状态机）。
     *
     * <p>目标状态必须是当前状态的合法后继，由 {@code ExchangeStatus} 校验；
     * 响应中的 {@code allowedNextStatus} 已给出可用取值，前端无需硬编码。
     *
     * <pre>POST /api/exchanges/{recordId}/status?target=PENDING_EVAL&amp;actualHours=7.5</pre>
     */
    @PostMapping("/{recordId}/status")
    public ApiResponse<ExchangeVO> changeStatus(@PathVariable Long recordId,
                                                @RequestParam String target,
                                                @RequestParam(required = false) Double actualHours) {
        return ApiResponse.success("状态已更新",
                exchangeService.changeStatus(SecurityUtils.currentSno(), recordId, target, actualHours));
    }

    /**
     * 我的交换列表（FR-M4-04）。
     *
     * <pre>GET /api/exchanges?status=IN_PROGRESS</pre>
     */
    @GetMapping
    public ApiResponse<List<ExchangeVO>> myExchanges(@RequestParam(required = false) String status) {
        return ApiResponse.success(exchangeService.myExchanges(SecurityUtils.currentSno(), status));
    }

    /**
     * 交换详情（仅参与方可见）。
     *
     * <pre>GET /api/exchanges/{recordId}</pre>
     */
    @GetMapping("/{recordId}")
    public ApiResponse<ExchangeVO> detail(@PathVariable Long recordId) {
        return ApiResponse.success(exchangeService.detail(recordId, SecurityUtils.currentSno()));
    }
}
