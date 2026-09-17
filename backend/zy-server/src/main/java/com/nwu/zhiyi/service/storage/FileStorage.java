package com.nwu.zhiyi.service.storage;

import java.io.InputStream;

/**
 * 文件存储抽象（FR-M5-03 文件传输 / FR-M9-06 存储与备份）。
 *
 * <p><b>为什么抽象出接口</b>：需求文档里"云服务器 / 云数据库 / 高性能对象存储"
 * 属于采购项（经费预算的"系统开发与云服务费"），开发期不可能先买 OSS；
 * 但业务代码不应该为此改两遍。因此把存储介质收敛到本接口，
 * 开发期用 {@code LocalFileStorage}（磁盘），采购后加一个 {@code OssFileStorage}
 * 实现即可切换，业务层零改动。
 *
 * <p>{@code storageType} 会随文件记录一起落库，便于迁移期识别历史文件的实际介质。
 *
 * @author 李泽宬
 */
public interface FileStorage {

    /**
     * 存储介质标识，与 {@code zy_collab_file.storage_type} 对应。
     *
     * @return 如 {@code LOCAL} / {@code OSS}
     */
    String storageType();

    /**
     * 保存文件。
     *
     * @param in          输入流（由调用方负责关闭）
     * @param originalName 原始文件名（用于取扩展名）
     * @param contentType MIME 类型
     * @param size        文件大小（字节），用于上限校验
     * @return 保存结果
     */
    StoredFile store(InputStream in, String originalName, String contentType, long size);

    /**
     * 读取文件内容。
     *
     * @param storagePath 存储路径（{@link StoredFile#storagePath()}）
     * @return 输入流（由调用方负责关闭）
     */
    InputStream retrieve(String storagePath);

    /**
     * 删除文件。文件不存在时不应抛异常（幂等）。
     *
     * @param storagePath 存储路径
     * @return 是否实际删除
     */
    boolean delete(String storagePath);

    /**
     * 校验文件是否可接受（大小、类型）。
     *
     * @param originalName 原始文件名
     * @param size         字节数
     * @throws com.nwu.zhiyi.common.exception.BusinessException 不满足时抛出
     */
    void validate(String originalName, long size);

    /**
     * 存储结果。
     *
     * @param storagePath 相对路径（落库用，不对外暴露）
     * @param sizeBytes   实际字节数
     * @param sha256      内容摘要
     */
    record StoredFile(String storagePath, long sizeBytes, String sha256) {
    }
}
