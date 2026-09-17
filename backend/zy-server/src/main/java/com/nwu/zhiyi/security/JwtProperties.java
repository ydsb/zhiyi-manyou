package com.nwu.zhiyi.security;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * JWT 配置项，对应 {@code zhiyi.jwt.*}。
 *
 * <p>生产环境务必通过环境变量 {@code ZHIYI_JWT_SECRET} 覆盖默认密钥。
 *
 * @author 李泽宬
 */
@Data
@Component
@ConfigurationProperties(prefix = "zhiyi.jwt")
public class JwtProperties {

    /** 签名密钥（HS256，长度需 ≥ 32 字节） */
    private String secret = "zhiyi-manyou-dev-secret-key-please-change-in-production-2026";

    /** 访问令牌有效期（分钟） */
    private long expireMinutes = 720;

    /** 刷新令牌有效期（分钟） */
    private long refreshExpireMinutes = 10080;

    /** 签发者 */
    private String issuer = "zhiyi-manyou";
}
