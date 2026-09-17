package com.nwu.zhiyi.service.storage;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 本地文件存储测试（FR-M5-03）。
 *
 * <p>重点覆盖<b>安全校验</b>：协作空间允许上传文件，是全平台唯一的用户输入落盘点，
 * 一旦文件名校验或路径处理出错就是任意文件写入漏洞。
 *
 * @author 李泽宬
 */
@DisplayName("M5 - 本地文件存储与安全校验")
class LocalFileStorageTest {

    @TempDir
    Path tempDir;

    private LocalFileStorage storage;

    @BeforeEach
    void setUp() {
        storage = new LocalFileStorage(tempDir.toString());
    }

    private InputStream content(String text) {
        return new ByteArrayInputStream(text.getBytes(StandardCharsets.UTF_8));
    }

    @Test
    @DisplayName("正常上传应落盘、返回相对路径与 SHA-256 摘要")
    void shouldStoreFileAndComputeDigest() throws IOException {
        String body = "协作交付物内容";
        FileStorage.StoredFile stored = storage.store(content(body), "设计稿说明.md", "text/markdown",
                body.getBytes(StandardCharsets.UTF_8).length);

        assertEquals("LOCAL", storage.storageType());
        assertTrue(stored.sizeBytes() > 0);
        assertEquals(64, stored.sha256().length(), "SHA-256 应为 64 位十六进制");
        assertTrue(Files.exists(tempDir.resolve(stored.storagePath())), "文件应真实落盘");

        // 摘要应与内容一致（同一内容得到同一 sha256）
        FileStorage.StoredFile again = storage.store(content(body), "另一个名字.md", "text/markdown",
                body.getBytes(StandardCharsets.UTF_8).length);
        assertEquals(stored.sha256(), again.sha256(), "相同内容应得到相同摘要（可用于去重）");
    }

    @Test
    @DisplayName("文件应重命名存储，避免原始文件名冲突与中文编码问题")
    void shouldRenameStoredFile() {
        String body = "x";
        FileStorage.StoredFile a = storage.store(content(body), "同名文件.txt", "text/plain", 1);
        FileStorage.StoredFile b = storage.store(content(body), "同名文件.txt", "text/plain", 1);

        assertNotEquals(a.storagePath(), b.storagePath(), "同名文件应得到不同存储路径");
        assertFalse(a.storagePath().contains("同名文件"), "存储路径不应包含原始文件名");
        assertTrue(a.storagePath().endsWith(".txt"), "应保留扩展名");
    }

    @Test
    @DisplayName("安全：携带路径穿越的文件名不应写到根目录之外")
    void shouldRejectPathTraversalInFileName() {
        // 文件名里的 ../ 会被剥离（只取最后一段），并在 store 内重命名为 UUID
        FileStorage.StoredFile stored = storage.store(content("evil"), "../../evil.txt", "text/plain", 4);
        Path actual = tempDir.resolve(stored.storagePath()).normalize();
        assertTrue(actual.startsWith(tempDir), "落盘路径必须仍在存储根目录内：" + actual);
    }

    @Test
    @DisplayName("安全：读取时拒绝越界路径（存储路径被篡改的场景）")
    void shouldRejectPathTraversalOnRetrieve() {
        BusinessException ex = assertThrows(BusinessException.class,
                () -> storage.retrieve("../../../../Windows/System32/drivers/etc/hosts"));
        assertEquals(ErrorCode.FORBIDDEN.getCode(), ex.getErrorCode().getCode(),
                "越界路径应判为禁止访问，实际：" + ex.getMessage());
    }

    @Test
    @DisplayName("安全：删除时同样拒绝越界路径")
    void shouldRejectPathTraversalOnDelete() {
        BusinessException ex = assertThrows(BusinessException.class,
                () -> storage.delete("../../../重要文件.txt"));
        assertEquals(ErrorCode.FORBIDDEN.getCode(), ex.getErrorCode().getCode());
    }

    @Test
    @DisplayName("扩展名白名单：不支持的格式应被拒绝")
    void shouldRejectDisallowedExtension() {
        // 可执行文件与脚本是最典型的风险类型
        for (String bad : new String[]{"virus.exe", "run.bat", "shell.sh", "lib.dll", "payload.jsp"}) {
            BusinessException ex = assertThrows(BusinessException.class,
                    () -> storage.validate(bad, 100), "应拒绝：" + bad);
            assertEquals(ErrorCode.FILE_TYPE_NOT_ALLOWED.getCode(), ex.getErrorCode().getCode());
        }
    }

    @Test
    @DisplayName("扩展名白名单：无扩展名应被拒绝")
    void shouldRejectFileWithoutExtension() {
        BusinessException ex = assertThrows(BusinessException.class,
                () -> storage.validate("README", 100));
        assertEquals(ErrorCode.FILE_TYPE_NOT_ALLOWED.getCode(), ex.getErrorCode().getCode());
    }

    @Test
    @DisplayName("扩展名白名单：协作场景常用格式应被接受（大写也接受）")
    void shouldAcceptCollaborationFileTypes() {
        for (String good : new String[]{"报告.docx", "数据.xlsx", "答辩.pptx", "说明.pdf",
                "截图.png", "素材.zip", "代码.py", "页面.vue", "脚本.sql", "图表.SVG"}) {
            storage.validate(good, 1024);
        }
    }

    @Test
    @DisplayName("空文件应被拒绝")
    void shouldRejectEmptyFile() {
        BusinessException ex = assertThrows(BusinessException.class,
                () -> storage.validate("空文件.txt", 0));
        assertEquals(ErrorCode.FILE_EMPTY.getCode(), ex.getErrorCode().getCode());
    }

    @Test
    @DisplayName("读取已存在的文件应返回原始内容")
    void shouldRetrieveStoredContent() throws IOException {
        String body = "内容往返测试";
        FileStorage.StoredFile stored = storage.store(content(body), "test.txt", "text/plain",
                body.getBytes(StandardCharsets.UTF_8).length);

        try (InputStream in = storage.retrieve(stored.storagePath())) {
            String read = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            assertEquals(body, read);
        }
    }

    @Test
    @DisplayName("读取不存在的文件应抛出文件不存在")
    void shouldThrowWhenFileMissing() {
        BusinessException ex = assertThrows(BusinessException.class,
                () -> storage.retrieve("2026/01/01/notexists.txt"));
        assertEquals(ErrorCode.FILE_NOT_FOUND.getCode(), ex.getErrorCode().getCode());
    }

    @Test
    @DisplayName("删除应为幂等：文件不存在时返回 false 而不抛异常")
    void shouldBeIdempotentOnDelete() {
        FileStorage.StoredFile stored = storage.store(content("待删除"), "del.txt", "text/plain", 9);
        assertTrue(storage.delete(stored.storagePath()), "首次删除应成功");
        assertFalse(storage.delete(stored.storagePath()), "重复删除应返回 false 而不是抛异常");
    }

    @Test
    @DisplayName("存储路径应包含日期分目录，避免单目录文件过多")
    void shouldUseDateDirectories() {
        FileStorage.StoredFile stored = storage.store(content("x"), "date.txt", "text/plain", 1);
        // yyyy/MM/dd/uuid.ext
        assertTrue(stored.storagePath().matches("\\d{4}/\\d{2}/\\d{2}/[0-9a-f]{32}\\.txt"),
                "路径格式应为 yyyy/MM/dd/uuid.ext，实际：" + stored.storagePath());
    }
}
