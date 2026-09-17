package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.service.credit.CreditCalculator;
import com.nwu.zhiyi.service.evaluation.EvaluationService;
import com.nwu.zhiyi.service.profile.ProfileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 开放能力接口（FR-M9-07 / FR-M9-08）。
 *
 * <p><b>设计取向：借鉴 MCP 的 tools/list + tools/call 约定</b>，把平台的核心计算能力
 * 暴露为<b>可被发现、可被调用、带参数校验</b>的标准化工具，便于：
 * <ul>
 *   <li>与校内其他系统集成（如综合素质测评系统直接调信用计算）；</li>
 *   <li>被智能体（Agent / LLM）作为 tool 调用 —— FR-M9-08 明确要求把
 *       "贡献度 / 信用值"计算封装为可被智能体调用的工具 API。</li>
 * </ul>
 *
 * <p><b>为什么先返回 schema 再调用</b>：调用方（尤其是智能体）需要先知道
 * "有哪些工具、各要什么参数"，否则只能靠文档猜测。
 * {@code GET /api/tools} 返回的 JSON Schema 可直接喂给 LLM 的函数调用协议。
 *
 * <p><b>权限</b>：工具接口只暴露<b>聚合计算</b>能力，不返回他人隐私明细；
 * 涉及个人数据的工具要求调用者已登录。因此本控制器整体需要认证，
 * 但不要求 ADMIN —— 校内其他系统用服务账号即可。
 *
 * @author 李泽宬
 */
@Slf4j
@RestController
@RequestMapping("/api/tools")
@RequiredArgsConstructor
public class ToolApiController {

    private final CreditCalculator creditCalculator;
    private final ProfileService profileService;
    private final EvaluationService evaluationService;

    /**
     * 工具清单（含 JSON Schema）。
     *
     * <p>返回格式刻意贴近 MCP 的 {@code tools/list}：
     * {@code {name, description, inputSchema}}，可直接用于 LLM 函数调用。
     *
     * <pre>GET /api/tools</pre>
     */
    @GetMapping
    public ApiResponse<Map<String, Object>> listTools() {
        List<Map<String, Object>> tools = new ArrayList<>();

        tools.add(tool("compute_credit_score",
                "计算指定学号的信用值（多因子加权），返回总分与各因子得分、权重、依据说明。",
                schema(Map.of("sno", prop("string", "学号，如 2024117420")),
                        List.of("sno"))));

        tools.add(tool("compute_ability_profile",
                "计算指定学号的能力画像五维得分，返回每维得分、样本数与分数出处说明。",
                schema(Map.of("sno", prop("string", "学号")),
                        List.of("sno"))));

        tools.add(tool("verify_certificate",
                "按校验码校验一条互评存证的完整性，返回是否被改动、存证等级与持有人信息。",
                schema(Map.of("verifyCode", prop("string", "能力鉴定报告上的校验码，如 C3F5EFC7")),
                        List.of("verifyCode"))));

        tools.add(tool("get_governance_status",
                "查询指定学号的治理相关状态：信用等级、可担任仲裁委员、并发交换上限。",
                schema(Map.of("sno", prop("string", "学号")),
                        List.of("sno"))));

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("protocol", "zhiyi-tools/1.0（约定参考 MCP tools/list）");
        data.put("tools", tools);
        data.put("note", "调用方式：POST /api/tools/call，body 为 {name, arguments}。"
                + "所有工具只返回聚合计算结果，不暴露他人协作明细与隐私数据。");
        return ApiResponse.success(data);
    }

