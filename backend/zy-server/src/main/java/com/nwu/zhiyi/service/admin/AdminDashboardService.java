package com.nwu.zhiyi.service.admin;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import cn.hutool.json.JSONUtil;
import com.nwu.zhiyi.common.enums.CreditLevel;
import com.nwu.zhiyi.common.enums.DemandInterestStatus;
import com.nwu.zhiyi.common.enums.DemandStatus;
import com.nwu.zhiyi.common.enums.DisputeStatus;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.domain.entity.DashboardSnapshot;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.DemandInterest;
import com.nwu.zhiyi.domain.entity.Dispute;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.DashboardSnapshotMapper;
import com.nwu.zhiyi.domain.mapper.DemandInterestMapper;
import com.nwu.zhiyi.domain.mapper.DemandMapper;
import com.nwu.zhiyi.domain.mapper.DisputeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 运营数据看板服务（FR-M9-04）。
 *
 * <p>指标：日活、新增用户、卡片发布量、交换开始/完成量、匹配成功率、学科分布、信用分布。
 *
 * <p><b>为什么要落日快照而不是纯实时聚合</b>：
 * 趋势类指标（"上周三的日活"）在数据变化后无法回溯 —— 只能靠当时记下来。
 * 因此定时任务按日写入 {@code zy_dashboard_snapshot}，
 * 看板读快照画趋势；而当天的实时数字仍走实时查询，保证不会滞后一天。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private final StudentMapper studentMapper;
    private final DemandMapper demandMapper;
    private final DemandInterestMapper interestMapper;
    private final ExchangeRecordMapper exchangeMapper;
    private final SkillMapper skillMapper;
    private final DisputeMapper disputeMapper;
    private final AdminUserService adminUserService;
    private final DashboardSnapshotMapper dashboardSnapshotMapper;

    /**
     * 实时总览（当天数字，不依赖快照）。
     *
     * @return 指标集合
     */
    public Map<String, Object> overview() {
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();

        long userTotal = studentMapper.selectCount(null);
        long activeStatus = studentMapper.selectCount(new LambdaQueryWrapper<Student>()
                .eq(Student::getStatus, 1));
        long newToday = studentMapper.selectCount(new LambdaQueryWrapper<Student>()
                .ge(Student::getCreatedAt, todayStart));
        // 日活口径：当日有登录记录的用户数（lastLoginAt 当天）
        long activeToday = studentMapper.selectCount(new LambdaQueryWrapper<Student>()
                .ge(Student::getLastLoginAt, todayStart));

        long demandOpen = demandMapper.selectCount(new LambdaQueryWrapper<Demand>()
                .eq(Demand::getStatus, DemandStatus.OPEN));
        long demandTotal = demandMapper.selectCount(null);
        long demandToday = demandMapper.selectCount(new LambdaQueryWrapper<Demand>()
                .ge(Demand::getCreatedAt, todayStart));

        long exchangeTotal = exchangeMapper.selectCount(null);
        long exchangeInProgress = exchangeMapper.selectCount(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.IN_PROGRESS));
        long exchangeCompleted = exchangeMapper.selectCount(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.COMPLETED));
        long exchangeToday = exchangeMapper.selectCount(new LambdaQueryWrapper<ExchangeRecord>()
                .ge(ExchangeRecord::getCreatedAt, todayStart));
        long finishedToday = exchangeMapper.selectCount(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.COMPLETED)
                .ge(ExchangeRecord::getFinishedAt, todayStart));

        long skillTotal = skillMapper.selectCount(null);
        long skillEnabled = skillMapper.selectCount(new LambdaQueryWrapper<Skill>()
                .eq(Skill::getStatus, 1));
        long openDisputes = disputeMapper.selectCount(new LambdaQueryWrapper<Dispute>()
                .in(Dispute::getStatus,
                        List.of(DisputeStatus.PENDING.name(), DisputeStatus.VOTING.name())));

        Map<String, Object> m = new LinkedHashMap<>();
        // 用户
        m.put("userTotal", userTotal);
        m.put("userActive", activeStatus);
        m.put("newUsersToday", newToday);
        m.put("activeUsersToday", activeToday);
        m.put("bannedUsers", userTotal - activeStatus);
        // 供需
        m.put("demandTotal", demandTotal);
        m.put("demandOpen", demandOpen);
        m.put("demandToday", demandToday);
        // 交换
        m.put("exchangeTotal", exchangeTotal);
        m.put("exchangeInProgress", exchangeInProgress);
        m.put("exchangeCompleted", exchangeCompleted);
        m.put("exchangeStartedToday", exchangeToday);
        m.put("exchangeFinishedToday", finishedToday);
        m.put("completionRate", rate(exchangeCompleted, exchangeTotal));
        // 匹配成功率：发出邀约中被接受的比率
        long interestTotal = interestMapper.selectCount(null);
        long interestAccepted = interestMapper.selectCount(new LambdaQueryWrapper<DemandInterest>()
                .eq(DemandInterest::getStatus, DemandInterestStatus.ACCEPTED));
        m.put("inviteTotal", interestTotal);
        m.put("inviteAccepted", interestAccepted);
        m.put("matchSuccessRate", rate(interestAccepted, interestTotal));
        // 技能与治理
        m.put("skillTotal", skillTotal);
        m.put("skillEnabled", skillEnabled);
        m.put("openDisputes", openDisputes);

        m.put("collegeDistribution", adminUserService.collegeDistribution());
        m.put("creditDistribution", creditDistribution());
        m.put("skillCategoryDistribution", skillCategoryDistribution());
        m.put("generatedAt", LocalDateTime.now());
        return m;
    }

    /**
     * 信用等级分布（FR-M9-04：信用分布）。
     *
     * @return 各等级人数
     */
    public List<Map<String, Object>> creditDistribution() {
        List<Student> all = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getCreditScore));
        Map<String, Integer> counter = new LinkedHashMap<>();
        for (CreditLevel level : CreditLevel.values()) {
            counter.put(level.getLabel(), 0);
        }
        for (Student s : all) {
            counter.merge(CreditLevel.of(s.getCreditScore()).getLabel(), 1, Integer::sum);
        }
        List<Map<String, Object>> list = new ArrayList<>();
        counter.forEach((label, count) -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("label", label);
            m.put("count", count);
            list.add(m);
        });
        return list;
    }

    /**
     * 学科门类分布（FR-M9-04：学科分布）。
     *
     * @return 各门类技能标签数
     */
    public List<Map<String, Object>> skillCategoryDistribution() {
        List<Skill> all = skillMapper.selectList(new LambdaQueryWrapper<Skill>()
                .select(Skill::getCategoryL1));
        Map<String, Integer> counter = new LinkedHashMap<>();
        for (Skill s : all) {
            String c = StringUtils.hasText(s.getCategoryL1()) ? s.getCategoryL1() : "未分类";
            counter.merge(c, 1, Integer::sum);
        }
        List<Map<String, Object>> list = new ArrayList<>();
        counter.entrySet().stream()
                .sorted((a, b) -> b.getValue() - a.getValue())
                .forEach(e -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("label", e.getKey());
                    m.put("count", e.getValue());
                    list.add(m);
                });
        return list;
    }

    /**
     * 最近 N 天的趋势（读日快照）。
     *
     * @param days 天数
     * @return 趋势数据；无快照的日期返回空数组并由前端提示"需运行批处理"
     */
    public Map<String, Object> trend(int days) {
        int d = Math.min(90, Math.max(1, days <= 0 ? 14 : days));
        LocalDate from = LocalDate.now().minusDays(d - 1L);
        List<DashboardSnapshot> snaps =
                dashboardSnapshotMapper.selectList(new LambdaQueryWrapper<DashboardSnapshot>()
                        .ge(DashboardSnapshot::getStatDate, from)
                        .orderByAsc(DashboardSnapshot::getStatDate));

        List<String> dates = new ArrayList<>();
        List<Integer> activeUsers = new ArrayList<>();
        List<Integer> finished = new ArrayList<>();
        List<Integer> published = new ArrayList<>();
        for (DashboardSnapshot s : snaps) {
            dates.add(s.getStatDate().toString());
            activeUsers.add(s.getActiveUsers() == null ? 0 : s.getActiveUsers());
            finished.add(s.getExchangeFinished() == null ? 0 : s.getExchangeFinished());
            published.add(s.getDemandPublished() == null ? 0 : s.getDemandPublished());
        }

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("dates", dates);
        m.put("activeUsers", activeUsers);
        m.put("exchangeFinished", finished);
        m.put("demandPublished", published);
        m.put("snapshotCount", snaps.size());
        m.put("note", snaps.isEmpty()
                ? "暂无日快照数据。快照由定时任务每日凌晨生成，也可调用 POST /api/admin/dashboard/snapshot 手动触发。"
                : "数据来自每日快照；当天实时数字请看总览。");
        return m;
    }

    /**
     * 生成/更新当日快照（定时任务与手动触发共用）。
     *
     * @param date 统计日期
     * @return 快照 ID
     */
    @Transactional(rollbackFor = Exception.class)
    public Long snapshot(LocalDate date) {
        LocalDate d = date == null ? LocalDate.now() : date;
        LocalDateTime start = d.atStartOfDay();
        LocalDateTime end = d.plusDays(1).atStartOfDay();

        long activeUsers = studentMapper.selectCount(new LambdaQueryWrapper<Student>()
                .ge(Student::getLastLoginAt, start).lt(Student::getLastLoginAt, end));
        long newUsers = studentMapper.selectCount(new LambdaQueryWrapper<Student>()
                .ge(Student::getCreatedAt, start).lt(Student::getCreatedAt, end));
        long published = demandMapper.selectCount(new LambdaQueryWrapper<Demand>()
                .ge(Demand::getCreatedAt, start).lt(Demand::getCreatedAt, end));
        long started = exchangeMapper.selectCount(new LambdaQueryWrapper<ExchangeRecord>()
                .ge(ExchangeRecord::getCreatedAt, start).lt(ExchangeRecord::getCreatedAt, end));
        long finished = exchangeMapper.selectCount(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.COMPLETED)
                .ge(ExchangeRecord::getFinishedAt, start).lt(ExchangeRecord::getFinishedAt, end));

        long inviteTotal = interestMapper.selectCount(new LambdaQueryWrapper<DemandInterest>()
                .ge(DemandInterest::getCreatedAt, start).lt(DemandInterest::getCreatedAt, end));
        long inviteAccepted = interestMapper.selectCount(new LambdaQueryWrapper<DemandInterest>()
                .eq(DemandInterest::getStatus, DemandInterestStatus.ACCEPTED)
                .ge(DemandInterest::getCreatedAt, start).lt(DemandInterest::getCreatedAt, end));

        Map<String, Object> metrics = new LinkedHashMap<>();
        metrics.put("collegeDistribution", adminUserService.collegeDistribution());
        metrics.put("creditDistribution", creditDistribution());

        DashboardSnapshot existing =
                dashboardSnapshotMapper.selectOne(new LambdaQueryWrapper<DashboardSnapshot>()
                        .eq(DashboardSnapshot::getStatDate, d));

        DashboardSnapshot snap =
                new DashboardSnapshot()
                        .setStatDate(d)
                        .setActiveUsers((int) activeUsers)
                        .setNewUsers((int) newUsers)
                        .setDemandPublished((int) published)
                        .setExchangeStarted((int) started)
                        .setExchangeFinished((int) finished)
                        .setMatchSuccessRate(rateDecimal(inviteAccepted, inviteTotal))
                        .setMetrics(JSONUtil.toJsonStr(metrics));

        if (existing != null) {
            // 同一天重跑覆盖（唯一键），不产生重复数据点
            snap.setId(existing.getId());
            dashboardSnapshotMapper.updateById(snap);
            return existing.getId();
        }
        dashboardSnapshotMapper.insert(snap);
        log.info("[看板] 生成日快照 {}：日活 {}、完成 {}、发布 {}",
                d, activeUsers, finished, published);
        return snap.getId();
    }

    /**
     * 系统健康摘要（FR-M9 附带能力，便于管理员快速判断"平台是否正常"）。
     *
     * @return 摘要
     */
    public Map<String, Object> health() {
        Map<String, Object> m = new LinkedHashMap<>();
        long users = studentMapper.selectCount(null);
        long skills = skillMapper.selectCount(null);
        m.put("userCount", users);
        m.put("skillCount", skills);
        m.put("database", "OK");
        // 数据一致性抽查：交换双方是否存在、技能是否被引用
        long orphanExchanges = exchangeMapper.selectCount(new LambdaQueryWrapper<ExchangeRecord>()
                .and(w -> w.isNull(ExchangeRecord::getGiverSno).or().isNull(ExchangeRecord::getTakerSno)));
        m.put("orphanExchanges", orphanExchanges);
        m.put("consistencyOk", orphanExchanges == 0);
        m.put("checkedAt", LocalDateTime.now());
        return m;
    }

    private static String rate(long numerator, long denominator) {
        if (denominator <= 0) {
            return "—";
        }
        return Math.round(numerator * 100.0 / denominator) + "%";
    }

    private static BigDecimal rateDecimal(long numerator, long denominator) {
        if (denominator <= 0) {
            return null;
        }
        return BigDecimal.valueOf(numerator * 100.0 / denominator).setScale(2, RoundingMode.HALF_UP);
    }
}

