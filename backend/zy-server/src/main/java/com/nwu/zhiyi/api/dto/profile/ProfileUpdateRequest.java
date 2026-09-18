package com.nwu.zhiyi.api.dto.profile;

import jakarta.validation.constraints.Size;
import lombok.Data;

import java.io.Serializable;

/**
 * 个人资料修改请求（FR-M1-05）。
 *
 * <p><b>哪些字段可改、哪些不可改</b>，这里是有意收窄的：
 *
 * <table border="1">
 *   <tr><th>字段</th><th>可改</th><th>理由</th></tr>
 *   <tr><td>昵称 / 学院 / 专业 / 年级 / 简介 / 头像</td><td>是</td>
 *       <td>FR-M1-05 明确要求用户可编辑</td></tr>
 *   <tr><td>学号 {@code sno}</td><td><b>否</b></td>
 *       <td>是教务系统的逻辑外键，全平台业务表都靠它关联；一旦可改，
 *           历史交换、互评、信用流水会全部指向一个不存在的学号</td></tr>
 *   <tr><td>姓名 {@code sname}</td><td><b>否</b></td>
 *       <td>映射教务库，属于实名信息，需走核验流程而不是用户自填</td></tr>
 *   <tr><td>角色 / 信用值 / 核验状态 / 账号状态</td><td><b>否</b></td>
 *       <td>这些是治理结果，由 M8 与 M9 通过专门接口调整并留审计日志；
 *           允许在"编辑资料"里顺手改掉，等于绕过了整套治理链路</td></tr>
 *   <tr><td>手机号 / 邮箱</td><td><b>本次未开放</b></td>
 *       <td>表注释写明"脱敏展示、加密存储"，但现状是明文存储。
 *           在加密方案落地前开放编辑，会把明文手机号的暴露面扩大，
 *           因此先不提供，而不是先做了再说</td></tr>
 * </table>
 *
 * <p>字段全部可空：前端是"提交整份表单"，但用户可能只改了一项。
 * 为空的字段按"不修改"处理（而不是清空），避免误操作把已有资料抹掉。
 * 想真正清空某个字段，传空字符串 {@code ""}。
 *
 * @author 李泽宬
 */
@Data
public class ProfileUpdateRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    @Size(max = 64, message = "昵称长度不能超过 64 位")
    private String nickname;

    @Size(max = 64, message = "学院名称长度不能超过 64 位")
    private String college;

    @Size(max = 64, message = "专业名称长度不能超过 64 位")
    private String major;

    @Size(max = 16, message = "年级长度不能超过 16 位")
    private String grade;

    @Size(max = 255, message = "头像地址长度不能超过 255 位")
    private String avatar;

    @Size(max = 500, message = "个人简介不能超过 500 字")
    private String intro;
}
