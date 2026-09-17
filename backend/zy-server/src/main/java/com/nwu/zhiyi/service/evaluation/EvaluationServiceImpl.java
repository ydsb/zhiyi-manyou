package com.nwu.zhiyi.service.evaluation;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.collab.ProcessSummaryVO;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationAmendRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationReviewRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationStatusVO;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationSubmitRequest;
import com.nwu.zhiyi.api.dto.evaluation.EvaluationVO;
import com.nwu.zhiyi.api.dto.evaluation.IntegrityResultVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.EvidenceLevel;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.EvaluationAmendment;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.EvaluationAmendmentMapper;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.collab.WorkspaceService;
import com.nwu.zhiyi.service.exchange.ExchangeService;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 双向互评服务实现（模块 M6）。
 *
 * <p><b>可见性（FR-M6-05）的强制点</b>：不是在前端隐藏分数，而是在
 * {@link #visibilityOf} 里决定是否把 {@code dimScores/totalScore/comment}
 * 置为 null 后再返回。任何绕过前端的调用也拿不到未到期的分数。
 *
 * <p><b>完成后自动流转</b>：双方都提交后，交换从「待互评」推进到「已完成」，
 * 这样 M7 能力画像与 M8 信用计算就有明确的触发点。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EvaluationServiceImpl implements EvaluationService {

    private final EvaluationGradeMapper evaluationMapper;
    private final EvaluationAmendmentMapper amendmentMapper;
    private final ExchangeRecordMapper exchangeMapper;
    private final StudentMapper studentMapper;
    private final SkillMapper skillMapper;
    private final DimensionScoreCalculator calculator;
    private final EvaluationContentAuditor auditor;
    private final CollusionDetector collusionDetector;
    private final WorkspaceService workspaceService;
    private final NotificationService notificationService;
    private final ExchangeService exchangeService;

    /** 双方互评完成后的默认存证等级（S2 阶段仅哈希固化） */
    private static final EvidenceLevel DEFAULT_EVIDENCE = EvidenceLevel.HASH;

    /* ==================== 提交互评 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public EvaluationStatusVO submit(String fromSno, EvaluationSubmitRequest request) {
        ExchangeRecord record = exchangeMapper.selectById(request.getRecordId());
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND);
        }
        if (!record.isParticipant(fromSno)) {
            throw new BusinessException(ErrorCode.NOT_PARTICIPANT, "你不是该交换的参与方，无法评价");
        }
        if (record.getStatus() != ExchangeStatus.PENDING_EVAL) {
            throw new BusinessException(ErrorCode.EVALUATION_NOT_ALLOWED_STATUS,
                    String.format("当前状态为「%s」，只有「待互评」状态下才能提交评价",
                            record.getStatus() == null ? "未知" : record.getStatus().getLabel()));
        }

        // 被评价人 = 对方
        String toSno = record.getGiverSno().equals(fromSno) ? record.getTakerSno() : record.getGiverSno();
        if (toSno == null || toSno.equals(fromSno)) {
            throw new BusinessException(ErrorCode.EVALUATION_CANNOT_SELF);
        }

        // 幂等：同一交换同一评价人只能有一条（DDL 唯一索引兜底，这里给友好提示）
        Long exists = evaluationMapper.selectCount(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getRecordId, record.getId())
                .eq(EvaluationGrade::getFromSno, fromSno));
        if (exists != null && exists > 0) {
            throw new BusinessException(ErrorCode.EVALUATION_ALREADY_SUBMITTED);
        }

        // 维度分校验与总分计算（口径唯一）
        Map<String, Double> dimScores = calculator.normalize(request.getDimScores());
        BigDecimal totalScore = calculator.totalScore(dimScores);

        // 内容审核（低分强制说明 + 攻击性用语打标）
        EvaluationContentAuditor.Result audit = auditor.audit(request.getComment(), totalScore.doubleValue());

        // 互刷检测（FR-M6-07）：命中只打标不拦截
        LocalDateTime now = LocalDateTime.now();
        CollusionDetector.Result collusion = collusionDetector.detect(
                record, fromSno, toSno, totalScore, request.getComment(), now);

        List<String> auditRemarks = new ArrayList<>();
        if (audit.needsManualReview() && audit.remark() != null) {
            auditRemarks.add(audit.remark());
        }
        if (collusion.suspected()) {
            auditRemarks.addAll(collusion.reasons());
        }

        // 封存存证：sealedAt 是哈希时间锚点，必须显式写入（DDL 无默认值）
        EvaluationGrade grade = new EvaluationGrade()
                .setRecordId(record.getId())
                .setFromSno(fromSno)
                .setToSno(toSno)
                .setDimScores(calculator.toJson(dimScores))
                .setDimCanonical(calculator.toCanonical(dimScores))
                .setTotalScore(totalScore)
                .setComment(trimToNull(request.getComment()))
                .setAnonymous(Boolean.TRUE.equals(request.getAnonymous()) ? 1 : 0)
                .setDisputeFlag(0)
                .setTimeoutFlag(0)
                .setEvidenceLevel(DEFAULT_EVIDENCE)
                .setAuditStatus(auditRemarks.isEmpty() ? "PASSED" : "PENDING")
                .setAuditRemark(auditRemarks.isEmpty() ? null : String.join("；", auditRemarks))
                .setSealedAt(now.withNano(0));
        grade.seal();
        evaluationMapper.insert(grade);

        log.info("[互评提交] record={} {} → {} 总分={} 匿名={} 审核={}",
                record.getRecordNo(), fromSno, toSno, totalScore,
                grade.anonymousSubmission(), grade.getAuditStatus());

        // 通知被评价人（内容不含分值与评语，避免提前泄露；FR-M6-05）
        notificationService.send(toSno, NotificationType.EVAL_RECEIVED,
                "收到一条协作评价",
                "对方已完成对本次交换的评价" + (grade.anonymousSubmission() ? "（匿名）" : "")
                        + "，待你提交评价后即可互相查看",
                "EXCHANGE", record.getId());

        // 双方都提交后自动流转为「已完成」
        EvaluationStatusVO status = status(record.getId(), fromSno);
        if (Boolean.TRUE.equals(status.getBothSubmitted())) {
            completeRecord(record, fromSno);
            status = status(record.getId(), fromSno);
        }
        return status;
    }

    /**
     * 双方互评完成后把交换推进到「已完成」。
     *
     * <p>放在这里而不是定时任务里，是为了让状态变更有明确触发点 ——
     * M7 能力画像与 M8 信用计算都以「已完成」为输入。
     */
    private void completeRecord(ExchangeRecord record, String operator) {
        try {
            exchangeService.changeStatus(operator, record.getId(),
                    ExchangeStatus.COMPLETED.name(), null);
            log.info("[互评完成] record={} 双方评价齐备，交换已流转为「已完成」", record.getRecordNo());
            notificationService.sendToExchangeParties(record.getId(), null,
                    NotificationType.EVAL_REMIND, "交换已完成",
                    "双方互评已齐备，本次交换完成。可到「我的交换」查看评价与过程记录");
        } catch (Exception e) {
            // 状态流转失败不应让评价提交回滚（评价本身已经落库并存证）
            log.warn("[互评完成] 状态流转失败（评价已保存）：record={} - {}",
                    record.getRecordNo(), e.getMessage());
        }
    }

    /* ==================== 查询互评进度 ==================== */

    @Override
    public EvaluationStatusVO status(Long recordId, String viewerSno) {
        ExchangeRecord record = exchangeMapper.selectById(recordId);
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND);
        }
        boolean isParticipant = record.isParticipant(viewerSno);
        if (!isParticipant && !isAdmin(viewerSno)) {
            throw new BusinessException(ErrorCode.NOT_PARTICIPANT, "你不是该交换的参与方");
        }

        List<EvaluationGrade> grades = evaluationMapper.selectList(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getRecordId, recordId));

        EvaluationGrade mine = grades.stream()
                .filter(g -> viewerSno != null && viewerSno.equals(g.getFromSno()))
                .findFirst().orElse(null);
        EvaluationGrade peer = grades.stream()
                .filter(g -> viewerSno == null || !viewerSno.equals(g.getFromSno()))
                .findFirst().orElse(null);

        EvaluationStatusVO vo = new EvaluationStatusVO();
        vo.setRecordId(recordId);
        vo.setRecordNo(record.getRecordNo());
        vo.setTitle(record.getTitle());
        if (record.getStatus() != null) {
            vo.setStatus(record.getStatus().name());
            vo.setStatusLabel(record.getStatus().getLabel());
        }
        vo.setPendingEvalAt(record.getPendingEvalAt() == null ? null : record.getPendingEvalAt().toString());
        if (record.getPendingEvalAt() != null) {
            vo.setPendingDays(Duration.between(record.getPendingEvalAt(), LocalDateTime.now()).toDays());
        }

        String peerSno = viewerSno == null ? null
                : (record.getGiverSno().equals(viewerSno) ? record.getTakerSno() : record.getGiverSno());
        vo.setPeerSno(peerSno);
        vo.setPeerName(displayName(peerSno));
        vo.setPeerProvideSkill(skillName(record, peerSno));

        boolean mySubmitted = mine != null;
        boolean peerSubmitted = peer != null;
        vo.setMySubmitted(mySubmitted);
        vo.setPeerSubmitted(peerSubmitted);
        vo.setBothSubmitted(mySubmitted && peerSubmitted);
        vo.setCanSubmit(record.getStatus() == ExchangeStatus.PENDING_EVAL && !mySubmitted);

        // FR-M6-05：双方都提交后才互相可见；管理员为调查需要可直接查看
        boolean peerVisible = vo.getBothSubmitted() || isAdmin(viewerSno);
        vo.setPeerScoreVisible(peerVisible);

        vo.setMyEvaluation(mine == null ? null : toVO(mine, viewerSno, true));
        vo.setPeerEvaluation(peer == null ? null : toVO(peer, viewerSno, peerVisible));
        if (mine != null) {
            vo.setMyTotalScore(mine.getTotalScore());
        }
        if (peer != null && peerVisible) {
            vo.setPeerTotalScore(peer.getTotalScore());
        }

        if (!mySubmitted && record.getStatus() == ExchangeStatus.PENDING_EVAL) {
            vo.setHint("请完成你的评价。对方已提交的评价在你提交后才能看到（防报复性评价）");
        } else if (mySubmitted && !peerSubmitted) {
            vo.setHint("你已提交。对方的评分将在其提交后可见");
        } else if (vo.getBothSubmitted()) {
            vo.setHint("双方互评已完成，评价已哈希存证，任何改动都可被校验接口检出");
        }

        // 附上 M5 的客观行为语料，供互评时对照（创新点 1 的"互相印证"）
        try {
            ProcessSummaryVO summary = workspaceService.processSummary(recordId, viewerSno);
            vo.setProcessDigest(buildProcessDigest(summary));
            vo.setProcessMetrics(new ArrayList<>(summary.getParticipants()));
        } catch (Exception e) {
            log.debug("[互评] 过程指标读取失败（不影响互评）：{}", e.getMessage());
        }
        return vo;
    }

    private String buildProcessDigest(ProcessSummaryVO s) {
        if (s == null) {
            return null;
        }
        return String.format("任务 %d 项完成 %d 项，按期率 %s，留言 %d 条，交付文件 %d 个",
                nvl(s.getTaskTotal()), nvl(s.getTaskDone()),
                s.getOnTimeRate() == null ? "—" : Math.round(s.getOnTimeRate() * 100) + "%",
                nvl(s.getMessageTotal()), nvl(s.getFileGroupTotal()));
    }

    /* ==================== 我的评价列表 ==================== */

    @Override
    public List<EvaluationVO> myEvaluations(String sno, String type) {
        LambdaQueryWrapper<EvaluationGrade> wrapper = new LambdaQueryWrapper<EvaluationGrade>()
                .orderByDesc(EvaluationGrade::getSealedAt);
        if ("SENT".equalsIgnoreCase(type)) {
            wrapper.eq(EvaluationGrade::getFromSno, sno);
        } else if ("RECEIVED".equalsIgnoreCase(type)) {
            wrapper.eq(EvaluationGrade::getToSno, sno);
        } else {
            wrapper.and(w -> w.eq(EvaluationGrade::getFromSno, sno).or().eq(EvaluationGrade::getToSno, sno));
        }
        List<EvaluationGrade> list = evaluationMapper.selectList(wrapper);
        if (list.isEmpty()) {
            return List.of();
        }

        // 批量取用户与交换记录，避免 N+1
        Set<String> snos = new LinkedHashSet<>();
        Set<Long> recordIds = new LinkedHashSet<>();
        list.forEach(g -> {
            snos.add(g.getFromSno());
            snos.add(g.getToSno());
            recordIds.add(g.getRecordId());
        });
        Map<String, Student> students = studentMapper.selectBriefBySnos(snos).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));
        Map<Long, ExchangeRecord> records = exchangeMapper.selectBatchIds(recordIds).stream()
                .collect(Collectors.toMap(ExchangeRecord::getId, r -> r, (a, b) -> a));

        // 可见性统一按"该交换是否双方都已提交"判断
        Map<Long, Long> submittedCount = new LinkedHashMap<>();
        list.forEach(g -> submittedCount.merge(g.getRecordId(), 1L, Long::sum));

        List<EvaluationVO> result = new ArrayList<>(list.size());
        for (EvaluationGrade g : list) {
            boolean mine = sno.equals(g.getFromSno());
            boolean bothSubmitted = submittedCount.getOrDefault(g.getRecordId(), 0L) >= 2;
            boolean visible = mine || bothSubmitted || isAdmin(sno);
            EvaluationVO vo = toVO(g, sno, visible);
            Student from = students.get(g.getFromSno());
            Student to = students.get(g.getToSno());
            if (from != null) {
                vo.setFromName(from.displayName());
            }
            if (to != null) {
                vo.setToName(to.displayName());
            }
            ExchangeRecord r = records.get(g.getRecordId());
            if (r != null && vo.getRecordId() != null) {
                // 交换编号便于前端直接展示
                vo.setRecordId(g.getRecordId());
            }
            result.add(vo);
        }
        return result;
    }

    @Override
    public EvaluationVO detail(Long evaluationId, String viewerSno) {
        EvaluationGrade grade = evaluationMapper.selectById(evaluationId);
        if (grade == null) {
            throw new BusinessException(ErrorCode.EVALUATION_NOT_FOUND);
        }
        ExchangeRecord record = exchangeMapper.selectById(grade.getRecordId());
        boolean participant = record != null && record.isParticipant(viewerSno);
        if (!participant && !isAdmin(viewerSno)) {
            throw new BusinessException(ErrorCode.NOT_PARTICIPANT, "你不是该交换的参与方");
        }
        boolean mine = viewerSno != null && viewerSno.equals(grade.getFromSno());
        boolean bothSubmitted = evaluationMapper.countByRecord(grade.getRecordId()) >= 2;
        EvaluationVO vo = toVO(grade, viewerSno, mine || bothSubmitted || isAdmin(viewerSno));
        vo.setFromName(displayName(grade.getFromSno()));
        vo.setToName(displayName(grade.getToSno()));
        return vo;
    }

    /* ==================== 追加修正记录 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public EvaluationVO amend(Long evaluationId, String operator, EvaluationAmendRequest request) {
        EvaluationGrade grade = evaluationMapper.selectById(evaluationId);
        if (grade == null) {
            throw new BusinessException(ErrorCode.EVALUATION_NOT_FOUND);
        }

        BigDecimal before = grade.getTotalScore();
        BigDecimal after = before;
        if (request.getTotalScore() != null) {
            double v = request.getTotalScore();
            if (v < 0 || v > 100) {
                throw new BusinessException(ErrorCode.EVALUATION_SCORE_OUT_OF_RANGE,
                        "修正后总分应在 0~100 之间，当前为 " + v);
            }
            after = BigDecimal.valueOf(v).setScale(2, java.math.RoundingMode.HALF_UP);
        }

        EvaluationAmendment amendment = new EvaluationAmendment()
                .setEvaluationId(evaluationId)
                .setRecordId(grade.getRecordId())
                .setReason(request.getReason().trim())
                .setScoreBefore(before)
                .setScoreAfter(after)
                .setOperator(operator)
                .setDisputeId(request.getDisputeId())
                .setStatus(EvaluationAmendment.STATUS_EFFECTIVE);
        amendmentMapper.insert(amendment);

        /*
         * 修正生效：只更新总分与封存时间。
         *
         * 注意这里不重算 record_hash —— 评价原文（维度分/评语）未被改动，
         * 重算会让"原始存证"失去意义。分值的变更由修正记录承载，
         * 校验接口会同时返回原始哈希与修正历史，两者对照可追溯。
         * 若需让篡改检测覆盖分值变化，应由仲裁流程同时更新哈希并留下新凭证（M8）。
         */
        if (request.getTotalScore() != null) {
            evaluationMapper.updateById(new EvaluationGrade()
                    .setId(evaluationId)
                    .setTotalScore(after)
                    .setDisputeFlag(1));
        } else {
            evaluationMapper.updateById(new EvaluationGrade().setId(evaluationId).setDisputeFlag(1));
        }

        log.info("[互评修正] evaluation={} 由 {} 修正：{} → {}，原因：{}",
                evaluationId, operator, before, after, request.getReason());
        return detail(evaluationId, operator);
    }

    /* ==================== 待审互评的列出与复核（FR-M9-03） ==================== */

    /** 复核状态常量 */
    private static final String AUDIT_PENDING = "PENDING";
    private static final String AUDIT_PASSED = "PASSED";
    private static final String AUDIT_REJECTED = "REJECTED";

    @Override
    public EvaluationReviewPage listForReview(String status, int page, int size) {
        String target = (status == null || status.isBlank()) ? AUDIT_PENDING : status.trim().toUpperCase();
        int p = Math.max(1, page);
        int s = Math.min(100, Math.max(1, size));

        Long total = evaluationMapper.selectCount(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getAuditStatus, target));

        List<EvaluationGrade> rows = evaluationMapper.selectList(
                new LambdaQueryWrapper<EvaluationGrade>()
                        .eq(EvaluationGrade::getAuditStatus, target)
                        // 待复核的先看最久的：先到先处理，避免老记录永远沉底
                        .orderByAsc(EvaluationGrade::getSealedAt)
                        .orderByAsc(EvaluationGrade::getId)
                        .last("LIMIT " + ((p - 1) * s) + ", " + s));

        if (rows.isEmpty()) {
            return new EvaluationReviewPage(List.of(), total == null ? 0 : total, p, s);
        }

        // 批量取交换与姓名，避免逐行查询（N+1）
        Set<Long> recordIds = rows.stream().map(EvaluationGrade::getRecordId).collect(Collectors.toSet());
        Map<Long, ExchangeRecord> records = exchangeMapper.selectList(
                        new LambdaQueryWrapper<ExchangeRecord>().in(ExchangeRecord::getId, recordIds))
                .stream().collect(Collectors.toMap(ExchangeRecord::getId, r -> r, (a, b) -> a));

        Set<String> snos = new java.util.HashSet<>();
        rows.forEach(r -> {
            snos.add(r.getFromSno());
            snos.add(r.getToSno());
        });
        Map<String, String> names = studentMapper.selectList(
                        new LambdaQueryWrapper<Student>().in(Student::getSno, snos))
                .stream().collect(Collectors.toMap(Student::getSno, Student::displayName, (a, b) -> a));

        List<ReviewRow> list = new ArrayList<>();
        for (EvaluationGrade g : rows) {
            ExchangeRecord rec = records.get(g.getRecordId());
            list.add(new ReviewRow(
                    g.getId(),
                    g.getRecordId(),
                    rec == null ? null : rec.getRecordNo(),
                    rec == null ? null : rec.getTitle(),
                    g.getFromSno(), names.getOrDefault(g.getFromSno(), g.getFromSno()),
                    g.getToSno(), names.getOrDefault(g.getToSno(), g.getToSno()),
                    g.getTotalScore(), g.getComment(),
                    g.getAuditStatus(), g.getAuditRemark(),
                    g.getDisputeFlag(), g.getTimeoutFlag(),
                    g.getSealedAt(),
                    // 存证校验：审核界面必须能看出记录本身是否完好，
                    // 否则管理员可能在已被篡改的数据上做判断
                    g.verifyIntegrity()));
        }
        return new EvaluationReviewPage(list, total == null ? 0 : total, p, s);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public EvaluationVO review(Long evaluationId, String operator, EvaluationReviewRequest request) {
        EvaluationGrade grade = evaluationMapper.selectById(evaluationId);
        if (grade == null) {
            throw new BusinessException(ErrorCode.EVALUATION_NOT_FOUND);
        }

        String decision = request.getDecision() == null ? "" : request.getDecision().trim().toUpperCase();
        if (!AUDIT_PASSED.equals(decision) && !AUDIT_REJECTED.equals(decision)) {
            throw new BusinessException(ErrorCode.EVALUATION_AUDIT_DECISION_ILLEGAL,
                    "无法识别的复核结论：" + request.getDecision());
        }
        /*
         * 只允许复核处于 PENDING 的记录。
         *
         * 为什么不做成"可反复改判"：待办数字的语义是"还有多少条需要处理"，
         * 若允许对已复核记录重复提交，同一条会被反复计入/移出，数字就失去意义；
         * 更重要的是审计日志里会出现多次互相矛盾的结论。
         * 真要改判，应走 amend 追加修正记录，那条链路本来就保留前后值。
         */
        if (!AUDIT_PENDING.equals(grade.getAuditStatus())) {
            throw new BusinessException(ErrorCode.EVALUATION_AUDIT_STATUS_ILLEGAL,
                    "该互评当前状态为「" + grade.getAuditStatus() + "」，不需要人工复核");
        }

        /*
         * 只更新审核状态与说明，绝不触碰参与哈希的字段
         * （dimCanonical / totalScore / comment / sealedAt）。
         * 改它们会让 record_hash 校验失败，把一条完好的存证变成"疑似被篡改"。
         * auditStatus / auditRemark 不在哈希原文里，因此可以安全更新。
         */
        evaluationMapper.updateById(new EvaluationGrade()
                .setId(evaluationId)
                .setAuditStatus(decision)
                .setAuditRemark("[人工复核] " + request.getRemark().trim()));

        log.info("[互评复核] evaluation={} 由 {} 判定为 {}：{}",
                evaluationId, operator, decision, request.getRemark().trim());

        return detail(evaluationId, operator);
    }

    /* ==================== 存证校验（FR-M6-04） ==================== */

    @Override
    public IntegrityResultVO verifyByRecordNo(String recordNo) {
        if (!StringUtils.hasText(recordNo)) {
            throw BusinessException.paramInvalid("交换编号不能为空");
        }
        ExchangeRecord record = exchangeMapper.selectOne(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getRecordNo, recordNo.trim()));
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND, "交换记录不存在：" + recordNo);
        }
        List<EvaluationGrade> grades = evaluationMapper.selectList(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getRecordId, record.getId())
                .orderByAsc(EvaluationGrade::getSealedAt));

        IntegrityResultVO vo = new IntegrityResultVO();
        vo.setTarget("交换 " + record.getRecordNo());
        vo.setRecordId(record.getId());
        vo.setRecordNo(record.getRecordNo());
        vo.setCheckedCount(grades.size());
        vo.setItems(new ArrayList<>());

        if (grades.isEmpty()) {
            vo.setIntact(true);
            vo.setBrokenCount(0);
            vo.setEvidenceLevel(null);
            vo.setEvidenceNote("该交换尚无评价记录，无可校验内容");
            return vo;
        }

        int broken = 0;
        EvidenceLevel lowest = EvidenceLevel.CHAIN;
        for (EvaluationGrade g : grades) {
            boolean intact = g.verifyIntegrity();
            if (!intact) {
                broken++;
                // 诊断：同时打印落库原文与按字段重建的原文，便于定位误报原因
                log.warn("[存证校验] 记录 {} 校验不通过。落库原文=[{}] 重建原文=[{}]",
                        g.getId(), g.getHashPayload(), g.rebuiltHashPayload());
            }
            if (g.getEvidenceLevel() != null
                    && g.getEvidenceLevel().ordinal() < lowest.ordinal()) {
                lowest = g.getEvidenceLevel();
            }
            vo.getItems().add(item(g, intact));
        }
        vo.setBrokenCount(broken);
        vo.setIntact(broken == 0);
        vo.setEvidenceLevel(lowest.getLabel());
        vo.setEvidenceNote(lowest.getDescription()
                + (lowest == EvidenceLevel.HASH
                ? "。注意：哈希固化可检出字段级改动，但不能防止有库权限者同步重算哈希，"
                  + "外部锚定（可信时间戳/联盟链）将在 S3 阶段接入。"
                : ""));
        log.info("[存证校验] record={} 校验 {} 条，异常 {} 条", record.getRecordNo(), grades.size(), broken);
        return vo;
    }

    @Override
    public IntegrityResultVO verifyByCode(String verifyCode) {
        if (!StringUtils.hasText(verifyCode)) {
            throw BusinessException.paramInvalid("校验码不能为空");
        }
        EvaluationGrade grade = evaluationMapper.selectOne(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getVerifyCode, verifyCode.trim().toUpperCase()));
        if (grade == null) {
            throw new BusinessException(ErrorCode.EVALUATION_CERT_INVALID);
        }
        boolean intact = grade.verifyIntegrity();

        IntegrityResultVO vo = new IntegrityResultVO();
        vo.setTarget("评价凭证 " + grade.getVerifyCode());
        vo.setRecordId(grade.getRecordId());
        vo.setVerifyCode(grade.getVerifyCode());
        vo.setCheckedCount(1);
        vo.setBrokenCount(intact ? 0 : 1);
        vo.setIntact(intact);
        vo.setTotalScore(grade.getTotalScore());
        vo.setSealedAt(grade.getSealedAt());
        vo.setItems(List.of(item(grade, intact)));

        ExchangeRecord record = exchangeMapper.selectById(grade.getRecordId());
        if (record != null) {
            vo.setRecordNo(record.getRecordNo());
        }
        Student owner = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getSname, Student::getNickname, Student::getCollege)
                .eq(Student::getSno, grade.getToSno()));
        if (owner != null) {
            vo.setOwnerName(owner.displayName());
            vo.setOwnerCollege(owner.getCollege());
        }
        Map<String, Double> dims = calculator.fromJson(grade.getDimScores());
        vo.setDimensionSummary(calculator.toLabeledMap(dims).entrySet().stream()
                .map(e -> e.getKey() + " " + e.getValue())
                .collect(Collectors.joining("；")));
        EvidenceLevel level = grade.getEvidenceLevel() == null ? EvidenceLevel.HASH : grade.getEvidenceLevel();
        vo.setEvidenceLevel(level.getLabel());
        vo.setEvidenceNote(level.getDescription());
        return vo;
    }

    private IntegrityResultVO.Item item(EvaluationGrade g, boolean intact) {
        IntegrityResultVO.Item item = new IntegrityResultVO.Item();
        item.setEvaluationId(g.getId());
        item.setFromName(g.anonymousSubmission() ? "匿名评价" : displayName(g.getFromSno()));
        item.setToName(displayName(g.getToSno()));
        item.setTotalScore(g.getTotalScore());
        item.setIntact(intact);
        item.setRecordHash(g.getRecordHash());
        item.setSealedAt(g.getSealedAt());
        item.setEvidenceLevel(g.getEvidenceLevel() == null ? null : g.getEvidenceLevel().getLabel());
        item.setMessage(intact
                ? "校验通过：记录内容与封存哈希一致"
                : "校验不通过：记录内容与封存哈希不一致，疑被改动");
        return item;
    }

    /* ==================== 装配与工具 ==================== */

    /**
     * 实体 → 视图对象。
     *
     * @param grade   评价实体
     * @param viewer  查看者学号
     * @param visible 是否允许看到分值与评语
     */
    private EvaluationVO toVO(EvaluationGrade grade, String viewer, boolean visible) {
        EvaluationVO vo = new EvaluationVO();
        vo.setId(grade.getId());
        vo.setRecordId(grade.getRecordId());
        vo.setFromSno(grade.getFromSno());
        vo.setToSno(grade.getToSno());
        vo.setAnonymous(grade.anonymousSubmission());
        vo.setMine(viewer != null && viewer.equals(grade.getFromSno()));
        vo.setScoreVisible(visible);
        vo.setTimeoutScored(grade.isTimeoutScored());
        vo.setDisputed(grade.getDisputeFlag() != null && grade.getDisputeFlag() == 1);
        vo.setAuditStatus(grade.getAuditStatus());
        vo.setAuditRemark(grade.getAuditRemark());
        vo.setVerifyCode(grade.getVerifyCode());
        vo.setSealedAt(grade.getSealedAt());
        vo.setCreatedAt(grade.getCreatedAt());

        EvidenceLevel level = grade.getEvidenceLevel() == null ? EvidenceLevel.HASH : grade.getEvidenceLevel();
        vo.setEvidenceLevel(level.name());
        vo.setEvidenceLevelLabel(level.getLabel());
        vo.setEvidenceDescription(level.getDescription());
        // 哈希只给前 16 位做展示指纹，完整值通过校验接口返回
        vo.setRecordHash(grade.getRecordHash() == null ? null
                : grade.getRecordHash().substring(0, Math.min(16, grade.getRecordHash().length())) + "…");

        if (visible) {
            Map<String, Double> dims = calculator.fromJson(grade.getDimScores());
            Map<String, BigDecimal> labeled = new LinkedHashMap<>();
            calculator.toLabeledMap(dims).forEach((k, v) ->
                    labeled.put(k, BigDecimal.valueOf(v).setScale(1, java.math.RoundingMode.HALF_UP)));
            vo.setDimScores(labeled);
            vo.setTotalScore(grade.getTotalScore());
            vo.setComment(grade.getComment());
        }

        // 修正历史：参与方可知情，但只有分值可见时才带出
        List<EvaluationAmendment> amendments = amendmentMapper.selectList(
                new LambdaQueryWrapper<EvaluationAmendment>()
                        .eq(EvaluationAmendment::getEvaluationId, grade.getId())
                        .orderByAsc(EvaluationAmendment::getCreatedAt));
        if (!amendments.isEmpty() && visible) {
            vo.setAmendments(amendments.stream().map(a -> {
                EvaluationVO.AmendmentVO av = new EvaluationVO.AmendmentVO();
                av.setId(a.getId());
                av.setReason(a.getReason());
                av.setScoreBefore(a.getScoreBefore());
                av.setScoreAfter(a.getScoreAfter());
                av.setOperator(a.getOperator());
                av.setDisputeId(a.getDisputeId());
                av.setStatus(a.getStatus());
                av.setCreatedAt(a.getCreatedAt());
                return av;
            }).collect(Collectors.toList()));
        }
        return vo;
    }

    private boolean isAdmin(String sno) {
        if (sno == null) {
            return false;
        }
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getRole)
                .eq(Student::getSno, sno));
        return s != null && s.getRole() == com.nwu.zhiyi.common.enums.UserRole.ADMIN;
    }

    private String displayName(String sno) {
        if (!StringUtils.hasText(sno)) {
            return null;
        }
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getSname, Student::getNickname)
                .eq(Student::getSno, sno));
        return s == null ? sno : s.displayName();
    }

    /** 取某个参与方在本次交换中「提供的技能」名 */
    private String skillName(ExchangeRecord record, String sno) {
        if (sno == null) {
            return null;
        }
        Long skillId = sno.equals(record.getGiverSno()) ? record.getGiveSkillId() : record.getLearnSkillId();
        if (skillId == null) {
            return null;
        }
        Skill skill = skillMapper.selectById(skillId);
        return skill == null ? null : skill.getName();
    }

    private static int nvl(Integer v) {
        return v == null ? 0 : v;
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String t = value.trim();
        return t.isEmpty() ? null : t;
    }
}
