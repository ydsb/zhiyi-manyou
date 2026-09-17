package com.nwu.zhiyi.config;

import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalTimeSerializer;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Jackson 时序配置。
 *
 * <p>说明：{@code spring.jackson.date-format} 只作用于 {@code java.util.Date}，
 * 对 Java 8 时间类型无效。此处通过 builder 的 serializerByType / deserializerByType
 * 覆盖默认的 JSR-310 序列化器，统一为 {@code yyyy-MM-dd HH:mm:ss}。
 *
 * <p>重要：全局 {@link com.fasterxml.jackson.databind.ObjectMapper} 由 Spring Boot 管理，
 * 过滤器与安全处理器（如 Spring Security 的 401 响应）必须<b>注入</b>该实例，
 * 而不是 {@code new ObjectMapper()}，否则会因缺少 JSR-310 模块而序列化失败。
 *
 * @author 李泽宬
 */
@Configuration
public class JacksonConfig {

    public static final String DATE_TIME_PATTERN = "yyyy-MM-dd HH:mm:ss";
    public static final String DATE_PATTERN = "yyyy-MM-dd";
    public static final String TIME_PATTERN = "HH:mm:ss";

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer javaTimeCustomizer() {
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern(DATE_TIME_PATTERN);
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern(DATE_PATTERN);
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern(TIME_PATTERN);

        return builder -> {
            // 覆盖 Spring Boot 默认注册的 ISO-8601 序列化器
            builder.serializerByType(LocalDateTime.class, new LocalDateTimeSerializer(dateTimeFormatter));
            builder.serializerByType(LocalDate.class, new LocalDateSerializer(dateFormatter));
            builder.serializerByType(LocalTime.class, new LocalTimeSerializer(timeFormatter));
            builder.deserializerByType(LocalDateTime.class, new LocalDateTimeDeserializer(dateTimeFormatter));
            builder.deserializerByType(LocalDate.class, new LocalDateDeserializer(dateFormatter));
            builder.deserializerByType(LocalTime.class, new LocalTimeDeserializer(timeFormatter));
        };
    }
}
