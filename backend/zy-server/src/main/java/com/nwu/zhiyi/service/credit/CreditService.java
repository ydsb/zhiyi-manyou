package com.nwu.zhiyi.service.credit;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.CreditLevel;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.CreditLedger;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.CreditLedgerMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.governance.GovernanceAuditService;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 信用服务（FR-M8-01 / FR-M8-02）。
 *
 * <p>职责：
 * <ol>
 *   <li>按多因子模型<b>重算</b>信用值（{@link CreditCalculator}）并同步等级与并发上限；</li>
 *   <li>记录每一次变动的流水（{@code zy_credit_ledger}）—— 用户能查到"我的信用为什么掉了"；</li>
 *   <li>等级变更时发通知，并写审计日志。</li>
 * </ol>
 *
 * <p><b>为什么"重算"而不是"加减分"</b>：见 {@link CreditCalculator} 的类注释。
 * 简言之：加减分模型下"刷量"是最优策略，组合式模型让刷量无利可图。
 * 因此本服务只提供 {@link #recalculate} 作为常规入口，
 * {@link #adjust} 仅用于管理员/裁决的强制干预（会写审计日志）。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CreditService {

    private final CreditCalculator calculator;
    private final StudentMapper studentMapper;
    private final CreditLedgerMapper ledgerMapper;
    private final NotificationService notificationService;
    private final GovernanceAuditService auditService;

    /**
     * 重算某用户的信用值并落库（FR-M8-01）。
     *
     * <p>幂等：反复调用结果一致，因此可以在交换完成、评价提交、裁决执行后安心调用。
     *
     * @param sno    学号
     * @param reason 触发原因（写入流水便于追溯）
     * @return 变动结果；分数未变化时 {@code changed = false}
     */
    @Transactional(rollbackFor = Exception.class)
    public ChangeResult recalculate(String sno, String reason) {
        Student student = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .eq(Student::getSno, sno));
        if (student == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        int before = student.getCreditScore() == null ? CreditCalculator.INIT_SCORE : student.getCreditScore();
        CreditCalculator.Result r = calculator.compute(sno);
        int after = r.score();

        CreditLevel levelBefore = CreditLevel.of(before);
        CreditLevel levelAfter = CreditLevel.of(after);

        if (before == after) {
            /*
             * 分数没变也要落库：等级编号与并发上限可能因等级规则调整、
             * 或历史脏数据而不一致。只改内存对象不 updateById 等于没修。
             */
            Integer levelCodeBefore = student.getCreditLevel();
            syncLevelAndQuota(student, levelAfter, levelBefore);
            if (!java.util.Objects.equals(levelCodeBefore, student.getCreditLevel())) {
                studentMapper.updateById(student);
                log.info("[信用] {} 等级编号校正：{} → {}（分数未变）",
                        sno, levelCodeBefore, student.getCreditLevel());
            }
            return new ChangeResult(sno, before, after, levelBefore, levelAfter, false, r);
        }

        student.setCreditScore(after);
        syncLevelAndQuota(student, levelAfter, levelBefore);
        studentMapper.updateById(student);

        ledgerMapper.insert(new CreditLedger()
                .setSno(sno)
                .setDelta(after - before)
                .setScoreAfter(after)
                .setReason(reason)
                .setRemark(buildRemark(r)));

        // 等级变化时通知用户 —— 这是让用户理解"信用有什么用"的关键触点
        if (levelAfter != levelBefore) {
            boolean up = levelAfter.isHigherThan(levelBefore);
            notificationService.send(sno, NotificationType.SYSTEM,
                    up ? "信用等级提升：" + levelAfter.getLabel() : "信用等级下降：" + levelAfter.getLabel(),
                    String.format("信用值 %d → %d。当前等级「%s」：%s",
                            before, after, levelAfter.getLabel(), levelAfter.getPrivilege()),
                    "CREDIT", student.getId());
            auditService.record(GovernanceAuditService.builder()
                    .action("CREDIT_ADJUST")
                    .actorSno(GovernanceAuditService.SYSTEM)
                    .actorRole("SYSTEM")
                    .targetType("STUDENT")
                    .targetId(sno)
                    .summary(String.format("信用等级 %s → %s（信用值 %d → %d）",
                            levelBefore.getLabel(), levelAfter.getLabel(), before, after))
                    .reason("系统按多因子模型重算：" + reason)
                    .visible(true)
                    .build());
        }

        log.info("[信用] {} {} → {}（等级 {} → {}）触发原因：{}",
                sno, before, after, levelBefore.getLabel(), levelAfter.getLabel(), reason);
        return new ChangeResult(sno, before, after, levelBefore, levelAfter, true, r);
    }

    /**
     * 强制调整信用值（管理员/裁决执行，FR-M8-06）。
     *
     * <p>与 {@link #recalculate} 的区别：这是**外部强加**的处罚或补偿，
     * 不是模型算出来的。因此必须写审计日志，且理由必填。
     *
     * @param sno    学号
     * @param delta  变动值（正加负减）
     * @param reason 原因（必填）
     * @param remark 说明
     * @param audit  是否写审计日志（裁决内部执行时由裁决流程统一记录，可传 false）
     * @return 变动结果
     */
    @Transactional(rollbackFor = Exception.class)
    public ChangeResult adjust(String sno, int delta, String reason, String remark, boolean audit) {
        if (reason == null || reason.isBlank()) {
            throw new BusinessException(ErrorCode.GOVERNANCE_REASON_REQUIRED);
        }
        Student student = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .eq(Student::getSno, sno));
        if (student == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        int before = student.getCreditScore() == null ? CreditCalculator.INIT_SCORE : student.getCreditScore();
        /*
         * 信用值封闭在 0~CreditLevel.RANGE_MAX。
         *
         * 注意上界是 200 而不是 100：等级表里「优秀」需 140+、「卓越」需 180+，
         * 若上界取 100，这两档既无法达到，惩罚也会被错误地钳掉
         * （150 扣 15 分本应得 135，钳到 100 相当于多扣 35 分）。
         */
        int after = Math.max(0, Math.min(CreditLevel.RANGE_MAX, before + delta));
        CreditLevel levelBefore = CreditLevel.of(before);
        CreditLevel levelAfter = CreditLevel.of(after);

        student.setCreditScore(after);
        syncLevelAndQuota(student, levelAfter, levelBefore);
        studentMapper.updateById(student);

        ledgerMapper.insert(new CreditLedger()
                .setSno(sno)
                .setDelta(after - before)
                .setScoreAfter(after)
                .setReason(reason)
                .setRemark(remark));

        if (audit) {
            auditService.record(GovernanceAuditService.builder()
                    .action("CREDIT_ADJUST")
                    .actorSno(GovernanceAuditService.SYSTEM)
                    .actorRole("SYSTEM")
                    .targetType("STUDENT")
                    .targetId(sno)
                    .summary(String.format("信用值 %d → %d（%s）", before, after, reason))
                    .reason(remark == null ? reason : remark)
                    .visible(true)
                    .build());
        }

        notificationService.send(sno, NotificationType.SYSTEM,
                delta < 0 ? "信用值被扣减" : "信用值获得补偿",
                String.format("信用值 %d → %d。原因：%s", before, after,
                        remark == null ? reason : remark),
                "CREDIT", student.getId());

        log.info("[信用] 强制调整 {} {} → {}（{}）", sno, before, after, reason);
        return new ChangeResult(sno, before, after, levelBefore, levelAfter, before != after, null);
    }

    /**
     * 查询信用详情：当前值、等级、权限、因子明细与最近流水。
     *
     * <p>返回因子明细是本模块的重点 —— 用户必须能回答"我的信用为什么是这个数"，
     * 否则信用体系就只是一个让人困惑的数字。
     *
     * @param sno 学号
     * @return 详情
     */
    public Map<String, Object> detail(String sno) {
        Student student = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .eq(Student::getSno, sno));
        if (student == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        CreditCalculator.Result r = calculator.compute(sno);
        int current = student.getCreditScore() == null ? CreditCalculator.INIT_SCORE : student.getCreditScore();
        CreditLevel level = CreditLevel.of(current);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("sno", sno);
        data.put("name", student.displayName());
        data.put("creditScore", current);
        data.put("creditLevel", level.name());
        data.put("creditLevelLabel", level.getLabel());
        data.put("privilege", level.getPrivilege());
        data.put("exchangeQuota", level.getExchangeQuota());
        data.put("eligibleArbitrator", level.isEligibleArbitrator());
        data.put("computedScore", r.score());
        data.put("isNewUser", r.isNewUser());
        data.put("exchangeCount", r.exchangeCount());
        data.put("totalHours", r.totalHours());
        data.put("caliber", r.describe());

        // 因子明细
        List<Map<String, Object>> factors = new java.util.ArrayList<>();
        r.factors().forEach((name, f) -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("name", name);
            m.put("score", f.score() < 0 ? null : f.score());
            m.put("weight", f.weight());
            m.put("weightPercent", Math.round(f.weight() * 100));
            m.put("detail", f.detail());
            factors.add(m);
        });
        data.put("factors", factors);

        // 下一个等级的差距 —— 给用户明确的努力目标
        CreditLevel next = nextLevel(level);
        if (next != null) {
            Map<String, Object> n = new LinkedHashMap<>();
            n.put("label", next.getLabel());
            n.put("needScore", next.getMinScore());
            n.put("gap", Math.max(0, next.getMinScore() - current));
            n.put("privilege", next.getPrivilege());
            data.put("nextLevel", n);
        } else {
            data.put("nextLevel", null);
        }

        // 最近流水
        List<CreditLedger> ledger = ledgerMapper.selectList(new LambdaQueryWrapper<CreditLedger>()
                .eq(CreditLedger::getSno, sno)
                .orderByDesc(CreditLedger::getCreatedAt)
                .last("LIMIT 20"));
        data.put("ledger", ledger);
        return data;
    }

    /** 等级权限公示表（FR-M8-07，任何人可查"各等级能做什么"） */
    public List<Map<String, Object>> levelRules() {
        List<Map<String, Object>> list = new java.util.ArrayList<>();
        for (CreditLevel level : CreditLevel.values()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("level", level.name());
            m.put("label", level.getLabel());
            m.put("minScore", level.getMinScore());
            m.put("maxScore", level == CreditLevel.OUTSTANDING ? null : level.getMaxScore());
            m.put("exchangeQuota", level.getExchangeQuota());
            m.put("eligibleArbitrator", level.isEligibleArbitrator());
            m.put("privilege", level.getPrivilege());
            list.add(m);
        }
        return list;
    }

    /**
     * 同步等级与并发上限。
     *
     * <p>FR-M8-02 的核心落点：等级不只是标签，它直接改写 {@code exchange_quota}，
     * 而该字段被 M4 的邀约校验读取 —— 于是"信用低则接单受限"自动生效，
     * 不需要在各个业务里重复判断信用分。
     */
    private void syncLevelAndQuota(Student student, CreditLevel level, CreditLevel previous) {
        /*
         * 无条件写入等级编号（1~5）。
         *
         * 不能只在分数变化时写 —— 历史数据里存在 credit_level 与 credit_score
         * 不匹配的情况（早期 ordinal() 与 1~5 约定混用，注册流程又写死 1）。
         * 若只在分数变化时同步，这些脏数据会永远错着。
         * 本方法幂等，每次重算顺手校正，成本可忽略。
         */
        student.setCreditLevel(level.levelCode());
        // 管理员账号（quota=99）不参与等级配额改写，避免把测试账号限死
        if (student.getExchangeQuota() == null || student.getExchangeQuota() < 99) {
            student.setExchangeQuota(level.getExchangeQuota());
        }
    }

    private CreditLevel nextLevel(CreditLevel current) {
        CreditLevel[] all = CreditLevel.values();
        int idx = current.ordinal();
        return idx + 1 < all.length ? all[idx + 1] : null;
    }

    private String buildRemark(CreditCalculator.Result r) {
        StringBuilder sb = new StringBuilder("因子：");
        r.factors().forEach((name, f) -> {
            sb.append(name);
            sb.append(f.score() < 0 ? "无数据" : " ").append(f.score() < 0 ? "" : f.score());
            sb.append("；");
        });
        return sb.length() > 255 ? sb.substring(0, 252) + "..." : sb.toString();
    }

    /**
     * 信用变动结果。
     *
     * @param sno          学号
     * @param before       变动前
     * @param after        变动后
     * @param levelBefore  变动前等级
     * @param levelAfter   变动后等级
     * @param changed      是否真的发生变化
     * @param computed     计算结果（强制调整时为 null）
     */
    public record ChangeResult(String sno, int before, int after,
                               CreditLevel levelBefore, CreditLevel levelAfter,
                               boolean changed, CreditCalculator.Result computed) {
    }
}
