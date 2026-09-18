package com.nwu.zhiyi.service;

import cn.hutool.core.util.StrUtil;
import com.nwu.zhiyi.api.dto.LoginRequest;
import com.nwu.zhiyi.api.dto.LoginVO;
import com.nwu.zhiyi.api.dto.RegisterRequest;
import com.nwu.zhiyi.api.dto.UserInfoVO;
import com.nwu.zhiyi.api.dto.profile.ProfileUpdateRequest;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.AuthStatus;
import com.nwu.zhiyi.common.enums.CreditLevel;
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
                .setCreditLevel(CreditLevel.of(CreditLevel.INIT_SCORE).levelCode())
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
     * 修改个人资料（FR-M1-05）。
     *
     * <p><b>只允许改"自我介绍类"字段</b>：昵称、学院、专业、年级、头像、简介。
     * 学号、姓名、角色、信用值、核验状态、账号状态一律不可经此接口改动 ——
     * 前者是全平台业务关联的逻辑外键，后者是治理结果，都有专门的流程与审计链路
     * （见 {@code ProfileUpdateRequest} 的字段说明）。这样收窄不是偷懒，
     * 而是避免"编辑资料"变成绕过治理的后门。
     *
     * <p><b>三态语义（这是本方法最容易做错的地方）</b>：
     * <table border="1">
     *   <tr><th>入参</th><th>含义</th><th>落库</th></tr>
     *   <tr><td>{@code null}</td><td>不修改</td><td>不写该列</td></tr>
     *   <tr><td>{@code ""} 或纯空白</td><td>清空</td><td>写 {@code ""}</td></tr>
     *   <tr><td>{@code "  值  "}</td><td>修改</td><td>写 trim 后的值</td></tr>
     * </table>
     *
     * <p><b>为什么"清空"写空串而不是 NULL</b>：MyBatis-Plus 的 {@code updateById}
     * 默认策略会<b>跳过值为 null 的字段</b>（{@code FieldStrategy.NOT_NULL}），
     * 因此 null 只能表达"不修改"。若把"清空"也实现成写 null，实际效果是
     * "什么都没改" —— 用户点保存后没有任何变化，却收不到任何错误提示。
     * 本项目首次实现就踩了这个坑（由 ProfileUpdateSemanticsTest 抓出）。
     *
     * <p>写空串不影响展示：{@code Student.displayName()} 用
     * {@code nickname.isEmpty()} 判空并回退到实名，前端各处也都是
     * {@code value || '—'} 的写法，空串与 NULL 表现一致。
     *
     * @param sno     学号（取自登录态）
     * @param request 修改请求
     * @return 修改后的用户信息
     */
    @Transactional(rollbackFor = Exception.class)
    public UserInfoVO updateProfile(String sno, ProfileUpdateRequest request) {
        Student student = studentMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Student>()
                        .eq(Student::getSno, sno));
        if (student == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }

        Student patch = new Student().setId(student.getId());
        int changed = 0;
        if (request.getNickname() != null) {
            patch.setNickname(normalize(request.getNickname()));
            changed++;
        }
        if (request.getCollege() != null) {
            patch.setCollege(normalize(request.getCollege()));
            changed++;
        }
        if (request.getMajor() != null) {
            patch.setMajor(normalize(request.getMajor()));
            changed++;
        }
        if (request.getGrade() != null) {
            patch.setGrade(normalize(request.getGrade()));
            changed++;
        }
        if (request.getAvatar() != null) {
            patch.setAvatar(normalize(request.getAvatar()));
            changed++;
        }
        if (request.getIntro() != null) {
            patch.setIntro(normalize(request.getIntro()));
            changed++;
        }

        if (changed == 0) {
            // 没有任何字段被提交：不写库、也不报错，直接回显当前资料。
            // 报错会让"只点了一下保存"变成一个令人困惑的失败。
            log.debug("[资料修改] {} 提交了空请求，未做任何修改", sno);
            return toUserInfo(student);
        }

        studentMapper.updateById(patch);
        log.info("[资料修改] {} 更新了 {} 个字段", sno, changed);
        return toUserInfo(studentMapper.selectById(student.getId()));
    }

    /**
     * 归一化文本输入：裁剪首尾空白；纯空白返回空串（表示"清空"）。
     *
     * <p>返回空串而非 null 是刻意的 —— null 在更新语义里代表"不修改"，
     * 详见 {@link #updateProfile} 的三态说明。
     *
     * @param raw 原始输入，调用方保证非 null
     * @return 裁剪后的值；纯空白时为空串
     */
    private static String normalize(String raw) {
        return raw.trim();
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
