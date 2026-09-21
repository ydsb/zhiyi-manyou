package com.nwu.zhiyi.service.profile;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.profile.DataExportVO;
import com.nwu.zhiyi.api.dto.profile.RadarChartVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.CollabMessage;
import com.nwu.zhiyi.domain.entity.CreditLedger;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.CollabFileMapper;
import com.nwu.zhiyi.domain.mapper.CollabMessageMapper;
import com.nwu.zhiyi.domain.mapper.CreditLedgerMapper;
import com.nwu.zhiyi.domain.mapper.DemandMapper;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 个人数据导出服务（FR-M1-07）。
 *
 * <p><b>为什么单独成类</b>：导出要横跨 M1（账号）、M2（技能画像）、M4（需求与交换）、
 * M5（协作留言）、M6（互评）、M7（能力画像与勋章）、M8（信用流水）七个模块的数据。
 * 塞进任何一个既有 Service 都会让那一个类承担本不属于它的依赖；
 * 单列之后，数据导出这一件事的边界与隐私规则也集中在一处，便于审查。
 *
 * <p><b>隐私规则（本类的核心约束）</b>：
 * <ul>
 *   <li>只导出<b>关于导出人</b>的数据；</li>
 *   <li>互评只导出<b>我收到</b>的，不导出我给出的 —— 后者是对他人的评价，
 *       属于对方的数据，且平台对评价有匿名与可见性规则（FR-M6-05），
 *       从导出通道漏出去等于绕过那些规则；</li>
 *   <li>对方只保留展示名（平台内本就公开），不含学号与联系方式；</li>
 *   <li>匿名互评在导出中同样保持匿名 —— 不能因为"数据归用户所有"就泄露评价人身份，
 *       匿名承诺一旦在导出通道破例，整个互评机制的可信度就没了。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DataExportService {

    private final StudentMapper studentMapper;
    private final SkillMapper skillMapper;
    private final ExchangeRecordMapper exchangeMapper;
    private final EvaluationGradeMapper evaluationMapper;
    private final DemandMapper demandMapper;
    private final CreditLedgerMapper creditLedgerMapper;
    private final CollabMessageMapper messageMapper;
    private final CollabFileMapper fileMapper;
    private final ProfileService profileService;
    private final SkillProfileService skillProfileService;
    private final AuthService authService;

    /** 导出的说明文案，随文件一起给用户，讲清包含与不包含什么 */
    private static final String EXPORT_NOTE =
            "本文件包含你在「知驿·漫游」平台上的个人数据：账号资料、技能画像、能力画像、"
                    + "发布的需求卡片、交换记录、收到的互评、信用流水、数字勋章与协作留言。"
                    + "不含你对他人的评价原文（属于对方数据）、他人学号与联系方式。"
                    + "匿名互评在导出中保持匿名。";

    /**
     * 导出当前用户的全部个人数据。
     *
     * @param sno 学号（取自登录态）
     * @return 结构化导出数据
     */
    public DataExportVO export(String sno) {
        Student student = studentMapper.selectOne(
                new LambdaQueryWrapper<Student>().eq(Student::getSno, sno));
        if (student == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }

        DataExportVO vo = new DataExportVO();
        vo.setExportedAt(LocalDateTime.now());
        vo.setSno(sno);
        vo.setNote(EXPORT_NOTE);

        // 一、账号与资料（复用 AuthService 的脱敏视图，保证与 /api/auth/me 口径一致）
        vo.setAccount(authService.toUserInfo(student));

        // 二、技能画像（复用既有服务，避免此处再算一遍分组逻辑）
        vo.setSkills(skillProfileService.mine(sno));

        // 三、能力画像
        vo.setAbility(buildAbility(sno));

        // 四、我发布的需求卡片
        List<Demand> demands = demandMapper.selectList(new LambdaQueryWrapper<Demand>()
                .eq(Demand::getOwnerSno, sno)
                .orderByDesc(Demand::getCreatedAt));
        vo.setDemands(buildDemands(demands));

        // 五、我的交换记录
        List<ExchangeRecord> records = exchangeMapper.selectList(new LambdaQueryWrapper<ExchangeRecord>()
                .and(w -> w.eq(ExchangeRecord::getGiverSno, sno).or().eq(ExchangeRecord::getTakerSno, sno))
                .orderByDesc(ExchangeRecord::getCreatedAt));
        vo.setExchanges(buildExchanges(records, sno));

        // 六、我收到的互评
        List<EvaluationGrade> received = evaluationMapper.selectList(
                new LambdaQueryWrapper<EvaluationGrade>()
                        .eq(EvaluationGrade::getToSno, sno)
                        .orderByDesc(EvaluationGrade::getSealedAt));
        vo.setReceivedEvaluations(buildEvaluations(received, records));

        // 七、信用流水
        List<CreditLedger> ledgers = creditLedgerMapper.selectList(new LambdaQueryWrapper<CreditLedger>()
                .eq(CreditLedger::getSno, sno)
                .orderByDesc(CreditLedger::getCreatedAt));
        vo.setCreditLedger(buildCredit(ledgers));

        // 八、数字勋章
        vo.setBadges(profileService.badges(sno).stream()
                .filter(b -> Boolean.TRUE.equals(b.getUnlocked()))
                .map(b -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("name", b.getName());
                    m.put("description", b.getDescription());
                    m.put("conditionText", b.getConditionText());
                    m.put("grantedAt", b.getGrantedAt());
                    return m;
                })
                .collect(Collectors.toList()));

        // 九、我发出的协作留言
        Set<Long> myRecordIds = records.stream().map(ExchangeRecord::getId).collect(Collectors.toSet());
        vo.setMessages(buildMessages(myRecordIds, records, sno));

        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("技能画像标签", vo.getSkills() == null ? 0 : vo.getSkills().getTotal());
        counts.put("需求卡片", vo.getDemands().size());
        counts.put("交换记录", vo.getExchanges().size());
        counts.put("收到的互评", vo.getReceivedEvaluations().size());
        counts.put("信用流水", vo.getCreditLedger().size());
        counts.put("数字勋章", vo.getBadges().size());
        counts.put("协作留言", vo.getMessages().size());
        vo.setCounts(counts);

        log.info("[数据导出] {} 导出完成：{}", sno, counts);
        return vo;
    }

    /* ---------------- 各板块组装 ---------------- */

    private DataExportVO.AbilityProfile buildAbility(String sno) {
        RadarChartVO radar = profileService.radar(sno);
        DataExportVO.AbilityProfile a = new DataExportVO.AbilityProfile();
        Map<String, java.math.BigDecimal> scores = new LinkedHashMap<>();
        Map<String, String> evidence = new LinkedHashMap<>();
        for (RadarChartVO.DimensionScore d : radar.getDimensions()) {
            scores.put(d.getLabel(), d.getScore());
            evidence.put(d.getLabel(), d.getEvidence());
        }
        a.setDimensionScores(scores);
        a.setDimensionEvidence(evidence);
        a.setOverallScore(radar.getOverallScore());
        a.setSampleCount(radar.getSampleCount());
        a.setTotalHours(radar.getTotalHours());
        a.setAvgScore(radar.getAvgScore());
        a.setCaliberNote(radar.getCaliberNote());
        return a;
    }

    private List<DataExportVO.DemandItem> buildDemands(List<Demand> demands) {
        if (demands.isEmpty()) {
            return List.of();
        }
        Map<Long, String> skillNames = loadSkillNames(demands.stream()
                .flatMap(d -> java.util.stream.Stream.of(d.getExpectedSkillId(), d.getOfferSkillId()))
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toSet()));

        List<DataExportVO.DemandItem> list = new ArrayList<>();
        for (Demand d : demands) {
            DataExportVO.DemandItem item = new DataExportVO.DemandItem();
            item.setDemandNo(d.getDemandNo());
            item.setTitle(d.getTitle());
            item.setDescription(d.getDescription());
            item.setExpectedSkill(skillNames.get(d.getExpectedSkillId()));
            item.setOfferSkill(skillNames.get(d.getOfferSkillId()));
            item.setStatusLabel(d.getStatus() == null ? null : d.getStatus().getLabel());
            item.setAuditStatus(d.getAuditStatus() == null ? null : d.getAuditStatus().name());
            item.setExpectedHours(d.getExpectedHours());
            item.setMatchCount(d.getMatchCount());
            item.setViewCount(d.getViewCount());
            item.setCreatedAt(d.getCreatedAt());
            list.add(item);
        }
        return list;
    }

    private List<DataExportVO.ExchangeItem> buildExchanges(List<ExchangeRecord> records, String sno) {
        if (records.isEmpty()) {
            return List.of();
        }
        Map<Long, String> skillNames = loadSkillNames(records.stream()
                .flatMap(r -> java.util.stream.Stream.of(r.getGiveSkillId(), r.getLearnSkillId()))
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toSet()));
        Map<String, String> peerNames = loadDisplayNames(records.stream()
                .flatMap(r -> java.util.stream.Stream.of(r.getGiverSno(), r.getTakerSno()))
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toSet()));

        List<DataExportVO.ExchangeItem> list = new ArrayList<>();
        for (ExchangeRecord r : records) {
            boolean isGiver = sno.equals(r.getGiverSno());
            String peerSno = isGiver ? r.getTakerSno() : r.getGiverSno();

            DataExportVO.ExchangeItem item = new DataExportVO.ExchangeItem();
            item.setRecordNo(r.getRecordNo());
            item.setTitle(r.getTitle());
            item.setMyRole(isGiver ? "GIVER" : "TAKER");
            item.setStatusLabel(r.getStatus() == null ? null : r.getStatus().getLabel());
            /*
             * 我提供的 / 我学到的，按"我"的视角区分。
             * 表结构上 give_skill_id 是供给方提供的技能，learn_skill_id 是需求方
             * 想学的技能；对需求方而言，他提供出去的其实是 learn 对应的那个技能
             * （以技易技：用我会的换我想学的），因此这里要按角色换位，
             * 否则需求方看到的"我提供的技能"会是错的。
             */
            item.setProvidedSkill(isGiver
                    ? skillNames.get(r.getGiveSkillId())
                    : skillNames.get(r.getLearnSkillId()));
            item.setAcquiredSkill(isGiver
                    ? skillNames.get(r.getLearnSkillId())
                    : skillNames.get(r.getGiveSkillId()));
            item.setPeerName(peerNames.get(peerSno));
            item.setExpectedHours(r.getExpectedHours());
            item.setActualHours(r.getActualHours());
            item.setStartedAt(r.getStartedAt());
            item.setFinishedAt(r.getFinishedAt());
            item.setCreatedAt(r.getCreatedAt());
            list.add(item);
        }
        return list;
    }

    private List<DataExportVO.ReceivedEvaluation> buildEvaluations(List<EvaluationGrade> grades,
                                                                  List<ExchangeRecord> records) {
        if (grades.isEmpty()) {
            return List.of();
        }
        Map<Long, ExchangeRecord> recordMap = records.stream()
                .collect(Collectors.toMap(ExchangeRecord::getId, r -> r, (a, b) -> a));
        Map<String, String> names = loadDisplayNames(
                grades.stream().map(EvaluationGrade::getFromSno)
                        .filter(java.util.Objects::nonNull).collect(Collectors.toSet()));

        List<DataExportVO.ReceivedEvaluation> list = new ArrayList<>();
        for (EvaluationGrade g : grades) {
            DataExportVO.ReceivedEvaluation e = new DataExportVO.ReceivedEvaluation();
            ExchangeRecord rec = recordMap.get(g.getRecordId());
            e.setRecordNo(rec == null ? null : rec.getRecordNo());
            e.setRecordTitle(rec == null ? null : rec.getTitle());
            // 匿名评价保持匿名：导出通道不能绕过平台的匿名承诺
            boolean anon = g.anonymousSubmission();
            e.setAnonymous(anon);
            e.setFromName(anon ? "匿名同学" : names.get(g.getFromSno()));
            e.setTotalScore(g.getTotalScore());
            e.setDimensionScores(parseJson(g.getDimScores()));
            e.setComment(g.getComment());
            e.setSealedAt(g.getSealedAt());
            e.setVerifyCode(g.getVerifyCode());
            e.setEvidenceLevel(g.getEvidenceLevel() == null ? null : g.getEvidenceLevel().name());
            e.setDisputeFlag(g.getDisputeFlag());
            list.add(e);
        }
        return list;
    }

    private List<DataExportVO.CreditItem> buildCredit(List<CreditLedger> ledgers) {
        List<DataExportVO.CreditItem> list = new ArrayList<>();
        for (CreditLedger l : ledgers) {
            DataExportVO.CreditItem c = new DataExportVO.CreditItem();
            c.setDelta(l.getDelta());
            c.setScoreAfter(l.getScoreAfter());
            c.setReason(l.getReason());
            c.setRemark(l.getRemark());
            c.setCreatedAt(l.getCreatedAt());
            list.add(c);
        }
        return list;
    }

    private List<DataExportVO.MessageItem> buildMessages(Set<Long> recordIds,
                                                        List<ExchangeRecord> records, String sno) {
        if (recordIds.isEmpty()) {
            return List.of();
        }
        List<CollabMessage> msgs = messageMapper.selectList(new LambdaQueryWrapper<CollabMessage>()
                .in(CollabMessage::getRecordId, recordIds)
                .eq(CollabMessage::getSenderSno, sno)
                .orderByAsc(CollabMessage::getCreatedAt));
        if (msgs.isEmpty()) {
            return List.of();
        }

        Map<Long, String> recordNos = records.stream()
                .filter(r -> r.getRecordNo() != null)
                .collect(Collectors.toMap(ExchangeRecord::getId, ExchangeRecord::getRecordNo, (a, b) -> a));
        Set<Long> fileIds = msgs.stream().map(CollabMessage::getFileId)
                .filter(java.util.Objects::nonNull).collect(Collectors.toCollection(LinkedHashSet::new));
        Map<Long, String> fileNames = fileIds.isEmpty() ? Map.of()
                : fileMapper.selectList(new LambdaQueryWrapper<com.nwu.zhiyi.domain.entity.CollabFile>()
                        .in(com.nwu.zhiyi.domain.entity.CollabFile::getId, fileIds))
                .stream().collect(Collectors.toMap(
                        com.nwu.zhiyi.domain.entity.CollabFile::getId,
                        com.nwu.zhiyi.domain.entity.CollabFile::getFileName, (a, b) -> a));

        List<DataExportVO.MessageItem> list = new ArrayList<>();
        for (CollabMessage m : msgs) {
            DataExportVO.MessageItem item = new DataExportVO.MessageItem();
            item.setRecordNo(recordNos.get(m.getRecordId()));
            item.setContent(m.getContent());
            item.setFileName(m.getFileId() == null ? null : fileNames.get(m.getFileId()));
            item.setCreatedAt(m.getCreatedAt());
            list.add(item);
        }
        return list;
    }

    /* ---------------- 公共查询 ---------------- */

    private Map<Long, String> loadSkillNames(Set<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return skillMapper.selectList(new LambdaQueryWrapper<Skill>().in(Skill::getId, ids))
                .stream().collect(Collectors.toMap(Skill::getId, Skill::getName, (a, b) -> a));
    }

    private Map<String, String> loadDisplayNames(Set<String> snos) {
        if (snos.isEmpty()) {
            return Map.of();
        }
        return studentMapper.selectList(new LambdaQueryWrapper<Student>().in(Student::getSno, snos))
                .stream().collect(Collectors.toMap(Student::getSno, Student::displayName, (a, b) -> a));
    }

    /** 把维度分 JSON 解析成 Map；解析失败返回 null 而不是抛异常（导出不应因一条脏数据失败） */
    private Map<String, Object> parseJson(String json) {
        if (json == null || json.isBlank()) {
            return null;
        }
        try {
            JSONObject obj = JSONUtil.parseObj(json);
            Map<String, Object> map = new LinkedHashMap<>();
            for (String key : obj.keySet()) {
                map.put(key, obj.get(key));
            }
            return map;
        } catch (Exception ex) {
            log.warn("[数据导出] 维度分 JSON 解析失败，已跳过：{}", json);
            return null;
        }
    }
}
