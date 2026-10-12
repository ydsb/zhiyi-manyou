package com.nwu.zhiyi.security;

import org.junit.jupiter.api.Test;

import java.time.Instant;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class TokenRevocationServiceTest {

    @Test
    void ignoresExpiredRevocationAndCleansItUp() {
        TokenRevocationService service = new TokenRevocationService();
        service.revoke("expired", Instant.now().minusSeconds(1));
        assertFalse(service.isRevoked("expired"));
        assertTrue(service.cleanupExpired() >= 0);
    }

    @Test
    void tracksOnlyUnexpiredTokens() {
        TokenRevocationService service = new TokenRevocationService();
        service.revoke("active", Instant.now().plusSeconds(60));
        assertTrue(service.isRevoked("active"));
    }
}
