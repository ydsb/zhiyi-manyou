package com.nwu.zhiyi.service;

import com.nwu.zhiyi.api.dto.LoginVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.UserRole;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.domain.mapper.UserSkillProfileMapper;
import com.nwu.zhiyi.security.JwtTokenProvider;
import com.nwu.zhiyi.security.RefreshTokenStore;
import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 刷新令牌白名单语义测试。
 *
 * <p>核心场景：refresh token 只能消费一次；消费成功后才签发新的一对令牌。
 */
class AuthServiceRefreshTest {

    private final StudentMapper studentMapper = mock(StudentMapper.class);
    private final UserSkillProfileMapper profileMapper = mock(UserSkillProfileMapper.class);
    private final JwtTokenProvider tokenProvider = mock(JwtTokenProvider.class);
    private final PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
    private final RefreshTokenStore refreshTokenStore = mock(RefreshTokenStore.class);

    private final AuthService authService =
            new AuthService(studentMapper, profileMapper, tokenProvider, passwordEncoder, refreshTokenStore);

    @Test
    void consumedRefreshTokenIsRejected() {
        Claims parsedClaims = claims("2024117420", "old-jti");
        when(tokenProvider.parseRefreshToken("old-refresh")).thenReturn(parsedClaims);
        when(refreshTokenStore.consume("old-jti", "2024117420")).thenReturn(false);

        BusinessException ex = assertThrows(BusinessException.class,
                () -> authService.refresh("old-refresh"));

        assertEquals(ErrorCode.TOKEN_INVALID, ex.getErrorCode());
        verify(studentMapper, never()).selectOne(any());
    }

    @Test
    void refreshConsumesOldTokenAndRegistersNewOne() {
        Claims parsedClaims = claims("2024117420", "old-jti");
        when(tokenProvider.parseRefreshToken("old-refresh")).thenReturn(parsedClaims);
        when(refreshTokenStore.consume("old-jti", "2024117420")).thenReturn(true);

        Student student = new Student()
                .setSno("2024117420")
                .setSname("测试用户")
                .setStatus(1)
                .setRole(UserRole.USER);
        when(studentMapper.selectOne(any())).thenReturn(student);
        when(tokenProvider.createAccessToken(anyString(), any(UserRole.class))).thenReturn("new-access");
        when(tokenProvider.createRefreshToken(anyString(), any(UserRole.class))).thenReturn("new-refresh");
        when(tokenProvider.getJtiFromSignedToken("new-refresh")).thenReturn("new-jti");
        when(tokenProvider.getExpireSeconds()).thenReturn(43200L);

        LoginVO result = authService.refresh("old-refresh");

        assertEquals("new-access", result.getAccessToken());
        assertEquals("new-refresh", result.getRefreshToken());
        verify(refreshTokenStore).register("new-jti", "2024117420");
    }

    private static Claims claims(String sno, String jti) {
        Claims claims = mock(Claims.class);
        when(claims.getSubject()).thenReturn(sno);
        when(claims.getId()).thenReturn(jti);
        return claims;
    }
}