package com.nwu.zhiyi.api.dto.collab;

import com.nwu.zhiyi.domain.entity.CollabFile;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作文件视图对象（FR-M5-03）。
 *
 * <p>刻意不暴露 {@code storagePath}：真实存储路径属于内部实现，
 * 对外只给 {@code downloadUrl}，避免绕过权限校验直连文件。
 *
 * @author 李泽宬
 */
@Data
public class CollabFileVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long recordId;

    /** 逻辑文件标识：同一文件的所有版本共享此值 */
    private String groupKey;

    private Integer version;

    /** 该逻辑文件当前的最大版本号，用于前端显示 v2 / v3 */
    private Integer latestVersion;

    private Boolean latest;

    private String fileName;
    private String contentType;
    private Long sizeBytes;

    /** 人类可读大小，如 1.2 MB */
    private String sizeText;

    private String sha256;
    private Long taskId;
    private String taskTitle;

    private String uploaderSno;
    private String uploaderName;

    /** 版本说明 */
    private String remark;

    private LocalDateTime createdAt;

    /** 下载地址（带权限校验的接口，非直连存储） */
    private String downloadUrl;

    /** 该逻辑文件的全部历史版本数 */
    private Integer versionCount;

    public static CollabFileVO of(CollabFile file) {
        if (file == null) {
            return null;
        }
        CollabFileVO vo = new CollabFileVO();
        vo.setId(file.getId());
        vo.setRecordId(file.getRecordId());
        vo.setGroupKey(file.getGroupKey());
        vo.setVersion(file.getVersion());
        vo.setLatest(file.isLatestVersion());
        vo.setFileName(file.getFileName());
        vo.setContentType(file.getContentType());
        vo.setSizeBytes(file.getSizeBytes());
        vo.setSizeText(humanSize(file.getSizeBytes()));
        vo.setSha256(file.getSha256());
        vo.setTaskId(file.getTaskId());
        vo.setUploaderSno(file.getUploaderSno());
        vo.setRemark(file.getRemark());
        vo.setCreatedAt(file.getCreatedAt());
        vo.setDownloadUrl("/api/workspaces/files/" + file.getId() + "/download");
        return vo;
    }

    /** 字节数转可读文本 */
    public static String humanSize(Long bytes) {
        if (bytes == null || bytes <= 0) {
            return "0 B";
        }
        if (bytes < 1024) {
            return bytes + " B";
        }
        if (bytes < 1024 * 1024) {
            return String.format("%.1f KB", bytes / 1024.0);
        }
        if (bytes < 1024L * 1024 * 1024) {
            return String.format("%.1f MB", bytes / 1024.0 / 1024.0);
        }
        return String.format("%.2f GB", bytes / 1024.0 / 1024.0 / 1024.0);
    }
}
