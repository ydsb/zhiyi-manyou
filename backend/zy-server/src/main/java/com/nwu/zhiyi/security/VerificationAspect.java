package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.AuthStatus;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

/**
 * 实名核验门：拦截标注了 {@link RequireVerified} 的业务方法。
 *
 * <p>校验顺序：
 * <ol>
 *   <li>没有登录态 -> 2001（正常不会走到这里，属于防御性兜底）</li>
 *   <li>{@code auth_status != VERIFIED} -> 2006</li>
 *   <li>通过 -> 继续执行原方法</li>
 * </ol>
 *
 * <p>注意：这里用 AOP 而不是在登录时拦截，是为了区分「能看」和「能写」——
 * 未核验用户可以浏览公开内容，但不能发布需求 / 发起交换 / 提交互评等。
 *
 * @author yueyong
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class VerificationAspect {

    private final StudentMapper studentMapper;

    @Around("@annotation(com.nwu.zhiyi.security.RequireVerified)")
    public Object guard(ProceedingJoinPoint joinPoint) throws Throwable {
        String sno = SecurityUtils.currentSnoOrNull();
        if (sno == null) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED);
        }
        String authStatus = studentMapper.selectAuthStatusBySno(sno);
        if (!AuthStatus.VERIFIED.name().equals(authStatus)) {
            log.info("[实名核验] 未核验用户尝试执行受限操作：sno={} authStatus={}", sno, authStatus);
            throw new BusinessException(ErrorCode.ACCOUNT_NOT_VERIFIED);
        }
        return joinPoint.proceed();
    }
}