package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.enums.UserRole;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

class JwtTokenProviderTest {

    @Test
    void refusesMissingOrShortSigningSecret() {
        JwtProperties missing = new JwtProperties();
        missing.setSecret("");
        assertThrows(IllegalStateException.class, () -> new JwtTokenProvider(missing));

        JwtProperties shortSecret = new JwtProperties();
        shortSecret.setSecret("too-short");
        assertThrows(IllegalStateException.class, () -> new JwtTokenProvider(shortSecret));
    }

    @Test
    void acceptsASecretOfAtLeast32Utf8Bytes() {
        JwtProperties properties = new JwtProperties();
        properties.setSecret("01234567890123456789012345678901");
        JwtTokenProvider provider = new JwtTokenProvider(properties);

        assertDoesNotThrow(() -> provider.createAccessToken("student-1", UserRole.USER));
    }

    @Test
    void revokedTokenCannotBeParsedAfterLogout() {
        JwtProperties properties = new JwtProperties();
        properties.setSecret("01234567890123456789012345678901");
        TokenRevocationService revocations = new TokenRevocationService();
        JwtTokenProvider provider = new JwtTokenProvider(properties, revocations);

        String token = provider.createAccessToken("student-1", UserRole.USER);
        assertNotNull(provider.parse(token));
        assertNotNull(provider.getJti(token));
        assertDoesNotThrow(() -> provider.revoke(token));
        assertNull(provider.parse(token));
        assertNull(provider.getJti(token));
    }
}
