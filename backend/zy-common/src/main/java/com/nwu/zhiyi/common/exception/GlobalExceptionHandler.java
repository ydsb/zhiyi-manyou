package com.nwu.zhiyi.common.exception;

import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.web.TraceIdFilter;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.NoHandlerFoundException;

import java.util.stream.Collectors;

/**
 * 全局异常处理器：把各类异常统一转换为 {@link ApiResponse}。
 *
 * <p><b>状态码约定（重要）</b>：所有 <b>/api</b> 接口的业务与参数类错误一律返回
 * <b>HTTP 200</b>，真实语义放在响应体的 {@code code} 字段中。原因：
 * 返回非 200 时 Servlet 容器会转发到 {@code /error}，而本项目未注册错误页
 * （{@code spring.web.resources.add-mappings=false}），会导致响应体丢失。
 * 前端只需判断 {@code code != 0} 即视为失败。
 *
 * <p>认证与权限失败由 Spring Security 的
 * {@code RestAuthenticationEntryPoint} / {@code RestAccessDeniedHandler}
 * 处理，保持标准 HTTP 401 / 403（此时响应体由安全过滤器直接写出，不经过容器错误页）。
 *
 * <p>未知异常仍返回 HTTP 500，避免把系统故障伪装成业务失败。
 *
 * @author 李泽宬
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /* ==================== 业务异常 ==================== */

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusinessException(BusinessException ex) {
        ErrorCode errorCode = ex.getErrorCode();
        log.warn("[业务异常] code={} message={}", errorCode.getCode(), ex.getMessage());
        return ok(ApiResponse.error(errorCode, ex.getMessage()));
    }

    /* ==================== 参数校验 ==================== */

    /** @Valid 校验失败（RequestBody） */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleMethodArgumentNotValid(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .map(GlobalExceptionHandler::formatFieldError)
                .collect(Collectors.joining("；"));
        log.warn("[参数校验失败] {}", message);
        return ok(ApiResponse.error(ErrorCode.PARAM_INVALID, message));
    }

    /** 表单/查询参数绑定失败 */
    @ExceptionHandler(BindException.class)
    public ResponseEntity<ApiResponse<Void>> handleBindException(BindException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .map(GlobalExceptionHandler::formatFieldError)
                .collect(Collectors.joining("；"));
        log.warn("[参数绑定失败] {}", message);
        return ok(ApiResponse.error(ErrorCode.PARAM_INVALID, message));
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ApiResponse<Void>> handleMissingParam(MissingServletRequestParameterException ex) {
        String message = "缺少必要参数：" + ex.getParameterName();
        log.warn("[缺少参数] {}", message);
        return ok(ApiResponse.error(ErrorCode.PARAM_MISSING, message));
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiResponse<Void>> handleTypeMismatch(MethodArgumentTypeMismatchException ex) {
        String message = String.format("参数 %s 类型不正确，期望类型：%s", ex.getName(),
                ex.getRequiredType() == null ? "unknown" : ex.getRequiredType().getSimpleName());
        log.warn("[参数类型错误] {}", message);
        return ok(ApiResponse.error(ErrorCode.PARAM_FORMAT_ERROR, message));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResponse<Void>> handleNotReadable(HttpMessageNotReadableException ex) {
        log.warn("[请求体解析失败] {}", ex.getMessage());
        return ok(ApiResponse.error(ErrorCode.REQUEST_BODY_MISSING, "请求体缺失或格式不正确"));
    }

    /* ==================== 路由与请求方法 ==================== */

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiResponse<Void>> handleMethodNotSupported(HttpRequestMethodNotSupportedException ex) {
        String message = "不支持的请求方法：" + ex.getMethod();
        log.warn("[请求方法不支持] {}", message);
        return ok(ApiResponse.error(ErrorCode.REQUEST_METHOD_NOT_SUPPORTED, message));
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleNoHandlerFound(NoHandlerFoundException ex) {
        String message = "接口不存在：" + ex.getHttpMethod() + " " + ex.getRequestURL();
        log.warn("[接口不存在] {}", message);
        return ok(ApiResponse.error(ErrorCode.NOT_FOUND, message));
    }

    /* ==================== 兜底 ==================== */

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(IllegalArgumentException ex) {
        log.warn("[非法参数] {}", ex.getMessage());
        String message = ex.getMessage() == null ? ErrorCode.PARAM_INVALID.getMessage() : ex.getMessage();
        return ok(ApiResponse.error(ErrorCode.PARAM_INVALID, message));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception ex) {
        log.error("[系统异常] {}", ex.getMessage(), ex);
        return ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR)
                .body(withTrace(ApiResponse.error(ErrorCode.SYSTEM_ERROR)));
    }

    /* ==================== 私有工具 ==================== */

    private static String formatFieldError(FieldError fieldError) {
        return fieldError.getField() + " " + fieldError.getDefaultMessage();
    }

    /**
     * 统一以 HTTP 200 返回错误体，避免容器转发到 /error 导致响应体丢失。
     */
    private static ResponseEntity<ApiResponse<Void>> ok(ApiResponse<Void> body) {
        return ResponseEntity.ok(withTrace(body));
    }

    private static ApiResponse<Void> withTrace(ApiResponse<Void> response) {
        response.setTraceId(MDC.get(TraceIdFilter.TRACE_ID));
        return response;
    }
}
