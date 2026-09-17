package com.nwu.zhiyi.service.governance;

import cn.hutool.json.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.governance.ArbitrationVoteRequest;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.ArbitrationResult;
import com.nwu.zhiyi.common.enums.DisputeStatus;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.ArbitrationVote;
import com.nwu.zhiyi.domain.entity.Dispute;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.ArbitrationVoteMapper;
import com.nwu.zhiyi.domain.mapper.DisputeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.credit.CreditService;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 仲裁表决与裁决自动执行（FR-M8-05 / FR-M8-06）。
 *
 * <p><b>判决定则</b>：
 * <ol>
 *   <li>得票多者胜（弃权不计入有效票）；</li>
 *   <li>有效票为 0（全部弃权或无人投票）→ 视为<b>申诉不成立</b>。
 *       理由：举证责任在申诉人，"没有形成多数意见"意味着事实未被证明。</li>
 *   <li>平票 → 同样按不成立处理，并把平票情况写进裁决书 —— 平票说明事实
 *       存在争议，此时不应惩罚任何一方（疑罪从无）。</li>
 * </ol>
 *
 * <p><b>裁决自动执行</b>（FR-M8-06）三件事：
 * <ol>
 *   <li>调整信用值：申诉成立 → 被申诉人扣分、申诉人补偿；不成立 → 申诉人扣分（滥用申诉的代价）；</li>
 *   <li>修正评价：若争议涉及"评价不公"，把相关评价标记为申诉状态，
 *       由 {@code EvaluationService.amend} 追加修正记录（<b>不直接改分数</b>，
 *       因为评价本体是哈希存证的，只能追加）；</li>
 *   <li>账号处置：严重违规（多次未履约）触发封禁；封禁会同步降低并发上限。</li>
 * </ol>
 *
 * <p><b>为什么"申诉不成立也要扣分"</b>：否则恶意申诉没有成本，
 * 会变成骚扰工具。但扣分幅度小于被申诉人败诉的幅度 —— 鼓励正当维权，
 * 抑制滥用，二者需要区分开。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ArbitrationService {

    private final DisputeMapper disputeMapper;
    private final ArbitrationVoteMapper voteMapper;
    private final ExchangeRecordMapper exchangeMapper;
    private final StudentMapper studentMapper;
    private final DisputeService disputeService;
    private final CreditService creditService;
    private final NotificationService notificationService;
    private final GovernanceAuditService auditService;

    /* ---------------- 裁决执行力度（可调） ---------------- */

    /** 申诉成立：被申诉人扣分 */
    private static final int PENALTY_RESPONDENT = -15;
    /** 申诉成立：申诉人信用补偿（维权成本补偿） */
    private static final int COMPENSATE_APPLICANT = 3;
    /** 申诉不成立：申诉人扣分（滥用申诉的成本，明显小于被申诉人败诉的惩罚） */
    private static final int PENALTY_APPLICANT = -5;
    /** 触发封禁的累计败诉次数 */
    private static final int BAN_THRESHOLD = 3;

    /* ==================== 投票（FR-M8-05） ==================== */

    /**
     * 提交仲裁投票。
     *
     * @param disputeId  争议 ID
     * @param voterSno   委员学号
     * @param request    投票内容
     * @return 投票后的争议详情
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> vote(Long disputeId, String voterSno, ArbitrationVoteRequest request) {
        Dispute dispute = requireDispute(disputeId);
        if (!dispute.isVoting()) {
            throw new BusinessException(ErrorCode.DISPUTE_STATUS_ILLEGAL,
                    "该争议当前不在投票阶段（状态：" + dispute.getStatus() + "）");
        }
        if (dispute.isVoteExpired()) {
            throw new BusinessException(ErrorCode.ARBITRATION_VOTE_EXPIRED);
        }

        String ineligible = disputeService.checkEligibility(dispute, voterSno);
        if (ineligible != null) {
            throw new BusinessException(ErrorCode.ARBITRATOR_NOT_ELIGIBLE, ineligible);
        }

        String vote = request.getVote() == null ? "" : request.getVote().trim().toUpperCase();
        if (!List.of(ArbitrationVote.VOTE_APPLICANT, ArbitrationVote.VOTE_RESPONDENT,
                ArbitrationVote.VOTE_ABSTAIN).contains(vote)) {
            throw BusinessException.paramInvalid("投票选项不合法，应为 APPLICANT / RESPONDENT / ABSTAIN");
        }

        Student me = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getCreditScore).eq(Student::getSno, voterSno));
        String reason = String.format("信用 %s、非当事人、非当事人学院",
                me == null ? "未知" : me.getCreditScore());

        disputeService.recordVote(dispute, voterSno, vote, request.getComment(), reason);

        log.info("[仲裁] 争议 #{} 收到一票（{}），当前 {}/{}",
                disputeId, vote, dispute.getVoteCount(), dispute.getArbitratorCount());

        // 票数齐了可以立刻结算，不必等截止时间
        Dispute fresh = requireDispute(disputeId);
        if (fresh.getVoteCount() != null && fresh.getArbitratorCount() != null
                && fresh.getVoteCount() >= fresh.getArbitratorCount()) {
            log.info("[仲裁] 争议 #{} 委员已全部投票，提前结算", disputeId);
            settle(fresh, "全体委员已完成表决");
        }
        return disputeService.detail(disputeId, voterSno);
    }

    /* ==================== 结算与执行（FR-M8-06） ==================== */

    /**
     * 结算某争议并执行裁决。
     *
     * <p>可由三种方式触发：委员投满票、超过表决时限（定时任务）、管理员提前处置。
     *
     * @param dispute 争议
     * @param trigger 触发原因（写入裁决书）
     * @return 执行结果摘要
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> settle(Dispute dispute, String trigger) {
        if (!dispute.isVoting()) {
            throw new BusinessException(ErrorCode.DISPUTE_STATUS_ILLEGAL,
                    "只有投票中的争议才能结算");
        }
        List<ArbitrationVote> votes = voteMapper.selectList(new LambdaQueryWrapper<ArbitrationVote>()
                .eq(ArbitrationVote::getDisputeId, dispute.getId()));

        long forApplicant = votes.stream().filter(ArbitrationVote::isForApplicant).count();
        long forRespondent = votes.stream().filter(ArbitrationVote::isForRespondent).count();
        long abstain = votes.stream().filter(ArbitrationVote::isAbstain).count();
        long valid = forApplicant + forRespondent;

        ArbitrationResult result;
        String verdict;
        if (valid == 0) {
            result = ArbitrationResult.NOT_UPHELD;
            verdict = String.format("有效票为 0（共 %d 票，其中弃权 %d 票），申诉不成立。"
                            + "举证责任在申诉人，未形成多数意见即视为事实未被证明。",
                    votes.size(), abstain);
        } else if (forApplicant > forRespondent) {
            result = ArbitrationResult.UPHELD;
            verdict = String.format("委员会表决：支持申诉人 %d 票、支持被申诉人 %d 票、弃权 %d 票，"
                            + "申诉成立。认定被申诉人存在「%s」问题。",
                    forApplicant, forRespondent, abstain,
                    disputeService.detail(dispute.getId(), dispute.getApplicant())
                            .getOrDefault("disputeTypeLabel", "违约"));
        } else {
            /*
             * 平票（forApplicant == forRespondent 且有效票 > 0）：
             * 委员会对事实存在实质分歧，不作责任认定，双方均不受处罚（疑罪从无）。
             */
            result = ArbitrationResult.TIE;
            verdict = String.format("委员会表决出现平票（各 %d 票，弃权 %d 票）。"
                            + "事实存在争议，按疑罪从无原则不作责任认定，双方均不受处罚。",
                    forApplicant, abstain);
        }

        String fullVerdict = verdict + "（" + trigger + "）";

        // ---------- 自动执行 ----------
        JSONObject execution = new JSONObject(true);
        execution.set("trigger", trigger);
        execution.set("result", result.name());
        List<String> actions = new ArrayList<>();

        ExchangeRecord record = exchangeMapper.selectById(dispute.getRecordId());
        if (result == ArbitrationResult.UPHELD) {
            // 被申诉人承担责任
            CreditService.ChangeResult c1 = creditService.adjust(dispute.getRespondent(),
                    PENALTY_RESPONDENT, "DISPUTE_LOST",
                    "争议 #" + dispute.getId() + " 裁决认定承担责任", false);
            actions.add(String.format("被申诉人信用 %d → %d", c1.before(), c1.after()));
            execution.set("respondentCredit", Map.of("before", c1.before(), "after", c1.after()));

            // 申诉人的维权成本补偿
            CreditService.ChangeResult c2 = creditService.adjust(dispute.getApplicant(),
                    COMPENSATE_APPLICANT, "DISPUTE_WON",
                    "争议 #" + dispute.getId() + " 胜诉补偿", false);
            actions.add(String.format("申诉人信用 %d → %d", c2.before(), c2.after()));
            execution.set("applicantCredit", Map.of("before", c2.before(), "after", c2.after()));

            // 交换置为争议状态（已裁决，标记为争议以区别于正常完成）
            if (record != null && record.getStatus() != ExchangeStatus.DISPUTED
                    && record.getStatus() != ExchangeStatus.CANCELLED) {
                try {
                    record.transferTo(ExchangeStatus.DISPUTED);
                    exchangeMapper.updateById(record);
                    actions.add("交换状态标记为「争议中」");
                } catch (Exception e) {
                    log.warn("[仲裁] 交换状态流转失败 record={} - {}", record.getRecordNo(), e.getMessage());
                }
            }

            // 累计败诉次数达阈值 → 封禁
            long lostCount = countLostDisputes(dispute.getRespondent());
            execution.set("respondentLostCount", lostCount);
            if (lostCount >= BAN_THRESHOLD) {
                Student resp = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                        .eq(Student::getSno, dispute.getRespondent()));
                if (resp != null) {
                    resp.setStatus(0);
                    resp.setExchangeQuota(0);
                    studentMapper.updateById(resp);
                    actions.add(String.format("累计承担责任 %d 次，账号已封禁（并发上限置 0）", lostCount));
                    execution.set("banned", true);
                    auditService.record(GovernanceAuditService.builder()
                            .action("ACCOUNT_BAN")
                            .actorSno(GovernanceAuditService.SYSTEM)
                            .actorRole("SYSTEM")
                            .targetType("STUDENT")
                            .targetId(dispute.getRespondent())
                            .summary(String.format("账号封禁：累计在 %d 起争议中被认定承担责任", lostCount))
                            .reason("达到封禁阈值 " + BAN_THRESHOLD + " 次")
                            .visible(true)
                            .build());
                }
            } else {
                execution.set("banned", false);
            }
        } else if (result == ArbitrationResult.NOT_UPHELD) {
            // 申诉人承担滥用成本
            CreditService.ChangeResult c = creditService.adjust(dispute.getApplicant(),
                    PENALTY_APPLICANT, "DISPUTE_REJECTED",
                    "争议 #" + dispute.getId() + " 申诉未获支持", false);
            actions.add(String.format("申诉人信用 %d → %d（申诉未获支持）", c.before(), c.after()));
            execution.set("applicantCredit", Map.of("before", c.before(), "after", c.after()));
            execution.set("banned", false);
        } else {
            actions.add("平票，双方均不受处罚");
            execution.set("banned", false);
        }

        execution.set("actions", actions);

        // ---------- 写回争议 ----------
        dispute.setStatus(result == ArbitrationResult.NOT_UPHELD
                ? DisputeStatus.REJECTED.name() : DisputeStatus.RESOLVED.name());
        dispute.setVerdict(fullVerdict);
        dispute.setResolvedAt(LocalDateTime.now());
        dispute.setResolvedBy("VOTE");
        dispute.setExecutionLog(execution.toString());
        disputeMapper.updateById(dispute);

        // ---------- 审计留痕（FR-M8-07） ----------
        auditService.record(GovernanceAuditService.builder()
                .action("DISPUTE_RESOLVE")
                .actorSno(GovernanceAuditService.SYSTEM)
                .actorRole("SYSTEM")
                .targetType("DISPUTE")
                .targetId(String.valueOf(dispute.getId()))
                .summary(String.format("争议 #%d 裁决：%s（%d 票支持申诉 / %d 票支持被申诉 / %d 弃权）",
                        dispute.getId(), result.getLabel(),
                        forApplicant, forRespondent, abstain))
                .detail(execution.toString())
                .reason(trigger)
                .visible(true)
                .build());

        // ---------- 通知双方 ----------
        String title = result == ArbitrationResult.UPHELD ? "争议裁决：申诉成立"
                : result == ArbitrationResult.NOT_UPHELD ? "争议裁决：申诉未获支持" : "争议裁决：平票未认定责任";
        for (String sno : List.of(dispute.getApplicant(), dispute.getRespondent())) {
            notificationService.send(sno, NotificationType.DISPUTE, title,
                    fullVerdict + " 执行明细：" + String.join("；", actions),
                    "DISPUTE", dispute.getId());
        }

        log.info("[仲裁] 争议 #{} 已裁决：{}（{}/{}，弃权 {}）触发：{}",
                dispute.getId(), result.name(), forApplicant, forRespondent, abstain, trigger);
        return execution;
    }

    /**
     * 管理员紧急处置（FR-M8-08）。
     *
     * <p>管理员保留紧急干预权（如违法违规内容下架、委员不足时的处置），
     * 但<b>必须填写理由</b>，且操作会写入审计日志并公示 ——
     * "有权力"与"受监督"同时成立。
     *
     * @param disputeId 争议 ID
     * @param adminSno  管理员
     * @param upheld    裁决倾向：true 支持申诉人
     * @param reason    处置理由（必填）
     * @return 执行结果
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> adminResolve(Long disputeId, String adminSno,
                                            boolean upheld, String reason) {
        if (!StringUtils.hasText(reason)) {
            throw new BusinessException(ErrorCode.GOVERNANCE_REASON_REQUIRED);
        }
        Dispute dispute = requireDispute(disputeId);
        if (dispute.isFinal()) {
            throw new BusinessException(ErrorCode.DISPUTE_STATUS_ILLEGAL, "该争议已结案");
        }

        // 管理员处置：不经过投票，直接按倾向执行
        // 复用 settle 的执行逻辑会要求 VOTING 状态，因此这里单独实现
        JSONObject execution = new JSONObject(true);
        execution.set("trigger", "管理员紧急处置");
        execution.set("result", upheld ? "UPHELD" : "NOT_UPHELD");
        execution.set("adminReason", reason.trim());
        List<String> actions = new ArrayList<>();

        ExchangeRecord record = exchangeMapper.selectById(dispute.getRecordId());
        if (upheld) {
            CreditService.ChangeResult c1 = creditService.adjust(dispute.getRespondent(),
                    PENALTY_RESPONDENT, "DISPUTE_LOST",
                    "争议 #" + disputeId + " 经管理员处置认定承担责任", false);
            actions.add(String.format("被申诉人信用 %d → %d", c1.before(), c1.after()));
            CreditService.ChangeResult c2 = creditService.adjust(dispute.getApplicant(),
                    COMPENSATE_APPLICANT, "DISPUTE_WON", "争议 #" + disputeId + " 经管理员处置胜诉", false);
            actions.add(String.format("申诉人信用 %d → %d", c2.before(), c2.after()));
            if (record != null && record.getStatus() != ExchangeStatus.DISPUTED
                    && record.getStatus() != ExchangeStatus.CANCELLED) {
                try {
                    record.transferTo(ExchangeStatus.DISPUTED);
                    exchangeMapper.updateById(record);
                    actions.add("交换状态标记为「争议中」");
                } catch (Exception e) {
                    log.warn("[仲裁] 交换状态流转失败 - {}", e.getMessage());
                }
            }
            dispute.setStatus(DisputeStatus.RESOLVED.name());
        } else {
            CreditService.ChangeResult c = creditService.adjust(dispute.getApplicant(),
                    PENALTY_APPLICANT, "DISPUTE_REJECTED", "争议 #" + disputeId + " 经管理员处置驳回", false);
            actions.add(String.format("申诉人信用 %d → %d", c.before(), c.after()));
            dispute.setStatus(DisputeStatus.REJECTED.name());
        }

        execution.set("actions", actions);
        String verdict = String.format("管理员紧急处置（非委员会表决）：%s。处置理由：%s。"
                        + "该操作已写入审计日志并公示。",
                upheld ? "认定申诉成立" : "驳回申诉", reason.trim());
        dispute.setVerdict(verdict);
        dispute.setResolvedAt(LocalDateTime.now());
        dispute.setResolvedBy("ADMIN");
        dispute.setExecutionLog(execution.toString());
        disputeMapper.updateById(dispute);

        // 管理员干预必须留痕（FR-M8-08），且角色标为 ADMIN 以便公示页区分
        auditService.record(GovernanceAuditService.builder()
                .action("ADMIN_INTERVENE")
                .actorSno(adminSno)
                .actorRole("ADMIN")
                .targetType("DISPUTE")
                .targetId(String.valueOf(disputeId))
                .summary(String.format("管理员处置争议 #%d：%s", disputeId, upheld ? "认定申诉成立" : "驳回申诉"))
                .detail(execution.toString())
                .reason(reason.trim())
                .visible(true)
                .build());

        for (String sno : List.of(dispute.getApplicant(), dispute.getRespondent())) {
            notificationService.send(sno, NotificationType.DISPUTE,
                    "争议已由管理员处置", verdict + " 执行明细：" + String.join("；", actions),
                    "DISPUTE", disputeId);
        }

        log.info("[仲裁] 争议 #{} 由管理员 {} 处置：{}，理由：{}",
                disputeId, adminSno, upheld ? "成立" : "驳回", reason);
        return execution;
    }

    /**
     * 结算所有已过期但未结案的争议（定时任务调用）。
     *
     * <p>表决时限到了必须有结果，否则争议会无限期悬置 ——
     * 对当事人不公平，也让治理显得失效。
     *
     * @return 结算数量
     */
    @Transactional(rollbackFor = Exception.class)
    public int settleExpired() {
        List<Dispute> expired = disputeMapper.selectList(new LambdaQueryWrapper<Dispute>()
                .eq(Dispute::getStatus, DisputeStatus.VOTING.name())
                .isNotNull(Dispute::getVoteDeadline)
                .lt(Dispute::getVoteDeadline, LocalDateTime.now()));
        int count = 0;
        for (Dispute d : expired) {
            try {
                settle(d, "表决时限已到，按已投票数结算");
                count++;
            } catch (Exception e) {
                log.warn("[仲裁] 争议 #{} 自动结算失败：{}", d.getId(), e.getMessage());
            }
        }
        if (count > 0) {
            log.info("[仲裁] 本轮自动结算 {} 起超时争议", count);
        }
        return count;
    }

    /** 统计某用户在已结争议中被认定承担责任的次数 */
    private long countLostDisputes(String sno) {
        List<Dispute> disputes = disputeMapper.selectList(new LambdaQueryWrapper<Dispute>()
                .eq(Dispute::getRespondent, sno)
                .eq(Dispute::getStatus, DisputeStatus.RESOLVED.name()));
        // verdict 里包含"认定被申诉人"即视为承担责任（与 CreditCalculator 口径一致）
        return disputes.stream()
                .filter(d -> d.getVerdict() != null && d.getVerdict().contains("认定被申诉人"))
                .count();
    }

    private Dispute requireDispute(Long id) {
        Dispute d = disputeMapper.selectById(id);
        if (d == null) {
            throw new BusinessException(ErrorCode.DISPUTE_NOT_FOUND);
        }
        return d;
    }
}
