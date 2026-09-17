package com.nwu.zhiyi.service.evaluation;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.EvaluationDimension;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 互评维度分计算测试（FR-M6-02）。
 *
 * @author 李泽宬
 */
@DisplayName("M6 - 互评维度分与总分计算")
class DimensionScoreCalculatorTest {

    private DimensionScoreCalculator calculator;

    @BeforeEach
    void setUp() {
        calculator = new DimensionScoreCalculator();
    }

    private Map<String, Object> fullScores(double value) {
        Map<String, Object> m = new LinkedHashMap<>();
        for (EvaluationDimension d : EvaluationDimension.values()) {
            m.put(d.getKey(), value);
        }
        return m;
    }

    @Test
    @DisplayName("权重之和必须为 1 —— 否则总分口径失真")
    void weightsShouldSumToOne() {
        assertEquals(1.0, EvaluationDimension.weightSum(), 0.0001,
                "四个维度权重之和必须为 1.0，当前为 " + EvaluationDimension.weightSum());
    }

    @Test
    @DisplayName("等权维度下，四项同分时总分等于该分")
    void shouldComputeWeightedTotal() {
        Map<String, Double> n = calculator.normalize(fullScores(90));
        BigDecimal total = calculator.totalScore(n);
        assertEquals(0, total.compareTo(new BigDecimal("90.00")), "四项 90 分总分应为 90，实际 " + total);
    }

    @Test
    @DisplayName("不同维度分应按权重加权（非简单平均）")
    void shouldWeightDimensions() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("task_completion", 100);
        m.put("delivery_quality", 80);
        m.put("communication", 60);
        m.put("cross_discipline", 40);
        // 等权 → 平均 = 70
        Map<String, Double> n = calculator.normalize(m);
        assertEquals(0, calculator.totalScore(n).compareTo(new BigDecimal("70.00")),
                "等权时总分应为算术平均 70，实际 " + calculator.totalScore(n));
    }

    @Test
    @DisplayName("缺任一维度应被拒绝（缺项会让总分失真）")
    void shouldRejectMissingDimension() {
        Map<String, Object> m = fullScores(90);
        m.remove("communication");
        BusinessException ex = assertThrows(BusinessException.class, () -> calculator.normalize(m));
        assertEquals(ErrorCode.EVALUATION_DIMENSION_MISSING.getCode(), ex.getErrorCode().getCode());
        assertTrue(ex.getMessage().contains("沟通效率"), "提示应指明缺哪个维度：" + ex.getMessage());
    }

    @Test
    @DisplayName("空维度分应被拒绝")
    void shouldRejectEmptyScores() {
        assertThrows(BusinessException.class, () -> calculator.normalize(null));
        assertThrows(BusinessException.class, () -> calculator.normalize(Map.of()));
    }

    @Test
    @DisplayName("分数越界应被拒绝")
    void shouldRejectOutOfRange() {
        Map<String, Object> tooHigh = fullScores(100);
        tooHigh.put("task_completion", 101);
        assertThrows(BusinessException.class, () -> calculator.normalize(tooHigh));

        Map<String, Object> negative = fullScores(60);
        negative.put("delivery_quality", -1);
        assertThrows(BusinessException.class, () -> calculator.normalize(negative));
    }

    @Test
    @DisplayName("非数字分数应被拒绝并给出可读提示")
    void shouldRejectNonNumeric() {
        Map<String, Object> m = fullScores(80);
        m.put("communication", "很好");
        BusinessException ex = assertThrows(BusinessException.class, () -> calculator.normalize(m));
        assertTrue(ex.getMessage().contains("沟通效率"), ex.getMessage());
    }

    @Test
    @DisplayName("边界值 0 与 100 应被接受")
    void shouldAcceptBoundaryValues() {
        Map<String, Double> zero = calculator.normalize(fullScores(0));
        assertEquals(0, calculator.totalScore(zero).compareTo(BigDecimal.ZERO.setScale(2)));

        Map<String, Double> full = calculator.normalize(fullScores(100));
        assertEquals(0, calculator.totalScore(full).compareTo(new BigDecimal("100.00")));
    }

    @Test
    @DisplayName("小数分应统一保留一位小数，保证哈希原文稳定")
    void shouldNormalizeDecimals() {
        Map<String, Object> m = fullScores(88.88888);
        Map<String, Double> n = calculator.normalize(m);
        assertEquals(88.9, n.get("task_completion"), 0.0001, "应四舍五入到一位小数");
    }

    @Test
    @DisplayName("JSON 序列化的 key 顺序必须固定，否则哈希原文会不稳定")
    void jsonShouldHaveStableKeyOrder() {
        Map<String, Double> n = calculator.normalize(fullScores(90));
        String json1 = calculator.toJson(n);
        String json2 = calculator.toJson(new LinkedHashMap<>(n));
        assertEquals(json1, json2, "同一组分数必须产生完全相同的 JSON 字符串");

        // 顺序应为枚举声明顺序
        int p1 = json1.indexOf("task_completion");
        int p2 = json1.indexOf("delivery_quality");
        int p3 = json1.indexOf("communication");
        int p4 = json1.indexOf("cross_discipline");
        assertTrue(p1 < p2 && p2 < p3 && p3 < p4, "key 顺序应为枚举声明顺序：" + json1);
    }

    @Test
    @DisplayName("JSON 往返应保持一致")
    void shouldRoundTripJson() {
        Map<String, Double> n = calculator.normalize(fullScores(75.5));
        String json = calculator.toJson(n);
        Map<String, Double> parsed = calculator.fromJson(json);
        assertEquals(n.get("task_completion"), parsed.get("task_completion"), 0.0001);
        assertEquals(4, parsed.size());
    }

    @Test
    @DisplayName("非法 JSON 应安全返回空 Map 而不是抛异常")
    void shouldHandleBrokenJson() {
        assertTrue(calculator.fromJson(null).isEmpty());
        assertTrue(calculator.fromJson("不是JSON").isEmpty());
        assertTrue(calculator.fromJson("").isEmpty());
    }

    @Test
    @DisplayName("中文标签映射应覆盖四个维度")
    void shouldProvideLabeledMap() {
        Map<String, Double> n = calculator.normalize(fullScores(80));
        Map<String, Double> labeled = calculator.toLabeledMap(n);
        assertEquals(4, labeled.size());
        assertNotNull(labeled.get("任务完成度"));
        assertNotNull(labeled.get("交付质量"));
        assertNotNull(labeled.get("沟通效率"));
        assertNotNull(labeled.get("跨专业协作能力"));
    }

    @Test
    @DisplayName("维度解析：按 key 可反查，未识别 key 返回 null")
    void shouldResolveDimensionByKey() {
        assertEquals(EvaluationDimension.TASK_COMPLETION, EvaluationDimension.ofKey("task_completion"));
        assertEquals(EvaluationDimension.COMMUNICATION, EvaluationDimension.ofKey("COMMUNICATION"));
        assertEquals(null, EvaluationDimension.ofKey("unknown_key"));
        assertEquals(null, EvaluationDimension.ofKey(null));
    }
}
