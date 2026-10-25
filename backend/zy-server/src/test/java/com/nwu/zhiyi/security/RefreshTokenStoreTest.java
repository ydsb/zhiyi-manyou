package com.nwu.zhiyi.security;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RefreshTokenStoreTest {

    private final RefreshTokenStore store = new RefreshTokenStore();

    @Test
    void refreshTokenCanOnlyBeConsumedOnce() {
        store.register("jti-1", "2024117420");

        assertTrue(store.consume("jti-1", "2024117420"));
        assertFalse(store.consume("jti-1", "2024117420"));
    }

    @Test
    void wrongSnoCannotConsumeToken() {
        store.register("jti-2", "2024117420");

        // 学号不匹配时不能消费，也不能把别人的令牌消耗掉
        assertFalse(store.consume("jti-2", "2024999999"));
        assertTrue(store.consume("jti-2", "2024117420"));
    }

    @Test
    void revokedTokenCannotBeConsumed() {
        store.register("jti-3", "2024117420");
        store.revoke("jti-3");

        assertFalse(store.consume("jti-3", "2024117420"));
    }

    @Test
    void unknownTokenCannotBeConsumed() {
        assertFalse(store.consume("not-registered", "2024117420"));
    }
}