    /**
     * 调用工具。
     *
     * <pre>POST /api/tools/call  {"name":"compute_credit_score","arguments":{"sno":"2024117420"}}</pre>
     */
    @PostMapping("/call")
    public ApiResponse<Map<String, Object>> call(@RequestBody Map<String, Object> body) {
        String name = body.get("name") == null ? null : String.valueOf(body.get("name")).trim();
        if (name == null || name.isBlank()) {
            throw BusinessException.paramInvalid("缺少工具名 name");
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> args = body.get("arguments") instanceof Map
                ? (Map<String, Object>) body.get("arguments") : Map.of();

        String sno = str(args.get("sno"));
        String verifyCode = str(args.get("verifyCode"));

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("tool", name);
        switch (name) {
            case "compute_credit_score" -> {
                requireArg(sno, "sno");
                CreditCalculator.Result r = creditCalculator.compute(sno);
                Map<String, Object> factors = new LinkedHashMap<>();
                r.factors().forEach((k, f) -> {
                    Map<String, Object> fm = new LinkedHashMap<>();
                    fm.put("score", f.score() < 0 ? null : f.score());
                    fm.put("weight", f.weight());
                    fm.put("detail", f.detail());
                    factors.put(k, fm);
                });
                result.put("sno", sno);
                result.put("score", r.score());
                result.put("factors", factors);
                result.put("explanation", r.describe());
                result.put("isNewUser", r.isNewUser());
                result.put("exchangeCount", r.exchangeCount());
            }
            case "compute_ability_profile" -> {
                requireArg(sno, "sno");
                var radar = profileService.radar(sno);
                List<Map<String, Object>> dims = new ArrayList<>();
                radar.getDimensions().forEach(d -> {
                    Map<String, Object> dm = new LinkedHashMap<>();
                    dm.put("key", d.getKey());
                    dm.put("label", d.getLabel());
                    dm.put("score", d.getScore());
                    dm.put("sampleCount", d.getSampleCount());
                    dm.put("evidence", d.getEvidence());
                    dims.add(dm);
                });
                result.put("sno", sno);
                result.put("name", radar.getName());
                result.put("overallScore", radar.getOverallScore());
                result.put("dimensions", dims);
                result.put("caliber", radar.getCaliberNote());
            }
            case "verify_certificate" -> {
                requireArg(verifyCode, "verifyCode");
                var integrity = evaluationService.verifyByCode(verifyCode);
                result.put("verifyCode", integrity.getVerifyCode());
                result.put("intact", integrity.getIntact());
                result.put("evidenceLevel", integrity.getEvidenceLevel());
                result.put("ownerName", integrity.getOwnerName());
                result.put("totalScore", integrity.getTotalScore());
                result.put("sealedAt", integrity.getSealedAt());
                result.put("note", integrity.getEvidenceNote());
            }
            case "get_governance_status" -> {
                requireArg(sno, "sno");
                CreditCalculator.Result r = creditCalculator.compute(sno);
                var level = com.nwu.zhiyi.common.enums.CreditLevel.of(r.score());
                result.put("sno", sno);
                result.put("creditScore", r.score());
                result.put("level", level.name());
                result.put("levelLabel", level.getLabel());
                result.put("eligibleArbitrator", level.isEligibleArbitrator());
                result.put("exchangeQuota", level.getExchangeQuota());
                result.put("privilege", level.getPrivilege());
            }
            default -> throw BusinessException.paramInvalid(
                    "未知工具：" + name + "。可用工具清单见 GET /api/tools");
        }
        log.info("[工具调用] {} args={}", name, args.keySet());
        return ApiResponse.success(result);
    }

    /* ---------------- schema 构造工具 ---------------- */

    private static Map<String, Object> tool(String name, String description, Map<String, Object> inputSchema) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("name", name);
        m.put("description", description);
        m.put("inputSchema", inputSchema);
        return m;
    }

    private static Map<String, Object> schema(Map<String, Object> properties, List<String> required) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", "object");
        m.put("properties", properties);
        m.put("required", required);
        m.put("additionalProperties", false);
        return m;
    }

    private static Map<String, Object> prop(String type, String description) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", type);
        m.put("description", description);
        return m;
    }

    private static String str(Object v) {
        return v == null ? null : String.valueOf(v).trim();
    }

    private static void requireArg(String value, String argName) {
        if (value == null || value.isBlank()) {
            throw BusinessException.paramInvalid("缺少必填参数：" + argName);
        }
    }
}
