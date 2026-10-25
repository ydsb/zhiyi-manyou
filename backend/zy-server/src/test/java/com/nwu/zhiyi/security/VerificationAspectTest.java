package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.AuthStatus;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import org.aspectj.lang.ProceedingJoinPoint;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 实名核验门测试：未登录 -> 2001；未核验 -> 2006；已核验 -> 放行。
 */
class VerificationAspectTest {

    private final StudentMapper studentMapper = mock(StudentMapper.class);
    private final VerificationAspect aspect = new VerificationAspect(studentMapper);
    private final ProceedingJoinPoint joinPoint = mock(ProceedingJoinPoint.class);

    @AfterEach
    void clearContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void unauthenticatedUserIsRejected() throws Throwable {
        BusinessException ex = assertThrows(BusinessException.class, () -> aspect.guard(joinPoint));

        assertEquals(ErrorCode.UNAUTHORIZED, ex.getErrorCode());
        verify(joinPoint, never()).proceed();
    }

    @Test
    void unverifiedUserIsRejectedWith2006() throws Throwable {
        login("2024117420");
        when(studentMapper.selectAuthStatusBySno("2024117420")).thenReturn(AuthStatus.UNVERIFIED.name());

        BusinessException ex = assertThrows(BusinessException.class, () -> aspect.guard(joinPoint));

        assertEquals(ErrorCode.ACCOUNT_NOT_VERIFIED, ex.getErrorCode());
        verify(joinPoint, never()).proceed();
    }

    @Test
    void verifiedUserCanProceed() throws Throwable {
        login("2024117420");
        when(studentMapper.selectAuthStatusBySno("2024117420")).thenReturn(AuthStatus.VERIFIED.name());
        Object result = new Object();
        when(joinPoint.proceed()).thenReturn(result);

        assertSame(result, aspect.guard(joinPoint));
        verify(joinPoint).proceed();
    }

    private static void login(String sno) {
        UserPrincipal principal = UserPrincipal.of(sno, "USER");
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities()));
    }
}