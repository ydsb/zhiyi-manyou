package com.nwu.zhiyi.service.admin;

import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.api.PageResult;
import com.nwu.zhiyi.common.enums.AuditStatus;
import com.nwu.zhiyi.common.enums.DemandStatus;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.ContentReport;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.GovernanceAudit;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.ContentReportMapper;
import com.nwu.zhiyi.domain.mapper.DemandMapper;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.collab.WorkspaceService;
import com.nwu.zhiyi.service.governance.GovernanceAuditService;
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
 * 内容审核队列服务（FR-M9-03）。
 *
 * <p><b>两条并行的审核路径</b>：
 * <ol>
 *   <li><b>自动审核</b>：发卡片时 {@code DemandContentAuditor} 命中敏感词/广告特征 →
 *       卡片置为 {@code PENDING} 进入队列；</li>
 *   <li><b>用户举报</b>：其他用户举报卡片/留言/评价 → 进入本队列等待管理员处置。</li>
 * </ol>
 *
 * <p><b>为什么举报与争议要分开处理</b>：争议（{@code zy_dispute}）针对的是
 * <b>交换履约</b>问题，有当事人双方、走仲裁委员会集体表决；
 * 举报针对的是<b>内容违规</b>（广告、辱骂、虚假信息），由管理员直接处置。
 * 两者的处理主体、时限与后果完全不同，混在一起会让两种流程互相干扰。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminContentService {

    private final ContentReportMapper reportMapper;
    private final DemandMapper demandMapper;
    private final SkillMapper skillMapper;
    private final StudentMapper studentMapper;
    private final EvaluationGradeMapper evaluationMapper;
    private final WorkspaceService workspaceService;
    private final GovernanceAuditService auditService;
    private final NotificationService notificationService;

    /* ==================== 待审卡片（自动审核命中） ==================== */

    /**
     * 待审需求卡片列表。
     *
     * @param page 页码
     * @param size 每页条数
     * @return 分页结果
     */
    public PageResult<Map<String, Object>> pendingDemands(int page, int size) {
        int p = Math.max(1, page);
        int s = Math.min(100, Math.max(1, size <= 0 ? 20 : size));
        Page<Demand> result = demandMapper.selectPage(new Page<>(p, s),
                new LambdaQueryWrapper<Demand>()
                        .eq(Demand::getAuditStatus, AuditStatus.PENDING)
                        .orderByAsc(Demand::getCreatedAt));
        List<Map<String, Object>> rows = result.getRecords().stream().map(d -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", d.getId());
            m.put("demandNo", d.getDemandNo());
            m.put("title", d.getTitle());
            m.put("description", d.getDescription());
            m.put("ownerSno", d.getOwnerSno());
            m.put("ownerName", displayName(d.getOwnerSno()));
            m.put("expectedSkill", skillName(d.getExpectedSkillId()));
            m.put("offerSkill", skillName(d.getOfferSkillId()));
            m.put("visibility", d.getVisibility() == null ? null : d.getVisibility().name());
            m.put("auditStatus", d.getAuditStatus() == null ? null : d.getAuditStatus().name());
            m.put("auditRemark", d.getAuditRemark());
            m.put("createdAt", d.getCreatedAt());
            return m;
        }).toList();
        return PageResult.of(rows, result.getTotal(), p, s);
    }

    /**
     * 审核需求卡片（通过 / 驳回）。
     *
     * @param demandId 卡片 ID
     * @param approved true 通过 / false 驳回
     * @param remark   审核意见（驳回时必填 —— 用户需要知道怎么改）
     * @param operator 操作管理员
     * @return 更新后的卡片
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> auditDemand(Long demandId, boolean approved, String remark, String operator) {
        Demand d = demandMapper.selectById(demandId);
        if (d == null) {
            throw BusinessException.paramInvalid("需求卡片不存在：" + demandId);
        }
        if (!approved && !StringUtils.hasText(remark)) {
            // 驳回必须说明原因，否则用户无从修改，只能反复提交
            throw new BusinessException(ErrorCode.ADMIN_REMARK_REQUIRED,
                    "驳回必须填写原因，用户需要知道如何修改");
        }

        d.setAuditStatus(approved ? AuditStatus.PASSED : AuditStatus.REJECTED);
        d.setAuditRemark(StringUtils.hasText(remark) ? remark.trim() : "审核通过");
        if (!approved) {
            // 驳回的卡片不再招募
            d.setStatus(DemandStatus.CLOSED);
        }
        demandMapper.updateById(d);

        auditService.record(GovernanceAuditService.builder()
                .action(GovernanceAudit.ACTION_RULE_UPDATE)
                .actorSno(operator)
                .actorRole(GovernanceAudit.ROLE_ADMIN)
                .targetType("DEMAND")
                .targetId(String.valueOf(demandId))
                .summary(String.format("内容审核：卡片「%s」%s", d.getTitle(), approved ? "通过" : "驳回"))
                .reason(StringUtils.hasText(remark) ? remark.trim() : "审核通过")
                .visible(true)
                .build());

        notificationService.send(d.getOwnerSno(), NotificationType.SYSTEM,
                approved ? "需求卡片已通过审核" : "需求卡片未通过审核",
                approved ? String.format("你发布的「%s」已通过审核，现在所有人都能看到了", d.getTitle())
                        : String.format("你发布的「%s」未通过审核。原因：%s", d.getTitle(), remark.trim()),
                "DEMAND", demandId);

        log.info("[管理端] {} 审核卡片 {} 结果={} 意见={}", operator, d.getDemandNo(),
                approved ? "通过" : "驳回", remark);
        return Map.of("id", d.getId(), "demandNo", d.getDemandNo(),
                "auditStatus", d.getAuditStatus().name(),
                "auditStatusLabel", d.getAuditStatus().getLabel());
    }

    /* ==================== 用户举报（FR-M9-03） ==================== */

    /**
     * 提交举报。
     *
     * @param reporterSno 举报人
     * @param targetType  对象类型：DEMAND / MESSAGE / EVALUATION / SKILL
     * @param targetId    对象 ID
     * @param reasonType  举报类型：AD / ABUSE / FAKE / PLAGIARISM / OTHER
     * @param detail      补充说明
     * @return 举报记录
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> createReport(String reporterSno, String targetType, Long targetId,
                                            String reasonType, String detail) {
        String type = targetType == null ? "" : targetType.trim().toUpperCase();
        if (!List.of("DEMAND", "MESSAGE", "EVALUATION", "SKILL").contains(type)) {
            throw BusinessException.paramInvalid(
                    "举报对象类型不合法，应为 DEMAND / MESSAGE / EVALUATION / SKILL");
        }
        String reason = reasonType == null ? "" : reasonType.trim().toUpperCase();
        if (!List.of("AD", "ABUSE", "FAKE", "PLAGIARISM", "OTHER").contains(reason)) {
            throw BusinessException.paramInvalid(
                    "举报类型不合法，应为 AD / ABUSE / FAKE / PLAGIARISM / OTHER");
        }
        // 校验对象存在，避免举报空气
        if (!targetExists(type, targetId)) {
            throw new BusinessException(ErrorCode.REPORT_TARGET_NOT_FOUND);
        }
        // 重复举报拦截（DDL 有唯一键兜底，这里给友好提示）
        Long dup = reportMapper.selectCount(new LambdaQueryWrapper<ContentReport>()
                .eq(ContentReport::getReporterSno, reporterSno)
                .eq(ContentReport::getTargetType, type)
                .eq(ContentReport::getTargetId, targetId));
        if (dup != null && dup > 0) {
            throw new BusinessException(ErrorCode.REPORT_DUPLICATE);
        }

        ContentReport report = new ContentReport()
                .setReporterSno(reporterSno)
                .setTargetType(type)
                .setTargetId(targetId)
                .setReasonType(reason)
                .setDetail(StringUtils.hasText(detail) ? detail.trim() : null)
                .setStatus("PENDING");
        reportMapper.insert(report);
        log.info("[举报] {} 举报 {}#{} 类型={}", reporterSno, type, targetId, reason);
        return toReportView(report);
    }

    /**
     * 举报队列（管理员）。
     *
     * @param status PENDING / ACCEPTED / REJECTED，为空返回全部
     * @param page   页码
     * @param size   每页条数
     * @return 分页结果
     */
    public PageResult<Map<String, Object>> listReports(String status, int page, int size) {
        int p = Math.max(1, page);
        int s = Math.min(100, Math.max(1, size <= 0 ? 20 : size));
        LambdaQueryWrapper<ContentReport> wrapper = new LambdaQueryWrapper<ContentReport>()
                .orderByAsc(ContentReport::getStatus)
                .orderByDesc(ContentReport::getCreatedAt);
        if (StringUtils.hasText(status)) {
            wrapper.eq(ContentReport::getStatus, status.trim().toUpperCase());
        }
        Page<ContentReport> result = reportMapper.selectPage(new Page<>(p, s), wrapper);
        List<Map<String, Object>> rows = result.getRecords().stream().map(r -> {
            Map<String, Object> m = toReportView(r);
            m.put("targetSummary", describeTarget(r.getTargetType(), r.getTargetId()));
            return m;
        }).toList();
        return PageResult.of(rows, result.getTotal(), p, s);
    }

    /**
     * 处理举报。
     *
     * <p>举报成立时按对象类型执行对应处置：
     * <ul>
     *   <li>DE_MAND 卡片 → 下架并驳回</li>
     *   <li>SKILL 技能标签 → 停用</li>
     *   <li>EVALUATION 评价 → 标记疑似不公，转人工复核（<b>不直接改分</b>，
     *       因为评价本体是哈希存证的，改分需走争议仲裁的修正流程）</li>
     *   <li>MESSAGE 留言 → 记录处置结论（留言作为争议证据需保留，不做物理删除）</li>
     * </ul>
     *
     * @param reportId 举报 ID
     * @param accepted true 举报成立 / false 不成立
     * @param remark   处理说明（必填）
     * @param operator 操作管理员
     * @return 处理结果
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> handleReport(Long reportId, boolean accepted, String remark, String operator) {
        ContentReport report = reportMapper.selectById(reportId);
        if (report == null) {
            throw new BusinessException(ErrorCode.REPORT_NOT_FOUND);
        }
        if (!"PENDING".equals(report.getStatus())) {
            throw new BusinessException(ErrorCode.REPORT_ALREADY_HANDLED);
        }
        if (!StringUtils.hasText(remark)) {
            throw new BusinessException(ErrorCode.ADMIN_REMARK_REQUIRED);
        }

        List<String> actions = new ArrayList<>();
        if (accepted) {
            actions.addAll(applyPenalty(report));
        }

        report.setStatus(accepted ? "ACCEPTED" : "REJECTED");
        report.setHandlerSno(operator);
        report.setHandleRemark(remark.trim());
        report.setHandledAt(LocalDateTime.now());
        reportMapper.updateById(report);

        auditService.record(GovernanceAuditService.builder()
                .action(GovernanceAudit.ACTION_RULE_UPDATE)
                .actorSno(operator)
                .actorRole(GovernanceAudit.ROLE_ADMIN)
                .targetType(report.getTargetType())
                .targetId(String.valueOf(report.getTargetId()))
                .summary(String.format("举报处理：%s#%d %s", report.getTargetType(),
                        report.getTargetId(), accepted ? "举报成立" : "举报不成立"))
                .detail(actions.isEmpty() ? null : JSONUtil.toJsonStr(actions))
                .reason(remark.trim())
                .visible(true)
                .build());

        // 告知举报人结果 —— 不反馈会让用户不再举报，社区自净机制随之失效
        notificationService.send(report.getReporterSno(), NotificationType.SYSTEM,
                accepted ? "你的举报已成立" : "你的举报未成立",
                String.format("对 %s#%d 的举报处理结果：%s", report.getTargetType(),
                        report.getTargetId(), remark.trim()),
                report.getTargetType(), report.getTargetId());

        log.info("[举报] {} 处理举报 #{} 结果={} 处置={}", operator, reportId,
                accepted ? "成立" : "不成立", actions);
        Map<String, Object> result = toReportView(report);
        result.put("actions", actions);
        return result;
    }

    /**
     * 按举报成立执行处置。
     *
     * @param report 举报
     * @return 处置说明列表
     */
    private List<String> applyPenalty(ContentReport report) {
        List<String> actions = new ArrayList<>();
        switch (report.getTargetType()) {
            case "DEMAND" -> {
                Demand d = demandMapper.selectById(report.getTargetId());
                if (d != null) {
                    d.setAuditStatus(AuditStatus.REJECTED);
                    d.setAuditRemark("举报成立，已下架");
                    d.setStatus(DemandStatus.CLOSED);
                    demandMapper.updateById(d);
                    actions.add("卡片「" + d.getTitle() + "」已下架");
                }
            }
            case "SKILL" -> {
                Skill s = skillMapper.selectById(report.getTargetId());
                if (s != null) {
                    // 技能标签用 status=0 标记停用，不物理删除 —— 历史交换记录仍引用它
                    s.setStatus(0);
                    skillMapper.updateById(s);
                    actions.add("技能标签「" + s.getName() + "」已停用（保留历史引用）");
                }
            }
            case "EVALUATION" -> {
                EvaluationGrade g = evaluationMapper.selectById(report.getTargetId());
                if (g != null) {
                    evaluationMapper.updateById(new EvaluationGrade()
                            .setId(g.getId())
                            .setAuditStatus("PENDING")
                            .setAuditRemark("举报成立，转人工复核"));
                    actions.add("评价已标记为待复核（评价本体不可直接修改，需走仲裁修正流程）");
                }
            }
            case "MESSAGE" -> actions.add("留言已标记处理（作为争议证据保留，不做物理删除）");
            default -> actions.add("已记录处置结论");
        }
        return actions;
    }

    /**
     * 待办事项汇总（管理端首页用）。
     *
     * <p>把"需要管理员处理的事"集中成一个数字，避免管理员在多个页面间来回找。
     *
     * @return 待办统计
     */
    public Map<String, Object> todoSummary() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("pendingDemands", demandMapper.selectCount(new LambdaQueryWrapper<Demand>()
                .eq(Demand::getAuditStatus, AuditStatus.PENDING)));
        m.put("pendingReports", reportMapper.selectCount(new LambdaQueryWrapper<ContentReport>()
                .eq(ContentReport::getStatus, "PENDING")));
        m.put("pendingEvaluations", evaluationMapper.selectCount(new LambdaQueryWrapper<EvaluationGrade>()
                .eq(EvaluationGrade::getAuditStatus, "PENDING")));
        return m;
    }

    /* ---------------- 工具 ---------------- */

    private boolean targetExists(String type, Long id) {
        return switch (type) {
            case "DEMAND" -> demandMapper.selectById(id) != null;
            case "SKILL" -> skillMapper.selectById(id) != null;
            case "EVALUATION" -> evaluationMapper.selectById(id) != null;
            // 留言的 Mapper 未直接注入（留言服务归 M5），用协作空间服务间接校验存在性代价高，
            // 这里放行并由审核时人工判断；留言 ID 非法不会造成数据错误。
            case "MESSAGE" -> true;
            default -> false;
        };
    }

    /**
     * 我的举报记录（给举报人反馈处理进度）。
     *
     * <p>不反馈会让用户觉得"举报没用"，社区自净机制随之失效。
     *
     * @param sno 举报人
     * @return 举报列表与统计
     */
    public Map<String, Object> myReports(String sno) {
        List<ContentReport> list = reportMapper.selectList(new LambdaQueryWrapper<ContentReport>()
                .eq(ContentReport::getReporterSno, sno)
                .orderByDesc(ContentReport::getCreatedAt));
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("total", list.size());
        data.put("pending", list.stream().filter(ContentReport::isPending).count());
        data.put("accepted", list.stream().filter(r -> "ACCEPTED".equals(r.getStatus())).count());
        data.put("rejected", list.stream().filter(r -> "REJECTED".equals(r.getStatus())).count());
        data.put("records", list.stream().map(r -> {
            Map<String, Object> m = toReportView(r);
            m.put("targetSummary", describeTarget(r.getTargetType(), r.getTargetId()));
            return m;
        }).toList());
        return data;
    }
    /** 生成被举报对象的可读摘要，便于管理员快速判断 */
    private String describeTarget(String type, Long id) {
        try {
            return switch (type) {
                case "DEMAND" -> {
                    Demand d = demandMapper.selectById(id);
                    yield d == null ? "（卡片已删除）"
                            : String.format("「%s」由 %s 发布", d.getTitle(), displayName(d.getOwnerSno()));
                }
                case "SKILL" -> {
                    Skill s = skillMapper.selectById(id);
                    yield s == null ? "（标签已删除）"
                            : String.format("标签「%s」（%s）", s.getName(), s.getCategoryL1());
                }
                case "EVALUATION" -> {
                    EvaluationGrade g = evaluationMapper.selectById(id);
                    yield g == null ? "（评价已删除）"
                            : String.format("%s → %s 的评价：%s 分",
                            displayName(g.getFromSno()), displayName(g.getToSno()), g.getTotalScore());
                }
                default -> type + "#" + id;
            };
        } catch (Exception e) {
            return type + "#" + id;
        }
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

    private Map<String, Object> toReportView(ContentReport r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", r.getId());
        m.put("reporterSno", r.getReporterSno());
        m.put("reporterName", displayName(r.getReporterSno()));
        m.put("targetType", r.getTargetType());
        m.put("targetId", r.getTargetId());
        m.put("reasonType", r.getReasonType());
        m.put("reasonLabel", reasonLabel(r.getReasonType()));
        m.put("detail", r.getDetail());
        m.put("status", r.getStatus());
        m.put("statusLabel", statusLabel(r.getStatus()));
        m.put("handlerSno", r.getHandlerSno());
        m.put("handleRemark", r.getHandleRemark());
        m.put("handledAt", r.getHandledAt());
        m.put("createdAt", r.getCreatedAt());
        return m;
    }

    private static String reasonLabel(String reason) {
        return switch (reason == null ? "" : reason) {
            case "AD" -> "广告营销";
            case "ABUSE" -> "辱骂攻击";
            case "FAKE" -> "虚假信息";
            case "PLAGIARISM" -> "抄袭";
            default -> "其他";
        };
    }

    private static String statusLabel(String status) {
        return switch (status == null ? "" : status) {
            case "PENDING" -> "待处理";
            case "ACCEPTED" -> "举报成立";
            case "REJECTED" -> "举报不成立";
            default -> status;
        };
    }
}
