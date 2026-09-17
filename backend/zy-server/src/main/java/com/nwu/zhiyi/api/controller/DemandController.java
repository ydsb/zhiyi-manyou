package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.demand.DemandCreateRequest;
import com.nwu.zhiyi.api.dto.demand.DemandInterestVO;
import com.nwu.zhiyi.api.dto.demand.DemandQuery;
import com.nwu.zhiyi.api.dto.demand.DemandUpdateRequest;
import com.nwu.zhiyi.api.dto.demand.MarketCardVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.api.PageResult;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.demand.DemandService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.List;

/**
 * 供需集市接口（模块 M4 的卡片部分）。
 *
 * <p><b>鉴权</b>：集市浏览（{@code GET /api/demands}）匿名开放，便于未登录用户
 * 先看到平台价值；发布、修改、邀约相关接口需登录（见 SecurityConfig）。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/demands")
@RequiredArgsConstructor
public class DemandController {

    private final DemandService demandService;

    /**
     * 集市信息流（FR-M4-02 / FR-M4-03）。
     *
     * <pre>GET /api/demands?sort=MATCH&amp;categoryL1=工学&amp;onlyHighMatch=true&amp;page=1&amp;size=10</pre>
     *
     * @param query 查询条件（自动绑定）
     */
    @GetMapping
    public ApiResponse<PageResult<MarketCardVO>> feed(DemandQuery query) {
        String viewerSno = SecurityUtils.currentSnoOrNull();
        return ApiResponse.success(demandService.feed(viewerSno, query));
    }

    /**
     * 我发布的卡片。
     *
     * <pre>GET /api/demands/mine</pre>
     */
    @GetMapping("/mine")
    public ApiResponse<List<MarketCardVO>> mine() {
        return ApiResponse.success(demandService.myDemands(SecurityUtils.currentSno()));
    }

    /**
     * 我收到的交换邀约（FR-M4-05 响应侧）。
     *
     * <pre>GET /api/demands/interests/received</pre>
     */
    @GetMapping("/interests/received")
    public ApiResponse<List<DemandInterestVO>> received() {
        return ApiResponse.success(demandService.receivedInterests(SecurityUtils.currentSno()));
    }

    /**
     * 我发出的交换邀约。
     *
     * <pre>GET /api/demands/interests/sent</pre>
     */
    @GetMapping("/interests/sent")
    public ApiResponse<List<DemandInterestVO>> sent() {
        return ApiResponse.success(demandService.sentInterests(SecurityUtils.currentSno()));
    }

    /**
     * 卡片详情（含意向明细，会累加浏览量）。
     *
     * <pre>GET /api/demands/{id}</pre>
     */
    @GetMapping("/{id}")
    public ApiResponse<MarketCardVO> detail(@PathVariable Long id) {
        return ApiResponse.success(demandService.detail(id, SecurityUtils.currentSnoOrNull()));
    }

    /**
     * 发布需求卡片（FR-M4-01）。
     *
     * <pre>POST /api/demands</pre>
     */
    @PostMapping
    public ApiResponse<MarketCardVO> create(@Valid @RequestBody DemandCreateRequest request) {
        MarketCardVO card = demandService.create(SecurityUtils.currentSno(), request);
        String message = "PENDING".equals(card.getAuditStatus())
                ? "已发布，内容命中风险特征需人工复核，复核通过后出现在集市"
                : "发布成功";
        return ApiResponse.success(message, card);
    }

    /**
     * 修改卡片（仅发布人）。
     *
     * <pre>PUT /api/demands/{id}</pre>
     */
    @PutMapping("/{id}")
    public ApiResponse<MarketCardVO> update(@PathVariable Long id,
                                            @Valid @RequestBody DemandUpdateRequest request) {
        return ApiResponse.success("已更新", demandService.update(id, SecurityUtils.currentSno(), request));
    }

    /**
     * 关闭卡片（仅发布人）。
     *
     * <pre>DELETE /api/demands/{id}</pre>
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Void> close(@PathVariable Long id) {
        demandService.close(id, SecurityUtils.currentSno());
        return ApiResponse.success("已关闭该需求", null);
    }
}
