package com.nwu.zhiyi.service.storage;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.UUID;

/** S3-compatible storage adapter for AWS S3, MinIO and compatible OSS gateways. */
@Slf4j
@Component
@ConditionalOnProperty(prefix = "zhiyi.storage", name = "type", havingValue = "S3")
public class S3FileStorage implements FileStorage, AutoCloseable {
    private static final DateTimeFormatter DATE_DIR = DateTimeFormatter.ofPattern("yyyy/MM/dd");
    private final S3Client client;
    private final String bucket;

    public S3FileStorage(
            @Value("${zhiyi.storage.s3.endpoint:}") String endpoint,
            @Value("${zhiyi.storage.s3.region:us-east-1}") String region,
            @Value("${zhiyi.storage.s3.bucket:zhiyi-manyou}") String bucket,
            @Value("${zhiyi.storage.s3.access-key:}") String accessKey,
            @Value("${zhiyi.storage.s3.secret-key:}") String secretKey,
            @Value("${zhiyi.storage.s3.path-style:true}") boolean pathStyle) {
        this(createClient(endpoint, region, accessKey, secretKey, pathStyle), bucket);
        log.info("[文件存储] S3 兼容对象存储已启用 bucket={} endpoint={}", bucket,
                endpoint == null || endpoint.isBlank() ? "AWS default" : endpoint);
    }

    S3FileStorage(S3Client client, String bucket) {
        this.client = java.util.Objects.requireNonNull(client, "client");
        this.bucket = requireText(bucket, "zhiyi.storage.s3.bucket");
    }

    private static S3Client createClient(String endpoint, String region, String accessKey,
                                         String secretKey, boolean pathStyle) {
        var builder = S3Client.builder().region(Region.of(region));
        if (endpoint != null && !endpoint.isBlank()) {
            builder.endpointOverride(java.net.URI.create(endpoint));
        }
        if (!accessKey.isBlank() && !secretKey.isBlank()) {
            builder.credentialsProvider(StaticCredentialsProvider.create(
                    AwsBasicCredentials.create(accessKey, secretKey)));
        } else {
            builder.credentialsProvider(DefaultCredentialsProvider.create());
        }
        builder.serviceConfiguration(software.amazon.awssdk.services.s3.S3Configuration.builder()
                .pathStyleAccessEnabled(pathStyle).build());
        return builder.build();
    }

    @Override public String storageType() { return "S3"; }

    @Override
    public void close() {
        client.close();
    }

    @Override
    public StoredFile store(InputStream in, String originalName, String contentType, long size) {
        validate(originalName, size);
        String key = LocalDate.now().format(DATE_DIR) + "/" + UUID.randomUUID().toString().replace("-", "")
                + extensionOf(originalName);
        Path temp = null;
        try {
            temp = Files.createTempFile("zhiyi-upload-", ".tmp");
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            long actual;
            try (DigestInputStream dis = new DigestInputStream(in, digest)) {
                Files.copy(dis, temp, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                actual = Files.size(temp);
            }
            if (actual != size) log.debug("[文件存储] 上传声明大小 {} 与实际大小 {} 不同", size, actual);
            PutObjectRequest request = PutObjectRequest.builder().bucket(bucket).key(key)
                    .contentType(contentType == null || contentType.isBlank() ? "application/octet-stream" : contentType)
                    .contentLength(actual).build();
            client.putObject(request, RequestBody.fromFile(temp));
            return new StoredFile(key, actual, hex(digest.digest()));
        } catch (Exception e) {
            log.error("[文件存储] S3 上传失败 key={}", key, e);
            throw new BusinessException(ErrorCode.FILE_UPLOAD_ERROR, "对象存储上传失败：" + e.getMessage());
        } finally {
            if (temp != null) try { Files.deleteIfExists(temp); } catch (IOException ignored) { }
        }
    }

    @Override
    public InputStream retrieve(String storagePath) {
        String key = requirePath(storagePath);
        try {
            ResponseInputStream<?> stream = client.getObject(GetObjectRequest.builder().bucket(bucket).key(key).build());
            return stream;
        } catch (NoSuchKeyException e) {
            throw new BusinessException(ErrorCode.FILE_NOT_FOUND);
        } catch (S3Exception e) {
            if (e.statusCode() == 404) throw new BusinessException(ErrorCode.FILE_NOT_FOUND);
            log.error("[文件存储] S3 读取失败 key={} status={}", storagePath, e.statusCode(), e);
            throw new BusinessException(ErrorCode.FILE_STORAGE_ERROR, "对象存储读取失败");
        } catch (Exception e) {
            log.error("[文件存储] S3 读取失败 key={}", storagePath, e);
            throw new BusinessException(ErrorCode.FILE_STORAGE_ERROR, "对象存储读取失败");
        }
    }

    @Override
    public boolean delete(String storagePath) {
        String key = requirePath(storagePath);
        try {
            client.deleteObject(DeleteObjectRequest.builder().bucket(bucket).key(key).build());
            return true;
        } catch (Exception e) {
            log.warn("[文件存储] S3 删除失败 key={} - {}", storagePath, e.getMessage());
            return false;
        }
    }

    @Override public void validate(String originalName, long size) {
        LocalFileStorage.validateFile(originalName, size);
    }

    private static String requireText(String value, String name) {
        if (value == null || value.isBlank()) throw new IllegalStateException(name + " must be configured when S3 storage is enabled");
        return value.trim();
    }
    private static String requirePath(String path) {
        if (path == null || path.isBlank() || path.startsWith("/") || path.contains("..")) throw new BusinessException(ErrorCode.FILE_NOT_FOUND);
        return path;
    }
    private static String extensionOf(String name) {
        if (name == null) return "";
        String n = name.replace('\\', '/');
        int slash = n.lastIndexOf('/'); if (slash >= 0) n = n.substring(slash + 1);
        int dot = n.lastIndexOf('.'); return dot < 0 || dot == n.length() - 1 ? "" : n.substring(dot).toLowerCase(Locale.ROOT);
    }
    private static String hex(byte[] bytes) {
        StringBuilder out = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) out.append(String.format("%02x", b));
        return out.toString();
    }
}
