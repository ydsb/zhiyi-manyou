package com.nwu.zhiyi.service.evaluation;

import com.nwu.zhiyi.api.dto.evaluation.EvaluationAmendRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationReviewRequest;
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
     * 待人工复核的互评列表（FR-M9-03）。
     *
     * <p>互刷检测（M6）会把可疑评价标为 {@code PENDING} 并记录命中的风险特征。
     * 本方法让管理端能看到这些记录 —— 在此之前待办徽标算得出数字，
     * 却没有任何界面能列出或处置它们，形成"有计数、无入口"的空环。
     *
     * @param status 审核状态过滤：PENDING 待复核 / PASSED 已通过 / REJECTED 已驳回；
     *               为空默认 PENDING
     * @param page   页码，从 1 开始
     * @param size   每页条数
     * @return 分页结果（含交换标题、参与人等展示所需信息）
     */
    EvaluationReviewPage listForReview(String status, int page, int size);

    /**
     * 人工复核一条互评（FR-M9-03）。
     *
     * <p>只改变"是否需要人工干预"这一判断，<b>不改分值</b> ——
     * 需要改分时另行调用 {@link #amend}，让审计日志能区分
     * "复核后维持原分"与"复核并调整分值"。
     *
     * @param evaluationId 评价 ID
     * @param operator     操作人
     * @param request      复核结论与说明
     * @return 复核后的评价视图
     */
    EvaluationVO review(Long evaluationId, String operator, EvaluationReviewRequest request);

    /**
     * 待复核互评的分页结果。
     *
     * @param records 当前页记录
     * @param total   总条数
     * @param page    当前页
     * @param size    每页条数
     */
    record EvaluationReviewPage(List<ReviewRow> records, long total, int page, int size) {
    }

    /**
     * 待复核列表的一行。
     *
     * <p>刻意做成扁平结构而不是复用 {@code EvaluationVO}：审核界面需要的是
     * "谁评价谁、什么交换、命中了什么风险、多少分"，而 {@code EvaluationVO}
     * 带有面向被评价人的匿名化与可见性处理，直接复用会把管理员也当成普通查看者，
     * 可能隐去管理所需的信息。
     *
     * @param id              评价 ID
     * @param recordId        交换记录 ID
     * @param recordNo        交换业务编号
     * @param recordTitle     协作主题
     * @param fromSno         评价人
     * @param fromName        评价人姓名
     * @param toSno           被评价人
     * @param toName          被评价人姓名
     * @param totalScore      总分
     * @param comment         评语
     * @param auditStatus     审核状态
     * @param auditRemark     命中的风险特征说明
     * @param disputeFlag     是否被申诉
     * @param timeoutFlag     是否超时默认计分
     * @param sealedAt        封存时间
     * @param integrityOk     存证校验是否通过
     */
    record ReviewRow(Long id, Long recordId, String recordNo, String recordTitle,
                     String fromSno, String fromName, String toSno, String toName,
                     java.math.BigDecimal totalScore, String comment,
                     String auditStatus, String auditRemark,
                     Integer disputeFlag, Integer timeoutFlag,
                     java.time.LocalDateTime sealedAt, Boolean integrityOk) {
    }

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
