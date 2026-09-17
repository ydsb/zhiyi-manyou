package com.nwu.zhiyi.service.evaluation;

import com.nwu.zhiyi.common.enums.EvidenceLevel;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 互评存证测试（FR-M6-03 / 验收项 AC-05）。
 *
 * <p>AC-05 的验收标准是"篡改数据库评价记录后，校验接口能检出不一致"，
 * 因此本测试逐字段篡改并断言 {@code verifyIntegrity()} 必然返回 false ——
 * 这是 M6 最核心的可验证承诺，必须有测试锁定。
 *
 * @author 李泽宬
 */
@DisplayName("M6 - 互评哈希存证与篡改检测（AC-05）")
class EvaluationIntegrityTest {

    /** 构造一条已封存的评价 */
    private EvaluationGrade sealedGrade() {
        EvaluationGrade g = new EvaluationGrade()
                .setRecordId(5L)
                .setFromSno("2024117420")
                .setToSno("2024117421")
                .setDimScores("{\"task_completion\":90.0,\"delivery_quality\":85.0,"
                        + "\"communication\":88.0,\"cross_discipline\":80.0}")
                .setDimCanonical("task_completion=90.0;delivery_quality=85.0;"
                        + "communication=88.0;cross_discipline=80.0")
                .setTotalScore(new BigDecimal("85.75"))
                .setComment("任务按期完成，图表质量不错，沟通顺畅")
                .setAnonymous(0)
                .setDisputeFlag(0)
                .setTimeoutFlag(0)
                .setSealedAt(LocalDateTime.of(2026, 9, 17, 21, 30, 0));
        return g.seal();
    }

    /* ==================== 封存 ==================== */

    @Test
    @DisplayName("封存应生成 SHA-256 哈希、原文与校验码，且立即可通过校验")
    void shouldSealAndVerify() {
        EvaluationGrade g = sealedGrade();

        assertNotNull(g.getRecordHash(), "应生成存证哈希");
        assertEquals(64, g.getRecordHash().length(), "SHA-256 为 64 位十六进制");
        assertNotNull(g.getHashPayload(), "应留存哈希原文，便于精确复算");
        assertNotNull(g.getVerifyCode(), "应生成对外校验码");
        assertEquals(8, g.getVerifyCode().length(), "校验码为 8 位");
        assertEquals(EvidenceLevel.HASH, g.getEvidenceLevel(), "默认存证等级为哈希固化");

        assertTrue(g.verifyIntegrity(), "刚封存的记录必须自洽");
    }

    @Test
    @DisplayName("封存时间被截断到秒，与哈希原文格式一致（避免精度差异导致误报）")
    void shouldTruncateSealedAtToSecond() {
        EvaluationGrade g = new EvaluationGrade()
                .setRecordId(1L).setFromSno("a").setToSno("b")
                .setDimScores("{}").setTotalScore(BigDecimal.TEN)
                .setSealedAt(LocalDateTime.of(2026, 9, 17, 21, 30, 0, 123_456_789));
        g.seal();
        assertEquals(0, g.getSealedAt().getNano(), "封存时间应截断到秒");
    }

    @Test
    @DisplayName("相同内容两次封存（时间相同）应得到相同哈希 —— 保证可复算")
    void shouldBeReproducible() {
        EvaluationGrade a = sealedGrade();
        EvaluationGrade b = sealedGrade();
        assertEquals(a.getRecordHash(), b.getRecordHash(),
                "相同内容与相同时间锚点必须产生相同哈希，否则校验不可靠");
        assertEquals(a.getHashPayload(), b.getHashPayload());
    }

    /* ==================== AC-05：逐字段篡改必须被检出 ==================== */

    @Test
    @DisplayName("AC-05：改动总分应被检出")
    void shouldDetectScoreTampering() {
        EvaluationGrade g = sealedGrade();
        assertTrue(g.verifyIntegrity());

        g.setTotalScore(new BigDecimal("95.00"));   // 把 85.75 改成 95
        assertFalse(g.verifyIntegrity(), "总分被改动必须检出");
    }

    @Test
    @DisplayName("AC-05：改动规范化维度串应被检出（维度分篡改的实际检出路径）")
    void shouldDetectDimensionTampering() {
        EvaluationGrade g = sealedGrade();
        g.setDimCanonical("task_completion=100.0;delivery_quality=100.0;"
                + "communication=100.0;cross_discipline=100.0");
        assertFalse(g.verifyIntegrity(), "规范维度串被改动必须检出");
    }

    @Test
    @DisplayName("参与哈希的是规范串而非 dimScores（刻意的设计约束，勿改回）")
    void hashShouldDependOnCanonicalNotJson() {
        /*
         * 设计约束：dim_scores 是 MySQL JSON 列，读写往返会改变字符串表示
         * （加空格、重排顺序），无法逐字节重现，因此不能参与哈希；
         * 参与哈希的是 dim_canonical（只由数值决定的确定性字符串）。
         *
         * 本用例锁定该约束：仅改变 dimScores 的字符串表示不影响哈希，
         * 数值未变时校验仍应通过。若有人误把 dimScores 改回参与哈希，本测试会失败。
         */
        EvaluationGrade base = sealedGrade();
        EvaluationGrade reformatted = sealedGrade();
        reformatted.setDimScores("{\"communication\": 88.0, \"task_completion\": 90.0, "
                + "\"cross_discipline\": 80.0, \"delivery_quality\": 85.0}");

        assertEquals(base.getRecordHash(), reformatted.getRecordHash(),
                "仅改变 dimScores 的表示不应影响哈希");
        assertTrue(reformatted.verifyIntegrity(), "数值未变，校验应通过");
    }

