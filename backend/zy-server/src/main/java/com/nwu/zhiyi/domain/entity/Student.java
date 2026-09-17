package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.AuthStatus;
import com.nwu.zhiyi.common.enums.AuthType;
import com.nwu.zhiyi.common.enums.UserRole;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户（学生）实体 —— 对应表 {@code zy_student}。
 *
 * <p>与教务基础信息表 {@code STUDENT(sno, sname)} 的对应关系：{@code sno} 为逻辑主键来源，
 * 平台自身业务表通过 {@code sno} 做非侵入式关联，不修改教务库结构。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_student")
public class Student implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 学号（与教务系统一致，逻辑外键） */
    private String sno;

    /** 姓名（映射教务 sname） */
    private String sname;

    /** 昵称（对外展示名） */
    private String nickname;

    /** 密码（BCrypt 哈希；统一认证用户可为空） */
    private String password;

    private String email;

    private String phone;

    private String college;

    private String major;

    private String grade;

    private String avatar;

    private String intro;

    /** 认证方式（数据库以枚举名存储） */
    private AuthType authType;

    /** 实名核验状态（数据库以枚举名存储） */
    private AuthStatus authStatus;

    /** 角色（数据库以枚举名存储） */
    private UserRole role;

    /** 信用值（初始 100） */
    private Integer creditScore;

    /** 信用等级 1~5 */
    private Integer creditLevel;

    /** 并发进行中的交换上限 */
    private Integer exchangeQuota;

    /** 账号状态：0禁用 1正常 2注销 */
    private Integer status;

    private LocalDateTime lastLoginAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    @TableField(select = false)
    private Integer deleted;

    /* ---------------- 领域行为 ---------------- */

    /** 是否为可用状态账号 */
    public boolean isActive() {
        return status != null && status == 1;
    }

    /** 是否为管理员 */
    public boolean isAdmin() {
        return role == UserRole.ADMIN;
    }

    /** 是否为仲裁委员（管理员亦具备裁决权） */
    public boolean isArbitrator() {
        return role == UserRole.ARBITRATOR || role == UserRole.ADMIN;
    }

    /** 对外展示名：优先昵称，其次姓名 */
    public String displayName() {
        return nickname == null || nickname.isEmpty() ? sname : nickname;
    }
}
