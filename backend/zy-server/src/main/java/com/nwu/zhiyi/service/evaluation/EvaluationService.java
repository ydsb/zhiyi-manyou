package com.nwu.zhiyi.service.evaluation;

import com.nwu.zhiyi.api.dto.evaluation.EvaluationAmendRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationStatusVO;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationSubmitRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationVO;
import com.nwu.zhiyi.api.dto.evaluation.IntegrityResultVO;

import java.util.List;

/**
 * 双向互评服务（模块 M6）。
 *
 * <p>对应需求：
 * <ul>
 *   <li>FR-M6-01 待互评状态下双方须完成互评，支持匿名/实名</li>
 *   <li>FR-M6-02 维度化打分 + 文字评语</li>
 *   <li>FR-M6-03 提交后哈希固化存证，仅可追加修正记录</li>
 *   <li>FR-M6-04 存证校验（按交换编号 / 按校验码）</li>
 *   <li>FR-M6-05 双方互评完成前互相不可见评分</li>
 *   <li>FR-M6-07 互刷信用检测</li>
 * </ul>
 *
 * @author 李泽宬
 */
public interface EvaluationService {

    /**
     * 提交互评（FR-M6-01 ~ FR-M6-03、FR-M6-05、FR-M6-07）。
     *
     * @param fromSno 评价人
     * @param request 请求体
     * @return 该交换的互评进度（含本次提交结果）
     */
    EvaluationStatusVO submit(String fromSno, EvaluationSubmitRequest request);

    /**
     * 查询某交换的互评进度与可见的评分（FR-M6-05 的可见性在服务端强制）。
     *
     * @param recordId  交换记录 ID
     * @param viewerSno 查看者
     * @return 互评进度
     */
    EvaluationStatusVO status(Long recordId, String viewerSno);

    /**
     * 我的互评列表（我发出的与我收到的）。
     *
     * @param sno   学号
     * @param type  SENT 我发出的 / RECEIVED 我收到的
     * @return 评价列表
     */
    List<EvaluationVO> myEvaluations(String sno, String type);

    /**
     * 评价详情。
     *
     * @param evaluationId 评价 ID
     * @param viewerSno    查看者
     * @return 评价视图（含可见性处理与修正历史）
     */
    EvaluationVO detail(Long evaluationId, String viewerSno);

    /**
     * 追加修正记录（FR-M6-03，管理端/仲裁）。
     *
     * @param evaluationId 评价 ID
     * @param operator     操作人
     * @param request      请求体
     * @return 修正后的评价视图
     */
    EvaluationVO amend(Long evaluationId, String operator, EvaluationAmendRequest request);

    /**
     * 按交换编号校验存证（FR-M6-04）。
     *
     * @param recordNo 交换业务编号，如 ZY202609170201
     * @return 校验结果
     */
    IntegrityResultVO verifyByRecordNo(String recordNo);

    /**
     * 按校验码校验单条评价（FR-M6-04，供能力鉴定报告验真）。
     *
     * @param verifyCode 校验码
     * @return 校验结果
     */
    IntegrityResultVO verifyByCode(String verifyCode);
}
