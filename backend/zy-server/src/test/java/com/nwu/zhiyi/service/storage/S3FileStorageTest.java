package com.nwu.zhiyi.service.storage;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.http.AbortableInputStream;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@DisplayName("S3 兼容对象存储")
class S3FileStorageTest {
    private final S3Client client = mock(S3Client.class);
    private final S3FileStorage storage = new S3FileStorage(client, "test-bucket");

    @AfterEach
    void closeClient() { storage.close(); }

    @Test
    @DisplayName("上传应写入对象、保留白名单扩展名并计算内容摘要")
    void shouldUploadAndComputeDigest() throws IOException {
        String body = "对象存储内容";
        byte[][] uploaded = new byte[1][];
        when(client.putObject(any(PutObjectRequest.class), any(RequestBody.class))).thenAnswer(invocation -> {
            PutObjectRequest request = invocation.getArgument(0);
            assertEquals("test-bucket", request.bucket());
            assertTrue(request.key().matches("\\d{4}/\\d{2}/\\d{2}/[0-9a-f]{32}\\.pdf"));
            assertEquals("application/pdf", request.contentType());
            uploaded[0] = invocation.getArgument(1, RequestBody.class)
                    .contentStreamProvider().newStream().readAllBytes();
            return null;
        });
        var result = storage.store(new ByteArrayInputStream(body.getBytes(StandardCharsets.UTF_8)),
                "报告.PDF", "application/pdf", body.getBytes(StandardCharsets.UTF_8).length);

        assertEquals("S3", storage.storageType());
        assertEquals(body.getBytes(StandardCharsets.UTF_8).length, result.sizeBytes());
        assertEquals(64, result.sha256().length());
        assertArrayEquals(body.getBytes(StandardCharsets.UTF_8), uploaded[0]);
        verify(client).putObject(any(PutObjectRequest.class), any(RequestBody.class));
    }

    @Test
    @DisplayName("读取与删除应只操作通过校验的对象键")
    void shouldRetrieveAndDeleteObject() throws IOException {
        String key = "2026/10/12/object.txt";
        when(client.getObject(any(GetObjectRequest.class))).thenReturn(new ResponseInputStream<>(
                GetObjectResponse.builder().build(), AbortableInputStream.create(new ByteArrayInputStream("ok".getBytes(StandardCharsets.UTF_8)))));
        try (var input = storage.retrieve(key)) {
            assertEquals("ok", new String(input.readAllBytes(), StandardCharsets.UTF_8));
        }
        assertTrue(storage.delete(key));
        verify(client).getObject(argThat((GetObjectRequest request) -> request.bucket().equals("test-bucket") && request.key().equals(key)));
        verify(client).deleteObject(argThat((DeleteObjectRequest request) -> request.bucket().equals("test-bucket") && request.key().equals(key)));
    }

    @Test
    @DisplayName("读取与删除拒绝空键和路径穿越键")
    void shouldRejectUnsafeKeys() {
        for (String key : new String[]{null, "", "/absolute.txt", "../secret.txt", "folder/../secret.txt"}) {
            assertThrows(BusinessException.class, () -> storage.retrieve(key));
            assertThrows(BusinessException.class, () -> storage.delete(key));
        }
        verifyNoInteractions(client);
    }

    @Test
    @DisplayName("对象存储与本地存储共用扩展名及空文件校验")
    void shouldShareValidationRules() {
        BusinessException unsupported = assertThrows(BusinessException.class, () -> storage.validate("run.exe", 10));
        assertEquals(ErrorCode.FILE_TYPE_NOT_ALLOWED.getCode(), unsupported.getErrorCode().getCode());
        BusinessException empty = assertThrows(BusinessException.class, () -> storage.validate("empty.txt", 0));
        assertEquals(ErrorCode.FILE_EMPTY.getCode(), empty.getErrorCode().getCode());
    }
}
