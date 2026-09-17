package com.nwu.zhiyi.service;

import cn.hutool.core.util.StrUtil;
import com.nwu.zhiyi.api.dto.LoginRequest;
import com.nwu.zhiyi.api.dto.LoginVO;
import com.nwu.zhiyi.api.dto.RegisterRequest;
import com.nwu.zhiyi.api.dto.UserInfoVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.AuthStatus;
import com.nwu.zhiyi.common.enums.AuthType;
import com.nwu.zhiyi.common.enums.UserRole;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.domain.mapper.UserSkillProfileMapper;
import com.nwu.zhiyi.security.JwtTokenProvider;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 认证服务：登录、注册、令牌刷新、当前用户信息。
 *
 * <p>对应需求 FR-M1-01 ~ FR-M1-07。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final StudentMapper studentMapper;
    private final UserSkillProfileMapper userSkillProfileMapper;
    private final JwtTokenProvider tokenProvider;
    private final PasswordEncoder passwordEncoder;

    /**
     * 账号密码登录。
     *
     * @param request 登录请求
     * @return 登录结果（含访问令牌与用户信息）
     */
    @Transactional(rollbackFor = Exception.class)
    public LoginVO login(LoginRequest request) {
        Student student = studentMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Student>()
                        .eq(Student::getSno, request.getSno()));

        if (student == null) {
            throw new BusinessException(ErrorCode.LOGIN_FAILED);
        }
        if (!student.isActive()) {
            throw new BusinessException(ErrorCode.ACCOUNT_DISABLED);
        }
        if (StrUtil.isBlank(student.getPassword())
                || !passwordEncoder.matches(request.getPassword(), student.getPassword())) {
            throw new BusinessException(ErrorCode.LOGIN_FAILED);
        }

        // 更新最近登录时间
        Student update = new Student().setId(student.getId()).setLastLoginAt(LocalDateTime.now());
        studentMapper.updateById(update);
        student.setLastLoginAt(update.getLastLoginAt());

        log.info("[登录成功] sno={} role={}", student.getSno(), student.getRole());

        // 未建立技能画像视为首次登录，前端据此触发"新手漫游导引"
        boolean firstLogin = !userSkillProfileMapper.existsBySno(student.getSno());

        return buildLoginVO(student, firstLogin);
    }

    /**
     * 注册（降级方案：邮箱/手机注册 + 学号人工核验）。
     *
     * @param request 注册请求
     * @return 登录结果
     */
    @Transactional(rollbackFor = Exception.class)
    public LoginVO register(RegisterRequest request) {
        Long exists = studentMapper.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Student>()
                        .eq(Student::getSno, request.getSno()));
        if (exists != null && exists > 0) {
            throw new BusinessException(ErrorCode.SNO_ALREADY_EXISTS);
        }

        Student student = new Student()
                .setSno(request.getSno())
                .setSname(request.getSname())
                .setNickname(request.getSname())
                .setPassword(passwordEncoder.encode(request.getPassword()))
                .setEmail(request.getEmail())
                .setPhone(request.getPhone())
                .setCollege(request.getCollege())
                .setMajor(request.getMajor())
                .setGrade(request.getGrade())
                .setAuthType(AuthType.VERIFY)
                .setAuthStatus(AuthStatus.UNVERIFIED)
                .setRole(UserRole.USER)
                .setCreditScore(100)
                .setCreditLevel(1)
                .setExchangeQuota(3)
                .setStatus(1)
                .setLastLoginAt(LocalDateTime.now());
        studentMapper.insert(student);

        log.info("[注册成功] sno={} college={}", student.getSno(), student.getCollege());
        return buildLoginVO(student, true);
    }

    /**
     * 使用刷新令牌换取新的访问令牌。
     *
     * @param refreshToken 刷新令牌
     * @return 登录结果
     */
    @Transactional(rollbackFor = Exception.class)
    public LoginVO refresh(String refreshToken) {
        Claims claims = tokenProvider.parse(refreshToken);
        if (claims == null) {
            throw new BusinessException(ErrorCode.TOKEN_INVALID);
        }
        if (!JwtTokenProvider.TYPE_REFRESH.equals(claims.get(JwtTokenProvider.CLAIM_TYPE, String.class))) {
            throw new BusinessException(ErrorCode.TOKEN_INVALID, "令牌类型不正确，请使用刷新令牌");
        }
        String sno = claims.getSubject();
        Student student = studentMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Student>()
                        .eq(Student::getSno, sno));
        if (student == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        if (!student.isActive()) {
            throw new BusinessException(ErrorCode.ACCOUNT_DISABLED);
        }
        return buildLoginVO(student, false);
    }

    /**
     * 查询当前登录用户信息。
     *
     * @param sno 学号
     * @return 用户信息视图对象
     */
    public UserInfoVO getUserInfo(String sno) {
        Student student = studentMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Student>()
                        .eq(Student::getSno, sno));
        if (student == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        return toUserInfo(student);
    }

    /**
     * 用户实体 → 对外视图对象（脱敏：不含密码、手机号）。
     *
     * @param student 用户实体
     * @return 视图对象
     */
    public UserInfoVO toUserInfo(Student student) {
        return UserInfoVO.builder()
                .sno(student.getSno())
                .displayName(student.displayName())
                .college(student.getCollege())
                .major(student.getMajor())
                .grade(student.getGrade())
                .avatar(student.getAvatar())
                .intro(student.getIntro())
                .role(student.getRole() == null ? null : student.getRole().name())
                .authType(student.getAuthType() == null ? null : student.getAuthType().name())
                .authStatus(student.getAuthStatus() == null ? null : student.getAuthStatus().name())
                .creditScore(student.getCreditScore())
                .creditLevel(student.getCreditLevel())
                .lastLoginAt(student.getLastLoginAt())
                .build();
    }

    private LoginVO buildLoginVO(Student student, boolean firstLogin) {
        UserRole role = student.getRole() == null ? UserRole.USER : student.getRole();
        return LoginVO.builder()
                .accessToken(tokenProvider.createAccessToken(student.getSno(), role))
                .refreshToken(tokenProvider.createRefreshToken(student.getSno(), role))
                .tokenType("Bearer")
                .expiresIn(tokenProvider.getExpireSeconds())
                .firstLogin(firstLogin)
                .user(toUserInfo(student))
                .build();
    }
}
