package com.nwu.zhiyi.common.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 哈希工具：用于互评记录的存证固化与校验。
 *
 * @author 李泽宬
 */
public final class HashUtils {

    private static final char[] HEX = "0123456789abcdef".toCharArray();

    private HashUtils() {
    }

    /**
     * 计算 SHA-256 十六进制摘要。
     *
     * @param raw 原文
     * @return 64 位小写十六进制字符串
     */
    public static String sha256Hex(String raw) {
        if (raw == null) {
            raw = "";
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(raw.getBytes(StandardCharsets.UTF_8));
            char[] out = new char[bytes.length * 2];
            for (int i = 0; i < bytes.length; i++) {
                int v = bytes[i] & 0xFF;
                out[i * 2] = HEX[v >>> 4];
                out[i * 2 + 1] = HEX[v & 0x0F];
            }
            return new String(out);
        } catch (NoSuchAlgorithmException e) {
            // JDK 必然支持 SHA-256，此处不会发生
            throw new IllegalStateException("当前 JDK 不支持 SHA-256", e);
        }
    }

    /**
     * 由完整哈希派生出便于人工抄录的短校验码（8 位大写十六进制）。
     *
     * @param hash 完整哈希
     * @return 短校验码，如 {@code 3F9A21C7}
     */
    public static String shortVerifyCode(String hash) {
        if (hash == null || hash.length() < 8) {
            return "";
        }
        return hash.substring(0, 8).toUpperCase();
    }

    /**
     * 校验原文与哈希是否匹配。
     *
     * @param raw  原文
     * @param hash 期望哈希
     * @return 匹配返回 true
     */
    public static boolean matches(String raw, String hash) {
        return hash != null && hash.equalsIgnoreCase(sha256Hex(raw));
    }
}
