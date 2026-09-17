package com.nwu.zhiyi.service.governance;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.domain.entity.GovernanceAudit;
import com.nwu.zhiyi.domain.mapper.GovernanceAuditMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 治理审计服务（FR-M8-07 操作可追溯 / FR-M8-08 管理员干预留痕）。
 *
 * <p><b>设计原则：只追加，不修改不删除。</b>
 * 治理的公信力来自"能查" —— 每次信用调整、裁决、封禁、评价修正都应能回答
 * "谁、何时、依据什么、改了什么"。因此本服务<b>只提供写入与查询</b>，
 * 刻意不提供 update / delete 方法。
 *
 * <p><b>写入不能影响主流程</b>：审计失败不应让业务回滚（例如裁决已经生效、
 * 信用已经调整，此时审计写失败若抛出异常会造成"业务成功但被回滚"的困惑）。
 * 因此 {@link #record} 内部捕获异常，仅告警。这是有意的权衡：
 * 用极小概率的审计缺失，换业务流程的健壮性。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GovernanceAuditService {

    private final GovernanceAuditMapper auditMapper;

    /** 系统自动执行的标识 */
    public static final String SYSTEM = GovernanceAudit.SYSTEM_ACTOR;

    /**
     * 记录一条治理操作。
     *
     * @param entry 记录内容（用 {@link #builder()} 构造）
     */
    @Transactional(rollbackFor = Exception.class)
    public void record(Entry entry) {
        try {
            if (entry.action == null || entry.action.isBlank()) {
                log.warn("[治理审计] 拒绝写入：action 为空");
                return;
            }
            if (entry.summary == null || entry.summary.isBlank()) {
                log.warn("[治理审计] 拒绝写入：summary 为空（action={}）", entry.action);
                return;
            }
            GovernanceAudit audit = new GovernanceAudit()
                    .setAction(entry.action)
                    .setActorSno(entry.actorSno == null ? SYSTEM : entry.actorSno)
                    .setActorRole(entry.actorRole == null ? GovernanceAudit.ROLE_SYSTEM : entry.actorRole)
                    .setTargetType(entry.targetType)
                    .setTargetId(entry.targetId)
                    .setSummary(entry.summary)
                    .setDetail(entry.detail)
                    .setReason(entry.reason)
                    .setVisible(entry.visible == null || entry.visible ? 1 : 0);
            auditMapper.insert(audit);
            log.debug("[治理审计] {} by {} → {}", entry.action, audit.getActorSno(), entry.summary);
        } catch (Exception e) {
            // 审计是旁路，不能因为它失败而回滚已经生效的业务
            log.warn("[治理审计] 写入失败（业务不受影响）：action={} - {}", entry.action, e.getMessage());
        }
    }

    /**
     * 查询公示的治理动态（FR-M8-07）。
     *
     * <p>只返回 {@code visible = 1} 的记录 —— 涉及隐私的操作留痕但不公示。
     *
     * @param limit 条数
     * @return 公示列表
     */
    public List<Map<String, Object>> publicLog(int limit) {
        int max = Math.min(100, Math.max(1, limit <= 0 ? 30 : limit));
        List<GovernanceAudit> list = auditMapper.selectList(new LambdaQueryWrapper<GovernanceAudit>()
                .eq(GovernanceAudit::getVisible, 1)
                .orderByDesc(GovernanceAudit::getCreatedAt)
                .last("LIMIT " + max));
        return list.stream().map(this::toView).toList();
    }

    /**
     * 查询全部审计记录（管理员视角，含不公示项）。
     *
     * <p>支持按操作对象筛选，便于"查某个用户的信用为什么变了"。
     *
     * @param targetId 对象标识（学号），可为空
     * @param action   操作类型，可为空
     * @param limit    条数
     * @return 记录列表
     */
    public List<Map<String, Object>> query(String targetId, String action, int limit) {
        int max = Math.min(200, Math.max(1, limit <= 0 ? 50 : limit));
        LambdaQueryWrapper<GovernanceAudit> wrapper = new LambdaQueryWrapper<GovernanceAudit>()
                .orderByDesc(GovernanceAudit::getCreatedAt)
                .last("LIMIT " + max);
        if (targetId != null && !targetId.isBlank()) {
            wrapper.eq(GovernanceAudit::getTargetId, targetId.trim());
        }
        if (action != null && !action.isBlank()) {
            wrapper.eq(GovernanceAudit::getAction, action.trim());
        }
        return auditMapper.selectList(wrapper).stream().map(this::toView).toList();
    }

    /**
     * 统计各类治理操作的数量（公示页用，让社区看到治理的活跃度与分布）。
     *
     * @return 统计结果
     */
    public Map<String, Object> statistics() {
        List<GovernanceAudit> all = auditMapper.selectList(new LambdaQueryWrapper<GovernanceAudit>()
                .select(GovernanceAudit::getAction, GovernanceAudit::getActorRole));
        Map<String, Integer> byAction = new LinkedHashMap<>();
        Map<String, Integer> byRole = new LinkedHashMap<>();
        for (GovernanceAudit a : all) {
            byAction.merge(a.getAction(), 1, Integer::sum);
            byRole.merge(a.getActorRole(), 1, Integer::sum);
        }
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("total", all.size());
        data.put("byAction", byAction);
        data.put("byRole", byRole);
        data.put("actionLabels", ACTION_LABELS);
        return data;
    }

    /** 操作类型的中文说明（公示页展示，避免用户看到 CREDIT_ADJUST 这种内部代号） */
    public static final Map<String, String> ACTION_LABELS = Map.of(
            GovernanceAudit.ACTION_CREDIT_ADJUST, "信用值调整",
            GovernanceAudit.ACTION_DISPUTE_RESOLVE, "争议裁决",
            GovernanceAudit.ACTION_EVALUATION_AMEND, "评价修正",
            GovernanceAudit.ACTION_ACCOUNT_BAN, "账号处置",
            GovernanceAudit.ACTION_RULE_UPDATE, "规则更新",
            GovernanceAudit.ACTION_ADMIN_INTERVENE, "管理员干预",
            GovernanceAudit.ACTION_BADGE_GRANT, "勋章授予");

    private Map<String, Object> toView(GovernanceAudit a) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", a.getId());
        m.put("action", a.getAction());
        m.put("actionLabel", ACTION_LABELS.getOrDefault(a.getAction(), a.getAction()));
        m.put("actorSno", a.getActorSno());
        m.put("actorRole", a.getActorRole());
        m.put("targetType", a.getTargetType());
        m.put("targetId", a.getTargetId());
        m.put("summary", a.getSummary());
        m.put("reason", a.getReason());
        m.put("visible", a.isPublic());
        m.put("systemAction", a.isSystemAction());
        m.put("createdAt", a.getCreatedAt());
        return m;
    }

    /** 记录内容构造器（字段多，用 builder 比构造参数更可读） */
    public static EntryBuilder builder() {
        return new EntryBuilder();
    }

    /** 记录内容 */
    public static final class Entry {
        private String action;
        private String actorSno;
        private String actorRole;
        private String targetType;
        private String targetId;
        private String summary;
        private String detail;
        private String reason;
        private Boolean visible;
    }

    /** 链式构造器 */
    public static final class EntryBuilder {
        private final Entry e = new Entry();

        public EntryBuilder action(String v) {
            e.action = v;
            return this;
        }

        public EntryBuilder actorSno(String v) {
            e.actorSno = v;
            return this;
        }

        public EntryBuilder actorRole(String v) {
            e.actorRole = v;
            return this;
        }

        public EntryBuilder targetType(String v) {
            e.targetType = v;
            return this;
        }

        public EntryBuilder targetId(String v) {
            e.targetId = v;
            return this;
        }

        public EntryBuilder summary(String v) {
            e.summary = v;
            return this;
        }

        public EntryBuilder detail(String v) {
            e.detail = v;
            return this;
        }

        public EntryBuilder reason(String v) {
            e.reason = v;
            return this;
        }

        public EntryBuilder visible(boolean v) {
            e.visible = v;
            return this;
        }

        public Entry build() {
            return e;
        }
    }

    /** 供测试：当前时间（便于断言时间范围） */
    static LocalDateTime now() {
        return LocalDateTime.now();
    }
}
