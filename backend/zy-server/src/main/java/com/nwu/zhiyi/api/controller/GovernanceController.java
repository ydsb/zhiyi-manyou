package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.governance.ArbitrationVoteRequest;
import com.nwu.zhiyi.api.dto.governance.DisputeCreateRequest;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.enums.CreditLevel;
import com.nwu.zhiyi.common.enums.DisputeType;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.credit.CreditService;
import com.nwu.zhiyi.service.governance.ArbitrationService;
import com.nwu.zhiyi.service.governance.DisputeService;
import com.nwu.zhiyi.service.governance.GovernanceAuditService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 社区治理接口（模块 M8）。
 *
 * <p>鉴权约定：
 * <ul>
 *   <li>治理规则与公示动态<b>匿名开放</b> —— 治理透明是平台公信力的前提，
 *       连规则都要登录才能看就谈不上"公示"；</li>
 *   <li>申诉、答辩、投票需登录，并由服务层校验身份（当事人 / 合格委员）；</li>
 *   <li>管理员处置需 ADMIN，且必须填理由，操作会留痕公示。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/governance")
@RequiredArgsConstructor
public class GovernanceController {

    private final DisputeService disputeService;
    private final ArbitrationService arbitrationService;
    private final GovernanceAuditService auditService;
    private final CreditService creditService;

    /* ==================== 公示（FR-M8-07，匿名开放） ==================== */

    /**
     * 治理规则公示：信用等级权限、争议类型、仲裁流程、处罚力度。
     *
     * <p>把所有规则一次性摊开，用户能自己判断"我这个行为会有什么后果"：
     * 这比事后解释更有说服力，也是"规则前置"的基本要求。
     *
     * <pre>GET /api/governance/rules</pre>
     */
    @GetMapping("/rules")
    public ApiResponse<Map<String, Object>> rules() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("creditLevels", creditService.levelRules());

        List<Map<String, Object>> types = new ArrayList<>();
        for (DisputeType t : DisputeType.values()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("code", t.name());
            m.put("label", t.getLabel());
            m.put("description", t.getDescription());
            types.add(m);
        }
        data.put("disputeTypes", types);

        Map<String, Object> flow = new LinkedHashMap<>();
        flow.put("steps", List.of(
                "任一方在交换进行中或完成后发起申诉，并提交证据或详细陈述",
                "系统抽取仲裁委员会：跨学科、信用等级「优秀」以上、非当事人及其学院",
                "生成卷宗：自动汇总协作全过程数据（任务、打卡、留言统计、交付、互评、时间轴）",
                "委员匿名表决（默认 72 小时），公示只暴露票数分布，投票内容哈希存证",
                "多数决自动执行：调整信用值、修正评价、必要时封禁账号",
                "合格委员不足时不降低门槛，转管理员处置并要求填写理由，全程留痕公示"));
        flow.put("arbitratorEligibility",
                "信用等级达到「" + CreditLevel.EXCELLENT.getLabel() + "」及以上、"
                        + "非当事人、与当事人不同学院、账号状态正常");
        flow.put("voteRule", "得票多者胜；无人形成多数意见或平票时，按疑罪从无不作责任认定，双方均不受处罚");
        flow.put("penaltyRule", Map.of(
                "申诉成立", "被申诉人信用 -15，申诉人 +3（维权成本补偿）",
                "申诉未获支持", "申诉人信用 -5（遏制滥用申诉，力度小于败诉惩罚）",
                "平票", "双方均不受处罚",
                "累计承担责任", "达 3 次自动封禁账号并置并发上限为 0"));
        data.put("flow", flow);

