package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;

/**
 * 当前登录用户工具类。
 *
 * @author 李泽宬
 */
public final class SecurityUtils {

    private SecurityUtils() {
    }

    /** 获取当前登录主体（可能为空） */
    public static Optional<UserPrincipal> currentPrincipal() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return Optional.empty();
        }
        Object principal = authentication.getPrincipal();
        if (principal instanceof UserPrincipal) {
            return Optional.of((UserPrincipal) principal);
        }
        return Optional.empty();
    }

    /**
     * 获取当前登录学号，未登录抛出 401 业务异常。
     *
     * @return 学号
     */
    public static String currentSno() {
        return currentPrincipal()
                .map(UserPrincipal::getSno)
                .orElseThrow(() -> new BusinessException(ErrorCode.UNAUTHORIZED));
    }

    /** 获取当前登录学号，未登录返回 null（用于可选登录的场景） */
    public static String currentSnoOrNull() {
        return currentPrincipal().map(UserPrincipal::getSno).orElse(null);
    }

    /** 当前用户是否为管理员 */
    public static boolean isAdmin() {
        return currentPrincipal().map(p -> p.getRole().name().equals("ADMIN")).orElse(false);
    }

    /** 当前用户是否为仲裁委员或管理员 */
    public static boolean isArbitrator() {
        return currentPrincipal()
                .map(p -> "ARBITRATOR".equals(p.getRole().name()) || "ADMIN".equals(p.getRole().name()))
                .orElse(false);
    }
}