    @Test
    @DisplayName("AC-05：改动评语应被检出")
    void shouldDetectCommentTampering() {
        EvaluationGrade g = sealedGrade();
        g.setComment("这个评价被改成了别的内容");
        assertFalse(g.verifyIntegrity(), "评语被改动必须检出");
    }

    @Test
    @DisplayName("AC-05：改动评价人或被评价人应被检出")
    void shouldDetectPartyTampering() {
        EvaluationGrade g1 = sealedGrade();
        g1.setFromSno("2024117422");
        assertFalse(g1.verifyIntegrity(), "评价人被改动必须检出");

        EvaluationGrade g2 = sealedGrade();
        g2.setToSno("2024117422");
        assertFalse(g2.verifyIntegrity(), "被评价人被改动必须检出");
    }

    @Test
    @DisplayName("AC-05：改动关联的交换记录 ID 应被检出（防止把评价挪到另一次交换）")
    void shouldDetectRecordIdTampering() {
        EvaluationGrade g = sealedGrade();
        g.setRecordId(6L);
        assertFalse(g.verifyIntegrity(), "交换记录 ID 被改动必须检出");
    }

    @Test
    @DisplayName("AC-05：改动封存时间应被检出")
    void shouldDetectSealedAtTampering() {
        EvaluationGrade g = sealedGrade();
        g.setSealedAt(g.getSealedAt().plusHours(1));
        assertFalse(g.verifyIntegrity(), "封存时间被改动必须检出");
    }

    @Test
    @DisplayName("AC-05：抹掉哈希应判为校验不通过（而不是通过）")
    void shouldFailWhenHashMissing() {
        EvaluationGrade g = sealedGrade();
        g.setRecordHash(null);
        assertFalse(g.verifyIntegrity(), "无哈希必须判为不通过，不能默认通过");
        g.setRecordHash("   ");
        assertFalse(g.verifyIntegrity(), "空白哈希也必须判为不通过");
    }

    @Test
    @DisplayName("AC-05：替换为另一个自洽哈希应被检出（哈希与内容不匹配）")
    void shouldDetectHashSubstitution() {
        EvaluationGrade g = sealedGrade();
        EvaluationGrade other = new EvaluationGrade()
                .setRecordId(99L).setFromSno("x").setToSno("y")
                .setDimScores("{\"task_completion\":10.0}").setTotalScore(BigDecimal.ONE)
                .setSealedAt(LocalDateTime.of(2020, 1, 1, 0, 0, 0));
        other.seal();

        g.setRecordHash(other.getRecordHash());
        assertFalse(g.verifyIntegrity(), "把哈希换成别的记录的哈希必须检出");
        assertNotEquals(g.getRecordHash(), g.buildHashPayload(), "原始内容与哈希不应一致");
    }

    /* ==================== 内容规范化 ==================== */

    @Test
    @DisplayName("评语首尾空白应在封存前规范化，避免同一内容算出不同哈希")
    void shouldTrimCommentBeforeSealing() {
        EvaluationGrade g = new EvaluationGrade()
                .setRecordId(1L).setFromSno("a").setToSno("b")
                .setDimScores("{}").setTotalScore(BigDecimal.TEN)
                .setComment("  内容有前后空格  ")
                .setSealedAt(LocalDateTime.of(2026, 1, 1, 0, 0, 0));
        g.seal();
        assertEquals("内容有前后空格", g.getComment(), "封存时应去掉首尾空白");
        assertTrue(g.verifyIntegrity());
    }

    @Test
    @DisplayName("超时默认计分的记录应可识别")
    void shouldIdentifyTimeoutScored() {
        EvaluationGrade g = sealedGrade().setTimeoutFlag(1);
        assertTrue(g.isTimeoutScored());

        EvaluationGrade normal = sealedGrade();
        assertFalse(normal.isTimeoutScored(), "正常提交不应被标记为超时计分");
    }

    @Test
    @DisplayName("匿名标记应可识别")
    void shouldIdentifyAnonymous() {
        assertTrue(sealedGrade().setAnonymous(1).anonymousSubmission());
        assertFalse(sealedGrade().anonymousSubmission());
    }

    @Test
    @DisplayName("哈希原文格式固定：字段顺序与分隔符不可随意变更")
    void shouldKeepStablePayloadFormat() {
        EvaluationGrade g = sealedGrade();
        String payload = g.getHashPayload();
        // 7 段用 | 连接：recordId|from|to|dims|total|comment|sealedAt
        assertEquals(7, payload.split("\\|", -1).length,
                "哈希原文必须恰好 7 段，改动格式会让所有历史记录校验失败：" + payload);
        assertTrue(payload.startsWith("5|2024117420|2024117421|"), payload);
        assertTrue(payload.endsWith("|2026-09-17 21:30:00"), payload);
    }
}
