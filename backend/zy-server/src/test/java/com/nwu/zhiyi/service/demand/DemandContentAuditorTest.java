package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.common.enums.AuditStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 需求卡片内容审核测试（FR-M4-07）。
 *
 * @author 李泽宬
 */
@DisplayName("M4 - 内容审核（敏感词与广告识别）")
class DemandContentAuditorTest {

    private DemandContentAuditor auditor;

    @BeforeEach
    void setUp() {
        auditor = new DemandContentAuditor();
    }

    @Test
    @DisplayName("正常技能互助需求应直接通过")
    void shouldPassNormalDemand() {
        DemandContentAuditor.Result result = auditor.audit(
                "需要会做动态交互效果的同学",
                "已有 Vue3 静态页面，希望加入滚动视差与过渡动画，我可以教你数学建模作为回报。");
        assertEquals(AuditStatus.PASSED, result.status());
        assertNull(result.remark());
    }

    @Test
    @DisplayName("学术不端类词汇应直接驳回")
    void shouldRejectAcademicMisconduct() {
        DemandContentAuditor.Result result = auditor.audit("求代写论文", "价格好商量");
        assertEquals(AuditStatus.REJECTED, result.status());
        assertNotNull(result.remark());
        assertTrue(result.remark().contains("代写论文"), "说明应指出命中的词：" + result.remark());
    }

    @Test
    @DisplayName("刷单类词汇应直接驳回")
    void shouldRejectRatingManipulation() {
        assertEquals(AuditStatus.REJECTED, auditor.audit("互刷信用", "互相好评").status());
        assertEquals(AuditStatus.REJECTED, auditor.audit("刷单兼职", null).status());
    }

    @Test
    @DisplayName("有偿交易倾向应转人工复核而非直接拒绝（避免误杀）")
    void shouldFlagPaidIntentForReview() {
        DemandContentAuditor.Result result = auditor.audit(
                "想找人辅导算法，可以付费", "预算不多，希望价格便宜一点");
        assertEquals(AuditStatus.PENDING, result.status());
        assertTrue(result.remark().contains("付费") || result.remark().contains("价格"),
                "应记录命中的敏感词：" + result.remark());
    }

    @Test
    @DisplayName("疑似联系方式应转人工复核（引导站内沟通以保留存证）")
    void shouldFlagContactInfo() {
        DemandContentAuditor.Result phone = auditor.audit("联系我 13812345678", null);
        assertEquals(AuditStatus.PENDING, phone.status());
        assertTrue(phone.remark().contains("联系方式"), phone.remark());

        DemandContentAuditor.Result wechat = auditor.audit(null, "加微信：abc12345 详聊");
        assertEquals(AuditStatus.PENDING, wechat.status());
    }

    @Test
    @DisplayName("外部链接应转人工复核")
    void shouldFlagExternalLink() {
        DemandContentAuditor.Result result = auditor.audit("详见 https://example.com/x", null);
        assertEquals(AuditStatus.PENDING, result.status());
        assertTrue(result.remark().contains("链接"), result.remark());
    }

    @Test
    @DisplayName("多个风险特征应合并记录")
    void shouldMergeMultipleHits() {
        DemandContentAuditor.Result result = auditor.audit(
                "付费辅导，加微信 abc12345", "详见 www.example.com");
        assertEquals(AuditStatus.PENDING, result.status());
        assertTrue(result.remark().contains("；"), "多条命中应以分号合并：" + result.remark());
    }

    @Test
    @DisplayName("空内容应安全处理")
    void shouldHandleBlankInput() {
        assertEquals(AuditStatus.PASSED, auditor.audit(null, null).status());
        assertEquals(AuditStatus.PASSED, auditor.audit("", "").status());
    }

    @Test
    @DisplayName("驳回优先级高于人工复核")
    void rejectShouldWinOverReview() {
        // 同时含"付费"（复核）与"代考"（驳回），应以驳回为准
        assertEquals(AuditStatus.REJECTED, auditor.audit("付费代考", null).status());
    }
}
