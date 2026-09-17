package com.nwu.zhiyi.service.evaluation;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.EvaluationDimension;
import com.nwu.zhiyi.common.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 互评维度分计算器（FR-M6-02）。
 *
 * <p><b>单一口径原则</b>：总分只能由这里算出来。能力雷达图（M7）、信用计算（M8）、
 * 能力鉴定报告都引用同一个 {@code totalScore}；如果各模块自行加权，会出现
 * "同一份评价在不同页面分数不同"的问题，且无法追溯以哪个为准。
 *
 * <p>校验规则：
 * <ul>
 *   <li>四个维度（{@link EvaluationDimension}）全部必填 —— 缺项会让总分失真；</li>
 *   <li>每项取值 0~100 的整数或一位小数；</li>
 *   <li>总分 = Σ(维度分 × 权重)，四舍五入保留两位小数。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Slf4j
@Component
public class DimensionScoreCalculator {

    /** 维度分下限 */
    private static final double MIN_SCORE = 0;
    /** 维度分上限 */
    private static final double MAX_SCORE = 100;

    /**
     * 解析并校验维度分。
     *
     * @param dimScores 维度分 Map（key 为 {@link EvaluationDimension#getKey()}）
     * @return 规范化后的维度分（保持顺序）
     * @throws BusinessException 缺项或越界时抛出
     */
    public Map<String, Double> normalize(Map<String, Object> dimScores) {
        if (dimScores == null || dimScores.isEmpty()) {
            throw new BusinessException(ErrorCode.EVALUATION_DIMENSION_MISSING);
        }
        Map<String, Double> normalized = new LinkedHashMap<>();
        for (EvaluationDimension dimension : EvaluationDimension.values()) {
            Object raw = dimScores.get(dimension.getKey());
            if (raw == null) {
                throw new BusinessException(ErrorCode.EVALUATION_DIMENSION_MISSING,
                        "缺少评价维度：" + dimension.getLabel());
            }
            double value = toDouble(raw, dimension);
            normalized.put(dimension.getKey(), value);
        }
        // 提示未识别的多余维度（不报错，但记录日志便于排查前端拼错 key）
        for (String key : dimScores.keySet()) {
            if (EvaluationDimension.ofKey(key) == null) {
                log.warn("[互评] 忽略未识别的评价维度：{}", key);
            }
        }
        return normalized;
    }

