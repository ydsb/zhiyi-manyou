package com.nwu.zhiyi.security;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 标记「需要实名核验（authStatus = VERIFIED）」的业务操作。
 *
 * <p><b>为什么不做成登录门槛</b>：匿名访客都能浏览公开内容，如果未核验用户连登录都被拒，
 * 他反而"连访客都不如"。实名核验是<b>按操作</b>的权限门：浏览不需要，发布/交换/互评等需要。
 *
 * <p>由 {@link VerificationAspect} 统一校验，失败返回 {@code 2006 AUTH_NOT_VERIFIED}。
 *
 * @author yueyong
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequireVerified {
}