package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.junit.jupiter.api.Test;

import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RequestRateLimiterTest {

    @Test
    void rejectsRequestsAfterWindowQuotaIsConsumed() {
        RequestRateLimiter limiter = new RequestRateLimiter();
        Duration window = Duration.ofMinutes(1);
        assertTrue(limiter.tryAcquire("demand:create:user-1", 2, window));
        assertTrue(limiter.tryAcquire("demand:create:user-1", 2, window));

        BusinessException exceeded = assertThrows(BusinessException.class,
                () -> limiter.check("demand:create:user-1", 2, window));
        assertEquals(ErrorCode.RATE_LIMITED, exceeded.getErrorCode());
    }

    @Test
    void separatesDifferentKeys() {
        RequestRateLimiter limiter = new RequestRateLimiter();
        Duration window = Duration.ofMinutes(1);
        limiter.check("user-a", 1, window);
        limiter.check("user-b", 1, window);
    }
}
