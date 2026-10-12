package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class LoginProtectionServiceTest {

    @Test
    void locksAfterFiveFailuresAndSuccessResetsState() {
        LoginProtectionService service = new LoginProtectionService();
        for (int i = 0; i < LoginProtectionService.MAX_FAILURES; i++) {
            service.recordFailure("20240001", "127.0.0.1");
        }

        BusinessException locked = assertThrows(BusinessException.class,
                () -> service.ensureAllowed("20240001", "127.0.0.1"));
        assertEquals(ErrorCode.LOGIN_RATE_LIMITED, locked.getErrorCode());

        service.recordSuccess("20240001", "127.0.0.1");
        assertDoesNotThrow(() -> service.ensureAllowed("20240001", "127.0.0.1"));
    }

    @Test
    void differentIpHasIndependentFailureCounter() {
        LoginProtectionService service = new LoginProtectionService();
        for (int i = 0; i < LoginProtectionService.MAX_FAILURES; i++) {
            service.recordFailure("20240001", "127.0.0.1");
        }
        assertDoesNotThrow(() -> service.ensureAllowed("20240001", "127.0.0.2"));
    }
}
