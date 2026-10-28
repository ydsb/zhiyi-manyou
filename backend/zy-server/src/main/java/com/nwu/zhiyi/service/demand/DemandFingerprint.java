package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.common.enums.DemandVisibility;
import com.nwu.zhiyi.domain.entity.Demand;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HexFormat;

/**
 * 需求卡片内容指纹。
 *
 * <p>用于限制同一用户同时存在多张内容完全相同的开放卡片。指纹只包含用户可编辑的
 * 业务字段，不包含 {@code demandNo}、主键、时间戳、状态、审核信息、浏览量等
 * 服务端派生字段。</p>
 *
 * <p>字符串使用 UTF-8 字节长度做前缀，避免通过拼接分隔符制造歧义；空字符串与
 * {@code null} 统一视为空值。数据库迁移脚本使用同样的规范化规则回填历史数据。</p>
 *
 * @author yueyong
 */
public final class DemandFingerprint {

    private static final char FIELD_SEPARATOR = '\u001F';
    private static final String NULL_VALUE = "N";
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private DemandFingerprint() {
    }

    public static String of(Demand demand) {
        return of(demand.getTitle(), demand.getDescription(), demand.getExpectedSkillId(),
                demand.getOfferSkillId(), demand.getExpectedHours(), demand.getExpectedPeriod(),
                demand.getVisibility(), demand.getExpireAt());
    }

    public static String of(String title,
                            String description,
                            Long expectedSkillId,
                            Long offerSkillId,
                            Integer expectedHours,
                            String expectedPeriod,
                            DemandVisibility visibility,
                            LocalDateTime expireAt) {
        StringBuilder canonical = new StringBuilder(512);
        appendString(canonical, normalize(title));
        appendSeparator(canonical);
        appendString(canonical, normalize(description));
        appendSeparator(canonical);
        appendLong(canonical, expectedSkillId);
        appendSeparator(canonical);
        appendLong(canonical, offerSkillId);
        appendSeparator(canonical);
        appendInteger(canonical, expectedHours);
        appendSeparator(canonical);
        appendString(canonical, normalize(expectedPeriod));
        appendSeparator(canonical);
        appendString(canonical, visibility == null ? null : visibility.name());
        appendSeparator(canonical);
        appendString(canonical, expireAt == null ? null : TIME_FORMATTER.format(expireAt));
        return sha256(canonical.toString());
    }

    private static String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static void appendString(StringBuilder target, String value) {
        if (value == null) {
            target.append(NULL_VALUE);
            return;
        }
        int bytes = value.getBytes(StandardCharsets.UTF_8).length;
        target.append('S').append(':').append(bytes).append(':').append(value);
    }

    private static void appendLong(StringBuilder target, Long value) {
        if (value == null) {
            target.append(NULL_VALUE);
        } else {
            target.append('L').append(':').append(value);
        }
    }

    private static void appendInteger(StringBuilder target, Integer value) {
        if (value == null) {
            target.append(NULL_VALUE);
        } else {
            target.append('I').append(':').append(value);
        }
    }

    private static void appendSeparator(StringBuilder target) {
        target.append(FIELD_SEPARATOR);
    }

    private static String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 is unavailable", e);
        }
    }
}
