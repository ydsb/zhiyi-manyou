package com.nwu.zhiyi.security;

import com.nwu.zhiyi.common.enums.UserRole;
import com.nwu.zhiyi.domain.entity.Student;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

/**
 * 登录用户主体，承载学号与角色，供安全上下文与业务层使用。
 *
 * @author 李泽宬
 */
@Getter
public class UserPrincipal implements UserDetails {

    private static final long serialVersionUID = 1L;

    /** 学号（用户名） */
    private final String sno;

    /** 密码哈希 */
    private final String password;

    /** 姓名 */
    private final String sname;

    /** 角色 */
    private final UserRole role;

    /** 账号是否可用 */
    private final boolean enabled;

    private final Collection<? extends GrantedAuthority> authorities;

    public UserPrincipal(String sno, String password, String sname, UserRole role, boolean enabled) {
        this.sno = sno;
        this.password = password;
        this.sname = sname;
        this.role = role == null ? UserRole.USER : role;
        this.enabled = enabled;
        this.authorities = Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + this.role.name()));
    }

    /**
     * 由用户实体构建主体。
     *
     * @param student 用户实体
     * @return 登录主体
     */
    public static UserPrincipal from(Student student) {
        return new UserPrincipal(student.getSno(), student.getPassword(), student.getSname(),
                student.getRole(), student.isActive());
    }

    /**
     * 轻量构建（仅用于 JWT 解析后的上下文恢复，不参与密码校验）。
     *
     * @param sno  学号
     * @param role 角色
     * @return 登录主体
     */
    public static UserPrincipal of(String sno, String role) {
        UserRole userRole;
        try {
            userRole = role == null ? UserRole.USER : UserRole.valueOf(role);
        } catch (IllegalArgumentException e) {
            userRole = UserRole.USER;
        }
        return new UserPrincipal(sno, null, sno, userRole, true);
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getUsername() {
        return sno;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }
}
