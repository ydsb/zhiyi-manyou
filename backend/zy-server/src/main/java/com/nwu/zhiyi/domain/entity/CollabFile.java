package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作空间文件版本实体 —— 对应表 {@code zy_collab_file}（FR-M5-03 / FR-M5-07）。
 *
 * <p><b>版本模型</b>：{@code groupKey} 标识"同一个逻辑文件"，每次上传生成一条新记录、
 * {@code version} 自增，旧版本置 {@code isLatest = 0} 但保留不删，
 * 从而支持历史版本回溯与内容对照。
 *
 * <p>{@code storagePath} 与 {@code storageType} 把存储介质抽象出来：
 * 现在是本地磁盘（LOCAL），采购云服务后切到对象存储（OSS）只需新增实现类，
 * 不动业务代码（对应 FR-M9-06 的"数据备份与存储"要求）。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_collab_file")
public class CollabFile implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 所属交换记录 ID */
    private Long recordId;

    /** 逻辑文件标识（同一文件的多版本共享） */
    private String groupKey;

    /** 版本号，从 1 自增 */
    private Integer version;

    /** 是否最新版本：1是 0否（历史版本） */
    private Integer isLatest;

    /** 原始文件名 */
    private String fileName;

    /** MIME 类型 */
    private String contentType;

    /** 文件大小（字节） */
    private Long sizeBytes;

    /** 存储类型：LOCAL / OSS */
    private String storageType;

    /** 存储路径或对象键（不对外暴露） */
    private String storagePath;

    /** 内容摘要，用于去重与完整性校验 */
    private String sha256;

    /** 关联任务项 ID（可作为该任务的交付物） */
    private Long taskId;

    /** 上传人学号 */
    private String uploaderSno;

    /** 版本说明（本次改了什么） */
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 是否最新版本 */
    public boolean isLatestVersion() {
        return isLatest != null && isLatest == 1;
    }

    /** 是否为历史版本 */
    public boolean isHistoryVersion() {
        return !isLatestVersion();
    }
}