        data.put("auditRule",
                "所有治理操作写入不可修改的审计日志。管理员保留紧急干预权，"
                        + "但必须填写理由，且操作会公示（涉及隐私的操作留痕但不公示）。");
        return ApiResponse.success(data);
    }

    /**
     * 治理动态公示（FR-M8-07）：最近的裁决、信用调整、账号处置记录。
     *
     * <pre>GET /api/governance/logs?limit=30</pre>
     */
    @GetMapping("/logs")
    public ApiResponse<List<Map<String, Object>>> logs(@RequestParam(defaultValue = "30") int limit) {
        return ApiResponse.success(auditService.publicLog(limit));
    }

    /**
     * 治理统计：各类操作数量与分布，让社区看到治理活跃度。
     *
     * <pre>GET /api/governance/statistics</pre>
     */
    @GetMapping("/statistics")
    public ApiResponse<Map<String, Object>> statistics() {
        return ApiResponse.success(auditService.statistics());
    }

    /* ==================== 申诉（FR-M8-03） ==================== */

    /**
     * 发起争议申诉。
     *
     * <pre>POST /api/governance/disputes</pre>
     */
    @PostMapping("/disputes")
    public ApiResponse<Map<String, Object>> create(@Valid @RequestBody DisputeCreateRequest request) {
        Map<String, Object> detail = disputeService.create(SecurityUtils.currentSno(), request);
        Object status = detail.get("status");
        String message = "VOTING".equals(status)
                ? "申诉已受理，仲裁委员会已抽取并进入匿名表决"
                : "申诉已受理。当前合格仲裁委员不足，已转管理员处置（操作会留痕公示）";
        return ApiResponse.success(message, detail);
    }

    /**
     * 我的争议列表（含我作为当事人与待我仲裁的）。
     *
     * <pre>GET /api/governance/disputes/mine</pre>
     */
    @GetMapping("/disputes/mine")
    public ApiResponse<Map<String, Object>> mine() {
        String sno = SecurityUtils.currentSno();
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("asParty", disputeService.myDisputes(sno));
        data.put("toArbitrate", disputeService.pendingForArbitration(sno));
        return ApiResponse.success(data);
    }

    /**
     * 争议详情（含卷宗，仅当事人/合格委员/管理员可见）。
     *
     * <pre>GET /api/governance/disputes/{id}</pre>
     */
    @GetMapping("/disputes/{id}")
    public ApiResponse<Map<String, Object>> detail(@PathVariable Long id) {
        return ApiResponse.success(disputeService.detail(id, SecurityUtils.currentSno()));
    }

    /**
     * 被申诉人提交答辩。
     *
     * <pre>POST /api/governance/disputes/{id}/defense</pre>
     */
    @PostMapping("/disputes/{id}/defense")
    public ApiResponse<Map<String, Object>> defense(@PathVariable Long id,
                                                    @RequestBody Map<String, String> body) {
        String defense = body == null ? null : body.get("defense");
        return ApiResponse.success("答辩已提交，仲裁委员会将一并参考",
                disputeService.submitDefense(id, SecurityUtils.currentSno(), defense));
    }

    /* ==================== 仲裁（FR-M8-04 / FR-M8-05） ==================== */

    /**
     * 提交仲裁投票（匿名表决）。
     *
     * <pre>POST /api/governance/disputes/{id}/vote</pre>
     */
    @PostMapping("/disputes/{id}/vote")
    public ApiResponse<Map<String, Object>> vote(@PathVariable Long id,
                                                 @Valid @RequestBody ArbitrationVoteRequest request) {
        return ApiResponse.success("表决已记录（匿名存证）",
                arbitrationService.vote(id, SecurityUtils.currentSno(), request));
    }

    /* ==================== 管理员处置（FR-M8-08） ==================== */

    /**
     * 管理员紧急处置争议。**理由必填**，操作会留痕并公示。
     *
     * <pre>POST /api/admin/governance/disputes/{id}/resolve</pre>
     */
    @PostMapping("/admin/disputes/{id}/resolve")
    public ApiResponse<Map<String, Object>> adminResolve(@PathVariable Long id,
                                                         @RequestBody Map<String, Object> body) {
        boolean upheld = Boolean.TRUE.equals(body.get("upheld"));
        String reason = body.get("reason") == null ? null : String.valueOf(body.get("reason"));
        return ApiResponse.success("处置已执行，操作已留痕并公示",
                arbitrationService.adminResolve(id, SecurityUtils.currentSno(), upheld, reason));
    }

    /**
     * 查询审计日志（管理员视角，含不公示项）。
     *
     * <pre>GET /api/governance/audits?targetId=xxx&amp;action=CREDIT_ADJUST</pre>
     */
    @GetMapping("/audits")
    public ApiResponse<List<Map<String, Object>>> audits(@RequestParam(required = false) String targetId,
                                                         @RequestParam(required = false) String action,
                                                         @RequestParam(defaultValue = "50") int limit) {
        return ApiResponse.success(auditService.query(targetId, action, limit));
    }
}
