package com.nwu.zhiyi.service.exchange;

import com.nwu.zhiyi.api.dto.exchange.ExchangeApplyRequest;
import com.nwu.zhiyi.api.dto.exchange.ExchangeVO;

import java.util.List;
import java.util.Map;

/**
 * 技能交换服务（模块 M4 的流程部分）。
 *
 * <p>对应需求：
 * <ul>
 *   <li>FR-M4-04 交换状态机</li>
 *   <li>FR-M4-05 发起邀约 / 接受 / 拒绝，接受后生成专属协作空间</li>
 *   <li>FR-M4-06 以技易技的双向技能置换</li>
 *   <li>FR-M4-09 并发进行中的交换数量上限</li>
 * </ul>
 *
 * @author 李泽宬
 */
public interface ExchangeService {

    /**
     * 对需求卡片发起交换邀约（FR-M4-05）。
     *
     * @param applicantSno 申请人学号（提供技能的一方）
     * @param request      请求体
     * @return 结果，含 createdExchange 与 interest
     */
    Map<String, Object> apply(String applicantSno, ExchangeApplyRequest request);

    /**
     * 响应交换邀约：接受或拒绝（FR-M4-05）。
     *
     * @param operator    操作人（卡片发布人）
     * @param interestId  意向 ID
     * @param accept      true 接受，false 拒绝
     * @param reason      拒绝原因（可选）
     * @return 结果，accepted 时含 exchange
     */
    Map<String, Object> respond(String operator, Long interestId, boolean accept, String reason);

    /**
     * 申请人撤回邀约。
     *
     * @param applicantSno 申请人
     * @param interestId   意向 ID
     */
    void withdraw(String applicantSno, Long interestId);

    /**
     * 推进交换状态（FR-M4-04 状态机）。
     *
     * @param operator  操作人
     * @param recordId  交换记录 ID
     * @param targetStatus 目标状态名
     * @param actualHours 实际投入时长（进入待互评时可选填写）
     * @return 更新后的交换
     */
    ExchangeVO changeStatus(String operator, Long recordId, String targetStatus, Double actualHours);

    /**
     * 查询与我相关的交换（我作为供给方或需求方）。
     *
     * @param sno    学号
     * @param status 可选状态过滤
     * @return 交换列表
     */
    List<ExchangeVO> myExchanges(String sno, String status);

    /**
     * 交换详情（仅参与方可见）。
     *
     * @param recordId  记录 ID
     * @param viewerSno 查看人
     * @return 交换详情
     */
    ExchangeVO detail(Long recordId, String viewerSno);
}
