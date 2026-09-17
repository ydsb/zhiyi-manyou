package com.nwu.zhiyi.service.evaluation;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 互评内容审核测试。
 *
 * <p>核心规则：<b>低分必须给出具体说明</b> —— 无理由差评对双方都无价值，
 * 也是事后申诉的高发源头。
 *
 * @author 李泽宬
 */
@DisplayName("M6 - 互评内容审核")
class EvaluationContentAuditorTest {

    private EvaluationContentAuditor auditor;

    @BeforeEach
    void setUp() {
        auditor = new EvaluationContentAuditor();
    }

    @Test
    @DisplayName("高分 + 简短评语应通过")
    void shouldPassHighScoreShortComment() {
        EvaluationContentAuditor.Result r = auditor.audit("很顺利", 95);
        assertTrue(r.passed());
        assertFalse(r.needsManualReview());
    }

    @Test
    @DisplayName("低分不给说明应被拒绝，并提示需要多少字")
    void shouldRejectLowScoreWithoutReason() {
        BusinessException ex = assertThrows(BusinessException.class,
                () -> auditor.audit("不好", 45));
        assertEquals(ErrorCode.EVALUATION_COMMENT_REQUIRED.getCode(), ex.getErrorCode().getCode());
        assertTrue(ex.getMessage().contains("15"), "提示应说明最小字数：" + ex.getMessage());
    }

    @Test
    @DisplayName("低分给足说明应通过")
    void shouldPassLowScoreWithReason() {
        EvaluationContentAuditor.Result r = auditor.audit(
                "约定的三个任务只完成了一个，交付的图表数据口径也对不上，后续需要重新核对", 45);
        assertTrue(r.passed());
    }

    @Test
    @DisplayName("低分且完全无评语应被拒绝")
    void shouldRejectLowScoreWithNullComment() {
        assertThrows(BusinessException.class, () -> auditor.audit(null, 30));
        assertThrows(BusinessException.class, () -> auditor.audit("   ", 30));
    }

    @Test
    @DisplayName("临界值：恰好 60 分不触发低分强制说明")
    void shouldNotEnforceAtThreshold() {
        EvaluationContentAuditor.Result r = auditor.audit("一般", 60.0);
        assertTrue(r.passed(), "60 分及以上不强制长评语");
    }

    @Test
    @DisplayName("人身攻击用语应转人工复核（不直接驳回，避免误杀）")
    void shouldFlagAbusiveWords() {
        EvaluationContentAuditor.Result r = auditor.audit(
                "协作过程中对方沟通很不到位，态度也让人无语，感觉就是在敷衍了事，属于垃圾水平", 40);
        assertTrue(r.passed(), "仍允许提交，只打标复核");
        assertTrue(r.needsManualReview());
        assertTrue(r.remark().contains("人身攻击"), r.remark());
    }

    @Test
    @DisplayName("夹带联系方式应转人工复核")
    void shouldFlagContactInfo() {
        EvaluationContentAuditor.Result r = auditor.audit(
                "整体还可以，后续有问题可以加微信 abc12345 继续聊这次协作的事情", 80);
        assertTrue(r.needsManualReview());
        assertTrue(r.remark().contains("联系方式"), r.remark());
    }

    @Test
    @DisplayName("评语超长应被拒绝（与库表长度对齐）")
    void shouldRejectTooLongComment() {
        String longComment = "很".repeat(1001);
        assertThrows(BusinessException.class, () -> auditor.audit(longComment, 90));
    }

    @Test
    @DisplayName("正常评语不应被误判为需复核")
    void shouldNotFlagNormalComment() {
        EvaluationContentAuditor.Result r = auditor.audit(
                "任务拆解清晰，交付的两版图表都按时给了，跨专业术语解释得很耐心", 92);
        assertFalse(r.needsManualReview(), "正常评语不应触发复核：" + r.remark());
    }
}
