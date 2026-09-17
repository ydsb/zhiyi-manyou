package com.nwu.zhiyi.common.api;

import lombok.Getter;

/**
 * 全局错误码。
 *
 * <p>分段约定：
 * <ul>
 *   <li>0：成功</li>
 *   <li>1xxx：参数与请求错误</li>
 *   <li>2xxx：认证与权限错误</li>
 *   <li>3xxx：业务错误</li>
 *   <li>4xxx：外部依赖错误（AI、向量库、缓存等）</li>
 *   <li>5xxx：系统错误</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Getter
public enum ErrorCode {

    /* ---------------- 成功 ---------------- */
    SUCCESS(0, "操作成功"),

    /* ---------------- 1xxx 参数 ---------------- */
    PARAM_INVALID(1001, "请求参数不合法"),
    PARAM_MISSING(1002, "缺少必要参数"),
    PARAM_FORMAT_ERROR(1003, "参数格式错误"),
    REQUEST_METHOD_NOT_SUPPORTED(1004, "请求方法不支持"),
    REQUEST_BODY_MISSING(1005, "请求体不能为空"),

    /* ---------------- 2xxx 认证与权限 ---------------- */
    UNAUTHORIZED(2001, "未登录或登录已过期"),
    FORBIDDEN(2002, "无权限执行该操作"),
    TOKEN_INVALID(2003, "令牌无效"),
    TOKEN_EXPIRED(2004, "令牌已过期"),
    ACCOUNT_DISABLED(2005, "账号已被禁用"),
    ACCOUNT_NOT_VERIFIED(2006, "账号未通过实名核验"),

    /* ---------------- 3xxx 业务 ---------------- */
    LOGIN_FAILED(3001, "学号或密码错误"),
    SNO_ALREADY_EXISTS(3002, "该学号已注册"),
    USER_NOT_FOUND(3003, "用户不存在"),
    SKILL_NOT_FOUND(3004, "技能标签不存在"),
    SKILL_ALREADY_EXISTS(3005, "技能标签已存在"),
    EXCHANGE_NOT_FOUND(3006, "交换记录不存在"),
    EXCHANGE_STATUS_ILLEGAL(3007, "当前交换状态不允许该操作"),
    EXCHANGE_QUOTA_EXCEEDED(3008, "进行中的交换数量已达上限"),
    CANNOT_EXCHANGE_WITH_SELF(3009, "不能与自己发起技能交换"),
    EVALUATION_ALREADY_SUBMITTED(3010, "已提交过评价，不可重复提交"),
    EVALUATION_NOT_ALLOWED(3011, "当前状态不可评价"),
    EVALUATION_IMMUTABLE(3012, "评价记录已存证，不可修改"),
    DISPUTE_ALREADY_EXISTS(3013, "该交换已存在处理中的争议"),
    NOT_PARTICIPANT(3014, "你不是该交换的参与方"),
    MATCH_NO_RESULT(3015, "暂无匹配结果"),

    /* ---------------- 3xxx 供需集市与交换（M4） ---------------- */
    DEMAND_NOT_FOUND(3020, "需求卡片不存在"),
    DEMAND_NOT_OPEN(3021, "该需求已停止招募"),
    DEMAND_OWNER_CANNOT_APPLY(3022, "不能对自己发布的需求发起交换"),
    INTEREST_ALREADY_EXISTS(3023, "你已对该需求发起过交换，请等待对方响应"),
    INTEREST_NOT_FOUND(3024, "交换意向不存在"),
    INTEREST_NOT_PENDING(3025, "该交换意向已处理，不能重复操作"),
    DEMAND_NOT_OWNER(3026, "只有发布人可以执行该操作"),
    DEMAND_CONTENT_REJECTED(3027, "内容未通过审核"),
    PENDING_INTEREST_LIMIT(3028, "你待响应的交换邀约过多，请先处理现有邀约"),
    EXCHANGE_SKILL_REQUIRED(3029, "交换双方技能不能相同"),
    AUDIT_PENDING(3030, "内容需人工复核，暂时无法公开"),

    /* ---------------- 3xxx 协作工作台（M5） ---------------- */
    WORKSPACE_NOT_AVAILABLE(3040, "该交换尚未进入协作阶段"),
    TASK_NOT_FOUND(3041, "任务项不存在"),
    TASK_ALREADY_DONE(3042, "任务已完成，不能重复打卡"),
    TASK_STATUS_ILLEGAL(3043, "任务状态不允许该操作"),
    FILE_NOT_FOUND(3044, "文件不存在"),
    FILE_EMPTY(3045, "上传文件为空"),
    FILE_TYPE_NOT_ALLOWED(3046, "不支持的文件类型"),
    FILE_TOO_LARGE(3047, "文件大小超出限制"),
    MESSAGE_EMPTY(3048, "留言内容不能为空"),

    /* ---------------- 3xxx 双向互评（M6） ---------------- */
    EVALUATION_NOT_ALLOWED_STATUS(3050, "当前交换状态不可评价"),
    EVALUATION_DIMENSION_MISSING(3051, "评价维度不完整"),
    EVALUATION_SCORE_OUT_OF_RANGE(3052, "评价分数超出取值范围"),
    EVALUATION_CANNOT_SELF(3053, "不能评价自己"),
    EVALUATION_NOT_FOUND(3054, "评价记录不存在"),
    EVALUATION_INTEGRITY_BROKEN(3055, "该评价记录校验不通过，内容已被改动"),
    EVALUATION_CERT_INVALID(3056, "校验码无效或记录不存在"),
    EVALUATION_COMMENT_REQUIRED(3057, "低分评价必须填写具体说明"),
    COLLUSION_SUSPECTED(3058, "该交换被判定为疑似互刷，评价已转人工复核"),
    AMENDMENT_NOT_FOUND(3059, "修正记录不存在"),

    /* ---------------- 3xxx 数字档案与能力画像（M7） ---------------- */
    PROFILE_NOT_ENOUGH_DATA(3060, "协作数据不足，暂无法生成能力画像"),
    PROFILE_SNAPSHOT_NOT_FOUND(3061, "能力画像快照不存在"),
    BADGE_NOT_FOUND(3062, "勋章不存在"),
    BADGE_ALREADY_OWNED(3063, "已拥有该勋章"),
    GROWTH_REPORT_NOT_FOUND(3064, "成长周报不存在"),
    REPORT_EXPORT_FAILED(3065, "报告导出失败"),
    PROFILE_DIMENSION_MAPPING_MISSING(3066, "技能未映射到能力维度"),

    /* ---------------- 4xxx 外部依赖 ---------------- */
    AI_SERVICE_UNAVAILABLE(4001, "语义解析服务暂不可用，已降级为标签匹配"),
    VECTOR_STORE_ERROR(4002, "向量库访问异常"),
    CACHE_ERROR(4003, "缓存访问异常"),
    FILE_UPLOAD_ERROR(4004, "文件上传失败"),

    /* ---------------- 5xxx 系统 ---------------- */
    SYSTEM_ERROR(5000, "系统内部错误，请稍后重试"),
    DATABASE_ERROR(5001, "数据库操作异常"),
    NOT_FOUND(5002, "请求的资源不存在");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