    /**
     * 计算加权总分。
     *
     * @param normalized 已规范化的维度分
     * @return 总分 0~100，保留两位小数
     */
    public BigDecimal totalScore(Map<String, Double> normalized) {
        double sum = 0;
        for (EvaluationDimension dimension : EvaluationDimension.values()) {
            Double value = normalized.get(dimension.getKey());
            if (value != null) {
                sum += value * dimension.getWeight();
            }
        }
        return BigDecimal.valueOf(sum).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 把维度分序列化为 JSON 字符串（存库用）。
     *
     * <p>使用固定顺序（枚举声明顺序），保证同一组分数产生的字符串完全一致 ——
     * 否则哈希原文会因 key 顺序不同而变化，历史记录校验将不可靠。
     *
     * @param normalized 规范化维度分
     * @return JSON 字符串
     */
    public String toJson(Map<String, Double> normalized) {
        JSONObject json = new JSONObject(true);
        for (EvaluationDimension dimension : EvaluationDimension.values()) {
            Double value = normalized.get(dimension.getKey());
            json.set(dimension.getKey(), value == null ? 0 : value);
        }
        return json.toString();
    }

    /**
     * 从 JSON 字符串还原维度分（读取展示用）。
     *
     * @param json JSON 字符串
     * @return 维度分 Map，解析失败返回空 Map
     */
    public Map<String, Double> fromJson(String json) {
        Map<String, Double> result = new LinkedHashMap<>();
        if (json == null || json.isBlank()) {
            return result;
        }
        try {
            JSONObject obj = JSONUtil.parseObj(json);
            for (EvaluationDimension dimension : EvaluationDimension.values()) {
                Object v = obj.get(dimension.getKey());
                if (v != null) {
                    result.put(dimension.getKey(), Double.parseDouble(String.valueOf(v)));
                }
            }
        } catch (Exception e) {
            log.warn("[互评] 维度分 JSON 解析失败：{} - {}", json, e.getMessage());
        }
        return result;
    }

    /**
     * 生成维度中文标签映射（前端展示用）。
     *
     * @param normalized 维度分
     * @return 标签 → 分值
     */
    public Map<String, Double> toLabeledMap(Map<String, Double> normalized) {
        Map<String, Double> labeled = new LinkedHashMap<>();
        for (EvaluationDimension dimension : EvaluationDimension.values()) {
            Double value = normalized.get(dimension.getKey());
            if (value != null) {
                labeled.put(dimension.getLabel(), value);
            }
        }
        return labeled;
    }

    /**
     * 生成**规范化维度串**：固定顺序、固定小数位、固定分隔符。
     *
     * <p>为什么需要它，而不是直接用 dimScores 原串参与哈希：
     * dim_scores 列是 MySQL 的 JSON 类型，而 JSON 属于"规范化存储"——
     * 写入的紧凑串与读回的表示可能不同（会加空格、按内部顺序重排）。
     * 哈希要求"原文可逐字节重现"，因此不能拿 JSON 列的原始字符串参与计算。
     *
     * <p>这里另生成一份确定性字符串（同时落库为独立列），它只由数值决定、
     * 与存储格式无关，从而保证：
     *   - 未改动：重建的规范串与封存时逐字节一致 → 校验通过；
     *   - 任一维度分被改：规范串必然变化 → 校验失败（检出篡改）。
     *
     * <p>格式：key=value 以 ; 连接，顺序为枚举声明顺序，数值统一一位小数。
     * 此格式一旦确定不可再改。
     *
     * @param normalized 规范化维度分
     * @return 规范串
     */
    public String toCanonical(Map<String, Double> normalized) {
        StringBuilder sb = new StringBuilder();
        for (EvaluationDimension dimension : EvaluationDimension.values()) {
            if (sb.length() > 0) {
                sb.append(';');
            }
            Double value = normalized.get(dimension.getKey());
            sb.append(dimension.getKey()).append('=')
                    .append(BigDecimal.valueOf(value == null ? 0 : value)
                            .setScale(1, RoundingMode.HALF_UP)
                            .toPlainString());
        }
        return sb.toString();
    }

    /**
     * 由 JSON 串还原规范串（历史数据回填与容错路径）。
     *
     * @param dimScoresJson 维度分 JSON
     * @return 规范串；维度不全或 JSON 不可解析时返回 null
     */
    public String canonicalFromJson(String dimScoresJson) {
        Map<String, Double> parsed = fromJson(dimScoresJson);
        if (parsed.size() != EvaluationDimension.values().length) {
            return null;
        }
        return toCanonical(parsed);
    }
    private double toDouble(Object raw, EvaluationDimension dimension) {
        double value;
        try {
            value = Double.parseDouble(String.valueOf(raw).trim());
        } catch (NumberFormatException e) {
            throw BusinessException.paramInvalid(
                    "维度「" + dimension.getLabel() + "」的分数不是合法数字：" + raw);
        }
        if (value < MIN_SCORE || value > MAX_SCORE) {
            throw new BusinessException(ErrorCode.EVALUATION_SCORE_OUT_OF_RANGE,
                    String.format("维度「%s」的分数应在 %.0f~%.0f 之间，当前为 %s",
                            dimension.getLabel(), MIN_SCORE, MAX_SCORE, raw));
        }
        // 统一保留一位小数，避免 88.88888 这类值进入哈希原文
        return BigDecimal.valueOf(value).setScale(1, RoundingMode.HALF_UP).doubleValue();
    }
}
