package com.nwu.zhiyi.service.evaluation;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * 互评内容审核（配合 FR-M6-07，保证评价语料可读可用）。
 *
 * <p>比 M4 的需求卡片审核更严的一点：<b>低分必须给出具体说明</b>。
 * 原因有两面 ——
 * <ul>
 *   <li>对<b>被评价人</b>：一句"1 分"没有可改进信息，属于无效反馈；</li>
 *   <li>对<b>平台</b>：无理由差评是被申诉的高发源头，事后仲裁缺乏依据。</li>
 * </ul>
 * 因此分值低于阈值时强制要求评语达到最小长度。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
public class EvaluationContentAuditor {

    /** 低分阈值：低于该分数必须填写具体说明 */
    private static final double LOW_SCORE_THRESHOLD = 60.0;

    /** 低分评语的最小长度 */
    private static final int LOW_SCORE_MIN_COMMENT = 15;

    /** 评语最大长度（与 DDL 的 VARCHAR(1000) 对齐） */
    private static final int MAX_COMMENT_LENGTH = 1000;

    /** 辱骂/人身攻击类词汇（转发人工复核，不直接驳回 —— 避免误杀） */
    private static final List<String> ABUSIVE_WORDS = List.of(
            "傻逼", "智障", "废物", "垃圾", "滚蛋", "脑残", "有病", "神经病", "去死"
    );

    /** 联系方式：评价是对过程的记录，不应夹带私下交易线索 */
    private static final List<Pattern> CONTACT_PATTERNS = List.of(
            Pattern.compile("1[3-9]\\d{9}"),
            Pattern.compile("(?i)(qq|微信|vx|weixin)\\s*[:：]?\\s*[a-zA-Z0-9_-]{5,}")
    );

    /**
     * 审核结果。
     *
     * @param passed            是否通过（false 时由调用方抛出）
     * @param needsManualReview 是否需要转人工复核（仍允许提交，仅打标）
     * @param remark            说明
     */
    public record Result(boolean passed, boolean needsManualReview, String remark) {

        static Result ok() {
            return new Result(true, false, null);
        }

        static Result review(String remark) {
            return new Result(true, true, remark);
        }
    }

    /**
     * 审核评语内容。
     *
     * @param comment    文字评语
     * @param totalScore 加权总分（用于低分强制说明）
     * @return 审核结果
     */
    public Result audit(String comment, double totalScore) {
        String text = comment == null ? "" : comment.trim();

        if (text.length() > MAX_COMMENT_LENGTH) {
            throw BusinessException.paramInvalid(
                    "评语长度不能超过 " + MAX_COMMENT_LENGTH + " 字，当前 " + text.length() + " 字");
        }

        // 低分必须有具体说明
        if (totalScore < LOW_SCORE_THRESHOLD && text.length() < LOW_SCORE_MIN_COMMENT) {
            throw new BusinessException(ErrorCode.EVALUATION_COMMENT_REQUIRED,
                    String.format("总分低于 %.0f 分时必须填写不少于 %d 字的具体说明（当前 %d 字），"
                                    + "既便于对方改进，也是后续申诉的依据",
                            LOW_SCORE_THRESHOLD, LOW_SCORE_MIN_COMMENT, text.length()));
        }

        Set<String> hits = new java.util.LinkedHashSet<>();
        for (String word : ABUSIVE_WORDS) {
            if (text.contains(word)) {
                hits.add("疑似人身攻击用语「" + word + "」");
            }
        }
        for (Pattern p : CONTACT_PATTERNS) {
            if (p.matcher(text).find()) {
                hits.add("包含疑似联系方式");
                break;
            }
        }
        if (!hits.isEmpty()) {
            String remark = hits.stream().collect(Collectors.joining("；"));
            log.info("[互评审核] 转人工复核：{}", remark);
            return Result.review(remark);
        }
        return Result.ok();
    }
}
