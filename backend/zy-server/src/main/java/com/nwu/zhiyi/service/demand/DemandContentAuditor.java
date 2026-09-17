package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.common.enums.AuditStatus;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * 需求卡片内容审核（FR-M4-07）。
 *
 * <p><b>设计取舍</b>：需求文档要求"敏感词过滤 + 广告/刷单识别，命中则转人工复核"。
 * 当前实现为<b>轻量规则审核</b>：
 * <ul>
 *   <li>不引入第三方敏感词库（体积大、需要持续维护），只保留与"校园技能交换"场景
 *       强相关的风险特征；</li>
 *   <li>命中即置为 {@code PENDING} 转人工复核，<b>而不是直接拒绝</b>，
 *       避免误杀正常需求（例如有人确实想找"代做"）；</li>
 *   <li>审核不通过不影响数据落库，管理员可在后台复核后放行。</li>
 * </ul>
 *
 * <p>后续（M9）可把规则外置为配置表，并接入学校已有的内容安全接口。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
public class DemandContentAuditor {

    /** 明确违规：学术不端、代考代写等 —— 直接驳回 */
    private static final List<String> REJECT_WORDS = List.of(
            "代考", "替考", "代写论文", "论文代写", "代做毕设", "包过",
            "刷单", "刷好评", "刷信用", "套现", "博彩", "赌博", "色情", "涉政"
    );

    /** 需要人工复核：可能涉及有偿交易或广告，但也可能是正常表述 */
    private static final List<String> REVIEW_WORDS = List.of(
            "付费", "收费", "价格", "多少钱", "报价", "红包", "转账", "微信转账",
            "加微信", "加qq", "扫码", "私聊", "兼职", "招募代理", "长期合作",
            "代做", "代刷", "外挂", "破解"
    );

    /** 联系方式外泄（引导私下交易，绕过平台的信用与存证体系） */
    private static final List<Pattern> CONTACT_PATTERNS = List.of(
            Pattern.compile("1[3-9]\\d{9}"),                       // 手机号
            Pattern.compile("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"), // 邮箱
            Pattern.compile("(?i)(qq|微信|vx|weixin)\\s*[:：]?\\s*[a-zA-Z0-9_-]{5,}")
    );

    /** 广告特征：连续重复字符、过多链接 */
    private static final Pattern URL_PATTERN = Pattern.compile("(?i)https?://|www\\.");

    /**
     * 审核结果。
     *
     * @param status 审核状态
     * @param remark 说明（命中原因）
     */
    public record Result(AuditStatus status, String remark) {

        public boolean passed() {
            return status == AuditStatus.PASSED;
        }
    }

    /**
     * 审核文本内容。
     *
     * @param title       标题
     * @param description 详述
     * @return 审核结果
     */
    public Result audit(String title, String description) {
        String text = ((title == null ? "" : title) + "\n" + (description == null ? "" : description)).toLowerCase();
        Set<String> hits = new LinkedHashSet<>();

        for (String word : REJECT_WORDS) {
            if (text.contains(word)) {
                log.warn("[内容审核] 驳回，命中违禁词：{}", word);
                return new Result(AuditStatus.REJECTED, "命中违禁词「" + word + "」，内容不予发布");
            }
        }

        for (String word : REVIEW_WORDS) {
            if (text.contains(word)) {
                hits.add("敏感词「" + word + "」");
            }
        }

        for (Pattern p : CONTACT_PATTERNS) {
            if (p.matcher(text).find()) {
                hits.add("疑似联系方式（平台建议站内沟通，以保留协作与存证记录）");
                break;
            }
        }

        if (URL_PATTERN.matcher(text).find()) {
            hits.add("包含外部链接");
        }

        if (!hits.isEmpty()) {
            String remark = String.join("；", new ArrayList<>(hits));
            log.info("[内容审核] 转人工复核：{}", remark);
            return new Result(AuditStatus.PENDING, remark);
        }
        return new Result(AuditStatus.PASSED, null);
    }
}
