package com.nwu.zhiyi.service.admin;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.api.PageResult;
import com.nwu.zhiyi.common.enums.AuthStatus;
import com.nwu.zhiyi.common.enums.CreditLevel;
import com.nwu.zhiyi.common.enums.UserRole;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.credit.CreditService;
import com.nwu.zhiyi.domain.entity.GovernanceAudit;
import com.nwu.zhiyi.service.governance.GovernanceAuditService;
import com.nwu.zhiyi.service.notify.NotificationService;
import com.nwu.zhiyi.common.enums.NotificationType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户管理服务（FR-M9-01）。
 *
 * <p>提供：分页查询、禁用/启用、角色分配、实名核验状态维护、信用重置。
 *
 * <p><b>三条自我保护规则</b>（管理端最容易出事的地方）：
 * <ol>
 *   <li>不能对自己执行禁用/降权 —— 防止管理员误操作把自己锁在门外；</li>
 *   <li>不能操作其他管理员账号 —— 避免管理员互相封禁；</li>
 *   <li>所有写操作<b>必须填写说明</b>，并写入治理审计日志 ——
 *       管理权限越大，留痕要求越高。</li>
 * </ol>
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminUserService {

    private final StudentMapper studentMapper;
    private final CreditService creditService;
    private final GovernanceAuditService auditService;
    private final NotificationService notificationService;

    /**
     * 分页查询用户（FR-M9-01）。
     *
     * @param keyword  模糊匹配学号/姓名/昵称，可为空
     * @param college  按学院筛选，可为空
     * @param status   按账号状态筛选（1 正常 / 0 禁用），可为空
     * @param role     按角色筛选，可为空
     * @param page     页码，从 1 起
     * @param size     每页条数
     * @return 分页结果
     */
    public PageResult<Map<String, Object>> listUsers(String keyword, String college,
                                                    Integer status, String role,
                                                    int page, int size) {
        int p = Math.max(1, page);
        int s = Math.min(100, Math.max(1, size <= 0 ? 20 : size));

        LambdaQueryWrapper<Student> wrapper = new LambdaQueryWrapper<Student>()
                .orderByDesc(Student::getCreatedAt);
        if (StringUtils.hasText(keyword)) {
            String k = keyword.trim();
            wrapper.and(w -> w.like(Student::getSno, k)
                    .or().like(Student::getSname, k)
                    .or().like(Student::getNickname, k));
        }
        if (StringUtils.hasText(college)) {
            wrapper.eq(Student::getCollege, college.trim());
        }
        if (status != null) {
            wrapper.eq(Student::getStatus, status);
        }
        if (StringUtils.hasText(role)) {
            try {
                wrapper.eq(Student::getRole, UserRole.valueOf(role.trim().toUpperCase()));
            } catch (IllegalArgumentException e) {
                throw BusinessException.paramInvalid("角色取值不合法：" + role);
            }
        }

        Page<Student> result = studentMapper.selectPage(new Page<>(p, s), wrapper);
        List<Map<String, Object>> rows = result.getRecords().stream().map(this::toAdminView).toList();
        return PageResult.of(rows, result.getTotal(), p, s);
    }

    /**
     * 用户详情（含信用因子明细）。
     *
     * @param sno 学号
     * @return 详情
     */
    public Map<String, Object> userDetail(String sno) {
        Student s = requireUser(sno);
        Map<String, Object> m = toAdminView(s);
        try {
            m.put("creditDetail", creditService.detail(sno));
        } catch (Exception e) {
            log.warn("[管理端] 读取信用详情失败 sno={} - {}", sno, e.getMessage());
        }
        return m;
    }

    /**
     * 启用/禁用账号（FR-M9-01）。
     *
     * <p>禁用同时把并发上限置 0 —— 否则用户已占用的交换仍可继续，
     * "禁用"就成了半个措施。
     *
     * @param sno       目标学号
     * @param enabled   true 启用 / false 禁用
     * @param operator  操作管理员
     * @param remark    操作说明（必填）
     * @return 更新后的用户视图
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> setStatus(String sno, boolean enabled, String operator, String remark) {
        Student target = requireUser(sno);
        guard(operator, target, "调整账号状态");
        requireRemark(remark);

        target.setStatus(enabled ? 1 : 0);
        if (enabled) {
            // 恢复时按信用等级重算并发上限，而不是无条件给固定值
            CreditLevel level = CreditLevel.of(target.getCreditScore());
            target.setExchangeQuota(level.getExchangeQuota());
        } else {
            target.setExchangeQuota(0);
        }
        studentMapper.updateById(target);

        auditService.record(GovernanceAuditService.builder()
                .action(GovernanceAudit.ACTION_ACCOUNT_BAN)
                .actorSno(operator)
                .actorRole(GovernanceAudit.ROLE_ADMIN)
                .targetType("STUDENT")
                .targetId(sno)
                .summary(String.format("%s账号：%s（%s）", enabled ? "启用" : "禁用",
                        target.displayName(), sno))
                .reason(remark.trim())
                .visible(true)
                .build());

        notificationService.send(sno, NotificationType.SYSTEM,
                enabled ? "账号已恢复" : "账号已被禁用",
                enabled ? "你的账号已恢复正常使用。" : ("账号已被管理员禁用。原因：" + remark.trim()),
                "STUDENT", target.getId());

        log.info("[管理端] {} {}账号 {}，理由：{}", operator, enabled ? "启用" : "禁用", sno, remark);
        return toAdminView(target);
    }

    /**
     * 分配角色（FR-M9-01）。
     *
     * @param sno      目标学号
     * @param role     角色名：USER / ARBITRATOR / ADMIN
     * @param operator 操作管理员
     * @param remark   操作说明（必填）
     * @return 更新后的用户视图
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> assignRole(String sno, String role, String operator, String remark) {
        Student target = requireUser(sno);
        guard(operator, target, "分配角色");
        requireRemark(remark);

        UserRole newRole;
        try {
            newRole = UserRole.valueOf(role.trim().toUpperCase());
        } catch (Exception e) {
            throw BusinessException.paramInvalid("角色取值不合法，应为 USER / ARBITRATOR / ADMIN");
        }
        UserRole oldRole = target.getRole();
        if (oldRole == newRole) {
            throw BusinessException.paramInvalid("该用户当前已是「" + newRole + "」角色");
        }
        target.setRole(newRole);
        studentMapper.updateById(target);

        auditService.record(GovernanceAuditService.builder()
                .action(GovernanceAudit.ACTION_RULE_UPDATE)
                .actorSno(operator)
                .actorRole(GovernanceAudit.ROLE_ADMIN)
                .targetType("STUDENT")
                .targetId(sno)
                .summary(String.format("分配角色：%s（%s）%s → %s",
                        target.displayName(), sno, oldRole, newRole))
                .reason(remark.trim())
                .visible(true)
                .build());

        log.info("[管理端] {} 将 {} 的角色 {} → {}，理由：{}", operator, sno, oldRole, newRole, remark);
        return toAdminView(target);
    }

    /**
     * 维护实名核验状态（FR-M9-01）。
     *
     * @param sno      目标学号
     * @param status   核验状态：UNVERIFIED / PENDING / VERIFIED / FAILED
     * @param operator 操作管理员
     * @param remark   操作说明（必填）
     * @return 更新后的用户视图
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> setAuthStatus(String sno, String status, String operator, String remark) {
        Student target = requireUser(sno);
        requireRemark(remark);

        AuthStatus newStatus;
        try {
            newStatus = AuthStatus.valueOf(status.trim().toUpperCase());
        } catch (Exception e) {
            throw BusinessException.paramInvalid(
                    "核验状态不合法，应为 UNVERIFIED / PENDING / VERIFIED / FAILED");
        }
        AuthStatus old = target.getAuthStatus();
        target.setAuthStatus(newStatus);
        studentMapper.updateById(target);

        auditService.record(GovernanceAuditService.builder()
                .action(GovernanceAudit.ACTION_RULE_UPDATE)
                .actorSno(operator)
                .actorRole(GovernanceAudit.ROLE_ADMIN)
                .targetType("STUDENT")
                .targetId(sno)
                .summary(String.format("实名核验状态：%s（%s）%s → %s",
                        target.displayName(), sno, old, newStatus))
                .reason(remark.trim())
                .visible(false)
                .build());   // 核验状态涉及个人身份信息，留痕但不公示

        log.info("[管理端] {} 将 {} 的核验状态 {} → {}", operator, sno, old, newStatus);
        return toAdminView(target);
    }

    /**
     * 按多因子模型重算某用户信用值（FR-M9-01 辅助能力）。
     *
     * <p>日常无需人工干预（批处理会兜底），主要用于排查"信用值看起来不对"的反馈。
     *
     * @param sno      目标学号
     * @param operator 操作管理员
     * @param remark   操作说明（必填）
     * @return 变动结果
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> recalculateCredit(String sno, String operator, String remark) {
        requireUser(sno);
        requireRemark(remark);
        CreditService.ChangeResult r = creditService.recalculate(sno, "ADMIN_MANUAL");

        auditService.record(GovernanceAuditService.builder()
                .action(GovernanceAudit.ACTION_CREDIT_ADJUST)
                .actorSno(operator)
                .actorRole(GovernanceAudit.ROLE_ADMIN)
                .targetType("STUDENT")
                .targetId(sno)
                .summary(String.format("手动重算信用值：%d → %d", r.before(), r.after()))
                .reason(remark.trim())
                .visible(true)
                .build());

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("sno", sno);
        m.put("before", r.before());
        m.put("after", r.after());
        m.put("levelLabel", r.levelAfter().getLabel());
        m.put("changed", r.changed());
        return m;
    }

    /* ---------------- 内部校验 ---------------- */

    private Student requireUser(String sno) {
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .eq(Student::getSno, sno));
        if (s == null) {
            throw new BusinessException(ErrorCode.ADMIN_TARGET_USER_NOT_FOUND);
        }
        return s;
    }

    /**
     * 自我保护：不得对自己或其他管理员执行危险操作。
     *
     * <p>这两条规则看似简单，但管理后台最常见的生产事故就是
     * "管理员把自己封了"或"两个管理员互相封禁"。
     */
    private void guard(String operator, Student target, String action) {
        if (operator.equals(target.getSno())) {
            throw new BusinessException(ErrorCode.ADMIN_CANNOT_MODIFY_SELF,
                    "不能对自己执行「" + action + "」，请由其他管理员操作");
        }
        if (target.getRole() == UserRole.ADMIN) {
            throw new BusinessException(ErrorCode.ADMIN_CANNOT_MODIFY_ADMIN,
                    "不能对其他管理员执行「" + action + "」");
        }
    }

    private void requireRemark(String remark) {
        if (!StringUtils.hasText(remark)) {
            throw new BusinessException(ErrorCode.ADMIN_REMARK_REQUIRED);
        }
    }

    private Map<String, Object> toAdminView(Student s) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", s.getId());
        m.put("sno", s.getSno());
        m.put("name", s.displayName());
        m.put("sname", s.getSname());
        m.put("nickname", s.getNickname());
        m.put("college", s.getCollege());
        m.put("major", s.getMajor());
        m.put("grade", s.getGrade());
        m.put("email", s.getEmail());
        m.put("authType", s.getAuthType() == null ? null : s.getAuthType().name());
        m.put("authStatus", s.getAuthStatus() == null ? null : s.getAuthStatus().name());
        m.put("role", s.getRole() == null ? null : s.getRole().name());
        m.put("creditScore", s.getCreditScore());
        m.put("creditLevel", s.getCreditLevel());
        m.put("creditLevelLabel", CreditLevel.of(s.getCreditScore()).getLabel());
        m.put("exchangeQuota", s.getExchangeQuota());
        m.put("status", s.getStatus());
        m.put("statusLabel", s.getStatus() != null && s.getStatus() == 1 ? "正常" : "已禁用");
        m.put("lastLoginAt", s.getLastLoginAt());
        m.put("createdAt", s.getCreatedAt());
        return m;
    }

    /** 按学院聚合用户数（看板用） */
    public List<Map<String, Object>> collegeDistribution() {
        List<Student> all = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                .select(Student::getCollege));
        Map<String, Integer> counter = new java.util.LinkedHashMap<>();
        for (Student s : all) {
            String c = StringUtils.hasText(s.getCollege()) ? s.getCollege() : "未填写";
            counter.merge(c, 1, Integer::sum);
        }
        List<Map<String, Object>> list = new java.util.ArrayList<>();
        counter.entrySet().stream()
                .sorted((a, b) -> b.getValue() - a.getValue())
                .forEach(e -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("college", e.getKey());
                    m.put("count", e.getValue());
                    list.add(m);
                });
        return list;
    }
}
