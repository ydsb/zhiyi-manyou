package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.CollabFile;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * 协作空间文件版本 Mapper（FR-M5-03）。
 *
 * @author 李泽宬
 */
@Mapper
public interface CollabFileMapper extends BaseMapper<CollabFile> {

    /**
     * 取某逻辑文件当前的最大版本号（用于新增版本时自增）。
     *
     * @param recordId 交换记录 ID
     * @param groupKey 逻辑文件标识
     * @return 最大版本号，不存在时返回 null
     */
    @Select("SELECT MAX(version) FROM zy_collab_file WHERE record_id = #{recordId} AND group_key = #{groupKey}")
    Integer selectMaxVersion(@Param("recordId") Long recordId, @Param("groupKey") String groupKey);

    /**
     * 把某逻辑文件的全部版本置为非最新（上传新版本前调用）。
     *
     * @param recordId 交换记录 ID
     * @param groupKey 逻辑文件标识
     * @return 影响行数
     */
    @Update("UPDATE zy_collab_file SET is_latest = 0 WHERE record_id = #{recordId} AND group_key = #{groupKey}")
    int clearLatestFlag(@Param("recordId") Long recordId, @Param("groupKey") String groupKey);

    /**
     * 某交换下的最新版本文件列表（按上传时间倒序）。
     *
     * @param recordId 交换记录 ID
     * @return 最新版本文件
     */
    @Select("SELECT * FROM zy_collab_file WHERE record_id = #{recordId} AND is_latest = 1 "
            + "ORDER BY created_at DESC")
    List<CollabFile> selectLatestByRecord(@Param("recordId") Long recordId);

    /**
     * 某交换下文件上传总次数（含历史版本），用于过程性指标中的"版本迭代频次"。
     *
     * @param recordId 交换记录 ID
     * @param uploaderSno 可选，只统计某人的上传
     * @return 次数
     */
    @Select("<script>"
            + "SELECT COUNT(*) FROM zy_collab_file WHERE record_id = #{recordId} "
            + "<if test='uploaderSno != null'> AND uploader_sno = #{uploaderSno}</if>"
            + "</script>")
    int countUploads(@Param("recordId") Long recordId, @Param("uploaderSno") String uploaderSno);
}
