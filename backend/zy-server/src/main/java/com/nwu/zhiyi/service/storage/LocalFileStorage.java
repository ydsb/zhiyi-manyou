package com.nwu.zhiyi.service.storage;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.common.util.HashUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * 本地磁盘文件存储实现。
 *
 * <p>开发与小规模试点阶段的默认实现（对应 FR-M9-06 的"本地存储"选项）。
 * 文件按 {@code yyyy/MM/dd} 分目录，文件名用随机 UUID 重命名以避免：
 * <ul>
 *   <li>原始文件名冲突；</li>
 *   <li>用户上传的文件名携带路径穿越字符（{@code ../}）导致越权写入；</li>
 *   <li>中文文件名在不同操作系统上的编码问题。</li>
 * </ul>
 * 原始文件名单独存在数据库里，下载时通过 Content-Disposition 还原。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
public class LocalFileStorage implements FileStorage {

    private static final DateTimeFormatter DATE_DIR = DateTimeFormatter.ofPattern("yyyy/MM/dd");

    /** 允许的扩展名白名单（协作交付物场景：文档、表格、演示、图片、压缩包、代码文本） */
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(
            "doc", "docx", "xls", "xlsx", "ppt", "pptx", "pdf", "txt", "md", "csv",
            "png", "jpg", "jpeg", "gif", "webp", "svg",
            "zip", "rar", "7z",
            "java", "py", "js", "ts", "vue", "sql", "json", "xml", "html", "css", "ipynb"
    );

    private final Path root;

    public LocalFileStorage(@Value("${zhiyi.storage.local-root:G:/DEV/zhiyi-uploads}") String rootDir) {
        this.root = Paths.get(rootDir).toAbsolutePath().normalize();
        try {
            Files.createDirectories(this.root);
            log.info("[文件存储] 本地存储根目录：{}", this.root);
        } catch (IOException e) {
            throw new IllegalStateException("无法创建文件存储目录：" + this.root, e);
        }
    }

    @Override
    public String storageType() {
        return "LOCAL";
    }

    @Override
    public StoredFile store(InputStream in, String originalName, String contentType, long size) {
        validate(originalName, size);

        String extension = extensionOf(originalName);
        String relative = LocalDate.now().format(DATE_DIR) + "/"
                + UUID.randomUUID().toString().replace("-", "")
                + (extension.isEmpty() ? "" : "." + extension);
        Path target = root.resolve(relative).normalize();

        // 防御路径穿越：确保最终路径仍在根目录内
        if (!target.startsWith(root)) {
            throw new BusinessException(ErrorCode.FILE_UPLOAD_ERROR, "非法的文件路径");
        }

        try {
            Files.createDirectories(target.getParent());
            String sha256 = copyAndDigest(in, target);
            long actual = Files.size(target);
            log.info("[文件存储] 已保存 {} （{} 字节，sha256={}）",
                    relative, actual, sha256.substring(0, 12) + "...");
            return new StoredFile(relative, actual, sha256);
        } catch (IOException e) {
            log.error("[文件存储] 保存失败：{}", originalName, e);
            throw new BusinessException(ErrorCode.FILE_UPLOAD_ERROR, "文件保存失败：" + e.getMessage());
        }
    }

    @Override
    public InputStream retrieve(String storagePath) {
        Path target = resolveSafely(storagePath);
        if (!Files.exists(target)) {
            throw new BusinessException(ErrorCode.FILE_NOT_FOUND);
        }
        try {
            return Files.newInputStream(target);
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.FILE_NOT_FOUND, "文件读取失败：" + e.getMessage());
        }
    }

    @Override
    public boolean delete(String storagePath) {
        Path target = resolveSafely(storagePath);
        try {
            return Files.deleteIfExists(target);
        } catch (IOException e) {
            log.warn("[文件存储] 删除失败：{} - {}", storagePath, e.getMessage());
            return false;
        }
    }

    @Override
    public void validate(String originalName, long size) {
        if (size <= 0) {
            throw new BusinessException(ErrorCode.FILE_EMPTY);
        }
        String extension = extensionOf(originalName);
        if (extension.isEmpty() || !ALLOWED_EXTENSIONS.contains(extension)) {
            throw new BusinessException(ErrorCode.FILE_TYPE_NOT_ALLOWED,
                    "不支持的文件类型：" + (extension.isEmpty() ? "无扩展名" : "." + extension)
                            + "，允许的类型：" + String.join(" / ", ALLOWED_EXTENSIONS));
        }
    }

    /**
     * 规范化并校验路径，拒绝越出根目录的请求。
     */
    private Path resolveSafely(String storagePath) {
        if (storagePath == null || storagePath.isBlank()) {
            throw new BusinessException(ErrorCode.FILE_NOT_FOUND);
        }
        Path target = root.resolve(storagePath).normalize();
        if (!target.startsWith(root)) {
            log.warn("[文件存储] 检测到越权路径访问尝试：{}", storagePath);
            throw new BusinessException(ErrorCode.FORBIDDEN, "非法的文件路径");
        }
        return target;
    }

    /**
     * 边写盘边计算 SHA-256，避免二次读取整个文件。
     */
    private String copyAndDigest(InputStream in, Path target) throws IOException {
        MessageDigest digest;
        try {
            digest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("当前 JDK 不支持 SHA-256", e);
        }
        try (DigestInputStream dis = new DigestInputStream(in, digest)) {
            Files.copy(dis, target, StandardCopyOption.REPLACE_EXISTING);
        }
        return toHex(digest.digest());
    }

    private static String extensionOf(String fileName) {
        if (fileName == null) {
            return "";
        }
        // 去掉可能的路径部分，只取文件名
        String name = fileName.replace('\\', '/');
        int slash = name.lastIndexOf('/');
        if (slash >= 0) {
            name = name.substring(slash + 1);
        }
        int dot = name.lastIndexOf('.');
        if (dot < 0 || dot == name.length() - 1) {
            return "";
        }
        return name.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    private static String toHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(Character.forDigit((b >> 4) & 0xF, 16));
            sb.append(Character.forDigit(b & 0xF, 16));
        }
        return sb.toString();
    }

    /** 暴露根目录，供下载接口与运维排查使用 */
    public Path getRoot() {
        return root;
    }

    /** 内容摘要工具（供调用方复用同一套实现） */
    public static String sha256Of(String raw) {
        return HashUtils.sha256Hex(raw);
    }
}
