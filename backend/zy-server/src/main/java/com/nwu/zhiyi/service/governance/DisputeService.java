package com.nwu.zhiyi.service.governance;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.governance.DisputeCreateRequest;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.CreditLevel;
import com.nwu.zhiyi.common.enums.DisputeStatus;
import com.nwu.zhiyi.common.enums.DisputeType;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.common.util.HashUtils;
import com.nwu.zhiyi.domain.entity.ArbitrationVote;
import com.nwu.zhiyi.domain.entity.CollabEvent;
import com.nwu.zhiyi.domain.entity.CollabMessage;
import com.nwu.zhiyi.domain.entity.CollabTask;
import com.nwu.zhiyi.domain.entity.Dispute;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.ArbitrationVoteMapper;
import com.nwu.zhiyi.domain.mapper.CollabEventMapper;
import com.nwu.zhiyi.domain.mapper.CollabMessageMapper;
import com.nwu.zhiyi.domain.mapper.CollabTaskMapper;
import com.nwu.zhiyi.domain.mapper.DisputeMapper;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 争议申诉与仲裁服务（FR-M8-03 / FR-M8-04 / FR-M8-05）。
 *
 * <p><b>治理流程</b>：
 * <pre>
 *   一方申诉（附证据）
 *        ↓
 *   系统抽取仲裁委员会（跨学科、高信用、非当事人）
 *        ↓
 *   生成"卷宗"：后台抽取协作全过程交互数据（时间轴 + 任务 + 留言 + 互评）
 *        ↓
 *   委员匿名投票（限时）
 *        ↓
 *   多数决 → 自动执行：调信用 / 修正评价 / 账号处置
 * </pre>
 *
 * <p><b>三个关键设计</b>：
 * <ol>
 *   <li><b>卷宗快照一次生成、后续不变</b>：所有委员必须基于同一份事实材料表决。
 *       若每次查看都实时重查，后续新增的数据会改变卷宗内容，导致委员看到的
 *       事实不同，裁决的正当性就站不住。</li>
 *   <li><b>委员资格是硬门槛</b>：信用等级需达到「优秀」以上（FR-M8-02 的权限落点），
 *       且必须是跨学科（与被申诉人不同学院）。让信用不良者参与裁决会直接
 *       摧毁治理公信力。</li>
 *   <li><b>匿名但可审计</b>：公示只暴露票数分布，投票内容哈希存证。
 *       对社区匿名，对审计透明。</li>
 * </ol>
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DisputeService {

    private final DisputeMapper disputeMapper;
    private final ArbitrationVoteMapper voteMapper;
    private final ExchangeRecordMapper exchangeMapper;
    private final StudentMapper studentMapper;
    private final SkillMapper skillMapper;
    private final EvaluationGradeMapper evaluationMapper;
    private final CollabTaskMapper taskMapper;
    private final CollabMessageMapper messageMapper;
    private final CollabEventMapper eventMapper;
    private final NotificationService notificationService;
    private final GovernanceAuditService auditService;

    /** 抽取的委员人数 */
    @Value("${zhiyi.governance.arbitrator-count:3}")
    private int arbitratorCount;

    /** 表决时限（小时） */
    @Value("${zhiyi.governance.vote-hours:72}")
    private int voteHours;

    /** 委员所需最低信用等级（默认「优秀」） */
    @Value("${zhiyi.governance.min-arbitrator-level:3}")
    private int minArbitratorLevel;

    /* ==================== 发起申诉（FR-M8-03） ==================== */

    /**
     * 发起争议申诉。
     *
     * <p>规则：
     * <ul>
     *   <li>只有交换参与方可以申诉；</li>
     *   <li>交换需处于「进行中 / 待互评 / 已完成 / 争议中」——「洽谈中」尚未产生
     *       实质协作，无可争议内容；</li>
     *   <li>同一交换不允许重复申诉（已有处理中的争议时拒绝）。</li>
     * </ul>
     *
     * @param applicantSno 申诉人
     * @param request      请求体
     * @return 争议详情
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> create(String applicantSno, DisputeCreateRequest request) {
        ExchangeRecord record = exchangeMapper.selectById(request.getRecordId());
        if (record == null) {
            throw new BusinessException(ErrorCode.DISPUTE_RECORD_NOT_FOUND);
        }
        if (!record.isParticipant(applicantSno)) {
            throw new BusinessException(ErrorCode.DISPUTE_NOT_PARTICIPANT);
        }
        ExchangeStatus status = record.getStatus();
        if (status == ExchangeStatus.NEGOTIATING || status == ExchangeStatus.CANCELLED) {
            throw new BusinessException(ErrorCode.DISPUTE_STATUS_ILLEGAL,
                    String.format("交换状态为「%s」，尚无实质协作内容可申诉",
                            status == null ? "未知" : status.getLabel()));
        }

        // 已有处理中的争议 → 拒绝重复申诉
        Long open = disputeMapper.selectCount(new LambdaQueryWrapper<Dispute>()
                .eq(Dispute::getRecordId, record.getId())
                .in(Dispute::getStatus, List.of(DisputeStatus.PENDING.name(), DisputeStatus.VOTING.name())));
        if (open != null && open > 0) {
            throw new BusinessException(ErrorCode.DISPUTE_ALREADY_EXISTS);
        }

        // 证据校验：附件与文字陈述至少要有一项
        boolean hasEvidence = request.getEvidence() != null && !request.getEvidence().isEmpty();
        boolean hasStatement = StringUtils.hasText(request.getStatement());
        if (!hasEvidence && !hasStatement) {
            throw new BusinessException(ErrorCode.DISPUTE_EVIDENCE_EMPTY);
        }

        DisputeType type = parseType(request.getDisputeType());
        String respondent = record.getGiverSno().equals(applicantSno)
                ? record.getTakerSno() : record.getGiverSno();

        Dispute dispute = new Dispute()
                .setRecordId(record.getId())
                .setApplicant(applicantSno)
                .setRespondent(respondent)
                .setDisputeType(type.name())
                .setReason(request.getReason().trim())
                .setStatement(trimToNull(request.getStatement()))
                .setEvidence(hasEvidence ? JSONUtil.toJsonStr(request.getEvidence()) : null)
                .setStatus(DisputeStatus.PENDING.name())
                .setArbitratorCount(0)
                .setVoteCount(0);
        disputeMapper.insert(dispute);

        log.info("[争议] 受理 record={} 类型={} 申诉人={} 被申诉人={}",
                record.getRecordNo(), type.name(), applicantSno, respondent);

        // 生成卷宗（FR-M8-04）
        String caseFile = buildCaseFile(dispute, record);
        dispute.setCaseFile(caseFile);

        // 抽取委员并进入投票阶段
        List<Student> arbitrators = selectArbitrators(applicantSno, respondent);
        if (arbitrators.size() < arbitratorCount) {
            /*
             * 委员不足时【不】降级凑数 —— 让信用不足者参与裁决会摧毁治理公信力。
             * 正确做法是转入"待管理员处置"：仍走公示与留痕（FR-M8-08），
             * 但由管理员紧急干预并说明理由。
             */
            dispute.setStatus(DisputeStatus.PENDING.name());
            disputeMapper.updateById(dispute);
            notifyAdminFallback(dispute, record, arbitrators.size());
            auditService.record(GovernanceAuditService.builder()
                    .action("DISPUTE_RESOLVE")
                    .actorSno(GovernanceAuditService.SYSTEM)
                    .actorRole("SYSTEM")
                    .targetType("DISPUTE")
                    .targetId(String.valueOf(dispute.getId()))
                    .summary(String.format("争议 #%d 委员不足（仅 %d 人达标），转管理员处置",
                            dispute.getId(), arbitrators.size()))
                    .reason("高信用委员数量不足，为避免降低裁决门槛，转由管理员处置并留痕")
                    .visible(true)
                    .build());
            log.warn("[争议] #{} 合格委员仅 {} 人（需要 {}），转管理员处置",
                    dispute.getId(), arbitrators.size(), arbitratorCount);
        } else {
            dispute.setStatus(DisputeStatus.VOTING.name());
            dispute.setArbitratorCount(arbitrators.size());
            dispute.setVoteDeadline(LocalDateTime.now().plusHours(voteHours));
            disputeMapper.updateById(dispute);
            notifyArbitrators(dispute, record, arbitrators);
            log.info("[争议] #{} 抽取委员 {} 人，表决截止 {}",
                    dispute.getId(), arbitrators.size(), dispute.getVoteDeadline());
        }

        notificationService.send(respondent, NotificationType.DISPUTE,
                "收到争议申诉",
                String.format("协作「%s」被发起申诉（%s）。你可以在争议详情中提交答辩",
                        record.getTitle(), type.getLabel()),
                "DISPUTE", dispute.getId());

        return detail(dispute.getId(), applicantSno);
    }

    /**
     * 被申诉人提交答辩。
     *
     * <p>给被告申辩机会是程序正义的最低要求 —— 单方陈述即定罪，
     * 委员会看到的就只是片面事实。
     *
     * @param disputeId 争议 ID
     * @param sno       提交人（必须是被申诉人）
     * @param defense   答辩内容
     * @return 争议详情
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> submitDefense(Long disputeId, String sno, String defense) {
        Dispute dispute = requireDispute(disputeId);
        if (!sno.equals(dispute.getRespondent())) {
            throw new BusinessException(ErrorCode.DISPUTE_NOT_PARTICIPANT,
                    "只有被申诉人才能提交答辩");
        }
        if (!dispute.isOpen()) {
            throw new BusinessException(ErrorCode.DISPUTE_STATUS_ILLEGAL, "该争议已结案，无法再提交答辩");
        }
        if (!StringUtils.hasText(defense)) {
            throw new BusinessException(ErrorCode.DISPUTE_EVIDENCE_EMPTY, "答辩内容不能为空");
        }
        dispute.setDefense(defense.trim());
        disputeMapper.updateById(dispute);
        log.info("[争议] #{} 被申诉人已提交答辩（{} 字）", disputeId, defense.trim().length());
        return detail(disputeId, sno);
    }

    /* ==================== 卷宗生成（FR-M8-04） ==================== */

    /**
     * 抽取协作全过程交互数据生成卷宗。
     *
     * <p>这是"去中心化治理"能成立的技术前提：委员不必逐个去翻协作空间，
     * 系统把该看的东西一次性整理好。卷宗内容：
     * <ul>
     *   <li>交换基本信息（主题、双方、时长、状态流转时间）</li>
     *   <li>任务拆解与打卡记录（谁承诺了什么、完成情况）</li>
     *   <li>留言统计（沟通频次，但不含具体内容 —— 保护隐私，且避免委员被情绪化表述影响）</li>
     *   <li>文件交付记录</li>
     *   <li>双向互评（分数与评语）</li>
     *   <li>时间轴关键事件</li>
     * </ul>
     *
     * @param dispute 争议
     * @param record  交换记录
     * @return 卷宗 JSON
     */
    private String buildCaseFile(Dispute dispute, ExchangeRecord record) {
        JSONObject caseFile = new JSONObject(true);

        // ---------- 交换概况 ----------
        JSONObject summary = new JSONObject(true);
        summary.set("recordNo", record.getRecordNo());
        summary.set("title", record.getTitle());
        summary.set("description", record.getDescription());
        summary.set("status", record.getStatus() == null ? null : record.getStatus().name());
        summary.set("statusLabel", record.getStatus() == null ? null : record.getStatus().getLabel());
        summary.set("startedAt", record.getStartedAt());
        summary.set("pendingEvalAt", record.getPendingEvalAt());
        summary.set("finishedAt", record.getFinishedAt());
        summary.set("expectedHours", record.getExpectedHours());
        summary.set("actualHours", record.getActualHours());
        caseFile.set("exchange", summary);

        // ---------- 双方信息（含信用，供委员评估陈述可信度） ----------
        caseFile.set("parties", buildParties(record));

        // ---------- 任务拆解与打卡 ----------
        List<CollabTask> tasks = taskMapper.selectList(new LambdaQueryWrapper<CollabTask>()
                .eq(CollabTask::getRecordId, record.getId())
                .orderByAsc(CollabTask::getId));
        List<Map<String, Object>> taskView = new ArrayList<>();
        for (CollabTask t : tasks) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("title", t.getTitle());
            m.put("assignee", displayName(t.getAssigneeSno()));
            m.put("status", t.getStatus() == null ? null : t.getStatus().name());
            m.put("deadline", t.getDeadline());
            m.put("doneAt", t.getDoneAt());
            m.put("overdue", t.isOverdue());
            m.put("evidenceUrl", t.getEvidenceUrl());
            taskView.add(m);
        }
        caseFile.set("tasks", taskView);
        caseFile.set("taskSummary", buildTaskSummary(tasks));

        // ---------- 沟通记录（只给统计，不给内容） ----------
        Long msgCount = messageMapper.selectCount(new LambdaQueryWrapper<CollabMessage>()
                .eq(CollabMessage::getRecordId, record.getId()));
        JSONObject comm = new JSONObject(true);
        comm.set("messageCount", msgCount);
        comm.set("giverMessages", messageMapper.countBySender(record.getId(), record.getGiverSno()));
        comm.set("takerMessages", messageMapper.countBySender(record.getId(), record.getTakerSno()));
        caseFile.set("communication", comm);

        // ---------- 互评 ----------
        List<EvaluationGrade> grades = evaluationMapper.selectList(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getRecordId, record.getId()));
        List<Map<String, Object>> evalView = new ArrayList<>();
        for (EvaluationGrade g : grades) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("from", displayName(g.getFromSno()));
            m.put("to", displayName(g.getToSno()));
            m.put("totalScore", g.getTotalScore());
            m.put("comment", g.getComment());
            m.put("anonymous", g.anonymousSubmission());
            m.put("timeoutScored", g.isTimeoutScored());
            m.put("sealedAt", g.getSealedAt());
            // 顺带做完整性校验：若评价已被篡改，委员应当知道
            m.put("integrityOk", g.verifyIntegrity());
            evalView.add(m);
        }
        caseFile.set("evaluations", evalView);

        // ---------- 时间轴（最近 50 条） ----------
        List<CollabEvent> events = eventMapper.selectList(new LambdaQueryWrapper<CollabEvent>()
                .eq(CollabEvent::getRecordId, record.getId())
                .orderByAsc(CollabEvent::getOccurredAt)
                .last("LIMIT 50"));
        List<String> timeline = new ArrayList<>();
        for (CollabEvent e : events) {
            timeline.add(String.format("[%s] %s（%s）",
                    e.getOccurredAt(), e.getTitle(), displayName(e.getActorSno())));
        }
        caseFile.set("timeline", timeline);

        // ---------- 申诉与答辩 ----------
        JSONObject claim = new JSONObject(true);
        claim.set("type", dispute.getDisputeType());
        claim.set("typeLabel", parseType(dispute.getDisputeType()).getLabel());
        claim.set("reason", dispute.getReason());
        claim.set("statement", dispute.getStatement());
        claim.set("evidence", dispute.getEvidence());
        claim.set("applicant", displayName(dispute.getApplicant()));
        claim.set("respondent", displayName(dispute.getRespondent()));
        claim.set("filedAt", LocalDateTime.now());
        caseFile.set("claim", claim);

        return caseFile.toString();
    }

    private List<Map<String, Object>> buildParties(ExchangeRecord record) {
        List<Map<String, Object>> parties = new ArrayList<>();
        for (String sno : new String[]{record.getGiverSno(), record.getTakerSno()}) {
            if (sno == null) {
                continue;
            }
            Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                    .select(Student::getSno, Student::getSname, Student::getNickname,
                            Student::getCollege, Student::getMajor, Student::getCreditScore)
                    .eq(Student::getSno, sno));
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("sno", sno);
            m.put("name", s == null ? sno : s.displayName());
            m.put("college", s == null ? null : s.getCollege());
            m.put("role", record.getGiverSno().equals(sno) ? "供给方" : "需求方");
            m.put("creditScore", s == null ? null : s.getCreditScore());
            m.put("provideSkill", skillName(record.getGiverSno().equals(sno)
                    ? record.getGiveSkillId() : record.getLearnSkillId()));
            parties.add(m);
        }
        return parties;
    }

    private Map<String, Object> buildTaskSummary(List<CollabTask> tasks) {
        Map<String, Object> m = new LinkedHashMap<>();
        long done = tasks.stream().filter(t -> t.getStatus() == com.nwu.zhiyi.common.enums.TaskStatus.DONE).count();
        long overdue = tasks.stream().filter(CollabTask::isOverdue).count();
        m.put("total", tasks.size());
        m.put("done", done);
        m.put("overdue", overdue);
        m.put("completionRate", tasks.isEmpty() ? null
                : Math.round(done * 100.0 / tasks.size()) + "%");
        return m;
    }

    /* ==================== 委员抽取（FR-M8-04） ==================== */

    /**
     * 抽取仲裁委员。
     *
     * <p>资格条件（全部满足）：
     * <ol>
     *   <li><b>非当事人</b> —— 最基础的利益回避；</li>
     *   <li><b>信用等级达标</b> —— 默认需「优秀」以上（FR-M8-02 的权限落点）；</li>
     *   <li><b>跨学科</b> —— 与被申诉人、申诉人不同学院。这既是需求明确要求
     *       （"由跨学科、高信用用户组成"），也能减少熟人偏袒；</li>
     *   <li>账号状态正常。</li>
     * </ol>
     *
     * <p>符合条件者不足时<b>不降级凑数</b>，而是转管理员处置并留痕 ——
     * 降低裁决门槛会摧毁治理公信力，代价远大于"这批争议由管理员处理"。
     *
     * @param applicantSno  申诉人
     * @param respondentSno 被申诉人
     * @return 选中的委员
     */
    public List<Student> selectArbitrators(String applicantSno, String respondentSno) {
        Set<String> excluded = new LinkedHashSet<>();
        excluded.add(applicantSno);
        excluded.add(respondentSno);

        // 当事人所在学院也排除（减少熟人偏袒；同一学院的同学更容易互相认识）
        Set<String> excludedColleges = new LinkedHashSet<>();
        for (String sno : excluded) {
            Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                    .select(Student::getSno, Student::getCollege)
                    .eq(Student::getSno, sno));
            if (s != null && StringUtils.hasText(s.getCollege())) {
                excludedColleges.add(s.getCollege());
            }
        }

        List<Student> candidates = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                .isNotNull(Student::getCreditScore)
                .ge(Student::getCreditScore, CreditLevel.values()[minArbitratorLevel].getMinScore())
                .notIn(Student::getSno, excluded)
                .eq(Student::getStatus, 1));

        List<Student> eligible = new ArrayList<>();
        for (Student s : candidates) {
            if (excludedColleges.contains(s.getCollege())) {
                continue;
            }
            eligible.add(s);
        }

        // 随机抽取，避免总是同几个人当委员（也降低被围猎的可能）
        Collections.shuffle(eligible);
        List<Student> picked = eligible.size() <= arbitratorCount
                ? eligible : eligible.subList(0, arbitratorCount);
        log.info("[仲裁] 候选 {} 人（排除当事人及其学院 {}），抽取 {} 人",
                eligible.size(), excludedColleges, picked.size());
        return new ArrayList<>(picked);
    }

    /**
     * 判断某用户是否有资格对该争议投票。
     *
     * @param dispute 争议
     * @param sno     用户
     * @return 资格说明；有资格返回 {@code null}
     */
    public String checkEligibility(Dispute dispute, String sno) {
        if (sno.equals(dispute.getApplicant()) || sno.equals(dispute.getRespondent())) {
            return "当事人不得参与裁决";
        }
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getCollege, Student::getCreditScore, Student::getStatus)
                .eq(Student::getSno, sno));
        if (s == null) {
            return "用户不存在";
        }
        if (s.getStatus() == null || s.getStatus() != 1) {
            return "账号状态异常";
        }
        CreditLevel level = CreditLevel.of(s.getCreditScore());
        if (!level.isEligibleArbitrator()) {
            return String.format("信用等级为「%s」，需达到「优秀」以上才能担任仲裁委员",
                    level.getLabel());
        }
        // 已投过票
        Long voted = voteMapper.selectCount(new LambdaQueryWrapper<ArbitrationVote>()
                .eq(ArbitrationVote::getDisputeId, dispute.getId())
                .eq(ArbitrationVote::getVoterSno, sno));
        if (voted != null && voted > 0) {
            return "你已对该争议投过票";
        }
        return null;
    }

    /* ==================== 查询 ==================== */

    /**
     * 我的争议列表（我作为申诉人或被申诉人）。
     *
     * @param sno 学号
     * @return 列表
     */
    public List<Map<String, Object>> myDisputes(String sno) {
        List<Dispute> list = disputeMapper.selectList(new LambdaQueryWrapper<Dispute>()
                .and(w -> w.eq(Dispute::getApplicant, sno).or().eq(Dispute::getRespondent, sno))
                .orderByDesc(Dispute::getCreatedAt));
        return list.stream().map(d -> toListView(d, sno)).toList();
    }

    /**
     * 待我仲裁的争议（我符合委员资格、尚未投票、且仍在投票中）。
     *
     * @param sno 学号
     * @return 列表
     */
    public List<Map<String, Object>> pendingForArbitration(String sno) {
        Student me = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getCreditScore, Student::getStatus)
                .eq(Student::getSno, sno));
        if (me == null || !CreditLevel.of(me.getCreditScore()).isEligibleArbitrator()) {
            return List.of();
        }
        List<Dispute> voting = disputeMapper.selectList(new LambdaQueryWrapper<Dispute>()
                .eq(Dispute::getStatus, DisputeStatus.VOTING.name())
                .ne(Dispute::getApplicant, sno)
                .ne(Dispute::getRespondent, sno)
                .orderByAsc(Dispute::getVoteDeadline));
        List<Map<String, Object>> result = new ArrayList<>();
        for (Dispute d : voting) {
            Long voted = voteMapper.selectCount(new LambdaQueryWrapper<ArbitrationVote>()
                    .eq(ArbitrationVote::getDisputeId, d.getId())
                    .eq(ArbitrationVote::getVoterSno, sno));
            if (voted != null && voted > 0) {
                continue;
            }
            result.add(toListView(d, sno));
        }
        return result;
    }

    /**
     * 争议详情（含卷宗）。
     *
     * @param disputeId 争议 ID
     * @param viewerSno 查看者
     * @return 详情
     */
    public Map<String, Object> detail(Long disputeId, String viewerSno) {
        Dispute d = requireDispute(disputeId);
        Map<String, Object> m = toListView(d, viewerSno);

        boolean isParty = viewerSno.equals(d.getApplicant()) || viewerSno.equals(d.getRespondent());
        boolean isAdmin = isAdmin(viewerSno);
        boolean eligible = checkEligibility(d, viewerSno) == null;

        // 卷宗只对当事人、合格委员与管理员开放 —— 协作过程数据属于隐私
        if (isParty || isAdmin || eligible) {
            m.put("caseFile", d.getCaseFile() == null ? null : JSONUtil.parseObj(d.getCaseFile()));
        } else {
            m.put("caseFile", null);
        }
        m.put("canDefense", viewerSno.equals(d.getRespondent()) && d.isOpen());
        m.put("canVote", eligible && d.isVoting() && !d.isVoteExpired());
        m.put("myVote", myVote(d.getId(), viewerSno));
        // 投票结果：投票截止或已结案后才公开
        boolean resultVisible = d.isVoteExpired() || DisputeStatus.RESOLVED.name().equals(d.getStatus())
                || isAdmin;
        m.put("voteResult", resultVisible ? voteResult(d.getId()) : null);
        m.put("executionLog", d.getExecutionLog() == null ? null : JSONUtil.parseObj(d.getExecutionLog()));
        return m;
    }

    /**
     * 投票结果统计（匿名：只给票数，不给谁投了什么）。
     *
     * @param disputeId 争议 ID
     * @return 统计
     */
    public Map<String, Object> voteResult(Long disputeId) {
        List<ArbitrationVote> votes = voteMapper.selectList(new LambdaQueryWrapper<ArbitrationVote>()
                .eq(ArbitrationVote::getDisputeId, disputeId));
        long forApplicant = votes.stream().filter(ArbitrationVote::isForApplicant).count();
        long forRespondent = votes.stream().filter(ArbitrationVote::isForRespondent).count();
        long abstain = votes.stream().filter(ArbitrationVote::isAbstain).count();

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("total", votes.size());
        m.put("forApplicant", forApplicant);
        m.put("forRespondent", forRespondent);
        m.put("abstain", abstain);
        // 匿名评论：不带投票人身份
        m.put("comments", votes.stream()
                .filter(v -> StringUtils.hasText(v.getComment()))
                .map(ArbitrationVote::getComment).toList());
        return m;
    }

    private Map<String, Object> myVote(Long disputeId, String sno) {
        ArbitrationVote v = voteMapper.selectOne(new LambdaQueryWrapper<ArbitrationVote>()
                .eq(ArbitrationVote::getDisputeId, disputeId)
                .eq(ArbitrationVote::getVoterSno, sno));
        if (v == null) {
            return null;
        }
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("vote", v.getVote());
        m.put("comment", v.getComment());
        m.put("createdAt", v.getCreatedAt());
        return m;
    }

    /** 记录一票（由 ArbitrationService 调用，统一在此维护计票） */
    @Transactional(rollbackFor = Exception.class)
    public void recordVote(Dispute dispute, String voterSno, String vote, String comment, String reason) {
        String payload = String.join("|", String.valueOf(dispute.getId()), voterSno, vote,
                comment == null ? "-" : comment.trim(), LocalDateTime.now().toString());
        ArbitrationVote v = new ArbitrationVote()
                .setDisputeId(dispute.getId())
                .setVoterSno(voterSno)
                .setVote(vote)
                .setComment(comment == null ? null : comment.trim())
                .setVoteHash(HashUtils.sha256Hex(payload))
                .setSelectionReason(reason);
        voteMapper.insert(v);

        dispute.setVoteCount((dispute.getVoteCount() == null ? 0 : dispute.getVoteCount()) + 1);
        disputeMapper.updateById(dispute);
    }

    private Dispute requireDispute(Long id) {
        Dispute d = disputeMapper.selectById(id);
        if (d == null) {
            throw new BusinessException(ErrorCode.DISPUTE_NOT_FOUND);
        }
        return d;
    }

    private void notifyArbitrators(Dispute dispute, ExchangeRecord record, List<Student> arbitrators) {
        for (Student s : arbitrators) {
            notificationService.send(s.getSno(), NotificationType.DISPUTE,
                    "你被抽取为仲裁委员",
                    String.format("协作「%s」存在争议，请在 %d 小时内完成匿名表决",
                            record.getTitle(), voteHours),
                    "DISPUTE", dispute.getId());
        }
    }

    private void notifyAdminFallback(Dispute dispute, ExchangeRecord record, int found) {
        notificationService.send("admin", NotificationType.DISPUTE,
                "争议需管理员处置",
                String.format("协作「%s」的争议（#%d）仅抽取到 %d 名合格委员，不足 %d 人，"
                                + "请按治理规则处置并填写理由（操作将留痕公示）",
                        record.getTitle(), dispute.getId(), found, arbitratorCount),
                "DISPUTE", dispute.getId());
    }

    private Map<String, Object> toListView(Dispute d, String viewerSno) {
        ExchangeRecord record = exchangeMapper.selectById(d.getRecordId());
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", d.getId());
        m.put("recordId", d.getRecordId());
        m.put("recordNo", record == null ? null : record.getRecordNo());
        m.put("exchangeTitle", record == null ? null : record.getTitle());
        m.put("disputeType", d.getDisputeType());
        m.put("disputeTypeLabel", parseType(d.getDisputeType()).getLabel());
        m.put("applicant", d.getApplicant());
        m.put("applicantName", displayName(d.getApplicant()));
        m.put("respondent", d.getRespondent());
        m.put("respondentName", displayName(d.getRespondent()));
        m.put("reason", d.getReason());
        m.put("status", d.getStatus());
        m.put("statusLabel", statusLabel(d.getStatus()));
        m.put("arbitratorCount", d.getArbitratorCount());
        m.put("voteCount", d.getVoteCount());
        m.put("voteDeadline", d.getVoteDeadline());
        m.put("voteExpired", d.isVoteExpired());
        m.put("verdict", d.getVerdict());
        m.put("resolvedBy", d.getResolvedBy());
        m.put("resolvedAt", d.getResolvedAt());
        m.put("createdAt", d.getCreatedAt());
        m.put("myRole", viewerSno.equals(d.getApplicant()) ? "APPLICANT"
                : viewerSno.equals(d.getRespondent()) ? "RESPONDENT" : "ARBITRATOR");
        return m;
    }

    private static DisputeType parseType(String value) {
        if (value == null) {
            return DisputeType.OTHER;
        }
        try {
            return DisputeType.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return DisputeType.OTHER;
        }
    }

    private static String statusLabel(String status) {
        try {
            return DisputeStatus.valueOf(status).getLabel();
        } catch (Exception e) {
            return status;
        }
    }

    private boolean isAdmin(String sno) {
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getRole)
                .eq(Student::getSno, sno));
        return s != null && s.getRole() == com.nwu.zhiyi.common.enums.UserRole.ADMIN;
    }

    private String displayName(String sno) {
        if (!StringUtils.hasText(sno)) {
            return "—";
        }
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getSname, Student::getNickname)
                .eq(Student::getSno, sno));
        return s == null ? sno : s.displayName();
    }

    private String skillName(Long skillId) {
        if (skillId == null) {
            return null;
        }
        Skill s = skillMapper.selectById(skillId);
        return s == null ? null : s.getName();
    }

    private static String trimToNull(String v) {
        if (v == null) {
            return null;
        }
        String t = v.trim();
        return t.isEmpty() ? null : t;
    }
}
