package com.nwu.zhiyi.service.profile;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.profile.AbilityReportVO;
import com.nwu.zhiyi.api.dto.profile.BadgeVO;
import com.nwu.zhiyi.api.dto.profile.GrowthTrendVO;
import com.nwu.zhiyi.api.dto.profile.RadarChartVO;
import com.nwu.zhiyi.api.dto.collab.ProcessSummaryVO;
import com.nwu.zhiyi.common.enums.AbilityDimension;
import com.nwu.zhiyi.common.enums.EvidenceLevel;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.domain.entity.AbilityProfile;
import com.nwu.zhiyi.domain.entity.Badge;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.GrowthReport;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.entity.UserBadge;
import com.nwu.zhiyi.domain.mapper.AbilityProfileMapper;
import com.nwu.zhiyi.domain.mapper.BadgeMapper;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.GrowthReportMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.domain.mapper.UserBadgeMapper;
import com.nwu.zhiyi.service.collab.WorkspaceService;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.WeekFields;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 数字档案与能力画像服务实现（模块 M7）。
 *
 * <p><b>雷达图为什么实时算而不只读快照</b>：AC-06 的验收标准是
 * 「雷达图随协作数据变化正确刷新」。若只读月度快照，用户完成一次交换后
 * 要等到下个月才看到变化，验收会直接不通过。因此：
 * <ul>
 *   <li>主页雷达图 = <b>实时计算</b>（保证即时刷新）；</li>
 *   <li>快照 = <b>定时落库</b>（供成长轨迹画历史曲线，实时算不出历史）；</li>
 *   <li>两者共用 {@link ProfileCalculator}，口径天然一致。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ProfileServiceImpl implements ProfileService {

    private final ProfileCalculator calculator;
    private final AbilityProfileMapper profileMapper;
    private final GrowthReportMapper reportMapper;
    private final BadgeMapper badgeMapper;
    private final UserBadgeMapper userBadgeMapper;
    private final StudentMapper studentMapper;
    private final ExchangeRecordMapper exchangeMapper;
    private final EvaluationGradeMapper evaluationMapper;
    private final SkillMapper skillMapper;
    private final WorkspaceService workspaceService;
    private final NotificationService notificationService;

    private static final DateTimeFormatter MONTH_FMT = DateTimeFormatter.ofPattern("yyyy-MM");

    /** 统计口径说明（前端直接展示，避免用户误解数字含义） */
    private static final String CALIBER_NOTE =
            "维度分 = 该维度下各次已完成交换的互评总分按协作时长加权平均；"
                    + "「沟通协作」取互评的沟通效率维度分。"
                    + "只统计你「提供出去」的技能所属维度 —— 教别人什么才证明你会什么。"
                    + "无样本的维度显示为空，不按 0 分计。";

    /* ==================== 雷达图（FR-M7-01 / FR-M7-02） ==================== */

    @Override
    public RadarChartVO radar(String sno) {
        Student student = requireStudent(sno);
        /*
         * 顺手评估一次勋章。
         *
         * 勋章若只靠每日定时任务授予，用户完成交换后勋章状态不会立刻变化，
         * 而 AC-06 要求「随协作数据变化正确刷新」。因此读取画像时按需评估一次
         * （幂等：已拥有的不会重复授予），定时任务只作为兜底。
         */
        safeGrantBadges(sno);
        ProfileCalculator.Result r = calculator.compute(sno);

        RadarChartVO vo = new RadarChartVO();
        vo.setSno(sno);
        vo.setName(student.displayName());
        vo.setCollege(student.getCollege());
        vo.setMajor(student.getMajor());
        vo.setSampleCount(r.exchangeCount());
        vo.setAvgScore(r.avgScore());
        vo.setTotalHours(r.totalHours());
        vo.setOverallScore(r.overall());
        vo.setCaliberNote(CALIBER_NOTE);
        vo.setInsufficientData(r.samples().isEmpty());

        List<RadarChartVO.DimensionScore> dims = new ArrayList<>();
        Map<String, BigDecimal> scoreMap = new LinkedHashMap<>();
        for (AbilityDimension d : AbilityDimension.values()) {
            RadarChartVO.DimensionScore ds = new RadarChartVO.DimensionScore();
            ds.setKey(d.getKey());
            ds.setLabel(d.getLabel());
            ds.setDescription(d.getDescription());
            ds.setScore(r.dimScores().get(d.getKey()));
            ds.setSampleCount(r.dimCounts().get(d.getKey()));
            ds.setEvidence(r.dimEvidence().get(d.getKey()));
            ds.setSkills(r.dimSkills().get(d.getKey()));
            ds.setMax(100);
            dims.add(ds);
            scoreMap.put(d.getKey(), r.dimScores().get(d.getKey()));
        }
        vo.setDimensions(dims);
        vo.setScoreMap(scoreMap);
        return vo;
    }

    /* ==================== 快照（FR-M7-03） ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long snapshot(String sno, String period, String periodType) {
        ProfileCalculator.Result r = calculator.compute(sno);
        if (r.samples().isEmpty()) {
            // 无样本不落快照：空快照会在成长曲线上画出一个假的数据点
            log.debug("[能力画像] {} 无已完成交换样本，跳过快照", sno);
            return null;
        }

        JSONObject dims = new JSONObject(true);
        r.dimScores().forEach((k, v) -> dims.set(k, v));

        JSONObject raw = new JSONObject(true);
        raw.set("caliber", CALIBER_NOTE);
        raw.set("sampleCount", r.exchangeCount());
        raw.set("evidence", r.dimEvidence());
        raw.set("skills", r.dimSkills());

        AbilityProfile existing = profileMapper.selectOne(new LambdaQueryWrapper<AbilityProfile>()
                .eq(AbilityProfile::getSno, sno)
                .eq(AbilityProfile::getPeriod, period)
                .eq(AbilityProfile::getPeriodType, periodType));

        AbilityProfile profile = new AbilityProfile()
                .setSno(sno)
                .setPeriod(period)
                .setPeriodType(periodType)
                .setDims(dims.toString())
                .setSampleCount(r.exchangeCount())
                .setAvgScore(r.avgScore())
                .setTotalHours(r.totalHours())
                .setRawInputs(raw.toString());

        if (existing != null) {
            // 同一周期重跑批处理：更新而非新增，避免成长曲线出现重复点
            profile.setId(existing.getId());
            profileMapper.updateById(profile);
            return existing.getId();
        }
        profileMapper.insert(profile);
        log.info("[能力画像] 生成快照 sno={} period={} 样本={} 综合={}",
                sno, period, r.samples().size(), r.overall());
        return profile.getId();
    }

    /** 批量刷新全部学生的当月快照（定时任务调用） */
    public int snapshotAll() {
        String period = LocalDate.now().format(MONTH_FMT);
        List<Student> students = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                .select(Student::getSno));
        int count = 0;
        for (Student s : students) {
            try {
                if (snapshot(s.getSno(), period, AbilityProfile.TYPE_MONTH) != null) {
                    count++;
                }
            } catch (Exception e) {
                log.warn("[能力画像] 快照失败 sno={} - {}", s.getSno(), e.getMessage());
            }
        }
        return count;
    }

    /* ==================== 成长轨迹（FR-M7-07） ==================== */

    @Override
    public GrowthTrendVO growthTrend(String sno, int limit) {
        int max = Math.min(36, Math.max(1, limit <= 0 ? 12 : limit));
        List<AbilityProfile> snapshots = profileMapper.selectList(new LambdaQueryWrapper<AbilityProfile>()
                .eq(AbilityProfile::getSno, sno)
                .orderByAsc(AbilityProfile::getPeriod));
        // 只取最近 max 个时间点
        if (snapshots.size() > max) {
            snapshots = snapshots.subList(snapshots.size() - max, snapshots.size());
        }

        GrowthTrendVO vo = new GrowthTrendVO();
        vo.setSno(sno);
        vo.setPointCount(snapshots.size());
        vo.setDimensionLabels(AbilityDimension.labelTable());
        vo.setNote("数据来自每月自动生成的能力画像快照。快照保留历史状态，"
                + "因此曲线能反映真实变化；实时值请以雷达图为准。");

        List<String> periods = snapshots.stream().map(AbilityProfile::getPeriod).toList();
        vo.setPeriods(periods);

        // 每个维度一条序列，长度与 periods 对齐（缺失位置为 null，前端断线处理）
        Map<String, List<BigDecimal>> series = new LinkedHashMap<>();
        for (AbilityDimension d : AbilityDimension.values()) {
            List<BigDecimal> line = new ArrayList<>();
            for (AbilityProfile p : snapshots) {
                line.add(readDim(p.getDims(), d.getKey()));
            }
            series.put(d.getKey(), line);
        }
        vo.setSeries(series);

        // 变化摘要：首末对比
        List<GrowthTrendVO.ChangeSummary> changes = new ArrayList<>();
        for (AbilityDimension d : AbilityDimension.values()) {
            List<BigDecimal> line = series.get(d.getKey()).stream()
                    .filter(java.util.Objects::nonNull).toList();
            if (line.size() < 2) {
                continue;
            }
            BigDecimal first = line.get(0);
            BigDecimal latest = line.get(line.size() - 1);
            GrowthTrendVO.ChangeSummary cs = new GrowthTrendVO.ChangeSummary();
            cs.setKey(d.getKey());
            cs.setLabel(d.getLabel());
            cs.setFirst(first);
            cs.setLatest(latest);
            BigDecimal delta = latest.subtract(first).setScale(2, RoundingMode.HALF_UP);
            cs.setDelta(delta);
            cs.setImproved(delta.compareTo(BigDecimal.ZERO) >= 0);
            changes.add(cs);
        }
        changes.sort(Comparator.comparing(GrowthTrendVO.ChangeSummary::getDelta).reversed());
        vo.setChanges(changes);
        return vo;
    }

    private BigDecimal readDim(String dimsJson, String key) {
        if (dimsJson == null || dimsJson.isBlank()) {
            return null;
        }
        try {
            Object v = JSONUtil.parseObj(dimsJson).get(key);
            if (v == null || "null".equals(String.valueOf(v))) {
                return null;
            }
            return new BigDecimal(String.valueOf(v));
        } catch (Exception e) {
            return null;
        }
    }

    /* ==================== 勋章（FR-M7-04） ==================== */

    @Override
    public List<BadgeVO> badges(String sno) {
        safeGrantBadges(sno);
        List<Badge> all = badgeMapper.selectList(new LambdaQueryWrapper<Badge>()
                .orderByAsc(Badge::getId));
        Map<Long, UserBadge> owned = userBadgeMapper.selectList(new LambdaQueryWrapper<UserBadge>()
                        .eq(UserBadge::getSno, sno)).stream()
                .collect(Collectors.toMap(UserBadge::getBadgeId, b -> b, (a, b) -> a));
        MetricSnapshot metrics = collectMetrics(sno);

        List<BadgeVO> result = new ArrayList<>();
        for (Badge b : all) {
            BadgeVO vo = new BadgeVO();
            vo.setId(b.getId());
            vo.setCode(b.getCode());
            vo.setName(b.getName());
            vo.setDescription(b.getDescription());
            vo.setIcon(b.getIcon());
            vo.setLevel(b.getLevel() == null ? null : String.valueOf(b.getLevel()));
            vo.setConditionText(b.getConditionExpr());

            UserBadge ub = owned.get(b.getId());
            vo.setUnlocked(ub != null);
            if (ub != null) {
                vo.setGrantedAt(ub.getGrantedAt());
                vo.setRefRecordId(ub.getRefRecordId());
            }
            // 进度提示：让用户知道"还差什么"，这是激励设计的关键
            int current = metrics.valueOf(b.getConditionExpr());
            int target = metricTarget(b.getConditionExpr());
            vo.setCurrentValue(current);
            vo.setTargetValue(target);
            if (ub == null) {
                vo.setProgressHint(String.format("%s（当前 %d / 目标 %d）",
                        b.getConditionExpr(), current, target));
            }
            result.add(vo);
        }
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public List<BadgeVO> grantBadges(String sno) {
        List<Badge> all = badgeMapper.selectList(new LambdaQueryWrapper<Badge>());
        Set<Long> owned = userBadgeMapper.selectList(new LambdaQueryWrapper<UserBadge>()
                        .eq(UserBadge::getSno, sno)).stream()
                .map(UserBadge::getBadgeId).collect(Collectors.toSet());
        MetricSnapshot metrics = collectMetrics(sno);

        List<BadgeVO> newly = new ArrayList<>();
        for (Badge b : all) {
            if (owned.contains(b.getId())) {
                continue;
            }
            if (!metrics.satisfies(b.getConditionExpr())) {
                continue;
            }
            UserBadge ub = new UserBadge()
                    .setSno(sno)
                    .setBadgeId(b.getId())
                    .setGrantedAt(LocalDateTime.now())
                    .setRefRecordId(metrics.latestRecordId);
            userBadgeMapper.insert(ub);

            BadgeVO vo = new BadgeVO();
            vo.setId(b.getId());
            vo.setCode(b.getCode());
            vo.setName(b.getName());
            vo.setDescription(b.getDescription());
            vo.setIcon(b.getIcon());
            vo.setLevel(b.getLevel() == null ? null : String.valueOf(b.getLevel()));
            vo.setUnlocked(true);
            vo.setGrantedAt(ub.getGrantedAt());
            newly.add(vo);

            notificationService.send(sno, NotificationType.BADGE,
                    "获得新勋章：" + b.getName(),
                    StringUtils.hasText(b.getDescription()) ? b.getDescription() : b.getConditionExpr(),
                    "BADGE", b.getId());
            log.info("[勋章授予] sno={} 获得「{}」", sno, b.getName());
        }
        return newly;
    }

    /**
     * 勋章条件求值所需的指标快照。
     *
     * <p>刻意做成"先算一次指标、再对多个条件求值"，避免每个勋章各查一遍数据库。
     * 规则解析支持 {@code zy_badge.condition_expr} 里已定义的四种变量与
     * {@code >=} / {@code >} / {@code AND} 组合，够用且无需引入脚本引擎。
     */
    private static final class MetricSnapshot {
        int completedExchange;
        int distinctCollege;
        int skillLearners;
        int avgScore;
        int creditScore;
        Long latestRecordId;

        /** 解析并求值条件表达式 */
        boolean satisfies(String expr) {
            return evaluate(expr, true) > 0;
        }

        /** 取表达式中"主指标"的当前值，用于进度提示 */
        int valueOf(String expr) {
            String var = primaryVar(expr);
            return value(var);
        }

        int value(String var) {
            if (var == null) {
                return 0;
            }
            switch (var) {
                case "completed_exchange":
                    return completedExchange;
                case "distinct_college":
                    return distinctCollege;
                case "skill_learners":
                    return skillLearners;
                case "avg_score":
                    return avgScore;
                case "credit_score":
                    return creditScore;
                default:
                    return 0;
            }
        }

        /** 求值：返回 1 表示满足，0 表示不满足 */
        private int evaluate(String expr, boolean all) {
            if (expr == null || expr.isBlank()) {
                return 0;
            }
            String[] clauses = expr.toUpperCase().contains(" AND ")
                    ? expr.split("(?i)\\s+AND\\s+") : new String[]{expr};
            int ok = 1;
            for (String clause : clauses) {
                if (!evaluateSingle(clause.trim())) {
                    ok = 0;
                    break;
                }
            }
            return ok;
        }

        private boolean evaluateSingle(String clause) {
            String op = clause.contains(">=") ? ">=" : (clause.contains(">") ? ">" : null);
            if (op == null) {
                return false;
            }
            int idx = clause.indexOf(op);
            String left = clause.substring(0, idx).trim();
            String right = clause.substring(idx + op.length()).trim();
            try {
                int actual = value(left);
                int target = Integer.parseInt(right);
                return ">=".equals(op) ? actual >= target : actual > target;
            } catch (NumberFormatException e) {
                log.warn("[勋章] 条件表达式无法解析：{}", clause);
                return false;
            }
        }

        private static String primaryVar(String expr) {
            if (expr == null) {
                return null;
            }
            for (String v : List.of("completed_exchange", "distinct_college",
                    "skill_learners", "avg_score", "credit_score")) {
                if (expr.contains(v)) {
                    return v;
                }
            }
            return null;
        }
    }

    /**
     * 安全地评估并授予勋章。
     *
     * <p>包一层 try/catch：勋章授予是"锦上添花"的副作用，
     * 失败绝不能影响画像/报告的读取。同时它是幂等的 ——
     * 已拥有的勋章不会重复授予。
     */
    private void safeGrantBadges(String sno) {
        try {
            grantBadges(sno);
        } catch (Exception e) {
            log.warn("[勋章] 按需评估失败（不影响画像读取）sno={} - {}", sno, e.getMessage());
        }
    }
    /** 目标值（表达式右侧数字），用于进度提示 */
    private int metricTarget(String expr) {
        if (expr == null) {
            return 0;
        }
        java.util.regex.Matcher m = java.util.regex.Pattern.compile("(>=|>)\\s*(\\d+)").matcher(expr);
        return m.find() ? Integer.parseInt(m.group(2)) : 0;
    }

    /** 汇总勋章条件所需的全部指标（一次查询算完） */
    private MetricSnapshot collectMetrics(String sno) {
        MetricSnapshot m = new MetricSnapshot();
        Student student = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getCreditScore)
                .eq(Student::getSno, sno));
        m.creditScore = student == null || student.getCreditScore() == null ? 0 : student.getCreditScore();

        List<ExchangeRecord> done = exchangeMapper.selectList(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.COMPLETED)
                .and(w -> w.eq(ExchangeRecord::getGiverSno, sno).or().eq(ExchangeRecord::getTakerSno, sno)));
        m.completedExchange = done.size();
        if (!done.isEmpty()) {
            m.latestRecordId = done.stream()
                    .max(Comparator.comparing(ExchangeRecord::getId)).map(ExchangeRecord::getId).orElse(null);
        }

        // 去重学院数：与我完成过协作的对方的学院
        Set<String> colleges = new LinkedHashSet<>();
        Set<String> peerSnos = new LinkedHashSet<>();
        for (ExchangeRecord r : done) {
            String peer = r.getGiverSno().equals(sno) ? r.getTakerSno() : r.getGiverSno();
            if (peer != null) {
                peerSnos.add(peer);
            }
        }
        if (!peerSnos.isEmpty()) {
            studentMapper.selectBriefBySnos(peerSnos).forEach(s -> {
                if (StringUtils.hasText(s.getCollege())) {
                    colleges.add(s.getCollege());
                }
            });
        }
        m.distinctCollege = colleges.size();

        // "教会了几个人"：我作为提供方完成过的交换数（同一人多次只算一人）
        Set<String> learners = new LinkedHashSet<>();
        for (ExchangeRecord r : done) {
            if (r.getGiverSno().equals(sno) && r.getTakerSno() != null) {
                learners.add(r.getTakerSno());
            }
        }
        m.skillLearners = learners.size();

        // 收到的互评平均分
        List<EvaluationGrade> received = evaluationMapper.selectList(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getToSno, sno));
        m.avgScore = received.isEmpty() ? 0
                : received.stream().map(EvaluationGrade::getTotalScore)
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(received.size()), 0, RoundingMode.HALF_UP)
                .intValue();
        return m;
    }

    /* ==================== 能力鉴定报告（FR-M7-06 / FR-M7-08） ==================== */

    @Override
    public AbilityReportVO report(String sno) {
        Student student = requireStudent(sno);
        RadarChartVO radar = radar(sno);

        AbilityReportVO vo = new AbilityReportVO();
        vo.setSno(sno);
        vo.setName(student.displayName());
        vo.setCollege(student.getCollege());
        vo.setMajor(student.getMajor());
        vo.setGrade(asText(student.getGrade()));
        vo.setCreditScore(student.getCreditScore());
        vo.setCreditLevel(asText(student.getCreditLevel()));
        vo.setGeneratedAt(LocalDateTime.now().withNano(0));

        vo.setDimensions(radar.getDimensions());
        vo.setOverallScore(radar.getOverallScore());
        vo.setSampleCount(radar.getSampleCount());
        vo.setTotalHours(radar.getTotalHours());
        vo.setAvgScore(radar.getAvgScore());
        vo.setPeriodText("截至 " + LocalDate.now() + " 的全部已完成协作");

        vo.setExchanges(buildExchangeItems(sno));
        vo.setBadges(badges(sno).stream().filter(Boolean.TRUE::equals).toList().isEmpty()
                ? badges(sno).stream().filter(b -> Boolean.TRUE.equals(b.getUnlocked())).toList()
                : badges(sno).stream().filter(b -> Boolean.TRUE.equals(b.getUnlocked())).toList());
        vo.setStrengths(buildStrengths(radar));
        vo.setBehaviorSummary(buildBehaviorSummary(sno));
        vo.setCaliber(Map.of(
                "caliber", CALIBER_NOTE,
                "timeWeighted", true,
                "providedSkillOnly", true));

        // 校验码取自该用户收到的最近一条互评 —— 报告的可验真锚点（M6 链路）
        EvaluationGrade latest = evaluationMapper.selectOne(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getToSno, sno)
                .orderByDesc(EvaluationGrade::getSealedAt)
                .last("LIMIT 1"));
        if (latest != null && StringUtils.hasText(latest.getVerifyCode())) {
            vo.setVerifyCode(latest.getVerifyCode());
            vo.setVerifyUrl("/api/certificates/" + latest.getVerifyCode());
            EvidenceLevel level = latest.getEvidenceLevel() == null
                    ? EvidenceLevel.HASH : latest.getEvidenceLevel();
            vo.setEvidenceLevel(level.getLabel());
            vo.setIntegrityNote(level.getDescription()
                    + "。注意：哈希固化可检出字段级篡改，但不能防止有库权限者同步重算哈希，"
                    + "外部锚定（可信时间戳/联盟链）将在后续阶段接入。");
        } else {
            vo.setEvidenceLevel(null);
            vo.setIntegrityNote("暂无互评存证记录，本报告不含可验真凭证。");
        }
        vo.setReportNo(String.format("RPT-%s-%s", LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE),
                StringUtils.hasText(vo.getVerifyCode()) ? vo.getVerifyCode() : "00000000"));

        vo.setDisclaimer("本报告由「知驿·漫游」平台依据平台内真实协作记录与双向互评自动生成。"
                + "维度分为该维度下已完成交换的互评总分按协作时长加权平均，仅统计持有人"
                + "「提供出去」的技能；无样本维度不计入。报告数据可通过校验码在线验真。");
        return vo;
    }

    /** 协作履历明细 */
    private List<AbilityReportVO.ExchangeRecordItem> buildExchangeItems(String sno) {
        List<ExchangeRecord> done = exchangeMapper.selectList(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.COMPLETED)
                .and(w -> w.eq(ExchangeRecord::getGiverSno, sno).or().eq(ExchangeRecord::getTakerSno, sno))
                .orderByDesc(ExchangeRecord::getFinishedAt));
        if (done.isEmpty()) {
            return List.of();
        }

        Set<String> peerSnos = new LinkedHashSet<>();
        Set<Long> skillIds = new LinkedHashSet<>();
        Set<Long> recordIds = new LinkedHashSet<>();
        for (ExchangeRecord r : done) {
            peerSnos.add(r.getGiverSno().equals(sno) ? r.getTakerSno() : r.getGiverSno());
            skillIds.add(r.getGiveSkillId());
            skillIds.add(r.getLearnSkillId());
            recordIds.add(r.getId());
        }
        peerSnos.remove(null);
        skillIds.remove(null);
        Map<String, Student> peers = peerSnos.isEmpty() ? Map.of()
                : studentMapper.selectBriefBySnos(peerSnos).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));
        Map<Long, Skill> skills = skillIds.isEmpty() ? Map.of()
                : skillMapper.selectBatchIds(skillIds).stream()
                .collect(Collectors.toMap(Skill::getId, s -> s, (a, b) -> a));
        Map<Long, EvaluationGrade> received = evaluationMapper.selectList(
                        new LambdaQueryWrapper<EvaluationGrade>()
                                .eq(EvaluationGrade::getToSno, sno)
                                .in(EvaluationGrade::getRecordId, recordIds)).stream()
                .collect(Collectors.toMap(EvaluationGrade::getRecordId, g -> g, (a, b) -> a));

        List<AbilityReportVO.ExchangeRecordItem> items = new ArrayList<>();
        for (ExchangeRecord r : done) {
            AbilityReportVO.ExchangeRecordItem item = new AbilityReportVO.ExchangeRecordItem();
            item.setRecordNo(r.getRecordNo());
            item.setTitle(r.getTitle());
            String peer = r.getGiverSno().equals(sno) ? r.getTakerSno() : r.getGiverSno();
            Student p = peers.get(peer);
            item.setPeerName(p == null ? peer : p.displayName());
            boolean isGiver = r.getGiverSno().equals(sno);
            Skill give = skills.get(r.getGiveSkillId());
            Skill learn = skills.get(r.getLearnSkillId());
            item.setProvidedSkill(isGiver
                    ? (give == null ? null : give.getName())
                    : (learn == null ? null : learn.getName()));
            item.setAcquiredSkill(isGiver
                    ? (learn == null ? null : learn.getName())
                    : (give == null ? null : give.getName()));
            item.setStatusLabel(r.getStatus() == null ? null : r.getStatus().getLabel());
            item.setFinishedAt(r.getFinishedAt() == null ? null : r.getFinishedAt().toLocalDate());
            item.setHours(r.getActualHours() != null ? r.getActualHours()
                    : (r.getExpectedHours() == null ? null : BigDecimal.valueOf(r.getExpectedHours())));

            EvaluationGrade g = received.get(r.getId());
            if (g != null) {
                item.setReceivedScore(g.getTotalScore());
                item.setComment(g.anonymousSubmission() ? "（匿名评价）" : g.getComment());
            }
            items.add(item);
        }
        return items;
    }

    /** 代表性长项：得分最高的两个维度 */
    private List<String> buildStrengths(RadarChartVO radar) {
        return radar.getDimensions().stream()
                .filter(d -> d.getScore() != null)
                .sorted(Comparator.comparing(RadarChartVO.DimensionScore::getScore).reversed())
                .limit(2)
                .map(d -> String.format("%s %.1f 分：%s", d.getLabel(), d.getScore(),
                        d.getSkills().isEmpty() ? "—" : String.join("、", d.getSkills())))
                .toList();
    }

    /** 客观行为摘要（引用 M5 过程性指标，体现"主观互评 + 客观行为"互相印证） */
    private String buildBehaviorSummary(String sno) {
        List<ExchangeRecord> done = exchangeMapper.selectList(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.COMPLETED)
                .and(w -> w.eq(ExchangeRecord::getGiverSno, sno).or().eq(ExchangeRecord::getTakerSno, sno)));
        if (done.isEmpty()) {
            return "暂无已完成的协作记录。";
        }
        int totalTasks = 0;
        int doneTasks = 0;
        int messages = 0;
        int files = 0;
        for (ExchangeRecord r : done) {
            try {
                ProcessSummaryVO s = workspaceService.processSummary(r.getId(), sno);
                totalTasks += s.getTaskTotal() == null ? 0 : s.getTaskTotal();
                doneTasks += s.getTaskDone() == null ? 0 : s.getTaskDone();
                messages += s.getMessageTotal() == null ? 0 : s.getMessageTotal();
                files += s.getFileUploadTotal() == null ? 0 : s.getFileUploadTotal();
            } catch (Exception e) {
                log.debug("[能力报告] 过程指标读取失败 record={} - {}", r.getId(), e.getMessage());
            }
        }
        return String.format("完成协作 %d 次；过程记录任务 %d 项（完成 %d 项，完成率 %s）；"
                        + "协作留言 %d 条，交付文件 %d 份。",
                done.size(), totalTasks, doneTasks,
                totalTasks == 0 ? "—" : Math.round(doneTasks * 100.0 / totalTasks) + "%",
                messages, files);
    }

    /* ==================== 成长周报（FR-M7-05） ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long generateWeeklyReport(String sno) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);
        LocalDate weekEnd = weekStart.plusDays(6);
        String weekKey = String.format("%d-W%02d", weekStart.getYear(),
                weekStart.get(WeekFields.ISO.weekOfWeekBasedYear()));

        GrowthReport existing = reportMapper.selectOne(new LambdaQueryWrapper<GrowthReport>()
                .eq(GrowthReport::getSno, sno)
                .eq(GrowthReport::getWeekKey, weekKey));
        if (existing != null) {
            // 同一周只生成一次（幂等），重跑不覆盖已有总结
            return existing.getId();
        }

        // 本周窗口内完成的交换
        LocalDateTime from = weekStart.atStartOfDay();
        LocalDateTime to = weekEnd.plusDays(1).atStartOfDay();
        List<ExchangeRecord> finished = exchangeMapper.selectList(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.COMPLETED)
                .ge(ExchangeRecord::getFinishedAt, from)
                .lt(ExchangeRecord::getFinishedAt, to)
                .and(w -> w.eq(ExchangeRecord::getGiverSno, sno).or().eq(ExchangeRecord::getTakerSno, sno)));

        List<EvaluationGrade> received = evaluationMapper.selectList(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getToSno, sno)
                .ge(EvaluationGrade::getSealedAt, from)
                .lt(EvaluationGrade::getSealedAt, to));

        RadarChartVO radar = radar(sno);
        List<String> highlights = new ArrayList<>();
        for (ExchangeRecord r : finished) {
            highlights.add("完成协作「" + r.getTitle() + "」");
        }
        for (EvaluationGrade g : received) {
            highlights.add("收到一条互评（" + g.getTotalScore() + " 分）");
        }
        if (highlights.isEmpty()) {
            highlights.add("本周暂无完成的协作，可以为已有的交换补充过程记录");
        }

        BigDecimal weekAvg = received.isEmpty() ? null
                : received.stream().map(EvaluationGrade::getTotalScore)
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(received.size()), 2, RoundingMode.HALF_UP);

        String summary = buildWeeklySummary(sno, finished.size(), received.size(), weekAvg, radar);

        JSONObject metrics = new JSONObject(true);
        metrics.set("exchangesFinished", finished.size());
        metrics.set("evaluationsReceived", received.size());
        metrics.set("weekAvgScore", weekAvg);
        metrics.set("totalExchanges", radar.getSampleCount());
        metrics.set("overallScore", radar.getOverallScore());

        GrowthReport report = new GrowthReport()
                .setSno(sno)
                .setWeekKey(weekKey)
                .setWeekStart(weekStart)
                .setWeekEnd(weekEnd)
                .setSummary(summary)
                .setHighlights(JSONUtil.toJsonStr(highlights))
                .setMetrics(metrics.toString());
        reportMapper.insert(report);

        notificationService.send(sno, NotificationType.SYSTEM,
                "本周成长周报已生成", summary, "GROWTH_REPORT", report.getId());
        log.info("[成长周报] 生成 sno={} week={}", sno, weekKey);
        return report.getId();
    }

    private String buildWeeklySummary(String sno, int finished, int evaluations,
                                      BigDecimal weekAvg, RadarChartVO radar) {
        StringBuilder sb = new StringBuilder();
        sb.append("本周你完成了 ").append(finished).append(" 次协作");
        if (evaluations > 0) {
            sb.append("，收到 ").append(evaluations).append(" 条互评，平均 ")
                    .append(weekAvg).append(" 分");
        }
        sb.append("。");
        if (radar.getOverallScore() != null) {
            sb.append("当前综合能力值 ").append(radar.getOverallScore()).append(" 分。");
            String best = radar.getDimensions().stream()
                    .filter(d -> d.getScore() != null)
                    .max(Comparator.comparing(RadarChartVO.DimensionScore::getScore))
                    .map(RadarChartVO.DimensionScore::getLabel).orElse(null);
            if (best != null) {
                sb.append("其中「").append(best).append("」是你的相对强项。");
            }
            String weak = radar.getDimensions().stream()
                    .filter(d -> d.getScore() != null)
                    .min(Comparator.comparing(RadarChartVO.DimensionScore::getScore))
                    .map(RadarChartVO.DimensionScore::getLabel).orElse(null);
            if (weak != null && !weak.equals(best)) {
                sb.append("「").append(weak).append("」还有提升空间，可以尝试发起相关领域的交换。");
            }
        } else {
            sb.append("完成第一次技能交换后，这里会显示你的能力画像。");
        }
        return sb.toString();
    }

    @Override
    public List<Map<String, Object>> weeklyReports(String sno, int limit) {
        int max = Math.min(52, Math.max(1, limit <= 0 ? 12 : limit));
        List<GrowthReport> list = reportMapper.selectList(new LambdaQueryWrapper<GrowthReport>()
                .eq(GrowthReport::getSno, sno)
                .orderByDesc(GrowthReport::getWeekKey)
                .last("LIMIT " + max));
        List<Map<String, Object>> result = new ArrayList<>();
        for (GrowthReport r : list) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", r.getId());
            m.put("weekKey", r.getWeekKey());
            m.put("weekStart", r.getWeekStart() == null ? null : r.getWeekStart().toString());
            m.put("weekEnd", r.getWeekEnd() == null ? null : r.getWeekEnd().toString());
            m.put("summary", r.getSummary());
            m.put("highlights", r.getHighlights() == null ? List.of() : JSONUtil.toList(r.getHighlights(), Object.class));
            m.put("metrics", r.getMetrics() == null ? Map.of() : JSONUtil.parseObj(r.getMetrics()));
            m.put("createdAt", r.getCreatedAt());
            result.add(m);
        }
        return result;
    }

    /* ==================== 工具 ==================== */

    /** 安全转字符串（用于可能为枚举或数字的字段，避免类型不匹配） */
    private static String asText(Object v) {
        return v == null ? null : String.valueOf(v);
    }
    private Student requireStudent(String sno) {
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .eq(Student::getSno, sno));
        if (s == null) {
            throw new com.nwu.zhiyi.common.exception.BusinessException(
                    com.nwu.zhiyi.common.api.ErrorCode.USER_NOT_FOUND);
        }
        return s;
    }
}
