package com.nwu.zhiyi.api.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nwu.zhiyi.common.api.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Stateless MCP JSON-RPC endpoint exposing the platform's existing tool catalog. */
@RestController
@RequestMapping("/mcp")
@RequiredArgsConstructor
public class McpController {
    private static final String PROTOCOL_VERSION = "2025-03-26";
    private final ToolApiController tools;
    private final ObjectMapper objectMapper;

    @PostMapping
    public ResponseEntity<Object> handle(@RequestBody Map<String, Object> request) {
        Object id = request.get("id");
        if (id == null) return ResponseEntity.accepted().build(); // JSON-RPC notification
        Object methodValue = request.get("method");
        if (!(methodValue instanceof String method)) return jsonRpcError(id, -32600, "Invalid Request");
        @SuppressWarnings("unchecked")
        Map<String, Object> params = request.get("params") instanceof Map<?, ?> p
                ? (Map<String, Object>) p : Map.of();
        try {
            Object result = switch (method) {
                case "initialize" -> initialize(params);
                case "ping" -> Map.of();
                case "tools/list" -> tools.listTools().getData().get("tools");
                case "tools/call" -> callTool(params);
                default -> throw new UnknownMethodException();
            };
            return ResponseEntity.ok(Map.of("jsonrpc", "2.0", "id", id, "result", result));
        } catch (UnknownMethodException e) {
            return jsonRpcError(id, -32601, "Method not found");
        } catch (IllegalArgumentException e) {
            return jsonRpcError(id, -32602, e.getMessage());
        } catch (RuntimeException e) {
            return jsonRpcError(id, -32000, "Tool execution failed");
        }
    }

    private Map<String, Object> initialize(Map<String, Object> params) {
        Object requested = params.get("protocolVersion");
        String version = requested instanceof String s ? s : PROTOCOL_VERSION;
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("protocolVersion", version);
        result.put("capabilities", Map.of("tools", Map.of("listChanged", false)));
        result.put("serverInfo", Map.of("name", "zhiyi-manyou", "version", "1.0.0"));
        result.put("instructions", "知驿漫游校园技能交换与学习记录工具服务");
        return result;
    }

    private Map<String, Object> callTool(Map<String, Object> params) {
        Object name = params.get("name");
        if (!(name instanceof String toolName) || toolName.isBlank()) {
            throw new IllegalArgumentException("tools/call requires a tool name");
        }
        Object arguments = params.get("arguments");
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("name", toolName);
        body.put("arguments", arguments instanceof Map<?, ?> ? arguments : Map.of());
        ApiResponse<Map<String, Object>> response = tools.call(body);
        if (!response.isSuccess()) throw new IllegalArgumentException(response.getMessage());
        Map<String, Object> structured = response.getData();
        String text;
        try {
            text = objectMapper.writeValueAsString(structured);
        } catch (JsonProcessingException e) {
            text = String.valueOf(structured);
        }
        return Map.of("content", List.of(Map.of("type", "text", "text", text)),
                "structuredContent", structured, "isError", false);
    }

    private ResponseEntity<Object> jsonRpcError(Object id, int code, String message) {
        return ResponseEntity.ok(Map.of("jsonrpc", "2.0", "id", id,
                "error", Map.of("code", code, "message", message == null ? "Request failed" : message)));
    }

    private static final class UnknownMethodException extends RuntimeException { }
}
