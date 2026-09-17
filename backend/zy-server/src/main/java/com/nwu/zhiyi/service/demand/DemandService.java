package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.api.dto.demand.DemandCreateRequest;
import com.nwu.zhiyi.api.dto.demand.DemandInterestVO;
import com.nwu.zhiyi.api.dto.demand.DemandQuery;
import com.nwu.zhiyi.api.dto.demand.DemandUpdateRequest;
import com.nwu.zhiyi.api.dto.demand.MarketCardVO;
import com.nwu.zhiyi.common.api.PageResult;

import java.util.List;

/**
 * 供需集市服务（模块 M4 的卡片部分）。
 *
 * <p>对应需求：FR-M4-01（发布）、FR-M4-02（信息流与筛选排序）、
 * FR-M4-03（高匹配置顶）、FR-M4-07（内容审核）、FR-M4-09（并发上限校验配合）。
 *
 * @author 李泽宬
 */
public interface DemandService {

    /**
     * 发布需求卡片（FR-M4-01）。
     *
     * @param ownerSno 发布人学号
     * @param request  请求体
     * @return 装配好的卡片
     */
    MarketCardVO create(String ownerSno, DemandCreateRequest request);

    /**
     * 集市信息流（FR-M4-02 / FR-M4-03）。
     *
     * @param viewerSno 当前登录用户（可为 null）
     * @param query     查询条件
     * @return 分页卡片
     */
    PageResult<MarketCardVO> feed(String viewerSno, DemandQuery query);

    /**
     * 卡片详情（含交换意向明细）。同时累加浏览次数。
     *
     * @param demandId  卡片 ID
     * @param viewerSno 当前用户
     * @return 卡片详情
     */
    MarketCardVO detail(Long demandId, String viewerSno);

    /**
     * 修改卡片（仅发布人）。
     *
     * @param demandId  卡片 ID
     * @param operator  操作人
     * @param request   请求体
     * @return 更新后的卡片
     */
    MarketCardVO update(Long demandId, String operator, DemandUpdateRequest request);

    /**
     * 关闭卡片（仅发布人）。
     *
     * @param demandId 卡片 ID
     * @param operator 操作人
     */
    void close(Long demandId, String operator);

    /**
     * 我发布的卡片。
     *
     * @param ownerSno 学号
     * @return 卡片列表
     */
    List<MarketCardVO> myDemands(String ownerSno);

    /**
     * 我收到的交换邀约（FR-M4-05 的响应侧）。
     *
     * @param ownerSno 卡片发布人学号
     * @return 意向列表（含卡片标题）
     */
    List<DemandInterestVO> receivedInterests(String ownerSno);

    /**
     * 我发出的交换邀约。
     *
     * @param applicantSno 申请人学号
     * @return 意向列表
     */
    List<DemandInterestVO> sentInterests(String applicantSno);

    /* ==================== 供交换服务（M4 流程侧）调用的内部方法 ====================
     * 这些方法不直接对外暴露为 REST 接口，由 ExchangeService 在同事务内调用，
     * 保证"卡片状态"与"交换状态"的一致性。放在接口上以便跨服务注入使用时
     * 不必依赖具体实现类（避免 Spring 代理类型不匹配的问题）。
     * ======================================================================== */

    /**
     * 取卡片并校验可发起交换（存在、开放、非本人发布、可见、未过期）。
     *
     * @param demandId     卡片 ID
     * @param applicantSno 申请人
     * @return 卡片实体
     */
    com.nwu.zhiyi.domain.entity.Demand requireApplicable(Long demandId, String applicantSno);

    /**
     * 校验待响应邀约数量上限（防刷单，FR-M4-07）。
     *
     * @param applicantSno 申请人
     */
    void checkPendingInterestLimit(String applicantSno);

    /**
     * 标记卡片为已匹配（交换进入进行中时调用）。
     *
     * @param demandId 卡片 ID
     */
    void markMatched(Long demandId);

    /**
     * 递增卡片的邀约数。
     *
     * @param demandId 卡片 ID
     */
    void incrementMatchCount(Long demandId);
}
