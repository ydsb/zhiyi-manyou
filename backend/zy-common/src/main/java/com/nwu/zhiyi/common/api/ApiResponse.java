package com.nwu.zhiyi.common.api;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 统一响应体。
 *
 * <p>约定：{@code code=0} 表示成功，非 0 表示失败（见 {@link ErrorCode}）。
 *
 * @param <T> 业务数据类型
 * @author 李泽宬
 */
@Data
public class ApiResponse<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 业务状态码，0 为成功 */
    private int code;

    /** 提示信息 */
    private String message;

    /** 业务数据 */
    private T data;

    /** 链路追踪 ID，便于日志排查 */
    private String traceId;

    /** 服务器时间 */
    private LocalDateTime timestamp;

    private ApiResponse() {
        this.timestamp = LocalDateTime.now();
    }

    public static <T> ApiResponse<T> success() {
        return success(null);
    }

    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(ErrorCode.SUCCESS.getCode());
        response.setMessage(ErrorCode.SUCCESS.getMessage());
        response.setData(data);
        return response;
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        ApiResponse<T> response = success(data);
        response.setMessage(message);
        return response;
    }

    public static <T> ApiResponse<T> error(ErrorCode errorCode) {
        return error(errorCode, errorCode.getMessage());
    }

    public static <T> ApiResponse<T> error(ErrorCode errorCode, String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(errorCode.getCode());
        response.setMessage(message);
        return response;
    }

    public static <T> ApiResponse<T> error(int code, String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(code);
        response.setMessage(message);
        return response;
    }

    /** 判断是否成功（不参与 JSON 序列化，供服务端内部使用） */
    @JsonIgnore
    public boolean isSuccess() {
        return this.code == ErrorCode.SUCCESS.getCode();
    }
}
