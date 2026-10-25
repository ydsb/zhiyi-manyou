package com.nwu.zhiyi.service;

import com.nwu.zhiyi.api.dto.LoginVO;
import com.nwu.zhiyi.api.dto.RegisterRequest;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.UserRole;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.domain.mapper.UserSkillProfileMapper;
import com.nwu.zhiyi.security.JwtTokenProvider;
import com.nwu.zhiyi.security.RefreshTokenStore;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * 注册查重语义测试。
 *
 * <p>核心场景：学号被逻辑删除后重新注册时，查重必须能命中历史记录并返回 3002，
 * 而不是放行到 insert、撞唯一索引后返回 500。
 */
class AuthServiceRegisterTest {

    private final StudentMapper studentMapper = mock(StudentMapper.class);
    private final UserSkillProfileMapper profileMapper = mock(UserSkillProfileMapper.class);
    private final JwtTokenProvider tokenProvider = mock(JwtTokenProvider.class);
    private final PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
    private final RefreshTokenStore refreshTokenStore = mock(RefreshTokenStore.class);

    private final AuthService authService =
            new AuthService(studentMapper, profileMapper, tokenProvider, passwordEncoder, refreshTokenStore);

    @Test
    void logicallyDeletedSnoIsRejectedAsAlreadyRegistered() {
        when(studentMapper.countBySnoIncludingDeleted("2024117420")).thenReturn(1L);

        BusinessException ex = assertThrows(BusinessException.class,
                () -> authService.register(request("2024117420")));

        assertEquals(ErrorCode.SNO_ALREADY_EXISTS, ex.getErrorCode());
        // 查重命中后不应该再插入、也不应该做密码加密
        verify(studentMapper, never()).insert(any(Student.class));
        verifyNoInteractions(passwordEncoder);
        verifyNoInteractions(refreshTokenStore);
    }

    @Test
    void freshSnoIsRegisteredAndTokensAreIssued() {
        when(studentMapper.countBySnoIncludingDeleted("2024999999")).thenReturn(0L);
        when(passwordEncoder.encode("123456")).thenReturn("$2a$10$hashed");
        when(tokenProvider.createAccessToken(anyString(), any(UserRole.class))).thenReturn("access-token");
        when(tokenProvider.createRefreshToken(anyString(), any(UserRole.class))).thenReturn("refresh-token");
        when(tokenProvider.getJtiFromSignedToken("refresh-token")).thenReturn("refresh-jti");
        when(tokenProvider.getExpireSeconds()).thenReturn(43200L);

        LoginVO result = authService.register(request("2024999999"));

        assertNotNull(result);
        assertEquals("access-token", result.getAccessToken());
        assertEquals("refresh-token", result.getRefreshToken());
        assertEquals(Boolean.TRUE, result.getFirstLogin());
        verify(studentMapper).insert(any(Student.class));
        verify(refreshTokenStore).register("refresh-jti", "2024999999");
    }

    @Test
    void duplicateInsertRaceIsTranslatedToAlreadyRegistered() {
        when(studentMapper.countBySnoIncludingDeleted("2024888888")).thenReturn(0L);
        when(passwordEncoder.encode("123456")).thenReturn("$2a$10$hashed");
        when(studentMapper.insert(any(Student.class)))
                .thenThrow(new DuplicateKeyException("Duplicate entry '2024888888' for key 'uk_student_sno'"));

        BusinessException ex = assertThrows(BusinessException.class,
                () -> authService.register(request("2024888888")));

        assertEquals(ErrorCode.SNO_ALREADY_EXISTS, ex.getErrorCode());
    }
    private static RegisterRequest request(String sno) {
        RegisterRequest request = new RegisterRequest();
        request.setSno(sno);
        request.setSname("测试用户");
        request.setPassword("123456");
        return request;
    }
}